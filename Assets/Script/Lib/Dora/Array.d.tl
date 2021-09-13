local Object = require("Object").Type
local Item = require("ItemBase")
local record Array
	userdata
	embed Object
	const count: integer
	const capacity: integer
	const empty: boolean
	addRange: function(self: Array, other: Array)
	removeFrom: function(self: Array, other: Array)
	clear: function(self: Array)
	reverse: function(self: Array)
	shrink: function(self: Array)
	swap: function(self: Array, indexA: integer, indexB: integer)
	removeAt: function(self: Array, index: integer): boolean
	fastRemoveAt: function(self: Array, index: integer): boolean
	each: function(self: Array, func: function(Object): boolean): boolean
	const first: Item
	const last: Item
	const randomObject: Item
	set: function(self: Array, index: integer, item: Item)
	get: function(self: Array, index: integer): Item
	add: function(self: Array, item: Item)
	insert: function(self: Array, index: integer, item: Item)
	contains: function(self: Array, item: Item): boolean
	index: function(self: Array, item: Item): integer
	removeLast: function(self: Array): Item
	fastRemove: function(self: Array, index: integer): Item
	metamethod __index: function(self: Array, index: integer): Item
	metamethod __newindex: function(self: Array, index: integer, item: Item)
	metamethod __len: function(cls: Array): integer
end
local record ArrayClass
	type Type = Array
	metamethod __call: function(cls: Array): Array
	metamethod __call: function(cls: Array, items: {Item}): Array
end
local arrayClass: ArrayClass
return arrayClass
