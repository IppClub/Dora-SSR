/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Shader/ShaderCompiler.h"
#include "Basic/Application.h"
#include "Basic/Content.h"
#include "Common/Async.h"

#include "bgfx/dora/DoraShaderc.h"

#include "3rdParty/bgfx/dora/BgfxEmbeddedShaders.hpp"

NS_DORA_BEGIN

struct ShaderCompilerFileContext {
	std::unordered_map<std::string, std::string> files;
};

static bool tryGetEmbeddedShaderSource(String path, std::string& data) {
#if DORA_HAS_EMBEDDED_BGFX_SHADERS
	std::string file = path.toString();
	while (!file.empty() && file.front() == '/') {
		file.erase(file.begin());
	}
	auto pos = file.find_last_of("/\\");
	if (pos != std::string::npos) {
		file.erase(0, pos + 1);
	}
	if (file == "bgfx_shader.sh") {
		data = BgfxEmbeddedShaders::kBgfxShaderSh;
		return true;
	}
	if (file == "bgfx_compute.sh") {
		data = BgfxEmbeddedShaders::kBgfxComputeSh;
		return true;
	}
#else
	DORA_UNUSED_PARAM(path);
	DORA_UNUSED_PARAM(data);
#endif
	return false;
}

static const std::string& loadShaderFileData(ShaderCompilerFileContext& context, String path) {
	std::string key = path.toString();
	auto it = context.files.find(key);
	if (it != context.files.end()) {
		return it->second;
	}

	std::string data;
	if (!tryGetEmbeddedShaderSource(path, data)) {
		bx::Semaphore waitForLoaded;
		SharedContent.getThread()->run([path = key, &data, &waitForLoaded]() {
			auto content = SharedContent.loadUnsafe(path);
			if (!content.empty()) {
				data = std::move(content);
			}
			waitForLoaded.post();
		});
		waitForLoaded.wait();
	}
	auto file = context.files.emplace(std::move(key), std::move(data));
	return file.first->second;
}

