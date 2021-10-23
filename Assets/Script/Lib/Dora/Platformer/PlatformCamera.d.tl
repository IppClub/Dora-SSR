local Camera = require("Camera").Type
local Vec2 = require("Vec2").Type
local Rect = require("Rect").Type
local Node = require("Node").Type
local record PlatformCamera
	embed Camera
	position: Vec2
	rotation: number
	zoom: number
	boundary: Rect
	followRatio: Vec2
	followTarget: Node
end
local record PlatformCameraClass
	type Type = PlatformCamera
	metamethod __call: function(
		cls: PlatformCameraClass,
		name?: string --[[""]]
	): PlatformCamera
end
print(PlatformCamera.position)
print(PlatformCamera.boundary)
print(PlatformCamera.followRatio)
print(PlatformCamera.followTarget)
local platformCameraClass: PlatformCameraClass
return platformCameraClass
