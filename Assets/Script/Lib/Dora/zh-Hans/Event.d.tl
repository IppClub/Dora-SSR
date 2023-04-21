local ActionDef = require("Action").Def

-- 创建一个会带有发送节点事件的动作定义。
-- @usage
-- -- 可以通过执行动作的节点注册事件插槽来监听此事件。
-- node:slot("EventName", function(param: string)
-- 	print("带参数的EventName被触发，参数为", param)
-- end)
-- node:perform(Sequence(
-- 	Delay(3),
-- 	Event("EventName", "Hello")
-- ))
-- @param name (string) 要触发事件的名称。
-- @param param (string) 要传递给事件的参数。（默认值：空字符串）
-- @return (ActionDef) 创建的动作定义对象。
local event: function(
		name: string,
		param?: string --[[""]]
	): ActionDef

return event
