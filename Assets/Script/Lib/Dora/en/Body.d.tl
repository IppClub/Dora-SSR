local BodyDef = require("BodyDef").Type
local Vec2 = require("Vec2").Type
local type Body = require("BodyType")
local type Sensor = require("SensorType")
local type PhysicsWorld = require("PhysicsWorldType")

-- This is just a demonstration record showing some signal slot events that are used when the receivingContact property of a Body is set to true. And they are meant to be used for collision detection between Body objects.
-- @usage
-- -- you can register for these events using codes
-- body.receivingContact = true
-- body:slot("ContactStart", function(other: Body, point: Vec2, normal: Vec2, enabled: boolean)
-- 	print("A body has contacted", other, point, normal, enabled)
-- end)
local record __SLOT__

	-- Triggers when a Body object collides with a sensor object. This event triggers only when the Body attached with any fixture as sensor.
	-- @param other (Body) The other Body object that the current Body is colliding with.
	-- @param sensorTag (integer) The tag of the sensor that triggered this collision.
	["BodyEnter"]: function(other: Body, sensorTag: integer)

	-- Triggers when a `Body` object is no longer colliding with a sensor object. This event triggers only when the Body attached with any fixture as sensor.
	-- @param other (Body) The other `Body` object that the current `Body` is no longer colliding with.
	-- @param sensorTag (integer) The tag of the sensor that triggered this collision.
	["BodyLeave"]: function(other: Body, sensorTag: integer)

	-- Triggers when a `Body` object starts to collide with another object. This event triggers only when the `receivingContact` property of the `Body` is set to true.
	-- @param other (Body) The other `Body` object that the current `Body` is colliding with.
	-- @param point (Vec2) The point of collision in world coordinates.
	-- @param normal (Vec2) The normal vector of the contact surface in world coordinates.
	-- @param enabled (boolean) Whether the contact is enabled or not. Collisions that are filtered out will still trigger this event, but the enabled state will be false.
	["ContactStart"]: function(other: Body, point: Vec2, normal: Vec2, enabled: boolean)

	-- Triggers when a `Body` object stops colliding with another object. This event triggers only when the `receivingContact` property of the `Body` is set to true.
	-- @param other (Body) The other `Body` object that the current `Body` is no longer colliding with.
	-- @param point (Vec2) The point of collision in world coordinates.
	-- @param normal (Vec2) The normal vector of the contact surface in world coordinates.
	["ContactEnd"]: function(other: Body, point: Vec2, normal: Vec2)
end

-- A class for creating Body objects.
local record BodyClass
	type Type = Body

	-- Creates a new instance of `Body`.
	-- @param def (BodyDef) The definition for the body to be created.
	-- @param world (PhysicsWorld) The physics world where the body belongs.
	-- @param pos (Vec2) [optional] The initial position of the body. Defaults to zero vector.
	-- @param rot (number) [optional] The initial rotation angle of the body in degrees. Defaults to 0.
	-- @return (Body) The newly created `Body` instance.
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
