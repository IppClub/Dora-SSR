local Node3D = require("Node3D").Type
local Vec3 = require("Vec3").Type
local type Material3D = require("Material3DType")

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

	-- The number of animation clips in this model.
	const animationCount: integer

	-- The number of per-instance material slots.
	const materialCount: integer

	-- Gets an animation clip name by zero-based index.
	getAnimationName: function(self: Model3D, index: integer): string

	-- Checks whether an imported glTF node with the given name exists.
	hasNode: function(self: Model3D, name: string): boolean

	-- Attaches a user-owned Node3D below an imported node.
	attachToNode: function(self: Model3D, name: string, child: Node3D): boolean

	-- Gets the current model-space bounds minimum.
	getLocalBoundsMin: function(self: Model3D): Vec3

	-- Gets the current model-space bounds maximum.
	getLocalBoundsMax: function(self: Model3D): Vec3

	-- Gets the current world-space bounds minimum.
	getWorldBoundsMin: function(self: Model3D): Vec3

	-- Gets the current world-space bounds maximum.
	getWorldBoundsMax: function(self: Model3D): Vec3

	-- Gets a per-instance material slot by zero-based index.
	getMaterial: function(self: Model3D, index: integer): Material3D | nil

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
