local Camera = require("Camera").Type
local Vec2 = require("Vec2").Type
local record OthoCamera
	embed Camera
	position: Vec2
end
local record OthoCameraClass
	type Type = OthoCamera
	metamethod __call: function(cls: OthoCameraClass, name: string --[[""]]): OthoCamera
end
print(OthoCamera.position)
local othoCameraClass: OthoCameraClass
return othoCameraClass
