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
	-- 	builtin: + 内置着色器名称
	-- 	shader_compiled_file.bin
	-- 	Shader/shader_source_file.sc
	-- 详细说明：
	-- 	1. `"builtin:" + 名称` 会加载内嵌的内置着色器。
	-- 	2. 对于 `.sc` 文件，会把给定路径当作着色器源码直接加载并立即编译。
	-- 	3. 对于 `.bin` 文件，如果给定路径存在，则直接加载该文件。
	-- 	4. 否则引擎会尝试加载 `renderer_dir/filename.bin`，其中 `renderer_dir`
	-- 	   取决于当前渲染后端，例如 `dx11`、`metal`、`glsl`、`essl` 或 `spirv`。
	-- @return (SpriteEffect) 新的2D图元着色器特效对象。
	metamethod __call: function(self: SpriteEffectClass, vertShader: string, fragShader: string): SpriteEffect

	-- 用于创建一个空的2D图元着色器特效对象的元方法。
	-- @return (SpriteEffect) 新的2D图元着色器特效对象。
	metamethod __call: function(self: SpriteEffectClass): SpriteEffect
end

local spriteEffectClass: SpriteEffectClass
return spriteEffectClass