// Convert bgfx renderer type to DoraShaderc renderer type
static int toDoraRenderer(bgfx::RendererType::Enum type) {
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

// File I/O callbacks for DoraShaderc.
static int shaderFileReadCallback(const char* path, char* buffer, int bufferSize, void* userData) {
	if (!path || !buffer || bufferSize < 0 || !userData) {
		return -1;
	}

	auto* context = r_cast<ShaderCompilerFileContext*>(userData);
	const auto& fileData = loadShaderFileData(*context, path);
	if (fileData.empty()) {
		return -1;
	}

	int bytesToCopy = std::min(s_cast<int>(fileData.size()), bufferSize);
	if (bytesToCopy > 0) {
		std::memcpy(buffer, fileData.data(), s_cast<size_t>(bytesToCopy));
	}
	return bytesToCopy;
}

static int shaderFileExistsCallback(const char* path, void* userData) {
	if (!path || !userData) {
		return 0;
	}

	auto* context = r_cast<ShaderCompilerFileContext*>(userData);
	return loadShaderFileData(*context, path).empty() ? 0 : 1;
}

static long shaderGetFileSizeCallback(const char* path, void* userData) {
	if (!path || !userData) {
		return -1;
	}

	auto* context = r_cast<ShaderCompilerFileContext*>(userData);
	const auto& fileData = loadShaderFileData(*context, path);
	if (fileData.empty()) {
		return -1;
	}
	return s_cast<long>(fileData.size());
}

static std::string compileShaderSource(String source, ShaderStage stage, bool fromFile, std::string& err) {
	std::string result;

	int doraRenderer = toDoraRenderer(bgfx::getRendererType());
	if (doraRenderer < 0) {
		err = "unsupported renderer type"s;
		return result;
	}

	ShaderCompilerFileContext context;

	DoraShadercFileOps fileOps = {};
	fileOps.readFile = shaderFileReadCallback;
	fileOps.fileExists = shaderFileExistsCallback;
	fileOps.getFileSize = shaderGetFileSizeCallback;
	fileOps.userData = &context;

	DoraShadercOptions options;
	DoraShadercInitOptions(&options);

	options.stage = toDoraStage(stage);
	options.renderer = static_cast<DoraShadercRenderer>(doraRenderer);
	options.optimize = 1;
	options.debug = 0;
	options.fileOps = &fileOps;

#if DORA_HAS_EMBEDDED_BGFX_SHADERS
	const char* includeDirs[] = { "" };
	options.includeDirs = includeDirs;
	options.includeDirCount = s_cast<int>(std::size(includeDirs));
#endif

	DoraShadercResult compileResult = fromFile
		? DoraShadercCompileFromFile(source.c_str(), &options)
		: DoraShadercCompile(source.rawData(), static_cast<int>(source.size()), &options);

	if (!compileResult.success) {
		err = compileResult.errorMessage ? compileResult.errorMessage : "shader compilation failed"s;
		DoraShadercFreeResult(&compileResult);
		return result;
	}

	if (compileResult.bytecode && compileResult.bytecodeSize > 0) {
		result.resize(compileResult.bytecodeSize);
		std::memcpy(result.data(), compileResult.bytecode, compileResult.bytecodeSize);
	}

	DoraShadercFreeResult(&compileResult);
	return result;
}

ShaderCompiler::ShaderCompiler()
	: _thread(SharedAsyncThread.newThread()) { }

std::string ShaderCompiler::compile(String source, ShaderStage stage, bool fromFile, std::string& err) {
	std::string result;
	_thread->runInMainSync([&]() {
		result = compileShaderSource(source, stage, fromFile, err);
	});
	return result;
}

void ShaderCompiler::compileAsync(String source, ShaderStage stage, bool fromFile, const std::function<void(std::string, std::string)>& callback) {
	if (!callback) {
		return;
	}
	_thread->run(
		[source = source.toString(), stage, fromFile]() {
			std::string error;
			auto result = SharedShaderCompiler.compile(source, stage, fromFile, error);
			return Values::alloc(std::move(result), std::move(error));
		},
		[callback](Own<Values> values) {
			std::string result;
			std::string error;
			values->get(result, error);
			callback(std::move(result), std::move(error));
		});
}

std::string ShaderCompiler::compile(String sourceFile, String targetFile, ShaderStage stage) {
	if (sourceFile.empty()) {
		return "shader source file is empty"s;
	}
	if (targetFile.empty()) {
		return "shader target file is empty"s;
	}
	std::string result, err;
	_thread->runInMainSync([&]() {
		result = compileShaderSource(sourceFile, stage, true, err);
	});
	if (!SharedContent.save(targetFile, r_cast<const uint8_t*>(result.data()), s_cast<int64_t>(result.size()))) {
		err = fmt::format("failed to save compiled shader to \"{}\"", targetFile.toString());
	}
	return err;
}

void ShaderCompiler::compileAsync(String sourceFile, String targetFile, ShaderStage stage, const std::function<void(std::string)>& callback) {
	if (!callback) {
		return;
	}
	if (sourceFile.empty()) {
		callback("shader source file is empty"s);
		return;
	}
	if (targetFile.empty()) {
		callback("shader target file is empty"s);
		return;
	}
	_thread->run(
		[sourceFile = sourceFile.toString(), targetFile = targetFile.toString(), stage]() {
			std::string result, err;
			result = compileShaderSource(sourceFile, stage, true, err);
			if (err.empty() && !SharedContent.save(targetFile, r_cast<const uint8_t*>(result.data()), s_cast<int64_t>(result.size()))) {
				err = fmt::format("failed to save compiled shader to \"{}\"", targetFile);
			}
			return Values::alloc(std::move(err));
		},
		[callback](Own<Values> values) {
			std::string err;
			values->get(err);
			callback(std::move(err));
		});
}

NS_DORA_END
