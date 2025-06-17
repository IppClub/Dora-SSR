/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Audio/Sound.h"

#include "Basic/Application.h"
#include "Basic/Content.h"
#include "Basic/Director.h"
#include "Basic/Scheduler.h"
#include "Cache/SoundCache.h"

#include "soloud_wav.h"
#include "soloud_wavstream.h"

NS_DORA_BEGIN

/* SoundFile */
SoLoud::Wav* SoundFile::getWav() {
	return _wav;
}

SoundFile::SoundFile(OwnArray<uint8_t>&& data, size_t size)
	: _wav(nullptr)
	, _data(std::move(data))
	, _size(size) { }

SoundFile::~SoundFile() {
	if (_wav) {
		delete _wav;
		_wav = nullptr;
	}
}

bool SoundFile::init() {
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

/* SoundStream */

SoLoud::WavStream* SoundStream::getStream() {
	return _stream;
}

bool SoundStream::init() {
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

SoundStream::SoundStream(OwnArray<uint8_t>&& data, size_t size)
	: _stream(nullptr)
	, _data(std::move(data))
	, _size(size) { }

SoundStream::~SoundStream() {
	if (_stream) {
		delete _stream;
		_stream = nullptr;
	}
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
	return true;
}

uint32_t Audio::play(String filename, bool loop) {
	if (!_soloud) return 0;
	if (SoundFile* file = SharedSoundCache.load(filename)) {
		if (auto wav = file->getWav()) {
			SoLoud::handle handle = _soloud->play(*wav);
			_soloud->setLooping(handle, loop);
			_soloud->setInaudibleBehavior(handle, true, true);
			return handle;
		}
	}
	return 0;
}

void Audio::stop(uint32_t handle) {
	if (!_soloud) return;
	_soloud->stop(handle);
}

void Audio::playStream(String filename, bool loop, float crossFadeTime) {
	if (!_soloud) return;
	stopStream(crossFadeTime);
	std::string file(filename);
	SharedContent.loadAsyncUnsafe(filename, [file, this, crossFadeTime, loop](uint8_t* data, int64_t size) {
		if (_currentStream) {
			if (auto stream = _currentStream->getStream()) {
				stream->stop();
			}
			_currentStream = nullptr;
		}
		if (size == 0) {
			Error("failed to play audio stream: {}", file);
			return;
		}
		_currentStream = SoundStream::create(MakeOwnArray(data), s_cast<size_t>(size));
		if (!_currentStream) {
			Error("failed to play audio stream: {}", file);
			return;
		}
		_currentVoice = _soloud->play(*_currentStream->getStream(), 0.0f);
		_soloud->setLooping(_currentVoice, loop);
		_soloud->setProtectVoice(_currentVoice, true);
		_soloud->fadeVolume(_currentVoice, 1.0f, crossFadeTime);
	});
}

void Audio::stopStream(float fadeTime) {
	if (!_soloud) return;
	if (fadeTime > 0.0f) {
		if (_currentVoice && _soloud->isValidVoiceHandle(_currentVoice)) {
			_soloud->fadeVolume(_currentVoice, 0.0f, fadeTime);
			_soloud->scheduleStop(_currentVoice, fadeTime);
			SharedDirector.getSystemScheduler()->schedule(once([fadeTime, stream = _currentStream]() -> Job {
				co_sleep(fadeTime);
			}));
		}
	} else if (_currentStream) {
		if (auto stream = _currentStream->getStream()) {
			stream->stop();
		}
	}
	_currentVoice = 0;
	_currentStream = nullptr;
}

NS_DORA_END
