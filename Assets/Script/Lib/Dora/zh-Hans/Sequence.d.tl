local ActionDef = require("Action").Def

-- Creates a definition for an action that plays a sequence of other ActionDefs.
-- @param ... (ActionDef) A variable number of ActionDef objects to play in sequence.
-- @return (ActionDef) An ActionDef object that can be used to run the sequence of actions on a Node.
local sequence: function(...: ActionDef): ActionDef

return sequence
