/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Node/AudioSource.h"

#include "Audio/Audio.h"
#include "Cache/AudioCache.h"

#include "soloud.h"

NS_DORA_BEGIN

void AudioSource::setPan(float var) {
	_pan = var;
	if (_handle != 0) {
		SharedAudio.getSoLoud()->setPan(_handle, var);
	}
}

float AudioSource::getPan() const noexcept {
	return _pan;
}

void AudioSource::setVolume(float var) {
	_volume = var;
	if (_handle != 0) {
		SharedAudio.getSoLoud()->setVolume(_handle, var);
	}
}

float AudioSource::getVolume() const noexcept {
	return _volume;
}

void AudioSource::setPlaySpeed(float var) {
	_playSpeed = var;
	if (_handle != 0) {
		SharedAudio.getSoLoud()->setRelativePlaySpeed(_handle, var);
	}
}

float AudioSource::getPlaySpeed() const noexcept {
	return _playSpeed;
}

void AudioSource::setLooping(bool var) {
	_loop = var;
	if (_handle != 0) {
		SharedAudio.getSoLoud()->setLooping(_handle, var);
	}
}

bool AudioSource::isLooping() const noexcept {
	return _loop;
}

bool AudioSource::isPlaying() const noexcept {
	if (_handle != 0) {
		return SharedAudio.isVoicePlaying(_handle);
	}
	return false;
}

void AudioSource::seek(double startTime) {
	if (_handle != 0) {
		SharedAudio.getSoLoud()->seek(_handle, startTime);
	}
}

void AudioSource::scheduleStop(double timeToStop) {
	if (_handle != 0) {
		SharedAudio.getSoLoud()->scheduleStop(_handle, timeToStop);
	}
}

void AudioSource::stop(double fadeTime) {
	if (_handle != 0) {
		auto soloud = SharedAudio.getSoLoud();
		if (fadeTime > 0.0) {
			soloud->fadeVolume(_handle, 0, fadeTime);
			soloud->scheduleStop(_handle, fadeTime);
		} else {
			soloud->stop(_handle);
		}
	}
}

AudioSource::AudioSource(String filename, bool autoRemove, AudioBus* bus)
	: _filename(filename.toString())
	, _handle(0)
	, _is3D(false)
	, _loop(false)
	, _autoRemove(autoRemove)
	, _attenuation(0)
	, _attenuationFactor(1.0f)
	, _dopplerFactor(1.0f)
	, _velocity{0.0f, 0.0f, 0.0f}
	, _minDistance(0.0f)
	, _maxDistance(1000000.0f)
	, _volume(1.0f)
	, _pan(0.0f)
	, _playSpeed(1.0f)
	, _loopStartTime(0.0)
	, _bus(bus) {
}

void AudioSource::visit() {
	if (!_is3D) {
		Node::visit();
		return;
	}
	if (_handle != 0) {
		if (SharedAudio.isVoicePlaying(_handle)) {
			Vec4 point;
			Matrix::mulVec4(point, getWorld(), {0.0f, 0.0f, 0.0f, 1.0f});
			SharedAudio.getSoLoud()->set3dSourcePosition(_handle, point.x, point.y, point.z);
		}
	}
	Node::visit();
}

void AudioSource::cleanup() {
	if (_flags.isOff(Node::Cleanup)) {
		Node::cleanup();
		_bus = nullptr;
		_handle = 0;
	}
}

bool AudioSource::playBackground() {
	AssertIf(_flags.isOn(Node::Cleanup), "can not operate on an invalid AudioSource");
	if (_handle != 0 && SharedAudio.isVoicePlaying(_handle)) {
		return false;
	}
	_is3D = false;
	if (auto audioFile = SharedAudioCache.load(_filename)) {
		uint32_t busHandle = _bus ? _bus->getHandle() : 0;
		_pan = 0.0f;
		auto soloud = SharedAudio.getSoLoud();
		_handle = soloud->playBackground(*audioFile->getSource(), _volume, false, busHandle);
		soloud->setProtectVoice(_handle, true);
		if (_playSpeed != 1.0f) {
			soloud->setRelativePlaySpeed(_handle, _playSpeed);
		}
		if (_loopStartTime > 0.0) {
			soloud->setLoopPoint(_handle, _loopStartTime);
		}
		_protected = true;
		WRef<AudioSource> self(this);
		SharedAudio.addRef(_handle, audioFile, [self](uint32_t handle) {
			if (self && self->_handle == handle) {
				self->_handle = 0;
				self->emit("AudioEnd"sv, handle);
				if (self->_autoRemove) {
					self->removeFromParent();
				}
			}
		});
		return true;
	}
	return false;
}

bool AudioSource::play(double delayTime) {
	AssertIf(_flags.isOn(Node::Cleanup), "can not operate on an invalid AudioSource");
	if (_handle != 0 && SharedAudio.isVoicePlaying(_handle)) {
		return false;
	}
	_is3D = false;
	if (auto audioFile = SharedAudioCache.load(_filename)) {
		uint32_t busHandle = _bus ? _bus->getHandle() : 0;
		auto soloud = SharedAudio.getSoLoud();
		if (delayTime <= 0) {
			_handle = soloud->play(*audioFile->getSource(), _volume, _pan, false, busHandle);
		} else {
			_handle = soloud->playClocked(delayTime, *audioFile->getSource(), _volume, _pan, busHandle);
		}
		if (_protected) {
			soloud->setProtectVoice(_handle, true);
		}
		if (_playSpeed != 1.0f) {
			soloud->setRelativePlaySpeed(_handle, _playSpeed);
		}
		if (_loopStartTime > 0.0) {
			soloud->setLoopPoint(_handle, _loopStartTime);
		}
		WRef<AudioSource> self(this);
		SharedAudio.addRef(_handle, audioFile, [self](uint32_t handle) {
			if (self && self->_handle == handle) {
				self->_handle = 0;
				self->emit("AudioEnd"sv, handle);
				if (self->_autoRemove) {
					self->removeFromParent();
				}
			}
		});
		return true;
	}
	return false;
}

