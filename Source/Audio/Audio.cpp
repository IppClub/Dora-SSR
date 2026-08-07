/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Audio/Audio.h"

#include "Basic/Application.h"
#include "Basic/Content.h"
#include "Basic/Director.h"
#include "Basic/Scheduler.h"
#include "Cache/AudioCache.h"
#include "Node/Node.h"

#include "soloud_wav.h"
#include "soloud_wavstream.h"
#include "soloud_openmpt.h"

#include "libopenmpt/libopenmpt/libopenmpt.h"

#include "soloud_bassboostfilter.h"
#include "soloud_biquadresonantfilter.h"
#include "soloud_dcremovalfilter.h"
#include "soloud_echofilter.h"
#include "soloud_eqfilter.h"
#include "soloud_fftfilter.h"
#include "soloud_flangerfilter.h"
#include "soloud_freeverbfilter.h"
#include "soloud_lofifilter.h"
#include "soloud_robotizefilter.h"
#include "soloud_waveshaperfilter.h"

#include "ogg/ogg.h"
#include "vorbis/vorbisenc.h"

#include <algorithm>
#include <array>
#include <atomic>
#include <cstdio>
#include <cstring>
#include <deque>
#include <filesystem>
#include <fstream>
#include <mutex>
#include <vector>

namespace {

uint16_t readLE16(const uint8_t* data) {
	return static_cast<uint16_t>(static_cast<uint16_t>(data[0]) | (static_cast<uint16_t>(data[1]) << 8));
}

uint32_t readLE32(const uint8_t* data) {
	return static_cast<uint32_t>(data[0])
		| (static_cast<uint32_t>(data[1]) << 8)
		| (static_cast<uint32_t>(data[2]) << 16)
		| (static_cast<uint32_t>(data[3]) << 24);
}

void setOggError(char* buffer, size_t capacity, const char* message) {
	if (!buffer || capacity == 0) return;
	std::snprintf(buffer, capacity, "%s", message);
}

std::filesystem::path oggPath(const char* value) {
#if defined(__cpp_char8_t)
	return std::filesystem::path(reinterpret_cast<const char8_t*>(value));
#else
	return std::filesystem::u8path(value);
#endif
}

} // namespace

