/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Node/VideoNode.h"

#include "Basic/Content.h"

NS_DORA_BEGIN

class AnnexBNalSplitter {
public:
	explicit AnnexBNalSplitter(bool includeStartCode = true)
		: _includeStartCode(includeStartCode) { }

	void push(const uint8_t* data, size_t len) {
		if (!data || len == 0) return;
		_buf.insert(_buf.end(), data, data + len);
	}

	std::optional<std::vector<uint8_t>> popNal() {
		size_t sc0 = 0;
		size_t sc0_len = 0;
		if (!findStartCode(0, sc0, sc0_len)) {
			trimGarbageNoStartCode();
			return std::nullopt;
		}

		if (sc0 > 0) {
			erasePrefix(sc0);
			sc0 = 0;
		}

		size_t sc1 = 0;
		size_t sc1_len = 0;
		if (!findStartCode(sc0 + sc0_len, sc1, sc1_len)) {
			return std::nullopt;
		}

		size_t nal_begin = _includeStartCode ? sc0 : (sc0 + sc0_len);
		size_t nal_end = sc1;

		if (nal_end <= nal_begin) {
			erasePrefix(sc1);
			return std::nullopt;
		}

		std::vector<uint8_t> nal(_buf.begin() + nal_begin, _buf.begin() + nal_end);

		erasePrefix(sc1);

		return nal;
	}

	std::optional<std::vector<uint8_t>> flushLastNal() {
		size_t sc0 = 0, sc0_len = 0;
		if (!findStartCode(0, sc0, sc0_len)) return std::nullopt;

		if (sc0 > 0) {
			erasePrefix(sc0);
			sc0 = 0;
		}

		size_t nal_begin = _includeStartCode ? 0 : sc0_len;
		if (_buf.size() <= nal_begin) return std::nullopt;

		std::vector<uint8_t> nal(_buf.begin() + nal_begin, _buf.end());
		_buf.clear();
		return nal;
	}

	void clear() { _buf.clear(); }

private:
	bool findStartCode(size_t from, size_t& pos, size_t& len) const {
		const size_t n = _buf.size();
		if (n < 3 || from >= n) return false;

		for (size_t i = from; i + 3 <= n; ++i) {
			if (i + 2 < n && _buf[i] == 0x00 && _buf[i + 1] == 0x00 && _buf[i + 2] == 0x01) {
				pos = i;
				len = 3;
				return true;
			}
			if (i + 3 < n && _buf[i] == 0x00 && _buf[i + 1] == 0x00 && _buf[i + 2] == 0x00 && _buf[i + 3] == 0x01) {
				pos = i;
				len = 4;
				return true;
			}
		}
		return false;
	}

	void erasePrefix(size_t count) {
		if (count == 0) return;
		if (count >= _buf.size()) {
			_buf.clear();
			return;
		}
		std::memmove(_buf.data(), _buf.data() + count, _buf.size() - count);
		_buf.resize(_buf.size() - count);
	}

	void trimGarbageNoStartCode() {
		if (_buf.size() > 3) {
			std::vector<uint8_t> tail(_buf.end() - 3, _buf.end());
			_buf.swap(tail);
		}
	}

private:
	bool _includeStartCode = true;
	std::vector<uint8_t> _buf;
};

class VideoData : public VideoDataImpl {
public:
	virtual ~VideoData() {
		if (decoderStorage != nullptr) {
			h264bsdShutdown(decoderStorage);
			h264bsdFree(decoderStorage);
			decoderStorage = nullptr;
		}
		if (fileHandle != nullptr) {
			SDL_RWclose(fileHandle);
			fileHandle = nullptr;
		}
	}

	std::vector<uint8_t> streamBuffer;
	size_t streamBufferPos;
	std::list<std::vector<uint32_t>> frameBuffers; // RGBA buffer
	storage_t* decoderStorage = nullptr;
	SDL_RWops* fileHandle = nullptr;
	uint32_t currentPicId = 0;
	uint32_t videoWidth = 0;
	uint32_t videoHeight = 0;
	float frameRate = 0;
	bool looped = false;
	std::mutex buffersMutex;
	std::atomic<bool> stoped = false;
	static constexpr size_t CHUNK_SIZE = 64 * 1024; // 64KB chunks
	uint8_t buffer[CHUNK_SIZE];
	AnnexBNalSplitter splitter;

	bool init(String filename) {
		decoderStorage = h264bsdAlloc();
		if (!decoderStorage) {
			Error("VideoNode: failed to allocate decoder storage");
			return false;
		}

		u32 result = h264bsdInit(decoderStorage, 1); // 0 = enable output reordering
		if (result != H264BSD_RDY) {
			Error("VideoNode: failed to initialize decoder, error code: {}", result);
			h264bsdFree(decoderStorage);
			decoderStorage = nullptr;
			return false;
		}

		std::string fullPath = SharedContent.getFullPath(filename);
		fileHandle = SDL_RWFromFile(fullPath.c_str(), "rb");
		if (!fileHandle) {
			Error("VideoNode: failed to open file: {}, error: {}", fullPath, SDL_GetError());
			return false;
		}

		while (readFileChunk(true)) {
			if (videoWidth > 0 && videoHeight > 0) {
				break;
			}
		}

		if (videoWidth == 0 || videoHeight == 0 || frameRate == 0) {
			Error("VideoNode: failed to get video parameters from file {}", fullPath);
			return false;
		}

		return true;
	}

