local type PhysicsWorld = require("PhysicsWorldType")
local record PhysicsWorldClass
	type Type = PhysicsWorld
	b2Factor: number
	metamethod __call: function(self: PhysicsWorldClass): PhysicsWorld
end
local physicsWorldClass: PhysicsWorldClass
return physicsWorldClass
