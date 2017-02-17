/* Copyright (c) 2017 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "font/font_manager.h"

NS_DOROTHY_BEGIN

class FontCache
{
public:
	PROPERTY_READONLY(SpriteEffect*, DefaultEffect);
	virtual ~FontCache();
	void loadAync(String fontName, Uint32 fontSize, Uint32 fontIndex,
		const function<void(bgfx::FontHandle fontHandle)>& callback);
	bgfx::FontHandle load(String fontName, Uint32 fontSize, Uint32 fontIndex = 0);
	void unload();
	Sprite* createCharacter(bgfx::FontHandle fontHandle, bgfx::CodePoint character);
	std::tuple<Texture2D*, Rect> getCharacterInfo(bgfx::FontHandle fontHandle, bgfx::CodePoint character);
	const bgfx::GlyphInfo* getGlyphInfo(bgfx::FontHandle fontHandle, bgfx::CodePoint character);
protected:
	FontCache();
private:
	Ref<SpriteEffect> _defaultEffect;
	unordered_map<string, bgfx::TrueTypeHandle> _fonts;
	unordered_map<string, bgfx::FontHandle> _fontFaces;
	bgfx::FontManager _fontManager;
};

#define SharedFontCache \
	silly::Singleton<FontCache, SingletonIndex::FontCache>::shared()

ENUM_START(TextAlignment)
{
	Left,
	Center,
	Right
}
ENUM_END(TextAlignment)

class Label : public Node
{
public:
	static const int AutomaticWidth;
protected:

private:

};


NS_DOROTHY_END
