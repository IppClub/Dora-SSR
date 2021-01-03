/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

NS_DOROTHY_BEGIN

enum struct TextureWrap
{
	None,
	Mirror,
	Clamp,
	Border
};

enum struct TextureFilter
{
	None,
	Point,
	Anisotropic
};

class Texture2D : public Object
{
public:
	PROPERTY_READONLY(bgfx::TextureHandle, Handle);
	PROPERTY_READONLY(int, Width);
	PROPERTY_READONLY(int, Height);
	PROPERTY_READONLY_CREF(bgfx::TextureInfo, Info);
	PROPERTY_READONLY(TextureFilter, Filter);
	PROPERTY_READONLY(TextureWrap, UWrap);
	PROPERTY_READONLY(TextureWrap, VWrap);
	PROPERTY_READONLY(Uint64, Flags);
	virtual ~Texture2D();
	CREATE_FUNC(Texture2D);
protected:
	Texture2D(bgfx::TextureHandle handle, const bgfx::TextureInfo& info, Uint64 flags);
	bgfx::TextureHandle _handle;
private:
	Uint64 _flags;
	bgfx::TextureInfo _info;
	DORA_TYPE_OVERRIDE(Texture2D);
};

class TextureCache
{
public:
	virtual ~TextureCache() { }
	Texture2D* update(String name, Texture2D* texture);
	Texture2D* update(String filename, const Uint8* data, Sint64 size);
	Texture2D* get(String filename);
	/** @brief support format .jpg .png .dds .pvr .ktx */
	Texture2D* load(String filename);
	void loadAsync(String filename, const function<void(Texture2D*)>& handler);
    bool unload(Texture2D* texture);
    bool unload(String filename);
    bool unload();
    void removeUnused();
protected:
	TextureCache() { }
private:
	bx::DefaultAllocator _allocator;
	unordered_map<string, Ref<Texture2D>> _textures;
	SINGLETON_REF(TextureCache, BGFXDora);
};

#define SharedTextureCache \
	Dorothy::Singleton<Dorothy::TextureCache>::shared()

NS_DOROTHY_END
