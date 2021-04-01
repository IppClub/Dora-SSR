/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Audio/Sound.h"
#include "Cache/SoundCache.h"
#include "Basic/Content.h"
#include "Basic/Scheduler.h"
#include "Basic/Application.h"

NS_DOROTHY_BEGIN

/* SoundFile */
SoLoud::Wav& SoundFile::getWav()
{
	return _wav;
}

SoundFile::SoundFile(OwnArray<Uint8>&& data, size_t size):
_data(std::move(data)),
_size(size)
{ }

bool SoundFile::init()
{
	SoLoud::result result = _wav.loadMem(_data.get(), s_cast<Uint32>(_size), false, false);
	_data.reset();
	if (result)
	{
		Warn("failed to load sound file due to reason: {}.", SharedAudio.getSoLoud().getErrorString(result));
		return false;
	}
	return true;
}

/* SoundStream */
SoLoud::WavStream& SoundStream::getStream()
{
	return _stream;
}

bool SoundStream::init()
{
	SoLoud::result result = _stream.loadMem(_data.get(), s_cast<Uint32>(_size), false, false);
	if (result)
	{
		Error("failed to load sound file due to reason: {}.", SharedAudio.getSoLoud().getErrorString(result));
		return false;
	}
	return true;
}

SoundStream::SoundStream(OwnArray<Uint8>&& data, size_t size):
_data(std::move(data)),
_size(size)
{ }

/* Audio */
Audio::Audio():
_currentVoice(0),
_timer(Timer::create())
{ }

SoLoud::Soloud& Audio::getSoLoud()
{
	return _soloud;
}

Audio::~Audio()
{
	_soloud.deinit();
}

bool Audio::init()
{
	SoLoud::result result = _soloud.init();
	if (result)
	{
		Error("failed to init soloud engine deal to reason: {}.", _soloud.getErrorString(result));
		return false;
	}
	return true;
}

Uint32 Audio::play(String filename, bool loop)
{
	SoundFile* file = SharedSoundCache.load(filename);
	if (file)
	{
		SoLoud::handle handle = _soloud.play(file->getWav());
		_soloud.setLooping(handle, loop);
		_soloud.setInaudibleBehavior(handle, true, true);
		return handle;
	}
	return 0;
}

void Audio::stop(Uint32 handle)
{
	_soloud.stop(handle);
}

void Audio::playStream(String filename, bool loop, float crossFadeTime)
{
	if (_lastStream)
	{
		_lastStream->getStream().stop();
		_lastStream = nullptr;
	}
	stopStream(crossFadeTime);
	SharedContent.loadAsyncUnsafe(filename, [this, crossFadeTime, loop](Uint8* data, Sint64 size)
	{
		if (_currentStream)
		{
			_currentStream->getStream().stop();
		}
		_currentStream = SoundStream::create(MakeOwnArray(data), s_cast<size_t>(size));
		_currentVoice = _soloud.play(_currentStream->getStream(), 0.0f);
		_soloud.setLooping(_currentVoice, loop);
		_soloud.setProtectVoice(_currentVoice, true);
		_soloud.fadeVolume(_currentVoice, 1.0f, crossFadeTime);
	});
}

void Audio::stopStream(float fadeTime)
{
	if (fadeTime > 0.0f)
	{
		if (_currentVoice && _soloud.isValidVoiceHandle(_currentVoice))
		{
			_soloud.fadeVolume(_currentVoice, 0.0f, fadeTime);
			_soloud.scheduleStop(_currentVoice, fadeTime);
			_lastStream = _currentStream;
			_timer->start(fadeTime, [this]()
			{
				if (_lastStream)
				{
					_lastStream->getStream().stop();
					_lastStream = nullptr;
				}
			});
		}
	}
	else if (_currentStream)
	{
		_currentStream->getStream().stop();
	}
	_currentVoice = 0;
	_currentStream = nullptr;
}

NS_DOROTHY_END
