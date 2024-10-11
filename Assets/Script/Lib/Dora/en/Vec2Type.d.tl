local ContainerItem = require("ContainerItemType")

-- A record representing a 2D vector with an x and y component.
local record Vec2

	-- Inherits from `ContainerItem`.
	embed ContainerItem

	-- The x-component of the vector.
	const x: number

	-- The y-component of the vector.
	const y: number

	-- The length of the vector.
	const length: number

	-- The squared length of the vector.
	const lengthSquared: number

	-- The angle between the vector and the x-axis.
	const angle: number

	-- Calculates the distance between two vectors.
	-- @param vec (Vec2) The other vector to calculate the distance to.
	-- @return (number) The distance between the two vectors.
	distance: function(self: Vec2, vec: Vec2): number

	-- Calculates the squared distance between two vectors.
	-- @param vec (Vec2) The other vector to calculate the squared distance to.
	-- @return (number) The squared distance between the two vectors.
	distanceSquared: function(self: Vec2, vec: Vec2): number

	-- Normalizes the vector to have a length of 1.
	-- @return (Vec2) The normalized vector.
	normalize: function(self: Vec2): Vec2

	-- Gets the perpendicular vector of this vector.
	-- @return (Vec2) The perpendicular vector.
	perp: function(self: Vec2): Vec2

	-- Clamps the vector to a range between two other vectors.
	-- @param from (Vec2) The lower bound of the range.
	-- @param to (Vec2) The upper bound of the range.
	-- @return (Vec2) The clamped vector.
	clamp: function(self: Vec2, from: Vec2, to: Vec2): Vec2

	-- Gets the dot product of two vectors.
	-- @param other (Vec2) The other vector to calculate the dot product with.
	-- @return (number) The dot product of the two vectors.
	dot: function(self: Vec2, other: Vec2): number

	-- Adds two vectors together.
	-- @param other (Vec2) The other vector to add.
	-- @return (Vec2) The sum of the two vectors.
	add: function(self: Vec2, other: Vec2): Vec2

	-- Subtracts one vector from another.
	-- @param other (Vec2) The vector to subtract.
	-- @return (Vec2) The difference between the two vectors.
	sub: function(self: Vec2, other: Vec2): Vec2

	-- Multiplies two vectors component-wise.
	-- @param other (Vec2) The other vector to multiply by.
	-- @return (Vec2) The result of multiplying the two vectors component-wise.
	mul: function(self: Vec2, other: Vec2): Vec2

	-- Multiplies a vector by a scalar.
	-- @param other (Vec2) The scalar to multiply by, represented by a number.
	-- @return (Vec2) The result of multiplying the vector by the scalar.
	mul: function(self: Vec2, other: number): Vec2

	-- Multiplies a vector by a Size object.
	-- @param other (Size) The Size object to multiply by.
	-- @return (Vec2) The result of multiplying the vector by the Size object.
	-- @usage local halfVec = vec * Size(0.5, 0.5)
	mul: function(self: Vec2, other: Dora.Size.Type): Vec2

	-- Divide a vector by a scalar.
	-- @param other (number) The scalar to divide by, represented by a number.
	-- @return (Vec2) The result of dividing the vector by the scalar.
	div: function(self: Vec2, other: number): Vec2

	-- Compare two vectors for equality.
	-- @param other (Vec2) The other vector to compare to.
	-- @return (boolean) Whether or not the two vectors are equal.
	equals: function(self: Vec2, other: Vec2): boolean

	-- Adds two vectors together.
	-- @param other (Vec2) The other vector to add.
	-- @return (Vec2) The sum of the two vectors.
	metamethod __add: function(self: Vec2, other: Vec2): Vec2

	-- Subtracts one vector from another.
	-- @param other (Vec2) The vector to subtract.
	-- @return (Vec2) The difference between the two vectors.
	metamethod __sub: function(self: Vec2, other: Vec2): Vec2

	-- Multiplies two vectors component-wise.
	-- @param other (Vec2) The other vector to multiply by.
	-- @return (Vec2) The result of multiplying the two vectors component-wise.
	metamethod __mul: function(self: Vec2, other: Vec2): Vec2

	-- Multiplies a vector by a scalar.
	-- @param other (Vec2) The scalar to multiply by, represented by a number.
	-- @return (Vec2) The result of multiplying the vector by the scalar.
	metamethod __mul: function(self: Vec2, other: number): Vec2

	-- Multiplies a vector by a Size object.
	-- @param other (Size) The Size object to multiply by.
	-- @return (Vec2) The result of multiplying the vector by the Size object.
	-- @usage local halfVec = vec * Size(0.5, 0.5)
	metamethod __mul: function(self: Vec2, other: Dora.Size.Type): Vec2

	-- Divide a vector by a scalar.
	-- @param other (number) The scalar to divide by, represented by a number.
	-- @return (Vec2) The result of dividing the vector by the scalar.
	metamethod __div: function(self: Vec2, other: number): Vec2

	-- Compare two vectors for equality.
	-- @param other (Vec2) The other vector to compare to.
	-- @return (boolean) Whether or not the two vectors are equal.
	metamethod __eq: function(self: Vec2, other: Vec2): boolean
end

return Vec2
