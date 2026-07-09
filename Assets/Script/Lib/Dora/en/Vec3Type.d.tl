local ContainerItem = require("ContainerItemType")

-- A record representing a 3D vector with x, y and z components.
local record Vec3

	-- Inherits from `ContainerItem`.
	embed ContainerItem

	-- The x-component of the vector.
	x: number

	-- The y-component of the vector.
	y: number

	-- The z-component of the vector.
	z: number
end

return Vec3
