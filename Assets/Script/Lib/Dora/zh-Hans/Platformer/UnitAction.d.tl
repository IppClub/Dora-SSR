local Routine = require("Routine")
local type UnitAction = require("Platformer.UnitActionType")
local type Unit = require("Platformer.UnitType")

-- 用于定义游戏单位动作的参数类。
local record UnitActionParam

	-- 游戏单位动作的优先级。具有更高优先级（更大的数字）的动作将替换正在运行的低优先级的动作。
	-- 如果执行具有相同优先级的动作且将要执行的动作的参数“queued”的值为true，则不会替换正在执行的游戏单位动作。
	priority: integer

	-- 游戏单位动作的反应时间，以秒为单位。
	-- 反应时间将影响AI循环检查的时间间隔。
	-- 设置为0.0可以使AI检查在每个游戏帧中都被执行。
	reaction: number

	-- 游戏单位动作的恢复时间，以秒为单位。
	-- 恢复时间主要影响动画模型在切换不同动作播放的动画之间进行过渡的时间长度。
	recovery: number

	-- 游戏单位动作是否排队。排队的动作不会替换具有相同优先级切在运行中的动作。[可选]
	queued: boolean

	-- 用于检查游戏单位是否可以执行单位动作的函数。[可选]
	-- @param owner (Unit) 动作所属的游戏单位。
	-- @param action (UnitAction) 要检查可用性的动作。
	-- @return (boolean) 如果游戏单位动作检查通过则返回true，否则返回false。
	available: function(owner: Unit, action: UnitAction): boolean

	-- 用于准备游戏单位动作执行的初始状态并返回逐帧处理函数或携程的函数。
	-- @param owner (Unit) 动作所属的游戏单位。
	-- @param action (UnitAction) 当前的游戏单位动作。
	-- @return (function or Routine.Job) 逐帧处理函数或是携程用于处理动作逻辑，函数返回true，或在携程中yield true来停止动作处理。
	create: function(owner: Unit, action: UnitAction): (
		function(owner: Unit, action: UnitAction, deltaTime: number): (boolean)
		| Routine.Job
	)

	-- 当游戏单位停止执行单位动作时调用的函数。[可选]
	-- @param owner (Unit) 动作所属的游戏单位。
	stop: function(owner: Unit)
end

-- 用于创建并存储游戏单位动作定义的单例类。
local record UnitActionClass
	type Type = UnitAction

	-- 使用指定的名称和参数添加新的游戏单位动作定义。
	-- @param name (string) 新单位动作的名称。
	-- @param param (UnitActionParam) 新单位动作定义的参数。
	add: function(
		self: UnitActionClass,
		name: string,
		param: UnitActionParam
	)

	-- 删除所有的游戏单位动作定义。
	clear: function(self: UnitActionClass)
end

local unitActionClass: UnitActionClass
return unitActionClass
