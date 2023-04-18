local Object = require("Object").Type
local PhysicsWorld = require("PhysicsWorld").Type

-- 用于连接物理体的关节类。
local record Joint

	-- 继承自"Object".
	embed Object

	-- 所属的物理世界。
	const world: PhysicsWorld

	-- 将关节从物理世界中移除。
	destroy: function(self: Joint)
end

return Joint
