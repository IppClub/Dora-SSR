local type Vec2 = require("Vec2Type")

-- An interface for handling mouse inputs.
local record Mouse
	userdata

	-- The position of the mouse in the visible window's logical coordinate system, with the origin at the top-left.
	-- For a 2D scene, map it to `View.size`, apply the inverse Camera2D transform, and then call `node:convertToNodeSpace()`.
	-- Camera zoom must be divided rather than multiplied. For 3D node transforms or custom projections, use `node:onMouseMove()` and read `touch.location` instead.
	-- @usage
	-- local node = Node()
	-- local camera = Director.currentCamera as Camera2D.Type
	-- local mouse = Mouse.position
	-- local visualSize = App.visualSize
	-- local viewSize = View.size
	-- local viewPos = Vec2(
	-- 	mouse.x * viewSize.width / visualSize.width - viewSize.width / 2,
	-- 	viewSize.height / 2 - mouse.y * viewSize.height / visualSize.height
	-- ) / camera.zoom
	-- local angle = math.rad(camera.rotation)
	-- local worldPos = Vec2(
	-- 	viewPos.x * math.cos(angle) - viewPos.y * math.sin(angle),
	-- 	viewPos.x * math.sin(angle) + viewPos.y * math.cos(angle)
	-- ) + camera.position
	-- local nodePos = node:convertToNodeSpace(worldPos)
	const position: Vec2

	-- The accumulated mouse movement since the previous frame.
	const delta: Vec2

	-- Whether relative mouse mode is enabled. Relative mode hides and captures the cursor.
	relativeMode: boolean

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
