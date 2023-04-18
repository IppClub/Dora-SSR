local Node = require("Node").Type
local BlendFunc = require("BlendFunc").Type
local Vec2 = require("Vec2").Type
local Color = require("Color").Type

-- 用于绘制简单几何形状，如点、线和多边形的场景节点类。
local record DrawNode

	-- 继承自`Node`。
	embed Node

	-- 是否在绘制时写入深度缓冲区（默认为 false）。
	depthWrite: boolean

	-- 图形绘制使用的混合函数。
	blendFunc: BlendFunc

	-- 在指定位置绘制指定半径和颜色的点。
	-- @param pos (Vec2) 点的位置。
	-- @param radius (number) 点的半径。
	-- @param color (Color) [可选] 点的颜色（默认为白色）。
	drawDot: function(
		self: DrawNode,
		pos: Vec2,
		radius: number,
		color?: Color --[[0xffffffff]]
	)

	-- 在两个点之间绘制指定半径和颜色的线段。
	-- @param from (Vec2) 线段的起点。
	-- @param to (Vec2) 线段的终点。
	-- @param radius (number) 线段的半径。
	-- @param color (Color) [可选] 线段的颜色（默认为白色）。
	drawSegment: function(
		self: DrawNode,
		from: Vec2,
		to: Vec2,
		radius: number,
		color?: Color --[[0xffffffff]]
	)

	-- 使用指定填充颜色和边框绘制由顶点列表定义的多边形。
	-- @param verts ({Vec2}) 多边形的顶点。
	-- @param fillColor (Color) [可选] 多边形的填充颜色（默认为白色）。
	-- @param borderWidth (number) [可选] 边框的宽度（默认为 0）。
	-- @param borderColor (Color) [可选] 边框的颜色（默认为白色）。
	drawPolygon: function(
		self: DrawNode,
		verts: {Vec2},
		fillColor?: Color --[[0xffffffff]],
		borderWidth?: number --[[0]],
		borderColor?: Color --[[0xffffffff]]
	)

	-- 绘制一组具有自己颜色的顶点组成的三角形。
	-- @param verts ({{Vec2, Color}}) 顶点及其颜色的列表。
	drawVertices: function(self: DrawNode, verts: {{Vec2, Color}})

	-- 清除节点中先前绘制的所有图形。
	clear: function(self: DrawNode)
end

-- 用于创建绘图节点对象的类。
local record DrawNodeClass
	type Type = DrawNode

	-- 创建一个新的绘图节点对象。
	-- @return (DrawNode) 新的绘图节点对象。
	metamethod __call: function(self: DrawNodeClass): DrawNode
end

local drawNodeClass: DrawNodeClass
return drawNodeClass
