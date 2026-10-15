local Joint = require("JointType")

-- 用于对物理体施加旋转或线性力的连接关节。
local record MotorJoint

	-- 继承自`Joint`。
	embed Joint

	-- 关节发动机是否启用。
	enabled: boolean

	-- 关节发动机要施加的力。
	force: number

	-- 关节发动机的速度。
	speed: number
end

local record MotorJointClass
	type Type = MotorJoint
end

local motorJointClass: MotorJointClass
return motorJointClass
