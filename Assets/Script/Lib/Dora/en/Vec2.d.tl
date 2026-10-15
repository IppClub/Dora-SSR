local type Vec2 = require("Vec2Type")
local type Size = require("SizeType")

-- A class for creating Vec2 objects.
local record Vec2Class
	type Type = Vec2

	-- Creates a new Vec2 object from an existing Vec2 object.
	-- @param other (Vec2) The existing Vec2 object to create the new object from.
	-- @return (Vec2) The new Vec2 object.
	-- @usage local newVec = Vec2(existingVec)
	metamethod __call: function(self: Vec2Class, other: Vec2): Vec2

	-- Creates a new Vec2 object with the given x and y components.
	-- @param x (number) The x-component of the new vector.
	-- @param y (number) The y-component of the new vector.
	-- @return (Vec2) The new Vec2 object.
	-- @usage local newVec = Vec2(10, 20)
	metamethod __call: function(
		self: Vec2Class,
		x: number,
		y: number
	): Vec2

	-- Creates a new Vec2 object from a Size object.
	-- @param size (Size) The Size object to create the new vector from.
	-- @return (Vec2) The new Vec2 object.
	-- @usage local newVec = Vec2Class(Size(10, 20))
	metamethod __call: function(self: Vec2Class, size: Size): Vec2

	-- Gets zero-vector object.
	const zero: Vec2
end

local vec2Class: Vec2Class
return vec2Class
