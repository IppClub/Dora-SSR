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

	-- 创建一个新的2D纹理对象。
	-- @param filename (string) 纹理的文件路径。
	-- @return (Texture2D) 返回新创建的2D纹理对象。
	metamethod __call: function(self: Texture2DClass, filename: string): Texture2D | nil
end

local texture2DClass: Texture2DClass
return texture2DClass
