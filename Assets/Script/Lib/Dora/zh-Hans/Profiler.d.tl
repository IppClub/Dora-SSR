-- 用于性能测试分析的类。
local record ProfilerClass

	-- 性能测试分析事件的名称。
	const EventName: string

	-- 当前性能测试分析的级别。
	level: integer

	-- 调用一个函数并返回执行所需的时间。
	-- @param funcForProfiling (function) 要进行分析的函数。
	-- @return (number) 执行函数所需的时间。
	-- @usage local time = Profiler(myFunction)
	metamethod __call: function(self: ProfilerClass, funcForProfiling: function): number
end

local profiler: ProfilerClass
return profiler
