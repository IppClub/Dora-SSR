local Object = require("Object").Type
local Node3D = require("Node3D").Type
local Vec3 = require("Vec3").Type
local type PhysicsWorld3D = require("PhysicsWorld3DType")

-- 由 PhysicsWorld3D 持有的 3D 刚体组件。
local record Body3D
	embed Object

	-- The synchronized node. Nil after the body is destroyed.
	const node: Node3D | nil

	-- The owning physics world. Nil after the body is destroyed.
	const world: PhysicsWorld3D | nil

	-- Motion type: 0 static, 1 kinematic, 2 dynamic.
	const type: integer

	-- World-space linear velocity.
	linearVelocity: Vec3

	-- World-space angular velocity in radians per second.
	angularVelocity: Vec3

	-- Collision layer in the range 0 through 31.
	collisionLayer: integer

	-- Bit mask of accepted collision layers.
	collisionMask: integer

	-- Whether contacts generate events without collision response.
	sensor: boolean

	applyForce: function(self: Body3D, force: Vec3)
	applyImpulse: function(self: Body3D, impulse: Vec3)
	onContactEnter: function(self: Body3D, handler: function(other: Body3D, point: Vec3, normal: Vec3))
	onContactStay: function(self: Body3D, handler: function(other: Body3D, point: Vec3, normal: Vec3))
	onContactExit: function(self: Body3D, handler: function(other: Body3D, point: Vec3, normal: Vec3))

	-- Removes the body from its world and turns this into an empty object.
	destroy: function(self: Body3D)
end

return Body3D
