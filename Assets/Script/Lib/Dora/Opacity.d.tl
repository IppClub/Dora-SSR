local ActionDef = require("ActionDefBase")
local Ease = require("Ease")
return function(
		duration: number,
		from: number,
		to: number,
		easing?: Ease.EaseFunc --[[Ease.Linear]]
	): ActionDef
	print(duration, from, to, easing)
	return {}
end
