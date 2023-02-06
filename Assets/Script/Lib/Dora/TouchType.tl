local Object = require("Object").Type
local Vec2 = require("Vec2").Type
local record Touch
	embed Object
	enabled: boolean
	fromMouse: boolean
	const first: boolean
	const id: integer
	const delta: Vec2
	const location: Vec2
	const worldLocation: Vec2
end
print(Touch.delta)
print(Touch.location)
print(Touch.worldLocation)
return Touch
