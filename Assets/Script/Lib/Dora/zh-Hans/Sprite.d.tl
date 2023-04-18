local Rect = require("Rect").Type
local Texture2D = require("Texture2D").Type
local SpriteEffect = require("SpriteEffect").Type
local BlendFunc = require("BlendFunc").Type
local Node = require("Node").Type

-- The Sprite class to render texture in game scene tree hierarchy.
local record Sprite

	-- Inherits from `Node`.
	embed Node

	-- An enumeration for texture wrapping modes.
	enum TextureWrap
		"None"
		"Mirror"
		"Clamp"
		"Border"
	end

	-- An enumeration for texture filtering modes.
	enum TextureFilter
		"None"
		"Point"
		"Anisotropic"
	end

	-- Indicates whether the depth buffer should be written to when rendering the sprite (default is false).
	depthWrite: boolean

	-- Specifies the alpha reference value for alpha testing. Pixels with alpha values less than or equal to this value will be discarded.
	-- Only works with `sprite.effect = SpriteEffect("builtin:vs_sprite", "builtin:fs_spritealphatest")`.
	alphaRef: number

	-- Specifies the texture rectangle for the sprite, as an instance of the Rect class.
	textureRect: Rect

	-- Specifies the blend function for the sprite, as an instance of the BlendFunc class.
	blendFunc: BlendFunc

	-- Specifies the sprite effect, as an instance of the SpriteEffect class.
	effect: SpriteEffect

	-- Specifies the texture for the sprite, as an instance of the Texture2D class.
	texture: Texture2D

	-- Specifies the texture wrapping mode for the U (horizontal) axis.
	uwrap: TextureWrap

	-- Specifies the texture wrapping mode for the V (vertical) axis.
	vwrap: TextureWrap

	-- Specifies the texture filtering mode for the sprite.
	filter: TextureFilter
end

-- @usage
-- local Sprite = require("Sprite")
-- local sprite = Sprite("Image/file.png")
local record SpriteClass
	type Type = Sprite

	-- A metamethod for calling the SpriteClass as a function with no arguments.
	-- @return (Sprite) A new instance of the Sprite class.
	metamethod __call: function(self: SpriteClass): Sprite

	-- A metamethod for calling the SpriteClass as a function with a Texture2D and an optional Rect argument.
	-- @param texture (Texture2D) The texture to be used for the sprite.
	-- @param textureRect (Rect|nil) The rectangle defining the portion of the texture to use for the sprite.
	-- @return (Sprite) A new instance of the Sprite class with the specified texture and texture rectangle.
	metamethod __call: function(self: SpriteClass, texture: Texture2D, textureRect?: Rect): Sprite

	-- A metamethod for calling the SpriteClass as a function with a string argument.
	-- @param clipStr (string) The string containing format for loading a texture file.
	-- Can be "Image/file.png" and "Image/items.clip|itemA".
	-- @return (Sprite) A new instance of the Sprite class with the texture loaded from the specified image file.
	metamethod __call: function(self: SpriteClass, clipStr: string): Sprite
end

local spriteClass: SpriteClass
return spriteClass
