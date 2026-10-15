/**
 * Copyright (c) 2006-2023 LOVE Development Team
 *
 * This software is provided 'as-is', without any express or implied
 * warranty.  In no event will the authors be held liable for any damages
 * arising from the use of this software.
 *
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 * 1. The origin of this software must not be misrepresented; you must not
 *    claim that you wrote the original software. If you use this software
 *    in a product, an acknowledgment in the product documentation would be
 *    appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 *    misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 **/

#pragma once

#include "common/int.h"
#include "Drawable.h"
#include "Texture.h"
#include "vertex.h"

#include <string>
#include <vector>

namespace love
{
namespace graphics
{

/**
 * Love's public Mesh object contract with storage and rendering supplied by
 * the embedding backend. The original Lua wrapper targets this interface;
 * Dora owns the CPU/GPU buffers and draw submission for each Lua state.
 */
class Mesh : public Drawable
{
public:
	static love::Type type;

	struct AttribFormat
	{
		std::string name;
		vertex::DataType type;
		int components;
	};

	~Mesh() override = default;
	virtual void setVertex(size_t vertindex, const void *data, size_t datasize) = 0;
	virtual size_t getVertex(size_t vertindex, void *data, size_t datasize) = 0;
	virtual void *getVertexScratchBuffer() = 0;
	virtual void setVertexAttribute(size_t vertindex, int attribindex,
		const void *data, size_t datasize) = 0;
	virtual size_t getVertexAttribute(size_t vertindex, int attribindex,
		void *data, size_t datasize) = 0;
	virtual size_t getVertexCount() const = 0;
	virtual size_t getVertexStride() const = 0;
	virtual const std::vector<AttribFormat> &getVertexFormat() const = 0;
	virtual vertex::DataType getAttributeInfo(int attribindex, int &components) const = 0;
	virtual int getAttributeIndex(const std::string &name) const = 0;
	virtual void setAttributeEnabled(const std::string &name, bool enable) = 0;
	virtual bool isAttributeEnabled(const std::string &name) const = 0;
	virtual void attachAttribute(const std::string &name, Mesh *mesh,
		const std::string &attachname, AttributeStep step = STEP_PER_VERTEX) = 0;
	virtual bool detachAttribute(const std::string &name) = 0;
	virtual void *mapVertexData() = 0;
	virtual void unmapVertexData(size_t modifiedoffset = 0, size_t modifiedsize = size_t(-1)) = 0;
	virtual void flush() = 0;
	virtual void setVertexMap(const std::vector<uint32> &map) = 0;
	virtual void setVertexMap(IndexDataType datatype, const void *data, size_t datasize) = 0;
	virtual void setVertexMap() = 0;
	virtual bool getVertexMap(std::vector<uint32> &map) const = 0;
	virtual size_t getVertexMapCount() const = 0;
	virtual void setTexture(Texture *texture) = 0;
	virtual void setTexture() = 0;
	virtual Texture *getTexture() const = 0;
	virtual void setDrawMode(PrimitiveType mode) = 0;
	virtual PrimitiveType getDrawMode() const = 0;
	virtual void setDrawRange(int start, int count) = 0;
	virtual void setDrawRange() = 0;
	virtual bool getDrawRange(int &start, int &count) const = 0;

	static std::vector<AttribFormat> getDefaultVertexFormat();
};

} // graphics
} // love
