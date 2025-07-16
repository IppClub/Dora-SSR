/*
 * Copyright 2013 Jeremie Roy, modified by Li Jin 2022. All rights reserved.
 * License: https://github.com/bkaradzic/bgfx#license-bsd-2-clause
 */

#ifndef FONT_MANAGER_H_HEADER_GUARD
#define FONT_MANAGER_H_HEADER_GUARD

#include "bx/handlealloc.h"

namespace bgfx {

class Atlas;

#define MAX_OPENED_FILES 64
#define MAX_OPENED_FONT 64
#define MAX_FONT_BUFFER_SIZE 128
#define SDF_FONT_BUFFER_PADDING_RATIO 0.125
#define MAX_SDF_FONT_BUFFER_PADDING 16 // MAX_FONT_BUFFER_SIZE * SDF_FONT_BUFFER_PADDING_RATIO

struct FontInfo {
	/// The font height in pixel.
	uint16_t pixelSize;

	/// The pixel extents above the baseline in pixels (typically positive).
	float ascender;
	/// The extents below the baseline in pixels (typically negative).
	float descender;
	/// The spacing in pixels between one row's descent and the next row's ascent.
	float lineGap;

	/// Scale to apply to glyph data.
	float scale;

	/// Is SDF font.
	bool sdf = false;
};

// Glyph metrics:
// --------------
//
//                       xmin                     xmax
//                        |                         |
//                        |<-------- width -------->|
//                        |                         |
//              |         +-------------------------+----------------- ymax
//              |         |    ggggggggg   ggggg    |     ^        ^
//              |         |   g:::::::::ggg::::g    |     |        |
//              |         |  g:::::::::::::::::g    |     |        |
//              |         | g::::::ggggg::::::gg    |     |        |
//              |         | g:::::g     g:::::g     |     |        |
//    offset_x -|-------->| g:::::g     g:::::g     |  offset_y    |
//              |         | g:::::g     g:::::g     |     |        |
//              |         | g::::::g    g:::::g     |     |        |
//              |         | g:::::::ggggg:::::g     |     |        |
//              |         |  g::::::::::::::::g     |     |      height
//              |         |   gg::::::::::::::g     |     |        |
//  baseline ---*---------|---- gggggggg::::::g-----*--------      |
//            / |         |             g:::::g     |              |
//     origin   |         | gggggg      g:::::g     |              |
//              |         | g:::::gg   gg:::::g     |              |
//              |         |  g::::::ggg:::::::g     |              |
//              |         |   gg:::::::::::::g      |              |
//              |         |     ggg::::::ggg        |              |
//              |         |         gggggg          |              v
//              |         +-------------------------+----------------- ymin
//              |                                   |
//              |------------- advance_x ---------->|

/// Unicode value of a character
typedef int32_t CodePoint;

/// A structure that describe a glyph.
struct GlyphInfo {
	/// Index for faster retrieval.
	uint32_t glyphIndex;

	/// Glyph's width in pixels.
	float width;

	/// Glyph's height in pixels.
	float height;

	/// Glyph's left offset in pixels
	float offset_x;

	/// Glyph's top offset in pixels.
	///
	/// @remark This is the distance from the baseline to the top-most glyph
	///   scan line, upwards y coordinates being positive.
	float offset_y;

	/// For horizontal text layouts, this is the unscaled horizontal
	/// distance in pixels used to increment the pen position when the
	/// glyph is drawn as part of a string of text.
	float advance_x;

	/// Region index in the atlas storing textures.
	uint16_t regionIndex;

	/// Atlas contains this glyph
	Atlas* atlas;
};

BGFX_HANDLE(TrueTypeHandle);
BGFX_HANDLE(FontHandle);

class FontManager {
public:
	struct CachedFont;
	struct CachedFile {
		Dora::OwnArray<uint8_t> buffer;
		uint32_t bufferSize;
	};

	/// Create the font manager and create the texture cube as BGRA8 with
	/// linear filtering.
	FontManager(uint16_t _textureSideWidth);
	~FontManager();

	/// Load a TrueType font from a given buffer. The buffer is copied and
	/// thus can be freed or reused after this call.
	///
	/// @return invalid handle if the loading fail
	TrueTypeHandle createTtf(Dora::OwnArray<uint8_t>&& _buffer, uint32_t _size);

	/// Unload a TrueType font (free font memory) but keep loaded glyphs.
	void destroyTtf(TrueTypeHandle _handle);

	CachedFile* getCachedFile(TrueTypeHandle _handle) const;

	/// Return a font whose height is a fixed pixel size.
	FontHandle createFontByPixelSize(TrueTypeHandle _handle, uint32_t _pixelSize, bool _sdf);

	/// destroy a font (truetype or baked)
	void destroyFont(FontHandle _handle);

	/// Preload a single glyph, return true on success.
	bool preloadGlyph(FontHandle _handle, CodePoint _character);

	/// Return the font descriptor of a font.
	///
	/// @remark the handle is required to be valid
	const FontInfo& getFontInfo(FontHandle _handle) const;

	/// Return the rendering informations about the glyph region. Load the
	/// glyph from a TrueType font if possible
	///
	const GlyphInfo* getGlyphInfo(FontHandle _handle, CodePoint _codePoint);

	float getKerning(FontHandle _handle, CodePoint _codeLeft, CodePoint _codeRight);

protected:
	FontManager(const FontManager&) = delete;
	void operator=(const FontManager&) = delete;

private:

	void init();
	bool addBitmap(GlyphInfo& _glyphInfo, const uint8_t* _data);

	Atlas* m_currentAtlas;
	Dora::OwnVector<Atlas> m_atlases;

	uint16_t m_textureWidth;

	bx::HandleAllocT<MAX_OPENED_FONT> m_fontHandles;
	Dora::OwnArray<CachedFont> m_cachedFonts;

	bx::HandleAllocT<MAX_OPENED_FILES> m_filesHandles;
	Dora::OwnArray<CachedFile> m_cachedFiles;

	// temporary buffer to raster glyph
	Dora::OwnArray<uint8_t> m_buffer;

	GlyphInfo m_fallbackGlyph;
};

} // namespace bgfx

#endif // FONT_MANAGER_H_HEADER_GUARD
