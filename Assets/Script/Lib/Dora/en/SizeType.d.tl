local ContainerItem = require("ContainerItemType")

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
	-- @param other (Size) The other size to compare to.
	-- @return (boolean) Whether or not the two sizes are equal.
	-- @usage sizeA == sizeB or sizeC ~= sizeD
	equals: function(self: Size, other: Size): boolean

	-- Multiply the size by a vector.
	-- @param vec (Vec2) The vector to multiply by.
	-- @return (Size) The result of multiplying the size by the vector.
	-- @usage local halfSize = size * Vec2(0.5, 0.5)
	mul: function(self: Size, vec: Dora.Vec2.Type): Size

	-- Check if two sizes are equal.
	-- @param other (Size) The other size to compare to.
	-- @return (boolean) Whether or not the two sizes are equal.
	-- @usage sizeA == sizeB or sizeC ~= sizeD
	metamethod __eq: function(self: Size, other: Size): boolean

	-- Multiply the size by a vector.
	-- @param vec (Vec2) The vector to multiply by.
	-- @return (Size) The result of multiplying the size by the vector.
	-- @usage local halfSize = size * Vec2(0.5, 0.5)
	metamethod __mul: function(self: Size, vec: Dora.Vec2.Type): Size
end

return Size
