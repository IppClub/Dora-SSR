local Joint = require("JointBase")
local Vec2 = require("Vec2").Type
local record MoveJoint
	embed Joint
	position: Vec2
end
local record MoveJointClass
	type Type = MoveJoint
end
print(MoveJoint.position)
local moveJointClass: MoveJointClass
return moveJointClass
