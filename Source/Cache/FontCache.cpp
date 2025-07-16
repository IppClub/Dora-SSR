/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Cache/FontCache.h"

#include "Basic/Content.h"
#include "Effect/Effect.h"
#include "Node/Sprite.h"
#include "Other/atlas.h"
#include "Other/sdf_gen2d.h"
#include "Other/utf8.h"
#include "font/font_manager.h"

NS_DORA_BEGIN

/* TrueTypeFont */

uint32_t TrueTypeFile::_count = 0;
uint64_t TrueTypeFile::_storageSize = 0;

bgfx::TrueTypeHandle TrueTypeFile::getHandle() const noexcept {
	return _handle;
}

uint8_t* TrueTypeFile::getBuffer() const noexcept {
	return SharedFontManager.getCachedFile(_handle)->buffer.get();
}

uint32_t TrueTypeFile::getSize() const noexcept {
	return SharedFontManager.getCachedFile(_handle)->bufferSize;
}

uint32_t TrueTypeFile::getCount() {
	return _count;
}

uint64_t TrueTypeFile::getStorageSize() {
	return _storageSize;
}

TrueTypeFile::TrueTypeFile(bgfx::TrueTypeHandle handle)
	: _handle(handle) {
	_count++;
	_storageSize += getSize();
}

TrueTypeFile::~TrueTypeFile() {
	_count--;
	_storageSize -= getSize();
	SharedFontManager.destroyTtf(_handle);
	_handle = BGFX_INVALID_HANDLE;
}

/* Font */

bgfx::FontHandle Font::getHandle() const noexcept {
	return _handle;
}

Font::Font(NotNull<TrueTypeFile, 1> file, bgfx::FontHandle handle)
	: _file(file)
	, _handle(handle) { }

Font::~Font() {
	if (bgfx::isValid(_handle)) {
		SharedFontManager.destroyFont(_handle);
		_handle = BGFX_INVALID_HANDLE;
	}
}

const bgfx::FontInfo& Font::getInfo() const {
	return SharedFontManager.getFontInfo(_handle);
}

TrueTypeFile* Font::getFile() const noexcept {
	return _file;
}

/* FontCache */

FontCache::FontCache()
	: _defaultEffect(SpriteEffect::create("builtin:vs_sprite"_slice, "builtin:fs_spritewhite"_slice))
	, _sdfEffect(SpriteEffect::create("builtin:vs_sprite"_slice, "builtin:fs_spritesdfoutline"_slice)) { }

FontCache::~FontCache() {
	unload();
}

SpriteEffect* FontCache::getDefaultEffect() const noexcept {
	return _defaultEffect;
}

SpriteEffect* FontCache::getSDFEffect() const noexcept {
	return _sdfEffect;
}

std::tuple<std::string, int, bool> FontCache::getArgsFromStr(String fontStr) {
	auto tokens = fontStr.split(";"_slice);
	if (tokens.size() >= 2) {
		auto it = tokens.begin();
		Slice fontName = *it;
		int fontSize = (++it)->toInt();
		bool sdf = false;
		if (tokens.size() == 3 && *(++it) == "true"_slice) {
			sdf = true;
		}
		return {fontName.toString(), fontSize, sdf};
	} else {
		Error("invalid fontStr for \"{}\", expecting \"[fontName];[fontSize];[true or false as sdf]\".", fontStr.toString());
		return {Slice::Empty, 0, false};
	}
}

bool FontCache::unload() {
	if (_fonts.empty() && _fontFiles.empty()) {
		return false;
	}
	_fonts.clear();
	_fontFiles.clear();
	return true;
}

bool FontCache::unload(String fontStr) {
	std::string fontName;
	int fontSize = 0;
	bool sdf = false;
	std::tie(fontName, fontSize, sdf) = getArgsFromStr(fontStr);
	auto fontIt = _fonts.find(fontStr);
	if (fontIt != _fonts.end()) {
		TrueTypeFile* fontFile = fontIt->second->getFile();
		_fonts.erase(fontIt);
		if (fontFile->isSingleReferenced()) {
			auto fileIt = _fontFiles.find(fontName);
			if (fileIt != _fontFiles.end()) {
				_fontFiles.erase(fileIt);
			}
		}
		return true;
	}
	return false;
}

