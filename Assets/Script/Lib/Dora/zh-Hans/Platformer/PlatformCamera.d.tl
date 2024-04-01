local Camera = require("Camera").Type
local Vec2 = require("Vec2").Type
local Rect = require("Rect").Type
local Node = require("Node").Type

-- 用于2D平台游戏的相机，可以跟踪游戏单位的移动并保持其在相机视野内。
local record PlatformCamera

	-- 继承自 `Object`.
	embed Camera

	-- 相机的位置。
	position: Vec2

	-- 相机的旋转角度。
	rotation: number

	-- 相机的缩放系数，1.0表示正常大小，2.0表示缩放到两倍大小。
	zoom: number

	-- 相机可见范围的矩形区域。
	boundary: Rect

	-- 相机移动以跟随目标位置的速率。
	-- 例如，设置为`Vec2(1.0, 1.0)`时，相机将立即跟随目标位置。
	-- 设置为 Vec2(0.5, 0.5) 或更小的值时，相机将在每帧中移动到距离目标位置的一半，从而实现更加平滑的跟踪移动效果。
	followRatio: Vec2

	-- 相机跟踪目标位置的偏移量。
	followOffset: Vec2

	-- 相机在跟踪的游戏单位。
	followTarget: Node
end

-- 用于创建2D平台游戏相机实例的类。
local record PlatformCameraClass
	type Type = PlatformCamera

	-- 创建2D平台游戏相机的新实例。
	-- @param name (string) [可选] 新实例的名称，默认为空字符串。
	-- @return (PlatformCamera) 新的2D平台游戏相机实例。
	metamethod __call: function(
		self: PlatformCameraClass,
		name?: string --[[""]]
	): PlatformCamera
end

local platformCameraClass: PlatformCameraClass
return platformCameraClass
