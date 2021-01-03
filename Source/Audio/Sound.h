/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Basic/Object.h"
#include "soloud_wav.h"
#include "soloud_wavstream.h"

NS_DOROTHY_BEGIN

class Timer;

class SoundFile : public Object
{
public:
	PROPERTY_READONLY_CALL(SoLoud::Wav&, Wav);
	virtual bool init() override;
	CREATE_FUNC(SoundFile);
protected:
	SoundFile(OwnArray<Uint8>&& data, size_t size);
private:
	OwnArray<Uint8> _data;
	size_t _size;
	SoLoud::Wav _wav;
	DORA_TYPE_OVERRIDE(SoundFile);
};

class SoundStream : public Object
{
public:
	PROPERTY_READONLY_CALL(SoLoud::WavStream&, Stream);
	virtual bool init() override;
	CREATE_FUNC(SoundStream);
protected:
	SoundStream(OwnArray<Uint8>&& data, size_t size);
private:
	size_t _size;
	OwnArray<Uint8> _data;
	SoLoud::WavStream _stream;
	DORA_TYPE_OVERRIDE(SoundStream);
};

class Audio
{
public:
	PROPERTY_READONLY_CALL(SoLoud::Soloud&, SoLoud);
	virtual ~Audio();
	bool init();
	Uint32 play(String filename, bool loop = false);
	void stop(Uint32 handle);
	void playStream(String filename, bool loop = false, float crossFadeTime = 0.0f);
	void stopStream(float fadeTime = 0.0f);
protected:
	Audio();
	bool _init();
	Uint32 _play(String filename, bool);
	void _stop(Uint32 handle);
	void _playStream(String filename, bool loop = false, float crossFadeTime = 0.0f);
	void _stopStream(float fadeTime = 0.0f);
private:
	Ref<Timer> _timer;
	Uint32 _currentVoice;
	Ref<SoundStream> _lastStream;
	Ref<SoundStream> _currentStream;
	SoLoud::Soloud _soloud;
	SINGLETON_REF(Audio, Application);
};

#define SharedAudio \
	Dorothy::Singleton<Dorothy::Audio>::shared()

NS_DOROTHY_END
