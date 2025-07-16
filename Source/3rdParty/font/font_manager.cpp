/*
 * Copyright 2013 Jeremie Roy, modified by Li Jin 2022. All rights reserved.
 * License: https://github.com/bkaradzic/bgfx#license-bsd-2-clause
 */

#include "Const/Header.h"
using namespace Dora;

#include "font/font_manager.h"

#define STBTT_DEF extern
#include "stb/stb_truetype.h"

#include "tinystl/allocator.h"
#include "tinystl/unordered_map.h"
namespace stl = tinystl;

#include "Other/atlas.h"
#include "Other/sdf_gen2d.h"

namespace bgfx {

class TrueTypeFont {
public:
	TrueTypeFont();
	~TrueTypeFont();

	/// Initialize from  an external buffer
	/// @remark The ownership of the buffer is external, and you must ensure it stays valid up to this object lifetime
	/// @return true if the initialization succeed
	bool init(const uint8_t* _buffer, uint32_t _bufferSize, uint32_t _pixelHeight, bool _sdf);

	/// return the font descriptor of the current font
	const stbtt_fontinfo& getSTBInfo() const;
	const FontInfo& getFontInfo() const;

	/// raster a glyph as 8bit alpha to a memory buffer
	/// update the GlyphInfo according to the raster strategy
	/// @ remark buffer min size: glyphInfo.m_width * glyphInfo * height * sizeof(char)
	bool bakeGlyphAlpha(CodePoint _codePoint, GlyphInfo& _outGlyphInfo, uint8_t* _outBuffer);

private:
	stbtt_fontinfo m_fontInfo;
	FontInfo m_info;
};

TrueTypeFont::TrueTypeFont()
	: m_fontInfo{} { }

TrueTypeFont::~TrueTypeFont() { }

bool TrueTypeFont::init(const uint8_t* _buffer, uint32_t _bufferSize, uint32_t _pixelHeight, bool _sdf) {
	AssertUnless(m_fontInfo.data == nullptr, "TrueTypeFont already initialized");
	_pixelHeight = Math::clamp(_pixelHeight, 5U, 128U);

	if (!stbtt_InitFont(&m_fontInfo, _buffer, stbtt_GetFontOffsetForIndex(_buffer, 0))) {
		Error("stbtt_InitFont failed.");
		return false;
	}

	float scale = stbtt_ScaleForPixelHeight(&m_fontInfo, s_cast<float>(_pixelHeight));
	int ascent, descent, lineGap;
	stbtt_GetFontVMetrics(&m_fontInfo, &ascent, &descent, &lineGap);
	m_info.sdf = _sdf;
	m_info.scale = scale;
	m_info.ascender = ascent * scale;
	m_info.descender = descent * scale;
	m_info.lineGap = lineGap * scale;
	m_info.pixelSize = _pixelHeight;

	return true;
}

const stbtt_fontinfo& TrueTypeFont::getSTBInfo() const {
	return m_fontInfo;
}

const FontInfo& TrueTypeFont::getFontInfo() const {
	return m_info;
}

static std::unique_ptr<uint8_t[]> padTexture(
	const uint8_t* originalData, // Original texture data
	int pixelHeight,
	int originalWidth, // Original width (e.g., 128)
	int originalHeight, // Original height (e.g., 128)
	int& newWidth, // Reference to store new width
	int& newHeight // Reference to store new height
) {
	// Calculate new dimensions
	int padding = pixelHeight * SDF_FONT_BUFFER_PADDING_RATIO;
	newWidth = originalWidth + 2 * padding;
	newHeight = originalHeight + 2 * padding;

	// Allocate memory for the new padded texture
	auto paddedData = std::make_unique<uint8_t[]>(newWidth * newHeight);

	// Copy the original texture data into the center of the padded texture
	for (int y = 0; y < originalHeight; ++y) {
		std::memcpy(
			paddedData.get() + (y + padding) * newWidth + padding, // Destination
			originalData + y * originalWidth, // Source
			sizeof(uint8_t) * originalWidth // Number of bytes to copy
		);
	}

	return paddedData;
}

bool TrueTypeFont::bakeGlyphAlpha(CodePoint _codePoint, GlyphInfo& _glyphInfo, uint8_t* _outBuffer) {
	AssertUnless(m_fontInfo.data, "TrueTypeFont not initialized");
	int left, top, right, bottom;
	stbtt_GetCodepointBitmapBox(&m_fontInfo, _codePoint, m_info.scale, m_info.scale, &left, &top, &right, &bottom);
	int advanceWidth;
	stbtt_GetCodepointHMetrics(&m_fontInfo, _codePoint, &advanceWidth, nullptr);
	_glyphInfo.offset_x = (float)left;
	_glyphInfo.offset_y = (float)top;
	_glyphInfo.width = (float)(right - left);
	_glyphInfo.height = (float)(bottom - top);
	_glyphInfo.advance_x = (float)(advanceWidth * m_info.scale);
	_glyphInfo.glyphIndex = stbtt_FindGlyphIndex(&m_fontInfo, _codePoint);
	stbtt_MakeCodepointBitmap(&m_fontInfo, _outBuffer, right - left, bottom - top, right - left, m_info.scale, m_info.scale, _codePoint);
	if (m_info.sdf && _glyphInfo.width > 0 && _glyphInfo.height > 0) {
		int newWidth = 0, newHeight = 0;
		auto paddingBuff = padTexture(_outBuffer, m_info.pixelSize, s_cast<int>(_glyphInfo.width), s_cast<int>(_glyphInfo.height), newWidth, newHeight);
		auto [sdfBuffer, sdfSize] = sdf::sdf_gen2d{}.build(paddingBuff.get(), newWidth, newHeight);
		_glyphInfo.width = newWidth;
		_glyphInfo.height = newHeight;
		std::memcpy(_outBuffer, sdfBuffer.get(), sizeof(sdfBuffer[0]) * sdfSize);
	}
	return true;
}

typedef stl::unordered_map<CodePoint, GlyphInfo> GlyphHashMap;

// cache font data
struct FontManager::CachedFont {
	CachedFont()
		: trueTypeFont(nullptr) { }

