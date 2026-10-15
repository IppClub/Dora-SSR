local Object = require("Object").Type
local Routine = require("Routine")

-- 用于管理调度任务执行的调度器类。
local record Scheduler

	-- 继承自`Object`。
	embed Object

	-- 调度器的时间缩放系数。
	-- 会同步改变被调度的函数接收到的`deltaTime`时间参数值。
	timeScale: number

	-- 固定更新模式下的目标帧速率（以每秒帧数为单位）。
	-- 固定更新将确保更新函数以恒定的帧速率被调度，使用恒定的更新时间间隔值。
	-- 用于防止物理引擎产生奇怪行为或是用于通过网络通信同步一些状态。
	fixedFPS: integer

	-- 开始调度一个函数在每一个游戏帧里被执行。
	-- @param handler (function) 要调度的函数。
	-- 被调度的函数会接收到自上一帧以来的时间间隔。
	-- 如果函数返回 true，则会被停止调度。
	schedule: function(self: Scheduler, handler: function(number): boolean)

	-- 开始调度执行一个协程任务。
	-- @param job (Routine.Job) 要被调度的协程任务。
	schedule: function(self: Scheduler, job: Routine.Job)

	-- 如果调度器是由用户手动创建的，则用该方法手动更新调度器。
	-- @param deltaTime (number) 自上一次更新以来的时间间隔。
	-- @return (boolean) 如果调度器已经停止，则返回 true。
	update: function(self: Scheduler, deltaTime: number): boolean
end

-- 用于创建调度器对象的类。
local record SchedulerClass
	type Type = Scheduler

	-- 创建新的调度器对象。
	-- @return (Scheduler) 新创建的调度器对象。
	metamethod __call: function(self: SchedulerClass): Scheduler
end

local scheduler: SchedulerClass
return scheduler
