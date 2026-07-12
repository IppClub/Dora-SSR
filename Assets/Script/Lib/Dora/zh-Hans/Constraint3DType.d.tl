local Object = require("Object").Type
local type PhysicsWorld3D = require("PhysicsWorld3DType")
local type Body3D = require("Body3DType")

-- 由 PhysicsWorld3D 持有的双刚体约束。
local record Constraint3D
	embed Object

	-- 所属物理世界。约束销毁后为 nil。
	const world: PhysicsWorld3D | nil
	-- 第一端刚体。约束销毁后为 nil。
	const firstBody: Body3D | nil
	-- 第二端刚体。约束销毁后为 nil。
	const secondBody: Body3D | nil

	-- 从物理世界移除约束并将对象置空。
	destroy: function(self: Constraint3D)
end

return Constraint3D
