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

#include "wrap_GraphicsState.h"

#include "common/Exception.h"
#include "common/Module.h"
#include "math/wrap_Transform.h"

#include <cstring>
#include <string>
#include <vector>

namespace love
{
namespace graphics
{

static GraphicsStateCommand *stateCommand(lua_State *L)
{
	auto *module = luax_getmodule(L, Module::M_GRAPHICS);
	auto *command = dynamic_cast<GraphicsStateCommand *>(module);
	if (command == nullptr)
		luaL_error(L, "love.graphics has no state-local transform command adapter");
	return command;
}

int w_reset(lua_State *L)
{
	stateCommand(L)->reset(L);
	return 0;
}

int w_present(lua_State *L)
{
	luax_catchexcept(L, [&]() { stateCommand(L)->present(L); });
	return 0;
}

int w_flushBatch(lua_State *L)
{
	stateCommand(L)->flushBatch();
	return 0;
}

int w_getStackDepth(lua_State *L)
{
	lua_pushnumber(L, stateCommand(L)->getStackDepth());
	return 1;
}

int w_push(lua_State *L)
{
	GraphicsStateCommand::StackType type = GraphicsStateCommand::STACK_TRANSFORM;
	const char *name = lua_isnoneornil(L, 1) ? nullptr : luaL_checkstring(L, 1);
	if (name != nullptr)
	{
		if (strcmp(name, "transform") == 0)
			type = GraphicsStateCommand::STACK_TRANSFORM;
		else if (strcmp(name, "all") == 0)
			type = GraphicsStateCommand::STACK_ALL;
		else
			return luax_enumerror(L, "graphics stack type",
				std::vector<std::string>{"all", "transform"}, name);
	}
	luax_catchexcept(L, [&]() { stateCommand(L)->push(L, type); });
	if (luax_istype(L, 2, math::Transform::type))
	{
		math::Transform *transform = luax_totype<math::Transform>(L, 2);
		luax_catchexcept(L, [&]() { stateCommand(L)->applyTransform(transform); });
	}
	return 0;
}

int w_pop(lua_State *L)
{
	luax_catchexcept(L, [&]() { stateCommand(L)->pop(L); });
	return 0;
}

int w_rotate(lua_State *L)
{
	stateCommand(L)->rotate((float) luaL_checknumber(L, 1));
	return 0;
}

int w_scale(lua_State *L)
{
	float x = (float) luaL_optnumber(L, 1, 1.0f);
	stateCommand(L)->scale(x, (float) luaL_optnumber(L, 2, x));
	return 0;
}

int w_translate(lua_State *L)
{
	stateCommand(L)->translate((float) luaL_checknumber(L, 1),
		(float) luaL_checknumber(L, 2));
	return 0;
}

int w_shear(lua_State *L)
{
	stateCommand(L)->shear((float) luaL_checknumber(L, 1),
		(float) luaL_checknumber(L, 2));
	return 0;
}

int w_origin(lua_State *L)
{
	stateCommand(L)->origin();
	return 0;
}

int w_applyTransform(lua_State *L)
{
	math::Transform *transform = math::luax_checktransform(L, 1);
	luax_catchexcept(L, [&]() { stateCommand(L)->applyTransform(transform); });
	return 0;
}

int w_replaceTransform(lua_State *L)
{
	math::Transform *transform = math::luax_checktransform(L, 1);
	luax_catchexcept(L, [&]() { stateCommand(L)->replaceTransform(transform); });
	return 0;
}

int w_transformPoint(lua_State *L)
{
	Vector2 point{(float) luaL_checknumber(L, 1), (float) luaL_checknumber(L, 2)};
	point = stateCommand(L)->transformPoint(point);
	lua_pushnumber(L, point.x);
	lua_pushnumber(L, point.y);
	return 2;
}

int w_inverseTransformPoint(lua_State *L)
{
	Vector2 point{(float) luaL_checknumber(L, 1), (float) luaL_checknumber(L, 2)};
	luax_catchexcept(L, [&]() { point = stateCommand(L)->inverseTransformPoint(point); });
	lua_pushnumber(L, point.x);
	lua_pushnumber(L, point.y);
	return 2;
}

} // graphics
} // love
