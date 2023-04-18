local Joint = require("JointType")

-- A joint that applies a rotational or linear force to a physics body.
local record MotorJoint

	-- Inherits from `Joint`.
	embed Joint

	-- Whether or not the motor joint is enabled.
	enabled: boolean

	-- The force applied to the motor joint.
	force: number

	-- The speed of the motor joint.
	speed: number
end

local record MotorJointClass
	type Type = MotorJoint
end

local motorJointClass: MotorJointClass
return motorJointClass
