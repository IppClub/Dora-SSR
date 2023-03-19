local Effect = require("Effect").Type
local record SpriteEffect
	embed Effect
end
local record SpriteEffectClass
	type Type = SpriteEffect
	metamethod __call: function(self: SpriteEffectClass, vertShader: string, fragShader: string): SpriteEffect
	metamethod __call: function(self: SpriteEffectClass): SpriteEffect
end
local spriteEffectClass: SpriteEffectClass
return spriteEffectClass
