local Object = require("Object").Type
local Routine = require("Routine")
local record Scheduler
	embed Object
	timeScale: number
	schedule: function(self: Scheduler, object: Object)
	schedule: function(self: Scheduler, handler: function(number): boolean)
	schedule: function(self: Scheduler, job: Routine.Job)
	unschedule: function(self: Scheduler, object: Object)
end
local record SchedulerClass
	type Type = Scheduler
	metamethod __call: function(cls: SchedulerClass): Scheduler
end
local scheduler: SchedulerClass
return scheduler
