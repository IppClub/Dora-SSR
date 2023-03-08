local Routine = require("Routine")
local loop: function(routine: function(): boolean): Routine.Job
return loop
