local Node = require("Node").Type
local Object = require("Object").Type
local Camera = require("Camera").Type
local Texture2D = require("Texture2D").Type
local Color = require("Color").Type

-- 用于将游戏场景节点渲染到一张纹理上的类。
local record RenderTarget

	-- 继承自`Object`。
	embed Object

	-- 渲染目标的宽度。
	const width: integer

	-- 渲染目标的高度。
	const height: integer

	-- 渲染目标生成的纹理。
	const texture: Texture2D

	-- 用于渲染场景节点的相机。
	camera: Camera

	-- 渲染节点到目标纹理，不清空之前渲染的内容。
	-- @param target (Node) 要渲染到渲染目标的节点。
	render: function(self: RenderTarget, target: Node)

	-- 初始化渲染目标纹理上颜色，深度和模板值。
	-- @param color (Color) 用于初始化渲染目标的颜色。
	-- @param depth (number) [可选] 用于初始化渲染目标的深度缓冲区的值。默认为1。
	-- @param stencil (number) [可选] 用于初始化渲染目标的模板缓冲区的值。默认为0。
	renderWithClear: function(
		self: RenderTarget,
		color: Color,
		depth?: number --[[1]],
		stencil?: number --[[0]]
	)

	-- 初始化渲染目标纹理之后，再将场景节点渲染到目标纹理。
	-- @param target (Node) 要渲染到渲染目标的节点。
	-- @param color (Color) 用于初始化渲染目标的颜色。
	-- @param depth (number) [可选] 用于初始化渲染目标的深度缓冲区的值。默认为1。
	-- @param stencil (number) [可选] 用于初始化渲染目标的模板缓冲区的值。默认为0。
	renderWithClear: function(
		self: RenderTarget,
		target: Node,
		color: Color,
		depth?: number --[[1]],
		stencil?: integer --[[0]]
	)

	-- 异步将渲染目标的内容保存成一张PNG文件。
	-- @param filename (string) 新生成的PNG文件的名称。
	saveAsync: function(self: RenderTarget, filename: string)
end

-- 用于创建渲染目标对象的类。
local record RenderTargetClass
	type Type = RenderTarget

	-- 使用给定的宽度和高度创建一个新的渲染目标对象。
	-- @param width (integer) 渲染目标的宽度。
	-- @param height (integer) 渲染目标的高度。
	-- @return (RenderTarget) 创建的渲染目标。
	metamethod __call: function(self: RenderTargetClass, width: integer, height: integer): RenderTarget
end

local renderTargetClass: RenderTargetClass
return renderTargetClass
