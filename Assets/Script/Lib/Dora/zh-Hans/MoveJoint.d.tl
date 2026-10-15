local Joint = require("JointType")
local Vec2 = require("Vec2").Type

-- 用于控制物理体移动到特定位置的物理关节类。
local record MoveJoint

	-- 继承自`Object`。
	embed Joint

	-- 移动关节在游戏世界中的位置。
	position: Vec2
end

local record MoveJointClass
	type Type = MoveJoint
end

local moveJointClass: MoveJointClass
return moveJointClass
