local ActionDef = require("Action").Def

-- 创建一个动作定义，用于顺序执行一系列其它动作定义的动作。
-- @param ... (ActionDef) 多个要按顺序播放的动作定义对象。
-- @return (ActionDef) 动作定义对象，可用于在节点上运行动作序列。
local sequence: function(...: ActionDef): ActionDef

return sequence
