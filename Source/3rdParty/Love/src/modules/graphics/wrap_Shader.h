/**
 * Copyright (c) 2006-2023 LOVE Development Team
 */

#pragma once

#include "Shader.h"
#include "common/runtime.h"

namespace love::graphics
{

Shader *luax_checkshader(lua_State *L, int idx);
extern "C" int luaopen_shader(lua_State *L);

} // namespace love::graphics
