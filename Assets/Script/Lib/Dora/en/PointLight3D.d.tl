local Node3D = require("Node3D").Type
local Color3 = require("Color3")

-- A point light whose position follows its world transform.
local record PointLight3D
	embed Node3D

	-- The light color in sRGB space.
	color: Color3

	-- The light intensity.
	intensity: number

	-- The maximum effective range of the light.
	range: number
end

local record PointLight3DClass
	type Type = PointLight3D
	metamethod __call: function(self: PointLight3DClass): PointLight3D
end

local pointLight3DClass: PointLight3DClass
return pointLight3DClass
