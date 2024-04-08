local Object = require("Object").Type
local Entity = require("Entity").Type

-- ECS游戏系统中给实体分组的类。
local record Group

	-- 继承自`Object`。
	embed Object

	-- 实体组中实体的数量。
	const count: integer

	-- 实体组中的最后一个实体，如果实体组为空，则为nil。
	const first: Entity

	-- 对实体组中的每个实体调用一个函数。
	-- @param func (function) 对每个实体要调用的函数。
	-- 在函数内部返回true可停止迭代。
	-- @return (boolean) 如果所有实体都被处理，则为false，如果迭代被中断，则为true。
	each: function(self: Group, func: function(Entity): boolean): boolean

	-- 查找满足测试函数的第一个实体。
	-- @param func (function) 用于测试每个实体的函数，如果参数传入的实体为查找目标则应返回true，否则返回false。
	-- @return (Entity) 满足测试函数的第一个实体，如果没有找到，则返回nil。
	find: function(self: Group, func: function(Entity): boolean): Entity

	-- 监视实体组中实体的更改，每当添加或更改实体的属性（组件）时调用一个监测函数。
	-- @param func (function) 添加或更改实体时要调用的监测函数。返回 true 以停止监测。
	-- @return (Group) 当前的实体组本身，用于方法级连调用。
	watch: function(self: Group, func: function(Entity): boolean): Group
end

-- 用于创建实体组对象的类。
local record GroupClass
	type Type = Group

	-- 用于创建一个新的实体组的元方法。
	-- @param components ({string}) 列出要包含在实体组中的属性（组件）的名称的表格。
	-- @return (Group) 新的实体组。
	metamethod __call: function(self: GroupClass, componemts: {string}): Group
end

local groupClass: GroupClass
return groupClass
