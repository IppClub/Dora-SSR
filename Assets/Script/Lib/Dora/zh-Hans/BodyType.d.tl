local Node = require("Node").Type
local BodyDef = require("BodyDef").Type
local Vec2 = require("Vec2").Type
local Object = require("Object").Type
local FixtureDef = require("FixtureDef").Type
local type Sensor = require("SensorType")
local type PhysicsWorld = require("PhysicsWorldType")

-- 物理世界中的物理体类。
local record Body

	-- 继承自“Node”。
	embed Node

	-- 物理体所属的物理世界。
	const world: PhysicsWorld

	-- 物理体的定义。
	const bodyDef: BodyDef

	-- 物理体的质量。
	const mass: number

	-- 物理体是否被用作传感器。
	const sensor: boolean

	-- 物理体的 x 轴速度。
	velocityX: number

	-- 物理体的 y 轴速度。
	velocityY: number

	-- “Vec2”对象表示的物理体的速度。
	velocity: Vec2

	-- 物理体的角速率。
	angularRate: number

	-- 物理体所属的碰撞组编号。
	group: integer

	-- 物理体的线性阻尼。
	linearDamping: number

	-- 物理体的旋转阻尼。
	angularDamping: number

	-- 物理体的所有者。
	owner: Object

	-- 物理体当前是否会接收碰撞接触事件。
	receivingContact: boolean

	-- 在指定位置对物理体施加线性冲量。
	-- @param impulse (Vec2) 要施加的线性冲量。
	-- @param pos (Vec2) 施加冲量的位置。
	applyLinearImpulse: function(self: Body, impulse: Vec2, pos: Vec2)

	-- 对物理体施加角冲量。
	-- @param impulse (number) 要施加的角冲量。
	applyAngularImpulse: function(self: Body, impulse: number)

	-- 从物理体中移除具有指定标签的传感器。
	-- @param tag (integer) 要移除的传感器的标签编号。
	-- @return (boolean) 是否找到并删除具有指定标签的传感器。
	removeSensorByTag: function(self: Body, tag: integer): boolean

	-- 将混合物添加到物理体上。
	-- @param fixtureDef (FixtureDef) 要添加的混合物的定义。
	attach: function(self: Body, fixtureDef: FixtureDef)

	-- 获取具有特定标签编号的传感器。
	-- @param tag (integer) 要获取的传感器的标签编号。
	-- @return (Sensor) 具有给定标签的传感器。
	getSensorByTag: function(self: Body, tag: integer): Sensor

	-- 从物理体的传感器列表中移除特定的传感器。
	-- @param sensor (Sensor) 要移除的传感器。
	-- @return (boolean) 如果成功删除传感器，则为true，否则为false。
	removeSensor: function(self: Body, sensor: Sensor): boolean

	-- 将具有特定标签编号和混合物定义的新传感器添加到物理体上。
	-- @param tag (integer) 要添加的传感器的标签编号。
	-- @param fixtureDef (FixtureDef) 传感器的混合物定义。
	-- @return (Sensor) 新建的传感器。
	attachSensor: function(self: Body, tag: integer, fixtureDef: FixtureDef): Sensor

	-- 注册一个函数，该函数在物理体与其他物理体发生碰撞时被调用。
	-- 当注册的函数返回false时，物理体将不会触发本次的碰撞事件。
	-- @param filter (function) 碰撞过滤器函数。
	-- 	@param other (Body) 与物理体发生碰撞的其他物理体。
	-- 	@return (boolean) 是否允许物理体与其他物理体发生碰撞。
	onContactFilter: function(self: Body, filter: function(other: Body): boolean)

	-- 注册一个函数，当物理体进入传感器时被调用。
	-- @param callback (function) 物理体进入传感器时的回调函数。
	-- 	@param other (Body) 进入传感器的物理体。
	-- 	@param sensorTag (integer) 触发此碰撞的传感器的标签。
	onBodyEnter: function(self: Body, callback: function(other: Body, sensorTag: integer))

	-- 注册一个函数，当物理体离开传感器时被调用。
	-- @param callback (function) 物理体离开传感器时的回调函数。
	-- 	@param other (Body) 离开传感器的物理体。
	-- 	@param sensorTag (integer) 触发此碰撞的传感器的标签。
	onBodyLeave: function(self: Body, callback: function(other: Body, sensorTag: integer))

	-- 注册一个函数，当物理体开始与另一个物体发生碰撞时被调用。
	-- 该函数将设置`receivingContact`属性为true。
	-- @param callback (function) 物理体开始与另一个物体发生碰撞时的回调函数。
	-- 	@param other (Body) 物理体开始与之碰撞的另一个物体。
	-- 	@param point (Vec2) 世界坐标中的碰撞点。
	-- 	@param normal (Vec2) 世界坐标中的接触表面的法向量。
	-- 	@param enabled (boolean) 碰撞是否启用。被过滤的碰撞仍会触发此事件，但启用状态将为false。
	onContactStart: function(self: Body, callback: function(other: Body, point: Vec2, normal: Vec2, enabled: boolean))

	-- 注册一个函数，当物理体停止与另一个物体发生碰撞时被调用。
	-- 该函数将设置`receivingContact`属性为true。
	-- @param callback (function) 物理体停止与另一个物体发生碰撞时的回调函数。
	-- 	@param other (Body) 物理体不再与之碰撞的另一个物体。
	-- 	@param point (Vec2) 世界坐标中的碰撞点。
	-- 	@param normal (Vec2) 世界坐标中的接触表面的法向量。
	onContactEnd: function(self: Body, callback: function(other: Body, point: Vec2, normal: Vec2))
end

return Body
