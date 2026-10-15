local Vec3 = require("Vec3").Type
local type Body3D = require("Body3DType")
local type Constraint3D = require("Constraint3DType")

local record Constraint3DClass
	type Type = Constraint3D
	fixed: function(self: Constraint3DClass, firstBody: Body3D, secondBody: Body3D, anchor: Vec3): Constraint3D
	distance: function(self: Constraint3DClass, firstBody: Body3D, secondBody: Body3D, firstAnchor: Vec3, secondAnchor: Vec3, minDistance: number, maxDistance: number): Constraint3D
	hinge: function(self: Constraint3DClass, firstBody: Body3D, secondBody: Body3D, anchor: Vec3, axis: Vec3, minAngle?: number, maxAngle?: number): Constraint3D
end

local constraint3DClass: Constraint3DClass
return constraint3DClass
