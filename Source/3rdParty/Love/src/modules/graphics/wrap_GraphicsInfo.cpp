/**
 * Copyright (c) 2006-2023 LOVE Development Team
 *
 * This software is provided 'as-is', without any express or implied warranty.
 */
#include "wrap_GraphicsInfo.h"

#include "common/Module.h"

namespace love::graphics
{

static GraphicsInfoCommand *infoCommand(lua_State *L)
{
	auto *module = luax_getmodule(L, Module::M_GRAPHICS);
	auto *command = dynamic_cast<GraphicsInfoCommand *>(module);
	if (!command)
		luaL_error(L, "love.graphics has no state-local info command adapter");
	return command;
}

int w_getWidth(lua_State *L) { lua_pushinteger(L, infoCommand(L)->getWidth()); return 1; }
int w_getHeight(lua_State *L) { lua_pushinteger(L, infoCommand(L)->getHeight()); return 1; }
int w_getDimensions(lua_State *L)
{
	auto *command = infoCommand(L);
	lua_pushinteger(L, command->getWidth());
	lua_pushinteger(L, command->getHeight());
	return 2;
}
int w_getPixelWidth(lua_State *L) { lua_pushinteger(L, infoCommand(L)->getPixelWidth()); return 1; }
int w_getPixelHeight(lua_State *L) { lua_pushinteger(L, infoCommand(L)->getPixelHeight()); return 1; }
int w_getPixelDimensions(lua_State *L)
{
	auto *command = infoCommand(L);
	lua_pushinteger(L, command->getPixelWidth());
	lua_pushinteger(L, command->getPixelHeight());
	return 2;
}
int w_getDPIScale(lua_State *L) { lua_pushnumber(L, infoCommand(L)->getDPIScale()); return 1; }
int w_isActive(lua_State *L) { luax_pushboolean(L, infoCommand(L)->isActive()); return 1; }
int w_isCreated(lua_State *L) { luax_pushboolean(L, infoCommand(L)->isCreated()); return 1; }
int w_isGammaCorrect(lua_State *L) { luax_pushboolean(L, infoCommand(L)->isGammaCorrect()); return 1; }

}
