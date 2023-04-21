local Routine = require("Routine")

-- 创建一个只运行一次的协程任务。
-- @param routine (function) 只执行一次的协程函数。
-- 在协程函数内部使用`coroutine.yield(true)`或者直接`return`来中止任务的执行。
-- @return (Routine.Job) 只运行特定协程函数一次的协程任务。
local once: function(routine: function()): Routine.Job

return once
