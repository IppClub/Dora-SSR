local Node3D = require("Node3D").Type

-- Class used for rendering a glTF 3D model.
local record Model3D

	-- Inherits from `Node3D`.
	embed Node3D

	-- The playback speed multiplier of the current animation.
	speed: number

	-- The duration of the current animation in seconds.
	const duration: number

	-- The elapsed playback time of the current animation in seconds.
	const elapsed: number

	-- Whether an animation is currently playing.
	const playing: boolean

	-- Whether the current animation is paused.
	const paused: boolean

	-- Plays an animation by name.
	-- @param name (string) [optional] The animation name. Uses the default animation when omitted.
	-- @param loop (boolean) [optional] Whether the animation should loop. Default is false.
	-- @return (number) The animation duration in seconds, or 0 when not found.
	play: function(self: Model3D, name?: string, loop?: boolean --[[false]]): number

	-- Stops the current animation.
	stop: function(self: Model3D)

	-- Pauses the current animation.
	pause: function(self: Model3D)

	-- Resumes the paused animation.
	resume: function(self: Model3D)
end

local record Model3DClass
	type Type = Model3D

	-- Creates a new Model3D object from a model file path.
	-- @param path (string) The model file path.
	-- @return (Model3D) A new Model3D object, or nil when loading fails.
	metamethod __call: function(self: Model3DClass, path: string): Model3D | nil
end

local model3DClass: Model3DClass
return model3DClass
