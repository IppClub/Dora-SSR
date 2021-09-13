local Object = require("Object").Type
local record Slot
	embed Object
	add: function(self: Slot, handler: function(...: any))
	set: function(self: Slot, handler: function(...: any))
	remove: function(self: Slot, handler: function(...: any))
	clear: function(self: Slot)
end
local record SlotClass
	type Type = Slot
end
local slotClass: SlotClass
return slotClass
