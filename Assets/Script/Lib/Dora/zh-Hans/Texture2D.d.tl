local Object = require("Object").Type

-- 2D纹理对象的类。
local record Texture2D

	-- 继承自`Object`。
	embed Object

	-- 纹理的宽度，以像素为单位。
	const width: integer

	-- 纹理的高度，以像素为单位。
	const height: integer
end

-- 代表2D纹理对象类的对象。
local record Texture2DClass
	type Type = Texture2D
end

local texture2DClass: Texture2DClass
return texture2DClass
