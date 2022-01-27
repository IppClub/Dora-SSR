local record Color3
	userdata
	r: integer
	g: integer
	b: integer
	toRGB: function(self: Color3): integer
end
local record Color3Class
	type Type = Color3
	metamethod __call: function(cls: Color3Class): Color3
	metamethod __call: function(cls: Color3Class, rgb: integer): Color3
	metamethod __call: function(cls: Color3Class, r: integer, g: integer, b: integer): Color3
end
local color3Class: Color3Class
return color3Class
