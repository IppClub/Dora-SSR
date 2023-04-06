local Object = require("Object").Type

-- A record represents a 2D texture.
local record Texture2D
	embed Object

	-- The width of the texture, in pixels.
	const width: integer

	-- The height of the texture, in pixels.
	const height: integer
end

-- A record represents Texture2D class object.
local record Texture2DClass
	type Type = Texture2D
end

local texture2DClass: Texture2DClass
return texture2DClass