extern "C" int32_t dora_audio_encode_wav_to_ogg(
	const char* inputPath,
	const char* outputPath,
	float quality,
	void (*progress)(float, void*),
	void* userData,
	float progressStart,
	float progressEnd,
	uint64_t* bytesWritten,
	char* error,
	size_t errorCapacity) {
	if (bytesWritten) *bytesWritten = 0;
	if (error && errorCapacity > 0) error[0] = '\0';
	if (!inputPath || !outputPath || !bytesWritten) {
		setOggError(error, errorCapacity, "invalid Ogg encoder arguments");
		return 0;
	}

	try {
		std::ifstream input(oggPath(inputPath), std::ios::binary);
		if (!input) {
			setOggError(error, errorCapacity, "failed to open WAV input");
			return 0;
		}
		std::array<uint8_t, 44> header {};
		input.read(reinterpret_cast<char*>(header.data()), static_cast<std::streamsize>(header.size()));
		if (input.gcount() != static_cast<std::streamsize>(header.size())
			|| std::memcmp(header.data(), "RIFF", 4) != 0
			|| std::memcmp(header.data() + 8, "WAVE", 4) != 0
			|| std::memcmp(header.data() + 12, "fmt ", 4) != 0
			|| readLE16(header.data() + 20) != 1
			|| readLE16(header.data() + 34) != 16
			|| std::memcmp(header.data() + 36, "data", 4) != 0) {
			setOggError(error, errorCapacity, "generated WAV has an unsupported format");
			return 0;
		}
		const uint16_t channels = readLE16(header.data() + 22);
		const uint32_t sampleRate = readLE32(header.data() + 24);
		const uint32_t dataSize = readLE32(header.data() + 40);
		const size_t frameSize = static_cast<size_t>(channels) * sizeof(int16_t);
		if (channels == 0 || sampleRate == 0 || dataSize % frameSize != 0) {
			setOggError(error, errorCapacity, "generated WAV contains invalid PCM data");
			return 0;
		}

		std::ofstream output(oggPath(outputPath), std::ios::binary | std::ios::trunc);
		if (!output) {
			setOggError(error, errorCapacity, "failed to create Ogg output");
			return 0;
		}

		vorbis_info info;
		vorbis_info_init(&info);
		if (vorbis_encode_init_vbr(&info, channels, sampleRate, quality) != 0) {
			vorbis_info_clear(&info);
			setOggError(error, errorCapacity, "failed to initialize Ogg encoder");
			return 0;
		}
		vorbis_comment comment;
		vorbis_comment_init(&comment);
		vorbis_comment_add_tag(&comment, const_cast<char*>("ENCODER"), const_cast<char*>("Dora SSR"));
		vorbis_dsp_state dsp;
		vorbis_analysis_init(&dsp, &info);
		vorbis_block block;
		vorbis_block_init(&dsp, &block);
		ogg_stream_state stream;
		static std::atomic<uint32_t> nextSerial {0};
		const int serial = static_cast<int>(nextSerial.fetch_add(1, std::memory_order_relaxed) + 1);
		ogg_stream_init(&stream, serial);

		auto cleanup = [&]() {
			ogg_stream_clear(&stream);
			vorbis_block_clear(&block);
			vorbis_dsp_clear(&dsp);
			vorbis_comment_clear(&comment);
			vorbis_info_clear(&info);
		};
		auto writePage = [&](const ogg_page& page) {
			output.write(reinterpret_cast<const char*>(page.header), page.header_len);
			output.write(reinterpret_cast<const char*>(page.body), page.body_len);
			*bytesWritten += static_cast<uint64_t>(page.header_len + page.body_len);
			return output.good();
		};

		ogg_packet headerPacket;
		ogg_packet commentPacket;
		ogg_packet codePacket;
		if (vorbis_analysis_headerout(&dsp, &comment, &headerPacket, &commentPacket, &codePacket) != 0) {
			cleanup();
			setOggError(error, errorCapacity, "failed to create Ogg headers");
			return 0;
		}
		ogg_stream_packetin(&stream, &headerPacket);
		ogg_stream_packetin(&stream, &commentPacket);
		ogg_stream_packetin(&stream, &codePacket);
		ogg_page page;
		while (ogg_stream_flush(&stream, &page)) {
			if (!writePage(page)) {
				cleanup();
				setOggError(error, errorCapacity, "failed to write Ogg headers");
				return 0;
			}
		}

		constexpr size_t BlockFrames = 4096;
		const uint64_t totalFrames = dataSize / frameSize;
		uint64_t encodedFrames = 0;
		std::vector<int16_t> pcm(BlockFrames * channels);
		bool eos = false;
		while (!eos) {
			const uint64_t remaining = totalFrames - encodedFrames;
			const size_t frames = static_cast<size_t>(std::min<uint64_t>(BlockFrames, remaining));
			if (frames > 0) {
				const size_t byteCount = frames * frameSize;
				input.read(reinterpret_cast<char*>(pcm.data()), static_cast<std::streamsize>(byteCount));
				if (input.gcount() != static_cast<std::streamsize>(byteCount)) {
					cleanup();
					setOggError(error, errorCapacity, "failed to read WAV PCM data");
					return 0;
				}
				float** buffer = vorbis_analysis_buffer(&dsp, static_cast<int>(frames));
				for (size_t frame = 0; frame < frames; ++frame) {
					for (uint16_t channel = 0; channel < channels; ++channel) {
						buffer[channel][frame] = pcm[frame * channels + channel] / 32768.0f;
					}
				}
				vorbis_analysis_wrote(&dsp, static_cast<int>(frames));
				encodedFrames += frames;
				if (progress) {
					const float ratio = totalFrames == 0 ? 1.0f : static_cast<float>(encodedFrames) / static_cast<float>(totalFrames);
					progress(progressStart + (progressEnd - progressStart) * ratio, userData);
				}
			} else {
				vorbis_analysis_wrote(&dsp, 0);
			}

			while (vorbis_analysis_blockout(&dsp, &block) == 1) {
				vorbis_analysis(&block, nullptr);
				vorbis_bitrate_addblock(&block);
				ogg_packet packet;
				while (vorbis_bitrate_flushpacket(&dsp, &packet)) {
					ogg_stream_packetin(&stream, &packet);
					while (!eos && ogg_stream_pageout(&stream, &page)) {
						if (!writePage(page)) {
							cleanup();
							setOggError(error, errorCapacity, "failed while writing Ogg audio");
							return 0;
						}
						eos = ogg_page_eos(&page) != 0;
					}
				}
			}
		}

		output.flush();
		const bool succeeded = output.good();
		cleanup();
		if (!succeeded) {
			setOggError(error, errorCapacity, "failed to flush Ogg output");
			return 0;
		}
		return 1;
	} catch (const std::exception& exception) {
		setOggError(error, errorCapacity, exception.what());
		return 0;
	} catch (...) {
		setOggError(error, errorCapacity, "unexpected Ogg encoder failure");
		return 0;
	}
}

void soloud_stop_voice(uint32_t handle) {
	SharedApplication.invokeInLogic([handle]() {
		SharedAudio.removeRef(handle);
	});
}

