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
	depthWrite: boolean
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
	metamethod __call: function(self: SpriteClass): Sprite
	metamethod __call: function(self: SpriteClass, texture: Texture2D, textureRect?: Rect): Sprite
	metamethod __call: function(self: SpriteClass, clipStr: string): Sprite
end
local spriteClass: SpriteClass
return spriteClass
