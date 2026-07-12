local Vec3 = require("Vec3").Type
local type PhysicsShape3D = require("PhysicsShape3DType")

-- Factory functions for reusable 3D collision shapes.
local record PhysicsShape3DClass
	type Type = PhysicsShape3D

	box: function(self: PhysicsShape3DClass, halfExtent: Vec3): PhysicsShape3D
	sphere: function(self: PhysicsShape3DClass, radius: number): PhysicsShape3D
	capsule: function(self: PhysicsShape3DClass, halfHeight: number, radius: number): PhysicsShape3D
	compound: function(self: PhysicsShape3DClass): PhysicsShape3D
	loadMeshAsync: function(self: PhysicsShape3DClass, filename: string, handler: function(shape: PhysicsShape3D))
	loadConvexHullAsync: function(self: PhysicsShape3DClass, filename: string, handler: function(shape: PhysicsShape3D))
end

local physicsShape3DClass: PhysicsShape3DClass
return physicsShape3DClass