	bool readFileChunk(bool init = false) {
		if (!fileHandle) return false;

		{
			std::scoped_lock<std::mutex> lock(buffersMutex);
			if (frameRate > 0 && frameBuffers.size() >= frameRate * 2) {
				return true;
			}
		}

		size_t bytesRead = SDL_RWread(fileHandle, buffer, 1, CHUNK_SIZE);

		if (bytesRead > 0) {
			splitter.push(buffer, bytesRead);
			auto nal = splitter.popNal();
			if (!nal) return true;
			streamBuffer.insert(streamBuffer.end(), nal.value().begin(), nal.value().end());
			processVideoFrame();
			return true;
		} else if (auto nal = splitter.popNal(); nal) {
			streamBuffer.insert(streamBuffer.end(), nal.value().begin(), nal.value().end());
			processVideoFrame();
			return true;
		} else {
			if (!init && looped) {
				if (decoderStorage != nullptr) {
					h264bsdShutdown(decoderStorage);
					h264bsdFree(decoderStorage);
					decoderStorage = nullptr;
				}

				decoderStorage = h264bsdAlloc();
				if (!decoderStorage) {
					Error("VideoNode: failed to allocate decoder storage");
					return false;
				}

				u32 result = h264bsdInit(decoderStorage, 1); // 0 = enable output reordering
				if (result != H264BSD_RDY) {
					Error("VideoNode: failed to initialize decoder, error code: {}", result);
					h264bsdFree(decoderStorage);
					decoderStorage = nullptr;
					return false;
				}

				currentPicId = 0;
				streamBuffer.clear();
				streamBufferPos = 0;
				splitter.clear();
				SDL_RWseek(fileHandle, 0, RW_SEEK_SET);
			} else if (!init) {
				std::scoped_lock<std::mutex> lock(buffersMutex);
				frameBuffers.emplace_back();
			}
			return false;
		}
	}

	std::optional<std::vector<uint32_t>> getFrame() {
		std::scoped_lock<std::mutex> lock(buffersMutex);
		if (frameBuffers.empty()) {
			return std::nullopt;
		}
		auto front = std::move(frameBuffers.front());
		frameBuffers.pop_front();
		return front;
	}

	void processVideoFrame() {
		if (!decoderStorage) return;

		while (true) {
			if (streamBufferPos >= streamBuffer.size()) {
				break;
			}

			if (streamBufferPos >= 1024 * 1024 * 2) {
				streamBuffer.erase(streamBuffer.begin(), streamBuffer.begin() + streamBufferPos);
				streamBufferPos = 0;
			}

			h264bsdFlushBuffer(decoderStorage);

			uint8_t* byteStrm = streamBuffer.data() + streamBufferPos;
			u32 len = s_cast<u32>(streamBuffer.size() - streamBufferPos);
			u32 readBytes = 0;
			u32 result = h264bsdDecode(decoderStorage, byteStrm, len, currentPicId, &readBytes);

			bool hasErr = false;
			switch (result) {
				case H264BSD_RDY:
					streamBufferPos += readBytes;
					break;
				case H264BSD_HDRS_RDY: {
					streamBufferPos += readBytes;
					u32 top, left, width, height, croppingFlag;
					if (videoWidth == 0 || videoHeight == 0) {
						h264bsdCroppingParams(decoderStorage, &croppingFlag, &left, &width, &top, &height);
						if (!croppingFlag) {
							width = h264bsdPicWidth(decoderStorage) * 16;
							height = h264bsdPicHeight(decoderStorage) * 16;
						}
						videoWidth = width;
						videoHeight = height;
						parseFrameRate();
					}
					break;
				}
				case H264BSD_PIC_RDY: {
					streamBufferPos += readBytes;
					u32 picId = 0;
					u32 isIdrPic = 0;
					u32 numErrMbs = 0;
					u32* rgbaData = h264bsdNextOutputPictureRGBA(decoderStorage, &picId, &isIdrPic, &numErrMbs);
					if (rgbaData && videoWidth > 0 && videoHeight > 0) {
						size_t frameSize = videoWidth * videoHeight;
						std::vector<uint32_t> frameBuffer;
						frameBuffer.resize(frameSize);
						std::memcpy(frameBuffer.data(), rgbaData, frameSize * sizeof(uint32_t));
						{
							std::scoped_lock<std::mutex> lock(buffersMutex);
							frameBuffers.emplace_back(std::move(frameBuffer));
						}
						currentPicId++;
					}
					break;
				}
				case H264BSD_ERROR: {
					hasErr = true;
					break;
				}
				case H264BSD_PARAM_SET_ERROR:
				case H264BSD_MEMALLOC_ERROR: {
					hasErr = true;
					Error("VideoNode: decode error code: {}", result);
					break;
				}
				default: {
					hasErr = true;
					Error("VideoNode: unexpected error code: {}", result);
					break;
				}
			}
			if (readBytes == 0) {
				break;
			}
			if (hasErr) {
				break;
			}
		}
	}