	FontInfo fontInfo;
	GlyphHashMap cachedGlyphs;
	Own<TrueTypeFont> trueTypeFont;
};

FontManager::FontManager(uint16_t _textureSideWidth)
	: m_currentAtlas(nullptr)
	, m_textureWidth(_textureSideWidth) {
	init();
}

void FontManager::init() {
	m_cachedFiles = NewArray<CachedFile>(MAX_OPENED_FILES);
	m_cachedFonts = NewArray<CachedFont>(MAX_OPENED_FONT);
	const int bufferSize = MAX_FONT_BUFFER_SIZE + MAX_SDF_FONT_BUFFER_PADDING;
	m_buffer = NewArray<uint8_t>(bufferSize * bufferSize);
	auto atlas = New<Atlas>(m_textureWidth, Atlas::Gray, true);
	m_currentAtlas = atlas.get();
	m_atlases.push_back(std::move(atlas));

	const uint32_t W = 3;
	uint8_t buffer[W * W * 1];
	bx::memSet(buffer, 255, W * W * 1);

	m_fallbackGlyph.width = W;
	m_fallbackGlyph.height = W;
	m_fallbackGlyph.regionIndex = m_currentAtlas->addRegion(W, W, buffer, 1);
	m_fallbackGlyph.atlas = m_currentAtlas;
}

FontManager::~FontManager() {
	assert(m_fontHandles.getNumHandles() == 0); // All the fonts must be destroyed before destroying the manager
	assert(m_filesHandles.getNumHandles() == 0); // All the font files must be destroyed before destroying the manager
}

TrueTypeHandle FontManager::createTtf(Dora::OwnArray<uint8_t>&& _buffer, uint32_t _size) {
	uint16_t id = m_filesHandles.alloc();
	AssertUnless(id != bx::kInvalidHandle, "Invalid handle used");
	m_cachedFiles.get()[id].buffer = std::move(_buffer);
	m_cachedFiles.get()[id].bufferSize = _size;

	TrueTypeHandle ret = {id};
	return ret;
}

void FontManager::destroyTtf(TrueTypeHandle _handle) {
	AssertUnless(bgfx::isValid(_handle), "Invalid handle used");
	m_cachedFiles.get()[_handle.idx].buffer = nullptr;
	m_cachedFiles.get()[_handle.idx].bufferSize = 0;
	m_cachedFiles.get()[_handle.idx].buffer = nullptr;
	m_filesHandles.free(_handle.idx);
}

FontManager::CachedFile* FontManager::getCachedFile(TrueTypeHandle _handle) const {
	AssertUnless(bgfx::isValid(_handle), "Invalid handle used");
	return &m_cachedFiles.get()[_handle.idx];
}

FontHandle FontManager::createFontByPixelSize(TrueTypeHandle _ttfHandle, uint32_t _pixelSize, bool _sdf) {
	AssertUnless(bgfx::isValid(_ttfHandle), "Invalid handle used");

	auto ttf = New<TrueTypeFont>();
	if (!ttf->init(m_cachedFiles.get()[_ttfHandle.idx].buffer.get(), m_cachedFiles.get()[_ttfHandle.idx].bufferSize, _pixelSize, _sdf)) {
		FontHandle invalid = BGFX_INVALID_HANDLE;
		return invalid;
	}

	uint16_t fontIdx = m_fontHandles.alloc();
	AssertUnless(fontIdx != bx::kInvalidHandle, "Invalid handle used");

	CachedFont& font = m_cachedFonts.get()[fontIdx];
	font.fontInfo = ttf->getFontInfo();
	font.trueTypeFont = std::move(ttf);
	font.fontInfo.pixelSize = uint16_t(_pixelSize);
	font.cachedGlyphs.clear();

	FontHandle handle = {fontIdx};
	return handle;
}

void FontManager::destroyFont(FontHandle _handle) {
	AssertUnless(bgfx::isValid(_handle), "Invalid handle used");

	CachedFont& font = m_cachedFonts.get()[_handle.idx];

	if (font.trueTypeFont != nullptr) {
		font.trueTypeFont = nullptr;
	}

	font.cachedGlyphs.clear();
	m_fontHandles.free(_handle.idx);
}

bool FontManager::preloadGlyph(FontHandle _handle, CodePoint _codePoint) {
	AssertUnless(bgfx::isValid(_handle), "Invalid handle used");
	CachedFont& font = m_cachedFonts.get()[_handle.idx];

	GlyphHashMap::iterator iter = font.cachedGlyphs.find(_codePoint);
	if (iter != font.cachedGlyphs.end()) {
		return true;
	}
	if (nullptr != font.trueTypeFont) {
		GlyphInfo glyphInfo;
		if (!font.trueTypeFont->bakeGlyphAlpha(_codePoint, glyphInfo, m_buffer.get())) {
			return false;
		}
		if (!addBitmap(glyphInfo, m_buffer.get())) {
			auto atlas = New<Atlas>(m_textureWidth, Atlas::Gray, true);
			m_currentAtlas = atlas.get();
			m_atlases.push_back(std::move(atlas));
			if (!addBitmap(glyphInfo, m_buffer.get())) {
				return false;
			}
		}
		font.cachedGlyphs[_codePoint] = glyphInfo;
		return true;
	}
	return false;
}

const FontInfo& FontManager::getFontInfo(FontHandle _handle) const {
	AssertUnless(bgfx::isValid(_handle), "Invalid handle used");
	return m_cachedFonts.get()[_handle.idx].fontInfo;
}

const GlyphInfo* FontManager::getGlyphInfo(FontHandle _handle, CodePoint _codePoint) {
	const GlyphHashMap& cachedGlyphs = m_cachedFonts.get()[_handle.idx].cachedGlyphs;
	GlyphHashMap::const_iterator it = cachedGlyphs.find(_codePoint);

	if (it == cachedGlyphs.end()) {
		if (!preloadGlyph(_handle, _codePoint)) {
			return &m_fallbackGlyph;
		}

		it = cachedGlyphs.find(_codePoint);
	}

	AssertUnless(it != cachedGlyphs.end(), "Failed to preload glyph.");
	return &it->second;
}

bool FontManager::addBitmap(GlyphInfo& _glyphInfo, const uint8_t* _data) {
	uint16_t regionIndex = m_currentAtlas->addRegion((uint16_t)ceil(_glyphInfo.width), (uint16_t)ceil(_glyphInfo.height), _data);
	if (regionIndex == UINT16_MAX) {
		return false;
	}
	_glyphInfo.regionIndex = regionIndex;
	_glyphInfo.atlas = m_currentAtlas;
	return true;
}

float FontManager::getKerning(FontHandle _handle, CodePoint _codeLeft, CodePoint _codeRight) {
	const CachedFont& font = m_cachedFonts.get()[_handle.idx];
	TrueTypeFont* trueTypeFont = font.trueTypeFont.get();
	const GlyphHashMap& cachedGlyphs = font.cachedGlyphs;
	GlyphHashMap::const_iterator left = cachedGlyphs.find(_codeLeft);
	GlyphHashMap::const_iterator right = cachedGlyphs.find(_codeRight);
	if (left != cachedGlyphs.end() && right != cachedGlyphs.end()) {
		int32_t leftIndex = left->second.glyphIndex;
		int32_t rightIndex = right->second.glyphIndex;
		return stbtt_GetGlyphKernAdvance(&trueTypeFont->getSTBInfo(), leftIndex, rightIndex) * trueTypeFont->getFontInfo().scale;
	}
	return 0.0f;
}

} // namespace bgfx
