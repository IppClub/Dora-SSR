local Object = require("Object").Type
local ContainerItem = require("ContainerItemType")
local type Item = integer | number | boolean | string | ContainerItem

-- ECS游戏系统中的实体类。
local record Entity

	-- 继承自`Object`。
	embed Object

	-- 实体的索引。
	const index: integer

	-- 用于访问实体属性旧值的语法糖。
	-- 旧值是指实体的组件在上次发生更改之前的值。
	-- 不要在代码中保留对它的引用，因为它不是有效的Lua对象。
	const oldValues: {string: Item}

	-- 用于销毁实体及相关组件的函数。
	destroy: function(self: Entity)

	-- 用于设置实体上关联的属性（组件）。
	-- 这个函数将触发`Observer`对象监听的组件变更事件。
	-- @param key (string) 要设置的属性的名称。
	-- @param item (Item) 要将属性设置为的值。
	set: function(self: Entity, key: string, item: Item)

	-- 获取实体属性（组件）的值的函数。
	-- @param key (string) 要获取值的属性（组件）的名称。
	-- @return (Item) 属性（组件）的值。
	get: function(self: Entity, key: string): Item

	-- 获取实体属性（组件）的先前的值。
	-- @param key (string) 要获取先前值的属性的名称。
	-- 旧值是指实体的组件值在上次发生更改之前的值。
	-- @return (Item) 属性（组件）的先前值。
	getOld: function(self: Entity, key: string): Item

	-- 检索实体属性（组件）的值的元方法。
	-- @usage
	-- local valueX = entity.valueX
	-- @param key (string) 要检索值的属性的名称。
	-- @return (Item) 属性（组件）的值。
	metamethod __index: function(self: Entity, key: string): Item

	-- 设置实体属性（组件）的值的元方法。
	-- @usage
	-- entity.valueX = 123
	-- @param key (string) 要设置的属性（组件）的名称。
	-- @param item (Item) 要将属性（组件）设置为的值。
	metamethod __newindex: function(self: Entity, key: string, item: Item)
end

-- 用于在ECS游戏系统中创建和管理实体的类。
local record EntityClass
	type Type = Entity
	type Item = Item
	type ContainerItem = ContainerItem

	-- 所有正在运行的实体的数量。
	const count: integer

	-- 清除所有在运行实体的函数。
	clear: function(self: EntityClass)

	-- 创建具有指定组件的新实体的元方法。
	-- 新实体创建后，可以从`Group`和`Observer`对象中访问新创建的实体对象。
	-- @usage
	-- Entity({ a = 1, b = "abc", c = Node() })
	-- @param coms ({string: Item}) 包含组件名称（字符串）和组件值（Item）映射的Lua表。
	metamethod __call: function(self: EntityClass, coms: {string: Item})
end

local entity: EntityClass
return entity
