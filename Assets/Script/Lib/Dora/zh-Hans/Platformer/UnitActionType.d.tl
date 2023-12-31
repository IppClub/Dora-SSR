local type Unit = require("Platformer.UnitType")

-- 在游戏单位上执行的动作类
local record UnitAction
	userdata

	-- 游戏单位动作的反应时间长度，以秒为单位。
	-- 反应时间将影响AI检查的周期时间。
	reaction: number

	-- 游戏单位动作的恢复时间长度，以秒为单位。
	-- 恢复时间主要影响动画模型在不同动作中播放动画做切换的动画过渡时间。
	recovery: number

	-- 游戏单位动作的名称。
	const name: string

	-- 游戏单位动作当前是否正在执行。
	const doing: boolean

	-- 自游戏单位动作开始执行后经过的时间，以秒为单位。
	const elapsedTime: number

	-- 该动作所属的游戏单位。
	const owner: Unit
end

return UnitAction
