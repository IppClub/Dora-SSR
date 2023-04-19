local Node = require("Node").Type
local BlendFunc = require("BlendFunc").Type
local Color = require("Color").Type
local Vec2 = require("Vec2").Type

-- 使用顶点绘制线条的场景节点类。
local record Line

	-- 继承自`Node`。
	embed Node

	-- 是否应该写入深度。默认为false。
	depthWrite: boolean

	-- 用于渲染线条的混合函数。
	blendFunc: BlendFunc

	-- 添加顶点到线条。
	-- @param verts ({Vec2}) 要添加到线条的顶点表。
	-- @param color (Color) [可选] 线条的颜色（默认为不透明白色）。
	add: function(
		self: Line,
		verts: {Vec2},
		color?: Color --[[0xffffffff]]
	)

	-- 设置线条的顶点。
	-- @param verts ({Vec2}) 要设置的顶点表。
	-- @param color (Color) 线条的颜色（默认为不透明白色）。
	set: function(
		self: Line,
		verts: {Vec2},
		color?: Color --[[0xffffffff]]
	)

	-- 清除所有线条的顶点。
	clear: function(self: Line)
end

-- 用于创建线条节点对象的类。
local record LineClass
	type Type = Line

	-- 创建并返回一个新的线条节点对象。
	-- @param verts ({Vec2}) 要添加到线条的顶点表。
	-- @param color (Color) [可选] 线条的颜色（默认为不透明白色）。
	-- @return (Line) 线条节点对象。
	metamethod __call: function(
		self: LineClass,
		verts: {Vec2},
		color?: Color --[[0xffffffff]]
	): Line

	-- 创建并返回一个新的空线条节点对象。
	-- @return (Line) 线条节点对象。
	metamethod __call: function(self: LineClass): Line
end

local lineClass: LineClass
return lineClass
