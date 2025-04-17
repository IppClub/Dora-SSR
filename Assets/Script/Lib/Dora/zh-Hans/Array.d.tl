local Object = require("Object").Type
local ContainerItem = require("ContainerItemType")
local Job = require("Routine").Job

-- 数组对象支持存储的数据类型
local type Item = integer | number | boolean | string | thread | ContainerItem | Job

-- 支持各种操作的数组数据结构类。
-- 这个数组类被设计成以1为基数做索引，也就是说数组中的第一项的索引为1。这与Lua语言中用作数组的Lua表的行为一致。
local record Array

	-- 继承自`Object`.
	embed Object

	-- 数组中的对象总数。
	const count: integer

	-- 数组是否为空。
	const empty: boolean

	-- 将另一个数组中的所有对象添加到该数组的末尾。
	-- @param other (Array) 另一个数组对象。
	addRange: function(self: Array, other: Array)

	-- 从该数组中删除所有在另一个数组中也存在的对象。
	-- @param other (Array) 另一个数组对象。
	removeFrom: function(self: Array, other: Array)

	-- 从数组中删除所有对象。
	clear: function(self: Array)

	-- 反转数组中对象的顺序。
	reverse: function(self: Array)

	-- 从数组末尾删除所有空内存槽位。
	-- 用于释放数组持有的但未使用的内存。
	shrink: function(self: Array)

	-- 交换两个给定索引处的对象。
	-- @param indexA (integer) 第一个索引。
	-- @param indexB (integer) 第二个索引。
	swap: function(self: Array, indexA: integer, indexB: integer)

	-- 删除给定索引处的对象。
	-- @param index (integer) 要删除的索引。
	-- @return (boolean) 如果成功删除对象，则返回true，否则返回false。
	removeAt: function(self: Array, index: integer): boolean

	-- 快速删除给定索引处的对象。
	-- 在无需确保数组中元素的顺序时使用。
	-- @param index (integer) 要删除的索引。
	-- @return (boolean) 如果已删除一项则返回true，否则返回false。
	fastRemoveAt: function(self: Array, index: integer): boolean

	-- 对数组中的每个对象调用处理函数。
	-- 在迭代过程中，数组中的对象不能被添加或删除。
	-- @param func (function) 要为每个对象调用的函数。
	-- 如果返回false则继续迭代，返回true则停止。
	-- @return (boolean) 如果迭代完成则返回false，如果处理函数中断了迭代则返回true。
	each: function(self: Array, func: function(Object): boolean): boolean

	-- 获取数组中的第一项。
	const first: Item

	-- 获取数组中的最后一项。
	const last: Item

	-- 获取数组中的一个随机对象。
	const randomObject: Item

	-- 设置给定索引处的对象。
	-- @param index (integer) 要设置的索引，应从基数1开始。
	-- @param item (Item) 新的对象值。
	set: function(self: Array, index: integer, item: Item)

	-- 获取给定索引处的对象。
	-- @param index (integer) 要获取的索引，应为基数1开始。
	-- @return (Item) 索引处的对象值.
	get: function(self: Array, index: integer): Item

	-- 在数组末尾添加对象。
	-- @param item (Item) 要添加的对象。
	add: function(self: Array, item: Item)

	-- 在给定索引处插入对象，并向后移动其它对象。
	-- @param index (integer) 要插入的索引。
	-- @param item (Item) 要插入的对象。
	insert: function(self: Array, index: integer, item: Item)

	-- 检查数组是否包含给定的对象。
	-- @param item (Item) 要检查的对象。
	-- @return (boolean) 如果找到对象则返回True，否则返回false。
	contains: function(self: Array, item: Item): boolean

	-- 获取给定对象的索引。
	-- @param item (Item) 要搜索的对象。
	-- @return (integer) 对象的索引，如果未找到则返回0。
	index: function(self: Array, item: Item): integer

	-- 删除并返回数组中的最后一项。
	-- @return (Item) 数组中的最后一项。
	removeLast: function(self: Array): Item

	-- 从数组快速删除第一次出现的特定对象。
	-- 在无需确保数组中元素的顺序时使用。
	-- @param item (Item) 要删除的对象。
	-- @return (boolean) 如果找到并成功删除了该对象，则返回true，否则返回false。
	fastRemove: function(self: Array, item: Item): boolean

	-- 通过[]操作符访问给定索引处的对象的元方法。
	-- @param index (integer) 要获取的索引，应从基数1开始。
	-- @return (Item) 获取的对象。
	metamethod __index: function(self: Array, index: integer): Item

	-- 通过[]操作符设置给定索引处的对象的元方法。
	-- @param index (integer) 要设置的索引，应从基数1开始。
	-- @param item (Item) 新的对象。
	metamethod __newindex: function(self: Array, index: integer, item: Item)

	-- 通过＃运算符获取数组的长度的元方法。
	-- @return (integer) 数组的长度。
	metamethod __len: function(self: Array): integer
end

-- 用于创建数组对象的类。
local record ArrayClass
	type Type = Array
	type Item = Item
	type ContainerItem = ContainerItem

	-- 创建一个新的空数组对象的元方法。
	-- @return (Array) 新的数组对象。
	metamethod __call: function(self: ArrayClass): Array

	-- 以一个Lua数组表初始化创建一个新的数组对象。
	-- @param items ({Item}) 用于初始化数组的Lua数组表。
	-- @return (Array) 新的数组对象。
	metamethod __call: function(self: ArrayClass, items: {Item}): Array
end

local arrayClass: ArrayClass
return arrayClass
