/* Copyright (c) 2017 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

NS_DOROTHY_BEGIN

class Texture2D : public Object
{
public:
	PROPERTY_READONLY(bgfx::TextureHandle, Handle);
	PROPERTY_READONLY(int, Width);
	PROPERTY_READONLY(int, Height);
	PROPERTY_READONLY_REF(bgfx::TextureInfo, Info);
	virtual ~Texture2D();
	CREATE_FUNC(Texture2D);
protected:
	Texture2D(bgfx::TextureHandle handle, const bgfx::TextureInfo& info);
private:
	bgfx::TextureHandle _handle;
	bgfx::TextureInfo _info;
	DORA_TYPE_OVERRIDE(Texture2D);
};

class TextureCache : public Object
{
public:
	void set(String name, Texture2D* texture);
	/** @brief support format .png .dds .pvr .ktx */
	Texture2D* load(String filename);
	void loadAsync(String filename, const function<void(Texture2D*)>& handler);
    void unload(Texture2D* texture);
    void unload(String filename);
    void clear();
    void clearUnused();
protected:
	TextureCache();
	static void loadPNG(const OwnArray<Uint8>& data, uint8_t*& out,
		uint32_t& width, uint32_t& height, uint32_t& bpp,
		bgfx::TextureFormat::Enum& format);
private:
	unordered_map<string, Ref<Texture2D>> _textures;
	DORA_TYPE_OVERRIDE(TextureCache);
};

#define SharedTextureCache \
	silly::Singleton<TextureCache, SingletonIndex::TextureCache>::shared()

NS_DOROTHY_END
