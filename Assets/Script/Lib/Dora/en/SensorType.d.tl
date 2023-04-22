local Object = require("Object").Type
local Array = require("Array").Type
local type Body = require("BodyType")

-- A class to represent a physics sensor object in the game world.
local record Sensor

	-- Inherits from `Object`.
	embed Object

	-- Whether the sensor is currently enabled or not.
	enabled: boolean

	-- The tag for the sensor.
	const tag: integer

	-- The "Body" object that owns the sensor.
	const owner: Body

	-- Whether the sensor is currently sensing any other "Body" objects in the game world.
	const sensed: boolean

	-- An array of "Body" objects that are currently being sensed by the sensor.
	const sensedBodies: Array

	-- Determines whether the specified "Body" object is currently being sensed by the sensor.
	-- @param body (Body) The "Body" object to check if it is being sensed.
	-- @return (boolean) True if the "Body" object is being sensed by the sensor, false otherwise.
	contains: function(self: Sensor, body: Body): boolean
end

return Sensor
