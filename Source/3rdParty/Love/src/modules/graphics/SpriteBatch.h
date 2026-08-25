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

#include "common/Color.h"
#include "common/Matrix.h"
#include "Drawable.h"
#include "Mesh.h"
#include "Quad.h"
#include "Texture.h"
#include "vertex.h"

namespace love
{
namespace graphics
{

/**
 * Love's public SpriteBatch object contract. Storage and draw submission are
 * implemented by the embedding backend while the original Lua wrapper targets
 * this interface unchanged.
 */
class SpriteBatch : public Drawable
{
public:
	static love::Type type;

	~SpriteBatch() override = default;
	virtual int add(const Matrix4 &matrix, int index = -1) = 0;
	virtual int add(Quad *quad, const Matrix4 &matrix, int index = -1) = 0;
	virtual int addLayer(int layer, const Matrix4 &matrix, int index = -1) = 0;
	virtual int addLayer(int layer, Quad *quad, const Matrix4 &matrix, int index = -1) = 0;
	virtual void clear() = 0;
	virtual void flush() = 0;
	virtual void setTexture(Texture *texture) = 0;
	virtual Texture *getTexture() const = 0;
	virtual void setColor(const Colorf &color) = 0;
	virtual void setColor() = 0;
	virtual Colorf getColor(bool &active) const = 0;
	virtual int getCount() const = 0;
	virtual int getBufferSize() const = 0;
	virtual void attachAttribute(const std::string &name, Mesh *mesh) = 0;
	virtual void setDrawRange(int start, int count) = 0;
	virtual void setDrawRange() = 0;
	virtual bool getDrawRange(int &start, int &count) const = 0;
};

} // graphics
} // love
