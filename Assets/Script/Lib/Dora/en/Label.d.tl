local Node = require("Node").Type
local BlendFunc = require("BlendFunc").Type
local SpriteEffect = require("SpriteEffect").Type
local Sprite = require("Sprite").Type

-- A node for rendering text using a TrueType font.
local record Label

	-- Inherits from `Node`.
	embed Node

	-- Enumeration for text alignment setting.
	enum TextAlign
		"Left"
		"Center"
		"Right"
	end

	-- The alpha threshold value. Pixels with alpha values below this value will not be drawn.
	-- Only works with `label.effect = SpriteEffect("builtin:vs_sprite", "builtin:fs_spritealphatest")`.
	alphaRef: number

	-- The width of the text used for text wrapping.
	-- Set to `Label.AutomaticWidth` to disable wrapping.
	-- Default is `Label.AutomaticWidth`.
	textWidth: number

	-- The gap in pixels between lines of text.
	lineGap: number

	-- The gap in pixels between characters.
	spacing: number

	-- The text to be rendered.
	text: string

	-- The blend function used to render the text.
	blendFunc: BlendFunc

	-- Whether depth writing is enabled. (Default is false)
	depthWrite: boolean

	-- Whether the label is using batched rendering.
	-- When using batched rendering the `label:getCharacter()` function will no longer work, and getting better rendering performance. (Default is true)
	batched: boolean

	-- The sprite effect used to render the text.
	effect: SpriteEffect

	-- The text alignment setting.
	alignment: TextAlign

	-- The number of characters in the label.
	const characterCount: integer

	-- Returns the sprite for the character at the specified index.
	-- @param index (integer) The index of the character sprite to retrieve.
	-- @return (Sprite|nil) The sprite for the character, or `nil` if the index is out of range.
	getCharacter: function(self: Label, index: integer): Sprite | nil
end

-- A class for creating Label object.
local record LabelClass
	type Type = Label

	-- The value to use for automatic width calculation
	const AutomaticWidth: number

	-- Creates a new Label object with the specified font name and font size.
	-- @param fontName (string) The name of the font to use for the label.
	-- Can be font file path with or without file extension.
	-- @param fontSize (integer) The size of the font to use for the label.
	-- @return (Label) The new Label object.
	metamethod __call: function(self: LabelClass, fontName: string, fontSize: integer): Label
end

local labelClass: LabelClass
return labelClass
