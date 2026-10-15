local Vec3 = require("Vec3").Type
local type FixtureDef3D = require("FixtureDef3DType")

local record FixtureDef3DClass
	type Type = FixtureDef3D
	box: function(self: FixtureDef3DClass, halfExtent: Vec3): FixtureDef3D
	sphere: function(self: FixtureDef3DClass, radius: number): FixtureDef3D
	capsule: function(self: FixtureDef3DClass, halfHeight: number, radius: number): FixtureDef3D
	compound: function(self: FixtureDef3DClass): FixtureDef3D
	loadMeshAsync: function(self: FixtureDef3DClass, filename: string, handler: function(fixture: FixtureDef3D))
	loadConvexHullAsync: function(self: FixtureDef3DClass, filename: string, handler: function(fixture: FixtureDef3D))
end

local fixtureDef3DClass: FixtureDef3DClass
return fixtureDef3DClass
