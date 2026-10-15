local type BodyDef3D = require("BodyDef3DType")

local record BodyDef3DClass
	type Type = BodyDef3D
	metamethod __call: function(self: BodyDef3DClass): BodyDef3D
end

local bodyDef3DClass: BodyDef3DClass
return bodyDef3DClass
