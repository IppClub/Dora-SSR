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
	-- 	"builtin:" + theBuiltinShaderName
	-- 	"Shader/compiled_shader_file.bin"
	-- @return (SpriteEffect) A new SpriteEffect object.
	metamethod __call: function(self: SpriteEffectClass, vertShader: string, fragShader: string): SpriteEffect

	-- A metamethod for creating a new empty SpriteEffect object.
	-- @return (SpriteEffect) A new SpriteEffect object.
	metamethod __call: function(self: SpriteEffectClass): SpriteEffect
end

local spriteEffectClass: SpriteEffectClass
return spriteEffectClass
