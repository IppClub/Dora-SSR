local Object = require("Object").Type
local PhysicsWorld = require("PhysicsWorld").Type
local record Joint
	embed Object
	const world: PhysicsWorld
	destroy: function(self: Joint)
end
return Joint
