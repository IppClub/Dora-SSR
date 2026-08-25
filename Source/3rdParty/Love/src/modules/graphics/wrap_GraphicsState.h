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

#include "common/Vector.h"
#include "common/runtime.h"

namespace love
{
namespace math
{
class Transform;
}
namespace graphics
{

class GraphicsStateCommand
{
public:
	enum StackType
	{
		STACK_TRANSFORM,
		STACK_ALL,
	};
	virtual ~GraphicsStateCommand() = default;
	virtual void reset(lua_State *L) = 0;
	virtual void present(lua_State *L) = 0;
	virtual void flushBatch() = 0;
	virtual size_t getStackDepth() const = 0;
	virtual void push(lua_State *L, StackType type) = 0;
	virtual void pop(lua_State *L) = 0;
	virtual void rotate(float angle) = 0;
	virtual void scale(float x, float y) = 0;
	virtual void translate(float x, float y) = 0;
	virtual void shear(float x, float y) = 0;
	virtual void origin() = 0;
	virtual void applyTransform(math::Transform *transform) = 0;
	virtual void replaceTransform(math::Transform *transform) = 0;
	virtual Vector2 transformPoint(Vector2 point) const = 0;
	virtual Vector2 inverseTransformPoint(Vector2 point) const = 0;
};

int w_reset(lua_State *L);
int w_present(lua_State *L);
int w_flushBatch(lua_State *L);
int w_getStackDepth(lua_State *L);
int w_push(lua_State *L);
int w_pop(lua_State *L);
int w_rotate(lua_State *L);
int w_scale(lua_State *L);
int w_translate(lua_State *L);
int w_shear(lua_State *L);
int w_origin(lua_State *L);
int w_applyTransform(lua_State *L);
int w_replaceTransform(lua_State *L);
int w_transformPoint(lua_State *L);
int w_inverseTransformPoint(lua_State *L);

} // graphics
} // love
