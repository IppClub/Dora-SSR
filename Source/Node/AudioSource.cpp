/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Node/AudioSource.h"

#include "Audio/Audio.h"
#include "Cache/AudioCache.h"
#ifdef DORA_EMSCRIPTEN
#include "Basic/Content.h"
#include "Web/WebAudio.h"
#endif

#include "soloud.h"

NS_DORA_BEGIN

#ifdef DORA_EMSCRIPTEN
bool AudioSource::useWorklet() {
	if (!dora_worklet_ready()) return false;
	if ((!_audioFile || !_audioFile->getWebData().empty()) && (!_bus || _bus->getWebHandle())) return true;
	if (!_webFallbackReported) {
		_webFallbackReported = true;
		Warn("Web AudioSource '{}' retains SDL mixing: this custom decoder/PCM queue or pre-existing bus is not migrated.", _filename);
	}
	return false;
}

void AudioSource::workletConfig(float* c) const {
	using namespace DoraWebAudio;
	Vec4 point;
	if (_useExplicit3DPosition) point = {_position3D.x, _position3D.y, _position3D.z, 1};
	else Matrix::mulVec4(point, const_cast<AudioSource*>(this)->getWorld(), {0, 0, 0, 1});
	const float values[] = {static_cast<float>(_is3D ? 2 : _webBackground ? 1 : 0), _webDelay,
		_volume, _pan, _playSpeed, static_cast<float>(_loop), static_cast<float>(_protected), static_cast<float>(_loopStartTime),
		point.x, point.y, point.z, _velocity.x, _velocity.y, _velocity.z,
		_direction3D.x, _direction3D.y, _direction3D.z, _coneInnerAngle, _coneOuterAngle, _coneOuterVolume,
		_coneOuterHighGain, _airAbsorptionFactor, _minDistance, _maxDistance,
		static_cast<float>(_attenuation), _attenuationFactor, _dopplerFactor, static_cast<float>(_listenerRelative),
		static_cast<float>(_useVolumeLimits), _minVolumeLimit, _maxVolumeLimit};
	static_assert(sizeof(values) / sizeof(float) == SourceFields);
	std::copy(std::begin(values), std::end(values), c);
}

bool AudioSource::syncWorklet() {
	if (!dora_worklet_handle(_handle)) return false;
	float config[DoraWebAudio::SourceFields];
	workletConfig(config);
	dora_worklet_config(_handle, config);
	return true;
}

bool AudioSource::playWorklet(int mode, double delayTime) {
	_webBackground = mode == 1;
	_webDelay = static_cast<float>(delayTime);
	if (_webBackground) { _pan = 0; _protected = true; }
	float config[DoraWebAudio::SourceFields];
	workletConfig(config);
	const auto path = _audioFile ? "audio-file:" + std::to_string(_audioFile->getWebId()) : SharedContent.getFullPath(_filename);
	const auto bus = _bus ? _bus->getWebHandle() : 0;
	const auto isStatic = _audioFile && _audioFile->isWebStatic();
	if (dora_worklet_has(path.c_str())) _handle = dora_worklet_source(path.c_str(), nullptr, 0, config, bus, isStatic);
	else if (_audioFile) {
		const auto bytes = _audioFile->getWebData();
		_handle = dora_worklet_source(path.c_str(), bytes.data(), bytes.size(), config, bus, isStatic);
	}
	else {
		auto data = SharedContent.load(path);
		if (!data.first) return false;
		_handle = dora_worklet_source(path.c_str(), data.first.get(), data.second, config, bus, isStatic);
	}
	if (!_handle) return false;
	WRef<AudioSource> self(this);
	SharedAudio.addRef(_handle, nullptr, [self](uint32_t handle) {
		if (self && self->_handle == handle) {
			self->_handle = 0;
			self->emit("AudioEnd"sv, handle);
			if (self->_autoRemove) self->removeFromParent();
		}
	});
	return true;
}
#endif

void AudioSource::setPan(float var) {
	_pan = var;
#ifdef DORA_EMSCRIPTEN
	_webBackground = false;
	if (syncWorklet()) return;
#endif
	if (_handle != 0) {
		if (auto soloud = SharedAudio.getSoLoud()) {
			soloud->setPan(_handle, var);
		}
	}
}

