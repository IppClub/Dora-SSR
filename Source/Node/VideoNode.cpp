/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Node/VideoNode.h"

#include "Basic/Content.h"
#include "Audio/Audio.h"
#include "Node/AudioSource.h"

extern "C" {
#include "3rdParty/ogg/ogg.h"
#include "3rdParty/theora/include/theora/theoradec.h"
}

#include <algorithm>
#include <cmath>
#include <condition_variable>
#include <limits>

NS_DORA_BEGIN

namespace {

constexpr size_t MaxBufferedBytes = 32 * 1024 * 1024;

size_t bufferedFrameLimit(size_t width, size_t height, double frameRate) {
	if (width == 0 || height == 0 || !std::isfinite(frameRate) || frameRate <= 0.0
		|| width > std::numeric_limits<size_t>::max() / 4 / height) return 0;
	const size_t frameBytes = width * height * 4;
	const size_t timeLimit = static_cast<size_t>(std::clamp(std::ceil(frameRate * 2.0), 1.0, 240.0));
	// Keep at least one frame for playback, including a frame larger than the
	// queue budget. Decoder reference images and GPU uploads are separate.
	return std::max<size_t>(1, std::min(timeLimit, MaxBufferedBytes / frameBytes));
}

struct VideoFrame {
	std::vector<uint8_t> rgba;
	double time = 0.0;
	uint64_t cycle = 0;
	bool final = false;
};

class VideoData : public VideoDataImpl {
public:
	~VideoData() override {
		shutdownDecoder();
	}

	bool init(String filename) {
		auto [data, size] = SharedContent.load(filename);
		if (!data || size == 0) {
			Error("VideoNode: failed to load Ogg/Theora video through Content: {}", filename.toString());
			return false;
		}

		fileData.assign(data.get(), data.get() + size);
		if (!openStream()) {
			Error("VideoNode: invalid or unsupported Ogg/Theora video: {}", filename.toString());
			return false;
		}
		if (!buildSeekIndex() || !openStream()) return false;
		return true;
	}

	std::vector<uint8_t> extractAudio() const {
		return AudioDetail::extractOggVorbis(fileData);
	}

	// Requests and decoded frames share one lock. A serial invalidates in-flight
	// conversion too, so a superseded seek can never publish an old image.
	void seek(double target, uint64_t cycle) {
		{
			std::scoped_lock lock(framesMutex);
			seekTarget = target;
			seekCycle = cycle;
			seekPending = true;
			++requestSerial;
			frames.clear();
		}
		framesChanged.notify_all();
	}

	void decode() {
		bool atEnd = false;
		while (!stopped.load(std::memory_order_acquire)) {
			bool seeking = false;
			double target = 0.0;
			{
				std::unique_lock lock(framesMutex);
				framesChanged.wait(lock, [&]() {
					return stopped.load(std::memory_order_acquire) || seekPending
						|| (!atEnd && frames.size() < maxBufferedFrames);
				});
				if (stopped.load(std::memory_order_acquire)) break;
				if (seekPending) {
					seeking = true;
					target = seekTarget;
					decodeCycle = seekCycle;
					activeSerial = requestSerial.load();
					seekPending = false;
					atEnd = false;
				}
			}
			if (seeking && !seekDecoder(target)) {
				Error("VideoNode: failed to seek Ogg/Theora video");
				atEnd = true;
			} else if (decodeNextFrame()) {
				continue;
			}
			if (requestSerial.load() != activeSerial) continue;

			const double endTime = streamEndTime;
			const bool repeat = !atEnd && looped && !stopped.load() && openStream();
			{
				std::scoped_lock lock(framesMutex);
				if (requestSerial.load() != activeSerial) continue;
				frames.push_back({{}, endTime, decodeCycle, !repeat});
			}
			framesChanged.notify_all();
			atEnd = !repeat;
			if (repeat) ++decodeCycle;
		}
	}

	bool hasFrame() {
		std::scoped_lock lock(framesMutex);
		return !frames.empty();
	}

