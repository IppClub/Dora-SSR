local Rect = require("Rect").Type
local Vec2 = require("Vec2").Type
local Color = require("Color").Type
local Texture2D = require("Texture2D").Type
local SpriteEffect = require("SpriteEffect").Type
local BlendFunc = require("BlendFunc").Type
local Node = require("Node").Type
local record Grid
	embed Node
	depthWrite: boolean
	texture: Texture2D
	textureRect: Rect
	blendFunc: BlendFunc
	effect: SpriteEffect
	setPos: function(self: Grid, x: integer, y: integer, pos: Vec2)
	getPos: function(self: Grid, x: integer, y: integer)
	getColor: function(self: Grid, x: integer, y: integer): Color
	setColor: function(self: Grid, x: integer, y: integer, color: Color)
	moveUV: function(self: Grid, x: integer, y: integer, offset: Vec2)
end
local record GridClass
	type Type = Grid
	metamethod __call: function(self: GridClass, textureRect: Rect, gridX: integer, gridY: integer): Grid
	metamethod __call: function(self: GridClass, texture: Texture2D, textureRect: Rect, gridX: integer, gridY: integer): Grid
	metamethod __call: function(self: GridClass, texture: Texture2D, gridX: integer, gridY: integer): Grid
	metamethod __call: function(self: GridClass, clipStr: string, gridX: integer, gridY: integer): Grid
end
local gridClass: GridClass
return gridClass
