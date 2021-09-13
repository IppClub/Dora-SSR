local Object = require("Object").Type
local record Texture2D
	embed Object
	const width: integer
	const height: integer
end
local record Texture2DClass
	type Type = Texture2D
end
local texture2DClass: Texture2DClass
return texture2DClass
