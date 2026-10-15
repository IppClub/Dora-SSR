local Routine = require("Routine")

-- 创建一个协程任务，该任务会一直重复执行，直到满足某个条件退出。
-- @param routine (function) 需要重复执行的函数，返回非 nil 或非 false 值后停止。
-- 在 routine 函数中使用`coroutine.yield(true)`或`return true`来停止执行任务。
-- @return (Routine.Job) 重复运行给定函数的协程。
local loop: function(routine: function(): boolean): Routine.Job

return loop
