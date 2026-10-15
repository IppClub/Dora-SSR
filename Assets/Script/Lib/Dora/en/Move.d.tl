local ActionDef = require("Action").Def
local Vec2 = require("Vec2").Type
local Ease = require("Ease")

-- Creates a definition for an action that animates the position of a Node from one Vec2 value to another.
-- @param duration (number) The duration of the animation in seconds.
-- @param from (Vec2) The starting position of the Node.
-- @param to (Vec2) The ending position of the Node.
-- @param easing (EaseFunc) [optional] The easing function to use for the animation. Defaults to Ease.Linear if not specified.
-- @return (ActionDef) An ActionDef object that can be used to run the animation on a Node.
local move: function(
		duration: number,
		from: Vec2,
		to: Vec2,
		easing?: Ease.EaseFunc --[[Ease.Linear]]
	): ActionDef

return move
