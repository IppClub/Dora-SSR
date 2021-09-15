local BodyBase = require("BodyBase")
local PhysicsWorld = require("PhysicsWorldBase")
local BodyDef = require("BodyDef").Type
local Vec2 = require("Vec2").Type
local Object = require("Object").Type
local Sensor = require("Sensor").Type
local FixtureDef = require("FixtureDef").Type
local record Body
	embed BodyBase
	const world: PhysicsWorld
	const bodyDef: BodyDef
	const mass: number
	const sensor: boolean
	velocityX: number
	velocityY: number
	velocity: Vec2
	angularRate: number
	group: integer
	linearDamping: number
	angularDamping: number
	owner: Object
	receivingContact: boolean
	emittingEvent: boolean
	applyLinearImpulse: function(self: Body, impulse: Vec2, pos: Vec2)
	applyAngularImpulse: function(self: Body, impulse: number)
	removeSensorByTag: function(self: Body, tag: integer): boolean
	attach: function(self: Body, fixtureDef: FixtureDef)
	getSensorByTag: function(self: Body, tag: integer): Sensor
	removeSensor: function(self: Body, sensor: Sensor): boolean
	attachSensor: function(self: Body, tag: integer, fixtureDef: FixtureDef): Sensor
end
local record __SLOT__
	-- Body.receivingContact = true
	["BodyEnter"]: function(other: Body, sensor: Sensor)
	["BodyLeave"]: function(other: Body, sensor: Sensor)
	["ContactStart"]: function(other: Body, point: Vec2, normal: Vec2)
	["ContactEnd"]: function(other: Body, point: Vec2, normal: Vec2)
end
local record BodyClass
	type Type = Body
	metamethod __call: function(cls: BodyClass, def: BodyDef, world: PhysicsWorld, pos: Vec2 --[[Vec2.zero]], rot: number --[[0]]): Body -- class
end
print(Body.world)
print(Body.bodyDef)
print(Body.velocity)
print(Body.owner)
print(Body:getSensorByTag())
print(Body:attachSensor())
local bodyClass: BodyClass
return bodyClass
