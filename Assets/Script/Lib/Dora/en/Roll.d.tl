local ActionDef = require("Action").Def
local Ease = require("Ease")

-- Creates a definition for an action that animates the rotation of a Node from one value to another.
-- The roll animation will make sure the node is rotated to the target angle by the minimum rotation angle.
-- @param duration (number) The duration of the animation in seconds.
-- @param from (number) The starting roll value of the Node (in degrees).
-- @param to (number) The ending roll value of the Node (in degrees).
-- @param easing (EaseFunc) [optional] The easing function to use for the animation. Defaults to Ease.Linear if not specified.
-- @return (ActionDef) An ActionDef object that can be used to run the animation on a Node.
local roll: function(
		duration: number,
		from: number,
		to: number,
		easing?: Ease.EaseFunc --[[Ease.Linear]]
	): ActionDef

return roll
