local Camera = require("Camera").Type
local Vec2 = require("Vec2").Type

-- 游戏引擎中的2D相机对象类。
local record Camera2D

	-- 继承自`Camera`。
	embed Camera

	-- 相机旋转角度（以度为单位）。
	rotation: number

	-- 缩放相机的缩放参数。如果设置为1.0，则视野内的物件为正常大小。如果设置为2.0，则物件显示为两倍大小。
	zoom: number

	-- 相机在游戏世界中的位置。
	position: Vec2
end

-- 用于创建2D相机对象的类。
local record Camera2DClass
	type Type = Camera2D

	-- 使用特定的名称创建一个新的2D相机对象。
	-- @param name (string) 2D相机对象的名称。默认为空字符串。
	-- @return (Camera2D) 2D相机对象的新实例。
	metamethod __call: function(
		self: Camera2DClass,
		name?: string --[[""]]
	): Camera2D
end

local camera2DClass: Camera2DClass
return camera2DClass
