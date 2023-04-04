local Object = require("Object").Type
local Routine = require("Routine")

-- A scheduler that manages the execution of scheduled tasks.
local record Scheduler
	embed Object

	-- The time scale factor for the scheduler.
	-- This factor is applied to deltaTime that the scheduled functions will receive.
	timeScale: number

	-- Schedules a function to be called every frame.
	-- @param handler (function) The function to be called.
	-- It should take a single argument of type number, which represents the delta time since the last frame.
	-- If the function returns true, it will not be called again.
	schedule: function(self: Scheduler, handler: function(number): boolean)

	-- Schedules a coroutine job to be resumed every frame.
	-- @param job (Routine.Job) The coroutine job to be resumed.
	schedule: function(self: Scheduler, job: Routine.Job)
end

-- A class for creating Scheduler objects.
local record SchedulerClass
	type Type = Scheduler

	-- Creates a new Scheduler object.
	-- @return The newly created Scheduler object.
	metamethod __call: function(self: SchedulerClass): Scheduler
end

local scheduler: SchedulerClass
return scheduler
