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

	-- Whether the depth buffer should be written to when rendering the sprite (default is false).
	depthWrite: boolean

	-- The alpha reference value for alpha testing. Pixels with alpha values less than or equal to this value will be discarded.
	-- Only works with `sprite.effect = SpriteEffect("builtin:vs_sprite", "builtin:fs_spritealphatest")`.
	alphaRef: number

	-- The texture rectangle for the sprite.
	textureRect: Rect

	-- The blend function for the sprite.
	blendFunc: BlendFunc

	-- The sprite shader effect.
	effect: SpriteEffect

	-- The texture for the sprite.
	const texture: Texture2D

	-- The texture wrapping mode for the U (horizontal) axis.
	uwrap: TextureWrap

	-- The texture wrapping mode for the V (vertical) axis.
	vwrap: TextureWrap

	-- The texture filtering mode for the sprite.
	filter: TextureFilter
end

-- A class used for creating `Sprite` object.
-- @usage
-- local Sprite = require("Sprite")
-- local sprite = Sprite("Image/file.png")
local record SpriteClass
	type Type = Sprite
	type TextureFilter = Sprite.TextureFilter

	-- Gets the clip names and rectangles from the clip file.
	-- @param clipFile (string) The clip file name to load, should end with ".clip".
	-- @return ({string: Rect} | nil) A table containing the clip names and rectangles.
	getClips: function(self: SpriteClass, clipFile: string): {string: Rect} | nil

	-- A metamethod for creating Sprite object.
	-- @param clipStr (string) The string containing format for loading a texture file.
	-- Can be "Image/file.png" and "Image/items.clip|itemA". Supports image file format: jpg, png, dds, pvr, ktx.
	-- @return (Sprite | nil) A new instance of the Sprite class. If the texture file is not found, it will return nil.
	metamethod __call: function(self: SpriteClass, clipStr: string): Sprite | nil

	-- A metamethod for creating Sprite object.
	-- @return (Sprite) A new instance of the Sprite class.
	metamethod __call: function(self: SpriteClass): Sprite

	-- A metamethod for creating Sprite object.
	-- @param texture (Texture2D) The texture to be used for the sprite.
	-- @param textureRect (Rect) [optional] The rectangle defining the portion of the texture to use for the sprite, if not provided, the whole texture will be used for rendering.
	-- @return (Sprite) A new instance of the Sprite class.
	metamethod __call: function(self: SpriteClass, texture: Texture2D, textureRect?: Rect): Sprite
end

local spriteClass: SpriteClass
return spriteClass
