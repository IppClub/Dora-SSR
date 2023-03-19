local Node = require("Node").Type
local BlendFunc = require("BlendFunc").Type
local Color = require("Color").Type
local Vec2 = require("Vec2").Type
local record Line
	embed Node
	depthWrite: boolean
	blendFunc: BlendFunc
	add: function(
		self: Line,
		verts: {Vec2},
		color?: Color --[[0xffffffff]]
	)
	set: function(
		self: Line,
		verts: {Vec2},
		color?: Color --[[0xffffffff]]
	)
	clear: function(self: Line)
end
local record LineClass
	type Type = Line
	metamethod __call: function(
		self: LineClass,
		verts: {Vec2},
		color?: Color --[[0xffffffff]]
	): Line
	metamethod __call: function(self: LineClass): Line
end
local lineClass: LineClass
return lineClass
