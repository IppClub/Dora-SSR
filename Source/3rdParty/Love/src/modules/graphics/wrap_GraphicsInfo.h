/**
 * Copyright (c) 2006-2023 LOVE Development Team
 *
 * This software is provided 'as-is', without any express or implied warranty.
 */
#pragma once

#include "common/runtime.h"

namespace love::graphics
{

class GraphicsInfoCommand
{
public:
	virtual ~GraphicsInfoCommand() = default;
	virtual int getWidth() const = 0;
	virtual int getHeight() const = 0;
	virtual int getPixelWidth() const = 0;
	virtual int getPixelHeight() const = 0;
	virtual double getDPIScale() const = 0;
	virtual bool isActive() const = 0;
	virtual bool isCreated() const = 0;
	virtual bool isGammaCorrect() const = 0;
};

LOVE_EXPORT int w_getWidth(lua_State *L);
LOVE_EXPORT int w_getHeight(lua_State *L);
LOVE_EXPORT int w_getDimensions(lua_State *L);
LOVE_EXPORT int w_getPixelWidth(lua_State *L);
LOVE_EXPORT int w_getPixelHeight(lua_State *L);
LOVE_EXPORT int w_getPixelDimensions(lua_State *L);
LOVE_EXPORT int w_getDPIScale(lua_State *L);
LOVE_EXPORT int w_isActive(lua_State *L);
LOVE_EXPORT int w_isCreated(lua_State *L);
LOVE_EXPORT int w_isGammaCorrect(lua_State *L);

}
