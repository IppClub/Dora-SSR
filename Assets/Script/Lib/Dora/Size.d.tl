local type Size = require("SizeType")
local type Vec2 = require("Vec2Type")

-- A class for creating Size objects.
local record SizeClass
	type Type = Size

	-- Create a new Size object with the given width and height.
	-- @param width (number) [optional] The width of the new size (default 0).
	-- @param height (number) [optional] The height of the new size (default 0).
	-- @return (Size) The new Size object.
	-- @usage local size = Size(10, 20)
	metamethod __call: function(
		self: SizeClass,
		width?: number --[[0]],
		height?: number --[[0]]
	): Size

	-- Create a new Size object from an existing Size object.
	-- @param other (Size) The existing Size object to create the new object from.
	-- @return (Size) The new Size object.
	-- @usage local newSize = Size(existingSize)
	metamethod __call: function(self: SizeClass, other: Size): Size

	-- Create a new Size object from a Vec2 object.
	-- @param vec (Vec2) The vector to create the new size from, represented by a Vec2 object.
	-- @return (Size) The new Size object.
	-- @usage local size = Size(Vec2(10, 20))
	metamethod __call: function(self: SizeClass, vec: Vec2): Size

	-- Gets zero-size object.
	const zero: Size
end

local sizeClass: SizeClass
return sizeClass
