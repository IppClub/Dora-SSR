local Node3D = require("Node3D").Type
local Color3 = require("Color3")

-- A directional light whose direction follows its world rotation.
local record DirectionalLight3D
	embed Node3D

	-- The light color in sRGB space.
	color: Color3

	-- The light intensity.
	intensity: number
end

local record DirectionalLight3DClass
	type Type = DirectionalLight3D
	metamethod __call: function(self: DirectionalLight3DClass): DirectionalLight3D
end

local directionalLight3DClass: DirectionalLight3DClass
return directionalLight3DClass
