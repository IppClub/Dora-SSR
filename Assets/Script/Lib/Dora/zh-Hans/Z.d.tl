local ActionDef = require("Action").Def
local Ease = require("Ease")

-- 创建一个动作定义，用于使一个节点的 z 坐标位置发生变动。
-- @param duration (number) 动作的持续时间（秒）。
-- @param from (number) 节点的起始 z 坐标位置。
-- @param to (number) 节点的结束 z 坐标位置。
-- @param easing (EaseFunc) [可选] 动作使用的缓动函数。如果未指定，则默认为 Ease.Linear。
-- @return (ActionDef) 一个动作定义对象，可用于在节点上运行动作。
local z: function(
		duration: number,
		from: number,
		to: number,
		easing?: Ease.EaseFunc --[[Ease.Linear]]
	): ActionDef

return z
