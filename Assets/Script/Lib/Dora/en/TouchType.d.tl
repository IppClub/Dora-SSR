local Object = require("Object").Type
local Vec2 = require("Vec2").Type

-- Represents a touch input or mouse click event.
local record Touch

	-- Inherits from `Object`.
	embed Object

	-- Whether touch input is enabled or not.
	enabled: boolean

	-- Whether this is the first touch event when multi-touches exist.
	const first: boolean

	-- The unique identifier assigned to this touch event.
	const id: integer

	-- The amount and direction of movement since the last touch event.
	const delta: Vec2

	-- The location of the touch event in the node's local coordinate system.
	const location: Vec2

	-- The location of the touch event in the world coordinate system.
	const worldLocation: Vec2
end

return Touch
