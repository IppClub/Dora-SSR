local Rect = require("Rect").Type
local Vec2 = require("Vec2").Type
local Color = require("Color").Type
local Texture2D = require("Texture2D").Type
local SpriteEffect = require("SpriteEffect").Type
local BlendFunc = require("BlendFunc").Type
local Node = require("Node").Type

-- A class used to render a texture as a grid of sprites, where each sprite can be positioned, colored, and have its UV coordinates manipulated.
local record Grid

	-- Inherits from `Node`.
	embed Node

	-- The number of columns in the grid. And there are `gridX + 1` vertices horizontally for rendering.
	const gridX: integer

	-- The number of rows in the grid. And there are `gridY + 1` vertices vertically for rendering.
	const gridY: integer

	-- Whether depth writes are enabled (default is false).
	depthWrite: boolean

	-- The texture used for the grid.
	texture: Texture2D

	-- The rectangle within the texture that is used for the grid.
	textureRect: Rect

	-- The blending function used for the grid.
	blendFunc: BlendFunc

	-- The sprite effect applied to the grid.
	-- Default is `SpriteEffect("builtin:vs_sprite", "builtin:fs_sprite")`.
	effect: SpriteEffect

	-- Sets the position of a vertex in the grid.
	-- @param x (integer) The x-coordinate of the vertex in the grid.
	-- @param y (integer) The y-coordinate of the vertex in the grid.
	-- @param pos (Vec2) The new position of the vertex.
	-- @param z (number) [optional] The z-coordinate of the vertex. Default is 0.
	setPos: function(self: Grid, x: integer, y: integer, pos: Vec2, z?: number)

	-- Gets the position of a vertex in the grid.
	-- @param x (integer) The x-coordinate of the vertex in the grid.
	-- @param y (integer) The y-coordinate of the vertex in the grid.
	-- @return (Vec2) The current position of the vertex.
	getPos: function(self: Grid, x: integer, y: integer): Vec2

	-- Gets the color of a vertex in the grid.
	-- @param x (integer) The x-coordinate of the vertex in the grid.
	-- @param y (integer) The y-coordinate of the vertex in the grid.
	-- @return (Color) The current color of the vertex.
	getColor: function(self: Grid, x: integer, y: integer): Color

	-- Sets the color of a vertex in the grid.
	-- @param x (integer) The x-coordinate of the vertex in the grid.
	-- @param y (integer) The y-coordinate of the vertex in the grid.
	-- @param color (Color) The new color of the vertex.
	setColor: function(self: Grid, x: integer, y: integer, color: Color)

	-- Moves the UV coordinates of a vertex in the grid.
	-- @param x (integer) The x-coordinate of the vertex in the grid.
	-- @param y (integer) The y-coordinate of the vertex in the grid.
	-- @param offset (Vec2) The offset by which to move the UV coordinates.
	moveUV: function(self: Grid, x: integer, y: integer, offset: Vec2)
end

-- A class for creating Grid objects.
local record GridClass
	type Type = Grid

	-- Creates a new Grid with the specified texture rectangle and grid size.
	-- @param width (number) The width of the grid.
	-- @param height (number) The height of the grid.
	-- @param gridX (integer) The number of columns in the grid.
	-- @param gridY (integer) The number of rows in the grid.
	-- @return (Grid) The new Grid instance.
	metamethod __call: function(self: GridClass, width: number, height: number, gridX: integer, gridY: integer): Grid

	-- Creates a new Grid with the specified texture, texture rectangle, and grid size.
	-- @param texture (Texture2D) The texture to use for the grid.
	-- @param textureRect (Rect) The rectangle within the texture to use for the grid.
	-- @param gridX (integer) The number of columns in the grid.
	-- @param gridY (integer) The number of rows in the grid.
	-- @return (Grid) The new Grid instance.
	metamethod __call: function(self: GridClass, texture: Texture2D, textureRect: Rect, gridX: integer, gridY: integer): Grid

	-- Creates a new Grid with the specified texture and grid size.
	-- @param texture (Texture2D) The texture to use for the grid.
	-- @param gridX (integer) The number of columns in the grid.
	-- @param gridY (integer) The number of rows in the grid.
	-- @return (Grid) The new Grid instance.
	metamethod __call: function(self: GridClass, texture: Texture2D, gridX: integer, gridY: integer): Grid

	-- Creates a new Grid with the specified clip string and grid size.
	-- @param clipStr (string) The clip string to use for the grid.
	-- Can be "Image/file.png" and "Image/items.clip|itemA".
	-- @param gridX (integer) The number of columns in the grid.
	-- @param gridY (integer) The number of rows in the grid.
	-- @return (Grid) The new Grid instance.
	metamethod __call: function(self: GridClass, clipStr: string, gridX: integer, gridY: integer): Grid
end

local gridClass: GridClass
return gridClass
