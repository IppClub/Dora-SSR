/** Copyright (c) 2006-2023 LOVE Development Team. */
#pragma once

#include "common/runtime.h"
#include "Font.h"

namespace love::graphics
{

class GraphicsFontStateCommand
{
public:
	virtual ~GraphicsFontStateCommand() = default;
	virtual void setFont(Font *font) = 0;
	virtual Font *getFont() = 0;
};

LOVE_EXPORT int w_setFont(lua_State *L);
LOVE_EXPORT int w_getFont(lua_State *L);

}
