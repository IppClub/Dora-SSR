local Object = require("Object").Type

-- A class for Camera object in the game engine.
local record Camera

	-- Inherit from `Object`
	embed Object

	-- The name of the Camera.
	const name: string
end

local record CameraClass
	type Type = Camera
end

local cameraClass: CameraClass
return cameraClass
