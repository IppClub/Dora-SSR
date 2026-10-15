local Object = require("Object").Type
local Node3D = require("Node3D").Type
local Vec3 = require("Vec3").Type
local type PhysicsWorld3D = require("PhysicsWorld3DType")

-- A virtual capsule character controller owned by a PhysicsWorld3D.
local record CharacterController3D
	embed Object
	const node: Node3D | nil
	const world: PhysicsWorld3D | nil
	desiredVelocity: Vec3
	const velocity: Vec3
	const groundNormal: Vec3
	const grounded: boolean
	collisionLayer: integer
	collisionMask: integer
	jump: function(self: CharacterController3D, speed: number)
	destroy: function(self: CharacterController3D)
end

return CharacterController3D
