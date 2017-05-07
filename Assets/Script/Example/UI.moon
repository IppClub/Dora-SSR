Dorothy!
Button = require "UI.Control.Basic.Button"

Director\pushEntry with Button text:"点击\n按钮",width:60,height:60,fontName:"fangzhen16",fontSize:16
	\slot "Tapped",-> print "clicked!"
