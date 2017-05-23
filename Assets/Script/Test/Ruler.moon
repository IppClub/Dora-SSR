Dorothy!
Ruler = require "UI.Control.Basic.Ruler"
Button = require "UI.Control.Basic.Button"

ruler = Ruler {
	x:0
	y:0
	width:400
	height:60
	fontName:"NotoSansHans-Regular"
	fontSize:12
}

Director\pushEntry with Node!
	\addChild ruler
	\addChild with Button {
			text:"Show"
			y:-100
			width:60
			height:60
			fontSize:18
		}
		\slot "Tapped",->
			if .text == "Show"
				.text = "Hide"
				ruler\show 0,0,100,10,(value)->
					print value
			else
				.text = "Show"
				ruler\hide!
