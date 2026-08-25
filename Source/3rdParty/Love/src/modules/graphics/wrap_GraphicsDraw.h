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

#include "common/runtime.h"
#include "common/Module.h"
#include "Drawable.h"
#include "Mesh.h"
#include "Quad.h"
#include "Texture.h"

namespace love
{
namespace graphics
{

/**
 * State-local command boundary used by the original Graphics draw wrappers.
 * Native LOVE Graphics and Dora's embedded backend can provide different
 * implementations without changing Lua overload parsing.
 */
class GraphicsDrawCommand
{
public:
	virtual ~GraphicsDrawCommand() = default;
	virtual void draw(lua_State *L, Drawable *drawable, Texture *texture,
		Quad *quad, const Matrix4 &transform) = 0;
	virtual void drawLayer(lua_State *L, Texture *texture, int layer,
		Quad *quad, const Matrix4 &transform) = 0;
	virtual void drawInstanced(lua_State *L, Mesh *mesh, int instanceCount,
		const Matrix4 &transform) = 0;
};

int w_draw(lua_State *L);
int w_drawLayer(lua_State *L);
int w_drawInstanced(lua_State *L);

} // graphics
} // love
