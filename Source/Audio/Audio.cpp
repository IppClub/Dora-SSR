/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

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

/* AudioBus */

AudioBus::AudioBus()
	: _bus(new SoLoud::Bus())
	, _filters(nullptr) {
}

AudioBus::~AudioBus() {
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
	_handle = SharedAudio.getSoLoud()->play(*_bus);
	return Object::init();
}

void AudioBus::setPan(float var) {
	SharedAudio.getSoLoud()->setPan(_handle, var);
}

float AudioBus::getPan() const noexcept {
	return SharedAudio.getSoLoud()->getPan(_handle);
}

void AudioBus::setVolume(float var) {
	SharedAudio.getSoLoud()->setVolume(_handle, var);
}

float AudioBus::getVolume() const noexcept {
	return SharedAudio.getSoLoud()->getVolume(_handle);
}

void AudioBus::setPlaySpeed(float var) {
	SharedAudio.getSoLoud()->setRelativePlaySpeed(_handle, var);
}

float AudioBus::getPlaySpeed() const noexcept {
	return SharedAudio.getSoLoud()->getRelativePlaySpeed(_handle);
}

uint32_t AudioBus::getHandle() const noexcept {
	return _handle;
}

void AudioBus::fadeVolume(double time, float toVolume) {
	SharedAudio.getSoLoud()->fadeVolume(_handle, toVolume, time);
}

void AudioBus::fadePan(double time, float toPan) {
	SharedAudio.getSoLoud()->fadePan(_handle, toPan, time);
}

void AudioBus::fadePlaySpeed(double time, float toPlaySpeed) {
	SharedAudio.getSoLoud()->fadeRelativePlaySpeed(_handle, toPlaySpeed, time);
}

void AudioBus::setFilter(uint32_t index, String name) {
	if (!_filters) {
		_filters = new SoLoud::Filter*[FILTERS_PER_STREAM];
		std::fill(_filters, _filters + 1, nullptr);
	}
	if (index >= FILTERS_PER_STREAM) {
		Error("filter index {} out of range, max is {}", index, FILTERS_PER_STREAM - 1);
		return;
	}
	switch (Switch::hash(name)) {
		case ""_hash: {
			if (_filters[index]) {
				delete _filters[index];
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
	SharedAudio.getSoLoud()->setFilterParameter(_handle, index, attrId, value);
}

float AudioBus::getFilterParameter(uint32_t index, uint32_t attrId) {
	return SharedAudio.getSoLoud()->getFilterParameter(_handle, index, attrId);
}

void AudioBus::fadeFilterParameter(uint32_t index, uint32_t attrId, float to, double time) {
	SharedAudio.getSoLoud()->fadeFilterParameter(_handle, index, attrId, to, time);
}

/* Audio */

Audio::Audio()
	: _soloud(nullptr)
	, _currentVoice(0) { }

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
	SoLoud::result result = _soloud->init();
	if (result) {
		Error("failed to init soloud engine deal to reason: {}.", _soloud->getErrorString(result));
		delete _soloud;
		_soloud = nullptr;
		return false;
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
	if (auto audioFile = SharedAudioCache.load(filename)) {
		uint32_t handle = SharedAudio.getSoLoud()->play(*audioFile->getSource());
		_soloud->setLooping(handle, loop);
		SharedAudio.addRef(handle, audioFile, nullptr);
		return handle;
	}
	return 0;
}

void Audio::stop(uint32_t handle) {
	_soloud->stop(handle);
}

void Audio::playStream(String filename, bool loop, float crossFadeTime) {
	stopStream(crossFadeTime);
	std::string file(filename);
	SharedContent.loadAsyncUnsafe(filename, [file, this, crossFadeTime, loop](uint8_t* data, int64_t size) {
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
	_soloud->setGlobalVolume(var);
}

float Audio::getGlobalVolume() const noexcept {
	return _soloud->getGlobalVolume();
}

void Audio::setSoundSpeed(float var) {
	_soloud->set3dSoundSpeed(var);
}

float Audio::getSoundSpeed() const noexcept {
	return _soloud->get3dSoundSpeed();
}

void Audio::setPauseAllCurrent(bool aPause) {
	_soloud->setPauseAll(aPause);
}

void Audio::setListener(Node* node) {
	_listener = node;
}

Node* Audio::getListener() const noexcept {
	return _listener;
}

void Audio::setListenerAt(float aAtX, float aAtY, float aAtZ) {
	_soloud->set3dListenerAt(aAtX, aAtY, aAtZ);
}

void Audio::setListenerUp(float aUpX, float aUpY, float aUpZ) {
	_soloud->set3dListenerUp(aUpX, aUpY, aUpZ);
}

void Audio::setListenerVelocity(float aVelocityX, float aVelocityY, float aVelocityZ) {
	_soloud->set3dListenerVelocity(aVelocityX, aVelocityY, aVelocityZ);
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
