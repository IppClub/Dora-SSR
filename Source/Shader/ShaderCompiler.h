/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "bgfx/bgfx.h"

#include <string>
#include <string_view>
#include <vector>

NS_DORA_BEGIN

enum class ShaderStage {
	Vertex,
	Fragment,
	Compute
};

class ShaderCompiler {
public:
	static std::vector<uint8_t> compile(std::string_view source, ShaderStage stage);
	static std::vector<uint8_t> compileFromFile(std::string_view file, ShaderStage stage);
	static std::string_view getLastError();

private:
	static int toDoraRenderer(bgfx::RendererType::Enum type);

private:
	static thread_local std::string s_lastError;
};

NS_DORA_END