bool FontCache::unload(String fontName, uint32_t fontSize) {
	auto fontNameStr = fontName.toString();
	std::string fontFaceName = fmt::format("{};{}", fontNameStr, fontSize);
	auto fontIt = _fonts.find(fontFaceName);
	if (fontIt != _fonts.end()) {
		TrueTypeFile* fontFile = fontIt->second->getFile();
		_fonts.erase(fontIt);
		if (fontFile->isSingleReferenced()) {
			auto fileIt = _fontFiles.find(fontNameStr);
			if (fileIt != _fontFiles.end()) {
				_fontFiles.erase(fileIt);
			}
		}
		return true;
	}
	return false;
}

void FontCache::removeUnused() {
	for (auto it = _fonts.begin(); it != _fonts.end();) {
		if (it->second->isSingleReferenced()) {
			it = _fonts.erase(it);
		} else {
			++it;
		}
	}
	for (auto it = _fontFiles.begin(); it != _fontFiles.end();) {
		if (it->second->isSingleReferenced()) {
			it = _fontFiles.erase(it);
		} else {
			++it;
		}
	}
}

Font* FontCache::load(String fontStr) {
	std::string fontName;
	int fontSize = 0;
	bool sdf = false;
	std::tie(fontName, fontSize, sdf) = getArgsFromStr(fontStr);
	if (fontName.empty()) return nullptr;
	return load(fontName, fontSize, sdf);
}

Font* FontCache::load(String fontName, uint32_t fontSize, bool sdf) {
	auto name = Path::getName(fontName);
	std::string fontFaceName = fmt::format("{};{};{}", name, fontSize, sdf);
	auto fontIt = _fonts.find(fontFaceName);
	if (fontIt != _fonts.end()) {
		return fontIt->second;
	} else if (auto file = loadFontFile(fontName)) {
		bgfx::FontHandle fontHandle = SharedFontManager.createFontByPixelSize(file->getHandle(), fontSize, sdf);
		Font* font = Font::create(file, fontHandle);
		_fonts[fontFaceName] = font;
		return font;
	} else {
		return nullptr;
	}
}

TrueTypeFile* FontCache::loadFontFile(String fontName) {
	std::string fontNameStr = fontName.toString();
	std::string fontFile;
	BLOCK_START
	fontFile = SharedContent.getFullPath(fontNameStr);
	BREAK_IF(SharedContent.exist(fontFile));
	fontFile = SharedContent.getFullPath("Font/"s + fontNameStr + ".ttf"s);
	BREAK_IF(SharedContent.exist(fontFile));
	fontFile = SharedContent.getFullPath("Font/"s + fontNameStr + ".otf"s);
	BREAK_IF(SharedContent.exist(fontFile));
	Error("can not load font file named \"{}\".", fontNameStr);
	return nullptr;
	BLOCK_END
	auto fileIt = _fontFiles.find(fontFile);
	if (fileIt != _fontFiles.end()) {
		return fileIt->second.get();
	} else {
		auto data = SharedContent.load(fontFile);
		if (!data.first) {
			Error("failed to load font \"{}\".", fontNameStr);
			return nullptr;
		}
		bgfx::TrueTypeHandle trueTypeHandle = SharedFontManager.createTtf(std::move(data.first), s_cast<uint32_t>(data.second));
		TrueTypeFile* file = TrueTypeFile::create(trueTypeHandle);
		_fontFiles[fontFile] = file;
		return file;
	}
}

void FontCache::loadAync(String fontStr, const std::function<void(Font* fontHandle)>& callback) {
	std::string fontName;
	int fontSize = 0;
	bool sdf = false;
	std::tie(fontName, fontSize, sdf) = getArgsFromStr(fontStr);
	if (fontName.empty()) {
		callback(nullptr);
		return;
	}
	loadAync(fontName, fontSize, sdf, callback);
}

