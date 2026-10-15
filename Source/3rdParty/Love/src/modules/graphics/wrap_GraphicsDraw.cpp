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

#include "wrap_GraphicsDraw.h"
#include "wrap_GraphicsTransform.h"
#include "wrap_Mesh.h"
#include "wrap_Quad.h"
#include "wrap_Texture.h"

namespace love
{
namespace graphics
{

static GraphicsDrawCommand *drawCommand(lua_State *L)
{
	auto *module = luax_getmodule(L, Module::M_GRAPHICS);
	auto *command = dynamic_cast<GraphicsDrawCommand *>(module);
	if (command == nullptr)
		luaL_error(L, "love.graphics has no state-local draw command adapter");
	return command;
}

int w_draw(lua_State *L)
{
	Drawable *drawable = nullptr;
	Texture *texture = nullptr;
	Quad *quad = nullptr;
	int startidx = 2;

	if (luax_istype(L, 2, Quad::type))
	{
		texture = luax_checktexture(L, 1);
		quad = luax_totype<Quad>(L, 2);
		startidx = 3;
	}
	else if (lua_isnil(L, 2) && !lua_isnoneornil(L, 3))
	{
		return luax_typerror(L, 2, "Quad");
	}
	else
	{
		drawable = luax_checktype<Drawable>(L, 1);
		startidx = 2;
	}

	luax_checkstandardtransform(L, startidx, [&](const Matrix4 &m)
	{
		luax_catchexcept(L, [&]()
		{
			drawCommand(L)->draw(L, drawable, texture, quad, m);
		});
	});

	return 0;
}

int w_drawLayer(lua_State *L)
{
	Texture *texture = luax_checktexture(L, 1);
	Quad *quad = nullptr;
	int layer = (int) luaL_checkinteger(L, 2) - 1;
	int startidx = 3;

	if (luax_istype(L, startidx, Quad::type))
	{
		texture = luax_checktexture(L, 1);
		quad = luax_totype<Quad>(L, startidx);
		startidx++;
	}
	else if (lua_isnil(L, startidx) && !lua_isnoneornil(L, startidx + 1))
	{
		return luax_typerror(L, startidx, "Quad");
	}

	luax_checkstandardtransform(L, startidx, [&](const Matrix4 &m)
	{
		luax_catchexcept(L, [&]()
		{
			drawCommand(L)->drawLayer(L, texture, layer, quad, m);
		});
	});

	return 0;
}

int w_drawInstanced(lua_State *L)
{
	Mesh *mesh = luax_checkmesh(L, 1);
	const int instanceCount = static_cast<int>(luaL_checkinteger(L, 2));
	luax_checkstandardtransform(L, 3, [&](const Matrix4 &m)
	{
		luax_catchexcept(L, [&]()
		{
			drawCommand(L)->drawInstanced(L, mesh, instanceCount, m);
		});
	});
	return 0;
}

} // graphics
} // love
