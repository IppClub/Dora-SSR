local ActionDef = require("Action").Def
local Ease = require("Ease")

-- 创建一个动作定义对象，用于将场景节点的Y轴旋转角度从一个值变动到另一个值。
-- @param duration (number)动作持续时间（秒）。
-- @param from (number) Y轴旋转角度的起始值（度数）。
-- @param to (number) Y轴旋转角度的结束值（度数）。
-- @param easing (EaseFunc) [可选] 应用于动作的缓动函数。如果未指定，则默认为Ease.Linear。
-- @return (ActionDef) 返回一个动作定义对象，可用于在节点上执行动作。
local angleY: function(
		duration: number,
		from: number,
		to: number,
		easing?: Ease.EaseFunc --[[Ease.Linear]]
	): ActionDef

return angleY
