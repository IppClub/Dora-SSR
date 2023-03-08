local ActionDef = require("Action").Def
local Vec2 = require("Vec2").Type
local Ease = require("Ease")
local move: function(
		duration: number,
		from: Vec2,
		to: Vec2,
		easing?: Ease.EaseFunc --[[Ease.Linear]]
	): ActionDef
return move
