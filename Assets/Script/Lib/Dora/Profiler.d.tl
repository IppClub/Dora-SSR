local record ProfilerClass
	const EventName: string
	level: integer
	metamethod __call: function(cls: ProfilerClass, func: function): number
end

local profiler: ProfilerClass

return profiler