NS_DORA_BEGIN

uint32_t AudioFile::_count = 0;
uint64_t AudioFile::_storageSize = 0;

uint32_t AudioFile::getCount() {
	return _count;
}

uint64_t AudioFile::getStorageSize() {
	return _storageSize;
}

/* WavFile */

SoLoud::AudioSource* WavFile::getSource() const {
	return _wav;
}

double WavFile::getDuration() const {
	return _wav ? _wav->getLength() : 0.0;
}

double WavFile::getSampleRate() const {
	return _wav ? _wav->mBaseSamplerate : 0.0;
}

uint64_t WavFile::getSampleCount() const {
	return _wav ? _wav->mSampleCount : 0;
}

uint32_t WavFile::getChannelCount() const {
	return _wav ? _wav->mChannels : 0;
}

WavFile::WavFile(OwnArray<uint8_t>&& data, size_t size)
	: _wav(nullptr)
	, _data(std::move(data))
	, _size(size) {
	_count++;
	_storageSize += _size;
}

WavFile::~WavFile() {
	_count--;
	_storageSize -= _size;
	if (_wav) {
		delete _wav;
		_wav = nullptr;
	}
}

bool WavFile::init() {
	_wav = new SoLoud::Wav();
	SoLoud::result result = _wav->loadMem(_data.get(), s_cast<uint32_t>(_size), false, false);
	_data.reset();
	if (result) {
		delete _wav;
		_wav = nullptr;
		Error("failed to load sound file due to reason: {}.", SharedAudio.getSoLoud() ? SharedAudio.getSoLoud()->getErrorString(result) : "soloud is not initialized");
		return false;
	}
	return true;
}

/* WavStream */

SoLoud::AudioSource* WavStream::getSource() const {
	return _stream;
}

double WavStream::getDuration() const {
	return _stream ? _stream->getLength() : 0.0;
}

double WavStream::getSampleRate() const {
	return _stream ? _stream->mBaseSamplerate : 0.0;
}

uint64_t WavStream::getSampleCount() const {
	return _stream ? _stream->mSampleCount : 0;
}

uint32_t WavStream::getChannelCount() const {
	return _stream ? _stream->mChannels : 0;
}

bool WavStream::init() {
	_stream = new SoLoud::WavStream();
	SoLoud::result result = _stream->loadMem(_data.get(), s_cast<uint32_t>(_size), false, false);
	if (result) {
		delete _stream;
		_stream = nullptr;
		Error("failed to load sound file due to reason: {}.", SharedAudio.getSoLoud() ? SharedAudio.getSoLoud()->getErrorString(result) : "soloud is not initialized");
		return false;
	}
	return true;
}

WavStream::WavStream(OwnArray<uint8_t>&& data, size_t size)
	: _stream(nullptr)
	, _data(std::move(data))
	, _size(size) {
	_count++;
	_storageSize += _size;
}

WavStream::~WavStream() {
	_count--;
	_storageSize -= _size;
	if (_stream) {
		delete _stream;
		_stream = nullptr;
	}
}

/* OpenmptFile */

SoLoud::AudioSource* OpenmptFile::getSource() const {
	return _openmpt;
}

double OpenmptFile::getDuration() const {
	return _duration;
}

double OpenmptFile::getSampleRate() const {
	return _openmpt ? _openmpt->mBaseSamplerate : 0.0;
}

uint64_t OpenmptFile::getSampleCount() const {
	return _openmpt ? static_cast<uint64_t>(_duration * _openmpt->mBaseSamplerate) : 0;
}

uint32_t OpenmptFile::getChannelCount() const {
	return _openmpt ? _openmpt->mChannels : 0;
}

OpenmptFile::OpenmptFile(OwnArray<uint8_t>&& data, size_t size)
	: _data(std::move(data))
	, _size(size)
	, _duration(0.0)
	, _openmpt(nullptr) {
	_count++;
	_storageSize += _size;
}

OpenmptFile::~OpenmptFile() {
	_count--;
	_storageSize -= _size;
	delete _openmpt;
}

bool OpenmptFile::init() {
	_openmpt = new SoLoud::Openmpt();
	const SoLoud::result result = _openmpt->loadMem(
		_data.get(), static_cast<unsigned int>(_size), false, false);
	if (result != SoLoud::SO_NO_ERROR) {
		delete _openmpt;
		_openmpt = nullptr;
		Error("failed to load tracker module due to reason: {}.",
			SharedAudio.getSoLoud() ? SharedAudio.getSoLoud()->getErrorString(result) : "soloud is not initialized");
		return false;
	}
	if (auto* module = openmpt_module_create_from_memory(
			_data.get(), _size, nullptr, nullptr, nullptr)) {
		_duration = openmpt_module_get_duration_seconds(module);
		openmpt_module_destroy(module);
	}
	_data.reset();
	return true;
}

