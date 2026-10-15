local Camera = require("Camera").Type
local Vec2 = require("Vec2").Type
local Rect = require("Rect").Type
local Node = require("Node").Type

-- A platform camera for 2D platformer games that can track a game unit's movement and keep it within the camera's view.
local record PlatformCamera

	-- Inherits from `Object`.
	embed Camera

	-- The camera's position.
	position: Vec2

	-- The camera's rotation in degrees.
	rotation: number

	-- The camera's zoom factor, 1.0 means the normal size, 2.0 mean zoom to doubled size.
	zoom: number

	-- The rectangular area within which the camera is allowed to view.
	boundary: Rect

	-- The ratio at which the camera should move to keep up with the target's position.
	-- For example, set to `Vec2(1.0, 1.0)`, then the camera will keep up to the target's position right away.
	-- Set to Vec2(0.5, 0.5) or smaller value, then the camera will move halfway to the target's position each frame, resulting in a smooth and gradual movement.
	followRatio: Vec2

	-- The offset from the target's position that the camera should follow.
	followOffset: Vec2

	-- The game unit that the camera should track.
	followTarget: Node
end

-- A class that defines how to create instances of PlatformCamera.
local record PlatformCameraClass
	type Type = PlatformCamera

	-- Creates a new instance of PlatformCamera.
	-- @param name (string) [optional] The name of the new instance, default is empty string.
	-- @return (PlatformCamera) The new PlatformCamera instance.
	metamethod __call: function(
		self: PlatformCameraClass,
		name?: string --[[""]]
	): PlatformCamera
end

local platformCameraClass: PlatformCameraClass
return platformCameraClass
