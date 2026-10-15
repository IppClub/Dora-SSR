local BodyDef = require("BodyDef").Type
local Vec2 = require("Vec2").Type
local type Body = require("BodyType")
local type Sensor = require("SensorType")
local type PhysicsWorld = require("PhysicsWorldType")

-- 物理对象碰撞事件的信号槽定义。将物理体对象的“receivingContact“属性设置为true时，可以触发并接收到这些信号槽事件。
-- @usage
-- -- 可以使用以下形式的代码来注册监听这些事件：
-- body.receivingContact = true
-- body:slot("ContactStart", function(other: Body, point: Vec2, normal: Vec2, enabled: boolean)
-- 	print("感应器碰撞到了物理体", other, point, normal, enabled)
-- end)
local record __SLOT__

	-- 当物理体对象与传感器对象碰撞时触发。此事件当物理体附加了传感器时就会触发。
	-- @param other (Body) 当前发生碰撞的物理体对象。
	-- @param sensorTag (integer) 触发此碰撞事件的传感器的标签编号。
	["BodyEnter"]: function(other: Body, sensorTag: integer)

	-- 当物理体对象不再与传感器对象碰撞时触发。此事件当物理体附加了传感器时就会触发。
	-- @param other (Body) 当前结束碰撞的物理体对象。
	-- @param sensorTag (integer) 触发此碰撞事件的传感器的标签。
	["BodyLeave"]: function(other: Body, sensorTag: integer)

	-- 当一个物理体对象开始与另一个物理体碰撞时触发。
	-- 需要将物理体对象的“receivingContact”属性设置为true才会触发。
	-- @param other (Body) 被碰撞的物理体对象。
	-- @param point (Vec2) 世界坐标系中的碰撞点。
	-- @param normal (Vec2) 世界坐标系中的接触表面法向量。
	-- @param enabled (boolean) 碰撞是否启用。被过滤的碰撞仍会触发此事件，但启用状态将为false。
	["ContactStart"]: function(other: Body, point: Vec2, normal: Vec2, enabled: boolean)

	-- 当一个物理体对象停止与另一个物理体碰撞时触发。
	-- 需要将物理体对象的“receivingContact”属性设置为true才会触发。
	-- @param other (Body) 结束碰撞的物理体对象。
	-- @param point (Vec2) 世界坐标系中的碰撞点。
	-- @param normal (Vec2) 世界坐标系中的接触表面法向量。
	["ContactEnd"]: function(other: Body, point: Vec2, normal: Vec2)
end

-- 用于创建物理体对象的类。
local record BodyClass
	type Type = Body

	-- 创建一个新的物理体实例。
	-- @param def (BodyDef) 要创建的物理体的定义。
	-- @param world (PhysicsWorld) 物理体所属的物理世界。
	-- @param pos (Vec2) [可选] 物理体的初始位置。默认为零向量。
	-- @param rot (number) [可选] 物理体的初始旋转角度（以度为单位）。默认为0。
	-- @return (Body) 新创建的物理体实例。
	metamethod __call: function(
		self: BodyClass,
		def: BodyDef,
		world: PhysicsWorld,
		pos?: Vec2 --[[Vec2.zero]],
		rot?: number --[[0]]
	): Body -- class
end

local _: Sensor
print(Body:getSensorByTag(nil))
print(Body:attachSensor(nil, nil))
print(Body.world)

local bodyClass: BodyClass
return bodyClass