/* PCMQueueFile */

class PCMQueueFile::QueueSource : public SoLoud::AudioSource {
public:
	struct Buffer {
		std::vector<float> samples;
		uint32_t frames = 0;
		uint32_t offset = 0;
	};

	class Instance : public SoLoud::AudioSourceInstance {
	public:
		explicit Instance(QueueSource* parent)
			: _parent(parent) { }

		virtual unsigned int getAudio(float* output, unsigned int samplesToRead,
			unsigned int bufferSize) override {
			return _parent->read(output, samplesToRead, bufferSize);
		}

		virtual bool hasEnded() override {
			return _parent->empty();
		}

		virtual SoLoud::result seek(double seconds, float*, unsigned int) override {
			_parent->discard(static_cast<uint64_t>(seconds * _parent->_sampleRate));
			mStreamPosition = seconds;
			return SoLoud::SO_NO_ERROR;
		}

	private:
		QueueSource* _parent;
	};

	QueueSource(uint32_t sampleRate, uint32_t bitDepth, uint32_t channels, uint32_t buffers)
		: _sampleRate(sampleRate)
		, _bitDepth(bitDepth)
		, _channels(channels)
		, _capacity(buffers) {
		mBaseSamplerate = static_cast<float>(sampleRate);
		mChannels = channels;
		setSingleInstance(true);
	}

	virtual Instance* createInstance() override {
		return new Instance(this);
	}

	bool queue(std::span<const uint8_t> pcm) {
		const uint32_t bytesPerFrame = _channels * (_bitDepth / 8);
		if (pcm.size() % bytesPerFrame != 0)
			return false;
		if (pcm.empty())
			return true;
		std::lock_guard<std::mutex> lock(_mutex);
		if (_buffers.size() >= _capacity)
			return false;

		Buffer buffer;
		buffer.frames = static_cast<uint32_t>(pcm.size() / bytesPerFrame);
		buffer.samples.resize(static_cast<size_t>(buffer.frames) * _channels);
		for (uint32_t frame = 0; frame < buffer.frames; ++frame) {
			for (uint32_t channel = 0; channel < _channels; ++channel) {
				const size_t input = static_cast<size_t>(frame) * bytesPerFrame
					+ channel * (_bitDepth / 8);
				float sample = 0.0f;
				if (_bitDepth == 8) {
					sample = (static_cast<int>(pcm[input]) - 128) * (1.0f / 128.0f);
				} else {
					int value = static_cast<int>(pcm[input])
						| (static_cast<int>(pcm[input + 1]) << 8);
					if (value >= 0x8000) value -= 0x10000;
					sample = value * (1.0f / 32768.0f);
				}
				buffer.samples[static_cast<size_t>(channel) * buffer.frames + frame] = sample;
			}
		}
		_queuedFrames += buffer.frames;
		_buffers.push_back(std::move(buffer));
		return true;
	}

	void clear() {
		std::lock_guard<std::mutex> lock(_mutex);
		_buffers.clear();
		_queuedFrames = 0;
	}

	uint32_t getFreeBufferCount() const {
		std::lock_guard<std::mutex> lock(_mutex);
		return _capacity - static_cast<uint32_t>(_buffers.size());
	}

	uint64_t getQueuedFrames() const {
		std::lock_guard<std::mutex> lock(_mutex);
		return _queuedFrames;
	}

private:
	unsigned int read(float* output, unsigned int samplesToRead, unsigned int bufferSize) {
		std::lock_guard<std::mutex> lock(_mutex);
		unsigned int written = 0;
		while (written < samplesToRead && !_buffers.empty()) {
			auto& buffer = _buffers.front();
			const uint32_t available = buffer.frames - buffer.offset;
			const uint32_t count = std::min<uint32_t>(available, samplesToRead - written);
			for (uint32_t channel = 0; channel < _channels; ++channel) {
				std::copy_n(buffer.samples.data()
						+ static_cast<size_t>(channel) * buffer.frames + buffer.offset,
					count, output + static_cast<size_t>(channel) * bufferSize + written);
			}
			buffer.offset += count;
			written += count;
			if (buffer.offset == buffer.frames) {
				_queuedFrames -= buffer.frames;
				_buffers.pop_front();
			}
		}
		return written;
	}

	bool empty() const {
		std::lock_guard<std::mutex> lock(_mutex);
		return _buffers.empty();
	}

