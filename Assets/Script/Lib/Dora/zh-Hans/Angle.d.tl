local ActionDef = require("Action").Def
local Ease = require("Ease")

-- 创建一个动作定义对象，用于将场景节点的角度从一个值变动到另一个值。
-- @param duration (number) 动作持续时间（秒）。
-- @param from (number) 角度的起始值（度数）。
-- @param to (number) 角度的结束值（度数）。
-- @param easing (EaseFunc) [可选] 应用于动作的缓动函数。如果未指定，默认为Ease.Linear。
-- @return (ActionDef) 返回可用于在场景节点上执行动作的动作定义对象。
local angle: function(
		duration: number,
		from: number,
		to: number,
		easing?: Ease.EaseFunc --[[Ease.Linear]]
	): ActionDef

return angle
