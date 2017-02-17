/* Copyright (c) 2017 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Node/Label.h"
#include "font/font_manager.h"
#include "Other/atlas.h"

NS_DOROTHY_BEGIN

/* FontCache */

FontCache::FontCache():
_defaultEffect(SpriteEffect::create(SharedShaderCache.load("vs_sprite.bin"), SharedShaderCache.load("fs_spritewhite.bin")))
{ }

FontCache::~FontCache()
{
	unload();
}

void FontCache::unload()
{
	if (!_fontFaces.empty())
	{
		for (const auto& it : _fontFaces)
		{
			_fontManager.destroyFont(it.second);
		}
		_fontFaces.clear();
	}
	if (!_fonts.empty())
	{
		for (const auto& it : _fonts)
		{
			_fontManager.destroyTtf(it.second);
		}
		_fonts.clear();
	}
}

bgfx::FontHandle FontCache::load(String fontName, Uint32 fontSize, Uint32 fontIndex)
{
	ostringstream stream;
	stream << fontName.toString() << '_' << fontSize << '_' << fontIndex;
	string fontFaceName = stream.str();
	auto faceIt = _fontFaces.find(fontFaceName);
	if (faceIt != _fontFaces.end())
	{
		return faceIt->second;
	}
	else
	{
		auto fontIt = _fonts.find(fontName);
		if (fontIt != _fonts.end())
		{
			bgfx::FontHandle fontHandle = _fontManager.createFontByPixelSize(fontIt->second, fontIndex, fontSize);
			_fontFaces[fontFaceName] = fontHandle;
			return fontHandle;
		}
		else
		{
			string fontFile = "Font/" + fontName.toString() + ".ttf";
			if (!SharedContent.isFileExist(fontFile))
			{
				fontFile = "Font/" + fontName.toString() + ".otf";
				if (!SharedContent.isFileExist(fontFile))
				{
					return bgfx::FontHandle { bgfx::invalidHandle };
				}
			}
			auto data = SharedContent.loadFile(fontFile);
			bgfx::TrueTypeHandle trueTypeHandle = _fontManager.createTtf(data, s_cast<Uint32>(data.size()));
			_fonts[fontName] = trueTypeHandle;
			bgfx::FontHandle fontHandle = _fontManager.createFontByPixelSize(trueTypeHandle, fontIndex, fontSize);
			_fontFaces[fontFaceName] = fontHandle;
			return fontHandle;
		}

	}
}

void FontCache::loadAync(String fontName, Uint32 fontSize, Uint32 fontIndex, const function<void(bgfx::FontHandle fontHandle)>& callback)
{
	ostringstream stream;
	stream << fontName.toString() << '_' << fontSize << '_' << fontIndex;
	string fontFaceName = stream.str();
	auto faceIt = _fontFaces.find(fontFaceName);
	if (faceIt != _fontFaces.end())
	{
		callback(faceIt->second);
	}
	else
	{
		auto fontIt = _fonts.find(fontName);
		if (fontIt != _fonts.end())
		{
			bgfx::FontHandle fontHandle = _fontManager.createFontByPixelSize(fontIt->second, fontIndex, fontSize);
			_fontFaces[fontFaceName] = fontHandle;
			callback(fontHandle);
		}
		else
		{
			string fontFile = "Font/" + fontName.toString() + ".ttf";
			if (!SharedContent.isFileExist(fontFile))
			{
				fontFile = "Font/" + fontName.toString() + ".otf";
				if (!SharedContent.isFileExist(fontFile))
				{
					callback(bgfx::FontHandle { bgfx::invalidHandle });
				}
			}
			SharedContent.loadFileAsyncUnsafe(fontFile, [this, fontFaceName, fontName, fontIndex, fontSize, callback](Uint8* data, Sint64 size)
			{
				bgfx::TrueTypeHandle trueTypeHandle = _fontManager.createTtf(data, s_cast<Uint32>(size));
				_fonts[fontName] = trueTypeHandle;
				bgfx::FontHandle fontHandle = _fontManager.createFontByPixelSize(trueTypeHandle, fontIndex, fontSize);
				_fontFaces[fontFaceName] = fontHandle;
				callback(fontHandle);
			});
		}
	}
}

Sprite* FontCache::createCharacter(bgfx::FontHandle fontHandle, bgfx::CodePoint character)
{
	Texture2D* texture;
	Rect rect;
	std::tie(texture, rect) = getCharacterInfo(fontHandle, character);
	Sprite* sprite = Sprite::create(texture, rect);
	sprite->setEffect(_defaultEffect);
	return sprite;
}

std::tuple<Texture2D*, Rect> FontCache::getCharacterInfo(bgfx::FontHandle fontHandle, bgfx::CodePoint character)
{
	const bgfx::GlyphInfo* glyphInfo = _fontManager.getGlyphInfo(fontHandle, character);
	bgfx::Atlas* atlas = glyphInfo->atlas;
	const bgfx::AtlasRegion& region = atlas->getRegion(glyphInfo->regionIndex);
	return std::make_tuple(atlas->getTexture(), Rect(region.x, region.y, region.width, region.height));
}

const bgfx::GlyphInfo* FontCache::getGlyphInfo(bgfx::FontHandle fontHandle, bgfx::CodePoint character)
{
	return _fontManager.getGlyphInfo(fontHandle, character);
}

NS_DOROTHY_END
