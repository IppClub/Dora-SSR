local ActionDef = require("Action").Def
local Ease = require("Ease")

-- 创建一个动作定义，用于将节点的 y 轴缩放比例从一个值变动到另一个值。
-- @param duration (number) 动作持续时间，单位为秒。
-- @param from (number) y 轴缩放比例的起始值。
-- @param to (number) y 轴缩放比例的结束值。
-- @param easing (EaseFunc) [可选] 动作使用的缓动函数。如果未指定，默认为 Ease.Linear。
-- @return (ActionDef) 可用于在节点上运行动作的动作定义对象。
local scaleY: function(
		duration: number,
		from: number,
		to: number,
		easing?: Ease.EaseFunc --[[Ease.Linear]]
	): ActionDef

return scaleY
