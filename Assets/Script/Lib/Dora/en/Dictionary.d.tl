local Object = require("Object").Type
local Item = require("Array").Item
local ContainerItem = require("ContainerItemType")

-- A record type for storing pairs of string keys and various values.
local record Dictionary

	-- Inherits from `Object`.
	embed Object

	-- The number of items in the dictionary.
	const count: integer

	-- The keys of the items in the dictionary.
	const keys: {string}

	-- A method for accessing items in the dictionary.
	-- @param key (string) The key of the item to retrieve.
	-- @return (Item or nil) The Item with the given key, or nil if it does not exist.
	get: function(self: Dictionary, key: string): Item

	-- A method for setting items in the dictionary.
	-- @param key (string) The key of the item to set.
	-- @param item (Item) The Item to set for the given key, set to nil to delete this key-value pair.
	set: function(self: Dictionary, key: string, item: Item)

	-- A function that iterates over each item in the dictionary and calls a given function with the item and its key. The items in the dictionary can not be added or removed during the iteration.
	-- @param func (function) The function to call for each item in the dictionary.
	-- This function should take an Item and a string as arguments and return a boolean. Returns true to stop iteration, false to continue.
	-- @return (boolean) Returns false if the iteration completed successfully, true otherwise.
	each: function(self: Dictionary, func: function(Item, string): boolean): boolean

	-- A function that removes all the items from the dictionary.
	clear: function(self: Dictionary)

	-- A metamethod that allows accessing items in the dictionary using the index notation, e.g. "dict['key']" or "dict.key".
	-- @param key (string) The key of the item to retrieve.
	-- @return (Item or nil) The Item with the given key, or nil if it does not exist.
	metamethod __index: function(self: Dictionary, key: string): Item

	-- A metamethod that allows setting items in the dictionary using the index notation, e.g. "dict['key'] = value" or "dict.key = value".
	-- @param key (string) The key of the item to set.
	-- @param item (Item) The Item to set for the given key, set to nil to delete this key-value pair.
	metamethod __newindex: function(self: Dictionary, key: string, item: Item)
end

-- A class for creating Dictionary
-- @usage
-- local Dictionary = require("Dictionary")
-- local dict = Dictionary()
local record DictionaryClass
	type Type = Dictionary
	type Item = Item
	type ContainerItem = ContainerItem

	-- A metamethod that allows creating instances of the "Dictionary" type.
	-- @return (Dictionary) A new instance of the Dictionary type.
	metamethod __call: function(self: DictionaryClass): Dictionary
end

local dictionaryClass: DictionaryClass
return dictionaryClass
