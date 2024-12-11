local Pass = require("Pass").Type
local Object = require("Object").Type

-- A class for managing multiple render pass objects.
-- Effect objects allow you to combine multiple passes to create more complex shader effects.
local record Effect

	-- Inherits from `Object`.
	embed Object

	-- A function that adds a Pass object to this Effect.
	-- @param pass (Pass) The Pass object to add.
	add: function(self: Effect, pass: Pass)

	-- A function that retrieves a Pass object from this Effect by index.
	-- @param index (integer) The index of the Pass object to retrieve. Starts from 1.
	-- @return (Pass) The Pass object at the given index.
	get: function(self: Effect, index: integer): Pass

	-- A function that removes all Pass objects from this Effect.
	clear: function(self: Effect)
end

-- A class for creating Effect objects.
local record EffectClass
	type Type = Effect

	-- A metamethod that allows you to create a new Effect object.
	-- @param vertShader (string) The vertex shader file string.
	-- @param fragShader (string) The fragment shader file string.
	-- A shader file string must be one of the formats:
	-- 	"builtin:" + theBuiltinShaderName
	-- 	"Shader/compiled_shader_file.bin"
	-- @return (Effect) A new Effect object.
	metamethod __call: function(self: EffectClass, vertShader: string, fragShader: string): Effect

	-- Another metamethod that allows you to create a new empty Effect object.
	-- @return (Effect) A new empty Effect object.
	metamethod __call: function(self: EffectClass): Effect
end

local effectClass: EffectClass
return effectClass
