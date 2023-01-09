local ContainerItem = require("ContainerItemType")
local type Size = require("SizeType")
local record Vec2
	embed ContainerItem
	const x: number
	const y: number
	const length: number
	const lengthSquared: number
	const angle: number
	distance: function(self: Vec2, vec: Vec2): number
	distanceSquared: function(self: Vec2, vec: Vec2): number
	normalize: function(self: Vec2): Vec2
	perp: function(self: Vec2): Vec2
	clamp: function(self: Vec2, from: Vec2, to: Vec2): Vec2
	metamethod __add: function(self: Vec2, other: Vec2): Vec2
	metamethod __sub: function(self: Vec2, other: Vec2): Vec2
	metamethod __mul: function(self: Vec2, other: Vec2): Vec2
	metamethod __mul: function(self: Vec2, other: number): Vec2
	metamethod __mul: function(self: Vec2, other: Size): Vec2
	metamethod __div: function(self: Vec2, other: number): Vec2
	metamethod __eq: function(self: Vec2, other: Vec2): boolean
end
return Vec2