	std::optional<VideoFrame> getFrame(double time, uint64_t cycle) {
		std::optional<VideoFrame> result;
		{
			std::scoped_lock lock(framesMutex);
			while (!frames.empty() && frames.front().cycle == cycle && frames.front().time <= time + 1e-9) {
				// Deliver the last image before its end marker, even when catching up.
				if (result && frames.front().rgba.empty()) break;
				result = std::move(frames.front());
				frames.pop_front();
				if (result->rgba.empty()) break;
			}
		}
		if (result) framesChanged.notify_all();
		return result;
	}

	void stop() {
		stopped.store(true, std::memory_order_release);
		framesChanged.notify_all();
	}

	uint32_t videoWidth = 0;
	uint32_t videoHeight = 0;
	double frameRate = 0.0;
	double duration = 0.0;
	bool looped = false;

private:
	struct PacketPosition {
		size_t offset = 0;
		unsigned skip = 0;
	};
	struct SeekPoint {
		PacketPosition position;
		int64_t frame;
	};

	void trackPage() {
		bool discard = ogg_page_continued(&page) && !positionPending;
		unsigned starts = 0;
		for (int i = 0; i < page.header[26]; ++i) {
			if (!positionPending && !discard) {
				pendingPosition = {pageOffset, starts++};
				positionPending = true;
			}
			if (page.header[27 + i] < 255) {
				if (discard) discard = false;
				else {
					packetPositions.push_back(pendingPosition);
					positionPending = false;
				}
			}
		}
	}

	bool readPage() {
		while (ogg_sync_pageout(&sync, &page) != 1) {
			if (readPosition >= fileData.size()) return false;
			const size_t count = std::min<size_t>(8192, fileData.size() - readPosition);
			char* buffer = ogg_sync_buffer(&sync, s_cast<long>(count));
			if (!buffer) return false;
			std::memcpy(buffer, fileData.data() + readPosition, count);
			readPosition += count;
			if (ogg_sync_wrote(&sync, s_cast<long>(count)) != 0) return false;
		}
		pageOffset = readPosition - (sync.fill - sync.returned) - page.header_len - page.body_len;
		return true;
	}

	bool findTheoraStream() {
		while (readPage()) {
			if (!ogg_page_bos(&page)) break;

			ogg_stream_state candidate{};
			if (ogg_stream_init(&candidate, ogg_page_serialno(&page)) != 0) return false;
			ogg_stream_pagein(&candidate, &page);

			ogg_packet packet{};
			const bool theora = ogg_stream_packetpeek(&candidate, &packet) == 1
				&& packet.bytes >= 7
				&& (packet.packet[0] & 0x80) != 0
				&& std::memcmp(packet.packet + 1, "theora", 6) == 0;
			if (theora) {
				stream = candidate;
				streamInitialized = true;
				videoSerial = ogg_page_serialno(&page);
				pageValid = true;
				trackPage();
				return true;
			}
			ogg_stream_clear(&candidate);
		}
		return false;
	}

	bool readPacket(ogg_packet& packet) {
		if (!streamInitialized) return false;
		for (;;) {
			const int result = ogg_stream_packetout(&stream, &packet);
			if (result == 1) {
				if (packetPositions.empty()) return false;
				packetPosition = packetPositions.front();
				packetPositions.pop_front();
				return true;
			}
			if (result < 0) return false;
			if (pageValid && ogg_page_serialno(&page) == videoSerial && ogg_page_eos(&page)) return false;
			do {
				if (!readPage()) return false;
				pageValid = true;
			} while (ogg_page_serialno(&page) != videoSerial);
			trackPage();
			if (ogg_stream_pagein(&stream, &page) != 0) return false;
		}
	}

	bool buildSeekIndex() {
		int64_t frame = -1;
		size_t unanchored = 0;
		do {
			if (th_packet_isheader(&packet)) continue;
			++frame;
			if (th_packet_iskeyframe(&packet) == 1) seekPoints.push_back({packetPosition, frame});
			if (packet.granulepos >= 0) {
				const int64_t actual = th_granule_frame(decoder, packet.granulepos);
				for (size_t i = unanchored; i < seekPoints.size(); ++i) seekPoints[i].frame += actual - frame;
				unanchored = seekPoints.size();
				frame = actual;
			}
			duration = std::max(duration, (frame + 1) / frameRate);
		} while (readPacket(packet));
		return !seekPoints.empty();
	}

