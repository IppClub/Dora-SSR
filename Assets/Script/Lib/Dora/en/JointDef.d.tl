local Vec2 = require("Vec2").Type
local Object = require("Object").Type

-- A record that defines the properties of a joint to be created.
local record JointDef

	-- Inherits from `Object`.
	embed Object

	-- The center point of the joint, in local coordinates.
	center: Vec2

	-- The position of the joint, in world coordinates.
	position: Vec2

	-- The angle of the joint, in degrees.
	angle: number
end

-- A record for creating JointDef objects.
local record JointDefClass
	type Type = JointDef

	-- Creates a distance joint definition.
	-- @param canCollide (boolean) Whether or not the physics body connected to joint will collide with each other.
	-- @param bodyA (string) The name of first physics body to connect with the joint.
	-- @param bodyB (string) The name of second physics body to connect with the joint.
	-- @param anchorA (Vec2) The position of the joint on the first physics body.
	-- @param anchorB (Vec2) The position of the joint on the second physics body.
	-- @param frequency (number) The frequency of the joint, in Hertz (default is 0.0).
	-- @param damping (number) The damping ratio of the joint (default is 0.0).
	-- @return (JointDef) The new joint definition.
	distance: function(self: JointDefClass,
		canCollide: boolean,
		bodyA: string,
		bodyB: string,
		anchorA: Vec2,
		anchorB: Vec2,
		frequency?: number --[[0.0]],
		damping?: number --[[0.0]]): JointDef

	-- Creates a friction joint definition.
	-- @param canCollide (boolean) Whether or not the physics body connected to joint will collide with each other.
	-- @param bodyA (Body) The name of first physics body to connect with the joint.
	-- @param bodyB (Body) The name of second physics body to connect with the joint.
	-- @param worldPos (Vec2) The position of the joint in the game world.
	-- @param maxForce (number) The maximum force that can be applied to the joint.
	-- @param maxTorque (number) The maximum torque that can be applied to the joint.
	-- @return (Joint) The new friction joint definition.
	friction: function(self: JointDefClass,
		canCollide: boolean,
		bodyA: string,
		bodyB: string,
		worldPos: Vec2,
		maxForce: number,
		maxTorque: number): JointDef

	-- Creates a gear joint definition.
	-- @param canCollide (boolean) Whether or not the physics bodies connected to the joint can collide with each other.
	-- @param jointA (Joint) The name of first joint to connect with the gear joint.
	-- @param jointB (Joint) The name of second joint to connect with the gear joint.
	-- @param ratio (number) The gear ratio (default is 1.0).
	-- @return (Joint) The new gear joint definition.
	gear: function(self: JointDefClass,
		canCollide: boolean,
		jointA: string,
		jointB: string,
		ratio?: number --[[1.0]]): JointDef

	-- Creates a new spring joint definition.
	-- @param canCollide (boolean) Whether the connected bodies should collide with each other.
	-- @param bodyA (Body) The name of first body connected to the joint.
	-- @param bodyB (Body) The name of second body connected to the joint.
	-- @param linearOffset (Vec2) Position of body-B minus the position of body-A, in body-A's frame.
	-- @param angularOffset (number) Angle of body-B minus angle of body-A.
	-- @param maxForce (number) The maximum force the joint can exert.
	-- @param maxTorque (number) The maximum torque the joint can exert.
	-- @param correctionFactor (number) Optional correction factor, defaults to 1.0.
	-- @return (Joint) The created joint definition.
	spring: function(self: JointDefClass,
		canCollide: boolean,
		bodyA: string,
		bodyB: string,
		linearOffset: Vec2,
		angularOffset: number,
		maxForce: number,
		maxTorque: number,
		correctionFactor?: number --[[1.0]]): JointDef

	-- Creates a new prismatic joint definition.
	-- @param canCollide (boolean) Whether the connected bodies should collide with each other.
	-- @param bodyA (Body) The name of first body connected to the joint.
	-- @param bodyB (Body) The name of second body connected to the joint.
	-- @param worldPos (Vec2) The world position of the joint.
	-- @param axisAngle (number) The axis angle of the joint.
	-- @param lowerTranslation (number) Optional lower translation limit, defaults to 0.0.
	-- @param upperTranslation (number) Optional upper translation limit, defaults to 0.0.
	-- @param maxMotorForce (number) Optional maximum motor force, defaults to 0.0.
	-- @param motorSpeed (number) Optional motor speed, defaults to 0.0.
	-- @return (MotorJoint) The created prismatic joint definition.
	prismatic: function(self: JointDefClass,
		canCollide: boolean,
		bodyA: string,
		bodyB: string,
		worldPos: Vec2,
		axisAngle: number,
		lowerTranslation?: number --[[0.0]],
		upperTranslation?: number --[[0.0]],
		maxMotorForce?: number --[[0.0]],
		motorSpeed?: number --[[0.0]]): JointDef

	-- Create a pulley joint definition.
	-- @param canCollide (boolean) Whether or not the connected bodies will collide with each other.
	-- @param bodyA (Body) The name of first physics body to connect.
	-- @param bodyB (Body) The name of second physics body to connect.
	-- @param anchorA (Vec2) The position of the anchor point on the first body.
	-- @param anchorB (Vec2) The position of the anchor point on the second body.
	-- @param groundAnchorA (Vec2) The position of the ground anchor point on the first body in world coordinates.
	-- @param groundAnchorB (Vec2) The position of the ground anchor point on the second body in world coordinates.
	-- @param ratio (number) [optinal] The pulley ratio (default 1.0).
	-- @return (Joint) The pulley joint definition.
	pulley: function(self: JointDefClass,
		canCollide: boolean,
		bodyA: string,
		bodyB: string,
		anchorA: Vec2,
		anchorB: Vec2,
		groundAnchorA: Vec2,
		groundAnchorB: Vec2,
		ratio?: number --[[1.0]]): JointDef

	-- Create a revolute joint definition.
	-- @param canCollide (boolean) Whether or not the connected bodies will collide with each other.
	-- @param bodyA (Body) The name of first physics body to connect.
	-- @param bodyB (Body) The name of second physics body to connect.
	-- @param worldPos (Vec2) The position in world coordinates where the joint will be created.
	-- @param lowerAngle (number) [optinal] The lower angle limit (radians) (default 0.0).
	-- @param upperAngle (number) [optinal] The upper angle limit (radians) (default 0.0).
	-- @param maxMotorTorque (number) [optinal] The maximum torque that can be applied to the joint to achieve the target speed (default 0.0).
	-- @param motorSpeed (number) [optinal] The desired speed of the joint (default 0.0).
	-- @return (MotorJoint) The revolute joint definition.
	revolute: function(self: JointDefClass,
		canCollide: boolean,
		bodyA: string,
		bodyB: string,
		worldPos: Vec2,
		lowerAngle?: number --[[0.0]],
		upperAngle?: number --[[0.0]],
		maxMotorTorque?: number --[[0.0]],
		motorSpeed?: number --[[0.0]]): JointDef

	-- Create a rope joint definition.
	-- @param canCollide (boolean) Whether or not the connected bodies will collide with each other.
	-- @param bodyA (Body) The name of first physics body to connect.
	-- @param bodyB (Body) The name of second physics body to connect.
	-- @param anchorA (Vec2) The position of the anchor point on the first body.
	-- @param anchorB (Vec2) The position of the anchor point on the second body.
	-- @param maxLength (number) [optinal] The maximum distance between the anchor points (default 0.0).
	-- @return (Joint) The rope joint definition.
	rope: function(self: JointDefClass,
		canCollide: boolean,
		bodyA: string,
		bodyB: string,
		anchorA: Vec2,
		anchorB: Vec2,
		maxLength: number): JointDef

	-- Creates a weld joint definition.
	-- @param canCollide (boolean) Whether or not the bodies connected to the joint can collide with each other.
	-- @param bodyA (Body) The name of first body to be connected by the joint.
	-- @param bodyB (Body) The name of second body to be connected by the joint.
	-- @param worldPos (Vec2) The position in the world to connect the bodies together.
	-- @param frequency (number) [optional] The frequency at which the joint should be stiff, defaults to 0.0.
	-- @param damping (number) [optional] The damping rate of the joint, defaults to 0.0.
	-- @return (Joint) The newly created weld joint definition.
	weld: function(self: JointDefClass,
		canCollide: boolean,
		bodyA: string,
		bodyB: string,
		worldPos: Vec2,
		frequency?: number --[[0.0]],
		damping?: number --[[0.0]]): JointDef

	-- Creates a wheel joint definition.
	-- @param canCollide (boolean) Whether or not the bodies connected to the joint can collide with each other.
	-- @param bodyA (Body) The name of first body to be connected by the joint.
	-- @param bodyB (Body) The name of second body to be connected by the joint.
	-- @param worldPos (Vec2) The position in the world to connect the bodies together.
	-- @param axisAngle (number) The angle of the joint axis in radians.
	-- @param maxMotorTorque (number) [optional] The maximum torque the joint motor can exert, defaults to 0.0.
	-- @param motorSpeed (number) [optional] The target speed of the joint motor, defaults to 0.0.
	-- @param frequency (number) [optional] The frequency at which the joint should be stiff, defaults to 2.0.
	-- @param damping (number) [optional] The damping rate of the joint, defaults to 0.7.
	-- @return (MotorJoint) The newly created wheel joint definition.
	wheel: function(self: JointDefClass,
		canCollide: boolean,
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
