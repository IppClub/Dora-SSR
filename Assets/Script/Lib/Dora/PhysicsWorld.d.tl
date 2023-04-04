local type PhysicsWorld = require("PhysicsWorldType")

-- A class for creating PhysicsWorld objects.
local record PhysicsWorldClass
	type Type = PhysicsWorld

	-- A factor used for converting physics engine meters value to pixel value.
	-- Default 100.0 is a good value since the physics engine can well simulate real life objects
	-- between 0.1 to 10 meters. Use value 100.0 we can simulate game objects
	-- between 10 to 1000 pixels that suite most games.
	-- You can change this value before any physics body creation.
	scaleFactor: number

	-- Creates a new "PhysicsWorld" object.
	-- @return (PhysicsWorld) The new "PhysicsWorld" object.
	metamethod __call: function(self: PhysicsWorldClass): PhysicsWorld
end

local physicsWorldClass: PhysicsWorldClass
return physicsWorldClass
