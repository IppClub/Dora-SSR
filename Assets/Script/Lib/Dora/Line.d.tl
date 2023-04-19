local Node = require("Node").Type
local BlendFunc = require("BlendFunc").Type
local Color = require("Color").Type
local Vec2 = require("Vec2").Type

-- A class provides functionality for drawing lines using vertices.
local record Line

	-- Inherits from `Node`.
	embed Node

	-- Whether the depth should be written. (Default is false)
	depthWrite: boolean

	-- Blend function used for rendering the line.
	blendFunc: BlendFunc

	-- Adds vertices to the line.
	-- @param verts ({Vec2}) Table of vertices to add to the line.
	-- @param color (Color) [optional] Color of the line (default is opaque white).
	add: function(
		self: Line,
		verts: {Vec2},
		color?: Color --[[0xffffffff]]
	)

	-- Sets vertices of the line.
	-- @param verts ({Vec2}) Table of vertices to set.
	-- @param color (Color) Color of the line (default is opaque white).
	set: function(
		self: Line,
		verts: {Vec2},
		color?: Color --[[0xffffffff]]
	)

	-- Clears all the vertices of line.
	clear: function(self: Line)
end

-- A class for creating Line object.
local record LineClass
	type Type = Line

	-- Creates and returns a new Line object.
	-- @param verts ({Vec2}) Table of vertices to add to the line.
	-- @param color (Color) [optional] Color of the line (default is opaque white).
	-- @return (Line) Line object.
	metamethod __call: function(
		self: LineClass,
		verts: {Vec2},
		color?: Color --[[0xffffffff]]
	): Line

	-- Creates and returns a new empty Line object.
	-- @return (Line) Line object.
	metamethod __call: function(self: LineClass): Line
end

local lineClass: LineClass
return lineClass
