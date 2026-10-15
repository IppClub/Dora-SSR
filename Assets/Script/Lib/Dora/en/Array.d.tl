local Object = require("Object").Type
local ContainerItem = require("ContainerItemType")
local Job = require("Routine").Job

-- The supported array data types.
local type Item = integer | number | boolean | string | thread | ContainerItem | Job

-- An array data structure that supports various operations.
-- The Array record is designed to be 1-based indexing, which means that the first item in the array has an index of 1. This is the same behavior of Lua table used as an array.
local record Array

	-- Inherits from `Object`.
	embed Object

	-- The number of items in the array.
	const count: integer

	-- Whether the array is empty or not.
	const empty: boolean

	-- Adds all items from another array to the end of this array.
	-- @param other (Array) Another array object.
	addRange: function(self: Array, other: Array)

	-- Removes all items from this array that are also in another array.
	-- @param other (Array) Another array object.
	removeFrom: function(self: Array, other: Array)

	-- Removes all items from the array.
	clear: function(self: Array)

	-- Reverses the order of the items in the array.
	reverse: function(self: Array)

	-- Removes any empty slots from the end of the array.
	-- Used for release the unused memory this array holds.
	shrink: function(self: Array)

	-- Swaps the items at two given indices.
	-- @param indexA (integer) The first index.
	-- @param indexB (integer) The second index.
	swap: function(self: Array, indexA: integer, indexB: integer)

	-- Removes the item at the given index.
	-- @param index (integer) The index to remove.
	-- @return (boolean) True if an item was removed, false otherwise.
	removeAt: function(self: Array, index: integer): boolean

	-- Removes the item at the given index without preserving the order of the array.
	-- @param index (integer) The index to remove.
	-- @return (boolean) True if an item was removed, false otherwise.
	fastRemoveAt: function(self: Array, index: integer): boolean

	-- Calls a given function for each item in the array.
	-- The items in the array can not be added or removed during the iteration.
	-- @param func (function) The function to call for each item.
	-- Should return false to continue iteration, true to stop.
	-- @return (boolean) False if the iteration completed, true if it was interrupted by the function.
	each: function(self: Array, func: function(Object): boolean): boolean

	-- The first item in the array.
	const first: Item

	-- The last item in the array.
	const last: Item

	-- A random item from the array.
	const randomObject: Item

	-- Sets the item at the given index.
	-- @param index (integer) The index to set, should be 1 based.
	-- @param item (Item) The new item value.
	set: function(self: Array, index: integer, item: Item)

	-- Gets the item at the given index.
	-- @param index (integer) The index to get, should be 1 based.
	-- @return (Item) The item value.
	get: function(self: Array, index: integer): Item

	-- Adds an item to the end of the array.
	-- @param item (Item) The item to add.
	add: function(self: Array, item: Item)

	-- Inserts an item at the given index, shifting other items to the right.
	-- @param index (integer) The index to insert at.
	-- @param item (Item) The item to insert.
	insert: function(self: Array, index: integer, item: Item)

	-- Checks whether the array contains a given item.
	-- @param item (Item) The item to check.
	-- @return (boolean) True if the item is found, false otherwise.
	contains: function(self: Array, item: Item): boolean

	-- Gets the index of a given item.
	-- @param item (Item) The item to search for.
	-- @return (integer) The index of the item, or 0 if it is not found.
	index: function(self: Array, item: Item): integer

	-- Removes and returns the last item in the array.
	-- @return (Item) The last item removed from the array.
	removeLast: function(self: Array): Item

	-- Removes the first occurrence of a given item from the array without preserving order.
	-- @param item (Item) The item to remove.
	-- @return (boolean) True if the item was found and removed, false otherwise.
	fastRemove: function(self: Array, item: Item): boolean

	-- Metamethod to access the item at the given index using the [] operator.
	-- @param index (integer) The index to get, should be 1 based.
	-- @return (Item) The item value.
	metamethod __index: function(self: Array, index: integer): Item

	-- Metamethod to set the item at the given index using the [] operator.
	-- @param index (integer) The index to set, should be 1 based.
	-- @param item (Item) The new item value.
	metamethod __newindex: function(self: Array, index: integer, item: Item)

	-- Metamethod to get the length of the array using the # operator.
	-- @return (integer) The length of the array.
	metamethod __len: function(self: Array): integer
end

-- A class that creates Array objects.
local record ArrayClass
	type Type = Array
	type Item = Item
	type ContainerItem = ContainerItem

	-- Metamethod to create a new, empty array object.
	-- @return (Array) A new Array object.
	metamethod __call: function(self: ArrayClass): Array

	-- Metamethod to create a new array object initialized with a list of items.
	-- @param items ({Item}) A table of items to initialize the array with.
	-- @return (Array) A new Array object.
	metamethod __call: function(self: ArrayClass, items: {Item}): Array
end

local arrayClass: ArrayClass
return arrayClass
