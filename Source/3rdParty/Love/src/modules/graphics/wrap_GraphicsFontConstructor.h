/** Copyright (c) 2006-2023 LOVE Development Team. */
#pragma once

#include "Font.h"
#include "common/runtime.h"
#include "font/Rasterizer.h"

namespace love::graphics
{

class GraphicsFontConstructorCommand
{
public:
	virtual ~GraphicsFontConstructorCommand() = default;
	virtual Font *newDefaultFont(int size) = 0;
	virtual Font *newFont(love::font::Rasterizer *rasterizer) = 0;
};

LOVE_EXPORT int w_newFont(lua_State *L);
LOVE_EXPORT int w_newImageFont(lua_State *L);
LOVE_EXPORT int w_setNewFont(lua_State *L);

}
