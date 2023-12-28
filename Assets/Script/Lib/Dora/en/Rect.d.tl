local ContainerItem = require("ContainerItemType")
local Vec2 = require("Vec2").Type
local Size = require("Size").Type

-- A rectangle object with a left-bottom origin position and a size.
local record Rect

	-- Inherits from `ContainerItem`.
	embed ContainerItem

	-- The position of the origin of the rectangle.
	origin: Vec2

	-- The dimensions of the rectangle.
	size: Size

	-- The x-coordinate of the origin of the rectangle.
	x: number

	-- The y-coordinate of the origin of the rectangle.
	y: number

	-- The width of the rectangle.
	width: number

	-- The height of the rectangle.
	height: number

	-- The top edge in y-axis of the rectangle.
	top: number

	-- The bottom edge in y-axis of the rectangle.
	bottom: number

	-- The left edge in x-axis of the rectangle.
	left: number

	-- The right edge in x-axis of the rectangle.
	right: number

	-- The x-coordinate of the center of the rectangle.
	centerX: number

	-- The y-coordinate of the center of the rectangle.
	centerY: number

	-- The lower bound (left-bottom) of the rectangle.
	lowerBound: Vec2

	-- The upper bound (right-top) of the rectangle.
	upperBound: Vec2

	-- Set the properties of the rectangle.
	-- @param x (number) The x-coordinate of the origin of the rectangle.
	-- @param y (number) The y-coordinate of the origin of the rectangle.
	-- @param width (number) The width of the rectangle.
	-- @param height (number) The height of the rectangle.
	set: function(self: Rect, x: number, y: number, width: number, height: number)

	-- Check if a point is inside the rectangle.
	-- @param point (Vec2) The point to check, represented by a Vec2 object.
	-- @return (boolean) Whether or not the point is inside the rectangle.
	containsPoint: function(self: Rect, point: Vec2): boolean

	-- Check if the rectangle intersects with another rectangle.
	-- @param rect (Rect) The other rectangle to check for intersection with, represented by a Rect object.
	-- @return (boolean) Whether or not the rectangles intersect.
	intersectsRect: function(self: Rect, rect: Rect): boolean

	-- Check if two rectangles are equal.
	-- @param other (Rect) The other rectangle to compare to, represented by a Rect object.
	-- @return (boolean) Whether or not the two rectangles are equal.
	equals: function(self: Rect, other: Rect): boolean

	-- Check if two rectangles are equal.
	-- @param other (Rect) The other rectangle to compare to, represented by a Rect object.
	-- @return (boolean) Whether or not the two rectangles are equal.
	metamethod __eq: function(self: Rect, other: Rect): boolean
end

-- A class for creating rectangle objects.
local record RectClass
	type Type = Rect

	-- A rectangle object with all properties set to 0.
	const zero: Rect

	-- Create a new rectangle object using another rectangle object.
	-- @param other (Rect) The other rectangle object to create a new rectangle object from.
	-- @return (Rect) A new rectangle object.
	metamethod __call: function(self: RectClass, other: Rect): Rect

	-- Create a new rectangle object using individual properties.
	-- @param x (number) The x-coordinate of the origin of the rectangle.
	-- @param y (number) The y-coordinate of the origin of the rectangle.
	-- @param width (number) The width of the rectangle.
	-- @param height (number) The height of the rectangle.
	-- @return (Rect) A new rectangle object.
	metamethod __call: function(self: RectClass,
		x: number,
		y: number,
		width: number,
		height: number): Rect

	-- Create a new rectangle object using a Vec2 object for the origin and a Size object for the size.
	-- @param origin (Vec2) The origin of the rectangle, represented by a Vec2 object.
	-- @param size (Size) The size of the rectangle, represented by a Size object.
	-- @return (Rect) A new rectangle object.
	metamethod __call: function(self: RectClass, origin: Vec2, size: Size): Rect

	-- Create a new rectangle object with all properties set to 0.
	-- @return (Rect) A new rectangle object.
	metamethod __call: function(self: RectClass): Rect
end

local rectClass: RectClass
return rectClass
