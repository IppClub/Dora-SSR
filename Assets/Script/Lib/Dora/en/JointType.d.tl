local Object = require("Object").Type
local PhysicsWorld = require("PhysicsWorld").Type

-- A class that can be used to connect physics bodies together.
local record Joint

	-- Inherits from "Object".
	embed Object

	-- The physics world that the joint belongs to.
	const world: PhysicsWorld

	-- Destroys the joint and removes it from the physics simulation.
	destroy: function(self: Joint)
end

return Joint
