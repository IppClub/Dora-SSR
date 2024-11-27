local Object = require("Object").Type
local Routine = require("Routine")

-- A scheduler that manages the execution of scheduled tasks.
local record Scheduler

	-- Inherits from `Object`.
	embed Object

	-- The time scale factor for the scheduler.
	-- This factor is applied to deltaTime that the scheduled functions will receive.
	timeScale: number

	-- The target frame rate (in frames per second) for a fixed update mode.
	-- The fixed update will ensure a constant frame rate, and the operation handled in a fixed update can use a constant delta time value.
	-- It is used for preventing weird behavior of a physics engine or synchronizing some states via network communications.
	fixedFPS: integer

	-- Schedules a function to be called every frame.
	-- @param handler (function) The function to be called.
	-- It should take a single argument of type number, which represents the delta time since the last frame.
	-- If the function returns true, it will not be called again.
	schedule: function(self: Scheduler, handler: function(number): boolean)

	-- Schedules a coroutine job to be resumed every frame.
	-- @param job (Routine.Job) The coroutine job to be resumed.
	schedule: function(self: Scheduler, job: Routine.Job)

	-- Manually updates the scheduler if it is created by the user.
	-- @param deltaTime (number) The time interval since the last update.
	-- @return (boolean) Returns true if the scheduler has stopped.
	update: function(self: Scheduler, deltaTime: number): boolean
end

-- A class for creating Scheduler objects.
local record SchedulerClass
	type Type = Scheduler

	-- Creates a new Scheduler object.
	-- @return (Scheduler) The newly created Scheduler object.
	metamethod __call: function(self: SchedulerClass): Scheduler
end

local scheduler: SchedulerClass
return scheduler
