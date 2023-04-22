local Routine = require("Routine")

-- Create a coroutine job that runs once.
-- @param routine (function) A routine function to execute once when the coroutine is resumed.
-- Yield true or just return inside the routine function to stop the job execution half way.
-- @return (Routine.Job) A coroutine that runs the given routine function once.
local once: function(routine: function()): Routine.Job

return once
