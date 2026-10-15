local Playable = require("Playable").Type
local Node = require("Node").Type

-- Another implementation of the 'Playable' record.
local record Model

	-- Inherits from `Playable`.
	embed Playable

	-- Whether the animation model will be played in reverse.
	reversed: boolean

	-- The duration of the current animation.
	const duration: number

	-- Whether the animation model is currently playing.
	const playing: boolean

	-- Whether the animation model is currently paused.
	const paused: boolean

	-- Check if an animation exists in the model.
	-- @param name (string) The name of the animation to check.
	-- @return (boolean) Whether the animation exists in the model or not.
	hasAnimation: function(self: Model, name: string): boolean

	-- Pauses the currently playing animation.
	pause: function(self: Model)

	-- Resumes the currently paused animation, or plays a new animation if specified.
	-- @param name (string) [optional] The name of the animation to play.
	-- @param loop (boolean) [optional] Whether to loop the animation or not (default is false).
	resume: function(
		self: Model,
		name?: string,
		loop?: boolean --[[false]]
	)

	-- Resets the current animation to its initial state.
	reset: function(self: Model)

	-- Updates the animation to the specified time, and optionally in reverse.
	-- @param elapsed (number) The time to update to.
	-- @param reversed (boolean) [optional] Whether to play the animation in reverse (default is false).
	updateTo: function(
		self: Model,
		elapsed: number,
		reversed?: boolean --[[false]]
	)

	-- Gets the node with the specified name.
	-- @param name (string) The name of the node to get.
	-- @return (Node) The node with the specified name.
	getNodeByName: function(self: Model, name: string): Node

	-- Calls the specified function for each node in the model, and stops if the function returns false. The nodes can not be added or removed during the iteration.
	-- @param func (function) The function to call for each node.
	-- @return (boolean) Whether the function was called for all nodes or not.
	eachNode: function(self: Model, func: function(Node): boolean): boolean
end

-- A class for creating instances of the 'Model' record.
local record ModelClass
	type Type = Model

	-- A method that returns a new dummy instance of 'Model' that can do nothing.
	-- @return (Model) a new dummy instance of 'Model'.
	dummy: function(self: ModelClass): Model

	-- Gets the clip file from the specified model file.
	-- @param filename (string) The filename of the model file to search.
	-- @return (string) The name of the clip file.
	getClipFile: function(self: ModelClass, filename: string): string

	-- Gets an array of look names from the specified model file.
	-- @param filename (string) The filename of the model file to search.
	-- @return ({string}) An array of look names found in the model file.
	getLooks: function(self: ModelClass, filename: string): {string}

	-- Gets an array of animation names from the specified model file.
	-- @param filename (string) The filename of the model file to search.
	-- @return ({string}) An array of animation names found in the model file.
	getAnimations: function(self: ModelClass, filename: string): {string}

	-- Creates a new instance of 'Model' from the specified model file.
	-- @param filename (string) The filename of the model file to load.
	-- Can be filename with or without extension like: "Model/item" or "Model/item.model".
	-- @return (Model) a new instance of 'Model'.
	metamethod __call: function(self: ModelClass, filename: string): Model
end

local modelClass: ModelClass
return modelClass
