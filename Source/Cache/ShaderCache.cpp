/* Copyright (c) 2018 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Cache/ShaderCache.h"
#include "Basic/Content.h"
#include "Shader/Builtin.h"

NS_DOROTHY_BEGIN

/* Shader */

Shader::Shader(bgfx::ShaderHandle handle):
_handle(handle)
{ }

Shader::~Shader()
{
	if (bgfx::isValid(_handle))
	{
		bgfx::destroy(_handle);
	}
}

bgfx::ShaderHandle Shader::getHandle() const
{
	return _handle;
}

/* ShaderCache */

ShaderCache::ShaderCache()
{ }

void ShaderCache::update(String name, Shader* shader)
{
	string shaderFile = SharedContent.getFullPath(getShaderPath() + name);
	_shaders[shaderFile] = shader;
}

string ShaderCache::getShaderPath() const
{
	string shaderPath;
	switch (bgfx::getRendererType())
	{
		case bgfx::RendererType::Direct3D9:
			shaderPath = "dx9/";
			break;
		case bgfx::RendererType::Direct3D11:
		case bgfx::RendererType::Direct3D12:
			shaderPath = "dx11/";
			break;
		case bgfx::RendererType::Gnm:
			shaderPath = "pssl/";
			break;
		case bgfx::RendererType::Metal:
			shaderPath = "metal/";
			break;
		case bgfx::RendererType::OpenGL:
			shaderPath = "glsl/";
			break;
		case bgfx::RendererType::OpenGLES:
			shaderPath = "essl/";
			break;
		case bgfx::RendererType::Vulkan:
			shaderPath = "spirv/";
			break;
		default:
			break;
	}
	return shaderPath;
}

Shader* ShaderCache::load(String filename)
{
	auto items = filename.split(":");
	if (!items.empty() && items.front() == "builtin"_slice)
	{
		auto it = _shaders.find(filename);
		if (it != _shaders.end())
		{
			return it->second;
		}
		bgfx::RendererType::Enum type = bgfx::getRendererType();
		bgfx::ShaderHandle handle = bgfx::createEmbeddedShader(DoraShaders, type, items.back().toString().c_str());
		AssertUnless(bgfx::isValid(handle), "fail to load builtin shader named: \"{}\".", items.back());
		Shader* shader = Shader::create(handle);
		_shaders[filename] = shader;
		return shader;
	}
	string shaderFile = SharedContent.getFullPath(getShaderPath() + filename);
	auto it = _shaders.find(shaderFile);
	if (it != _shaders.end())
	{
		return it->second;
	}
	const bgfx::Memory* mem = SharedContent.loadFileBX(shaderFile);
	bgfx::ShaderHandle handle = bgfx::createShader(mem);
	AssertUnless(bgfx::isValid(handle), "fail to load shader \"{}\".", shaderFile);
	Shader* shader = Shader::create(handle);
	_shaders[shaderFile] = shader;
	return shader;
}

void ShaderCache::loadAsync(String filename, const function<void(Shader*)>& handler)
{
	string shaderFile = SharedContent.getFullPath(getShaderPath() + filename);
	SharedContent.loadFileAsyncBX(shaderFile, [this, shaderFile, handler](const bgfx::Memory* mem)
	{
		bgfx::ShaderHandle handle = bgfx::createShader(mem);
		if (bgfx::isValid(handle))
		{
			Shader* shader = Shader::create(handle);
			_shaders[shaderFile] = shader;
			handler(shader);
		}
		else
		{
			Warn("fail to load shader \"{}\".", shaderFile);
			handler(nullptr);
		}
	});
}

bool ShaderCache::unload(Shader* shader)
{
	for (const auto& it : _shaders)
	{
		if (it.second == shader)
		{
			_shaders.erase(_shaders.find(it.first));
			return true;
		}
	}
	return false;
}

bool ShaderCache::unload(String filename)
{
	string fullName = SharedContent.getFullPath(getShaderPath() + filename);
	auto it = _shaders.find(fullName);
	if (it != _shaders.end())
	{
		_shaders.erase(it);
		return true;
	}
	return false;
}

bool ShaderCache::unload()
{
	if (_shaders.empty())
	{
		return false;
	}
	_shaders.clear();
	return true;
}

void ShaderCache::removeUnused()
{
	vector<unordered_map<string,Ref<Shader>>::iterator> targets;
	for (auto it = _shaders.begin(); it != _shaders.end(); ++it)
	{
		if (it->second->isSingleReferenced())
		{
			targets.push_back(it);
		}
	}
	for (const auto& it : targets)
	{
		_shaders.erase(it);
	}
}

NS_DOROTHY_END
