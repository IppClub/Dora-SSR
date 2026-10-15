local type PhysicsWorld3D = require("PhysicsWorld3DType")

-- 用于创建 PhysicsWorld3D 实例的类对象。
local record PhysicsWorld3DClass
	type Type = PhysicsWorld3D

	-- Motion type constants accepted by body creation methods.
	const Static: integer
	const Kinematic: integer
	const Dynamic: integer

	metamethod __call: function(self: PhysicsWorld3DClass): PhysicsWorld3D
end

local physicsWorld3DClass: PhysicsWorld3DClass
return physicsWorld3DClass
