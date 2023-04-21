local ActionDef = require("Action").Def
local Ease = require("Ease")

-- 创建一个定义动作，使节点沿y轴做倾斜的变动。
-- @param duration (number) 动作的持续时间（秒）。
-- @param from (number) 节点在y轴上开始倾斜角度（以度为单位）。
-- @param to (number) 节点在y轴上结束倾斜角度（以度为单位）。
-- @param easing (EaseFunc) [可选] 用于动作的缓动函数。如果未指定，则默认为Ease.Linear。
-- @return (ActionDef) 定义动对象，可用于在节点上运行动作。
local skewY: function(
		duration: number,
		from: number,
		to: number,
		easing?: Ease.EaseFunc --[[Ease.Linear]]
	): ActionDef

return skewY
