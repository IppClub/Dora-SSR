local Rect = require("Rect").Type
local Vec2 = require("Vec2").Type
local Color = require("Color").Type
local Texture2D = require("Texture2D").Type
local SpriteEffect = require("SpriteEffect").Type
local BlendFunc = require("BlendFunc").Type
local Node = require("Node").Type
local record Grid
	embed Node
	is3D: boolean
	texture: Texture2D
	textureRect: Rect
	blendFunc: BlendFunc
	effect: SpriteEffect
	setPos: function(self: Grid, x: integer, y: integer, pos: Vec2)
	getPos: function(self: Grid, x: integer, y: integer)
	getColor: function(self: Grid, x: integer, y: integer): Color
	setColor: function(self: Grid, x: integer, y: integer, color: Color)
end
local record GridClass
	type Type = Grid
	metamethod __call: function(cls: GridClass, textureRect: Rect, gridX: number, gridY: number): Grid
	metamethod __call: function(cls: GridClass, texture: Texture2D, textureRect: Rect, gridX: number, gridY: number): Grid
	metamethod __call: function(cls: GridClass, texture: Texture2D, gridX: number, gridY: number): Grid
	metamethod __call: function(cls: GridClass, clipStr: string, gridX: number, gridY: number): Grid
end
print(Grid.textureRect)
print(Grid.blendFunc)
print(Grid.effect)
print(Grid.texture)
local gridClass: GridClass
return gridClass
