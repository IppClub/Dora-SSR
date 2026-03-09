/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Shader/ShaderCompiler.h"
#include "Basic/Content.h"

#include "3rdParty/bgfx/dora/DoraShaderc.h"

NS_DORA_BEGIN

// Static thread_local error message storage
thread_local std::string ShaderCompiler::s_lastError;

// File I/O callbacks for DoraShaderc
static int shaderFileReadCallback(const char* path, char* buffer, int bufferSize, void* userData) {
	if (!path || !buffer || bufferSize <= 0) {
		return -1;
	}

	auto data = SharedContent.load(path);
	if (!data.first || data.second == 0) {
		return -1;
	}

	int bytesToCopy = std::min(static_cast<int>(data.second), bufferSize);
	std::memcpy(buffer, data.first.get(), bytesToCopy);
	return bytesToCopy;
}

static int shaderFileExistsCallback(const char* path, void* userData) {
	if (!path) {
		return 0;
	}
	return SharedContent.exist(path) ? 1 : 0;
}

static long shaderGetFileSizeCallback(const char* path, void* userData) {
	if (!path) {
		return -1;
	}

	auto data = SharedContent.load(path);
	if (!data.first || data.second == 0) {
		return -1;
	}

	return static_cast<long>(data.second);
}

// Convert bgfx renderer type to DoraShaderc renderer type
int ShaderCompiler::toDoraRenderer(bgfx::RendererType::Enum type) {
	switch (type) {
		case bgfx::RendererType::OpenGL:
		case bgfx::RendererType::OpenGLES:
			return DoraShadercRenderer_OpenGL;

		case bgfx::RendererType::Metal:
			return DoraShadercRenderer_Metal;

		case bgfx::RendererType::Direct3D11:
			return DoraShadercRenderer_Direct3D11;

		case bgfx::RendererType::Direct3D12:
			return DoraShadercRenderer_Direct3D12;

		case bgfx::RendererType::Vulkan:
			return DoraShadercRenderer_Vulkan;

		default:
			return -1; // Unsupported renderer
	}
}

// Convert ShaderStage to DoraShadercStage
static DoraShadercStage toDoraStage(ShaderStage stage) {
	switch (stage) {
		case ShaderStage::Vertex:
			return DoraShadercStage_Vertex;

		case ShaderStage::Fragment:
			return DoraShadercStage_Fragment;

		case ShaderStage::Compute:
			return DoraShadercStage_Compute;

		default:
			return DoraShadercStage_Vertex;
	}
}

std::vector<uint8_t> ShaderCompiler::compile(std::string_view source, ShaderStage stage) {
	std::vector<uint8_t> result;

	// Resolve current bgfx renderer internally.
	int doraRenderer = toDoraRenderer(bgfx::getRendererType());
	if (doraRenderer < 0) {
		s_lastError = "Unsupported renderer type";
		return result;
	}

	// Initialize options
	DoraShadercOptions options;
	DoraShadercInitOptions(&options);

	options.stage = toDoraStage(stage);
	options.renderer = static_cast<DoraShadercRenderer>(doraRenderer);
	options.optimize = 1;
	options.debug = 0;

	// Compile shader
	DoraShadercResult compileResult = DoraShadercCompile(
		source.data(),
		static_cast<int>(source.size()),
		&options
	);

	if (!compileResult.success) {
		if (compileResult.errorMessage) {
			s_lastError = compileResult.errorMessage;
		} else {
			s_lastError = "Shader compilation failed";
		}
		DoraShadercFreeResult(&compileResult);
		return result;
	}

	// Copy bytecode to result
	if (compileResult.bytecode && compileResult.bytecodeSize > 0) {
		result.resize(compileResult.bytecodeSize);
		std::memcpy(result.data(), compileResult.bytecode, compileResult.bytecodeSize);
	}

	DoraShadercFreeResult(&compileResult);
	s_lastError.clear();
	return result;
}

std::vector<uint8_t> ShaderCompiler::compileFromFile(std::string_view file, ShaderStage stage) {
	std::vector<uint8_t> result;

	// Resolve current bgfx renderer internally.
	int doraRenderer = toDoraRenderer(bgfx::getRendererType());
	if (doraRenderer < 0) {
		s_lastError = "Unsupported renderer type";
		return result;
	}

	// Setup file operations
	DoraShadercFileOps fileOps = {};
	fileOps.readFile = shaderFileReadCallback;
	fileOps.fileExists = shaderFileExistsCallback;
	fileOps.getFileSize = shaderGetFileSizeCallback;
	fileOps.userData = nullptr;

	// Initialize options
	DoraShadercOptions options;
	DoraShadercInitOptions(&options);

	options.stage = toDoraStage(stage);
	options.renderer = static_cast<DoraShadercRenderer>(doraRenderer);
	options.optimize = 1;
	options.debug = 0;
	options.fileOps = &fileOps;

	// Compile shader from file
	std::string filePath(file);
	DoraShadercResult compileResult = DoraShadercCompileFromFile(
		filePath.c_str(),
		&options
	);

	if (!compileResult.success) {
		if (compileResult.errorMessage) {
			s_lastError = compileResult.errorMessage;
		} else {
			s_lastError = "Shader compilation failed";
		}
		DoraShadercFreeResult(&compileResult);
		return result;
	}

	// Copy bytecode to result
	if (compileResult.bytecode && compileResult.bytecodeSize > 0) {
		result.resize(compileResult.bytecodeSize);
		std::memcpy(result.data(), compileResult.bytecode, compileResult.bytecodeSize);
	}

	DoraShadercFreeResult(&compileResult);
	s_lastError.clear();
	return result;
}

std::string_view ShaderCompiler::getLastError() {
	return s_lastError;
}

NS_DORA_END
