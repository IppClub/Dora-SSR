/* Copyright (c) 2017 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Common/Singleton.h"

NS_DOROTHY_BEGIN

class SoundFile;

class SoundCache
{
public:
	SoundFile* update(String name, SoundFile* soundFile);
	SoundFile* update(String filename, const Uint8* data, Sint64 size);
	SoundFile* get(String filename);
	/** @brief support format .wav .ogg */
	SoundFile* load(String filename);
	void loadAsync(String filename, const function<void(SoundFile*)>& handler);
    bool unload(SoundFile* soundFile);
    bool unload(String filename);
    bool unload();
    void removeUnused();
protected:
	SoundCache() { }
private:
	unordered_map<string, Ref<SoundFile>> _soundFiles;
	DORA_TYPE(SoundCache);
	SINGLETON_REF(SoundCache, SoLoudPlayer);
};

#define SharedSoundCache \
	Dorothy::Singleton<Dorothy::SoundCache>::shared()

NS_DOROTHY_END
