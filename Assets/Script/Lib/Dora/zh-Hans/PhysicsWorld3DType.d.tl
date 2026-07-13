local Node = require("Node").Type
local Node3D = require("Node3D").Type
local Vec3 = require("Vec3").Type
local type Body3D = require("Body3DType")
local type CharacterController3D = require("CharacterController3DType")

-- A fixed-step 3D physics world backed by Jolt Physics.
local record PhysicsWorld3D
	embed Node
	gravity: Vec3
	createCharacter: function(self: PhysicsWorld3D, node: Node3D, halfHeight: number, radius: number, maxSlopeAngle?: number, stepHeight?: number): CharacterController3D
	destroyCharacter: function(self: PhysicsWorld3D, character: CharacterController3D)
	raycast: function(self: PhysicsWorld3D, start: Vec3, stop: Vec3, handler: function(body: Body3D, point: Vec3, normal: Vec3): boolean): boolean
	querySphere: function(self: PhysicsWorld3D, center: Vec3, radius: number, handler: function(body: Body3D): boolean): boolean
end

return PhysicsWorld3D
