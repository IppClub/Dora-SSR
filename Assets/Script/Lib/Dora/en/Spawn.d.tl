local ActionDef = require("Action").Def

-- Creates a definition for an action that runs a group of ActionDefs in parallel.
-- @param ... (ActionDef) A variable number of ActionDef objects to run in parallel.
-- @return (ActionDef) An ActionDef object that can be used to run the group of actions on a Node.
local spawn: function(...: ActionDef): ActionDef

return spawn