	bool seekDecoder(double target) {
		if (!openStream()) return false;
		auto point = std::upper_bound(seekPoints.begin(), seekPoints.end(), target,
			[this](double time, const SeekPoint& key) { return time < key.frame / frameRate; });
		if (point != seekPoints.begin()) --point;
		ogg_sync_reset(&sync);
		ogg_stream_reset(&stream);
		readPosition = point->position.offset;
		pageValid = false;
		positionPending = false;
		packetPositions.clear();
		for (unsigned i = 0; i <= point->position.skip; ++i) if (!readPacket(packet)) return false;
		const int shift = info.keyframe_granule_shift;
		const int64_t bias = 1 - th_granule_frame(decoder, int64_t(1) << shift);
		ogg_int64_t granule = (point->frame + bias) << shift;
		if (th_decode_ctl(decoder, TH_DECCTL_SET_GRANPOS, &granule, sizeof(granule)) != 0) return false;
		pendingPacket = true;
		discardBefore = target;
		return true;
	}

	bool openStream() {
		shutdownDecoder();
		readPosition = 0;
		pageValid = false;
		pendingPacket = false;
		streamEndTime = 0.0;
		discardBefore = 0.0;
		positionPending = false;
		packetPositions.clear();

		if (ogg_sync_init(&sync) != 0) return false;
		syncInitialized = true;
		th_info_init(&info);
		infoInitialized = true;
		th_comment_init(&comment);
		commentInitialized = true;

		if (!findTheoraStream()) return false;

		int result = 1;
		while (result > 0) {
			if (!readPacket(packet)) return false;
			result = th_decode_headerin(&info, &comment, &setup, &packet);
			if (result < 0) return false;
		}

		decoder = th_decode_alloc(&info, setup);
		th_setup_free(setup);
		setup = nullptr;
		if (!decoder) return false;

		const uint32_t decodedWidth = info.pic_width;
		const uint32_t decodedHeight = info.pic_height;
		if (decodedWidth == 0 || decodedHeight == 0
			|| decodedWidth > UINT16_MAX || decodedHeight > UINT16_MAX
			|| info.fps_numerator == 0 || info.fps_denominator == 0) return false;
		const double decodedFrameRate = static_cast<double>(info.fps_numerator) / info.fps_denominator;
		if (decodedFrameRate < 1.0 || decodedFrameRate > 240.0) return false;
		if (videoWidth == 0) {
			videoWidth = decodedWidth;
			videoHeight = decodedHeight;
			frameRate = decodedFrameRate;
			maxBufferedFrames = bufferedFrameLimit(videoWidth, videoHeight, frameRate);
			if (maxBufferedFrames == 0) return false;
		} else if (videoWidth != decodedWidth || videoHeight != decodedHeight
			|| frameRate != decodedFrameRate) {
			return false;
		}
		pendingPacket = true;
		return true;
	}

	bool decodeNextFrame() {
		while (!stopped.load(std::memory_order_acquire) && requestSerial.load() == activeSerial) {
			if (!pendingPacket && !readPacket(packet)) return false;
			pendingPacket = false;

			ogg_int64_t granulePosition = -1;
			if (packet.granulepos >= 0)
				th_decode_ctl(decoder, TH_DECCTL_SET_GRANPOS, &packet.granulepos, sizeof(packet.granulepos));
			const int result = th_decode_packetin(decoder, &packet, &granulePosition);
			if (result < 0) continue;
			// TH_DUPFRAME keeps the previous image for another frame interval.
			// Queue it too, otherwise static sections shorten the video timeline.

			streamEndTime = th_granule_time(decoder, granulePosition);
			// Decode reference images but publish only the requested frame. Keep
			// the final image even when seeking into a longer audio-only tail.
			if (streamEndTime <= discardBefore + 1e-9 && streamEndTime < duration - 1e-9) continue;
			th_ycbcr_buffer planes{};
			if (th_decode_ycbcr_out(decoder, planes) != 0) continue;

			VideoFrame frame;
			streamEndTime = th_granule_time(decoder, granulePosition);
			frame.time = std::max(0.0, streamEndTime - 1.0 / frameRate);
			frame.cycle = decodeCycle;
			convertFrame(planes, frame.rgba);
			{
				std::scoped_lock lock(framesMutex);
				if (requestSerial.load() != activeSerial) return false;
				frames.emplace_back(std::move(frame));
			}
			framesChanged.notify_all();
			return true;
		}
		return false;
	}

