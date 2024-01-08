/*
* Copyright 2013 Jeremie Roy. All rights reserved.
* License: https://github.com/bkaradzic/bgfx#license-bsd-2-clause
*/

#include "Const/Header.h"
#include "Cache/TextureCache.h"
using namespace Dora;

#include "bx/timer.h"
#include "bx/math.h"
#include "bgfx/bgfx.h"

#include <limits.h> // INT_MAX
#include <vector>

#include "Other/atlas.h"

namespace bgfx {

class RectanglePacker
{
public:
	RectanglePacker();
	RectanglePacker(uint32_t _width, uint32_t _height);

	/// non constructor initialization
	void init(uint32_t _width, uint32_t _height);

	/// find a suitable position for the given rectangle
	/// @return true if the rectangle can be added, false otherwise
	bool addRectangle(uint16_t _width, uint16_t _height, uint16_t& _outX, uint16_t& _outY);

	/// return the used surface in squared unit
	uint32_t getUsedSurface()
	{
		return m_usedSpace;
	}

	/// return the total available surface in squared unit
	uint32_t getTotalSurface()
	{
		return m_width * m_height;
	}

	/// return the usage ratio of the available surface [0:1]
	float getUsageRatio();

	/// reset to initial state
	void clear();

private:
	int32_t fit(uint32_t _skylineNodeIndex, uint16_t _width, uint16_t _height);

	/// Merges all skyline nodes that are at the same level.
	void merge();

	struct Node
	{
		Node(int16_t _x, int16_t _y, int16_t _width) : x(_x), y(_y), width(_width)
		{
		}

		int16_t x;     //< The starting x-coordinate (leftmost).
		int16_t y;     //< The y-coordinate of the skyline level line.
		int32_t width; //< The line _width. The ending coordinate (inclusive) will be x+width-1.
	};


