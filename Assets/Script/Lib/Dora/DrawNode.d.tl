local Node = require("Node").Type
local BlendFunc = require("BlendFunc").Type
local Vec2 = require("Vec2").Type
local Color = require("Color").Type
local record DrawNode
	embed Node
	depthWrite: boolean
	blendFunc: BlendFunc
	drawDot: function(
		self: DrawNode,
		pos: Vec2,
		radius: number,
		color?: Color --[[0xffffffff]]
	)
	drawSegment: function(
		self: DrawNode,
		from: Vec2,
		to: Vec2,
		radius: number,
		color?: Color --[[0xffffffff]]
	)
	drawPolygon: function(
		self: DrawNode,
		verts: {Vec2},
		fillColor?: Color --[[0xffffffff]],
		borderWidth?: number --[[0]],
		borderColor?: Color --[[0xffffffff]]
	)
	drawVertices: function(self: DrawNode, verts: {{Vec2, Color}})
	clear: function(self: DrawNode)
end
local record DrawNodeClass
	type Type = DrawNode
	metamethod __call: function(self: DrawNodeClass): DrawNode
end
local drawNodeClass: DrawNodeClass
return drawNodeClass
