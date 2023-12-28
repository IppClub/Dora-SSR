local ContainerItem = require("ContainerItemType")
local Vec2 = require("Vec2").Type
local Size = require("Size").Type

-- 一个以左下角为原点位置的矩形区域类。
local record Rect

	-- 继承自`ContainerItem`。
	embed ContainerItem

	-- 矩形原点的位置。
	origin: Vec2

	-- 矩形的尺寸。
	size: Size

	-- 矩形原点的 x 坐标。
	x: number

	-- 矩形原点的 y 坐标。
	y: number

	-- 矩形的宽度。
	width: number

	-- 矩形的高度。
	height: number

	-- 矩形的上边缘的 y 轴坐标值。
	top: number

	-- 矩形的下边缘的 y 轴坐标值。
	bottom: number

	-- 矩形的左边缘的 x 轴坐标值。
	left: number

	-- 矩形的右边缘的 x 轴坐标值。
	right: number

	-- 矩形中心的 x 坐标。
	centerX: number

	-- 矩形中心的 y 坐标。
	centerY: number

	-- 矩形的下界（左下角坐标）。
	lowerBound: Vec2

	-- 矩形的上界（右上角坐标）。
	upperBound: Vec2

	-- 设置矩形的属性。
	-- @param x (number) 矩形原点的 x 坐标。
	-- @param y (number) 矩形原点的 y 坐标。
	-- @param width (number) 矩形的宽度。
	-- @param height (number) 矩形的高度。
	set: function(self: Rect, x: number, y: number, width: number, height: number)

	-- 检查点是否在矩形内。
	-- @param point (Vec2) 要检查的点，用二维向量对象表示。
	-- @return (boolean) 点是否在矩形内。
	containsPoint: function(self: Rect, point: Vec2): boolean

	-- 检查矩形是否与另一个矩形相交。
	-- @param rect (Rect) 要检查相交的另一个矩形，用矩形对象表示。
	-- @return (boolean) 矩形是否相交。
	intersectsRect: function(self: Rect, rect: Rect): boolean

	-- 检查两个矩形是否相等。
	-- @param other (Rect) 要比较的另一个矩形，用`Rect`对象表示。
	-- @return (boolean) 两个矩形是否相等。
	equals: function(self: Rect, other: Rect): boolean

	-- 检查两个矩形是否相等。
	-- @param other (Rect) 要比较的另一个矩形，用`Rect`对象表示。
	-- @return (boolean) 两个矩形是否相等。
	metamethod __eq: function(self: Rect, other: Rect): boolean
end

-- 用于创建矩形对象的类。
local record RectClass
	type Type = Rect

	-- 所有属性均设置为 0 的矩形对象。
	const zero: Rect

	-- 使用另一个矩形对象创建新的矩形对象。
	-- @param other (Rect) 用于创建新矩形对象的另一个矩形对象。
	-- @return (Rect) 新的矩形对象。
	metamethod __call: function(self: RectClass, other: Rect): Rect

	-- 使用各种属性创建新的矩形对象。
	-- @param x (number) 矩形原点的 x 坐标。
	-- @param y (number) 矩形原点的 y 坐标。
	-- @param width (number) 矩形的宽度。
	-- @param height (number) 矩形的高度。
	-- @return (Rect) 新的矩形对象。
	metamethod __call: function(self: RectClass,
		x: number,
		y: number,
		width: number,
		height: number): Rect

	-- 使用二维向量对象表示的原点和尺寸对象表示的尺寸创建新的矩形对象。
	-- @param origin (Vec2) 矩形的原点，用二维向量对象表示。
	-- @param size (Size) 矩形的尺寸，用尺寸对象表示。
	-- @return (Rect) 新的矩形对象。
	metamethod __call: function(self: RectClass, origin: Vec2, size: Size): Rect

	-- 创建所有属性均设置为 0 的新矩形对象。
	-- @return (Rect) 新的矩形对象。
	metamethod __call: function(self: RectClass): Rect
end

local rectClass: RectClass
return rectClass
