local Object = require("Object").Type
local ContainerItem = require("ContainerItemType")
local type Item = integer | number | boolean | string | ContainerItem

-- A record type representing an entity for an ECS game system.
local record Entity

	-- Inherits from `Object`.
	embed Object

	-- The index of the entity.
	const index: integer

	-- A syntax shortcut for accessing the old values of the entity's properties.
	-- The old values are values before last change of the component values of the Entity.
	-- Don't keep a reference to it for it is not an actual table.
	const oldValues: {string: Item}

	-- A function that destroys the entity.
	destroy: function(self: Entity)

	-- A function that sets a property of the entity to a given value.
	-- This function will trigger events for Observer objects.
	-- @param key (string) The name of the property to set.
	-- @param item (Item) The value to set the property to.
	set: function(self: Entity, key: string, item: Item)

	-- A function that retrieves the value of a property of the entity
	-- @param key (string) The name of the property to retrieve the value of.
	-- @return (Item) The value of the specified property.
	get: function(self: Entity, key: string): Item

	-- A function that retrieves the previous value of a property of the entity
	-- @param key (string) The name of the property to retrieve the previous value of.
	-- The old values are values before last change of the component values of the Entity.
	-- @return (Item) The previous value of the specified property
	getOld: function(self: Entity, key: string): Item

	-- A metamethod that retrieves the value of a property of the entity.
	-- @usage
	-- local valueX = entity.valueX
	-- @param key (string) The name of the property to retrieve the value of.
	-- @return (Item) The value of the specified property.
	metamethod __index: function(self: Entity, key: string): Item

	-- A metamethod that sets the value of a property of the entity.
	-- @usage
	-- entity.valueX = 123
	-- @param key (string) The name of the property to set.
	-- @param item (Item) The value to set the property to.
	metamethod __newindex: function(self: Entity, key: string, item: Item)
end

-- A class for creating and managing entities in the ECS game systems.
local record EntityClass
	type Type = Entity
	type Item = Item
	type ContainerItem = ContainerItem

	-- The number of all running entities.
	const count: integer

	-- A function that clears all entities.
	clear: function(self: EntityClass)

	-- A metamethod that creates a new entity with the specified components.
	-- And you can then get the newly created Entity object from groups and observers.
	-- @usage
	-- Entity({ a = 1, b = "abc", c = Node() })
	-- @param coms ({string: Item}) A table mapping component names (strings) to component values (Items).
	metamethod __call: function(self: EntityClass, coms: {string: Item})
end

local entity: EntityClass
return entity
