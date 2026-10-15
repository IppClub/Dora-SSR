local Entity = require("Entity").Type

-- A record representing an observer of entity changes in the game systems.
local record Observer

	-- Watches the components changes to entities that match the observer's component filter.
	-- @param func (function) The function to call when a change occurs. Returns true to stop watching.
	-- @return (Observer) The same observer, for method chaining.
	watch: function(self: Observer, func: function(Entity): boolean): Observer
end

-- A class for creating Observer objects.
local record ObserverClass
	type Type = Observer

	-- The types of entity events that an observer can watch for.
	enum EntityEvent

		-- The addition of a new entity.
		"Add"

		-- The modification of an existing entity.
		"Change"

		-- The addition or modification of an entity.
		"AddOrChange"

		-- The removal of an existing entity.
		"Remove"
	end

	-- A metamethod that creates a new observer with the specified component filter and action to watch for
	-- @param event (EntityEvent) The type of entity event to watch for.
	-- @param components ({string}) A table listing the names of the components to filter entities by.
	-- @return (Observer) The new observer.
	metamethod __call: function(self: ObserverClass, event: EntityEvent, components: {string}): Observer
end

local observerClass: ObserverClass
return observerClass
