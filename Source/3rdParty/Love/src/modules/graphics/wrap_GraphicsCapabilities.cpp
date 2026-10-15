/** Copyright (c) 2006-2023 LOVE Development Team. */
#include "wrap_GraphicsCapabilities.h"

#include "common/Module.h"

#include <limits>

namespace love::graphics
{

static GraphicsCapabilitiesCommand *capabilitiesCommand(lua_State *L)
{
	auto *module = luax_getmodule(L, Module::M_GRAPHICS);
	auto *command = dynamic_cast<GraphicsCapabilitiesCommand *>(module);
	if (!command)
		luaL_error(L, "love.graphics has no state-local capabilities command adapter");
	return command;
}

static int pushBoolFields(lua_State *L, const GraphicsCapabilitiesCommand::BoolFields &fields)
{
	if (lua_istable(L, 1)) lua_pushvalue(L, 1);
	else lua_createtable(L, 0, static_cast<int>(fields.size()));
	for (const auto &[name, value] : fields)
	{
		luax_pushboolean(L, value);
		lua_setfield(L, -2, name.c_str());
	}
	return 1;
}

int w_getSupported(lua_State *L)
{
	GraphicsCapabilitiesCommand::BoolFields fields;
	luax_catchexcept(L, [&](){ fields = capabilitiesCommand(L)->getSupported(); });
	return pushBoolFields(L, fields);
}

int w_getTextureTypes(lua_State *L)
{
	GraphicsCapabilitiesCommand::BoolFields fields;
	luax_catchexcept(L, [&](){ fields = capabilitiesCommand(L)->getTextureTypes(); });
	return pushBoolFields(L, fields);
}

int w_getImageFormats(lua_State *L)
{
	GraphicsCapabilitiesCommand::BoolFields fields;
	luax_catchexcept(L, [&](){ fields = capabilitiesCommand(L)->getImageFormats(); });
	return pushBoolFields(L, fields);
}

int w_getCanvasFormats(lua_State *L)
{
	bool readable = true;
	int tableIndex = 1;
	if (lua_type(L, 1) == LUA_TBOOLEAN)
	{
		readable = luax_checkboolean(L, 1);
		tableIndex = 2;
	}
	GraphicsCapabilitiesCommand::BoolFields fields;
	luax_catchexcept(L, [&](){ fields = capabilitiesCommand(L)->getCanvasFormats(readable); });
	if (lua_istable(L, tableIndex)) lua_pushvalue(L, tableIndex);
	else lua_createtable(L, 0, static_cast<int>(fields.size()));
	for (const auto &[name, value] : fields)
	{
		luax_pushboolean(L, value);
		lua_setfield(L, -2, name.c_str());
	}
	return 1;
}

int w_getTextureFormats(lua_State *L)
{
	luaL_checktype(L, 1, LUA_TTABLE);
	lua_getfield(L, 1, "canvas");
	const bool canvas = luax_checkboolean(L, -1);
	lua_pop(L, 1);

	lua_getfield(L, 1, "computewrite");
	const bool computeWrite = lua_isnoneornil(L, -1) ? false : luax_checkboolean(L, -1);
	lua_pop(L, 1);
	lua_getfield(L, 1, "shaderatomics");
	const bool shaderAtomics = lua_isnoneornil(L, -1) ? false : luax_checkboolean(L, -1);
	lua_pop(L, 1);
	lua_getfield(L, 1, "readable");
	const int readable = lua_isnoneornil(L, -1) ? -1 : (luax_checkboolean(L, -1) ? 1 : 0);
	lua_pop(L, 1);

	GraphicsCapabilitiesCommand::BoolFields fields;
	luax_catchexcept(L, [&]() {
		fields = capabilitiesCommand(L)->getTextureFormats(
			canvas, readable, computeWrite, shaderAtomics);
	});
	if (lua_istable(L, 2)) lua_pushvalue(L, 2);
	else lua_createtable(L, 0, static_cast<int>(fields.size()));
	for (const auto &[name, value] : fields)
	{
		luax_pushboolean(L, value);
		lua_setfield(L, -2, name.c_str());
	}
	return 1;
}

int w_getRendererInfo(lua_State *L)
{
	GraphicsCapabilitiesCommand::RendererInfo info;
	luax_catchexcept(L, [&](){ info = capabilitiesCommand(L)->getRendererInfo(); });
	for (const auto &value : info) luax_pushstring(L, value);
	return 4;
}

int w_getSystemLimits(lua_State *L)
{
	GraphicsCapabilitiesCommand::NumberFields fields;
	luax_catchexcept(L, [&](){ fields = capabilitiesCommand(L)->getSystemLimits(); });
	if (lua_istable(L, 1)) lua_pushvalue(L, 1);
	else lua_createtable(L, 0, static_cast<int>(fields.size()));
	for (const auto &[name, value] : fields)
	{
		lua_pushnumber(L, value);
		lua_setfield(L, -2, name.c_str());
	}
	return 1;
}

int w_getStats(lua_State *L)
{
	GraphicsCapabilitiesCommand::Stats fields;
	luax_catchexcept(L, [&](){ fields = capabilitiesCommand(L)->getStats(); });
	if (lua_istable(L, 1)) lua_pushvalue(L, 1);
	else lua_createtable(L, 0, static_cast<int>(fields.size()));
	for (const auto &[name, value] : fields)
	{
		const auto maximum = static_cast<std::uint64_t>(std::numeric_limits<lua_Integer>::max());
		lua_pushinteger(L, static_cast<lua_Integer>(value > maximum ? maximum : value));
		lua_setfield(L, -2, name.c_str());
	}
	return 1;
}

}
