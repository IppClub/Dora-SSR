local Object = require("Object").Type
local ContainerItem = require("ContainerItemType")
local type Item = integer | number | boolean | string | ContainerItem
local record Entity
	embed Object
	const index: integer
	const oldValues: {string: Item}
	destroy: function(self: Entity)
	set: function(self: Entity, key: string, item: Item)
	get: function(self: Entity, key: string): Item
	getOld: function(self: Entity, key: string): Item
	metamethod __index: function(self: Entity, key: string): Item
	metamethod __newindex: function(self: Entity, key: string, item: Item)
end
local record EntityClass
	type Type = Entity
	type Item = Item
	type ContainerItem = ContainerItem
	const count: integer
	clear: function(self: EntityClass)
	metamethod __call: function(self: EntityClass, coms: {string: Item})
end
local entity: EntityClass
return entity
