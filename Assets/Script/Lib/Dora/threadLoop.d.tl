local Routine = require("Routine")
return function(routine: function(): boolean): Routine.Job
	print(routine)
end
