/*
 * Copyright 2013 Jeremie Roy. All rights reserved.
 * License: https://github.com/bkaradzic/bgfx#license-bsd-2-clause
 */

#include "Const/Header.h"
using namespace Dorothy;
#include "bx/macros.h"

#define STBTT_DEF extern
#include "stb/stb_truetype.h"

#include "bgfx/bgfx.h"

#include "tinystl/allocator.h"
#include "tinystl/unordered_map.h"
namespace stl = tinystl;

#include "font/font_manager.h"
#include "Other/atlas.h"

namespace bgfx {

class TrueTypeFont
{
public:
	TrueTypeFont();
	~TrueTypeFont();

	/// Initialize from  an external buffer
	/// @remark The ownership of the buffer is external, and you must ensure it stays valid up to this object lifetime
	/// @return true if the initialization succeed
	bool init(const uint8_t* _buffer, uint32_t _bufferSize, uint32_t _pixelHeight);

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

TrueTypeFont::TrueTypeFont():m_fontInfo{}
{ }

TrueTypeFont::~TrueTypeFont()
{ }

bool TrueTypeFont::init(const uint8_t* _buffer, uint32_t _bufferSize, uint32_t _pixelHeight)
{
	AssertUnless(m_fontInfo.data == nullptr, "TrueTypeFont already initialized");
	_pixelHeight = Math::clamp(_pixelHeight, 5U, 127U);

	if (!stbtt_InitFont(&m_fontInfo, _buffer, stbtt_GetFontOffsetForIndex(_buffer, 0)))
	{
		Error("stbtt_InitFont failed.");
		return false;
	}

	float scale = stbtt_ScaleForPixelHeight(&m_fontInfo, s_cast<float>(_pixelHeight));
	int ascent, descent, lineGap;
	stbtt_GetFontVMetrics(&m_fontInfo, &ascent, &descent, &lineGap);
	m_info.scale = scale;
	m_info.ascender = ascent * scale;
	m_info.descender = descent * scale;
	m_info.lineGap = lineGap * scale;
	m_info.pixelSize = _pixelHeight;

	return true;
}

const stbtt_fontinfo& TrueTypeFont::getSTBInfo() const
{
	return m_fontInfo;
}

const FontInfo& TrueTypeFont::getFontInfo() const
{
	return m_info;
}

bool TrueTypeFont::bakeGlyphAlpha(CodePoint _codePoint, GlyphInfo& _glyphInfo, uint8_t* _outBuffer)
{
	AssertUnless(m_fontInfo.data, "TrueTypeFont not initialized");
	int left, top, right, bottom;
	stbtt_GetCodepointBitmapBox(&m_fontInfo, _codePoint, m_info.scale, m_info.scale, &left, &top, &right, &bottom);
	int advanceWidth;
	stbtt_GetCodepointHMetrics(&m_fontInfo, _codePoint, &advanceWidth, nullptr);
	_glyphInfo.offset_x = (float)left;
	_glyphInfo.offset_y = (float)top;
	_glyphInfo.width = (float)(right-left);
	_glyphInfo.height = (float)(bottom-top);
	_glyphInfo.advance_x = (float)(advanceWidth * m_info.scale);
	_glyphInfo.glyphIndex = stbtt_FindGlyphIndex(&m_fontInfo, _codePoint);
	stbtt_MakeCodepointBitmap(&m_fontInfo, _outBuffer, right-left, bottom-top, right-left, m_info.scale, m_info.scale, _codePoint);
	return true;
}

typedef stl::unordered_map<CodePoint, GlyphInfo> GlyphHashMap;

// cache font data
struct FontManager::CachedFont
{
	CachedFont()
		: trueTypeFont(nullptr)
	{ }

