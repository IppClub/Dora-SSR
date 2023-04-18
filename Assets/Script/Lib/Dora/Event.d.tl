local ActionDef = require("Action").Def

-- Creates a definition for an action that emits event.
-- And you can get this event by register event slot from the action performing node. For example:
-- node:slot("EventName", function(param: string)
-- 	print("EventName triggered with param", param)
-- end)
-- node:perform(Sequence(
-- 	Delay(3),
-- 	Event("EventName", "Hello")
-- ))
-- @param name (string) The name of the event to be triggered.
-- @param param (string) The parameter to pass to the event. (default: "")
-- @return (ActionDef) The created `ActionDef`.
local event: function(
		name: string,
		param?: string --[[""]]
	): ActionDef

return event
