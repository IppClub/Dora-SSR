local ActionDef = require("Action").Def
local Ease = require("Ease")

-- 创建一个动作定义，用于将一个节点的旋转角度从一个值变动到另一个值。
-- 滚动动作将确保节点通过旋转角度最小的旋转方向旋转到目标角度。
-- @param duration (number) 动作持续时间（秒）。
-- @param from (number) 节点的起始旋转值（以度为单位）。
-- @param to (number) 节点的结束旋转值（以度为单位）。
-- @param easing (EaseFunc) [可选] 动作所使用的缓动函数。如果未指定，默认为 Ease.Linear。
-- @return (ActionDef) 可用于在节点上运行动作的动作定义对象。
local roll: function(
		duration: number,
		from: number,
		to: number,
		easing?: Ease.EaseFunc --[[Ease.Linear]]
	): ActionDef

return roll
