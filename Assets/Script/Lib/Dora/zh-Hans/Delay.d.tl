local ActionDef = require("Action").Def

-- 创建一个动作定义对象，用于延迟动作执行的时间。
-- @param duration (number) 延迟的持续时间（以秒为单位）。
-- @return (ActionDef) 新的动作定义对象。
local delay: function(duration: number): ActionDef

return delay
