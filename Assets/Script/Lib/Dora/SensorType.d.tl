local Object = require("Object").Type
local Array = require("Array").Type
local type Body = require("BodyType")
local record Sensor
	embed Object
	enabled: boolean
	const tag: integer
	const owner: Body
	const sensed: boolean
	const sensedBodies: Array
	contains: function(self: Sensor, body: Body): boolean
end
return Sensor
