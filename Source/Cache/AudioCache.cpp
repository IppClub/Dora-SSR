/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Cache/AudioCache.h"

#include "Audio/Audio.h"
#include "Basic/Content.h"

NS_DORA_BEGIN

AudioFile* AudioCache::update(String name, AudioFile* audioFile) {
	std::string fullPath = SharedContent.getFullPath(name);
	_audioFiles[fullPath] = audioFile;
	return audioFile;
}

AudioFile* AudioCache::get(String filename) {
	std::string fullPath = SharedContent.getFullPath(filename);
	auto it = _audioFiles.find(fullPath);
	if (it != _audioFiles.end()) {
		return it->second;
	}
	return nullptr;
}

static bool shouldStream(String filename, size_t size) {
	if (Path::getExt(filename) == "wav"sv) {
		if (size >= DORA_STREAMING_AUDIO_FILE_SIZE) {
			return true;
		}
	} else {
		return true;
	}
	return false;
}

AudioFile* AudioCache::load(String filename) {
	std::string fullPath = SharedContent.getFullPath(filename);
	auto it = _audioFiles.find(fullPath);
	if (it != _audioFiles.end()) {
		return it->second;
	}
	auto data = SharedContent.load(fullPath);
	if (!data.first) {
		Error("failed to load sound file \"{}\".", filename.toString());
		return nullptr;
	}
	AudioFile* audioFile = nullptr;
	if (shouldStream(filename, data.second)) {
		audioFile = WavStream::create(std::move(data.first), data.second);
	} else {
		audioFile = WavFile::create(std::move(data.first), data.second);
	}
	if (audioFile) {
		_audioFiles[fullPath] = audioFile;
		return audioFile;
	} else {
		Error("failed to load audio file \"{}\".", filename.toString());
		return nullptr;
	}
}

void AudioCache::loadAsync(String filename, const std::function<void(AudioFile*)>& handler) {
	std::string fullPath = SharedContent.getFullPath(filename);
	std::string file(filename.toString());
	SharedContent.loadAsyncUnsafe(fullPath, [this, file, fullPath, handler](uint8_t* data, int64_t size) {
		auto fileSize = s_cast<size_t>(size);
		AudioFile* audioFile = nullptr;
		if (shouldStream(fullPath, fileSize)) {
			audioFile = WavStream::create(MakeOwnArray(data), fileSize);
		} else {
			audioFile = WavFile::create(MakeOwnArray(data), fileSize);
		}
		if (audioFile) {
			_audioFiles[fullPath] = audioFile;
			handler(audioFile);
		} else {
			Error("failed to load sound file \"{}\".", file);
			handler(nullptr);
		}
	});
}

bool AudioCache::unload(AudioFile* audioFile) {
	for (const auto& it : _audioFiles) {
		if (it.second == audioFile) {
			_audioFiles.erase(_audioFiles.find(it.first));
			return true;
		}
	}
	return false;
}

bool AudioCache::unload(String filename) {
	std::string fullPath = SharedContent.getFullPath(filename);
	auto it = _audioFiles.find(fullPath);
	if (it != _audioFiles.end()) {
		_audioFiles.erase(it);
		return true;
	}
	return false;
}

bool AudioCache::unload() {
	if (_audioFiles.empty()) {
		return false;
	}
	_audioFiles.clear();
	return true;
}

void AudioCache::removeUnused() {
	std::vector<StringMap<Ref<AudioFile>>::iterator> targets;
	for (auto it = _audioFiles.begin(); it != _audioFiles.end(); ++it) {
		if (it->second->isSingleReferenced()) {
			targets.push_back(it);
		}
	}
	for (const auto& it : targets) {
		_audioFiles.erase(it);
	}
}

NS_DORA_END
