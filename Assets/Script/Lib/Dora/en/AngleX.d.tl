local ActionDef = require("Action").Def
local Ease = require("Ease")

-- Creates a definition for an action that animates the x-axis rotation angle of a Node from one value to another.
-- @param duration (number) The duration of the animation in seconds.
-- @param from (number) The starting value of the x-axis rotation angle in degrees.
-- @param to (number) The ending value of the x-axis rotation angle in degrees.
-- @param easing (EaseFunc) [optional] The easing function to use for the animation. Defaults to Ease.Linear if not specified.
-- @return (ActionDef) An ActionDef object that can be used to run the animation on a Node.
local angleX: function(
		duration: number,
		from: number,
		to: number,
		easing?: Ease.EaseFunc --[[Ease.Linear]]
	): ActionDef

return angleX
