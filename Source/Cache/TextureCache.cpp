/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Cache/TextureCache.h"
#include "Basic/Content.h"
#include "Common/Async.h"
#include "bimg/decode.h"

NS_DOROTHY_BEGIN

Texture2D::Texture2D(bgfx::TextureHandle handle, const bgfx::TextureInfo& info, Uint64 flags):
_handle(handle),
_info(info),
_flags(flags)
{ }

bgfx::TextureHandle Texture2D::getHandle() const
{
	return _handle;
}

int Texture2D::getWidth() const
{
	return s_cast<int>(_info.width);
}

int Texture2D::getHeight() const
{
	return s_cast<int>(_info.height);
}

const bgfx::TextureInfo& Texture2D::getInfo() const
{
	return _info;
}

TextureFilter Texture2D::getFilter() const
{
	if ((_flags & (BGFX_SAMPLER_MIN_POINT | BGFX_SAMPLER_MAG_POINT)) != 0)
	{
		return TextureFilter::Point;
	}
	return TextureFilter::Anisotropic;
}

TextureWrap Texture2D::getUWrap() const
{
	if ((_flags & BGFX_SAMPLER_U_CLAMP) != 0)
	{
		return TextureWrap::Clamp;
	}
	else if ((_flags & BGFX_SAMPLER_U_BORDER) != 0)
	{
		return TextureWrap::Border;
	}
	return TextureWrap::Mirror;
}

TextureWrap Texture2D::getVWrap() const
{
	if ((_flags & BGFX_SAMPLER_V_CLAMP) != 0)
	{
		return TextureWrap::Clamp;
	}
	else if ((_flags & BGFX_SAMPLER_V_BORDER) != 0)
	{
		return TextureWrap::Border;
	}
	return TextureWrap::Mirror;
}

Uint64 Texture2D::getFlags() const
{
	return _flags;
}

Texture2D::~Texture2D()
{
	if (bgfx::isValid(_handle))
	{
		bgfx::destroy(_handle);
		_handle = BGFX_INVALID_HANDLE;
	}
}

Texture2D* TextureCache::update(String name, Texture2D* texture)
{
	string fullPath = SharedContent.getFullPath(name);
	_textures[fullPath] = texture;
	return texture;
}

Texture2D* TextureCache::get(String filename)
{
	string fullPath = SharedContent.getFullPath(filename);
	auto it = _textures.find(fullPath);
	if (it != _textures.end())
	{
		return it->second;
	}
	return nullptr;
}

static void releaseImage(void* _ptr, void* _userData)
{
	DORA_UNUSED_PARAM(_ptr);
	bimg::ImageContainer* imageContainer = s_cast<bimg::ImageContainer*>(_userData);
	bimg::imageFree(imageContainer);
}

Texture2D* TextureCache::update(String filename, const Uint8* data, Sint64 size)
{
	AssertUnless(data && size > 0, "add invalid data to texture cache.");
	bimg::ImageContainer* imageContainer = bimg::imageParse(&_allocator, data, s_cast<uint32_t>(size));
	if (imageContainer)
	{
		Uint64 flags = BGFX_SAMPLER_U_CLAMP | BGFX_SAMPLER_V_CLAMP;
		const bgfx::Memory* mem = bgfx::makeRef(
			imageContainer->m_data, imageContainer->m_size,
			releaseImage, imageContainer);
		bgfx::TextureHandle handle = bgfx::createTexture2D(
			s_cast<uint16_t>(imageContainer->m_width),
			s_cast<uint16_t>(imageContainer->m_height),
			imageContainer->m_numMips > 1,
			imageContainer->m_numLayers,
			s_cast<bgfx::TextureFormat::Enum>(imageContainer->m_format),
			flags,
			mem);
		bgfx::TextureInfo info;
		bgfx::calcTextureSize(info,
			s_cast<uint16_t>(imageContainer->m_width),
			s_cast<uint16_t>(imageContainer->m_height),
			s_cast<uint16_t>(imageContainer->m_depth),
			imageContainer->m_cubeMap,
			imageContainer->m_numMips > 1,
			imageContainer->m_numMips,
			s_cast<bgfx::TextureFormat::Enum>(imageContainer->m_format));
		Texture2D* texture = Texture2D::create(handle, info, flags);
		string fullPath = SharedContent.getFullPath(filename);
		_textures[fullPath] = texture;
		return texture;
	}
	Warn("texture format \"{}\" is not supported for \"{}\".", Path::getExt(filename), filename);
	return nullptr;
}

