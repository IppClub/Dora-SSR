local Camera = require("Camera").Type
local Vec2 = require("Vec2").Type

-- 游戏引擎中正交相机对象的类。
local record CameraOtho

	-- 继承自`Camera`。
	embed Camera

	-- 相机在游戏世界中的位置。
	position: Vec2
end

-- 用于创建正交相机对象的类。
local record CameraOthoClass
	type Type = CameraOtho

	-- 使用给定名称创建一个新的正交相机对象。
	-- @param name (string) 正交相机对象的名称。默认为空字符串。
	-- @return (CameraOtho) 正交相机对象的新实例。
	metamethod __call: function(
		self: CameraOthoClass,
		name?: string --[[""]]
	): CameraOtho
end

local cameraOthoClass: CameraOthoClass
return cameraOthoClass
