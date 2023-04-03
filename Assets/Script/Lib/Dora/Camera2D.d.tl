local Camera = require("Camera").Type
local Vec2 = require("Vec2").Type

-- A class for 2D camera object in the game engine.
local record Camera2D

	-- Inherit from `Camera`
	embed Camera

	-- The rotation angle of the camera in degrees.
	rotation: number

	-- The factor by which to zoom the camera. If set to 1.0, the view is normal sized. If set to 2.0, items will appear double in size.
	zoom: number

	-- The position of the camera in the game world.
	position: Vec2
end

-- A class for creating Camera2D objects.
local record Camera2DClass
	type Type = Camera2D

	-- Creates a new Camera2D object with the given name.
	-- @param name (string) The name of the Camera2D object. Defaults to an empty string.
	-- @return (Camera2D) A new instance of the Camera2D object.
	metamethod __call: function(
		self: Camera2DClass,
		name?: string --[[""]]
	): Camera2D
end

local camera2DClass: Camera2DClass
return camera2DClass
