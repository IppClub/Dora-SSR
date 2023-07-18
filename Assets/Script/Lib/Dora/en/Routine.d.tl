-- A singleton record for managing coroutines.
local record Routine

	-- The Routine record is also an array of Job objects.
	{Job}

	-- An alias for a coroutine thread.
	type Job = thread

	-- Remove a coroutine job from the set and close it if it is still running.
	-- @param job (Job) The Job instance to remove.
	-- @return (boolean) True if the job was removed, false otherwise.
	remove: function(self: Routine, job: Job): boolean

	-- Remove all coroutine jobs and close them if they are still running.
	clear: function(self: Routine)

	-- Metamethod to add a new Job to the Routine.
	-- @param job (Job) The Job instance to add.
	-- @return (Job) The Job instance that was added.
	metamethod __call: function(self: Routine, job: Job): Job
end

local routine: Routine
return routine