	void convertFrame(const th_ycbcr_buffer& planes, std::vector<uint8_t>& rgba) const {
		rgba.resize(static_cast<size_t>(videoWidth) * videoHeight * 4);
		const int chromaShiftX = info.pixel_fmt == TH_PF_444 ? 0 : 1;
		const int chromaShiftY = info.pixel_fmt == TH_PF_420 ? 1 : 0;

		for (uint32_t y = 0; y < videoHeight; ++y) {
			const int sourceY = s_cast<int>(y) + info.pic_y;
			const int chromaY = sourceY >> chromaShiftY;
			for (uint32_t x = 0; x < videoWidth; ++x) {
				const int sourceX = s_cast<int>(x) + info.pic_x;
				const int chromaX = sourceX >> chromaShiftX;
				const int yy = planes[0].data[sourceY * planes[0].stride + sourceX];
				const int cb = planes[1].data[chromaY * planes[1].stride + chromaX];
				const int cr = planes[2].data[chromaY * planes[2].stride + chromaX];
				const int c = std::max(0, yy - 16);
				const int d = cb - 128;
				const int e = cr - 128;
				const auto clampByte = [](int value) {
					return s_cast<uint8_t>(std::clamp(value, 0, 255));
				};
				const size_t offset = (static_cast<size_t>(y) * videoWidth + x) * 4;
				rgba[offset] = clampByte((298 * c + 409 * e + 128) >> 8);
				rgba[offset + 1] = clampByte((298 * c - 100 * d - 208 * e + 128) >> 8);
				rgba[offset + 2] = clampByte((298 * c + 516 * d + 128) >> 8);
				rgba[offset + 3] = 255;
			}
		}
	}

	void shutdownDecoder() {
		if (decoder) {
			th_decode_free(decoder);
			decoder = nullptr;
		}
		if (setup) {
			th_setup_free(setup);
			setup = nullptr;
		}
		if (commentInitialized) {
			th_comment_clear(&comment);
			commentInitialized = false;
		}
		if (infoInitialized) {
			th_info_clear(&info);
			infoInitialized = false;
		}
		if (streamInitialized) {
			ogg_stream_clear(&stream);
			streamInitialized = false;
		}
		if (syncInitialized) {
			ogg_sync_clear(&sync);
			syncInitialized = false;
		}
	}

	std::vector<uint8_t> fileData;
	size_t readPosition = 0;
	ogg_sync_state sync{};
	ogg_stream_state stream{};
	ogg_page page{};
	ogg_packet packet{};
	int videoSerial = 0;
	bool syncInitialized = false;
	bool streamInitialized = false;
	bool pageValid = false;
	bool pendingPacket = false;
	th_info info{};
	th_comment comment{};
	th_setup_info* setup = nullptr;
	th_dec_ctx* decoder = nullptr;
	bool infoInitialized = false;
	bool commentInitialized = false;
	std::deque<VideoFrame> frames;
	std::mutex framesMutex;
	std::condition_variable framesChanged;
	size_t maxBufferedFrames = 2;
	std::atomic<bool> stopped = false;
	double streamEndTime = 0.0;
	uint64_t decodeCycle = 0;
	size_t pageOffset = 0;
	PacketPosition packetPosition, pendingPosition;
	bool positionPending = false;
	std::deque<PacketPosition> packetPositions;
	std::vector<SeekPoint> seekPoints;
	std::atomic<uint64_t> requestSerial = 0;
	uint64_t activeSerial = 0;
	bool seekPending = false;
	double seekTarget = 0.0;
	uint64_t seekCycle = 0;
	double discardBefore = 0.0;
};

void releaseFrame(void*, void* userData) {
	delete r_cast<std::vector<uint8_t>*>(userData);
}

} // namespace

