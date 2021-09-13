local Object = require("Object").Type
local Item = require("ItemBase")
local record Entity
	embed Object
	const index: integer
	const oldValues: {string: Item}
	destroy: function(self: Entity)
	set: function(self: Entity, key: string, item: Item)
	setNext: function(self: Entity, key: string, item: Item)
	get: function(self: Entity, key: string): Item
	getOld: function(self: Entity, key: string): Item
	metamethod __index: function(self: Entity, key: string): Item
	metamethod __newindex: function(self: Entity, key: string, item: Item)
end
local record EntityClass
	type Type = Entity
	const count: integer
	clear: function(cls: EntityClass)
	metamethod __call: function(cls: EntityClass): Entity
end
local entity: EntityClass
return entity
