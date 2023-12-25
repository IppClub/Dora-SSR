/*
 * Copyright 2013 Jeremie Roy. All rights reserved.
 * License: https://github.com/bkaradzic/bgfx#license-bsd-2-clause
 */

#ifndef CUBE_ATLAS_H_HEADER_GUARD
#define CUBE_ATLAS_H_HEADER_GUARD

/// Inspired from texture-atlas from freetype-gl (http://code.google.com/p/freetype-gl/)
/// by Nicolas Rougier (Nicolas.Rougier@inria.fr)
/// The actual implementation is based on the article by Jukka Jylänki : "A
/// Thousand Ways to Pack the Bin - A Practical Approach to Two-Dimensional
/// Rectangle Bin Packing", February 27, 2010.
/// More precisely, this is an implementation of the Skyline Bottom-Left
/// algorithm based on C++ sources provided by Jukka Jylänki at:
/// http://clb.demon.fi/files/RectangleBinPack/

#include "bgfx/bgfx.h"

namespace Dora {
class Texture2D;
}

namespace bgfx {

struct AtlasRegion
{
	uint16_t x, y;
	uint16_t width, height;
};

class RectanglePacker;

class Atlas
{
public:
	enum Type {
		Gray,
		RGBA8
	};
	/// create an empty dynamic atlas (region can be updated and added)
	/// @param textureSize an atlas creates a texture cube of 6 faces with size equal to (textureSize*textureSize * sizeof(RGBA) )
	/// @param maxRegionCount maximum number of region allowed in the atlas
	Atlas(uint16_t _textureSize, Type type, bool antiAlias = true, uint16_t _maxRegionsCount = 4096);

	~Atlas();

	/// add a region to the atlas, and copy the content of mem to the underlying texture
	uint16_t addRegion(uint16_t _width, uint16_t _height, const uint8_t* _bitmapBuffer, uint16_t outline = 0);

	/// update a preallocated region
	void updateRegion(const AtlasRegion& _region, const uint8_t* _bitmapBuffer);

	/// return the TextureHandle (cube) of the atlas
	Dora::Texture2D* getTexture() const
	{
		return m_texture;
	}

	//retrieve a region info
	const AtlasRegion& getRegion(uint16_t _handle) const
	{
		return m_regions[_handle];
	}

	/// retrieve the size of side of a texture in pixels
	uint16_t getTextureSize() const
	{
		return m_textureSize;
	}

	/// retrieve the usage ratio of the atlas
	//float getUsageRatio() const { return 0.0f; }

	/// retrieve the numbers of region in the atlas
	uint16_t getRegionCount() const
	{
		return m_regionCount;
	}

	/// retrieve a pointer to the region buffer (in order to serialize it)
	const AtlasRegion* getRegionBuffer() const
	{
		return m_regions;
	}

	/// retrieve the byte size of the texture
	uint32_t getTextureBufferSize() const
	{
		uint32_t bytes = m_type == Gray ? 1 : 4;
		return m_textureSize * m_textureSize * bytes;
	}

	/// retrieve the mirrored texture buffer (to serialize it)
	const uint8_t* getTextureBuffer() const
	{
		return m_textureBuffer;
	}

private:
	void init();

	RectanglePacker* m_packer;
	Type m_type;

	AtlasRegion* m_regions;
	uint8_t* m_textureBuffer;

	Dora::Ref<Dora::Texture2D> m_texture;
	uint16_t m_textureSize;
	float m_texelSize;
	float m_texelOffset[2];

	uint16_t m_regionCount;
	uint16_t m_maxRegionCount;
};

} // namespace bgfx

#endif // CUBE_ATLAS_H_HEADER_GUARD