	FontInfo fontInfo;
	GlyphHashMap cachedGlyphs;
	TrueTypeFont* trueTypeFont;
};

FontManager::FontManager(uint16_t _textureSideWidth)
	: m_currentAtlas(nullptr)
	, m_textureWidth(_textureSideWidth)
{
	init();
}

void FontManager::init()
{
	m_cachedFiles = NewArray<CachedFile>(MAX_OPENED_FILES);
	m_cachedFonts = NewArray<CachedFont>(MAX_OPENED_FONT);
	m_buffer = NewArray<uint8_t>(MAX_FONT_BUFFER_SIZE * MAX_FONT_BUFFER_SIZE * 1);
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

FontManager::~FontManager()
{
	assert(m_fontHandles.getNumHandles() == 0); // All the fonts must be destroyed before destroying the manager
	assert(m_filesHandles.getNumHandles() == 0); // All the font files must be destroyed before destroying the manager
}

TrueTypeHandle FontManager::createTtf(const uint8_t* _buffer, uint32_t _size)
{
	uint16_t id = m_filesHandles.alloc();
	AssertUnless(id != bx::kInvalidHandle, "Invalid handle used");
	m_cachedFiles.get()[id].buffer = new uint8_t[_size];
	m_cachedFiles.get()[id].bufferSize = _size;
	memcpy(m_cachedFiles.get()[id].buffer, _buffer, _size);

	TrueTypeHandle ret = { id };
	return ret;
}

void FontManager::destroyTtf(TrueTypeHandle _handle)
{
	AssertUnless(bgfx::isValid(_handle), "Invalid handle used");
	delete m_cachedFiles.get()[_handle.idx].buffer;
	m_cachedFiles.get()[_handle.idx].bufferSize = 0;
	m_cachedFiles.get()[_handle.idx].buffer = NULL;
	m_filesHandles.free(_handle.idx);
}

FontHandle FontManager::createFontByPixelSize(TrueTypeHandle _ttfHandle, uint32_t _pixelSize)
{
	AssertUnless(bgfx::isValid(_ttfHandle), "Invalid handle used");

	TrueTypeFont* ttf = new TrueTypeFont();
	if (!ttf->init(m_cachedFiles.get()[_ttfHandle.idx].buffer, m_cachedFiles.get()[_ttfHandle.idx].bufferSize, _pixelSize))
	{
		delete ttf;
		FontHandle invalid = BGFX_INVALID_HANDLE;
		return invalid;
	}

	uint16_t fontIdx = m_fontHandles.alloc();
	AssertUnless(fontIdx != bx::kInvalidHandle, "Invalid handle used");

	CachedFont& font = m_cachedFonts.get()[fontIdx];
	font.trueTypeFont = ttf;
	font.fontInfo = ttf->getFontInfo();
	font.fontInfo.pixelSize = uint16_t(_pixelSize);
	font.cachedGlyphs.clear();

	FontHandle handle = { fontIdx };
	return handle;
}

void FontManager::destroyFont(FontHandle _handle)
{
	AssertUnless(bgfx::isValid(_handle), "Invalid handle used");

	CachedFont& font = m_cachedFonts.get()[_handle.idx];

	if (font.trueTypeFont != NULL)
	{
		delete font.trueTypeFont;
		font.trueTypeFont = NULL;
	}

	font.cachedGlyphs.clear();
	m_fontHandles.free(_handle.idx);
}

bool FontManager::preloadGlyph(FontHandle _handle, CodePoint _codePoint)
{
	AssertUnless(bgfx::isValid(_handle), "Invalid handle used");
	CachedFont& font = m_cachedFonts.get()[_handle.idx];

	GlyphHashMap::iterator iter = font.cachedGlyphs.find(_codePoint);
	if (iter != font.cachedGlyphs.end() )
	{
		return true;
	}
	if (nullptr != font.trueTypeFont)
	{
		GlyphInfo glyphInfo;
		if (!font.trueTypeFont->bakeGlyphAlpha(_codePoint, glyphInfo, m_buffer.get()))
		{
			return false;
		}
		if (!addBitmap(glyphInfo, m_buffer.get()))
		{
			auto atlas = New<Atlas>(m_textureWidth, Atlas::Gray, true);
			m_currentAtlas = atlas.get();
			m_atlases.push_back(std::move(atlas));
			if (!addBitmap(glyphInfo, m_buffer.get()))
			{
				return false;
			}
		}
		font.cachedGlyphs[_codePoint] = glyphInfo;
		return true;
	}
	return false;
}

const FontInfo& FontManager::getFontInfo(FontHandle _handle) const
{
	AssertUnless(bgfx::isValid(_handle), "Invalid handle used");
	return m_cachedFonts.get()[_handle.idx].fontInfo;
}

const GlyphInfo* FontManager::getGlyphInfo(FontHandle _handle, CodePoint _codePoint)
{
	const GlyphHashMap& cachedGlyphs = m_cachedFonts.get()[_handle.idx].cachedGlyphs;
	GlyphHashMap::const_iterator it = cachedGlyphs.find(_codePoint);

	if (it == cachedGlyphs.end())
	{
		if (!preloadGlyph(_handle, _codePoint))
		{
			return &m_fallbackGlyph;
		}

		it = cachedGlyphs.find(_codePoint);
	}

	AssertUnless(it != cachedGlyphs.end(), "Failed to preload glyph.");
	return &it->second;
}

bool FontManager::addBitmap(GlyphInfo& _glyphInfo, const uint8_t* _data)
{
	uint16_t regionIndex = m_currentAtlas->addRegion((uint16_t)ceil(_glyphInfo.width), (uint16_t)ceil(_glyphInfo.height), _data);
	if (regionIndex == UINT16_MAX)
	{
		return false;
	}
	_glyphInfo.regionIndex = regionIndex;
	_glyphInfo.atlas = m_currentAtlas;
	return true;
}

float FontManager::getKerning(FontHandle _handle, CodePoint _codeLeft, CodePoint _codeRight)
{
	const CachedFont& font = m_cachedFonts.get()[_handle.idx];
	TrueTypeFont* trueTypeFont = font.trueTypeFont;
	const GlyphHashMap& cachedGlyphs = font.cachedGlyphs;
	GlyphHashMap::const_iterator left = cachedGlyphs.find(_codeLeft);
	GlyphHashMap::const_iterator right = cachedGlyphs.find(_codeRight);
	if (left != cachedGlyphs.end() && right != cachedGlyphs.end())
	{
		int32_t leftIndex= left->second.glyphIndex;
		int32_t rightIndex= right->second.glyphIndex;
		return stbtt_GetGlyphKernAdvance(&trueTypeFont->getSTBInfo(), leftIndex, rightIndex) * trueTypeFont->getFontInfo().scale;
	}
	return 0.0f;
}

} // namespace bgfx
