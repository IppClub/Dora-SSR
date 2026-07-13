local Node3D = require("Node3D").Type
local Vec3 = require("Vec3").Type
local type PhysicsWorld3D = require("PhysicsWorld3DType")
local type BodyDef3D = require("BodyDef3DType")

-- A 3D rigid body node owned by a PhysicsWorld3D.
local record Body3D
	embed Node3D

	const world: PhysicsWorld3D | nil
	const bodyDef: BodyDef3D
	const type: integer
	linearVelocity: Vec3
	angularVelocity: Vec3
	collisionLayer: integer
	collisionMask: integer
	sensor: boolean

	applyForce: function(self: Body3D, force: Vec3)
	applyLinearImpulse: function(self: Body3D, impulse: Vec3)
	onContactEnter: function(self: Body3D, handler: function(other: Body3D, point: Vec3, normal: Vec3))
	onContactStay: function(self: Body3D, handler: function(other: Body3D, point: Vec3, normal: Vec3))
	onContactExit: function(self: Body3D, handler: function(other: Body3D, point: Vec3, normal: Vec3))
end

return Body3D
