local Object = require("Object").Type

-- A record represents a 2D texture.
local record Texture2D

	-- Inherits from `Object`.
	embed Object

	-- The width of the texture, in pixels.
	const width: integer

	-- The height of the texture, in pixels.
	const height: integer
end

-- A record represents Texture2D class object.
local record Texture2DClass
	type Type = Texture2D

	-- Creates a texture object from the given file.
	-- @param filename (string) The file name of the texture.
	-- @return (Texture2D) The texture object.
	metamethod __call: function(self: Texture2DClass, filename: string): Texture2D | nil
end

local texture2DClass: Texture2DClass
return texture2DClass