	void parseFrameRate() {
		if (!decoderStorage) return;

		seqParamSet_t* activeSps = decoderStorage->activeSps;
		if (!activeSps) return;

		if (!activeSps->vuiParametersPresentFlag || !activeSps->vuiParameters) {
			return;
		}

		vuiParameters_t* vui = activeSps->vuiParameters;

		if (vui->timingInfoPresentFlag && vui->timeScale > 0 && vui->numUnitsInTick > 0) {
			frameRate = static_cast<float>(vui->timeScale) / static_cast<float>(vui->numUnitsInTick) / 2;
			if (frameRate < 1.0f || frameRate > 120.0f) {
				Warn("VideoNode: parsed frame rate {} fps seems invalid, using default 30 fps", frameRate);
				frameRate = 30.0f;
			}
		}
	}
};

VideoNode::VideoNode(String filename, bool looped)
	: _filename(filename.toString())
	, _looped(looped)
	, _frameAccumulator(0.0) {
}

VideoNode::~VideoNode() {
	cleanupResources();
}

bool VideoNode::init() {
	if (!Sprite::init()) return false;

	auto videoData = std::make_shared<VideoData>();
	_videoData = videoData;
	videoData->looped = _looped;
	if (!videoData->init(_filename)) {
		return false;
	}

	setSize({s_cast<float>(videoData->videoWidth),
		s_cast<float>(videoData->videoHeight)});

	_thread = New<Async>();
	_thread->run([videoData]() {
		while (!videoData->stoped) {
			videoData->readFileChunk();
		}
	});

	scheduleUpdate();
	return true;
}

void VideoNode::cleanup() {
	cleanupResources();
	Sprite::cleanup();
}

void VideoNode::cleanupResources() {
	if (_videoData) {
		s_cast<VideoData*>(_videoData.get())->stoped = true;
		_videoData = nullptr;
	}
}

static void releaseFrame(void*, void* userData) {
	auto buffer = r_cast<std::vector<uint32_t>*>(userData);
	delete buffer;
}

VideoNode::UpdateFlag VideoNode::updateTexture() {
	auto videoData = s_cast<VideoData*>(_videoData.get());
	if (!videoData) return UpdateFlag::Stop;

	uint32_t videoWidth = videoData->videoWidth;
	uint32_t videoHeight = videoData->videoHeight;
	if (videoWidth == 0 || videoHeight == 0) {
		return UpdateFlag::Stop;
	}

	auto frame = videoData->getFrame();
	if (!frame) {
		return UpdateFlag::Wait;
	}

	if (frame.value().empty()) {
		return UpdateFlag::Stop;
	}

	auto texture = getTexture();

	if (!texture || texture->getWidth() != s_cast<int>(videoWidth) || texture->getHeight() != s_cast<int>(videoHeight)) {

		bgfx::TextureHandle textureHandle = bgfx::createTexture2D(
			s_cast<uint16_t>(videoWidth),
			s_cast<uint16_t>(videoHeight),
			false, 1,
			bgfx::TextureFormat::RGBA8);

		if (!bgfx::isValid(textureHandle)) {
			Error("VideoNode: failed to create texture");
			return UpdateFlag::Stop;
		}

		bgfx::TextureInfo info;
		bgfx::calcTextureSize(info,
			s_cast<uint16_t>(videoWidth),
			s_cast<uint16_t>(videoHeight),
			0, false, false, 1,
			bgfx::TextureFormat::RGBA8);

		texture = Texture2D::create(textureHandle, info, BGFX_TEXTURE_NONE);
		setTexture(texture);
		setTextureRect(Rect{0.0f, 0.0f, s_cast<float>(videoData->videoWidth), s_cast<float>(videoData->videoHeight)});
	}

	if (texture) {
		auto buffer = new std::vector<uint32_t>(std::move(frame.value()));
		const bgfx::Memory* mem = bgfx::makeRef(
			buffer->data(),
			s_cast<uint32_t>(buffer->size() * sizeof(uint32_t)),
			releaseFrame,
			buffer);

		bgfx::updateTexture2D(texture->getHandle(), 0, 0, 0, 0,
			s_cast<uint16_t>(videoWidth),
			s_cast<uint16_t>(videoHeight),
			mem);
	}

	return UpdateFlag::Done;
}

bool VideoNode::update(double deltaTime) {
	auto videoData = s_cast<VideoData*>(_videoData.get());
	if (!videoData) return true;
	if (videoData->frameRate > 0.0f) {
		_frameAccumulator += deltaTime;
		double frameTime = 1.0 / videoData->frameRate;
		if (_frameAccumulator >= frameTime) {
			_frameAccumulator -= frameTime;
			if (UpdateFlag::Stop == updateTexture()) {
				return true;
			}
		}
	}
	return Sprite::update(deltaTime);
}

NS_DORA_END