Texture2D* TextureCache::load(String filename)
{
	string fullPath = SharedContent.getFullPath(filename);
	auto it = _textures.find(fullPath);
	if (it != _textures.end())
	{
		return it->second;
	}
	auto data = SharedContent.load(filename);
	return update(filename, data.first.get(), data.second);
}

void TextureCache::loadAsync(String filename, const function<void(Texture2D*)>& handler)
{
	string fullPath = SharedContent.getFullPath(filename);
	auto it = _textures.find(fullPath);
	if (it != _textures.end())
	{
		handler(it->second);
		return;
	}
	string file(filename);
	SharedContent.loadAsyncUnsafe(fullPath, [this, file, handler](Uint8* data, Sint64 size)
	{
		if (!data)
		{
			Warn("failed to read file data from \"{}\".", file);
			handler(nullptr);
			return;
		}
		SharedAsyncThread.run([this, data, size]()
		{
			bimg::ImageContainer* imageContainer = bimg::imageParse(&_allocator, data, s_cast<uint32_t>(size));
			delete [] data;
			return Values::alloc(imageContainer);
		}, [this, file, handler](Own<Values> result)
		{
			bimg::ImageContainer* imageContainer;
			result->get(imageContainer);
			if (imageContainer)
			{
				Uint64 flags = BGFX_SAMPLER_U_CLAMP | BGFX_SAMPLER_V_CLAMP;
				const bgfx::Memory* mem = bgfx::makeRef(
					imageContainer->m_data, imageContainer->m_size,
					releaseImage, imageContainer);
				bgfx::TextureHandle handle = bgfx::createTexture2D(
					s_cast<uint16_t>(imageContainer->m_width),
					s_cast<uint16_t>(imageContainer->m_height),
					imageContainer->m_numMips > 1,
					imageContainer->m_numLayers,
					s_cast<bgfx::TextureFormat::Enum>(imageContainer->m_format),
					flags,
					mem);
				bgfx::TextureInfo info;
				bgfx::calcTextureSize(info,
					s_cast<uint16_t>(imageContainer->m_width),
					s_cast<uint16_t>(imageContainer->m_height),
					s_cast<uint16_t>(imageContainer->m_depth),
					imageContainer->m_cubeMap,
					imageContainer->m_numMips > 1,
					imageContainer->m_numMips,
					s_cast<bgfx::TextureFormat::Enum>(imageContainer->m_format));
				Texture2D* texture = Texture2D::create(handle, info, flags);
				string fullPath = SharedContent.getFullPath(file);
				_textures[fullPath] = texture;
				handler(texture);
			}
			else
			{
				Warn("texture format \"{}\" is not supported for \"{}\".", Path::getExt(file), file);
				handler(nullptr);
			}
		});
	});
}

bool TextureCache::unload(Texture2D* texture)
{
	for (const auto& it : _textures)
	{
		if (it.second == texture)
		{
			_textures.erase(_textures.find(it.first));
			return true;
		}
	}
	return false;
}

bool TextureCache::unload(String filename)
{
	string fullPath = SharedContent.getFullPath(filename);
	auto it = _textures.find(fullPath);
	if (it != _textures.end())
	{
		_textures.erase(it);
		return true;
	}
	return false;
}

bool TextureCache::unload()
{
	if (_textures.empty())
	{
		return false;
	}
	_textures.clear();
	return true;
}

void TextureCache::removeUnused()
{
	vector<unordered_map<string,Ref<Texture2D>>::iterator> targets;
	for (auto it = _textures.begin();it != _textures.end();++it)
	{
		if (it->second->isSingleReferenced())
		{
			targets.push_back(it);
		}
	}
	for (const auto& it : targets)
	{
		_textures.erase(it);
	}
}

NS_DOROTHY_END
