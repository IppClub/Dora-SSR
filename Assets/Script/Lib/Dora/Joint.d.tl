local Vec2 = require("Vec2").Type
local Body = require("Body").Type
local JointDef = require("JointDef").Type
local Dictionary = require("Dictionary").Type
local MoveJoint = require("MoveJoint").Type
local MotorJoint = require("MotorJoint").Type
local Joint = require("JointType")
local record JointClass
	type Type = Joint
	distance: function(self: JointClass,
		collision: boolean,
		bodyA: Body,
		bodyB: Body,
		anchorA: Vec2,
		anchorB: Vec2,
		frequency?: number --[[0.0]],
		damping?: number --[[0.0]]): Joint
	friction: function(self: JointClass,
		collision: boolean,
		bodyA: Body,
		bodyB: Body,
		worldPos: Vec2,
		maxForce: number,
		maxTorque: number): Joint
	gear: function(self: JointClass,
		collision: boolean,
		jointA: Joint,
		jointB: Joint,
		ratio?: number --[[1.0]]): Joint
	spring: function(self: JointClass,
		collision: boolean,
		bodyA: Body,
		bodyB: Body,
		linearOffset: Vec2,
		angularOffset: number,
		maxForce: number,
		maxTorque: number,
		correctionFactor?: number --[[1.0]]): Joint
	move: function(self: JointClass,
		collision: boolean,
		body: Body,
		targetPos: Vec2,
		maxForce: number,
		frequency?: number --[[5.0]],
		damping?: number --[[0.7]]): MoveJoint
	prismatic: function(self: JointClass,
		collision: boolean,
		bodyA: Body,
		bodyB: Body,
		worldPos: Vec2,
		axisAngle: number,
		lowerTranslation?: number --[[0.0]],
		upperTranslation?: number --[[0.0]],
		maxMotorForce?: number --[[0.0]],
		motorSpeed?: number --[[0.0]]): MotorJoint
	pulley: function(self: JointClass,
		collision: boolean,
		bodyA: Body,
		bodyB: Body,
		anchorA: Vec2,
		anchorB: Vec2,
		groundAnchorA: Vec2,
		groundAnchorB: Vec2,
		ratio?: number --[[1.0]]): Joint
	revolute: function(self: JointClass,
		collision: boolean,
		bodyA: Body,
		bodyB: Body,
		worldPos: Vec2,
		lowerAngle?: number --[[0.0]],
		upperAngle?: number --[[0.0]],
		maxMotorTorque?: number --[[0.0]],
		motorSpeed?: number --[[0.0]]): MotorJoint
	rope: function(self: JointClass,
		collision: boolean,
		bodyA: Body,
		bodyB: Body,
		anchorA: Vec2,
		anchorB: Vec2,
		maxLength: number): Joint
	weld: function(self: JointClass,
		collision: boolean,
		bodyA: Body,
		bodyB: Body,
		worldPos: Vec2,
		frequency?: number --[[0.0]],
		damping?: number --[[0.0]]): Joint
	wheel: function(self: JointClass,
		collision: boolean,
		bodyA: Body,
		bodyB: Body,
		worldPos: Vec2,
		axisAngle: number,
		maxMotorTorque?: number --[[0.0]],
		motorSpeed?: number --[[0.0]],
		frequency?: number --[[2.0]],
		damping?: number --[[0.7]]): MotorJoint
	metamethod __call: function(self: JointClass, def: JointDef, itemDict: Dictionary): Joint
end
local jointClass: JointClass
return jointClass
