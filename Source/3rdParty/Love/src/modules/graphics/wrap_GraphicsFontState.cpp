/** Copyright (c) 2006-2023 LOVE Development Team. */
#include "wrap_GraphicsFontState.h"

#include "common/Module.h"
#include "wrap_Font.h"

namespace love::graphics
{

static GraphicsFontStateCommand *fontStateCommand(lua_State *L)
{
	auto *module = luax_getmodule(L, Module::M_GRAPHICS);
	auto *command = dynamic_cast<GraphicsFontStateCommand *>(module);
	if (!command) luaL_error(L, "love.graphics has no state-local Font state adapter");
	return command;
}

int w_setFont(lua_State *L)
{
	auto *font = luax_checkfont(L, 1);
	luax_catchexcept(L, [&](){ fontStateCommand(L)->setFont(font); });
	return 0;
}

int w_getFont(lua_State *L)
{
	Font *font = nullptr;
	luax_catchexcept(L, [&](){ font = fontStateCommand(L)->getFont(); });
	luax_pushtype(L, font);
	return 1;
}

}
