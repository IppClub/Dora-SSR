-- A class for profiling functions.
local record ProfilerClass

	-- The name of the profiling event.
	const EventName: string

	-- The current level of profiling.
	level: integer

	-- Calls a function and return the amount of time it took to execute.
	-- @param funcForProfiling (function) The function to profile.
	-- @return (number) The amount of time it took to execute the function.
	-- @usage local time = Profiler(myFunction)
	metamethod __call: function(self: ProfilerClass, funcForProfiling: function): number
end

local profiler: ProfilerClass
return profiler
