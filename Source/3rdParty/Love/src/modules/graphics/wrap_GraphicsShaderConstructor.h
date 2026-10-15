/** Copyright (c) 2006-2023 LOVE Development Team. */
#pragma once

#include "Shader.h"
#include "common/runtime.h"

namespace love::graphics
{

class GraphicsShaderConstructorCommand
{
public:
	virtual ~GraphicsShaderConstructorCommand() = default;
	virtual Shader *newShader(const std::string &vertexSource,
		const std::string &pixelSource) = 0;
	virtual bool validateShader(bool gles, const std::string &vertexSource,
		const std::string &pixelSource, std::string &error) = 0;
};

LOVE_EXPORT int w_newShader(lua_State *L);
LOVE_EXPORT int w_validateShader(lua_State *L);

}
