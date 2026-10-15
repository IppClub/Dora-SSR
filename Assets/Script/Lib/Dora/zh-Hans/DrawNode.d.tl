local Node = require("Node").Type
local BlendFunc = require("BlendFunc").Type
local Vec2 = require("Vec2").Type
local Rect = require("Rect").Type
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

	-- 在指定中心绘制指定半径和颜色的圆。
	drawCircle: function(self: DrawNode, center: Vec2, radius: number, color?: Color --[[0xffffffff]])

	-- 绘制带可选边框的矩形。
	drawRect: function(self: DrawNode, rect: Rect, fillColor?: Color --[[0xffffffff]], borderWidth?: number --[[0]], borderColor?: Color --[[0xffffffff]])

	-- 在指定中心绘制填充椭圆。
	drawEllipse: function(self: DrawNode, center: Vec2, radiusX: number, radiusY: number, color?: Color --[[0xffffffff]])

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

	-- 绘制圆头端点、尖角连接的连续折线，过长尖角使用斜切连接。radius 为线宽的一半；忽略相邻重复顶点。
	drawPolyline: function(self: DrawNode, verts: {Vec2}, radius: number, color?: Color --[[0xffffffff]], closed?: boolean --[[false]])

	-- 以度为单位绘制圆弧：零度朝向 +X，角度增大朝向 +Y。角度差按正负方向最多绘制一圈；整圈自动闭合。lineRadius 为线宽的一半。
	drawArc: function(self: DrawNode, center: Vec2, radius: number, startAngle: number, endAngle: number, lineRadius: number, color?: Color --[[0xffffffff]])

	-- 绘制圆角矩形。圆角半径限制为较短边的一半，零半径绘制普通矩形；borderWidth 为居中边框宽度的一半。
	drawRoundedRect: function(self: DrawNode, rect: Rect, cornerRadius: number, fillColor?: Color --[[0xffffffff]], borderWidth?: number --[[0]], borderColor?: Color --[[0xffffffff]])

	-- 绘制圆环，要求 0 <= innerRadius < outerRadius。内半径为零时填充中心；可选边框沿内外轮廓居中绘制，borderWidth 为半宽。
	drawRing: function(self: DrawNode, center: Vec2, innerRadius: number, outerRadius: number, fillColor?: Color --[[0xffffffff]], borderWidth?: number --[[0]], borderColor?: Color --[[0xffffffff]])

	-- 绘制扇形，角度以度为单位，从 +X 朝向 +Y 增大。正负角度差最多绘制一圈；整圈不绘制径向边，起止角相同时不绘制。borderWidth 为边框半宽。
	drawSector: function(self: DrawNode, center: Vec2, radius: number, startAngle: number, endAngle: number, fillColor?: Color --[[0xffffffff]], borderWidth?: number --[[0]], borderColor?: Color --[[0xffffffff]])

	-- 绘制圆头端点的二次贝塞尔曲线，端点重合时自动闭合；radius 为线宽的一半。自适应细分以 0.25 个局部坐标单位和控制点包围盒对角线的 1% 中较小值为目标误差，最多 1024 段。
	drawQuadraticBezier: function(self: DrawNode, from: Vec2, control: Vec2, to: Vec2, radius: number, color?: Color --[[0xffffffff]])

	-- 绘制圆头端点的三次贝塞尔曲线，端点重合时自动闭合；radius 为线宽的一半。自适应细分以 0.25 个局部坐标单位和控制点包围盒对角线的 1% 中较小值为目标误差，最多 1024 段。
	drawCubicBezier: function(self: DrawNode, from: Vec2, control1: Vec2, control2: Vec2, to: Vec2, radius: number, color?: Color --[[0xffffffff]])

	-- 按边界顺序绘制简单凸多边形或凹多边形，支持两种方向；不支持自相交或孔洞。边框以轮廓为中心向两侧延伸。
	-- @param verts ({Vec2}) 多边形的顶点。
	-- @param fillColor (Color) [可选] 多边形的填充颜色（默认为白色）。
	-- @param borderWidth (number) [可选] 边框宽度的一半，向轮廓两侧延伸（默认为 0）。
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
