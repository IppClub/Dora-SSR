/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Node/Node.h"

NS_DORA_BEGIN

class AudioFile;
class AudioBus;

class AudioSource : public Node {
public:
	PROPERTY(float, Volume);
	PROPERTY(float, Pan);
	PROPERTY(float, PlaySpeed);
	PROPERTY_BOOL(Looping);
	PROPERTY_READONLY_BOOL(Playing);

	virtual void visit() override;
	virtual void cleanup() override;

	void seek(double startTime);
	void setPaused(bool paused);
	bool isPaused() const;
	double getCurrentTime() const;
	void scheduleStop(double timeToStop);
	void stop(double fadeTime = 0.0);

	bool play(double delayTime = 0.0);
	bool playBackground();

	bool play3D(double delayTime = 0.0);
	void setLoopPoint(double loopStartTime);
	void setProtected(bool var);
	void set3DPosition(float x, float y, float z);
	void setVelocity(float vx, float vy, float vz);
	void set3DDirection(float x, float y, float z);
	void set3DCone(float innerAngle, float outerAngle, float outerVolume,
		float outerHighGain = 1.0f);
	void setAirAbsorptionFactor(float factor);
	void setVolumeLimits(float minVolume, float maxVolume);
	void setListenerRelative(bool relative);
	void setMinMaxDistance(float min, float max);
	enum class AttenuationModel {
		NoAttenuation = 0,
		InverseDistance = 1,
		LinearDistance = 2,
		ExponentialDistance = 3,
		ApplicationDistance = 4
	};
	void setAttenuation(AttenuationModel model, float factor);
	void setAttenuation(String model, float factor);
	void setDopplerFactor(float factor);

	CREATE_FUNC_NULLABLE(AudioSource);

protected:
	AudioSource(String filename, bool autoRemove = true, AudioBus* bus = nullptr);
	AudioSource(AudioFile* audioFile, bool autoRemove = true, AudioBus* bus = nullptr);

private:
	AudioFile* getAudioFile() const;
	std::string _filename;
	Ref<AudioFile> _audioFile;
	int _handle;
	bool _is3D;
	bool _loop;
	bool _protected;
	bool _useExplicit3DPosition;
	bool _useVolumeLimits;
	bool _listenerRelative;
	bool _autoRemove;
	Vec3 _position3D;
	Vec3 _velocity;
	Vec3 _direction3D;
	double _loopStartTime;
	float _volume;
	float _pan;
	float _playSpeed;
	float _minDistance;
	float _maxDistance;
	uint32_t _attenuation;
	float _attenuationFactor;
	float _dopplerFactor;
	float _coneInnerAngle;
	float _coneOuterAngle;
	float _coneOuterVolume;
	float _coneOuterHighGain;
	float _airAbsorptionFactor;
	float _minVolumeLimit;
	float _maxVolumeLimit;
	Ref<AudioBus> _bus;
	DORA_TYPE_OVERRIDE(AudioSource);
};

NS_DORA_END
