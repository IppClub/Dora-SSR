local Object = require("Object").Type

-- A Slot object that represents a single event slot with handlers.
local record Slot

	-- Inherits from `Object`.
	embed Object

	-- Adds a new handler function to this slot.
	-- @param handler (function) The handler function to add.
	add: function(self: Slot, handler: function(...: any))

	-- Sets a new handler function for this slot, replacing any existing handlers.
	-- @param handler (function) The handler function to set.
	set: function(self: Slot, handler: function(...: any))

	-- Removes a previously added handler function from this slot.
	-- @param handler (function) The handler function to remove.
	remove: function(self: Slot, handler: function(...: any))

	-- Clears all handler functions from this slot.
	clear: function(self: Slot)
end

local record SlotClass
	type Type = Slot
end

local slotClass: SlotClass
return slotClass