VideoNode::VideoNode(String filename, bool looped)
	: _filename(filename.toString())
	, _looped(looped) { }

VideoNode::~VideoNode() {
	cleanupResources();
}

bool VideoNode::init() {
	if (!Sprite::init()) return false;

	auto videoData = std::make_shared<VideoData>();
	videoData->looped = _looped;
	if (!videoData->init(_filename)) return false;
	_videoData = videoData;
	_duration = videoData->duration;
	auto audio = videoData->extractAudio();
	if (!audio.empty()) {
		auto bytes = NewArray<uint8_t>(audio.size());
		std::memcpy(bytes.get(), audio.data(), audio.size());
		if (auto file = WavStream::create(std::move(bytes), audio.size())) {
			_audioDuration = file->getDuration();
			_duration = std::max(_duration, _audioDuration);
			_audioSource = AudioSource::create(file, false);
			if (_audioSource) {
				WRef<VideoNode> self(this);
				_audioSource->slot("AudioEnd"sv, [self](Event*) {
					if (self) self->_audioEnded = true;
				});
				addChild(_audioSource, 0, "VideoAudio"sv);
			}
		}
	}

	setSize({s_cast<float>(videoData->videoWidth), s_cast<float>(videoData->videoHeight)});

	_thread = New<Async>();
	_thread->run([videoData]() { videoData->decode(); });
	scheduleUpdate();
	return true;
}

void VideoNode::cleanup() {
	cleanupResources();
	Sprite::cleanup();
}

void VideoNode::cleanupResources() {
	if (_audioSource) {
		_audioSource->stop();
		_audioSource->removeFromParent(true);
		_audioSource = nullptr;
	}
	if (_videoData) s_cast<VideoData*>(_videoData.get())->stop();
	if (_thread) {
		_thread->stop();
		_thread = nullptr;
	}
	_videoData = nullptr;
}

void VideoNode::pause() {
	_playbackTime = getCurrentTime();
	_paused = true;
	if (_audioSource) _audioSource->setPaused(true);
}

void VideoNode::resume() {
	play();
}

void VideoNode::play() {
	if (!_videoData) return;
	if (_ended) seek(0.0);
	_paused = false;
	if (_audioSource && isRunning() && _started) _audioSource->setPaused(false);
}

void VideoNode::seek(double seconds) {
	if (!_videoData || !std::isfinite(seconds)) return;
	_playbackTime = _seekTime = std::clamp(seconds, 0.0, _duration);
	if (_audioSource) _audioSource->stop();
	_started = false;
	_videoEnded = false;
	_decoderEnded = false;
	_audioEnded = false;
	_ended = _playbackTime >= _duration;
	_seeking = true;
	s_cast<VideoData*>(_videoData.get())->seek(_playbackTime, ++_cycle);
}

void VideoNode::rewind() {
	seek(0.0);
}

double VideoNode::getCurrentTime() const noexcept {
	if (_started && !_paused && !_ended && isRunning() && _audioSource && _audioSource->isPlaying())
		return std::clamp(std::max(_seekTime, _audioSource->getCurrentTime()), 0.0, _duration);
	return _playbackTime;
}

double VideoNode::getDuration() const noexcept {
	return _duration;
}

bool VideoNode::isPlaying() const noexcept {
	return _videoData && isRunning() && !_paused && !_ended;
}

void VideoNode::onEnter() {
	Sprite::onEnter();
	if (_audioSource && !_paused) _audioSource->setPaused(false);
}

void VideoNode::onExit() {
	_playbackTime = getCurrentTime();
	if (_audioSource) _audioSource->setPaused(true);
	Sprite::onExit();
}

bool VideoNode::isPaused() const {
	return _paused;
}

