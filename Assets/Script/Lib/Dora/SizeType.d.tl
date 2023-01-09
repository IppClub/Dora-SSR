local ContainerItem = require("ContainerItemType")
local type Vec2 = require("Vec2Type")
local record Size
	embed ContainerItem
	width: number
	height: number
	set: function(self: Size, width: number, height: number)
	metamethod __eq: function(self: Size, other: Size): boolean
	metamethod __mul: function(self: Size, vec: Vec2): Size
end
return Size
