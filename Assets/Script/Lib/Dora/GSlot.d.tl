local Object = require("Object").Type
local record GSlot
	embed Object
	const name: string
	const enabled: boolean
end
local record GSlotClass
	type Type = GSlot
end
local gSlotClass: GSlotClass
return gSlotClass
