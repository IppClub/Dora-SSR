local Vec3 = require("Vec3").Type
local type Body3D = require("Body3DType")
local type BodyDef3D = require("BodyDef3DType")
local type PhysicsWorld3D = require("PhysicsWorld3DType")

local record Body3DClass
	type Type = Body3D
	metamethod __call: function(self: Body3DClass, bodyDef: BodyDef3D, world: PhysicsWorld3D, position?: Vec3, angles?: Vec3): Body3D
end

local body3DClass: Body3DClass
return body3DClass
