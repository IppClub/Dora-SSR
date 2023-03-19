local Vec2 = require("Vec2").Type
local Object = require("Object").Type
local record JointDef
	embed Object
	center: Vec2
	position: Vec2
	angle: number
end
local record JointDefClass
	type Type = JointDef
	distance: function(self: JointDefClass,
		collision: boolean,
		bodyA: string,
		bodyB: string,
		anchorA: Vec2,
		anchorB: Vec2,
		frequency?: number --[[0.0]],
		damping?: number --[[0.0]]): JointDef
	friction: function(self: JointDefClass,
		collision: boolean,
		bodyA: string,
		bodyB: string,
		worldPos: Vec2,
		maxForce: number,
		maxTorque: number): JointDef
	gear: function(self: JointDefClass,
		collision: boolean,
		jointA: string,
		jointB: string,
		ratio?: number --[[1.0]]): JointDef
	spring: function(self: JointDefClass,
		collision: boolean,
		bodyA: string,
		bodyB: string,
		linearOffset: Vec2,
		angularOffset: number,
		maxForce: number,
		maxTorque: number,
		correctionFactor?: number --[[1.0]]): JointDef
	prismatic: function(self: JointDefClass,
		collision: boolean,
		bodyA: string,
		bodyB: string,
		worldPos: Vec2,
		axisAngle: number,
		lowerTranslation?: number --[[0.0]],
		upperTranslation?: number --[[0.0]],
		maxMotorForce?: number --[[0.0]],
		motorSpeed?: number --[[0.0]]): JointDef
	pulley: function(self: JointDefClass,
		collision: boolean,
		bodyA: string,
		bodyB: string,
		anchorA: Vec2,
		anchorB: Vec2,
		groundAnchorA: Vec2,
		groundAnchorB: Vec2,
		ratio?: number --[[1.0]]): JointDef
	revolute: function(self: JointDefClass,
		collision: boolean,
		bodyA: string,
		bodyB: string,
		worldPos: Vec2,
		lowerAngle?: number --[[0.0]],
		upperAngle?: number --[[0.0]],
		maxMotorTorque?: number --[[0.0]],
		motorSpeed?: number --[[0.0]]): JointDef
	rope: function(self: JointDefClass,
		collision: boolean,
		bodyA: string,
		bodyB: string,
		anchorA: Vec2,
		anchorB: Vec2,
		maxLength: number): JointDef
	weld: function(self: JointDefClass,
		collision: boolean,
		bodyA: string,
		bodyB: string,
		worldPos: Vec2,
		frequency?: number --[[0.0]],
		damping?: number --[[0.0]]): JointDef
	wheel: function(self: JointDefClass,
		collision: boolean,
		bodyA: string,
		bodyB: string,
		worldPos: Vec2,
		axisAngle: number,
		maxMotorTorque?: number --[[0.0]],
		motorSpeed?: number --[[0.0]],
		frequency?: number --[[2.0]],
		damping?: number --[[0.7]]): JointDef
end
local jointDefClass: JointDefClass
return jointDefClass
