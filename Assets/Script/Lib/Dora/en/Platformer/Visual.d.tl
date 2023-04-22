local Node = require("Node").Type

-- A class to represent a visual effect object like Particle, Frame Animation or just a Sprite.
local record Visual

	-- Inherits from `Node`.
	embed Node

	-- Whether the visual effect is currently playing or not.
	const playing: boolean

	-- Starts playing the visual effect.
	start: function(self: Visual)

	-- Stops playing the visual effect.
	stop: function(self: Visual)

	-- Automatically removes the visual effect from the game world when it finishes playing.
	-- @return (Visual) The same "Visual" object that was passed in as a parameter.
	autoRemove: function(self: Visual): Visual
end

-- A class for creating "Visual" objects.
local record VisualClass
	type Type = Visual

	-- Creates a new "Visual" object with the specified name.
	-- @param name (string) The name of the new "Visual" object.
	-- Could be a particle file, a frame animation file or a image file.
	-- @return (Visual) The new "Visual" object.
	metamethod __call: function(self: VisualClass, name: string): Visual
end

local visualClass: VisualClass
return visualClass
