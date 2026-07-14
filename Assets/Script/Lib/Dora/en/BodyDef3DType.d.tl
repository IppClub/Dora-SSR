local Vec3 = require("Vec3").Type
local type FixtureDef3D = require("FixtureDef3DType")

-- Reusable physical properties and fixtures used to create Body3D nodes.
local record BodyDef3D
	type: integer
	collisionLayer: integer
	collisionMask: integer
	sensor: boolean
	attach: function(self: BodyDef3D, fixture: FixtureDef3D, position?: Vec3, angles?: Vec3): boolean
end

return BodyDef3D
