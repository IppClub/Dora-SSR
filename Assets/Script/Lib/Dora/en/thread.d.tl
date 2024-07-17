local Routine = require("Routine")

-- Creates a new coroutine from a function and executes it.
-- @param routine (function) A function to execute as a coroutine.
-- @return (Routine.Job) A handle to the coroutine that was created.
local thread: function(routine: function()): Routine.Job

return thread
