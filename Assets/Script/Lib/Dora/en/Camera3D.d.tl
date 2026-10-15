local Camera = require("Camera").Type
local Vec3 = require("Vec3").Type

-- A class for 3D camera object in the game engine.
local record Camera3D

	-- Inherits from `Camera`.
	embed Camera

	-- The camera position.
	position: Vec3

	-- The camera target point.
	target: Vec3

	-- The camera up vector.
	up: Vec3

	-- Sets the camera position, target and up vector.
	-- @param position (Vec3) The camera position.
	-- @param target (Vec3) The camera target point.
	-- @param up (Vec3) [optional] The camera up vector. Defaults to Vec3(0, 1, 0).
	lookAt: function(self: Camera3D, position: Vec3, target: Vec3, up?: Vec3)
end

local record Camera3DClass
	type Type = Camera3D

	-- Creates a new Camera3D object with the given name.
	-- @param name (string) [optional] The name of the Camera3D object.
	-- @return (Camera3D) A new Camera3D object.
	metamethod __call: function(self: Camera3DClass, name?: string): Camera3D
end

local camera3DClass: Camera3DClass
return camera3DClass
