local Vec2 = require("Vec2").Type
local Body = require("Body").Type
local JointDef = require("JointDef").Type
local Dictionary = require("Dictionary").Type
local MoveJoint = require("MoveJoint").Type
local MotorJoint = require("MotorJoint").Type
local Joint = require("JointType")

-- A factory class to create different types of joints that can be used to connect physics bodies together.
local record JointClass
	type Type = Joint

	-- Creates a distance joint between two physics bodies.
	-- @param canCollide (boolean) Whether or not the physics body connected to joint will collide with each other.
	-- @param bodyA (Body) The first physics body to connect with the joint.
	-- @param bodyB (Body) The second physics body to connect with the joint.
	-- @param anchorA (Vec2) The position of the joint on the first physics body.
	-- @param anchorB (Vec2) The position of the joint on the second physics body.
	-- @param frequency (number) The frequency of the joint, in Hertz (default is 0.0).
	-- @param damping (number) The damping ratio of the joint (default is 0.0).
	-- @return (Joint) The new distance joint.
	distance: function(self: JointClass,
		canCollide: boolean,
		bodyA: Body,
		bodyB: Body,
		anchorA: Vec2,
		anchorB: Vec2,
		frequency?: number --[[0.0]],
		damping?: number --[[0.0]]): Joint

	-- Creates a friction joint between two physics bodies.
	-- @param canCollide (boolean) Whether or not the physics body connected to joint will collide with each other.
	-- @param bodyA (Body) The first physics body to connect with the joint.
	-- @param bodyB (Body) The second physics body to connect with the joint.
	-- @param worldPos (Vec2) The position of the joint in the game world.
	-- @param maxForce (number) The maximum force that can be applied to the joint.
	-- @param maxTorque (number) The maximum torque that can be applied to the joint.
	-- @return (Joint) The new friction joint.
	friction: function(self: JointClass,
		canCollide: boolean,
		bodyA: Body,
		bodyB: Body,
		worldPos: Vec2,
		maxForce: number,
		maxTorque: number): Joint

	-- Creates a gear joint between two other joints.
	-- @param canCollide (boolean) Whether or not the physics bodies connected to the joint can collide with each other.
	-- @param jointA (Joint) The first joint to connect with the gear joint.
	-- @param jointB (Joint) The second joint to connect with the gear joint.
	-- @param ratio (number) The gear ratio (default is 1.0).
	-- @return (Joint) The new gear joint.
	gear: function(self: JointClass,
		canCollide: boolean,
		jointA: Joint,
		jointB: Joint,
		ratio?: number --[[1.0]]): Joint

	-- Creates a new spring joint between the two specified bodies.
	-- @param canCollide (boolean) Whether the connected bodies should collide with each other.
	-- @param bodyA (Body) The first body connected to the joint.
	-- @param bodyB (Body) The second body connected to the joint.
	-- @param linearOffset (Vec2) Position of body-B minus the position of body-A, in body-A's frame.
	-- @param angularOffset (number) Angle of body-B minus angle of body-A.
	-- @param maxForce (number) The maximum force the joint can exert.
	-- @param maxTorque (number) The maximum torque the joint can exert.
	-- @param correctionFactor (number) Optional correction factor, defaults to 1.0.
	-- @return (Joint) The created joint.
	spring: function(self: JointClass,
		canCollide: boolean,
		bodyA: Body,
		bodyB: Body,
		linearOffset: Vec2,
		angularOffset: number,
		maxForce: number,
		maxTorque: number,
		correctionFactor?: number --[[1.0]]): Joint

	-- Creates a new move joint for the specified body.
	-- @param canCollide (boolean) Whether the body can collide with other bodies
	-- @param body (Body) The body that the joint is attached to.
	-- @param targetPos (Vec2) The target position that the body should move towards.
	-- @param maxForce (number) The maximum force the joint can exert.
	-- @param frequency (number) Optional frequency ratio, defaults to 5.0.
	-- @param damping (number) Optional damping ratio, defaults to 0.7.
	-- @return (MoveJoint) The created move joint.
	move: function(self: JointClass,
		canCollide: boolean,
		body: Body,
		targetPos: Vec2,
		maxForce: number,
		frequency?: number --[[5.0]],
		damping?: number --[[0.7]]): MoveJoint

	-- Creates a new prismatic joint between the two specified bodies.
	-- @param canCollide (boolean) Whether the connected bodies should collide with each other.
	-- @param bodyA (Body) The first body connected to the joint.
	-- @param bodyB (Body) The second body connected to the joint.
	-- @param worldPos (Vec2) The world position of the joint.
	-- @param axisAngle (number) The axis angle of the joint.
	-- @param lowerTranslation (number) Optional lower translation limit, defaults to 0.0.
	-- @param upperTranslation (number) Optional upper translation limit, defaults to 0.0.
	-- @param maxMotorForce (number) Optional maximum motor force, defaults to 0.0.
	-- @param motorSpeed (number) Optional motor speed, defaults to 0.0.
	-- @return (MotorJoint) The created prismatic joint.
	prismatic: function(self: JointClass,
		canCollide: boolean,
		bodyA: Body,
		bodyB: Body,
		worldPos: Vec2,
		axisAngle: number,
		lowerTranslation?: number --[[0.0]],
		upperTranslation?: number --[[0.0]],
		maxMotorForce?: number --[[0.0]],
		motorSpeed?: number --[[0.0]]): MotorJoint

	-- Create a pulley joint between two physics bodies.
	-- @param canCollide (boolean) Whether or not the connected bodies will collide with each other.
	-- @param bodyA (Body) The first physics body to connect.
	-- @param bodyB (Body) The second physics body to connect.
	-- @param anchorA (Vec2) The position of the anchor point on the first body.
	-- @param anchorB (Vec2) The position of the anchor point on the second body.
	-- @param groundAnchorA (Vec2) The position of the ground anchor point on the first body in world coordinates.
	-- @param groundAnchorB (Vec2) The position of the ground anchor point on the second body in world coordinates.
	-- @param ratio (number) [optinal] The pulley ratio (default 1.0).
	-- @return (Joint) The pulley joint.
	pulley: function(self: JointClass,
		canCollide: boolean,
		bodyA: Body,
		bodyB: Body,
		anchorA: Vec2,
		anchorB: Vec2,
		groundAnchorA: Vec2,
		groundAnchorB: Vec2,
		ratio?: number --[[1.0]]): Joint

	-- Create a revolute joint between two physics bodies.
	-- @param canCollide (boolean) Whether or not the connected bodies will collide with each other.
	-- @param bodyA (Body) The first physics body to connect.
	-- @param bodyB (Body) The second physics body to connect.
	-- @param worldPos (Vec2) The position in world coordinates where the joint will be created.
	-- @param lowerAngle (number) [optinal] The lower angle limit (radians) (default 0.0).
	-- @param upperAngle (number) [optinal] The upper angle limit (radians) (default 0.0).
	-- @param maxMotorTorque (number) [optinal] The maximum torque that can be applied to the joint to achieve the target speed (default 0.0).
	-- @param motorSpeed (number) [optinal] The desired speed of the joint (default 0.0).
	-- @return (MotorJoint) The revolute joint.
	revolute: function(self: JointClass,
		canCollide: boolean,
		bodyA: Body,
		bodyB: Body,
		worldPos: Vec2,
		lowerAngle?: number --[[0.0]],
		upperAngle?: number --[[0.0]],
		maxMotorTorque?: number --[[0.0]],
		motorSpeed?: number --[[0.0]]): MotorJoint


	-- Create a rope joint between two physics bodies.
	-- @param canCollide (boolean) Whether or not the connected bodies will collide with each other.
	-- @param bodyA (Body) The first physics body to connect.
	-- @param bodyB (Body) The second physics body to connect.
	-- @param anchorA (Vec2) The position of the anchor point on the first body.
	-- @param anchorB (Vec2) The position of the anchor point on the second body.
	-- @param maxLength (number) [optinal] The maximum distance between the anchor points (default 0.0).
	-- @return (Joint) The rope joint.
	rope: function(self: JointClass,
		canCollide: boolean,
		bodyA: Body,
		bodyB: Body,
		anchorA: Vec2,
		anchorB: Vec2,
		maxLength: number): Joint

	-- Creates a weld joint between two bodies.
	-- @param canCollide (boolean) Whether or not the bodies connected to the joint can collide with each other.
	-- @param bodyA (Body) The first body to be connected by the joint.
	-- @param bodyB (Body) The second body to be connected by the joint.
	-- @param worldPos (Vec2) The position in the world to connect the bodies together.
	-- @param frequency (number) [optional] The frequency at which the joint should be stiff, defaults to 0.0.
	-- @param damping (number) [optional] The damping rate of the joint, defaults to 0.0.
	-- @return (Joint) The newly created weld joint.
	weld: function(self: JointClass,
		canCollide: boolean,
		bodyA: Body,
		bodyB: Body,
		worldPos: Vec2,
		frequency?: number --[[0.0]],
		damping?: number --[[0.0]]): Joint

	-- Creates a wheel joint between two bodies.
	-- @param canCollide (boolean) Whether or not the bodies connected to the joint can collide with each other.
	-- @param bodyA (Body) The first body to be connected by the joint.
	-- @param bodyB (Body) The second body to be connected by the joint.
	-- @param worldPos (Vec2) The position in the world to connect the bodies together.
	-- @param axisAngle (number) The angle of the joint axis in radians.
	-- @param maxMotorTorque (number) [optional] The maximum torque the joint motor can exert, defaults to 0.0.
	-- @param motorSpeed (number) [optional] The target speed of the joint motor, defaults to 0.0.
	-- @param frequency (number) [optional] The frequency at which the joint should be stiff, defaults to 2.0.
	-- @param damping (number) [optional] The damping rate of the joint, defaults to 0.7.
	-- @return (MotorJoint) The newly created wheel joint.
	wheel: function(self: JointClass,
		canCollide: boolean,
		bodyA: Body,
		bodyB: Body,
		worldPos: Vec2,
		axisAngle: number,
		maxMotorTorque?: number --[[0.0]],
		motorSpeed?: number --[[0.0]],
		frequency?: number --[[2.0]],
		damping?: number --[[0.7]]): MotorJoint

	-- Creates a joint instance based on the given joint definition and item dictionary containing physics bodies to be connected by joint.
	-- @param def (JointDef) The joint definition.
	-- @param itemDict (Dictionary) The dictionary containing all the bodies and other required items.
	-- @return (Joint) The newly created joint.
	metamethod __call: function(self: JointClass, def: JointDef, itemDict: Dictionary): Joint
end

local jointClass: JointClass
return jointClass
