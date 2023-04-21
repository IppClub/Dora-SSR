local Routine = require("Routine")

-- Create a coroutine job that runs repeatedly until a condition is met.
-- @param routine (function) A routine function to execute repeatedly until it returns non-nil or non-false.
-- Yield or return true inside the routine function to stop the job execution.
-- @return (Routine.Job) A coroutine that runs the given routine function repeatedly.
local loop: function(routine: function(): boolean): Routine.Job

return loop
