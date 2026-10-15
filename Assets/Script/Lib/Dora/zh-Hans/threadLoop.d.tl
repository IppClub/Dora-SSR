local Routine = require("Routine")

-- 用一个要被重复运行的任务函数创建一个新的协程任务。
-- @param routine (function) 要进行重复执行的函数。函数可以返回 false 以继续运行，或返回 true 以停止。
-- @return (Routine.Job) 创建的协程任务对象。
local threadLoop: function(routine: function(): boolean): Routine.Job

return threadLoop
