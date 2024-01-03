local Effect = require("Effect").Type

-- 专门用于渲染2D图元的着色器特效类。
local record SpriteEffect

	-- 继承自`Effect`。
	embed Effect
end

-- 用于创建新的2D图元着色器特效的类。
local record SpriteEffectClass
	type Type = SpriteEffect

	-- 用于创建一个新的2D图元着色器特效对象的元方法。
	-- @param vertShader (string) 顶点着色器文件名字符串。
	-- @param fragShader (string) 片段着色器文件名字符串。
	-- 着色器文件名字符串必须是以下格式之一：
	-- 	"builtin:" + theBuiltinShaderName
	-- 	"Shader/compiled_shader_file.bin"
	-- @return (SpriteEffect) 新的2D图元着色器特效对象。
	metamethod __call: function(self: SpriteEffectClass, vertShader: string, fragShader: string): SpriteEffect

	-- 用于创建一个空的2D图元着色器特效对象的元方法。
	-- @return (SpriteEffect) 新的2D图元着色器特效对象。
	metamethod __call: function(self: SpriteEffectClass): SpriteEffect
end

local spriteEffectClass: SpriteEffectClass
return spriteEffectClass
