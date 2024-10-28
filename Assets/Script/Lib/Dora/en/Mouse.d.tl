local type Vec2 = require("Vec2Type")

-- An interface for handling mouse inputs.
local record Mouse
	userdata

	-- The position of the mouse in the visible window.
	-- You can use `Mouse.position * App.devicePixelRatio` to get the coordinate in the game world.
	-- Then use `node:convertToNodeSpace()` to convert the world coordinate to the local coordinate of the node.
	-- @usage
	-- local worldPos = Mouse.position * App.devicePixelRatio
	-- local nodePos = node:convertToNodeSpace(worldPos)
	const position: Vec2

	-- Whether the left mouse button is being pressed down.
	const leftButtonPressed: boolean

	-- Whether the right mouse button is being pressed down.
	const rightButtonPressed: boolean

	-- Whether the middle mouse button is being pressed down.
	const middleButtonPressed: boolean

	-- The mouse wheel value.
	const wheel: Vec2
end

local mouse: Mouse
return mouse
