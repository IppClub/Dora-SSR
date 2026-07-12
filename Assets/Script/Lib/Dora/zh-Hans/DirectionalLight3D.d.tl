local Node3D = require("Node3D").Type
local Color3 = require("Color3")

-- 方向由世界旋转决定的方向光。
local record DirectionalLight3D
	embed Node3D

	-- sRGB 空间中的灯光颜色。
	color: Color3

	-- 灯光强度。
	intensity: number
	castShadow: boolean
	shadowBias: number
	shadowNormalBias: number
end

local record DirectionalLight3DClass
	type Type = DirectionalLight3D
	metamethod __call: function(self: DirectionalLight3DClass): DirectionalLight3D
end

local directionalLight3DClass: DirectionalLight3DClass
return directionalLight3DClass