float AudioSource::getPan() const noexcept {
	return _pan;
}

void AudioSource::setVolume(float var) {
	_volume = var;
#ifdef DORA_EMSCRIPTEN
	if (syncWorklet()) return;
#endif
	if (_handle != 0) {
		if (auto soloud = SharedAudio.getSoLoud()) {
			soloud->setVolume(_handle, var);
		}
	}
}

float AudioSource::getVolume() const noexcept {
	return _volume;
}

void AudioSource::setPlaySpeed(float var) {
	_playSpeed = var;
#ifdef DORA_EMSCRIPTEN
	if (syncWorklet()) return;
#endif
	if (_handle != 0) {
		if (auto soloud = SharedAudio.getSoLoud()) {
			soloud->setRelativePlaySpeed(_handle, var);
		}
	}
}

float AudioSource::getPlaySpeed() const noexcept {
	return _playSpeed;
}

void AudioSource::setLooping(bool var) {
	_loop = var;
#ifdef DORA_EMSCRIPTEN
	if (syncWorklet()) return;
#endif
	if (_handle != 0) {
		if (auto soloud = SharedAudio.getSoLoud()) {
			soloud->setLooping(_handle, var);
		}
	}
}

bool AudioSource::isLooping() const noexcept {
	return _loop;
}

bool AudioSource::isPlaying() const noexcept {
#ifdef DORA_EMSCRIPTEN
	if (dora_worklet_handle(_handle)) return dora_worklet_get(_handle, 0) != 0;
#endif
	if (_handle != 0) {
		if (auto soloud = SharedAudio.getSoLoud()) {
			return soloud->isValidVoiceHandle(_handle);
		}
	}
	return false;
}

void AudioSource::seek(double startTime) {
#ifdef DORA_EMSCRIPTEN
	if (dora_worklet_handle(_handle)) { dora_worklet_control(_handle, 0, startTime); return; }
#endif
	if (_handle != 0) {
		if (auto soloud = SharedAudio.getSoLoud()) {
			soloud->seek(_handle, startTime);
		}
	}
}

void AudioSource::setPaused(bool paused) {
#ifdef DORA_EMSCRIPTEN
	if (dora_worklet_handle(_handle)) { dora_worklet_control(_handle, 1, paused); return; }
#endif
	if (_handle != 0 && isPlaying()) {
		if (auto soloud = SharedAudio.getSoLoud()) {
			soloud->setPause(_handle, paused);
		}
	}
}

bool AudioSource::isPaused() const {
#ifdef DORA_EMSCRIPTEN
	if (dora_worklet_handle(_handle)) return dora_worklet_get(_handle, 1) != 0;
#endif
	if (_handle != 0 && isPlaying()) {
		if (auto soloud = SharedAudio.getSoLoud()) {
			return soloud->getPause(_handle);
		}
	}
	return false;
}

double AudioSource::getCurrentTime() const {
#ifdef DORA_EMSCRIPTEN
	if (dora_worklet_handle(_handle)) return dora_worklet_get(_handle, 2);
#endif
	if (_handle != 0 && isPlaying()) {
		if (auto soloud = SharedAudio.getSoLoud()) {
			return soloud->getStreamPosition(_handle);
		}
	}
	return 0.0;
}

void AudioSource::scheduleStop(double timeToStop) {
#ifdef DORA_EMSCRIPTEN
	if (dora_worklet_handle(_handle)) { dora_worklet_control(_handle, 2, timeToStop); return; }
#endif
	if (_handle != 0) {
		if (auto soloud = SharedAudio.getSoLoud()) {
			soloud->scheduleStop(_handle, timeToStop);
		}
	}
}

