local ActionDef = require("Action").Def
local Ease = require("Ease")

-- 创建一个动作定义对象，用于改变场景节点的高度。
-- @param duration (number) 动作时长，单位为秒。
-- @param from (number) 节点高度的起始值。
-- @param to (number) 节点高度的结束值。
-- @param easing (EaseFunc) [可选] 动作所使用的缓动函数，默认为Ease.Linear。
-- @return (ActionDef) 动作定义对象，可用于在节点上运行动作。
local height: function(
		duration: number,
		from: number,
		to: number,
		easing?: Ease.EaseFunc --[[Ease.Linear]]
	): ActionDef

return height
