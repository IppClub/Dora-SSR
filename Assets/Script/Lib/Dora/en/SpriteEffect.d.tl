local Effect = require("Effect").Type

-- A record that is a specialization of Effect for rendering 2D sprites.
local record SpriteEffect

	-- Inherits from `Effect`.
	embed Effect
end

-- A class for creating SpriteEffect objects.
local record SpriteEffectClass
	type Type = SpriteEffect

	-- A metamethod that allows you to create a new SpriteEffect object.
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
	-- @return (SpriteEffect) A new SpriteEffect object.
	metamethod __call: function(self: SpriteEffectClass, vertShader: string, fragShader: string): SpriteEffect

	-- A metamethod for creating a new empty SpriteEffect object.
	-- @return (SpriteEffect) A new SpriteEffect object.
	metamethod __call: function(self: SpriteEffectClass): SpriteEffect
end

local spriteEffectClass: SpriteEffectClass
return spriteEffectClass
