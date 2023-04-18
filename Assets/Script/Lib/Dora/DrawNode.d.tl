local Node = require("Node").Type
local BlendFunc = require("BlendFunc").Type
local Vec2 = require("Vec2").Type
local Color = require("Color").Type

-- A record for scene node that draws simple shapes such as dots, lines, and polygons.
local record DrawNode

	-- Inherit from the `Node`.
	embed Node

	-- Whether to write to the depth buffer when drawing (default is false).
	depthWrite: boolean

	-- The blend function used to draw the shape.
	blendFunc: BlendFunc

	-- Draws a dot at a specified position with a specified radius and color.
	-- @param pos (Vec2) The position of the dot.
	-- @param radius (number) The radius of the dot.
	-- @param color (Color) [optional] The color of the dot (default is white).
	drawDot: function(
		self: DrawNode,
		pos: Vec2,
		radius: number,
		color?: Color --[[0xffffffff]]
	)

	-- Draws a line segment between two points with a specified radius and color.
	-- @param from (Vec2) The starting point of the line.
	-- @param to (Vec2) The ending point of the line.
	-- @param radius (number) The radius of the line.
	-- @param color (Color) [optional] The color of the line (default is white).
	drawSegment: function(
		self: DrawNode,
		from: Vec2,
		to: Vec2,
		radius: number,
		color?: Color --[[0xffffffff]]
	)

	-- Draws a polygon defined by a list of vertices with a specified fill color and border.
	-- @param verts ({Vec2}) The vertices of the polygon.
	-- @param fillColor (Color) [optional] The fill color of the polygon (default is white).
	-- @param borderWidth (number) [optional] The width of the border (default is 0).
	-- @param borderColor (Color) [optional] The color of the border (default is white).
	drawPolygon: function(
		self: DrawNode,
		verts: {Vec2},
		fillColor?: Color --[[0xffffffff]],
		borderWidth?: number --[[0]],
		borderColor?: Color --[[0xffffffff]]
	)

	-- Draws a set of vertices as triangles, each vertex with its own color.
	-- @param verts ({{Vec2, Color}}) The list of vertices and their colors.
	drawVertices: function(self: DrawNode, verts: {{Vec2, Color}})

	-- Clears all previously drawn shapes from the node.
	clear: function(self: DrawNode)
end

-- A class for creating DrawNode objects.
local record DrawNodeClass
	type Type = DrawNode

	-- Creates a new DrawNode object.
	-- @return (DrawNode) The new DrawNode object.
	metamethod __call: function(self: DrawNodeClass): DrawNode
end

local drawNodeClass: DrawNodeClass
return drawNodeClass
