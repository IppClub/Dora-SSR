local Node = require("Node").Type
local Node3D = require("Node3D").Type
local Vec3 = require("Vec3").Type
local type Body3D = require("Body3DType")
local type CharacterController3D = require("CharacterController3DType")
local type PhysicsShape3D = require("PhysicsShape3DType")
local type Constraint3D = require("Constraint3DType")

-- 使用 Jolt Physics、按固定时间步更新的 3D 物理世界。
local record PhysicsWorld3D
	embed Node

	gravity: Vec3

	createBox: function(self: PhysicsWorld3D, node: Node3D, halfExtent: Vec3, bodyType?: integer --[[2]]): Body3D
	createSphere: function(self: PhysicsWorld3D, node: Node3D, radius: number, bodyType?: integer --[[2]]): Body3D
	createCapsule: function(self: PhysicsWorld3D, node: Node3D, halfHeight: number, radius: number, bodyType?: integer --[[2]]): Body3D
	createBody: function(self: PhysicsWorld3D, node: Node3D, shape: PhysicsShape3D, bodyType?: integer --[[2]]): Body3D
	createCharacter: function(self: PhysicsWorld3D, node: Node3D, halfHeight: number, radius: number, maxSlopeAngle?: number --[[50.0]], stepHeight?: number --[[0.4]]): CharacterController3D
	createFixedConstraint: function(self: PhysicsWorld3D, firstBody: Body3D, secondBody: Body3D, anchor: Vec3): Constraint3D
	createDistanceConstraint: function(self: PhysicsWorld3D, firstBody: Body3D, secondBody: Body3D, firstAnchor: Vec3, secondAnchor: Vec3, minDistance: number, maxDistance: number): Constraint3D
	createHingeConstraint: function(self: PhysicsWorld3D, firstBody: Body3D, secondBody: Body3D, anchor: Vec3, axis: Vec3, minAngle: number, maxAngle: number): Constraint3D
	destroyBody: function(self: PhysicsWorld3D, body: Body3D)
	destroyCharacter: function(self: PhysicsWorld3D, character: CharacterController3D)
	destroyConstraint: function(self: PhysicsWorld3D, constraint: Constraint3D)

	-- Casts a ray and calls the handler for the nearest hit.
	raycast: function(
		self: PhysicsWorld3D,
		origin: Vec3,
		direction: Vec3,
		distance: number,
		handler: function(body: Body3D, point: Vec3, normal: Vec3, hitDistance: number): boolean
	): boolean

	-- Visits overlapping bodies until the handler returns true.
	overlapSphere: function(
		self: PhysicsWorld3D,
		center: Vec3,
		radius: number,
		handler: function(body: Body3D): boolean
	): boolean
end

return PhysicsWorld3D
