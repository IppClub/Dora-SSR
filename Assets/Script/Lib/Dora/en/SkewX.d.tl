local ActionDef = require("Action").Def
local Ease = require("Ease")

-- Creates a definition for an action that animates the skew of a Node along the x-axis.
-- @param duration (number) The duration of the animation in seconds.
-- @param from (number) The starting skew value of the Node on the x-axis (in degrees).
-- @param to (number) The ending skew value of the Node on the x-axis (in degrees).
-- @param easing (EaseFunc) [optional] The easing function to use for the animation. Defaults to Ease.Linear if not specified.
-- @return (ActionDef) An ActionDef object that can be used to run the animation on a Node.
local skewX: function(
		duration: number,
		from: number,
		to: number,
		easing?: Ease.EaseFunc --[[Ease.Linear]]
	): ActionDef

return skewX