	void discard(uint64_t frames) {
		std::lock_guard<std::mutex> lock(_mutex);
		while (frames > 0 && !_buffers.empty()) {
			auto& buffer = _buffers.front();
			const uint32_t available = buffer.frames - buffer.offset;
			if (frames < available) {
				buffer.offset += static_cast<uint32_t>(frames);
				break;
			}
			frames -= available;
			_queuedFrames -= buffer.frames;
			_buffers.pop_front();
		}
	}

	uint32_t _sampleRate;
	uint32_t _bitDepth;
	uint32_t _channels;
	uint32_t _capacity;
	mutable std::mutex _mutex;
	std::deque<Buffer> _buffers;
	uint64_t _queuedFrames = 0;
};

PCMQueueFile::PCMQueueFile(uint32_t sampleRate, uint32_t bitDepth,
	uint32_t channels, uint32_t buffers)
	: _sampleRate(sampleRate)
	, _bitDepth(bitDepth)
	, _channels(channels)
	, _buffers(buffers < 1 ? 8 : std::min<uint32_t>(buffers, 64))
	, _queue(nullptr) {
	_count++;
}

PCMQueueFile::~PCMQueueFile() {
	_count--;
	delete _queue;
	_queue = nullptr;
}

bool PCMQueueFile::init() {
	if (_sampleRate == 0 || (_bitDepth != 8 && _bitDepth != 16)
		|| (_channels != 1 && _channels != 2))
		return false;
	_queue = new QueueSource(_sampleRate, _bitDepth, _channels, _buffers);
	return true;
}

SoLoud::AudioSource* PCMQueueFile::getSource() const {
	return _queue;
}

double PCMQueueFile::getDuration() const {
	return _queue ? static_cast<double>(_queue->getQueuedFrames()) / _sampleRate : 0.0;
}

double PCMQueueFile::getSampleRate() const {
	return _sampleRate;
}

uint64_t PCMQueueFile::getSampleCount() const {
	return _queue ? _queue->getQueuedFrames() : 0;
}

uint32_t PCMQueueFile::getChannelCount() const {
	return _channels;
}

bool PCMQueueFile::queue(std::span<const uint8_t> pcm) {
	return _queue && _queue->queue(pcm);
}

void PCMQueueFile::clear() {
	if (_queue) _queue->clear();
}

uint32_t PCMQueueFile::getFreeBufferCount() const {
	return _queue ? _queue->getFreeBufferCount() : 0;
}

uint32_t PCMQueueFile::getBitDepth() const {
	return _bitDepth;
}

uint32_t PCMQueueFile::getBufferCount() const {
	return _buffers;
}

/* AudioBus */

AudioBus::AudioBus(AudioBus* parent)
	: _bus(new SoLoud::Bus())
	, _filters(nullptr)
	, _handle(0)
	, _parent(parent) {
}

AudioBus::~AudioBus() {
	if (_handle != 0) {
		if (auto soloud = SharedAudio.getSoLoud()) soloud->stop(_handle);
		_handle = 0;
	}
	if (_bus) {
		delete _bus;
		_bus = nullptr;
	}
	if (_filters) {
		for (int i = 0; i < FILTERS_PER_STREAM; i++) {
			delete _filters[i];
		}
		delete[] _filters;
		_filters = nullptr;
	}
}

bool AudioBus::init() {
	auto soloud = SharedAudio.getSoLoud();
	if (!soloud) return false;
	_handle = soloud->play(*_bus, 1.0f, 0.0f, false, _parent ? _parent->getHandle() : 0);
	if (_handle == 0) return false;
	soloud->setProtectVoice(_handle, true);
	// SoLoud::Bus keeps a separate channel handle which its mixer uses to
	// select child voices. Directly routing children through Soloud::play does
	// not initialize that field, so resolve it as soon as the bus is playing.
	_bus->findBusHandle();
	return Object::init();
}

void AudioBus::setPan(float var) {
	if (auto soloud = SharedAudio.getSoLoud()) soloud->setPan(_handle, var);
}

float AudioBus::getPan() const noexcept {
	if (auto soloud = SharedAudio.getSoLoud()) return soloud->getPan(_handle);
	return 0.0f;
}

void AudioBus::setVolume(float var) {
	if (auto soloud = SharedAudio.getSoLoud()) soloud->setVolume(_handle, var);
}

float AudioBus::getVolume() const noexcept {
	if (auto soloud = SharedAudio.getSoLoud()) return soloud->getVolume(_handle);
	return 0.0f;
}

void AudioBus::setPlaySpeed(float var) {
	if (auto soloud = SharedAudio.getSoLoud()) soloud->setRelativePlaySpeed(_handle, var);
}

float AudioBus::getPlaySpeed() const noexcept {
	if (auto soloud = SharedAudio.getSoLoud()) return soloud->getRelativePlaySpeed(_handle);
	return 0.0f;
}

