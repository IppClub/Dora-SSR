-- 向通过`node:gslot()`函数注册的所有监听器发送包含特定事件名称和参数的全局事件。
-- @param eventName (string) 要发送的全局事件的名称。
-- @param ... (...any) 要发送给全局事件监听器的参数数据。
local emit: function(eventName: string, ...: any)

return emit