void AudioSource::stop(double fadeTime) {
#ifdef DORA_EMSCRIPTEN
	if (dora_worklet_handle(_handle)) { dora_worklet_stop(_handle, fadeTime); return; }
#endif
	if (_handle != 0) {
		auto soloud = SharedAudio.getSoLoud();
		if (!soloud) return;
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
	, _protected(false)
	, _useExplicit3DPosition(false)
	, _useVolumeLimits(false)
	, _listenerRelative(false)
	, _autoRemove(autoRemove)
	, _position3D{0.0f, 0.0f, 0.0f}
	, _velocity{0.0f, 0.0f, 0.0f}
	, _direction3D{0.0f, 0.0f, 0.0f}
	, _loopStartTime(0.0)
	, _volume(1.0f)
	, _pan(0.0f)
	, _playSpeed(1.0f)
	, _minDistance(0.0f)
	, _maxDistance(1000000.0f)
	, _attenuation(0)
	, _attenuationFactor(1.0f)
	, _dopplerFactor(1.0f)
	, _coneInnerAngle(6.28318530717958647692f)
	, _coneOuterAngle(6.28318530717958647692f)
	, _coneOuterVolume(0.0f)
	, _coneOuterHighGain(1.0f)
	, _airAbsorptionFactor(0.0f)
	, _minVolumeLimit(0.0f)
	, _maxVolumeLimit(1.0f)
	, _bus(bus) {
}

AudioSource::AudioSource(AudioFile* audioFile, bool autoRemove, AudioBus* bus)
	: AudioSource(""_slice, autoRemove, bus) {
	_audioFile = audioFile;
}

AudioFile* AudioSource::getAudioFile() const {
	return _audioFile ? _audioFile.get() : SharedAudioCache.load(_filename);
}

void AudioSource::visit() {
#ifdef DORA_EMSCRIPTEN
	if (syncWorklet()) { Node::visit(); return; }
#endif
	if (!_is3D) {
		Node::visit();
		return;
	}
	if (_handle != 0) {
		if (auto soloud = SharedAudio.getSoLoud(); soloud && SharedAudio.isVoicePlaying(_handle)) {
			if (_useExplicit3DPosition) {
				soloud->set3dSourcePosition(_handle, _position3D.x, _position3D.y, _position3D.z);
			} else {
				Vec4 point;
				Matrix::mulVec4(point, getWorld(), {0.0f, 0.0f, 0.0f, 1.0f});
				soloud->set3dSourcePosition(_handle, point.x, point.y, point.z);
			}
		}
	}
	Node::visit();
}

void AudioSource::cleanup() {
	if (_flags.isOff(Node::Cleanup)) {
		Node::cleanup();
		_bus = nullptr;
		_audioFile = nullptr;
		_handle = 0;
	}
}

bool AudioSource::playBackground() {
	AssertIf(_flags.isOn(Node::Cleanup), "can not operate on an invalid AudioSource");
	if (_handle != 0 && isPlaying()) {
		return false;
	}
	_is3D = false;

#ifdef DORA_EMSCRIPTEN
	if (useWorklet()) return playWorklet(1, 0);
#endif
	auto soloud = SharedAudio.getSoLoud();
	if (!soloud) return false;
	if (auto audioFile = getAudioFile()) {
		uint32_t busHandle = _bus ? _bus->getHandle() : 0;
		_pan = 0.0f;
		_handle = soloud->playBackground(*audioFile->getSource(), _volume, false, busHandle);
		soloud->setProtectVoice(_handle, true);
		soloud->setLooping(_handle, _loop);
		if (_useVolumeLimits) {
			soloud->setVoiceVolumeLimits(_handle, _minVolumeLimit, _maxVolumeLimit);
		}
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
	if (_handle != 0 && isPlaying()) {
		return false;
	}
	_is3D = false;
#ifdef DORA_EMSCRIPTEN
	if (useWorklet()) return playWorklet(0, delayTime);
#endif
	auto soloud = SharedAudio.getSoLoud();
	if (!soloud) return false;
	if (auto audioFile = getAudioFile()) {
		uint32_t busHandle = _bus ? _bus->getHandle() : 0;
		if (delayTime <= 0) {
			_handle = soloud->play(*audioFile->getSource(), _volume, _pan, false, busHandle);
		} else {
			_handle = soloud->playClocked(delayTime, *audioFile->getSource(), _volume, _pan, busHandle);
		}
		if (_protected) {
			soloud->setProtectVoice(_handle, true);
		}
		soloud->setLooping(_handle, _loop);
		if (_useVolumeLimits) {
			soloud->setVoiceVolumeLimits(_handle, _minVolumeLimit, _maxVolumeLimit);
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
	if (_handle != 0 && isPlaying()) {
		return false;
	}
	_is3D = true;
#ifdef DORA_EMSCRIPTEN
	if (useWorklet()) return playWorklet(2, delayTime);
#endif
	auto soloud = SharedAudio.getSoLoud();
	if (!soloud) return false;
	if (auto audioFile = getAudioFile()) {
		uint32_t busHandle = _bus ? _bus->getHandle() : 0;
		Vec4 point;
		if (_useExplicit3DPosition) {
			point = {_position3D.x, _position3D.y, _position3D.z, 1.0f};
		} else {
			Matrix::mulVec4(point, getWorld(), {0.0f, 0.0f, 0.0f, 1.0f});
		}
		if (delayTime < 0) {
			_handle = soloud->play3d(*audioFile->getSource(), point.x, point.y, point.z, 0.0f, 0.0f, 0.0f, _volume, false, busHandle);
		} else {
			_handle = soloud->play3dClocked(delayTime, *audioFile->getSource(), point.x, point.y, point.z, 0.0f, 0.0f, 0.0f, _volume, busHandle);
		}
		soloud->setInaudibleBehavior(_handle, true, false);
		if (_protected) {
			soloud->setProtectVoice(_handle, true);
		}
		soloud->setLooping(_handle, _loop);
		if (_playSpeed != 1.0f) {
			soloud->setRelativePlaySpeed(_handle, _playSpeed);
		}
		if (_loopStartTime > 0.0) {
			soloud->setLoopPoint(_handle, _loopStartTime);
		}
		soloud->set3dSourceVelocity(_handle, _velocity.x, _velocity.y, _velocity.z);
		soloud->set3dSourceCone(_handle, _direction3D.x, _direction3D.y, _direction3D.z,
			_coneInnerAngle, _coneOuterAngle, _coneOuterVolume, _coneOuterHighGain);
		soloud->set3dSourceAirAbsorption(_handle, _airAbsorptionFactor);
		soloud->set3dSourceMinMaxDistance(_handle, _minDistance, _maxDistance);
		soloud->set3dSourceAttenuation(_handle, _attenuation, _attenuationFactor);
		soloud->set3dSourceDopplerFactor(_handle, _dopplerFactor);
		soloud->set3dSourceListenerRelative(_handle, _listenerRelative);
		if (_useVolumeLimits) {
			soloud->setVoiceVolumeLimits(_handle, _minVolumeLimit, _maxVolumeLimit);
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

void AudioSource::setLoopPoint(double loopStartTime) {
	_loopStartTime = loopStartTime;
#ifdef DORA_EMSCRIPTEN
	if (syncWorklet()) return;
#endif
	if (_handle != 0 && _loopStartTime > 0) {
		if (auto soloud = SharedAudio.getSoLoud()) {
			soloud->setLoopPoint(_handle, loopStartTime);
		}
	}
}

void AudioSource::setProtected(bool var) {
	_protected = var;
#ifdef DORA_EMSCRIPTEN
	if (syncWorklet()) return;
#endif
	if (_handle != 0) {
		if (auto soloud = SharedAudio.getSoLoud()) {
			soloud->setProtectVoice(_handle, var);
		}
	}
}

void AudioSource::set3DPosition(float x, float y, float z) {
	_useExplicit3DPosition = true;
	_position3D = {x, y, z};
#ifdef DORA_EMSCRIPTEN
	if (syncWorklet()) return;
#endif
	if (_handle != 0) {
		if (auto soloud = SharedAudio.getSoLoud()) {
			soloud->set3dSourcePosition(_handle, x, y, z);
		}
	}
}

void AudioSource::setVelocity(float vx, float vy, float vz) {
	_velocity = {vx, vy, vz};
#ifdef DORA_EMSCRIPTEN
	if (syncWorklet()) return;
#endif
	if (_handle != 0) {
		if (auto soloud = SharedAudio.getSoLoud()) {
			soloud->set3dSourceVelocity(_handle, vx, vy, vz);
		}
	}
}

void AudioSource::set3DDirection(float x, float y, float z) {
	_direction3D = {x, y, z};
#ifdef DORA_EMSCRIPTEN
	if (syncWorklet()) return;
#endif
	if (_handle != 0) {
		if (auto soloud = SharedAudio.getSoLoud()) {
			soloud->set3dSourceCone(_handle, _direction3D.x, _direction3D.y, _direction3D.z,
				_coneInnerAngle, _coneOuterAngle, _coneOuterVolume, _coneOuterHighGain);
		}
	}
}

void AudioSource::set3DCone(float innerAngle, float outerAngle, float outerVolume,
	float outerHighGain) {
	_coneInnerAngle = innerAngle;
	_coneOuterAngle = outerAngle;
	_coneOuterVolume = outerVolume;
	_coneOuterHighGain = outerHighGain;
#ifdef DORA_EMSCRIPTEN
	if (syncWorklet()) return;
#endif
	if (_handle != 0) {
		if (auto soloud = SharedAudio.getSoLoud()) {
			soloud->set3dSourceCone(_handle, _direction3D.x, _direction3D.y, _direction3D.z,
				_coneInnerAngle, _coneOuterAngle, _coneOuterVolume, _coneOuterHighGain);
		}
	}
}

void AudioSource::setAirAbsorptionFactor(float factor) {
	_airAbsorptionFactor = factor;
#ifdef DORA_EMSCRIPTEN
	if (syncWorklet()) return;
#endif
	if (_handle != 0) {
		if (auto soloud = SharedAudio.getSoLoud()) {
			soloud->set3dSourceAirAbsorption(_handle, factor);
		}
	}
}

void AudioSource::setVolumeLimits(float minVolume, float maxVolume) {
	_useVolumeLimits = true;
	_minVolumeLimit = minVolume;
	_maxVolumeLimit = maxVolume;
#ifdef DORA_EMSCRIPTEN
	if (syncWorklet()) return;
#endif
	if (_handle != 0) {
		if (auto soloud = SharedAudio.getSoLoud()) {
			soloud->setVoiceVolumeLimits(_handle, minVolume, maxVolume);
		}
	}
}

void AudioSource::setListenerRelative(bool relative) {
	_listenerRelative = relative;
#ifdef DORA_EMSCRIPTEN
	if (syncWorklet()) return;
#endif
	if (_handle != 0) {
		if (auto soloud = SharedAudio.getSoLoud()) {
			soloud->set3dSourceListenerRelative(_handle, relative);
		}
	}
}

void AudioSource::setMinMaxDistance(float min, float max) {
	_minDistance = min;
	_maxDistance = max;
#ifdef DORA_EMSCRIPTEN
	if (syncWorklet()) return;
#endif
	if (_handle != 0) {
		if (auto soloud = SharedAudio.getSoLoud()) {
			soloud->set3dSourceMinMaxDistance(_handle, min, max);
		}
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
		case AudioSource::AttenuationModel::ApplicationDistance:
			modelType = SoLoud::AudioSource::APPLICATION_DISTANCE;
			break;
	}
	_attenuation = modelType;
	_attenuationFactor = factor;
#ifdef DORA_EMSCRIPTEN
	if (syncWorklet()) return;
#endif
	if (_handle != 0) {
		if (auto soloud = SharedAudio.getSoLoud()) {
			soloud->set3dSourceAttenuation(_handle, modelType, factor);
		}
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
#ifdef DORA_EMSCRIPTEN
	if (syncWorklet()) return;
#endif
	if (_handle != 0) {
		if (auto soloud = SharedAudio.getSoLoud()) {
			soloud->set3dSourceAttenuation(_handle, modelType, factor);
		}
	}
}

void AudioSource::setDopplerFactor(float factor) {
	_dopplerFactor = factor;
#ifdef DORA_EMSCRIPTEN
	if (syncWorklet()) return;
#endif
	if (_handle != 0) {
		if (auto soloud = SharedAudio.getSoLoud()) {
			soloud->set3dSourceDopplerFactor(_handle, factor);
		}
	}
}

NS_DORA_END
