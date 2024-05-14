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
end

-- A class for creating EffekNode objects.
local record EffekNodeClass
	type Type = EffekNode

	-- Creates a new EffekNode object.
	-- @return (EffekNode) The new EffekNode object.
	metamethod __call: function(self: EffekNodeClass): EffekNode
end

local effekNodeClass: EffekNodeClass
return effekNodeClass
