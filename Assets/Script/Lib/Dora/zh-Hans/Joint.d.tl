local Vec2 = require("Vec2").Type
local Body = require("Body").Type
local JointDef = require("JointDef").Type
local Dictionary = require("Dictionary").Type
local MoveJoint = require("MoveJoint").Type
local MotorJoint = require("MotorJoint").Type
local Joint = require("JointType")

-- 用于创建可以将物体连接在一起的多种关节的工厂类。
local record JointClass
	type Type = Joint

	-- 创建两个物理体之间的距离关节。
	-- @param canCollide (boolean) 是否连接到关节的物理体会彼此碰撞。
	-- @param bodyA (Body) 要连接到关节的第一个物理体。
	-- @param bodyB (Body) 要连接到关节的第二个物理体。
	-- @param anchorA (Vec2) 关节在第一个物理体上的位置。
	-- @param anchorB (Vec2) 关节在第二个物理体上的位置。
	-- @param frequency (number) 关节的频率，单位为赫兹（默认值为 0.0）。
	-- @param damping (number) 关节的阻尼系数（默认值为 0.0）。
	-- @return (Joint) 新的距离关节。
	distance: function(self: JointClass,
		canCollide: boolean,
		bodyA: Body,
		bodyB: Body,
		anchorA: Vec2,
		anchorB: Vec2,
		frequency?: number --[[0.0]],
		damping?: number --[[0.0]]): Joint

	-- 创建两个物理体之间的摩擦关节。
	-- @param canCollide (boolean) 是否连接到关节的物理体会彼此碰撞。
	-- @param bodyA (Body) 要连接到关节的第一个物理体。
	-- @param bodyB (Body) 要连接到关节的第二个物理体。
	-- @param worldPos (Vec2) 关节在游戏世界中的位置。
	-- @param maxForce (number) 可以施加到关节的最大力量。
	-- @param maxTorque (number) 可以施加到关节的最大扭矩。
	-- @return (Joint) 新的摩擦关节。
	friction: function(self: JointClass,
		canCollide: boolean,
		bodyA: Body,
		bodyB: Body,
		worldPos: Vec2,
		maxForce: number,
		maxTorque: number): Joint

	-- 在两个其他关节之间创建齿轮关节。
	-- @param canCollide (boolean) 连接到关节的物理体是否可以彼此碰撞。
	-- @param jointA (Joint) 要连接到齿轮关节的第一个关节。
	-- @param jointB (Joint) 要连接到齿轮关节的第二个关节。
	-- @param ratio (number) 齿轮传动比率（默认值为 1.0）。
	-- @return (Joint) 新的齿轮关节。
	gear: function(self: JointClass,
		canCollide: boolean,
		jointA: Joint,
		jointB: Joint,
		ratio?: number --[[1.0]]): Joint

	-- 创建两个指定物理体之间的新弹簧关节。
	-- @param canCollide (boolean) 指定连接的两个物理体是否应该相互碰撞。
	-- @param bodyA (Body) 连接到关节的第一个物理体。
	-- @param bodyB (Body) 连接到关节的第二个物理体。
	-- @param linearOffset (Vec2) 在物理体A坐标系下，物理体B的位置减去物理体A的位置。
	-- @param angularOffset (number) 物理体B的角度减去物理体A的角度。
	-- @param maxForce (number) 关节能够施加的最大力。
	-- @param maxTorque (number) 关节能够施加的最大扭矩。
	-- @param correctionFactor (number) 可选的纠正系数，默认为1.0。
	-- @return (Joint) 创建的关节。
	spring: function(self: JointClass,
		canCollide: boolean,
		bodyA: Body,
		bodyB: Body,
		linearOffset: Vec2,
		angularOffset: number,
		maxForce: number,
		maxTorque: number,
		correctionFactor?: number --[[1.0]]): Joint

	-- 为指定的刚体创建一个新的拖拽关节。
	-- @param canCollide (boolean) 指定刚体是否可以与其他刚体碰撞。
	-- @param body (Body) 关节连接的刚体。
	-- @param targetPos (Vec2) 刚体应该拖拽到的目标位置。
	-- @param maxForce (number) 关节能够施加的最大力。
	-- @param frequency (number) 可选的频率比率，默认为5.0。
	-- @param damping (number) 可选的阻尼比率，默认为0.7。
	-- @return (MoveJoint) 创建的拖拽关节。
	move: function(self: JointClass,
		canCollide: boolean,
		body: Body,
		targetPos: Vec2,
		maxForce: number,
		frequency?: number --[[5.0]],
		damping?: number --[[0.7]]): MoveJoint

	-- 创建两个指定刚体之间的新移动关节。
	-- @param canCollide (boolean) 指定连接的两个刚体是否应该相互碰撞。
	-- @param bodyA (Body) 连接到关节的第一个刚体。
	-- @param bodyB (Body) 连接到关节的第二个刚体。
	-- @param worldPos (Vec2) 关节的世界坐标。
	-- @param axisAngle (number) 关节的轴角度。
	-- @param lowerTranslation (number) 可选的下限平移量，默认为0.0。
	-- @param upperTranslation (number) 可选的上限平移量，默认为0.0。
	-- @param maxMotorForce (number) 可选的最大电机力，默认为0.0。
	-- @param motorSpeed (number) 可选的电机速度，默认为0.0。
	-- @return (MotorJoint) 创建的移动关节。
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

	-- 在两个物理体之间创建一个滑轮关节。
	-- @param canCollide (boolean) 连接的物体是否会相互碰撞。
	-- @param bodyA (Body) 要连接的第一个物理体。
	-- @param bodyB (Body) 要连接的第二个物理体。
	-- @param anchorA (Vec2) 第一个物体上的锚点的位置。
	-- @param anchorB (Vec2) 第二个物体上的锚点的位置。
	-- @param groundAnchorA (Vec2) 第一个物体上的地面锚点在世界坐标系中的位置。
	-- @param groundAnchorB (Vec2) 第二个物体上的地面锚点在世界坐标系中的位置。
	-- @param ratio (number) [可选] 滑轮比率（默认值为1.0）。
	-- @return (Joint) 滑轮关节。
	pulley: function(self: JointClass,
		canCollide: boolean,
		bodyA: Body,
		bodyB: Body,
		anchorA: Vec2,
		anchorB: Vec2,
		groundAnchorA: Vec2,
		groundAnchorB: Vec2,
		ratio?: number --[[1.0]]): Joint

	-- 在两个物理体之间创建旋转关节。
	-- @param canCollide (boolean) 连接的物体是否会相互碰撞。
	-- @param bodyA (Body) 要连接的第一个物理体。
	-- @param bodyB (Body) 要连接的第二个物理体。
	-- @param worldPos (Vec2) 关节将被创建的世界坐标位置。
	-- @param lowerAngle (number) [可选] 下限角度限制（弧度）（默认为0.0）。
	-- @param upperAngle (number) [可选] 上限角度限制（弧度）（默认为0.0）。
	-- @param maxMotorTorque (number) [可选] 关节施加的最大扭矩以达到目标速度（默认为0.0）。
	-- @param motorSpeed (number) [可选] 关节的期望速度（默认为0.0）。
	-- @return (MotorJoint) 旋转关节。
	revolute: function(self: JointClass,
		canCollide: boolean,
		bodyA: Body,
		bodyB: Body,
		worldPos: Vec2,
		lowerAngle?: number --[[0.0]],
		upperAngle?: number --[[0.0]],
		maxMotorTorque?: number --[[0.0]],
		motorSpeed?: number --[[0.0]]): MotorJoint

	-- 在两个物理体之间创建绳子关节。
	-- @param canCollide (boolean) 连接的物体是否会相互碰撞。
	-- @param bodyA (Body) 要连接的第一个物理体。
	-- @param bodyB (Body) 要连接的第二个物理体。
	-- @param anchorA (Vec2) 第一个物体上的锚点的位置。
	-- @param anchorB (Vec2) 第二个物体上的锚点的位置。
	-- @param maxLength (number) [可选] 锚点之间的最大距离（默认为0.0）。
	-- @return (Joint) 绳子关节。
	rope: function(self: JointClass,
		canCollide: boolean,
		bodyA: Body,
		bodyB: Body,
		anchorA: Vec2,
		anchorB: Vec2,
		maxLength: number): Joint

	-- 创建两个物体之间的焊接关节。
	-- @param canCollide (boolean) 是否允许连接的物体之间发生碰撞。
	-- @param bodyA (Body) 第一个将被连接的物体。
	-- @param bodyB (Body) 第二个将被连接的物体。
	-- @param worldPos (Vec2) 连接物体的世界位置。
	-- @param frequency (number) [可选] 关节的刚度频率，默认为 0.0。
	-- @param damping (number) [可选] 关节的阻尼比率，默认为 0.0。
	-- @return (Joint) 新创建的焊接关节。
	weld: function(self: JointClass,
		canCollide: boolean,
		bodyA: Body,
		bodyB: Body,
		worldPos: Vec2,
		frequency?: number --[[0.0]],
		damping?: number --[[0.0]]): Joint

	-- 创建两个物体之间的轮子关节。
	-- @param canCollide (boolean) 是否允许连接的物体之间发生碰撞。
	-- @param bodyA (Body) 第一个将被连接的物体。
	-- @param bodyB (Body) 第二个将被连接的物体。
	-- @param worldPos (Vec2) 连接物体的世界位置。
	-- @param axisAngle (number) 关节轴的角度，以弧度为单位。
	-- @param maxMotorTorque (number) [可选] 关节电机可以施加的最大力矩，默认为 0.0。
	-- @param motorSpeed (number) [可选] 关节电机的目标速度，默认为 0.0。
	-- @param frequency (number) [可选] 关节的刚度频率，默认为 2.0。
	-- @param damping (number) [可选] 关节的阻尼比率，默认为 0.7。
	-- @return (MotorJoint) 新创建的轮子关节。
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

	-- 根据给定的关节定义和物理体字典创建关节实例，字典中包含需要连接的物理体。
	-- @param def (JointDef) 关节定义。
	-- @param itemDict (Dictionary) 包含创建关节相关的物理体和关节对象的字典。
	-- @return (Joint) 新创建的关节。
	metamethod __call: function(self: JointClass, def: JointDef, itemDict: Dictionary): Joint
end

local jointClass: JointClass
return jointClass
