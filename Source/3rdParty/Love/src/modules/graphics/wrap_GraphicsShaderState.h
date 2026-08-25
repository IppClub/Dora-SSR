/** Copyright (c) 2006-2023 LOVE Development Team. */
#pragma once

#include "common/runtime.h"
#include "Shader.h"

namespace love::graphics
{

class GraphicsShaderStateCommand
{
public:
	virtual ~GraphicsShaderStateCommand() = default;
	virtual void setShader(Shader *shader) = 0;
	virtual Shader *getShader() const = 0;
};

LOVE_EXPORT int w_setShader(lua_State *L);
LOVE_EXPORT int w_getShader(lua_State *L);

}
