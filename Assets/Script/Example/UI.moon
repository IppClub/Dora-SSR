Dorothy!
Button = require "UI.Control.Basic.Button"
LineRect = require "UI.View.Shape.LineRect"
ScrollArea = require "UI.Control.Basic.ScrollArea"
AlignNode = require "UI.Control.Basic.AlignNode"

Panel = (width, height, viewWidth, viewHeight)->
	with ScrollArea {
			width:width
			height:height
			paddingX:50
			paddingY:50
			viewWidth:viewWidth
			viewHeight:viewHeight
		}
		.area\addChild LineRect width:width, height:height, color:0xffffffff
		for i = 1,1
			.view\addChild with Button {
					text:"点击\n按钮#{i}"
					width:60
					height:60
					fontName:"fangzhen16"
					fontSize:16
				}
				\slot "Tapped",-> print "clicked #{i}"
		.view\alignItems Size viewWidth,height

Director\pushEntry with AlignNode true,false
	\addChild with AlignNode!
		.size = Size 200,300
		.hAlign = "Left"
		.vAlign = "Top"
		.alignOffset = Vec2 10,10
		\addChild with Panel 200,300,430,640
			.position = Vec2 100,150
	\addChild with AlignNode!
		.size = Size 300,300
		.hAlign = "Center"
		.vAlign = "Center"
		.alignOffset = Vec2.zero
		\addChild with Panel 300,300,430,640
			.position = Vec2 150,150
	\addChild with AlignNode!
		.size = Size 150,200
		.hAlign = "Right"
		.vAlign = "Bottom"
		.alignOffset = Vec2 10,10
		\addChild with Panel 150,200,430,640
			.position = Vec2 75,100
	\alignLayout!
