local ContainerItem = require("ContainerItemBase")
local Vec2 = require("Vec2Base")
local record Size
	embed ContainerItem
	width: number
	height: number
	set: function(self: Size, width: number, height: number)
	metamethod __eq: function(self: Size, other: Size): boolean
	metamethod __mul: function(self: Size, vec: Vec2): Size
end
local record SizeClass
	type Type = Size
	metamethod __call: function(cls: SizeClass, other: Size): Size
	metamethod __call: function(cls: SizeClass, width: number --[[0]], height: number --[[0]]): Size
	metamethod __call: function(cls: SizeClass, vec: Vec2): Size
end
local sizeClass: SizeClass
return sizeClass
