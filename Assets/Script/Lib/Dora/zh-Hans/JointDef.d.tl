local Vec2 = require("Vec2").Type
local Object = require("Object").Type

-- 定义要创建关节的属性的类。
local record JointDef

	-- 继承自`Object`。
	embed Object

	-- 关节的中心点，以本地坐标表示。
	center: Vec2

	-- 关节的位置，以世界坐标表示。
	position: Vec2

	-- 关节的角度，以度数表示。
	angle: number
end

-- 用于创建关节定义对象的类。
local record JointDefClass
	type Type = JointDef

	-- 创建距离关节定义。
	-- @param canCollide (boolean) 连接到关节的物理体是否会相互碰撞。
	-- @param bodyA (string) 要连接到关节的第一个物理体的名称。
	-- @param bodyB (string) 要连接到关节的第二个物理体的名称。
	-- @param anchorA (Vec2) 第一个物理体上关节的位置。
	-- @param anchorB (Vec2) 第二个物理体上关节的位置。
	-- @param frequency (number) 关节的频率，以赫兹为单位（默认为 0.0）。
	-- @param damping (number) 关节的阻尼比（默认为 0.0）。
	-- @return (JointDef) 新关节定义。
	distance: function(self: JointDefClass,
		canCollide: boolean,
		bodyA: string,
		bodyB: string,
		anchorA: Vec2,
		anchorB: Vec2,
		frequency?: number --[[0.0]],
		damping?: number --[[0.0]]): JointDef

	-- 创建摩擦关节定义。
	-- @param canCollide (boolean) 连接到关节的物理体是否会相互碰撞。
	-- @param bodyA (Body) 要连接到关节的第一个物理体的名称。
	-- @param bodyB (Body) 要连接到关节的第二个物理体的名称。
	-- @param worldPos (Vec2) 关节在游戏世界中的位置。
	-- @param maxForce (number) 可应用于关节的最大力。
	-- @param maxTorque (number) 可应用于关节的最大扭矩。
	-- @return (Joint) 新摩擦关节定义。
	friction: function(self: JointDefClass,
		canCollide: boolean,
		bodyA: string,
		bodyB: string,
		worldPos: Vec2,
		maxForce: number,
		maxTorque: number): JointDef

	-- 创建齿轮关节定义。
	-- @param canCollide (boolean) 连接到关节的物理体是否会相互碰撞。
	-- @param jointA (Joint) 要连接到齿轮关节的第一个关节的名称。
	-- @param jointB (Joint) 要连接到齿轮关节的第二个关节的名称。
	-- @param ratio (number) 齿轮比（默认为 1.0）。
	-- @return (Joint) 新齿轮关节定义。
	gear: function(self: JointDefClass,
		canCollide: boolean,
		jointA: string,
		jointB: string,
		ratio?: number --[[1.0]]): JointDef

	-- 创建一个新的弹簧关节定义。
	-- @param canCollide (boolean) 是否连接的物理体应该彼此碰撞。
	-- @param bodyA (Body) 连接到关节的第一个物理体的名称。
	-- @param bodyB (Body) 连接到关节的第二个物理体的名称。
	-- @param linearOffset (Vec2) 以 body-A 为框架，表示 body-B 位置减去 body-A 位置的偏移量。
	-- @param angularOffset (number) body-B 的角度减去 body-A 的角度。
	-- @param maxForce (number) 关节可以施加的最大力量。
	-- @param maxTorque (number) 关节可以施加的最大扭矩。
	-- @param correctionFactor (number) 可选的校正因子，默认值为 1.0。
	-- @return (Joint) 创建的关节定义。
	spring: function(self: JointDefClass,
		canCollide: boolean,
		bodyA: string,
		bodyB: string,
		linearOffset: Vec2,
		angularOffset: number,
		maxForce: number,
		maxTorque: number,
		correctionFactor?: number --[[1.0]]): JointDef

	-- 创建一个新的移动关节定义。
	-- @param canCollide (boolean) 是否连接的物理体应该彼此碰撞。
	-- @param bodyA (Body) 连接到关节的第一个物理体的名称。
	-- @param bodyB (Body) 连接到关节的第二个物理体的名称。
	-- @param worldPos (Vec2) 关节的世界位置。
	-- @param axisAngle (number) 关节的轴角度。
	-- @param lowerTranslation (number) 可选的下限移动限制，默认值为 0.0。
	-- @param upperTranslation (number) 可选的上限移动限制，默认值为 0.0。
	-- @param maxMotorForce (number) 可选的最大电机力量，默认值为 0.0。
	-- @param motorSpeed (number) 可选的电机速度，默认值为 0.0。
	-- @return (MotorJoint) 创建的移动关节定义。
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

	-- 创建一个滑轮关节定义。
	-- @param canCollide (boolean) 连接的物理体是否应该彼此碰撞。
	-- @param bodyA (Body) 要连接的第一个物理体的名称。
	-- @param bodyB (Body) 要连接的第二个物理体的名称。
	-- @param anchorA (Vec2) 第一个物理体上的固定点的位置。
	-- @param anchorB (Vec2) 第二个物理体上的固定点的位置。
	-- @param groundAnchorA (Vec2) 第一个物理体上的地面固定点的位置，以世界坐标表示。
	-- @param groundAnchorB (Vec2) 第二个物理体上的地面固定点的位置，以世界坐标表示。
	-- @param ratio (number) [可选] 滑轮比率（默认为 1.0）。
	-- @return (Joint) 滑轮关节定义。
	pulley: function(self: JointDefClass,
		canCollide: boolean,
		bodyA: string,
		bodyB: string,
		anchorA: Vec2,
		anchorB: Vec2,
		groundAnchorA: Vec2,
		groundAnchorB: Vec2,
		ratio?: number --[[1.0]]): JointDef

	-- 创建旋转关节定义。
	-- @param canCollide (boolean) 连接的物理体是否会相互碰撞。
	-- @param bodyA (Body) 要连接的第一个物理体的名称。
	-- @param bodyB (Body) 要连接的第二个物理体的名称。
	-- @param worldPos (Vec2) 在世界坐标系中创建关节的位置。
	-- @param lowerAngle (number) [可选] 下限角度限制（弧度）（默认为0.0）。
	-- @param upperAngle (number) [可选] 上限角度限制（弧度）（默认为0.0）。
	-- @param maxMotorTorque (number) [可选] 可施加到关节上以达到目标速度的最大扭矩（默认为0.0）。
	-- @param motorSpeed (number) [可选] 关节的期望速度（默认为0.0）。
	-- @return (MotorJoint) 旋转关节定义。
	revolute: function(self: JointDefClass,
		canCollide: boolean,
		bodyA: string,
		bodyB: string,
		worldPos: Vec2,
		lowerAngle?: number --[[0.0]],
		upperAngle?: number --[[0.0]],
		maxMotorTorque?: number --[[0.0]],
		motorSpeed?: number --[[0.0]]): JointDef

	-- 创建绳索关节定义。
	-- @param canCollide (boolean) 连接的物理体是否会相互碰撞。
	-- @param bodyA (Body) 要连接的第一个物理体的名称。
	-- @param bodyB (Body) 要连接的第二个物理体的名称。
	-- @param anchorA (Vec2) 第一个物理体上锚点的位置。
	-- @param anchorB (Vec2) 第二个物理体上锚点的位置。
	-- @param maxLength (number) [可选] 锚点之间的最大距离（默认为0.0）。
	-- @return (Joint) 绳索关节定义。
	rope: function(self: JointDefClass,
		canCollide: boolean,
		bodyA: string,
		bodyB: string,
		anchorA: Vec2,
		anchorB: Vec2,
		maxLength: number): JointDef

	-- 创建焊接关节定义。
	-- @param canCollide (boolean) 连接到关节的物理体是否可以互相碰撞。
	-- @param bodyA (Body) 第一个要连接到关节的物理体的名称。
	-- @param bodyB (Body) 第二个要连接到关节的物理体的名称。
	-- @param worldPos (Vec2) 在世界中连接物理体的位置。
	-- @param frequency (number) [可选] 关节应该坚硬的频率，默认为 0.0。
	-- @param damping (number) [可选] 关节的阻尼率，默认为 0.0。
	-- @return (Joint) 新创建的焊接关节定义。
	weld: function(self: JointDefClass,
		canCollide: boolean,
		bodyA: string,
		bodyB: string,
		worldPos: Vec2,
		frequency?: number --[[0.0]],
		damping?: number --[[0.0]]): JointDef

	-- 创建轮子关节定义。
	-- @param canCollide (boolean) 连接到关节的物理体是否可以互相碰撞。
	-- @param bodyA (Body) 第一个要连接到关节的物理体的名称。
	-- @param bodyB (Body) 第二个要连接到关节的物理体的名称。
	-- @param worldPos (Vec2) 在世界中连接物理体的位置。
	-- @param axisAngle (number) 关节轴的角度（弧度）。
	-- @param maxMotorTorque (number) [可选] 关节电动机可以施加的最大扭矩，默认为 0.0。
	-- @param motorSpeed (number) [可选] 关节电动机的目标速度，默认为 0.0。
	-- @param frequency (number) [可选] 关节应该坚硬的频率，默认为 2.0。
	-- @param damping (number) [可选] 关节的阻尼率，默认为 0.7。
	-- @return (MotorJoint) 新创建的轮子关节定义。
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
