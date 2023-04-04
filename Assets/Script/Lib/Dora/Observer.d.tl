local Entity = require("Entity").Type

-- A record representing an observer of entity changes in the game systems.
local record Observer

	-- Watches the game state for changes to entities that match the observer's component filter, calling a function whenever a change occurs.
	-- @param func (function) The function to call when a change occurs.
	-- @return (Observer) The same observer, for method chaining.
	watch: function(self: Observer, func: function(Entity)): Observer
end

-- A class for creating Observer objects.
local record ObserverClass
	type Type = Observer

	-- The types of actions that an observer can watch for.
	enum Action

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
	-- @param action (Action) The type of action to watch for.
	-- @param components ({string}) A table listing the names of the components to filter entities by.
	-- @return The new observer.
	metamethod __call: function(self: ObserverClass, action: Action, components: {string}): Observer
end

local observerClass: ObserverClass
return observerClass
