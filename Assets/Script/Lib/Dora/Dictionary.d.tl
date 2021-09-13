local Object = require("Object").Type
local Array = require("Array").Type
local Item = require("ItemBase")
local record Dictionary
	embed Object
	const count: integer
	const keys: Array
	each: function(self: Dictionary, func: function(Item, string): boolean): boolean
	clear: function(self: Dictionary)
	metamethod __index: function(self: Dictionary, key: string): Item
	metamethod __newindex: function(self: Dictionary, key: string, item: Item)
end
local record DictionaryClass
	type Type = Dictionary
	metamethod __call: function(cls: DictionaryClass): Dictionary
end
local dictionaryClass: DictionaryClass
return dictionaryClass
