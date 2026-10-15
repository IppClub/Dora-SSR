local Joint = require("JointType")
local Vec2 = require("Vec2").Type

-- A type of joint that allows a physics body to move to a specific position.
local record MoveJoint

	-- Inherits from `Joint`.
	embed Joint

	-- The current position of the move joint in the game world.
	position: Vec2
end

local record MoveJointClass
	type Type = MoveJoint
end

local moveJointClass: MoveJointClass
return moveJointClass
