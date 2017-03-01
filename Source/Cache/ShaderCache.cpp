/* Copyright (c) 2017 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Cache/ShaderCache.h"
#include "Basic/Content.h"

NS_DOROTHY_BEGIN

/* Shader */

Shader::Shader(bgfx::ShaderHandle handle):
_handle(handle)
{ }

Shader::~Shader()
{
	if (bgfx::isValid(_handle))
	{
		bgfx::destroyShader(_handle);
	}
}

bgfx::ShaderHandle Shader::getHandle() const
{
	return _handle;
}

/* ShaderCache */

ShaderCache::ShaderCache()
{ }

void ShaderCache::set(String name, Shader* shader)
{
	_shaders[name] = shader;
}

string ShaderCache::getShaderPath() const
{
	string shaderPath;
	switch (bgfx::getRendererType())
	{
		case bgfx::RendererType::Noop:
		case bgfx::RendererType::Direct3D9:
			shaderPath = "Shader/dx9/";
			break;
		case bgfx::RendererType::Direct3D11:
		case bgfx::RendererType::Direct3D12:
			shaderPath = "Shader/dx11/";
			break;
		case bgfx::RendererType::Gnm:
			shaderPath = "Shader/pssl/";
			break;
		case bgfx::RendererType::Metal:
			shaderPath = "Shader/metal/";
			break;
		case bgfx::RendererType::OpenGL:
			shaderPath = "Shader/glsl/";
			break;
		case bgfx::RendererType::OpenGLES:
			shaderPath = "Shader/essl/";
			break;
		case bgfx::RendererType::Vulkan:
			shaderPath = "Shader/spirv/";
			break;
		default:
			break;
	}
	return shaderPath;
}

Shader* ShaderCache::load(String filename)
{
	string shaderFile = SharedContent.getFullPath(getShaderPath() + filename);
	const bgfx::Memory* mem = SharedContent.loadFileBX(shaderFile);
	bgfx::ShaderHandle handle = bgfx::createShader(mem);
	if (bgfx::isValid(handle))
	{
		Shader* shader = Shader::create(handle);
		_shaders[shaderFile] = shader;
		return shader;
	}
	else
	{
		Log("fail to load shader \"%s\".", shaderFile);
		return nullptr;
	}
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
			Log("fail to load shader \"%s\".", shaderFile);
			handler(nullptr);
		}
	});
}

void ShaderCache::unload(Shader* shader)
{
	for (const auto& it : _shaders)
	{
		if (it.second == shader)
		{
			_shaders.erase(_shaders.find(it.first));
			return;
		}
	}
}

void ShaderCache::unload(String filename)
{
	string fullName = SharedContent.getFullPath(getShaderPath() + filename);
	auto it = _shaders.find(fullName);
	if (it != _shaders.end())
	{
		_shaders.erase(it);
	}
}

void ShaderCache::clear()
{
	_shaders.clear();
}

void ShaderCache::clearUnused()
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
