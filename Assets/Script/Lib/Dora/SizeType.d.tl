local ContainerItem = require("ContainerItemType")
local type Vec2 = require("Vec2Type")

-- A size object with a given width and height.
local record Size

	-- Inherits from `ContainerItem`.
	embed ContainerItem

	-- The width of the size.
	width: number

	-- The height of the size.
	height: number

	-- Set the width and height of the size.
	-- @param width (number) The new width of the size.
	-- @param height (number) The new height of the size.
	set: function(self: Size, width: number, height: number)

	-- Check if two sizes are equal.
	-- @param other (Size) The other size to compare to, represented by a Size object.
	-- @return (boolean) Whether or not the two sizes are equal.
	-- @usage sizeA == sizeB or sizeC ~= sizeD
	metamethod __eq: function(self: Size, other: Size): boolean

	-- Multiply the size by a vector.
	-- @param vec (Vec2) The vector to multiply by, represented by a Vec2 object.
	-- @return (Size) The result of multiplying the size by the vector, represented by a new Size object.
	-- @usage local halfSize = size * Vec2(0.5, 0.5)
	metamethod __mul: function(self: Size, vec: Vec2): Size
end

return Size
