local Object = require("Object").Type
local Item = require("Array").Item
local ContainerItem = require("ContainerItemType")

-- 用字符串键和对应值存储数据的字典类。
local record Dictionary

	-- 继承自`Object`。
	embed Object

	-- 字典储存的键值对总数。
	const count: integer

	-- 字典中所有键的列表。
	const keys: {string}

	-- 访问字典数据的方法。
	-- @param key (string) 字符串类型的索引键。
	-- @return (Item 或 nil) 字典里存储的值，如果不存在则返回nil。
	get: function(self: Dictionary, key: string): Item

	-- 设置字典里的值的方法。
	-- @param key (string) 字符串类型的索引键。
	-- @param item (Item) 要为给定键设置的值，当设置值为nil时可以删除该键值对。
	set: function(self: Dictionary, key: string, item: Item)

	-- 遍历字典中每个键值对并调用处理函数。
	-- 在迭代过程中，字典中的键值对不能被添加或删除。
	-- @param func (function) 对字典中每个键值对调用的函数。
	-- 此函数会接收一个值对象Item和一个字符串的键作为参数，并需要返回一个布尔值。返回true停止遍历，false继续。
	-- @return (boolean) 如果遍历成功完成，则返回false，否则返回true。
	each: function(self: Dictionary, func: function(Item, string): boolean): boolean

	-- 从字典中删除所有键值对。
	clear: function(self: Dictionary)

	-- 允许使用索引访问字典的元方法，例如：dict['keyA'] 或 dict.keyB。
	-- @param key (string) 字符串类型的索引键。
	-- @return (Item 或 nil) 字典里存储的值，如果不存在则返回nil。
	metamethod __index: function(self: Dictionary, key: string): Item

	-- 允许使用索引设置字典里的值的元方法，例如：dict['keyA'] = value 或 dict.keyB = value。
	-- @param key (string) 字符串类型的索引键。
	-- @param item (Item) 要为给定键设置的值，当设置值为nil时可以删除该键值对。
	metamethod __newindex: function(self: Dictionary, key: string, item: Item)
end

-- 用于创建字典对象的类。
-- @usage
-- local Dictionary = require("Dictionary")
-- local dict = Dictionary()
local record DictionaryClass
	type Type = Dictionary
	type Item = Item
	type ContainerItem = ContainerItem

	-- 用于创建字典类型实例的元方法。
	-- @return (Dictionary) 字典类型的新实例。
	metamethod __call: function(self: DictionaryClass): Dictionary
end

local dictionaryClass: DictionaryClass
return dictionaryClass
