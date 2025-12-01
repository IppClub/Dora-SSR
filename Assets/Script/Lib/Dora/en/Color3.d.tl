-- A color with red, green and blue channels.
local record Color3
	userdata

	-- The red channel of the color, should be 0 to 255.
	r: integer

	-- The green channel of the color, should be 0 to 255.
	g: integer

	-- The blue channel of the color, should be 0 to 255.
	b: integer

	-- Converts the color to an RGB integer value.
	-- @return (integer) Converted RGB integer.
	toRGB: function(self: Color3): integer
end

-- A class for creating Color3 objects.
local record Color3Class
	type Type = Color3

	-- Creates a new `Color3` object from an RGB integer value.
	-- @param rgb (number) [optional] The RGB integer value to create the color from. Default is 0.
	-- For example 0xffffff (white), 0xff0000 (red)
	-- @return (Color3) A new `Color3` object.
	metamethod __call: function(self: Color3Class, rgb?: number): Color3

	-- Creates a new `Color3` object from RGB color channel values.
	-- @param r (number) The red channel value (0-255).
	-- @param g (number) The green channel value (0-255).
	-- @param b (number) The blue channel value (0-255).
	-- @return (Color) A new `Color3` object.
	metamethod __call: function(self: Color3Class, r: number, g: number, b: number): Color3
end

local color3Class: Color3Class
return color3Class