uint32_t AudioBus::getHandle() const noexcept {
	return _handle;
}

void AudioBus::fadeVolume(double time, float toVolume) {
	if (auto soloud = SharedAudio.getSoLoud()) soloud->fadeVolume(_handle, toVolume, time);
}

void AudioBus::fadePan(double time, float toPan) {
	if (auto soloud = SharedAudio.getSoLoud()) soloud->fadePan(_handle, toPan, time);
}

void AudioBus::fadePlaySpeed(double time, float toPlaySpeed) {
	if (auto soloud = SharedAudio.getSoLoud()) soloud->fadeRelativePlaySpeed(_handle, toPlaySpeed, time);
}

void AudioBus::setFilter(uint32_t index, String name) {
	if (!_filters) {
		_filters = new SoLoud::Filter*[FILTERS_PER_STREAM];
		std::fill(_filters, _filters + FILTERS_PER_STREAM, nullptr);
	}
	if (index >= FILTERS_PER_STREAM) {
		Error("filter index {} out of range, max is {}", index, FILTERS_PER_STREAM - 1);
		return;
	}
	// Bus::setFilter replaces the live instance under SoLoud's audio mutex.
	// Detach it before deleting the owning filter object, since several filter
	// instances retain a pointer to that object while the mixer is running.
	if (_filters[index]) {
		_bus->setFilter(index, nullptr);
		delete _filters[index];
		_filters[index] = nullptr;
	}
	switch (Switch::hash(name)) {
		case ""_hash: {
			if (_filters[index]) {
				delete _filters[index];
				_filters[index] = nullptr;
			}
			_bus->setFilter(index, nullptr);
			break;
		}
		case "BassBoost"_hash: {
			if (_filters[index]) {
				delete _filters[index];
			}
			_filters[index] = new SoLoud::BassboostFilter();
			_bus->setFilter(index, _filters[index]);
			break;
		}
		case "BiquadResonant"_hash: {
			if (_filters[index]) {
				delete _filters[index];
			}
			_filters[index] = new SoLoud::BiquadResonantFilter();
			_bus->setFilter(index, _filters[index]);
			break;
		}
		case "DCRemoval"_hash: {
			if (_filters[index]) {
				delete _filters[index];
			}
			_filters[index] = new SoLoud::DCRemovalFilter();
			_bus->setFilter(index, _filters[index]);
			break;
		}
		case "Echo"_hash: {
			if (_filters[index]) {
				delete _filters[index];
			}
			_filters[index] = new SoLoud::EchoFilter();
			_bus->setFilter(index, _filters[index]);
			break;
		}
		case "Eq"_hash: {
			if (_filters[index]) {
				delete _filters[index];
			}
			_filters[index] = new SoLoud::EqFilter();
			_bus->setFilter(index, _filters[index]);
			break;
		}
		case "FFT"_hash: {
			if (_filters[index]) {
				delete _filters[index];
			}
			_filters[index] = new SoLoud::FFTFilter();
			_bus->setFilter(index, _filters[index]);
			break;
		}
		case "Flanger"_hash: {
			if (_filters[index]) {
				delete _filters[index];
			}
			_filters[index] = new SoLoud::FlangerFilter();
			_bus->setFilter(index, _filters[index]);
			break;
		}
		case "FreeVerb"_hash: {
			if (_filters[index]) {
				delete _filters[index];
			}
			_filters[index] = new SoLoud::FreeverbFilter();
			_bus->setFilter(index, _filters[index]);
			break;
		}
		case "Lofi"_hash: {
			if (_filters[index]) {
				delete _filters[index];
			}
			_filters[index] = new SoLoud::LofiFilter();
			_bus->setFilter(index, _filters[index]);
			break;
		}
		case "Robotize"_hash: {
			if (_filters[index]) {
				delete _filters[index];
			}
			_filters[index] = new SoLoud::RobotizeFilter();
			_bus->setFilter(index, _filters[index]);
			break;
		}
		case "WaveShaper"_hash: {
			if (_filters[index]) {
				delete _filters[index];
			}
			_filters[index] = new SoLoud::WaveShaperFilter();
			_bus->setFilter(index, _filters[index]);
			break;
		}
		default:
			Error("unsupported filter \"{}\"", name.toString());
			break;
	}
}

void AudioBus::setFilterParameter(uint32_t index, uint32_t attrId, float value) {
	if (auto soloud = SharedAudio.getSoLoud()) soloud->setFilterParameter(_handle, index, attrId, value);
}

float AudioBus::getFilterParameter(uint32_t index, uint32_t attrId) {
	if (auto soloud = SharedAudio.getSoLoud()) return soloud->getFilterParameter(_handle, index, attrId);
	return 0.0f;
}

