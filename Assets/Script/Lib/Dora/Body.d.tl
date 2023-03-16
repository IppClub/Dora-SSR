local BodyDef = require("BodyDef").Type
local Vec2 = require("Vec2").Type
local type Body = require("BodyType")
local type Sensor = require("SensorType")
local type PhysicsWorld = require("PhysicsWorldType")
local record __SLOT__
	-- with Body.receivingContact = true
	["BodyEnter"]: function(other: Body, sensorTag: integer)
	["BodyLeave"]: function(other: Body, sensorTag: integer)
	["ContactStart"]: function(other: Body, point: Vec2, normal: Vec2)
	["ContactEnd"]: function(other: Body, point: Vec2, normal: Vec2)
end
local record BodyClass
	type Type = Body
	metamethod __call: function(
		cls: BodyClass,
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
