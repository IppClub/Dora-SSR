local Object = require("Object").Type
local Color = require("Color").Type

-- A record representing a shader pass.
local record Pass

	-- Inherits from `Object`.
	embed Object

	-- Whether this Pass should be a grab pass.
	-- A grab pass will render a portion of game scene into a texture frame buffer.
	-- Then use this texture frame buffer as an input for next render pass.
	grabPass: boolean

	-- A function that sets the values of shader parameters.
	-- @param name (string) The name of the parameter to set.
	-- @param var1 (number) The first numeric value to set.
	-- @param var2 (number) [optional] An optional second numeric value to set (default is 0).
	-- @param var3 (number) [optional] An optional third numeric value to set (default is 0).
	-- @param var4 (number) [optional] An optional fourth numeric value to set (default is 0).
	set: function(self: Pass,
		name: string,
		var1: number,
		var2?: number --[[0]],
		var3?: number --[[0]],
		var4?: number --[[0]])

	-- Another function that sets the values of shader parameters.
	-- Works the same as:
	-- pass:set("varName", color.r / 255.0, color.g / 255.0, color.b / 255.0, color.opacity)
	-- @param name (string) The name of the parameter to set.
	-- @param var (Color) The Color object to set.
	set: function(self: Pass, name: string, var: Color)
end

-- A class for creating Pass objects.
local record PassClass
	type Type = Pass

	-- A metamethod that allows you to create a new Pass object.
	-- @param vertShader (string) The vertex shader in binary form file string.
	-- @param fragShader (string) The fragment shader file string.
	-- A shader file string must be one of the formats:
	-- 	"builtin:" + theBuiltinShaderName
	-- 	"Shader/compiled_shader_file.bin"
	-- @return (Pass) A new Pass object.
	metamethod __call: function(self: PassClass, vertShader: string, fragShader: string): Pass
end

local passClass: PassClass
return passClass
