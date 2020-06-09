_ENV = Dorothy!
import "UI.Control.Basic.Ruler"
import "UI.Control.Basic.CircleButton"

ruler = Ruler {
	x:0
	y:0
	width:400
	height:60
	fontName:"NotoSansHans-Regular"
	fontSize:12
}

Director.entry\addChild with Node!
	\addChild ruler
	\addChild with CircleButton {
			text:"显示"
			y:-100
			radius:30
			fontSize:18
		}
		\slot "Tapped",->
			if .text == "显示"
				.text = "隐藏"
				ruler\show 0,0,100,10,(value)->
					print value
			else
				.text = "显示"
				ruler\hide!
