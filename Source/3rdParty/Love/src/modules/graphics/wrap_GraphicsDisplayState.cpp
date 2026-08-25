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

#include "wrap_GraphicsDisplayState.h"

#include "common/Module.h"

#include <cmath>
#include <cstring>
#include <string>
#include <vector>

namespace love
{
namespace graphics
{

static GraphicsDisplayStateCommand *displayStateCommand(lua_State *L)
{
	auto *module = luax_getmodule(L, Module::M_GRAPHICS);
	auto *command = dynamic_cast<GraphicsDisplayStateCommand *>(module);
	if (command == nullptr)
		luaL_error(L, "love.graphics has no state-local display state command adapter");
	return command;
}

static Colorf checkColor(lua_State *L)
{
	Colorf c;
	if (lua_istable(L, 1))
	{
		for (int i = 1; i <= 4; i++)
			lua_rawgeti(L, 1, i);
		c.r = (float) luaL_checknumber(L, -4);
		c.g = (float) luaL_checknumber(L, -3);
		c.b = (float) luaL_checknumber(L, -2);
		c.a = (float) luaL_optnumber(L, -1, 1.0);
		lua_pop(L, 4);
	}
	else
	{
		c.r = (float) luaL_checknumber(L, 1);
		c.g = (float) luaL_checknumber(L, 2);
		c.b = (float) luaL_checknumber(L, 3);
		c.a = (float) luaL_optnumber(L, 4, 1.0);
	}
	return c;
}

static int pushColor(lua_State *L, Colorf c)
{
	lua_pushnumber(L, c.r);
	lua_pushnumber(L, c.g);
	lua_pushnumber(L, c.b);
	lua_pushnumber(L, c.a);
	return 4;
}

int w_setColor(lua_State *L)
{
	displayStateCommand(L)->setColor(checkColor(L));
	return 0;
}

int w_getColor(lua_State *L)
{
	return pushColor(L, displayStateCommand(L)->getColor());
}

int w_setBackgroundColor(lua_State *L)
{
	displayStateCommand(L)->setBackgroundColor(checkColor(L));
	return 0;
}

int w_getBackgroundColor(lua_State *L)
{
	return pushColor(L, displayStateCommand(L)->getBackgroundColor());
}

int w_setLineWidth(lua_State *L)
{
	displayStateCommand(L)->setLineWidth((float) luaL_checknumber(L, 1));
	return 0;
}

int w_setLineStyle(lua_State *L)
{
	const char *str = luaL_checkstring(L, 1);
	GraphicsDisplayStateCommand::LineStyle style;
	if (strcmp(str, "rough") == 0)
		style = GraphicsDisplayStateCommand::LINE_ROUGH;
	else if (strcmp(str, "smooth") == 0)
		style = GraphicsDisplayStateCommand::LINE_SMOOTH;
	else
		return luax_enumerror(L, "line style", std::vector<std::string>{"rough", "smooth"}, str);
	displayStateCommand(L)->setLineStyle(style);
	return 0;
}

int w_setLineJoin(lua_State *L)
{
	const char *str = luaL_checkstring(L, 1);
	GraphicsDisplayStateCommand::LineJoin join;
	if (strcmp(str, "none") == 0)
		join = GraphicsDisplayStateCommand::LINE_JOIN_NONE;
	else if (strcmp(str, "miter") == 0)
		join = GraphicsDisplayStateCommand::LINE_JOIN_MITER;
	else if (strcmp(str, "bevel") == 0)
		join = GraphicsDisplayStateCommand::LINE_JOIN_BEVEL;
	else
		return luax_enumerror(L, "line join", std::vector<std::string>{"none", "miter", "bevel"}, str);
	displayStateCommand(L)->setLineJoin(join);
	return 0;
}

int w_getLineWidth(lua_State *L)
{
	lua_pushnumber(L, displayStateCommand(L)->getLineWidth());
	return 1;
}

int w_getLineStyle(lua_State *L)
{
	const char *str = displayStateCommand(L)->getLineStyle()
		== GraphicsDisplayStateCommand::LINE_ROUGH ? "rough" : "smooth";
	lua_pushstring(L, str);
	return 1;
}

int w_getLineJoin(lua_State *L)
{
	const char *str = nullptr;
	switch (displayStateCommand(L)->getLineJoin())
	{
	case GraphicsDisplayStateCommand::LINE_JOIN_NONE: str = "none"; break;
	case GraphicsDisplayStateCommand::LINE_JOIN_MITER: str = "miter"; break;
	case GraphicsDisplayStateCommand::LINE_JOIN_BEVEL: str = "bevel"; break;
	}
	lua_pushstring(L, str);
	return 1;
}

int w_setPointSize(lua_State *L)
{
	const float size = (float) luaL_checknumber(L, 1);
	luaL_argcheck(L, std::isfinite(size) && size > 0.0f, 1,
		"point size must be a finite number greater than zero");
	displayStateCommand(L)->setPointSize(size);
	return 0;
}

int w_getPointSize(lua_State *L)
{
	lua_pushnumber(L, displayStateCommand(L)->getPointSize());
	return 1;
}

int w_setColorMask(lua_State *L)
{
	GraphicsDisplayStateCommand::ColorMask mask;
	if (lua_gettop(L) <= 1 && lua_isnoneornil(L, 1))
		mask.r = mask.g = mask.b = mask.a = true;
	else
	{
		mask.r = luax_checkboolean(L, 1);
		mask.g = luax_checkboolean(L, 2);
		mask.b = luax_checkboolean(L, 3);
		mask.a = luax_checkboolean(L, 4);
	}
	displayStateCommand(L)->setColorMask(mask);
	return 0;
}

int w_getColorMask(lua_State *L)
{
	auto mask = displayStateCommand(L)->getColorMask();
	luax_pushboolean(L, mask.r);
	luax_pushboolean(L, mask.g);
	luax_pushboolean(L, mask.b);
	luax_pushboolean(L, mask.a);
	return 4;
}

int w_setWireframe(lua_State *L)
{
	displayStateCommand(L)->setWireframe(luax_checkboolean(L, 1));
	return 0;
}

int w_isWireframe(lua_State *L)
{
	luax_pushboolean(L, displayStateCommand(L)->isWireframe());
	return 1;
}

int w_setScissor(lua_State *L)
{
	const int nargs = lua_gettop(L);
	if (nargs == 0 || (nargs == 4 && lua_isnil(L, 1) && lua_isnil(L, 2)
		&& lua_isnil(L, 3) && lua_isnil(L, 4)))
	{
		displayStateCommand(L)->setScissor();
		return 0;
	}
	Rect rect;
	rect.x = (int) luaL_checkinteger(L, 1);
	rect.y = (int) luaL_checkinteger(L, 2);
	rect.w = (int) luaL_checkinteger(L, 3);
	rect.h = (int) luaL_checkinteger(L, 4);
	if (rect.w < 0 || rect.h < 0)
		return luaL_error(L, "Can't set scissor with negative width and/or height.");
	displayStateCommand(L)->setScissor(rect);
	return 0;
}

int w_intersectScissor(lua_State *L)
{
	Rect rect;
	rect.x = (int) luaL_checkinteger(L, 1);
	rect.y = (int) luaL_checkinteger(L, 2);
	rect.w = (int) luaL_checkinteger(L, 3);
	rect.h = (int) luaL_checkinteger(L, 4);
	if (rect.w < 0 || rect.h < 0)
		return luaL_error(L, "Can't set scissor with negative width and/or height.");
	displayStateCommand(L)->intersectScissor(rect);
	return 0;
}

int w_getScissor(lua_State *L)
{
	Rect rect;
	if (!displayStateCommand(L)->getScissor(rect))
		return 0;
	lua_pushinteger(L, rect.x);
	lua_pushinteger(L, rect.y);
	lua_pushinteger(L, rect.w);
	lua_pushinteger(L, rect.h);
	return 4;
}

static bool getFilterConstant(const char *name, GraphicsDisplayStateCommand::FilterMode &mode)
{
	if (strcmp(name, "linear") == 0)
		mode = GraphicsDisplayStateCommand::FILTER_LINEAR;
	else if (strcmp(name, "nearest") == 0)
		mode = GraphicsDisplayStateCommand::FILTER_NEAREST;
	else
		return false;
	return true;
}

static const char *getFilterConstant(GraphicsDisplayStateCommand::FilterMode mode)
{
	switch (mode)
	{
	case GraphicsDisplayStateCommand::FILTER_LINEAR: return "linear";
	case GraphicsDisplayStateCommand::FILTER_NEAREST: return "nearest";
	case GraphicsDisplayStateCommand::FILTER_NONE: return nullptr;
	}
	return nullptr;
}

int w_setDefaultFilter(lua_State *L)
{
	GraphicsDisplayStateCommand::Filter filter;
	const char *minstr = luaL_checkstring(L, 1);
	const char *magstr = luaL_optstring(L, 2, minstr);
	if (!getFilterConstant(minstr, filter.min))
		return luax_enumerror(L, "filter mode", std::vector<std::string>{"linear", "nearest"}, minstr);
	if (!getFilterConstant(magstr, filter.mag))
		return luax_enumerror(L, "filter mode", std::vector<std::string>{"linear", "nearest"}, magstr);
	filter.anisotropy = (float) luaL_optnumber(L, 3, 1.0);
	std::string error;
	if (!displayStateCommand(L)->setDefaultFilter(filter, error))
		return luaL_error(L, "%s", error.c_str());
	return 0;
}

int w_getDefaultFilter(lua_State *L)
{
	auto filter = displayStateCommand(L)->getDefaultFilter();
	const char *minstr = getFilterConstant(filter.min);
	const char *magstr = getFilterConstant(filter.mag);
	if (minstr == nullptr)
		return luaL_error(L, "Unknown minification filter mode");
	if (magstr == nullptr)
		return luaL_error(L, "Unknown magnification filter mode");
	lua_pushstring(L, minstr);
	lua_pushstring(L, magstr);
	lua_pushnumber(L, filter.anisotropy);
	return 3;
}

int w_setDefaultMipmapFilter(lua_State *L)
{
	auto filter = GraphicsDisplayStateCommand::FILTER_NONE;
	if (!lua_isnoneornil(L, 1))
	{
		const char *str = luaL_checkstring(L, 1);
		if (!getFilterConstant(str, filter))
			return luax_enumerror(L, "filter mode", std::vector<std::string>{"linear", "nearest"}, str);
	}
	const float sharpness = (float) luaL_optnumber(L, 2, 0.0);
	std::string error;
	if (!displayStateCommand(L)->setDefaultMipmapFilter(filter, sharpness, error))
		return luaL_error(L, "%s", error.c_str());
	return 0;
}

int w_getDefaultMipmapFilter(lua_State *L)
{
	GraphicsDisplayStateCommand::FilterMode filter;
	float sharpness;
	displayStateCommand(L)->getDefaultMipmapFilter(filter, sharpness);
	const char *str = getFilterConstant(filter);
	if (str != nullptr)
		lua_pushstring(L, str);
	else
		lua_pushnil(L);
	lua_pushnumber(L, sharpness);
	return 2;
}

static bool getBlendModeConstant(const char *name, GraphicsDisplayStateCommand::BlendMode &mode)
{
	static constexpr const char *names[] = {"alpha", "add", "subtract", "multiply",
		"lighten", "darken", "screen", "replace", "none"};
	for (int index = 0; index < 9; ++index)
		if (strcmp(name, names[index]) == 0)
		{
			mode = (GraphicsDisplayStateCommand::BlendMode) index;
			return true;
		}
	return false;
}

static const char *getBlendModeConstant(GraphicsDisplayStateCommand::BlendMode mode)
{
	static constexpr const char *names[] = {"alpha", "add", "subtract", "multiply",
		"lighten", "darken", "screen", "replace", "none"};
	return mode >= GraphicsDisplayStateCommand::BLEND_ALPHA
		&& mode <= GraphicsDisplayStateCommand::BLEND_NONE ? names[(int) mode] : nullptr;
}

static bool getBlendAlphaConstant(const char *name, GraphicsDisplayStateCommand::BlendAlpha &mode)
{
	if (strcmp(name, "alphamultiply") == 0)
		mode = GraphicsDisplayStateCommand::BLENDALPHA_MULTIPLY;
	else if (strcmp(name, "premultiplied") == 0)
		mode = GraphicsDisplayStateCommand::BLENDALPHA_PREMULTIPLIED;
	else
		return false;
	return true;
}

static const char *getBlendAlphaConstant(GraphicsDisplayStateCommand::BlendAlpha mode)
{
	return mode == GraphicsDisplayStateCommand::BLENDALPHA_MULTIPLY
		? "alphamultiply" : mode == GraphicsDisplayStateCommand::BLENDALPHA_PREMULTIPLIED
		? "premultiplied" : nullptr;
}

int w_setBlendMode(lua_State *L)
{
	GraphicsDisplayStateCommand::BlendMode mode;
	const char *str = luaL_checkstring(L, 1);
	if (!getBlendModeConstant(str, mode))
		return luax_enumerror(L, "blend mode", std::vector<std::string>{"alpha", "add",
			"subtract", "multiply", "lighten", "darken", "screen", "replace", "none"}, str);
	auto alphaMode = GraphicsDisplayStateCommand::BLENDALPHA_MULTIPLY;
	if (!lua_isnoneornil(L, 2))
	{
		const char *alpha = luaL_checkstring(L, 2);
		if (!getBlendAlphaConstant(alpha, alphaMode))
			return luax_enumerror(L, "blend alpha mode",
				std::vector<std::string>{"alphamultiply", "premultiplied"}, alpha);
	}
	std::string error;
	if (!displayStateCommand(L)->setBlendMode(mode, alphaMode, error))
		return luaL_error(L, "%s", error.c_str());
	return 0;
}

int w_getBlendMode(lua_State *L)
{
	GraphicsDisplayStateCommand::BlendAlpha alphaMode;
	auto mode = displayStateCommand(L)->getBlendMode(alphaMode);
	const char *str = getBlendModeConstant(mode);
	const char *alpha = getBlendAlphaConstant(alphaMode);
	if (str == nullptr)
		return luaL_error(L, "Unknown blend mode");
	if (alpha == nullptr)
		return luaL_error(L, "Unknown blend alpha mode");
	lua_pushstring(L, str);
	lua_pushstring(L, alpha);
	return 2;
}

static bool getCompareConstant(const char *name, GraphicsDisplayStateCommand::CompareMode &mode)
{
	static constexpr const char *names[] = {"less", "lequal", "equal", "gequal",
		"greater", "notequal", "always", "never"};
	for (int index = 0; index < 8; ++index)
		if (strcmp(name, names[index]) == 0)
		{
			mode = (GraphicsDisplayStateCommand::CompareMode) index;
			return true;
		}
	return false;
}

static const char *getCompareConstant(GraphicsDisplayStateCommand::CompareMode mode)
{
	static constexpr const char *names[] = {"less", "lequal", "equal", "gequal",
		"greater", "notequal", "always", "never"};
	return mode >= GraphicsDisplayStateCommand::COMPARE_LESS
		&& mode <= GraphicsDisplayStateCommand::COMPARE_NEVER ? names[(int) mode] : nullptr;
}

int w_setDepthMode(lua_State *L)
{
	auto compare = GraphicsDisplayStateCommand::COMPARE_ALWAYS;
	bool write = false;
	if (!(lua_isnoneornil(L, 1) && lua_isnoneornil(L, 2)))
	{
		const char *str = luaL_checkstring(L, 1);
		write = luax_checkboolean(L, 2);
		if (!getCompareConstant(str, compare))
			return luax_enumerror(L, "compare mode", std::vector<std::string>{"less", "lequal",
				"equal", "gequal", "greater", "notequal", "always", "never"}, str);
	}
	displayStateCommand(L)->setDepthMode(compare, write);
	return 0;
}

int w_getDepthMode(lua_State *L)
{
	bool write;
	const char *str = getCompareConstant(displayStateCommand(L)->getDepthMode(write));
	if (str == nullptr)
		return luaL_error(L, "Unknown compare mode");
	lua_pushstring(L, str);
	luax_pushboolean(L, write);
	return 2;
}

int w_setMeshCullMode(lua_State *L)
{
	const char *str = luaL_checkstring(L, 1);
	GraphicsDisplayStateCommand::CullMode mode;
	if (strcmp(str, "none") == 0) mode = GraphicsDisplayStateCommand::CULL_NONE;
	else if (strcmp(str, "back") == 0) mode = GraphicsDisplayStateCommand::CULL_BACK;
	else if (strcmp(str, "front") == 0) mode = GraphicsDisplayStateCommand::CULL_FRONT;
	else return luax_enumerror(L, "cull mode",
		std::vector<std::string>{"none", "back", "front"}, str);
	displayStateCommand(L)->setMeshCullMode(mode);
	return 0;
}

int w_getMeshCullMode(lua_State *L)
{
	static constexpr const char *names[] = {"none", "back", "front"};
	lua_pushstring(L, names[(int) displayStateCommand(L)->getMeshCullMode()]);
	return 1;
}

int w_setFrontFaceWinding(lua_State *L)
{
	const char *str = luaL_checkstring(L, 1);
	GraphicsDisplayStateCommand::Winding winding;
	if (strcmp(str, "cw") == 0) winding = GraphicsDisplayStateCommand::WINDING_CW;
	else if (strcmp(str, "ccw") == 0) winding = GraphicsDisplayStateCommand::WINDING_CCW;
	else return luax_enumerror(L, "vertex winding", std::vector<std::string>{"cw", "ccw"}, str);
	displayStateCommand(L)->setFrontFaceWinding(winding);
	return 0;
}

int w_getFrontFaceWinding(lua_State *L)
{
	lua_pushstring(L, displayStateCommand(L)->getFrontFaceWinding()
		== GraphicsDisplayStateCommand::WINDING_CW ? "cw" : "ccw");
	return 1;
}

int w_setStencilTest(lua_State *L)
{
	auto compare = GraphicsDisplayStateCommand::COMPARE_ALWAYS;
	int value = 0;
	if (!lua_isnoneornil(L, 1))
	{
		const char *str = luaL_checkstring(L, 1);
		if (!getCompareConstant(str, compare))
			return luax_enumerror(L, "compare mode", std::vector<std::string>{"less", "lequal",
				"equal", "gequal", "greater", "notequal", "always", "never"}, str);
		value = (int) luaL_checkinteger(L, 2);
	}
	displayStateCommand(L)->setStencilTest(compare, value);
	return 0;
}

int w_getStencilTest(lua_State *L)
{
	int value;
	const char *str = getCompareConstant(displayStateCommand(L)->getStencilTest(value));
	if (str == nullptr)
		return luaL_error(L, "Unknown compare mode.");
	lua_pushstring(L, str);
	lua_pushnumber(L, value);
	return 2;
}

int w_stencil(lua_State *L)
{
	luaL_checktype(L, 1, LUA_TFUNCTION);
	auto action = GraphicsDisplayStateCommand::STENCIL_REPLACE;
	if (!lua_isnoneornil(L, 2))
	{
		const char *str = luaL_checkstring(L, 2);
		static constexpr const char *names[] = {"replace", "increment", "decrement",
			"incrementwrap", "decrementwrap", "invert"};
		bool found = false;
		for (int index = 0; index < 6; ++index)
			if (strcmp(str, names[index]) == 0)
			{
				action = (GraphicsDisplayStateCommand::StencilAction) index;
				found = true;
				break;
			}
		if (!found)
			return luax_enumerror(L, "stencil draw action",
				std::vector<std::string>{"replace", "increment", "decrement",
					"incrementwrap", "decrementwrap", "invert"}, str);
	}
	const int value = (int) luaL_optinteger(L, 3, 1);
	bool shouldClear = true;
	int clearValue = 0;
	const int type = lua_type(L, 4);
	if (type == LUA_TBOOLEAN)
		shouldClear = !luax_toboolean(L, 4);
	else if (type == LUA_TNUMBER)
		clearValue = (int) luaL_checkinteger(L, 4);
	else if (type != LUA_TNONE && type != LUA_TNIL)
		luaL_checktype(L, 4, LUA_TBOOLEAN);
	std::string error;
	auto *command = displayStateCommand(L);
	if (!command->beginStencilWrite(action, value, shouldClear, clearValue, error))
		return luaL_error(L, "%s", error.c_str());
	lua_pushvalue(L, 1);
	const int status = lua_pcall(L, 0, 0, 0);
	command->endStencilWrite();
	if (status != LUA_OK)
		return lua_error(L);
	return 0;
}

} // graphics
} // love
