/* Copyright (c) 2017 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Cache/TextureCache.h"
#include "bx/endian.h"
#include "lodepng.h"

void* lodepng_malloc(size_t size)
{
	return ::malloc(size);
}

void* lodepng_realloc(void* ptr, size_t new_size)
{
	return ::realloc(ptr, new_size);
}

void lodepng_free(void* ptr)
{
	::free(ptr);
}

static void lodepng_free(void* _ptr, void* _userData)
{
	DORA_UNUSED_PARAM(_userData);
	lodepng_free(_ptr);
}

NS_DOROTHY_BEGIN

Texture2D::Texture2D(bgfx::TextureHandle handle, const bgfx::TextureInfo& info):
_handle(handle),
_info(info)
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

Texture2D::~Texture2D()
{
	if (bgfx::isValid(_handle))
	{
		bgfx::destroyTexture(_handle);
		_handle = BGFX_INVALID_HANDLE;
	}
}

TextureCache::TextureCache()
{ }

void TextureCache::set(String name, Texture2D* texture)
{
	_textures[name] = texture;
}

Texture2D* TextureCache::load(String filename)
{
	string fullPath = SharedContent.getFullPath(filename);
	auto it = _textures.find(fullPath);
	if (it != _textures.end())
	{
		return it->second;
	}
	string extension = filename.getFileExtension();
	switch (Switch::hash(extension))
	{
		case "dds"_hash:
		case "pvr"_hash:
		case "ktx"_hash:
		{
			bgfx::TextureInfo info;
			const bgfx::Memory* mem = SharedContent.loadFileBX(fullPath);
			if (mem->data)
			{
				bgfx::TextureHandle handle = bgfx::createTexture(mem, BGFX_TEXTURE_U_CLAMP | BGFX_TEXTURE_V_CLAMP, 0, &info);
				Texture2D* texture = Texture2D::create(handle, info);
				_textures[fullPath] = texture;
				return texture;
			}
			Log("failed to load texture \"%s\".", filename);
			return nullptr;
		}
		case "png"_hash:
		{
			auto data = SharedContent.loadFile(fullPath);
			if (data)
			{
				bgfx::TextureFormat::Enum format = bgfx::TextureFormat::RGBA8;
				uint32_t bpp = 32;
				uint32_t width = 0;
				uint32_t height = 0;
				uint8_t* out = nullptr;
				TextureCache::loadPNG(data, out, width, height, bpp, format);
				if (out)
				{
					const bgfx::Memory* mem = bgfx::makeRef(
						out, width * height * bpp / 8, lodepng_free);

					bgfx::TextureHandle handle = bgfx::createTexture2D(
						  uint16_t(width), uint16_t(height),
						  false, 1, format, BGFX_TEXTURE_U_CLAMP | BGFX_TEXTURE_V_CLAMP,
						  mem);

					bgfx::TextureInfo info;
					bgfx::calcTextureSize(info,
						uint16_t(width), uint16_t(height),
						0, false, false, 1, format);

					Texture2D* texture = Texture2D::create(handle, info);
					_textures[fullPath] = texture;
					return texture;
				}
			}
			Log("failed to load texture \"%s\".", filename);
			return nullptr;
		}
		default:
		{
			Log("texture format \"%s\" is not supported for \"%s\".", extension, filename);
			return nullptr;
		}
	}
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
	string extension = filename.getFileExtension();
	switch (Switch::hash(extension))
	{
		case "dds"_hash:
		case "pvr"_hash:
		case "ktx"_hash:
		{
			Ref<TextureCache> self(this);
			string file(filename);
			SharedContent.loadFileAsyncBX(filename, [self, file, fullPath, handler](const bgfx::Memory* mem)
			{
				if (mem->data)
				{
					bgfx::TextureInfo info;
					bgfx::TextureHandle handle = bgfx::createTexture(mem, BGFX_TEXTURE_U_CLAMP | BGFX_TEXTURE_V_CLAMP, 0, &info);
					Texture2D* texture = Texture2D::create(handle, info);
					auto it = self->_textures.find(fullPath);
					if (it == self->_textures.end())
					{
						self->_textures[fullPath] = texture;
						handler(texture);
					}
					else
					{
						Log("duplicated copy of \"%s\" was loaded and will then be destroyed.", file);
						handler(it->second);
					}
				}
				else
				{
					Log("failed to load texture \"%s\".", file);
					handler(nullptr);
				}
			});
			break;
		}
		case "png"_hash:
		{
			Ref<TextureCache> self(this);
			string fullPath = SharedContent.getFullPath(filename);
			string file(filename);
			SharedContent.loadFileAsyncUnsafe(filename, [self, file, fullPath, handler](Uint8* data, Sint64 size)
			{
				if (data)
				{
					Async::Process.run([data, size, self]()
					{
						auto localData = MakeOwnArray(data, s_cast<size_t>(size));
						uint8_t* out = nullptr;
						uint32_t width = 0, height = 0, bpp = 32;
						bgfx::TextureFormat::Enum format = bgfx::TextureFormat::RGBA8;
						TextureCache::loadPNG(localData, out, width, height, bpp, format);
						return Values::create(out, width, height, bpp, format);
					}, [self, file, fullPath, handler](Values* result)
					{
						uint8_t* out;
						uint32_t width, height, bpp;
						bgfx::TextureFormat::Enum format;
						result->get(out, width, height, bpp, format);
						if (out)
						{
							const bgfx::Memory* mem = bgfx::makeRef(
								out, width * height * bpp / 8, lodepng_free);

							bgfx::TextureHandle handle = bgfx::createTexture2D(
								  uint16_t(width), uint16_t(height),
								  false, 1, format, BGFX_TEXTURE_U_CLAMP | BGFX_TEXTURE_V_CLAMP,
								  mem);

							bgfx::TextureInfo info;
							bgfx::calcTextureSize(info,
								uint16_t(width), uint16_t(height),
								0, false, false, 1, format);

							Texture2D* texture = Texture2D::create(handle, info);
							auto it = self->_textures.find(fullPath);
							if (it == self->_textures.end())
							{
								self->_textures[fullPath] = texture;
								handler(texture);
							}
							else
							{
								Log("duplicated copy of \"%s\" was loaded and will then be destroyed.", file);
								handler(it->second);
							}
						}
					});
				}
				else
				{
					Log("failed to load texture \"%s\".", file);
					handler(nullptr);
				}
			});
			break;
		}
		default:
		{
			Log("texture format \"%s\" is not supported for \"%s\".", extension, filename);
			handler(nullptr);
			break;
		}
	}
}

void TextureCache::loadPNG(const OwnArray<Uint8>& data, uint8_t*& out, uint32_t& width, uint32_t& height, uint32_t& bpp, bgfx::TextureFormat::Enum& format)
{
	static const uint8_t pngMagic[] = {0x89, 0x50, 0x4E, 0x47, 0x0d, 0x0a};
	if (0 == memcmp(data, pngMagic, sizeof(pngMagic)))
	{
		unsigned error;
		LodePNGState state;
		lodepng_state_init(&state);
		state.decoder.color_convert = 0;
		error = lodepng_decode(&out, &width, &height, &state, data, data.size());
		if (0 == error)
		{
			switch (state.info_raw.bitdepth)
			{
			case 8:
				switch (state.info_raw.colortype)
				{
				case LCT_GREY:
					format = bgfx::TextureFormat::R8;
					bpp = 8;
					break;
				case LCT_GREY_ALPHA:
					format = bgfx::TextureFormat::RG8;
					bpp = 16;
					break;
				case LCT_RGB:
					format = bgfx::TextureFormat::RGB8;
					bpp = 24;
					break;
				case LCT_RGBA:
					format = bgfx::TextureFormat::RGBA8;
					bpp = 32;
					break;
				case LCT_PALETTE:
					format = bgfx::TextureFormat::R8;
					bpp = 8;
					break;
				}
				break;
			case 16:
				switch (state.info_raw.colortype)
				{
				case LCT_GREY:
					for (uint32_t ii = 0, num = width*height; ii < num; ++ii)
					{
						uint16_t* rgba = (uint16_t*)out + ii*4;
						rgba[0] = bx::toHostEndian(rgba[0], false);
					}
					format = bgfx::TextureFormat::R16;
					bpp = 16;
					break;
				case LCT_GREY_ALPHA:
					for (uint32_t ii = 0, num = width*height; ii < num; ++ii)
					{
						uint16_t* rgba = (uint16_t*)out + ii*4;
						rgba[0] = bx::toHostEndian(rgba[0], false);
						rgba[1] = bx::toHostEndian(rgba[1], false);
					}
					format = bgfx::TextureFormat::R16;
					bpp = 16;
					break;
				case LCT_RGBA:
					for (uint32_t ii = 0, num = width*height; ii < num; ++ii)
					{
						uint16_t* rgba = (uint16_t*)out + ii*4;
						rgba[0] = bx::toHostEndian(rgba[0], false);
						rgba[1] = bx::toHostEndian(rgba[1], false);
						rgba[2] = bx::toHostEndian(rgba[2], false);
						rgba[3] = bx::toHostEndian(rgba[3], false);
					}
					format = bgfx::TextureFormat::RGBA16;
					bpp = 64;
					break;
				case LCT_RGB:
				case LCT_PALETTE:
					break;
				}
				break;
			default:
				break;
			}
		}
		lodepng_state_cleanup(&state);
	}
}

void TextureCache::unload(Texture2D* texture)
{
	for (const auto& it : _textures)
	{
		if (it.second == texture)
		{
			_textures.erase(_textures.find(it.first));
			return;
		}
	}
}

void TextureCache::unload(String filename)
{
	string fullPath = SharedContent.getFullPath(filename);
	auto it = _textures.find(fullPath);
	if (it != _textures.end())
	{
		_textures.erase(it);
	}
}

void TextureCache::clear()
{
	_textures.clear();
}

void TextureCache::clearUnused()
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
