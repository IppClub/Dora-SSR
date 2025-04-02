-- 只包含红色、绿色和蓝色通道的颜色类。
local record Color3
	userdata

	-- 颜色的红色通道，取值为 0 到 255 之间。
	r: integer

	-- 颜色的绿色通道，取值为 0 到 255 之间。
	g: integer

	-- 颜色的蓝色通道，取值为 0 到 255 之间。
	b: integer

	-- 将颜色转换为RGB整数值。
	-- @return (integer) 转换后的RGB整数。
	toRGB: function(self: Color3): integer
end

-- 用于创建`Color3`对象的类。
local record Color3Class
	type Type = Color3

	-- 创建所有通道设置为0的颜色。
	-- @return (Color3) 新的`Color3`对象。
	metamethod __call: function(self: Color3Class): Color3

	-- 从RGB整数值创建新的`Color3`对象。
	-- @param rgb (integer) 从中创建颜色的RGB整数值。
	-- 例如：0xffffff（白色），0xff0000（红色）。
	-- @return (Color3) 新的`Color3`对象。
	metamethod __call: function(self: Color3Class, rgb: integer): Color3

	-- 从RGB颜色通道值创建新的`Color3`对象。
	-- @param r (number) 红色通道值（0-255）。
	-- @param g (number) 绿色通道值（0-255）。
	-- @param b (number) 蓝色通道值（0-255）。
	-- @return (Color3) 新的`Color3`对象。
	metamethod __call: function(self: Color3Class, r: number, g: number, b: number): Color3
end

local color3Class: Color3Class
return color3Class
