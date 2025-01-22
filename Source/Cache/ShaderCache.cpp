/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Cache/ShaderCache.h"

#include "Basic/Content.h"
#include "Shader/Builtin.h"

NS_DORA_BEGIN

/* Shader */

Shader::Shader(bgfx::ShaderHandle handle)
	: _handle(handle) { }

Shader::~Shader() {
	if (bgfx::isValid(_handle)) {
		bgfx::destroy(_handle);
	}
}

bgfx::ShaderHandle Shader::getHandle() const noexcept {
	return _handle;
}

/* ShaderCache */

ShaderCache::ShaderCache() { }

void ShaderCache::update(String name, Shader* shader) {
	std::string shaderFile = SharedContent.getFullPath(getShaderPath() + name);
	_shaders[shaderFile] = shader;
}

std::string ShaderCache::getShaderPath() const {
	std::string shaderPath;
	switch (bgfx::getRendererType()) {
		case bgfx::RendererType::Direct3D11:
		case bgfx::RendererType::Direct3D12:
			shaderPath = "dx11";
			break;
		case bgfx::RendererType::Gnm:
			shaderPath = "pssl";
			break;
		case bgfx::RendererType::Metal:
			shaderPath = "metal";
			break;
		case bgfx::RendererType::OpenGL:
			shaderPath = "glsl";
			break;
		case bgfx::RendererType::OpenGLES:
			shaderPath = "essl";
			break;
		case bgfx::RendererType::Vulkan:
			shaderPath = "spirv";
			break;
		default:
			break;
	}
	return shaderPath;
}

Shader* ShaderCache::load(String filename) {
	auto filenameStr = filename.toString();
	auto items = filename.split(":"_slice);
	if (!items.empty() && items.front() == "builtin"_slice) {
		auto it = _shaders.find(filenameStr);
		if (it != _shaders.end()) {
			return it->second;
		}
		bgfx::RendererType::Enum type = bgfx::getRendererType();
		bgfx::ShaderHandle handle = bgfx::createEmbeddedShader(DoraShaders, type, items.back().c_str());
		if (!bgfx::isValid(handle)) {
			Error("failed to load builtin shader named: \"{}\".", items.back().toString());
			return nullptr;
		}
		Shader* shader = Shader::create(handle);
		_shaders[filenameStr] = shader;
		return shader;
	}
	std::string shaderFile;
	if (SharedContent.exist(filenameStr)) {
		shaderFile = SharedContent.getFullPath(filenameStr);
	} else {
		auto path = Path::concat({getShaderPath(), filenameStr});
		if (SharedContent.exist(path)) {
			shaderFile = SharedContent.getFullPath(path);
		}
	}
	if (shaderFile.empty()) {
		Error("shader file \"{}\" not exist.", filenameStr);
		return nullptr;
	}
	auto it = _shaders.find(shaderFile);
	if (it != _shaders.end()) {
		return it->second;
	}
	const bgfx::Memory* mem = SharedContent.loadBX(shaderFile);
	bgfx::ShaderHandle handle = bgfx::createShader(mem);
	if (!bgfx::isValid(handle)) {
		Error("failed to load shader \"{}\".", shaderFile);
		return nullptr;
	}
	Shader* shader = Shader::create(handle);
	_shaders[shaderFile] = shader;
	return shader;
}

void ShaderCache::loadAsync(String filename, const std::function<void(Shader*)>& handler) {
	std::string shaderFile = SharedContent.getFullPath(getShaderPath() + filename);
	SharedContent.loadAsyncBX(shaderFile, [this, shaderFile, handler](const bgfx::Memory* mem) {
		bgfx::ShaderHandle handle = bgfx::createShader(mem);
		if (bgfx::isValid(handle)) {
			Shader* shader = Shader::create(handle);
			_shaders[shaderFile] = shader;
			handler(shader);
		} else {
			Error("failed to load shader \"{}\".", shaderFile);
			handler(nullptr);
		}
	});
}

bool ShaderCache::unload(Shader* shader) {
	for (const auto& it : _shaders) {
		if (it.second == shader) {
			_shaders.erase(_shaders.find(it.first));
			return true;
		}
	}
	return false;
}

bool ShaderCache::unload(String filename) {
	std::string fullName = SharedContent.getFullPath(getShaderPath() + filename);
	auto it = _shaders.find(fullName);
	if (it != _shaders.end()) {
		_shaders.erase(it);
		return true;
	}
	return false;
}

bool ShaderCache::unload() {
	if (_shaders.empty()) {
		return false;
	}
	_shaders.clear();
	return true;
}

void ShaderCache::removeUnused() {
	std::vector<StringMap<Ref<Shader>>::iterator> targets;
	for (auto it = _shaders.begin(); it != _shaders.end(); ++it) {
		if (it->second->isSingleReferenced()) {
			targets.push_back(it);
		}
	}
	for (const auto& it : targets) {
		_shaders.erase(it);
	}
}

NS_DORA_END
