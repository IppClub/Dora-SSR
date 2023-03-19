local Camera = require("Camera").Type
local Vec2 = require("Vec2").Type
local record CameraOtho
	embed Camera
	position: Vec2
end
local record CameraOthoClass
	type Type = CameraOtho
	metamethod __call: function(
		self: CameraOthoClass,
		name?: string --[[""]]
	): CameraOtho
end
local cameraOthoClass: CameraOthoClass
return cameraOthoClass
