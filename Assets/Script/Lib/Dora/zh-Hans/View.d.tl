local Size = require("Size").Type
local SpriteEffect = require("SpriteEffect").Type

-- A record that provides access to the 3D graphic view.
local record View
	userdata

	-- The size of the view in pixels.
	const size: Size

	-- The standard distance of the view from the origin.
	const standardDistance: number

	-- The aspect ratio of the view.
	const aspectRatio: number

	-- The distance to the near clipping plane.
	nearPlaneDistance: number

	-- The distance to the far clipping plane.
	farPlaneDistance: number

	-- The field of view of the view in degrees.
	fieldOfView: number

	-- The scale factor of the view.
	scale: number

	-- The post effect applied to the view.
	postEffect: SpriteEffect

	-- Whether or not vertical sync is enabled.
	vsync: boolean
end

local view: View
return view
