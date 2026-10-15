local Camera = require("Camera").Type
local Vec3 = require("Vec3").Type

-- 游戏引擎中的 3D 相机对象类。
local record Camera3D

	-- 继承自 `Camera`。
	embed Camera

	-- 相机位置。
	position: Vec3

	-- 相机目标点。
	target: Vec3

	-- 相机向上方向。
	up: Vec3

	-- 设置相机位置、目标点和向上方向。
	-- @param position (Vec3) 相机位置。
	-- @param target (Vec3) 相机目标点。
	-- @param up (Vec3) [可选] 相机向上方向。默认是 Vec3(0, 1, 0)。
	lookAt: function(self: Camera3D, position: Vec3, target: Vec3, up?: Vec3)
end

local record Camera3DClass
	type Type = Camera3D

	-- 使用给定名称创建新的 3D 相机对象。
	-- @param name (string) [可选] 3D 相机对象的名称。
	-- @return (Camera3D) 新的 Camera3D 对象。
	metamethod __call: function(self: Camera3DClass, name?: string): Camera3D
end

local camera3DClass: Camera3DClass
return camera3DClass
