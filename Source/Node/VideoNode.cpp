/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Node/VideoNode.h"

#include "Basic/Content.h"

extern "C" {
#include "3rdParty/ogg/ogg.h"
#include "3rdParty/theora/include/theora/theoradec.h"
}

#include <algorithm>
#include <condition_variable>

NS_DORA_BEGIN

namespace {

struct VideoFrame {
	std::vector<uint8_t> rgba;
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
		return true;
	}

	void decode() {
		while (!stopped.load(std::memory_order_acquire)) {
			{
				std::unique_lock lock(framesMutex);
				framesChanged.wait(lock, [this]() {
					return stopped.load(std::memory_order_acquire) || frames.size() < maxBufferedFrames;
				});
				if (stopped.load(std::memory_order_acquire)) break;
			}

			if (decodeNextFrame()) continue;

			if (looped && !stopped.load(std::memory_order_acquire)) {
				if (openStream()) continue;
				Error("VideoNode: failed to rewind Ogg/Theora video");
			}

			{
				std::scoped_lock lock(framesMutex);
				frames.emplace_back();
			}
			framesChanged.notify_all();
			break;
		}
	}

	std::optional<VideoFrame> getFrame() {
		std::optional<VideoFrame> result;
		{
			std::scoped_lock lock(framesMutex);
			if (!frames.empty()) {
				result = std::move(frames.front());
				frames.pop_front();
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
	bool looped = false;

private:
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
				return true;
			}
			ogg_stream_clear(&candidate);
		}
		return false;
	}

	bool readPacket(ogg_packet& packet) {
		if (!streamInitialized) return false;
		while (ogg_stream_packetout(&stream, &packet) != 1) {
			if (pageValid && ogg_page_serialno(&page) == videoSerial && ogg_page_eos(&page)) return false;
			do {
				if (!readPage()) return false;
				pageValid = true;
			} while (ogg_page_serialno(&page) != videoSerial);
			if (ogg_stream_pagein(&stream, &page) != 0) return false;
		}
		return true;
	}

	bool openStream() {
		shutdownDecoder();
		readPosition = 0;
		pageValid = false;
		pendingPacket = false;

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
			maxBufferedFrames = std::clamp<size_t>(static_cast<size_t>(std::ceil(frameRate * 2.0)), 2, 240);
		} else if (videoWidth != decodedWidth || videoHeight != decodedHeight
			|| frameRate != decodedFrameRate) {
			return false;
		}
		pendingPacket = true;
		return true;
	}

	bool decodeNextFrame() {
		while (!stopped.load(std::memory_order_acquire)) {
			if (!pendingPacket && !readPacket(packet)) return false;
			pendingPacket = false;

			ogg_int64_t granulePosition = -1;
			const int result = th_decode_packetin(decoder, &packet, &granulePosition);
			if (result < 0) continue;
			if (result > 0) continue;

			th_ycbcr_buffer planes{};
			if (th_decode_ycbcr_out(decoder, planes) != 0) continue;

			VideoFrame frame;
			convertFrame(planes, frame.rgba);
			{
				std::scoped_lock lock(framesMutex);
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
};

void releaseFrame(void*, void* userData) {
	delete r_cast<std::vector<uint8_t>*>(userData);
}

} // namespace

VideoNode::VideoNode(String filename, bool looped)
	: _filename(filename.toString())
	, _looped(looped)
	, _frameAccumulator(0.0)
	, _paused(false) { }

VideoNode::~VideoNode() {
	cleanupResources();
}

bool VideoNode::init() {
	if (!Sprite::init()) return false;

	auto videoData = std::make_shared<VideoData>();
	videoData->looped = _looped;
	if (!videoData->init(_filename)) return false;
	_videoData = videoData;

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
	if (_videoData) s_cast<VideoData*>(_videoData.get())->stop();
	if (_thread) {
		_thread->stop();
		_thread = nullptr;
	}
	_videoData = nullptr;
}

void VideoNode::pause() {
	_paused = true;
}

void VideoNode::resume() {
	_paused = false;
}

bool VideoNode::isPaused() const {
	return _paused;
}

VideoNode::UpdateFlag VideoNode::updateTexture() {
	auto videoData = s_cast<VideoData*>(_videoData.get());
	if (!videoData) return UpdateFlag::Stop;

	auto frame = videoData->getFrame();
	if (!frame) return UpdateFlag::Wait;
	if (frame->rgba.empty()) return UpdateFlag::Stop;

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

bool VideoNode::update(double deltaTime) {
	auto videoData = s_cast<VideoData*>(_videoData.get());
	if (!videoData) return true;
	if (!_paused && videoData->frameRate > 0.0) {
		_frameAccumulator += deltaTime;
		const double frameTime = 1.0 / videoData->frameRate;
		if (_frameAccumulator >= frameTime) {
			_frameAccumulator = std::fmod(_frameAccumulator, frameTime);
			if (updateTexture() == UpdateFlag::Stop) return true;
		}
	}
	return Sprite::update(deltaTime);
}

NS_DORA_END
