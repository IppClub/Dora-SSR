Dorothy builtin.Platformer
StartPanelView = require "UI.View.StartPanel"

Class StartPanelView,
	__init:=>
		buttons = {@fButton,@vButton,@dButton}
		for button in *buttons
			button\slot "Tapped",-> emit "PlayerSelect", switch button
				when @fButton then "Flandre"
				when @vButton then "Villy"
				when @dButton then "Dorothy"
		@node\schedule ->
			pos = nvg.TouchPos!*(View.size.width/App.visualSize.width)
			pos.y = View.size.height - pos.y
			for _,button in ipairs buttons
				localPos = button\convertToNodeSpace pos
				if Rect(Vec2.zero,button.size)\containsPoint localPos
					button\glow!
				else
					button\stopGlow!

