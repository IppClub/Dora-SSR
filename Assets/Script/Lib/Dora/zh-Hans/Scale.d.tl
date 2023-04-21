local ActionDef = require("Action").Def
local Ease = require("Ease")

-- 创建一个动作定义，该操作可将节点的 x 轴和 y 轴缩放从一个值变动到另一个值。
-- @param duration (number) 动作持续时间（秒）。
-- @param from (number) x 轴和 y 轴缩放的起始值。
-- @param to (number) x 轴和 y 轴缩放的结束值。
-- @param easing (EaseFunc) [可选] 动作使用的缓动函数。如果未指定，默认为 Ease.Linear。
-- @return (ActionDef) 动作定义对象，可用于在节点上运行动作。
local scale: function(
		duration: number,
		from: number,
		to: number,
		easing?: Ease.EaseFunc --[[Ease.Linear]]
	): ActionDef

return scale
