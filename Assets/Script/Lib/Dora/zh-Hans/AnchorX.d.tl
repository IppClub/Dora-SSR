local ActionDef = require("Action").Def
local Ease = require("Ease")

-- 创建一个动作定义对象，用于将场景节点的X坐标从一个值变动到另一个值。
-- @param duration (number) 动作的持续时间，以秒为单位。
-- @param from (number) X坐标的起始值。
-- @param to (number) X坐标的结束值。
-- @param easing (EaseFunc) [可选] 应用于动作的缓动函数。如果未指定，默认为Ease.Linear。
-- @return (ActionDef) 返回动作定义对象，可用于在场景节点上执行动作。
local anchorX: function(
		duration: number,
		from: number,
		to: number,
		easing?: Ease.EaseFunc --[[Ease.Linear]]
	): ActionDef

return anchorX
