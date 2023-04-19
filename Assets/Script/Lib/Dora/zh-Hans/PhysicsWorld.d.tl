local type PhysicsWorld = require("PhysicsWorldType")

-- 用于创建物理世界对象的类。
local record PhysicsWorldClass
	type Type = PhysicsWorld

	-- 用于将物理引擎的米制单位值转换为像素单位的系数。
	-- 默认值 100.0 是一个比较适合的值，因为物理引擎可以很好地模拟现实生活中，大小在 0.1 到 10 米之间的物体。使用值 100.0 可以模拟映射到大小在 10 到 1000 像素之间的游戏对象，可以适用于大多数游戏的游戏对象。
	-- 可以在创建任何物理体之前更改此值，使其生效。
	scaleFactor: number

	-- 创建一个新的物理世界对象。
	-- @return (PhysicsWorld) 新的物理世界对象。
	metamethod __call: function(self: PhysicsWorldClass): PhysicsWorld
end

local physicsWorldClass: PhysicsWorldClass
return physicsWorldClass
