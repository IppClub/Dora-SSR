Dorothy!
Button = require "UI.Control.Basic.Button"
LineRect = require "UI.View.Shape.LineRect"
ScrollArea = require "UI.Control.Basic.ScrollArea"
AlignNode = require "UI.Control.Basic.AlignNode"
utf8 = require "utf8"

label = with Label "NotoSansHans-Regular", 20
	.anchor = Vec2.zero
	.alignment = TextAlign.Left

textEditing = ""
textDisplay = ""

cursor = with Line {Vec2.zero,Vec2(0,20)},Color 0xff00ffff
	.visible = false
	\schedule loop ->
		cursor.visible = true
		sleep 0.5
		cursor.visible = false
		sleep 0.5

node = with Node!
	\addChild label
	\addChild cursor
	\attachIME!
	.keyboardEnabled = true
	\slot "KeyPressed",(key)->
		return if textEditing ~= ""
		switch key
			when "BackSpace"
				if #textDisplay > 0
					textDisplay = utf8.sub textDisplay, 1, -2
					label.text = textDisplay
					cursor.x = label.width+1
	\slot "TextInput",(text)->
		textDisplay = utf8.sub(textDisplay, 1, -1-utf8.len(textEditing))..text
		textEditing = ""
		label.text = textDisplay
		cursor.x = label.width+1
		\convertToWindowSpace Vec2(label.width,0),(pos)->
			Keyboard\updateIMEPosHint pos
	\slot "TextEditing",(text,start)->
		textDisplay = utf8.sub(textDisplay, 1, -1-utf8.len(textEditing))..text
		textEditing = text
		label.text = textDisplay
		charSprite = label\getCharacter utf8.len(textDisplay)-utf8.len(textEditing)+start
		cursor.x = charSprite.x + charSprite.width/2 + 1 if charSprite
		\convertToWindowSpace Vec2(label.width,0),(pos)->
			Keyboard\updateIMEPosHint pos

Director\pushEntry node
