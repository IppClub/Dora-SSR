/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Basic/Object.h"

namespace SoLoud {
class Wav;
class WavStream;
class Soloud;
class AudioSource;
class Bus;
class Filter;
} // namespace SoLoud

NS_DORA_BEGIN

class AudioFile : public Object {
public:
	PROPERTY_READONLY_CLASS(uint64_t, StorageSize);
	PROPERTY_READONLY_CLASS(uint32_t, Count);
	virtual SoLoud::AudioSource* getSource() const = 0;

protected:
	static uint64_t _storageSize;
	static uint32_t _count;
};

class WavFile : public AudioFile {
public:
	virtual ~WavFile();
	virtual SoLoud::AudioSource* getSource() const override;
	virtual bool init() override;
	CREATE_FUNC_NULLABLE(WavFile);

protected:
	WavFile(OwnArray<uint8_t>&& data, size_t size);

private:
	OwnArray<uint8_t> _data;
	size_t _size;
	SoLoud::Wav* _wav;
	DORA_TYPE_OVERRIDE(WavFile);
};

class WavStream : public AudioFile {
public:
	virtual ~WavStream();
	virtual SoLoud::AudioSource* getSource() const override;
	virtual bool init() override;
	CREATE_FUNC_NULLABLE(WavStream);

protected:
	WavStream(OwnArray<uint8_t>&& data, size_t size);

private:
	size_t _size;
	OwnArray<uint8_t> _data;
	SoLoud::WavStream* _stream;
	DORA_TYPE_OVERRIDE(WavStream);
};

class AudioBus : public Object {
public:
	PROPERTY(float, Volume);
	PROPERTY(float, Pan);
	PROPERTY(float, PlaySpeed);
	PROPERTY_READONLY(uint32_t, Handle);

	virtual ~AudioBus();
	virtual bool init() override;
	void fadeVolume(double time, float toVolume);
	void fadePan(double time, float toPan);
	void fadePlaySpeed(double time, float toPlaySpeed);

	void setFilter(uint32_t index, String name);
	void setFilterParameter(uint32_t index, uint32_t attrId, float value);
	float getFilterParameter(uint32_t index, uint32_t attrId);
	void fadeFilterParameter(uint32_t index, uint32_t attrId, float to, double time);

	CREATE_FUNC_NOT_NULL(AudioBus);

protected:
	AudioBus();

private:
	SoLoud::Bus* _bus;
	SoLoud::Filter** _filters;
	uint32_t _handle;
	DORA_TYPE_OVERRIDE(AudioBus);
};

class Node;

class Audio : public NonCopyable {
public:
	PROPERTY(float, SoundSpeed);
	PROPERTY(float, GlobalVolume);
	PROPERTY(Node*, Listener);
	PROPERTY_READONLY_CALL(SoLoud::Soloud*, SoLoud);

	virtual ~Audio();
	bool init();
	uint32_t play(String filename, bool loop = false);
	void stop(uint32_t handle);
	void playStream(String filename, bool loop = false, float crossFadeTime = 0.0f);
	void stopStream(float fadeTime = 0.0f);
	void stopAll(float fadeTime = 0.0f);

	void setPauseAllCurrent(bool aPause);

	void setListenerAt(float aAtX, float aAtY, float aAtZ);
	void setListenerUp(float aUpX, float aUpY, float aUpZ);
	void setListenerVelocity(float aVelocityX, float aVelocityY, float aVelocityZ);

public:
	void addRef(uint32_t handle, AudioFile* audioFile, const std::function<void(uint32_t)>& callback);
	void removeRef(uint32_t handle);
	bool isVoicePlaying(uint32_t handle) const;

protected:
	Audio();

private:
	bool _paused;
	uint32_t _currentVoice;
	Ref<WavStream> _currentStream;
	SoLoud::Soloud* _soloud;
	WRef<Node> _listener;
	struct AudioResource {
		Ref<AudioFile> ref;
		std::function<void(uint32_t)> callback;
	};
	std::unordered_map<uint32_t, Own<AudioResource>> _resources;
	SINGLETON_REF(Audio, Director);
};

#define SharedAudio \
	Dora::Singleton<Dora::Audio>::shared()

NS_DORA_END
