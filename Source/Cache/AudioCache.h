/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Common/Singleton.h"

NS_DORA_BEGIN

class AudioFile;

class AudioCache : public NonCopyable {
public:
	AudioFile* update(String name, AudioFile* audioFile);
	AudioFile* get(String filename);
	/** @brief support format .wav .ogg */
	AudioFile* load(String filename);
	void loadAsync(String filename, const std::function<void(AudioFile*)>& handler);
	bool unload(AudioFile* audioFile);
	bool unload(String filename);
	bool unload();
	void removeUnused();

protected:
	AudioCache() { }

private:
	StringMap<Ref<AudioFile>> _audioFiles;
	SINGLETON_REF(AudioCache, Audio);
};

#define SharedAudioCache \
	Dora::Singleton<Dora::AudioCache>::shared()

NS_DORA_END
