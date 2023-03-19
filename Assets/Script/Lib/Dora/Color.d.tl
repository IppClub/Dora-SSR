local Color3 = require("Color3").Type
local record Color
	userdata
	r: integer
	g: integer
	b: integer
	a: integer
	opacity: number
	toColor3: function(self: Color): Color3
	toARGB: function(self: Color): integer
end
local record ColorClass
	type Type = Color
	metamethod __call: function(self: ColorClass): Color
	metamethod __call: function(self: ColorClass, color: Color3, a: integer): Color
	metamethod __call: function(self: ColorClass, argb: integer): Color
	metamethod __call: function(self: ColorClass, r: integer, g: integer, b: integer, a: integer): Color
end
local colorClass: ColorClass
return colorClass
