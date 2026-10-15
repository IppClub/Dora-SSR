local Object = require("Object").Type
local record ActionDef end

-- 可以在节点上运行的动作类。
local record Action

	-- 继承自Object类。
	embed Object

	-- 动作的持续时间。
	const duration: number

	-- 动作是否正在运行。
	const running: boolean

	-- 动作是否暂停。
	const paused: boolean

	-- 动作是否应该倒着播放。
	reversed: boolean

	-- 动作运行的速度。
	-- 将其设置为1.0以获得正常速度，设置为2.0以获得两倍的速度，默认是1.0。
	speed: number

	-- 暂停动作。
	pause: function(self: Action)

	-- 恢复动作。
	resume: function(self: Action)

	-- 更新动作的状态。
	-- @param elapsed (number) 动作执行已经经过的时间，单位为秒。
	-- @param reversed (boolean) 是否倒放动作（默认为false）。
	updateTo: function(
		self: Action,
		elapsed: number,
		reversed?: boolean --[[false]]
	)
end

-- 用于创建可在节点上运行的动作的类。
local record ActionClass
	type Type = Action
	type Def = ActionDef

	-- 根据给定的定义创建新的动作。
	-- @param actionDef (ActionDef) 动作的定义。
	-- @return (Action) 新的动作对象。
	metamethod __call: function(self: ActionClass, actionDef: ActionDef): Action
end

local actionClass: ActionClass
return actionClass
