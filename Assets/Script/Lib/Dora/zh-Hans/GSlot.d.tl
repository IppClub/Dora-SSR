local Object = require("Object").Type

-- 全局信号槽对象，可用于处理全局事件。
local record GSlot

	-- 继承自`Object`。
	embed Object

	-- 全局信号槽的名称。
	const name: string

	-- 该信号槽当前是否启用或禁用。
	enabled: boolean
end

local record GSlotClass
	type Type = GSlot
end

local gSlotClass: GSlotClass
return gSlotClass
