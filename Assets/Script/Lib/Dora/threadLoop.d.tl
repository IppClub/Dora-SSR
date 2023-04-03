local Routine = require("Routine")

-- Create a new coroutine from a function that runs repeatedly.
-- @param routine (function) A function to execute repeatedly as a coroutine.
-- @return (Routine.Job) A handle to the coroutine that was created.
local threadLoop: function(routine: function(): boolean): Routine.Job
return threadLoop
