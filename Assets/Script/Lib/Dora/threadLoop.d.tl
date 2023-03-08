local Routine = require("Routine")
local threadLoop: function(routine: function(): boolean): Routine.Job
return threadLoop
