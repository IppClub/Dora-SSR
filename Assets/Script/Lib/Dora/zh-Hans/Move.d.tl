local ActionDef = require("Action").Def
local Vec2 = require("Vec2").Type
local Ease = require("Ease")

-- 创建一个动作定义，用于动态改变节点的位置。
-- @param duration (number) 动作的持续时间（秒）。
-- @param from (Vec2) 节点的起始位置。
-- @param to (Vec2) 节点的结束位置。
-- @param easing (EaseFunc) [可选] 动作使用的缓动函数。如果未指定，默认为Ease.Linear。
-- @return (ActionDef) 可用于在节点上运行动作的定义对象。
local move: function(
		duration: number,
		from: Vec2,
		to: Vec2,
		easing?: Ease.EaseFunc --[[Ease.Linear]]
	): ActionDef

return move
