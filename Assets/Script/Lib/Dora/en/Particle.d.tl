local Node = require("Node").Type

-- Represents a particle system node that emits and animates particles.
local record Particle

	-- Inherits from `Node`.
	embed Node

	-- Whether the particle system is active.
	const active: boolean

	-- Starts emitting particles.
	start: function(self: Particle)

	 -- Stops emitting particles and wait for all active particles to end their lives.
	stop: function(self: Particle)

	-- Registers a callback function for when the particle system ends.
	-- Triggered after a Particle node started a stop action and then all the active particles end their lives.
	-- @param callback (function) The callback function for when the particle system ends.
	onFinished: function(self: Particle, callback: function())
end

-- Signal slot that can be connected to a Particle object.
-- This is just a demonstration record showing the signal slot names and callbacks.
-- @usage
-- -- you can register for these events using codes
-- local particle = Particle("effect.par")
-- particle:start()
-- particle:slot("Finished", function()
-- 	print("The particle system has ended")
-- end)
local record __SLOT__

	-- Triggered after a Particle node started a stop action and then all the active particles end their lives.
	["Finished"]: function()
end

-- A class that can create new Particle objects.
local record ParticleClass
	type Type = Particle

	-- Creates a new Particle object from a particle system file.
	-- @param filename (string) The file path of the particle system file.
	-- @return (Particle) A new Particle object.
	metamethod __call: function(self: ParticleClass, filename: string): Particle
end

local particleClass: ParticleClass
return particleClass
