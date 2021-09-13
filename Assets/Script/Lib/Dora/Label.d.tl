local Node = require("Node").Type
local BlendFunc = require("BlendFunc").Type
local SpriteEffect = require("SpriteEffect").Type
local Sprite = require("Sprite").Type
local record Label
	embed Node
	enum TextAlign
		"Left"
		"Center"
		"Right"
	end
	alphaRef: number
	textWidth: number
	lineGap: number
	text: string
	blendFunc: BlendFunc
	is3D: boolean
	batched: boolean
	effect: SpriteEffect
	alignment: TextAlign
	const characterCount: integer
	getCharacter: function(self: Label, index: integer): Sprite
end
local record LabelClass
	type Type = Label
	const AutomaticWidth: number
	metamethod __call: function(cls: LabelClass, fontName: string, fontSize: integer): Label
end
local labelClass: LabelClass
return labelClass
