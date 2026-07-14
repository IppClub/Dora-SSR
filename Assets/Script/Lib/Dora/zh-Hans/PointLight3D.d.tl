local Node3D = require("Node3D").Type
local Color3 = require("Color3")

-- 位置由世界变换决定的点光源。
local record PointLight3D
	embed Node3D

	-- sRGB 空间中的灯光颜色。
	color: Color3

	-- 灯光强度。
	intensity: number

	-- 灯光的最大有效范围。
	range: number
end

local record PointLight3DClass
	type Type = PointLight3D
	metamethod __call: function(self: PointLight3DClass): PointLight3D
end

local pointLight3DClass: PointLight3DClass
return pointLight3DClass