void AudioBus::fadeFilterParameter(uint32_t index, uint32_t attrId, float to, double time) {
	if (auto soloud = SharedAudio.getSoLoud()) soloud->fadeFilterParameter(_handle, index, attrId, to, time);
}

/* Audio */

Audio::Audio()
	: _paused(false)
	, _currentVoice(0)
	, _soloud(nullptr) { }

SoLoud::Soloud* Audio::getSoLoud() {
	return _soloud;
}

Audio::~Audio() {
	if (_soloud) {
		_soloud->deinit();
		delete _soloud;
		_soloud = nullptr;
	}
}

bool Audio::init() {
	_soloud = new SoLoud::Soloud();
	SoLoud::result result = _soloud->init(SoLoud::Soloud::CLIP_ROUNDOFF, DORA_AUDIO_BACKEND, DORA_SAMPLERATE);
	if (result) {
		Warn("SoLoud backend failed ({}), audio disabled.", _soloud->getErrorString(result));
		delete _soloud;
		_soloud = nullptr;
		return false;
	}
	// Love Source filters are hosted by per-Source SoLoud buses, and each
	// LoveNode owns one parent bus. Keep 255 internal routing slots (the limit
	// of SoLoud's 8-bit resampler-owner table), but keep only the 32 strongest
	// leaf voices active. Other Sources retain valid handles and may re-enter
	// the same active list after a later volume/3D/lifecycle reorder.
	result = _soloud->setMaxActiveVoiceCount(255);
	if (result) {
		Warn("SoLoud active voice capacity could not be raised ({}).",
			_soloud->getErrorString(result));
	}
	result = _soloud->setMaxActiveSourceVoiceCount(32);
	if (result) {
		Warn("SoLoud active Source voice budget could not be configured ({}).",
			_soloud->getErrorString(result));
	}
	SharedDirector.getSystemScheduler()->schedule([this](double deltaTime) {
		if (_listener) {
			Vec4 point;
			Matrix::mulVec4(point, _listener->getWorld(), {0.0f, 0.0f, 0.0f, 1.0f});
			_soloud->set3dListenerPosition(point.x, point.y, point.z);
		}
		_soloud->update3dAudio();
		return false;
	});
	_soloud->set3dListenerUp(0, 1.0f, 0);
	_soloud->set3dListenerAt(0, 0, 1.0f);
	return true;
}

uint32_t Audio::play(String filename, bool loop) {
	if (!_soloud) return 0;
	if (auto audioFile = SharedAudioCache.load(filename)) {
		uint32_t handle = _soloud->play(*audioFile->getSource());
		if (handle == 0) return 0;
		_soloud->setLooping(handle, loop);
		SharedAudio.addRef(handle, audioFile, nullptr);
		return handle;
	}
	return 0;
}

void Audio::stop(uint32_t handle) {
	if (_soloud) _soloud->stop(handle);
}

void Audio::playStream(String filename, bool loop, float crossFadeTime) {
	if (!_soloud) return;
	stopStream(crossFadeTime);
	std::string file(filename);
	SharedContent.loadAsyncUnsafe(filename, [file, this, crossFadeTime, loop](uint8_t* data, int64_t size) {
		if (!_soloud) return;
		if (_currentStream) {
			auto stream = _currentStream->getSource();
			stream->stop();
			_currentStream = nullptr;
		}
		if (size == 0) {
			Error("failed to play audio stream: {}", file);
			return;
		}
		_currentStream = WavStream::create(MakeOwnArray(data), s_cast<size_t>(size));
		if (!_currentStream) {
			Error("failed to play audio stream: {}", file);
			return;
		}
		_currentVoice = _soloud->playBackground(*_currentStream->getSource(), 0.0f);
		addRef(_currentVoice, _currentStream, nullptr);
		_soloud->setLooping(_currentVoice, loop);
		_soloud->setProtectVoice(_currentVoice, true);
		_soloud->fadeVolume(_currentVoice, 1.0f, crossFadeTime);
		_soloud->setAutoStop(_currentVoice, true);
	});
}

void Audio::stopStream(float fadeTime) {
	if (!_soloud) return;
	if (fadeTime > 0.0f) {
		if (_currentVoice > 0 && _soloud->isValidVoiceHandle(_currentVoice)) {
			_soloud->fadeVolume(_currentVoice, 0.0f, fadeTime);
			_soloud->scheduleStop(_currentVoice, fadeTime);
		}
	} else if (_currentStream) {
		auto stream = _currentStream->getSource();
		stream->stop();
	}
	_currentVoice = 0;
	_currentStream = nullptr;
}

