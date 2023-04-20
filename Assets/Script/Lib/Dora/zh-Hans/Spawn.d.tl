local ActionDef = require("Action").Def

-- 创建一个定义，用于并行运行一组动作定义的动作。
-- @param ... (ActionDef) 多个要同时运行的动作定义对象。
-- @return (ActionDef) 一个动作定义对象，可用于在节点上运行该动作。
local spawn: function(...: ActionDef): ActionDef

return spawn
