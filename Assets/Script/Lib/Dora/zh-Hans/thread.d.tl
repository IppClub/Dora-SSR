local Routine = require("Routine")

-- 用要执行的函数创建并执行一个新协程任务。
-- @param routine (function) 要执行为协程任务的函数。
-- @return (Routine.Job) 创建的协程任务对象。
local thread: function(routine: function()): Routine.Job

return thread
