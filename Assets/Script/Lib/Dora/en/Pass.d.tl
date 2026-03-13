local Object = require("Object").Type
local Color = require("Color").Type
local Texture2D = require("Texture2D").Type

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

	-- Binds a texture to a sampler uniform and texture slot.
	-- @param name (string) The sampler name in the shader.
	-- @param texture (Texture2D) The texture to bind.
	-- @param slot (integer) The texture slot index.
	set: function(self: Pass, name: string, texture: Texture2D, slot: integer)

	-- Removes a previously set uniform or sampler binding by name.
	-- @param name (string) The uniform name in the shader.
	remove: function(self: Pass, name: string)
end

-- A class for creating Pass objects.
local record PassClass
	type Type = Pass

	-- A metamethod that allows you to create a new Pass object.
	-- @param vertShader (string) The vertex shader file string.
	-- @param fragShader (string) The fragment shader file string.
	-- A shader file string must be one of the formats:
	-- 	builtin: + theBuiltinShaderName
	-- 	shader_compiled_file.bin
	-- 	Shader/shader_source_file.sc
	-- Details:
	-- 	1. `"builtin:" + name` loads an embedded built-in shader.
	-- 	2. For `.sc` files, the given path is loaded as shader source and compiled immediately.
	-- 	3. For `.bin` files, if the given path exists, it is loaded directly.
	-- 	4. Otherwise the engine tries `renderer_dir/filename.bin`, where `renderer_dir`
	-- 	   depends on the active backend, such as `dx11`, `metal`, `glsl`, `essl`, or `spirv`.
	-- @return (Pass) A new Pass object.
	metamethod __call: function(self: PassClass, vertShader: string, fragShader: string): Pass
end

local passClass: PassClass
return passClass