void Audio::stopAll(float fadeTime) {
	if (!_soloud) return;
	if (fadeTime > 0.0f) {
		for (const auto& res : _resources) {
			_soloud->fadeVolume(res.first, 0.0f, fadeTime);
			_soloud->scheduleStop(res.first, fadeTime);
		}
	} else {
		for (const auto& res : _resources) {
			_soloud->stop(res.first);
		}
	}
}

void Audio::setGlobalVolume(float var) {
	if (_soloud) _soloud->setGlobalVolume(var);
}

float Audio::getGlobalVolume() const noexcept {
	return _soloud ? _soloud->getGlobalVolume() : 0.0f;
}

void Audio::setSoundSpeed(float var) {
	if (_soloud) _soloud->set3dSoundSpeed(var);
}

float Audio::getSoundSpeed() const noexcept {
	return _soloud ? _soloud->get3dSoundSpeed() : 0.0f;
}

void Audio::setDopplerScale(float var) {
	if (_soloud) _soloud->set3dDopplerScale(var);
}

float Audio::getDopplerScale() const noexcept {
	return _soloud ? _soloud->get3dDopplerScale() : 1.0f;
}

void Audio::setDistanceModel(Audio::DistanceModel model) {
	if (_soloud) {
		_soloud->set3dDistanceModel(static_cast<SoLoud::DISTANCE_MODELS>(model));
	}
}

Audio::DistanceModel Audio::getDistanceModel() const {
	return _soloud
		? static_cast<Audio::DistanceModel>(_soloud->get3dDistanceModel())
		: Audio::DistanceModel::InverseClamped;
}

void Audio::setPauseAllCurrent(bool aPause) {
	_paused = aPause;
	if (_soloud) _soloud->setPauseAll(aPause);
}

void Audio::setListener(Node* node) {
	_listener = node;
}

Node* Audio::getListener() const noexcept {
	return _listener;
}

void Audio::setListenerAt(float aAtX, float aAtY, float aAtZ) {
	if (_soloud) _soloud->set3dListenerAt(aAtX, aAtY, aAtZ);
}

void Audio::setListenerUp(float aUpX, float aUpY, float aUpZ) {
	if (_soloud) _soloud->set3dListenerUp(aUpX, aUpY, aUpZ);
}

void Audio::setListenerVelocity(float aVelocityX, float aVelocityY, float aVelocityZ) {
	if (_soloud) _soloud->set3dListenerVelocity(aVelocityX, aVelocityY, aVelocityZ);
}

void Audio::setListenerPosition(float aPosX, float aPosY, float aPosZ) {
	if (_soloud) _soloud->set3dListenerPosition(aPosX, aPosY, aPosZ);
}

void Audio::getListenerPosition(float& aPosX, float& aPosY, float& aPosZ) const {
	aPosX = _soloud ? _soloud->m3dPosition[0] : 0.0f;
	aPosY = _soloud ? _soloud->m3dPosition[1] : 0.0f;
	aPosZ = _soloud ? _soloud->m3dPosition[2] : 0.0f;
}

void Audio::getListenerAt(float& aAtX, float& aAtY, float& aAtZ) const {
	aAtX = _soloud ? _soloud->m3dAt[0] : 0.0f;
	aAtY = _soloud ? _soloud->m3dAt[1] : 0.0f;
	aAtZ = _soloud ? _soloud->m3dAt[2] : 1.0f;
}

void Audio::getListenerUp(float& aUpX, float& aUpY, float& aUpZ) const {
	aUpX = _soloud ? _soloud->m3dUp[0] : 0.0f;
	aUpY = _soloud ? _soloud->m3dUp[1] : 1.0f;
	aUpZ = _soloud ? _soloud->m3dUp[2] : 0.0f;
}

void Audio::getListenerVelocity(float& aVelocityX, float& aVelocityY, float& aVelocityZ) const {
	aVelocityX = _soloud ? _soloud->m3dVelocity[0] : 0.0f;
	aVelocityY = _soloud ? _soloud->m3dVelocity[1] : 0.0f;
	aVelocityZ = _soloud ? _soloud->m3dVelocity[2] : 0.0f;
}

void Audio::addRef(uint32_t handle, AudioFile* audioFile, const std::function<void(uint32_t)>& callback) {
	_resources[handle] = New<AudioResource>(MakeRef(audioFile), callback);
}

void Audio::removeRef(uint32_t handle) {
	auto it = _resources.find(handle);
	if (it != _resources.end()) {
		if (it->second->callback) {
			it->second->callback(it->first);
		}
		_resources.erase(it);
	}
}

bool Audio::isVoicePlaying(uint32_t handle) const {
	return _resources.find(handle) != _resources.end();
}

NS_DORA_END
