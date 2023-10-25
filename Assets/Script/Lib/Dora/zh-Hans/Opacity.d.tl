local ActionDef = require("Action").Def
local Ease = require("Ease")

-- 创建一个动作定义，用于将节点的不透明度从一个值变动到另一个值。
-- @param duration (number) 动作持续时间（以秒为单位）。
-- @param from (number) 节点的起始不透明度值（0-1.0）。
-- @param to (number) 节点的结束不透明度值（0-1.0）。
-- @param easing (EaseFunc) [可选] 用于动作的缓动函数。如果未指定，默认为Ease.Linear。
-- @return (ActionDef) 一个动作定义对象，可用于在节点上执行动作。
local opacity: function(
		duration: number,
		from: number,
		to: number,
		easing?: Ease.EaseFunc --[[Ease.Linear]]
	): ActionDef

return opacity