void FontCache::loadAync(String fontName, uint32_t fontSize, bool sdf, const std::function<void(Font* fontHandle)>& callback) {
	auto name = Path::getName(fontName);
	std::string fontFaceName = fmt::format("{};{};{}", name, fontSize, sdf);
	auto fontIt = _fonts.find(fontFaceName);
	if (fontIt != _fonts.end()) {
		callback(fontIt->second);
	} else {
		std::string fontNameStr = fontName.toString();
		std::string fontFile;
		BLOCK_START
		fontFile = SharedContent.getFullPath(fontNameStr);
		BREAK_IF(SharedContent.exist(fontFile));
		fontFile = SharedContent.getFullPath("Font/"s + fontNameStr + ".ttf"s);
		BREAK_IF(SharedContent.exist(fontFile));
		fontFile = SharedContent.getFullPath("Font/"s + fontNameStr + ".otf"s);
		BREAK_IF(SharedContent.exist(fontFile));
		Error("can not load font file named \"{}\".", fontNameStr);
		callback(nullptr);
		BLOCK_END
		auto fileIt = _fontFiles.find(fontFile);
		if (fileIt != _fontFiles.end()) {
			bgfx::FontHandle fontHandle = SharedFontManager.createFontByPixelSize(fileIt->second->getHandle(), fontSize, sdf);
			Font* font = Font::create(fileIt->second.get(), fontHandle);
			_fonts[fontFaceName] = font;
			callback(font);
		} else {
			SharedContent.loadAsyncUnsafe(fontFile, [this, fontFaceName, fontFile, fontSize, sdf, callback](uint8_t* data, int64_t size) {
				bgfx::TrueTypeHandle trueTypeHandle = SharedFontManager.createTtf(MakeOwnArray(data), s_cast<uint32_t>(size));
				TrueTypeFile* file = TrueTypeFile::create(trueTypeHandle);
				_fontFiles[fontFile] = file;
				bgfx::FontHandle fontHandle = SharedFontManager.createFontByPixelSize(trueTypeHandle, fontSize, sdf);
				Font* font = Font::create(file, fontHandle);
				_fonts[fontFaceName] = font;
				callback(font);
			});
		}
	}
}

Sprite* FontCache::createCharacter(Font* font, bgfx::CodePoint character) {
	Texture2D* texture;
	Rect rect;
	std::tie(texture, rect) = getCharacterInfo(font, character);
	Sprite* sprite = Sprite::create(texture, rect);
	return sprite;
}

std::tuple<Texture2D*, Rect> FontCache::getCharacterInfo(Font* font, bgfx::CodePoint character) {
	const bgfx::GlyphInfo* glyphInfo = SharedFontManager.getGlyphInfo(font->getHandle(), character);
	bgfx::Atlas* atlas = glyphInfo->atlas;
	const bgfx::AtlasRegion& region = atlas->getRegion(glyphInfo->regionIndex);
	if (font->getInfo().sdf) {
		return std::make_tuple(atlas->getTexture(), Rect(region.x, region.y, region.width, region.height));
	}
	return std::make_tuple(atlas->getTexture(), Rect(region.x, region.y, region.width, region.height));
}

const bgfx::GlyphInfo* FontCache::getGlyphInfo(Font* font, bgfx::CodePoint character) {
	return SharedFontManager.getGlyphInfo(font->getHandle(), character);
}

const bgfx::GlyphInfo* FontCache::updateCharacter(Sprite* sp, Font* font, bgfx::CodePoint character) {
	const bgfx::GlyphInfo* glyphInfo = SharedFontManager.getGlyphInfo(font->getHandle(), character);
	bgfx::Atlas* atlas = glyphInfo->atlas;
	const bgfx::AtlasRegion& region = atlas->getRegion(glyphInfo->regionIndex);
	sp->setTexture(atlas->getTexture());
	sp->setTextureRect(Rect(region.x, region.y, region.width, region.height));
	sp->setSize(sp->getTextureRect().size);
	return glyphInfo;
}

NS_DORA_END
