local Color3 = require("Color3").Type

-- A color with red, green, blue, and alpha channels.
local record Color
	userdata

	-- The red channel of the color, should be 0 to 255.
	r: integer

	-- The green channel of the color, should be 0 to 255.
	g: integer

	-- The blue channel of the color, should be 0 to 255.
	b: integer

	-- The alpha channel of the color, should be 0 to 255.
	a: integer

	-- Another representation for alpha channel. The opacity of the color, ranging from 0 to 1.
	opacity: number

	-- Converts the color to a Color3 value without alpha channel.
	-- @return (Color3) Converted Color3 value.
	toColor3: function(self: Color): Color3

	-- Converts the color to an ARGB integer value.
	-- @return (integer) Converted ARGB integer.
	toARGB: function(self: Color): integer
end

-- Provides methods for creating Color objects.
local record ColorClass
	type Type = Color

	-- Creates a new Color object with a Color3 object and alpha value.
	-- @param color (Color3) The color as a Color3 object.
	-- @param a (number) [optional] The alpha value of the color ranging from 0 to 255.
	-- @return (Color) A new Color object.
	metamethod __call: function(self: ColorClass, color: Color3, a: number): Color

	-- Creates a new `Color` object from an ARGB integer value.
	-- @param argb (number) [optional] The ARGB integer value to create the color from. Default is 0.
	-- For example 0xffffffff (opaque white), 0x88ff0000 (half transparent red)
	-- @return (Color) A new `Color` object.
	metamethod __call: function(self: ColorClass, argb?: number): Color

	-- Creates a new `Color` object from a RGBA string.
	-- @param rgba (string) The RGBA string to create the color from, format like "#RRGGBBAA".
	-- @return (Color) A new `Color` object.
	metamethod __call: function(self: ColorClass, rgba: string): Color

	-- Creates a new `Color` object from RGBA color channel values.
	-- @param r (number) The red channel value (0-255).
	-- @param g (number) The green channel value (0-255).
	-- @param b (number) The blue channel value (0-255).
	-- @param a (number) The alpha channel value (0-255).
	-- @return (Color) A new `Color` object.
	metamethod __call: function(self: ColorClass, r: number, g: number, b: number, a: number): Color
end

local colorClass: ColorClass
return colorClass
