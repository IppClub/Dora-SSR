local Node3D = require("Node3D").Type
local Color3 = require("Color3").Type

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
	-- 以阴影贴图 texel 为单位的阴影过滤半径。设为零会关闭过滤。
	shadowSoftness: number
end

local record DirectionalLight3DClass
	type Type = DirectionalLight3D
	metamethod __call: function(self: DirectionalLight3DClass): DirectionalLight3D
end

local directionalLight3DClass: DirectionalLight3DClass
return directionalLight3DClass
