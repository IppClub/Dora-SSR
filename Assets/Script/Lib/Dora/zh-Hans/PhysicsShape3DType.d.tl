local Object = require("Object").Type
local Vec3 = require("Vec3").Type

-- 可复用的不可变 Jolt 碰撞形状，或尚未冻结的复合形状构建器。
local record PhysicsShape3D
	embed Object

	-- 形状是否已冻结并可用于创建刚体。
	const built: boolean

	-- 在 build() 前添加位于复合形状局部空间中的子形状。
	addChild: function(self: PhysicsShape3D, shape: PhysicsShape3D, position: Vec3, eulerAngles?: Vec3): boolean

	-- 冻结一个非空复合形状。
	build: function(self: PhysicsShape3D): boolean
end

return PhysicsShape3D
