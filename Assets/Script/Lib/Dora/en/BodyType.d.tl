local Node = require("Node").Type
local BodyDef = require("BodyDef").Type
local Vec2 = require("Vec2").Type
local Object = require("Object").Type
local FixtureDef = require("FixtureDef").Type
local type Sensor = require("SensorType")
local type PhysicsWorld = require("PhysicsWorldType")

-- A class represents a physics body in the world.
local record Body

	-- Inherits from `Node`.
	embed Node

	-- The physics world that the body belongs to.
	const world: PhysicsWorld

	-- The definition of the body.
	const bodyDef: BodyDef

	-- The mass of the body.
	const mass: number

	-- Whether the body is used as a sensor or not.
	const sensor: boolean

	-- The x-axis velocity of the body.
	velocityX: number

	-- The y-axis velocity of the body.
	velocityY: number

	-- The velocity of the body as a `Vec2`.
	velocity: Vec2

	-- The angular rate of the body.
	angularRate: number

	-- The collision group that the body belongs to.
	group: integer

	-- The linear damping of the body.
	linearDamping: number

	-- The angular damping of the body.
	angularDamping: number

	-- The reference for an owner of the body.
	owner: Object

	-- Whether the body is currently receiving contact events or not.
	receivingContact: boolean

	-- Applies a linear impulse to the body at a specified position.
	-- @param impulse (Vec2) The linear impulse to apply.
	-- @param pos (Vec2) The position at which to apply the impulse.
	applyLinearImpulse: function(self: Body, impulse: Vec2, pos: Vec2)

	-- Applies an angular impulse to the body.
	-- @param impulse (number) The angular impulse to apply.
	applyAngularImpulse: function(self: Body, impulse: number)

	-- Removes the sensor with the specified tag from the body.
	-- @param tag (integer) The tag of the sensor to remove.
	-- @return (boolean) Whether a sensor with the specified tag was found and removed.
	removeSensorByTag: function(self: Body, tag: integer): boolean

	-- Attaches a fixture to the body.
	-- @param fixtureDef (FixtureDef) The fixture definition for the fixture to attach.
	attach: function(self: Body, fixtureDef: FixtureDef)

	-- Returns the sensor with the given tag.
	-- @param tag (integer) the tag of the sensor to get.
	-- @return (Sensor) the sensor with the given tag.
	getSensorByTag: function(self: Body, tag: integer): Sensor

	-- Removes the given sensor from the body's sensor list.
	-- @param sensor (Sensor) the sensor to remove.
	-- @return (boolean) true if the sensor was successfully removed, false otherwise.
	removeSensor: function(self: Body, sensor: Sensor): boolean

	-- Attaches a new sensor with the given tag and fixture definition to the body.
	-- @param tag (integer) the tag of the sensor to attach.
	-- @param fixtureDef (FixtureDef) the fixture definition of the sensor.
	-- @return (Sensor) the newly attached sensor.
	attachSensor: function(self: Body, tag: integer, fixtureDef: FixtureDef): Sensor

	-- Register a function to be called when the body begins to receive contact events. Return false from this function to prevent colliding.
	-- @param filter (function) The filter function to set.
	onContactFilter: function(self: Body, filter: function(other: Body): boolean)
end

return Body
