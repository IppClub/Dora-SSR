local Object = require("Object").Type
local Entity = require("Entity").Type

-- A record representing a group of entities in the ECS game systems.
local record Group

	-- Inherits from `Object`.
	embed Object

	-- The number of entities in the group.
	const count: integer

	-- The first entity in the group, or nil if the group is empty.
	const first: Entity

	-- Calls a function for each entity in the group.
	-- @param func (function) The function to call for each entity.
	-- Returning true inside the function to stop iteration.
	-- @return (boolean) False if all entities were processed, True if the iteration was interrupted.
	each: function(self: Group, func: function(Entity): boolean): boolean

	-- Finds the first entity in the group that satisfies a predicate function.
	-- @param func (function) The predicate function to test each entity with.
	-- @return (Entity) The first entity that satisfies the predicate, or nil if no entity does.
	find: function(self: Group, func: function(Entity): boolean): Entity

	-- Watches the group for changes to its entities, calling a function whenever an entity is added or changed.
	-- @param func (function) The function to call when an entity is added or changed. Returns true to stop watching.
	-- @return (Group) The same group, for method chaining.
	watch: function(self: Group, func: function(Entity): boolean): Group
end

-- A class for creating Group objects.
local record GroupClass
	type Type = Group

	-- A metamethod that creates a new group with the specified component names.
	-- @param components ({string}) A table listing the names of the components to include in the group.
	-- @return (Group) The new group.
	metamethod __call: function(self: GroupClass, componemts: {string}): Group
end

local groupClass: GroupClass
return groupClass