	uint32_t m_width;            //< width (in pixels) of the underlying texture
	uint32_t m_height;           //< height (in pixels) of the underlying texture
	uint32_t m_usedSpace;        //< Surface used in squared pixel
	std::vector<Node> m_skyline; //< node of the skyline algorithm
};

RectanglePacker::RectanglePacker()
	: m_width(0)
	, m_height(0)
	, m_usedSpace(0)
{
}

RectanglePacker::RectanglePacker(uint32_t _width, uint32_t _height)
	: m_width(_width)
	, m_height(_height)
	, m_usedSpace(0)
{
	// We want a one pixel border around the whole atlas to avoid any artefact when
	// sampling texture
	m_skyline.push_back(Node(1, 1, uint16_t(_width - 2) ) );
}

void RectanglePacker::init(uint32_t _width, uint32_t _height)
{
	AssertUnless(_width > 2, "_width must be > 2");
	AssertUnless(_height > 2, "_height must be > 2");
	m_width = _width;
	m_height = _height;
	m_usedSpace = 0;

	m_skyline.clear();
	// We want a one pixel border around the whole atlas to avoid any artifact when
	// sampling texture
	m_skyline.push_back(Node(1, 1, uint16_t(_width - 2) ) );
}

bool RectanglePacker::addRectangle(uint16_t _width, uint16_t _height, uint16_t& _outX, uint16_t& _outY)
{
	int best_height, best_index;
	int32_t best_width;
	Node* node;
	Node* prev;
	_outX = 0;
	_outY = 0;

	best_height = INT_MAX;
	best_index = -1;
	best_width = INT_MAX;
	for (uint16_t ii = 0, num = uint16_t(m_skyline.size() ); ii < num; ++ii)
	{
		int32_t yy = fit(ii, _width, _height);
		if (yy >= 0)
		{
			node = &m_skyline[ii];
			if ( ( (yy + _height) < best_height)
			|| ( ( (yy + _height) == best_height) && (node->width < best_width) ) )
			{
				best_height = uint16_t(yy) + _height;
				best_index = ii;
				best_width = node->width;
				_outX = node->x;
				_outY = uint16_t(yy);
			}
		}
	}

	if (best_index == -1)
	{
		return false;
	}

	Node newNode(_outX, _outY + _height, _width);
	m_skyline.insert(m_skyline.begin() + best_index, newNode);

	for (uint16_t ii = uint16_t(best_index + 1), num = uint16_t(m_skyline.size() ); ii < num; ++ii)
	{
		node = &m_skyline[ii];
		prev = &m_skyline[ii - 1];
		if (node->x < (prev->x + prev->width) )
		{
			uint16_t shrink = uint16_t(prev->x + prev->width - node->x);
			node->x += shrink;
			node->width -= shrink;
			if (node->width <= 0)
			{
				m_skyline.erase(m_skyline.begin() + ii);
				--ii;
				--num;
			}
			else
			{
				break;
			}
		}
		else
		{
			break;
		}
	}

	merge();
	m_usedSpace += _width * _height;
	return true;
}

float RectanglePacker::getUsageRatio()
{
	uint32_t total = m_width * m_height;
	if (total > 0)
	{
		return (float)m_usedSpace / (float)total;
	}

	return 0.0f;
}

void RectanglePacker::clear()
{
	m_skyline.clear();
	m_usedSpace = 0;

	// We want a one pixel border around the whole atlas to avoid any artefact when
	// sampling texture
	m_skyline.push_back(Node(1, 1, uint16_t(m_width - 2) ) );
}

int32_t RectanglePacker::fit(uint32_t _skylineNodeIndex, uint16_t _width, uint16_t _height)
{
	int32_t width = _width;
	int32_t height = _height;

	const Node& baseNode = m_skyline[_skylineNodeIndex];

	int32_t xx = baseNode.x, yy;
	int32_t widthLeft = width;
	int32_t ii = _skylineNodeIndex;

	if ( (xx + width) > (int32_t)(m_width - 1) )
	{
		return -1;
	}

	yy = baseNode.y;
	while (widthLeft > 0)
	{
		const Node& node = m_skyline[ii];
		if (node.y > yy)
		{
			yy = node.y;
		}

		if ( (yy + height) > (int32_t)(m_height - 1) )
		{
			return -1;
		}

		widthLeft -= node.width;
		++ii;
	}

	return yy;
}

void RectanglePacker::merge()
{
	Node* node;
	Node* next;
	uint32_t ii;

	for (ii = 0; ii < m_skyline.size() - 1; ++ii)
	{
		node = (Node*) &m_skyline[ii];
		next = (Node*) &m_skyline[ii + 1];
		if (node->y == next->y)
		{
			node->width += next->width;
			m_skyline.erase(m_skyline.begin() + ii + 1);
			--ii;
		}
	}
}

Atlas::Atlas(uint16_t _textureSize, Type type, bool antiAlias, uint16_t _maxRegionsCount)
	: m_textureSize(_textureSize)
	, m_regionCount(0)
	, m_maxRegionCount(_maxRegionsCount)
	, m_type(type)
{
	AssertUnless(_textureSize >= 64 && _textureSize <= 4096, "Invalid _textureSize {}.", _textureSize);
	AssertUnless(_maxRegionsCount >= 64 && _maxRegionsCount <= 32000, "Invalid _maxRegionsCount {}.", _maxRegionsCount);

	init();

	m_packer = new RectanglePacker();
	m_packer->init(_textureSize, _textureSize);

	m_regions = new AtlasRegion[_maxRegionsCount];
	uint32_t bytes = m_type == Gray ? 1 : 4;
	m_textureBuffer = new uint8_t[ _textureSize * _textureSize * bytes ];
	bx::memSet(m_textureBuffer, 0, _textureSize * _textureSize * bytes);

	bgfx::TextureFormat::Enum format = m_type == Gray ? bgfx::TextureFormat::A8 : bgfx::TextureFormat::RGBA8;

	const uint32_t textureFlags = antiAlias ? (BGFX_SAMPLER_NONE) : (BGFX_SAMPLER_MIN_POINT | BGFX_SAMPLER_MAG_POINT);

	bgfx::TextureHandle textureHandle = bgfx::createTexture2D(_textureSize
		, _textureSize
		, false
		, 1
		, format
		, textureFlags
		);

	bgfx::TextureInfo info;
	bgfx::calcTextureSize(info
		, _textureSize
		, _textureSize
		,0
		, false
		, false
		, 1
		, format);

	m_texture = Texture2D::create(textureHandle, info, textureFlags);
}

Atlas::~Atlas()
{
	delete m_packer;
	delete [] m_regions;
	delete [] m_textureBuffer;
}

void Atlas::init()
{
	m_texelSize = float(UINT16_MAX) / float(m_textureSize);
	float texelHalf = m_texelSize / 2.0f;
	switch (bgfx::getRendererType() )
	{
	case bgfx::RendererType::Direct3D11:
	case bgfx::RendererType::Direct3D12:
		m_texelOffset[0] = texelHalf;
		m_texelOffset[1] = texelHalf;
		break;

	default:
		m_texelOffset[0] = texelHalf;
		m_texelOffset[1] = -texelHalf;
		break;
	}
}

uint16_t Atlas::addRegion(uint16_t _width, uint16_t _height, const uint8_t* _bitmapBuffer, uint16_t outline)
{
	if (m_regionCount >= m_maxRegionCount)
	{
		return UINT16_MAX;
	}

	uint16_t xx = 0;
	uint16_t yy = 0;
	if (!m_packer->addRectangle(_width + 1, _height + 1, xx, yy))
	{
		return UINT16_MAX;
	}

	AtlasRegion& region = m_regions[m_regionCount];
	region.x = xx;
	region.y = yy;
	region.width = _width;
	region.height = _height;
	updateRegion(region, _bitmapBuffer);

	region.x += outline;
	region.y += outline;
	region.width -= (outline * 2);
	region.height -= (outline * 2);

	return m_regionCount++;
}

void Atlas::updateRegion(const AtlasRegion& _region, const uint8_t* _bitmapBuffer)
{
	uint32_t bytes = m_type == Gray ? 1 : 4;
	uint32_t targetSize = _region.width * _region.height * bytes;
	if (0 < targetSize)
	{
		const bgfx::Memory* mem = bgfx::alloc(targetSize);
		bx::memCopy(mem->data, _bitmapBuffer, mem->size);
		bgfx::updateTexture2D(m_texture->getHandle(), 0, 0, _region.x, _region.y, _region.width, _region.height, mem);
	}
}

} // namespace bgfx
