Dorothy!
LineRect = require "UI.View.Shape.LineRect"
utf8 = require "utf8"

LabelEx = Class Node,
	__init:(args)=>
		{:width,:height,:text,:fontName,:fontSize,:alignment,:renderOrder} = args
		text or= ""
		alignment or= TextAlign.Right
		fontName or= "NotoSansHans-Regular"
		fontSize or= 16
		renderOrder or= 0

		@size = Size width,height
		label = with Label fontName,fontSize
			.batched = false
			.alignment = alignment
			.renderOrder = renderOrder
			switch alignment
				when TextAlign.Center
					.position = Vec2(0.5,0.5)*@size
				when TextAlign.Left
					.y = height/2 - fontSize/2
					.anchor = Vec2.zero
				when TextAlign.Right
					.x = width
					.y = height/2 - fontSize/2
					.anchor = Vec2 1,0
		@addChild label
		@_label = label
		@text = text

	text:property => @_text,
		(value)=>
			@_text = value
			@_label.text = "..."
			minWidth = @_label.width
			@_label.text = value
			requiredWidth = math.max @width-minWidth,0
			charCount = utf8.len value
			if charCount > 0
				char = @_label\getCharacter 1
				left = char.x
				right = left
				for i = 2,charCount
					char = @_label\getCharacter i
					right = math.max char.x+char.width/2,right
					if right-left > requiredWidth
						displayText = utf8.sub value,1,i-1
						displayText ..= "..."
						@_label.text = displayText
						break

createLabel = (alignment)->
	with LabelEx text:"",width:100,height:30,:alignment
		\addChild LineRect width:100,height:30,color:0xffff0080
		text = "1.23456壹贰叁肆伍陆柒玐玖"
		textLen = utf8.len text
		\schedule once ->
			for i = 1,textLen
				.text = utf8.sub text,1,i
				sleep 0.3

Director.entry\addChild with Node!
	\addChild createLabel TextAlign.Center
	\addChild with createLabel TextAlign.Left
		.y = 40
	\addChild with createLabel TextAlign.Right
		.y = -40
