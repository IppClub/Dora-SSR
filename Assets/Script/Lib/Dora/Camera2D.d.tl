local Camera = require("Camera").Type
local Vec2 = require("Vec2").Type
local record Camera2D
	embed Camera
	rotation: number
	zoom: number
	position: Vec2
end
local record Camera2DClass
	type Type = Camera2D
	metamethod __call: function(cls: Camera2DClass, name: string --[[""]]): Camera2D
end
local camera2DClass: Camera2DClass
return camera2DClass
