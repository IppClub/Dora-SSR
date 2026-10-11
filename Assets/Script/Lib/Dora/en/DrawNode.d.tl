local Node = require("Node").Type
local BlendFunc = require("BlendFunc").Type
local Vec2 = require("Vec2").Type
local Rect = require("Rect").Type
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

	-- Draws a circle at a specified center with a specified radius and color.
	drawCircle: function(self: DrawNode, center: Vec2, radius: number, color?: Color --[[0xffffffff]])

	-- Draws a rectangle with an optional border.
	drawRect: function(self: DrawNode, rect: Rect, fillColor?: Color --[[0xffffffff]], borderWidth?: number --[[0]], borderColor?: Color --[[0xffffffff]])

	-- Draws a filled ellipse at a specified center.
	drawEllipse: function(self: DrawNode, center: Vec2, radiusX: number, radiusY: number, color?: Color --[[0xffffffff]])

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

	-- Draws a connected stroke with round caps and miter joins, beveling long miters. Radius is half the width; adjacent duplicates are ignored.
	drawPolyline: function(self: DrawNode, verts: {Vec2}, radius: number, color?: Color --[[0xffffffff]], closed?: boolean --[[false]])

	-- Draws an arc in degrees: zero points along +X and increasing angles turn toward +Y. The signed sweep is limited to one revolution; full circles close without caps. Line radius is half the width.
	drawArc: function(self: DrawNode, center: Vec2, radius: number, startAngle: number, endAngle: number, lineRadius: number, color?: Color --[[0xffffffff]])

	-- Draws a rounded rectangle. Corner radius is clamped to half the smaller dimension; zero draws a rectangle. Border width is half the centered border width.
	drawRoundedRect: function(self: DrawNode, rect: Rect, cornerRadius: number, fillColor?: Color --[[0xffffffff]], borderWidth?: number --[[0]], borderColor?: Color --[[0xffffffff]])

	-- Draws a ring with 0 <= innerRadius < outerRadius. Zero inner radius fills the center. Optional centered borders surround both contours; borderWidth is a half width.
	drawRing: function(self: DrawNode, center: Vec2, innerRadius: number, outerRadius: number, fillColor?: Color --[[0xffffffff]], borderWidth?: number --[[0]], borderColor?: Color --[[0xffffffff]])

	-- Draws a filled sector in degrees from +X toward +Y. Signed sweep is limited to one revolution; full circles omit radial edges and equal angles draw nothing. Border width is a half width.
	drawSector: function(self: DrawNode, center: Vec2, radius: number, startAngle: number, endAngle: number, fillColor?: Color --[[0xffffffff]], borderWidth?: number --[[0]], borderColor?: Color --[[0xffffffff]])

	-- Draws a quadratic Bezier stroke with round caps; coincident endpoints close the stroke. Radius is half the width. Adaptive subdivision targets the smaller of 0.25 local units and 1% of the control hull diagonal, with at most 1024 segments.
	drawQuadraticBezier: function(self: DrawNode, from: Vec2, control: Vec2, to: Vec2, radius: number, color?: Color --[[0xffffffff]])

	-- Draws a cubic Bezier stroke with round caps; coincident endpoints close the stroke. Radius is half the width. Adaptive subdivision targets the smaller of 0.25 local units and 1% of the control hull diagonal, with at most 1024 segments.
	drawCubicBezier: function(self: DrawNode, from: Vec2, control1: Vec2, control2: Vec2, to: Vec2, radius: number, color?: Color --[[0xffffffff]])

	-- Draws a simple convex or concave polygon in boundary order with either winding. Self-intersections and holes are unsupported; the border is centered on the outline.
	-- @param verts ({Vec2}) The vertices of the polygon.
	-- @param fillColor (Color) [optional] The fill color of the polygon (default is white).
	-- @param borderWidth (number) [optional] Half of the border width, extending to both sides of the outline (default is 0).
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