bool AudioSource::play3D(double delayTime) {
	AssertIf(_flags.isOn(Node::Cleanup), "can not operate on an invalid AudioSource");
	if (_handle != 0 && SharedAudio.isVoicePlaying(_handle)) {
		return false;
	}
	_is3D = true;
	if (auto audioFile = SharedAudioCache.load(_filename)) {
		uint32_t busHandle = _bus ? _bus->getHandle() : 0;
		Vec4 point;
		Matrix::mulVec4(point, getWorld(), {0.0f, 0.0f, 0.0f, 1.0f});
		auto soloud = SharedAudio.getSoLoud();
		if (delayTime < 0) {
			_handle = soloud->play3d(*audioFile->getSource(), point.x, point.y, point.z, 0.0f, 0.0f, 0.0f, _volume, false, busHandle);
		} else {
			_handle = soloud->play3dClocked(delayTime, *audioFile->getSource(), point.x, point.y, point.z, 0.0f, 0.0f, 0.0f, _volume, busHandle);
		}
		soloud->setInaudibleBehavior(_handle, true, false);
		if (_protected) {
			soloud->setProtectVoice(_handle, true);
		}
		if (_playSpeed != 1.0f) {
			soloud->setRelativePlaySpeed(_handle, _playSpeed);
		}
		if (_loopStartTime > 0.0) {
			soloud->setLoopPoint(_handle, _loopStartTime);
		}
		soloud->set3dSourceVelocity(_handle, _velocity.x, _velocity.y, _velocity.z);
		soloud->set3dSourceMinMaxDistance(_handle, _minDistance, _maxDistance);
		soloud->set3dSourceAttenuation(_handle, _attenuation, _attenuationFactor);
		soloud->set3dSourceDopplerFactor(_handle, _dopplerFactor);
		WRef<AudioSource> self(this);
		SharedAudio.addRef(_handle, audioFile, [self](uint32_t handle) {
			if (self && self->_handle == handle) {
				self->_handle = 0;
				self->emit("AudioEnd"sv, handle);
				if (self->_autoRemove) {
					self->removeFromParent();
				}
			}
		});
		return true;
	}
	return false;
}

void AudioSource::setLoopPoint(double loopStartTime) {
	_loopStartTime = loopStartTime;
	if (_handle != 0 && _loopStartTime > 0) {
		SharedAudio.getSoLoud()->setLoopPoint(_handle, loopStartTime);
	}
}

void AudioSource::setProtected(bool var) {
	_protected = var;
	if (_handle != 0) {
		SharedAudio.getSoLoud()->setProtectVoice(_handle, var);
	}
}

void AudioSource::setVelocity(float vx, float vy, float vz) {
	_velocity = {vx, vy, vz};
	if (_handle != 0) {
		SharedAudio.getSoLoud()->set3dSourceVelocity(_handle, vx, vy, vz);
	}
}

void AudioSource::setMinMaxDistance(float min, float max) {
	_minDistance = min;
	_maxDistance = max;
	if (_handle != 0) {
		SharedAudio.getSoLoud()->set3dSourceMinMaxDistance(_handle, min, max);
	}
}

void AudioSource::setAttenuation(AudioSource::AttenuationModel model, float factor) {
	uint32_t modelType = 0;
	switch (model) {
		case AudioSource::AttenuationModel::NoAttenuation:
			modelType = SoLoud::AudioSource::NO_ATTENUATION;
			break;
		case AudioSource::AttenuationModel::InverseDistance:
			modelType = SoLoud::AudioSource::INVERSE_DISTANCE;
			break;
		case AudioSource::AttenuationModel::LinearDistance:
			modelType = SoLoud::AudioSource::LINEAR_DISTANCE;
			break;
		case AudioSource::AttenuationModel::ExponentialDistance:
			modelType = SoLoud::AudioSource::EXPONENTIAL_DISTANCE;
			break;
	}
	_attenuation = modelType;
	_attenuationFactor = factor;
	if (_handle != 0) {
		SharedAudio.getSoLoud()->set3dSourceAttenuation(_handle, modelType, factor);
	}
}

void AudioSource::setAttenuation(String model, float factor) {
	uint32_t modelType = 0;
	switch (Switch::hash(model)) {
		case "NoAttenuation"_hash:
			modelType = SoLoud::AudioSource::NO_ATTENUATION;
			break;
		case "InverseDistance"_hash:
			modelType = SoLoud::AudioSource::INVERSE_DISTANCE;
			break;
		case "LinearDistance"_hash:
			modelType = SoLoud::AudioSource::LINEAR_DISTANCE;
			break;
		case "ExponentialDistance"_hash:
			modelType = SoLoud::AudioSource::EXPONENTIAL_DISTANCE;
			break;
		default:
			Issue("invalid attenuation model: \"{}\", should be one of \"NoAttenuation\", \"InverseDistance\", \"LinearDistance\" or \"ExponentialDistance\"", model.toString());
			break;
	}
	_attenuation = modelType;
	_attenuationFactor = factor;
	if (_handle != 0) {
		SharedAudio.getSoLoud()->set3dSourceAttenuation(_handle, modelType, factor);
	}
}

void AudioSource::setDopplerFactor(float factor) {
	_dopplerFactor = factor;
	if (_handle != 0) {
		SharedAudio.getSoLoud()->set3dSourceDopplerFactor(_handle, factor);
	}
}

NS_DORA_END
