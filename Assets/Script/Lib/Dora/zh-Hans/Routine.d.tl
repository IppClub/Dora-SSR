-- 用于管理协程任务的单例类。
local record Routine

	-- 该单例类也是包含在执行协程任务对象的数组。
	{Job}

	-- 协程任务类。
	type Job = thread

	-- 关闭并移除一个协程任务。
	-- @param job (Job) 要移除的协程任务。
	-- @return (boolean) 如果协程任务被移除，则为 true，否则为 false。
	remove: function(self: Routine, job: Job): boolean

	-- 关闭并移除所有协程任务。
	clear: function(self: Routine)

	-- 添加一个新的协程任务的元方法。
	-- @param job (Job) 要添加的协程任务实例。
	-- @return (Job) 被添加的协程任务实例。
	metamethod __call: function(self: Routine, job: Job): Job
end

local routine: Routine
return routine
