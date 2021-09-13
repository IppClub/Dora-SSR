local ActionDef = require("ActionDefBase")
local Vec2 = require("Vec2").Type
local Ease = require("Ease")
return function(duration: number, from: Vec2, to: Vec2, easing: Ease.EaseFunc --[[Ease.Linear]]): ActionDef
	print(duration, from, to, easing)
	return {}
end
