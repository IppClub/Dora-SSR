/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "SDL.h"

#include <algorithm>
#include <filesystem>
#include <fstream>
#include <string>

namespace Dora {

inline const std::string& windowsGameRoot() {
	static const auto root = [] {
		char* path = SDL_GetBasePath();
		std::string result = path ? path : "";
		SDL_free(path);
		return result;
	}();
	return root;
}

// The exporter writes an opaque project ID beside the executable. Read it
// before constructing Content or acquiring the editor's single-instance lock.
inline const std::string& windowsGameId() {
	static const auto id = [] {
		if (windowsGameRoot().empty()) return std::string{};
		std::ifstream config(std::filesystem::u8path(windowsGameRoot()) / "dora-game-id", std::ios::binary);
		char value[33];
		config.read(value, sizeof(value));
		if (config.gcount() != 32 || !std::all_of(value, value + 32, [](char ch) {
			return (ch >= '0' && ch <= '9') || (ch >= 'a' && ch <= 'f');
		})) return std::string{};
		return std::string(value, 32);
	}();
	return id;
}

} // namespace Dora
