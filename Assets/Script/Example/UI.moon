Dorothy!
Button = require "UI.Control.Basic.Button"
LineRect = require "UI.View.Shape.LineRect"
ScrollArea = require "UI.Control.Basic.ScrollArea"

Director\pushEntry with ScrollArea width:200,height:300,paddingX:50,paddingY:50,viewWidth:440,viewHeight:500
	.area\addChild LineRect width:200, height:300, color:0xffffffff
	for i = 1,50
		.view\addChild with Button {
				text:"点击\n按钮#{i}"
				width:60
				height:60
				fontName:"fangzhen16"
				fontSize:16
			}
			\slot "Tapped",-> print "clicked #{i}"
	.view\alignItems Size 440,300
