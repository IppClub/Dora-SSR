local Object = require("Object").Type
local Color = require("Color").Type
local Texture2D = require("Texture2D").Type

-- 代表着色器渲染流程的类。
local record Pass

	-- 继承自`Object`。
	embed Object

	-- 是否应该是一个采样流程。
	-- 一个采样流程将会把游戏场景渲染到一个纹理缓存中。
	-- 然后将该纹理帧缓存用作下一次渲染流程的输入。
	grabPass: boolean

	-- 用于设置着色器参数值的函数。
	-- @param name (string) 要设置的参数名称。
	-- @param var1 (number) 要设置的第一个数值。
	-- @param var2 (number) [可选] 要设置的第二个数值（默认为0）。
	-- @param var3 (number) [可选] 要设置的第三个数值（默认为0）。
	-- @param var4 (number) [可选] 要设置的第四个数值（默认为0）。
	set: function(self: Pass,
		name: string,
		var1: number,
		var2?: number --[[0]],
		var3?: number --[[0]],
		var4?: number --[[0]])

	-- 另一个设置着色器参数值的函数。
	-- 等同于代码：
	-- pass:set("varName", color.r / 255.0, color.g / 255.0, color.b / 255.0, color.opacity)
	-- @param name (string) 要设置的参数名称。
	-- @param var (Color) 要设置的颜色对象。
	set: function(self: Pass, name: string, var: Color)

	-- 绑定一个纹理到指定采样器和纹理槽位。
	-- @param name (string) 着色器中的采样器名称。
	-- @param texture (Texture2D) 要绑定的纹理。
	-- @param slot (integer) 纹理槽位索引。
	set: function(self: Pass, name: string, texture: Texture2D, slot: integer)

	-- 移除指定名称的 uniform 或采样器绑定。
	-- @param name (string) 着色器中的 uniform 名称。
	remove: function(self: Pass, name: string)
end

-- 用于创建着色器渲染流程对象的类。
local record PassClass
	type Type = Pass

	-- 用于创建一个新的渲染流程对象的元方法。
	-- @param vertShader (string) 顶点着色器文件字符串。
	-- @param fragShader (string) 片段着色器文件字符串。
	-- 着色器文件字符串必须是以下格式之一：
	-- 	builtin: + 内置着色器名称
	-- 	shader_compiled_file.bin
	-- 	Shader/shader_source_file.sc
	-- 详细说明：
	-- 	1. `"builtin:" + 名称` 会加载内嵌的内置着色器。
	-- 	2. 对于 `.sc` 文件，会把给定路径当作着色器源码直接加载并立即编译。
	-- 	3. 对于 `.bin` 文件，如果给定路径存在，则直接加载该文件。
	-- 	4. 否则引擎会尝试加载 `renderer_dir/filename.bin`，其中 `renderer_dir`
	-- 	   取决于当前渲染后端，例如 `dx11`、`metal`、`glsl`、`essl` 或 `spirv`。
	-- @return (Pass) 新的着色器渲染流程对象。
	metamethod __call: function(self: PassClass, vertShader: string, fragShader: string): Pass
end

local passClass: PassClass
return passClass