VideoNode::UpdateFlag VideoNode::updateTexture() {
	auto videoData = s_cast<VideoData*>(_videoData.get());
	if (!videoData) return UpdateFlag::Stop;

	auto frame = videoData->getFrame(_playbackTime, _cycle);
	if (!frame) return UpdateFlag::Wait;
	if (frame->rgba.empty()) return frame->final ? UpdateFlag::Stop : UpdateFlag::Loop;

	const uint32_t videoWidth = videoData->videoWidth;
	const uint32_t videoHeight = videoData->videoHeight;
	auto texture = getTexture();
	if (!texture || texture->getWidth() != s_cast<int>(videoWidth)
		|| texture->getHeight() != s_cast<int>(videoHeight)) {
		const bgfx::TextureHandle textureHandle = bgfx::createTexture2D(
			s_cast<uint16_t>(videoWidth), s_cast<uint16_t>(videoHeight), false, 1,
			bgfx::TextureFormat::RGBA8);
		if (!bgfx::isValid(textureHandle)) {
			Error("VideoNode: failed to create Ogg/Theora texture");
			return UpdateFlag::Stop;
		}

		bgfx::TextureInfo info;
		bgfx::calcTextureSize(info, s_cast<uint16_t>(videoWidth), s_cast<uint16_t>(videoHeight),
			0, false, false, 1, bgfx::TextureFormat::RGBA8);
		texture = Texture2D::create(textureHandle, info, BGFX_TEXTURE_NONE);
		setTexture(texture);
		setTextureRect(Rect{0.0f, 0.0f, s_cast<float>(videoWidth), s_cast<float>(videoHeight)});
	}

	auto buffer = new std::vector<uint8_t>(std::move(frame->rgba));
	const bgfx::Memory* memory = bgfx::makeRef(buffer->data(), s_cast<uint32_t>(buffer->size()),
		releaseFrame, buffer);
	bgfx::updateTexture2D(texture->getHandle(), 0, 0, 0, 0,
		s_cast<uint16_t>(videoWidth), s_cast<uint16_t>(videoHeight), memory);
	return UpdateFlag::Done;
}

bool VideoNode::beginPlayback() {
	auto videoData = s_cast<VideoData*>(_videoData.get());
	if (!videoData || _seeking || (!videoData->hasFrame() && !_videoEnded)) return false;
	_started = true;
	_audioEnded = !_audioSource || _playbackTime >= _audioDuration;
	if (_audioSource && !_audioEnded) {
		if (_audioSource->play()) {
			if (_playbackTime > 0.0) _audioSource->seek(_playbackTime);
		} else {
			Warn("VideoNode: failed to start Vorbis audio, continuing video without audio");
			_audioSource->removeFromParent(true);
			_audioSource = nullptr;
			_audioEnded = true;
		}
	}
	return true;
}

bool VideoNode::update(double deltaTime) {
	if (!_videoData) return Sprite::update(deltaTime);
	if (_seeking) {
		const auto result = updateTexture();
		if (result == UpdateFlag::Wait) return Sprite::update(deltaTime);
		_seeking = false;
		if (result == UpdateFlag::Stop || result == UpdateFlag::Loop) {
			_videoEnded = true;
			_decoderEnded = result == UpdateFlag::Stop;
		}
	}
	if (!_paused && !_ended) {
		if (!_started) {
			if (!beginPlayback()) return Sprite::update(deltaTime);
		} else if (_audioSource && _audioSource->isPlaying()) {
			_playbackTime = getCurrentTime();
		} else {
			_playbackTime = std::min(_duration, _playbackTime + deltaTime);
		}
		if (!_videoEnded) {
			const auto result = updateTexture();
			if (result == UpdateFlag::Stop || result == UpdateFlag::Loop) {
				_videoEnded = true;
				_decoderEnded = result == UpdateFlag::Stop;
			}
		}
		if (_videoEnded && (!_audioSource || _audioEnded)) {
			if (!_looped || _decoderEnded) {
				_ended = true;
				_playbackTime = _duration;
			} else {
				++_cycle;
				_playbackTime = _seekTime = 0.0;
				_started = false;
				_videoEnded = false;
				if (beginPlayback()) updateTexture();
			}
		}
	}
	// Keep lifecycle updates alive after EOF so play/seek can restart playback.
	return Sprite::update(deltaTime);
}

NS_DORA_END
