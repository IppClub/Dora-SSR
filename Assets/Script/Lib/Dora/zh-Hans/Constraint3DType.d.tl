local Object = require("Object").Type
local type PhysicsWorld3D = require("PhysicsWorld3DType")
local type Body3D = require("Body3DType")

-- A two-body constraint owned by a PhysicsWorld3D.
local record Constraint3D
	embed Object

	-- The owning world. Nil after the constraint is destroyed.
	const world: PhysicsWorld3D | nil
	-- The first constrained body. Nil after the constraint is destroyed.
	const firstBody: Body3D | nil
	-- The second constrained body. Nil after the constraint is destroyed.
	const secondBody: Body3D | nil

	-- Removes the constraint from its world and turns this into an empty object.
	destroy: function(self: Constraint3D)
end

return Constraint3D
