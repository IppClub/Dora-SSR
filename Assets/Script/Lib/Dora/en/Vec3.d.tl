local type Vec3 = require("Vec3Type")

-- A class for creating Vec3 objects.
local record Vec3Class
	type Type = Vec3

	-- Creates a new Vec3 object with the given x, y and z components.
	-- @param x (number) The x-component of the new vector.
	-- @param y (number) The y-component of the new vector.
	-- @param z (number) The z-component of the new vector.
	-- @return (Vec3) The new Vec3 object.
	-- @usage local newVec = Vec3(10, 20, 30)
	metamethod __call: function(
		self: Vec3Class,
		x: number,
		y: number,
		z: number
	): Vec3
end

local vec3Class: Vec3Class
return vec3Class
