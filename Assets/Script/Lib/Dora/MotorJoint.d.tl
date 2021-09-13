local Joint = require("JointBase")
local record MotorJoint
	embed Joint
	enabled: boolean
	force: number
	speed: number
end
local record MotorJointClass
	type Type = MotorJoint
end
local motorJointClass: MotorJointClass
return motorJointClass
