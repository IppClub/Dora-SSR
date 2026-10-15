local Object = require("Object").Type
local Vec3 = require("Vec3").Type

-- A reusable 3D collision fixture definition.
local record FixtureDef3D
	embed Object
	const built: boolean
	addChild: function(self: FixtureDef3D, fixture: FixtureDef3D, position: Vec3, angles?: Vec3): boolean
	build: function(self: FixtureDef3D): boolean
end

return FixtureDef3D
