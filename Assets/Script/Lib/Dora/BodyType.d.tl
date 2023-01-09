local Node = require("Node").Type
local BodyDef = require("BodyDef").Type
local Vec2 = require("Vec2").Type
local Object = require("Object").Type
local FixtureDef = require("FixtureDef").Type
local type Sensor = require("SensorType")
local type PhysicsWorld = require("PhysicsWorldType")
local record Body
	embed Node
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
	applyLinearImpulse: function(self: Body, impulse: Vec2, pos: Vec2)
	applyAngularImpulse: function(self: Body, impulse: number)
	removeSensorByTag: function(self: Body, tag: integer): boolean
	attach: function(self: Body, fixtureDef: FixtureDef)
	getSensorByTag: function(self: Body, tag: integer): Sensor
	removeSensor: function(self: Body, sensor: Sensor): boolean
	attachSensor: function(self: Body, tag: integer, fixtureDef: FixtureDef): Sensor
end
return Body
