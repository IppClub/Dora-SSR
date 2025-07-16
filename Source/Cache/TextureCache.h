/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "bx/allocator.h"

NS_DORA_BEGIN

enum struct TextureWrap {
	None = 0,
	Mirror = 1,
	Clamp = 2,
	Border = 3
};

enum struct TextureFilter {
	None = 0,
	Point = 1,
	Anisotropic = 2
};

class Texture2D : public Object {
public:
	PROPERTY_READONLY(bgfx::TextureHandle, Handle);
	PROPERTY_READONLY(int, Width);
	PROPERTY_READONLY(int, Height);
	PROPERTY_READONLY_CREF(bgfx::TextureInfo, Info);
	PROPERTY_READONLY(TextureFilter, Filter);
	PROPERTY_READONLY(TextureWrap, UWrap);
	PROPERTY_READONLY(TextureWrap, VWrap);
	PROPERTY_READONLY(uint64_t, Flags);
	PROPERTY_READONLY_CLASS(uint64_t, StorageSize);
	PROPERTY_READONLY_CLASS(uint32_t, Count);
	virtual ~Texture2D();
	CREATE_FUNC_NOT_NULL(Texture2D);

protected:
	Texture2D(bgfx::TextureHandle handle, const bgfx::TextureInfo& info, uint64_t flags);
	bgfx::TextureHandle _handle;

private:
	uint64_t _flags;
	bgfx::TextureInfo _info;
	static uint64_t _storageSize;
	static uint32_t _count;
	DORA_TYPE_OVERRIDE(Texture2D);
};

class TextureCache : public NonCopyable {
public:
	virtual ~TextureCache() { }
	Texture2D* update(String name, Texture2D* texture);
	Texture2D* update(String filename, const uint8_t* data, int64_t size);
	Texture2D* get(String filename);
	/** @brief support format .jpg .png .dds .pvr .ktx */
	Texture2D* load(String filename);
	void loadAsync(String filename, const std::function<void(Texture2D*)>& handler);
	bool unload(Texture2D* texture);
	bool unload(String filename);
	bool unload();
	void removeUnused();

protected:
	TextureCache() { }

private:
	bx::DefaultAllocator _allocator;
	StringMap<Ref<Texture2D>> _textures;
	SINGLETON_REF(TextureCache, BGFXDora);
};

#define SharedTextureCache \
	Dora::Singleton<Dora::TextureCache>::shared()

NS_DORA_END
