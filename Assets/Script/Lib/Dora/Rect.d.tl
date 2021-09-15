local Vec2 = require("Vec2").Type
local Size = require("Size").Type
local record Rect
	origin: Vec2
	size: Size
	x: number
	y: number
	width: number
	height: number
	left: number
	right: number
	centerX: number
	centerY: number
	bottom: number
	top: number
	lowerBound: Vec2
	upperBound: Vec2
	set: function(self: Rect, x: number, y: number, width: number, height: number)
	containsPoint: function(self: Rect, point: Vec2): boolean
	intersectsRect: function(self: Rect, rect: Rect): boolean
	metamethod __eq: function(self: Rect, other: Rect): boolean
end
local record RectClass
	type Type = Rect
	const zero: Rect
	metamethod __call: function(cls: RectClass, other: Rect): Rect
	metamethod __call: function(cls: RectClass,
		x: number,
		y: number,
		width: number,
		height: number): Rect
	metamethod __call: function(cls: RectClass, origin: Vec2, size: Size): Rect
	metamethod __call: function(cls: RectClass): Rect
end
print(Rect.origin)
print(Rect.size)
print(Rect.lowerBound)
print(Rect.upperBound)
local rectClass: RectClass
return rectClass
