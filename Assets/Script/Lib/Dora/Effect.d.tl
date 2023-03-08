local Pass = require("Pass").Type
local Object = require("Object").Type
local record Effect
	embed Object
	add: function(self: Effect, pass: Pass)
	get: function(self: Effect, index: integer): Pass
	clear: function(self: Effect)
end
local record EffectClass
	type Type = Effect
	metamethod __call: function(cls: EffectClass, vertShader: string, fragShader: string): Effect
	metamethod __call: function(cls: EffectClass): Effect
end
local effectClass: EffectClass
return effectClass
