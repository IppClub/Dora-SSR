local ContainerItem = require("ContainerItemType")
local Data = require("Platformer.Data")

-- 用于定义游戏子弹的对象如何与其他游戏对象碰撞的类。
local record TargetAllow
	embed ContainerItem

	-- 子弹对象是否可以与地形对象发生碰撞。
	terrainAllowed: boolean

	-- 允许或禁止子弹对象与游戏对象或单位碰撞。
	-- @param relation (Data.Relation) 子弹对象与其他游戏对象或游戏单位之间的关系。
	-- @param allow (boolean) 是否允许子弹对象进行碰撞。
	allow: function(self: TargetAllow, relation: Data.Relation, allow: boolean)

	-- 获取子弹对象是否允许与游戏对象或游戏单位碰撞。
	-- @param relation (Data.Relation) 子弹对象与其他游戏对象或游戏单位之间的关系。
	-- @return (boolean) 子弹对象是否允许发生碰撞。
	isAllow: function(self: TargetAllow, relation: Data.Relation): boolean

	-- 获取子弹对象是否允许与地形对象发生碰撞的参数值。
	-- @return (integer) 子弹对象是否允许与地形对象发生碰撞的参数值。
	toValue: function(): integer
end

-- @usage
-- local TargetAllow = require("TargetAllow")
-- local targetAllow = TargetAllow()
-- targetAllow.terrainAllowed = true
-- targetAllow:allow("Enemy", true)
local record TargetAllowClass
	type Type = TargetAllow
	metamethod __call: function(self: TargetAllowClass): TargetAllow
end

local targetAllowClass: TargetAllowClass
return targetAllowClass
