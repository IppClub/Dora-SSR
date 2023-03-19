local type Size = require("SizeType")
local type Vec2 = require("Vec2Type")
local record Vec2Class
	type Type = Vec2
	metamethod __call: function(self: Vec2Class, other: Vec2): Vec2
	metamethod __call: function(
		self: Vec2Class,
		x: number,
		y: number
	): Vec2
	metamethod __call: function(self: Vec2Class, size: Size): Vec2
	const zero: Vec2
end
local vec2Class: Vec2Class
return vec2Class
