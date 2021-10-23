local Rect = require("Rect").Type
local Texture2D = require("Texture2D").Type
local SpriteEffect = require("SpriteEffect").Type
local BlendFunc = require("BlendFunc").Type
local Node = require("Node").Type
local record Sprite
	embed Node
	enum TextureWrap
		"None"
		"Mirror"
		"Clamp"
		"Border"
	end
	enum TextureFilter
		"None"
		"Point"
		"Anisotropic"
	end
	is3D: boolean
	alphaRef: number
	textureRect: Rect
	blendFunc: BlendFunc
	effect: SpriteEffect
	texture: Texture2D
	uwrap: TextureWrap
	vwrap: TextureWrap
	filter: TextureFilter
end
local record SpriteClass
	type Type = Sprite
	metamethod __call: function(cls: SpriteClass): Sprite
	metamethod __call: function(cls: SpriteClass, texture: Texture2D, textureRect?: Rect): Sprite
	metamethod __call: function(cls: SpriteClass, clipStr: string): Sprite
end
print(Sprite.textureRect)
print(Sprite.blendFunc)
print(Sprite.effect)
print(Sprite.texture)
local spriteClass: SpriteClass
return spriteClass
