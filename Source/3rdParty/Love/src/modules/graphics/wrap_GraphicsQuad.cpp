/** Copyright (c) 2006-2023 LOVE Development Team. */
#include "wrap_GraphicsQuad.h"

#include "common/Module.h"
#include "wrap_GraphicsInfo.h"
#include "wrap_Quad.h"
#include "wrap_Texture.h"

namespace love::graphics
{

int w_newQuad(lua_State *L)
{
	auto *module = luax_getmodule(L, Module::M_GRAPHICS);
	auto *info = dynamic_cast<GraphicsInfoCommand *>(module);
	if (!info || !info->isCreated())
		return luaL_error(L, "love.graphics cannot function without a window!");

	Quad::Viewport viewport;
	viewport.x = luaL_checknumber(L, 1);
	viewport.y = luaL_checknumber(L, 2);
	viewport.w = luaL_checknumber(L, 3);
	viewport.h = luaL_checknumber(L, 4);

	double textureWidth = 0.0;
	double textureHeight = 0.0;
	int layer = 0;
	if (luax_istype(L, 5, Texture::type))
	{
		auto *texture = luax_checktexture(L, 5);
		textureWidth = texture->getWidth();
		textureHeight = texture->getHeight();
	}
	else if (luax_istype(L, 6, Texture::type))
	{
		layer = static_cast<int>(luaL_checkinteger(L, 5)) - 1;
		auto *texture = luax_checktexture(L, 6);
		textureWidth = texture->getWidth();
		textureHeight = texture->getHeight();
	}
	else if (!lua_isnoneornil(L, 7))
	{
		layer = static_cast<int>(luaL_checkinteger(L, 5)) - 1;
		textureWidth = luaL_checknumber(L, 6);
		textureHeight = luaL_checknumber(L, 7);
	}
	else
	{
		textureWidth = luaL_checknumber(L, 5);
		textureHeight = luaL_checknumber(L, 6);
	}

	auto *quad = new Quad(viewport, textureWidth, textureHeight);
	quad->setLayer(layer);
	luax_pushtype(L, quad);
	quad->release();
	return 1;
}

}
