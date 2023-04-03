local Camera = require("Camera").Type
local Vec2 = require("Vec2").Type

-- A class of an orthographic camera object in the game engine.
local record CameraOtho

	-- Inherit from `Camera`.
	embed Camera

	-- The position of the camera in the game world.
	position: Vec2
end

-- A class for creating CameraOtho objects.
local record CameraOthoClass
	type Type = CameraOtho

	-- Creates a new CameraOtho object with the given name.
	-- @param name (string) The name of the CameraOtho object. Defaults to an empty string.
	-- @return (CameraOtho) A new instance of the CameraOtho object.
	metamethod __call: function(
		self: CameraOthoClass,
		name?: string --[[""]]
	): CameraOtho
end

local cameraOthoClass: CameraOthoClass
return cameraOthoClass
