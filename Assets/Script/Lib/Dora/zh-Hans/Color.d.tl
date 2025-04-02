local Color3 = require("Color3").Type

-- 具有红色、绿色、蓝色和 alpha 通道的颜色类。
local record Color
	userdata

	-- 颜色的红色通道，取值为 0 到 255 之间。
	r: integer

	-- 颜色的绿色通道，取值为 0 到 255 之间。
	g: integer

	-- 颜色的蓝色通道，取值为 0 到 255 之间。
	b: integer

	-- 颜色的透明通道，取值为 0 到 255 之间。
	a: integer

	-- 颜色的透明通道的另一种表示。取值范围从 0 到 1。
	opacity: number

	-- 将颜色转换为没有透明通道的 Color3 对象。
	-- @return (Color3) 转换后的Color3对象。
	toColor3: function(self: Color): Color3

	-- 将颜色转换为 ARGB 整数值。
	-- @return (integer) 转换后的ARGB整数值。
	toARGB: function(self: Color): integer
end

-- 提供用于创建ARGB颜色对象的方法。
local record ColorClass
	type Type = Color

	-- 创建所有通道都设置为 0 的颜色。
	-- @return (Color) 新的颜色对象。
	metamethod __call: function(self: ColorClass): Color

	-- 使用`Color3`对象和透明值创建新的颜色对象。
	-- @param color (Color3) `Color3`颜色对象。
	-- @param a (number) [可选] 颜色的透明值，范围从 0 到 255。
	-- @return (Color) 新的颜色对象。
	metamethod __call: function(self: ColorClass, color: Color3, a: number): Color

	-- 从 ARGB 整数值创建新的颜色对象。
	-- @param argb (integer) 创建颜色的 ARGB 整数值。
	-- 示例：0xffffffff（不透明白色），0x88ff0000（半透明红色）。
	-- @return (Color) 新的颜色对象。
	metamethod __call: function(self: ColorClass, argb: integer): Color

	-- 从 RGBA 颜色通道值创建新的颜色对象。
	-- @param r (number) 红色通道值（0-255）。
	-- @param g (number) 绿色通道值（0-255）。
	-- @param b (number) 蓝色通道值（0-255）。
	-- @param a (number) 透明通道值（0-255）。
	-- @return (Color) 新的颜色对象。
	metamethod __call: function(self: ColorClass, r: number, g: number, b: number, a: number): Color
end

local colorClass: ColorClass
return colorClass
