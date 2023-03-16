local type Size = require("SizeType")
local type Vec2 = require("Vec2Type")
local record SizeClass
	type Type = Size
	metamethod __call: function(
		cls: SizeClass,
		width?: number --[[0]],
		height?: number --[[0]]
	): Size
	metamethod __call: function(cls: SizeClass, other: Size): Size
	metamethod __call: function(cls: SizeClass, vec: Vec2): Size
	const zero: Size
end
local sizeClass: SizeClass
return sizeClass
