_ENV = Dorothy!
import "UI.Control.Basic.Button"
import "UI.View.Shape.LineRect"
import "UI.Control.Basic.ScrollArea"
import "UI.Control.Basic.AlignNode"

Panel = (width, height, viewWidth, viewHeight)->
	with ScrollArea {
			width:width
			height:height
			paddingX:50
			paddingY:50
			viewWidth:viewWidth
			viewHeight:viewHeight
		}
		.border = LineRect width:width, height:height, color:0xffffffff
		.area\addChild .border
		for i = 1,50
			.view\addChild with Button {
					text:"点击\n按钮#{i}"
					width:60
					height:60
					fontName:"NotoSansHans-Regular"
					fontSize:16
				}
				\slot "Tapped",-> print "clicked #{i}"
		.view\alignItems Size viewWidth,height

Director.ui\addChild with AlignNode isRoot:true
	\addChild with AlignNode!
		.hAlign = "Left"
		.vAlign = "Top"
		.alignWidth = "200"
		.alignHeight = "h-20"
		.alignOffset = Vec2 10,10
		\addChild with Panel 200,300,430,640
			.position = Vec2 100,150
			\slot "AlignLayout",(w,h)->
				\adjustSizeWithAlign "auto",10,Size(w,h),Size(400,h)
				.position = Vec2 w/2,h/2
				.area\removeChild .border
				.border = LineRect width:w, height:h, color:0xffffffff
				.area\addChild .border
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
