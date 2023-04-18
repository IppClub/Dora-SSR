local Pass = require("Pass").Type
local Object = require("Object").Type

-- 用于管理多个渲染Pass对象的着色器特效类，可以组合多个Pass创建更复杂的着色器渲染效果。
local record Effect

	-- 继承自`Object`。
	embed Object

	-- 添加Pass对象。
	-- @param pass (Pass) 要添加的Pass对象。
	add: function(self: Effect, pass: Pass)

	-- 通过从1开始的索引获取Pass对象。
	-- @param index (integer) 获取Pass对象的整数索引，索引从1开始。
	-- @return (Pass) 给定索引的Pass对象。
	get: function(self: Effect, index: integer): Pass

	-- 从特效对象中删除所有Pass对象。
	clear: function(self: Effect)
end

-- 用于创建着色器特效对象的类。
local record EffectClass
	type Type = Effect

	-- 用于创建新的着色器特效对象的元方法。
	-- @param vertShader (string) 顶点着色器文件名字符串。
	-- @param fragShader (string) 片段着色器文件名字符串。
	-- 着色器文件字符串必须是以下格式之一：
	-- 	1. "builtin:" + theBuiltinShaderName
	-- 	2. "Shader/compiled_shader_file.bin"
	-- @return (Effect) 新创建的着色器特效对象。
	metamethod __call: function(self: EffectClass, vertShader: string, fragShader: string): Effect

	-- 创建新的空着色器特效对象的元方法。
	-- @return (Effect) 新的着色器特效对象。
	metamethod __call: function(self: EffectClass): Effect
end

local effectClass: EffectClass
return effectClass
