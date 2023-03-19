local Node = require("Node").Type
local record Particle
	embed Node
	const active: boolean
	start: function(self: Particle)
	stop: function(self: Particle)
end
local record __SLOT__
	-- Particle:start
	["Finished"]: function()
end
local record ParticleClass
	type Type = Particle
	metamethod __call: function(self: ParticleClass, filename: string): Particle
end
local particleClass: ParticleClass
return particleClass
