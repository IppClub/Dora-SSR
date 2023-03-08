local ActionDef = require("Action").Def
local Ease = require("Ease")
local scale: function(
		duration: number,
		from: number,
		to: number,
		easing?: Ease.EaseFunc --[[Ease.Linear]]
	): ActionDef
return scale
