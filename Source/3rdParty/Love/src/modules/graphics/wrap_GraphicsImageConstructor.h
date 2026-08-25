/** Copyright (c) 2006-2023 LOVE Development Team. */
#pragma once

#include "Image.h"
#include "common/runtime.h"

namespace love::graphics
{

class GraphicsImageConstructorCommand
{
public:
	virtual ~GraphicsImageConstructorCommand() = default;
	virtual Image *newImage(Image::Slices &slices, const Image::Settings &settings) = 0;
};

LOVE_EXPORT int w_newImage(lua_State *L);
LOVE_EXPORT int w_newArrayImage(lua_State *L);
LOVE_EXPORT int w_newCubeImage(lua_State *L);
LOVE_EXPORT int w_newVolumeImage(lua_State *L);

}
