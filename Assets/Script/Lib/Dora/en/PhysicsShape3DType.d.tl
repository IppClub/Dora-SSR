local Object = require("Object").Type
local Vec3 = require("Vec3").Type

-- A reusable immutable Jolt collision shape or an unfrozen compound builder.
local record PhysicsShape3D
	embed Object

	-- Whether this shape is frozen and can be used to create bodies.
	const built: boolean

	-- Adds a child shape in compound-local space before build().
	addChild: function(self: PhysicsShape3D, shape: PhysicsShape3D, position: Vec3, eulerAngles?: Vec3): boolean

	-- Freezes a non-empty compound shape.
	build: function(self: PhysicsShape3D): boolean
end

return PhysicsShape3D
