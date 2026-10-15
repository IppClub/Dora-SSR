local Node = require("Node").Type
local Vec2 = require("Vec2").Type

-- A base class for an animation model system.
local record Playable

	-- Inherits from `Node`.
	embed Node

	-- The look of the animation.
	look: string

	-- The play speed of the animation.
	speed: number

	-- The recovery time of the animation, in seconds.
	-- Used for doing transitions from one animation to another animation.
	recovery: number

	-- Whether the animation is flipped horizontally.
	fliped: boolean

	-- The current playing animation name.
	const current: string

	-- The last completed animation name.
	const lastCompleted: string

	-- Get a key point on the animation model by its name.
	-- In the Model animation system, key points are specific points set on the model. In DragonBone, key points are the positions of the armature. In Spine2D, key points are the positions of the point attachments.
	-- @param name (string) The name of the key point to get.
	-- @return (Vec2) The key point value as a Vec2.
	getKey: function(self: Playable, name: string): Vec2

	-- Plays an animation from the model.
	-- @param name (string) The name of the animation to play.
	-- @param loop (boolean) [optional] Whether to loop the animation or not (default is false).
	-- @return (number) The duration of the animation in seconds.
	play: function(
		self: Playable,
		name: string,
		loop?: boolean --[[false]]
	): number

	-- Stops the currently playing animation.
	stop: function(self: Playable)

	-- Attaches a child node to a slot on the animation model.
	-- @param name (string) The name of the slot to set.
	-- @param item (Node) The node to set the slot to.
	setSlot: function(self: Playable, name: string, item: Node)

	-- Gets the child node attached to the animation model.
	-- @param name (string) The name of the slot to get.
	-- @return (Node|nil) The node in the slot, or nil if there is no node in the slot.
	getSlot: function(self: Playable, name: string): Node | nil

	-- Registers a callback for when an animation has ended.
	-- @param callback (function) The callback function for when the animation has ended.
	-- 	@param animationName (string) The name of the animation that ended.
	-- 	@param target (Playable) The Playable instance that the animation was played on.
	onAnimationEnd: function(self: Playable, callback: function(animationName: string, target: Playable))
end

-- This is just a demonstration record showing signal slot events that are emiting by the Playable animation systems.
local record __SLOT__

	-- Triggers after an animation has ended on a Playable instance.
	-- @param animationName (string) The name of the animation that ended.
	-- @param target (Playable) The Playable instance that the animation was played on.
	["AnimationEnd"]: function(animationName: string, target: Playable)
end

-- A class for creating instances of the 'Playable' record.
local record PlayableClass
	type Type = Playable

	-- Creates a new instance of 'Playable' from the specified animation file.
	-- @param filename (string) the filename of the animation file to load.
	-- Supports DragonBone, Spine2D and Dora Model files.
	-- Should be one of the formats below:
	-- 	"model:" + modelFile
	-- 	"spine:" + spineStr
	-- 	"bone:" + dragonBoneStr
	-- @return (Playable) a new instance of 'Playable'. If the file could not be loaded, then nil is returned.
	metamethod __call: function(self: PlayableClass, filename: string): Playable | nil
end

local playableClass: PlayableClass
return playableClass
