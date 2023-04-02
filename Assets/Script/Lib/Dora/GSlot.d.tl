local Object = require("Object").Type

-- A global signal slot object that can be used to handle global events
local record GSlot
	embed Object

	-- The name of the GSlot.
	const name: string

	-- Whether the GSlot is currently enabled or disabled.
	const enabled: boolean
end

local record GSlotClass
	type Type = GSlot
end

local gSlotClass: GSlotClass
return gSlotClass
