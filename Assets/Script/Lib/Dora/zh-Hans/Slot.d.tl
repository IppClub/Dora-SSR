local Object = require("Object").Type

-- 用于监听节点事件的信号槽对象类。
local record Slot

	-- 继承自`Object`。
	embed Object

	-- 向此信号槽添加一个新的处理回调函数。
	-- @param handler (function) 要添加的处理函数。
	add: function(self: Slot, handler: function(...: any))

	-- 清除信号槽上之前添加的处理回调函数，并设置一个新的处理回调函数。
	-- @param handler (function) 要设置的处理回调函数。
	set: function(self: Slot, handler: function(...: any))

	-- 从此信号槽中删除先前添加的处理回调函数。
	-- @param handler (function) 要删除的处理回调函数。
	remove: function(self: Slot, handler: function(...: any))

	-- 清除此信号槽中的所有处理回调函数。
	clear: function(self: Slot)
end

local record SlotClass
	type Type = Slot
end

local slotClass: SlotClass
return slotClass
