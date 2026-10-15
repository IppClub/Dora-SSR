/** Copyright (c) 2006-2023 LOVE Development Team. */
#include "wrap_GraphicsShaderState.h"

#include "common/Module.h"
#include "wrap_Shader.h"

namespace love::graphics
{

static GraphicsShaderStateCommand *shaderStateCommand(lua_State *L)
{
	auto *module = luax_getmodule(L, Module::M_GRAPHICS);
	auto *command = dynamic_cast<GraphicsShaderStateCommand *>(module);
	if (!command) luaL_error(L, "love.graphics has no state-local Shader state adapter");
	return command;
}

int w_setShader(lua_State *L)
{
	Shader *shader = lua_isnoneornil(L, 1) ? nullptr : luax_checkshader(L, 1);
	luax_catchexcept(L, [&](){ shaderStateCommand(L)->setShader(shader); });
	return 0;
}

int w_getShader(lua_State *L)
{
	auto *shader = shaderStateCommand(L)->getShader();
	if (shader) luax_pushtype(L, shader);
	else lua_pushnil(L);
	return 1;
}

}
