local Node = require("Node").Type
local Vec2 = require("Vec2").Type

-- A class for playing Effekseer effects.
local record EffekNode

	-- Inherits from `Node`.
	embed Node

	-- Plays an Effekseer effect.
	-- @param filename (string) The filename of the effect.
	-- @param pos (Vec2) [optional] The XY position to play the effect at.
	-- @param z (number) [optional] The Z position to play the effect at.
	-- @return (integer) The handle of the effect.
	play: function(self: EffekNode, filename: string, pos?: Vec2, z?: number): integer

	-- Stops an Effekseer effect.
	-- @param handle (integer) The handle of the effect.
	stop: function(self: EffekNode, handle: integer)

	-- Registers a callback for when an Effekseer effect has ended.
	-- @param callback (function) The callback function for when the effect has ended.
	-- 	@param handle (integer) The handle of the effect that has ended.
	onEffekEnd: function(self: EffekNode, callback: function(handle: integer))
end

-- A class for creating EffekNode objects.
local record EffekNodeClass
	type Type = EffekNode

	-- Creates a new EffekNode object.
	-- @return (EffekNode) The new EffekNode object.
	metamethod __call: function(self: EffekNodeClass): EffekNode
end

-- Signal slot that can be connected to an EffekNode object.
-- This is just a demonstration record showing the signal slot names and callbacks.
-- @usage
-- -- you can register for these events using codes
-- local effekNode = EffekNode()
-- local laserHandle = effekNode.play("Laser.efk", Vec2.zero)
-- effekNode:slot("EffekEnd", function(handle: integer)
-- 	if handle == laserHandle then
-- 		print("The laser effect has ended")
-- 	end
-- end)
local record __SLOT__

	-- Triggers when an Effekseer effect has ended.
	-- @param handle (integer) The handle of the effect that has ended.
	["EffekEnd"]: function(handle: integer)
end

local effekNodeClass: EffekNodeClass
return effekNodeClass
