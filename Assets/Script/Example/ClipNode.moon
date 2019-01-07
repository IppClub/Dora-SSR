Dorothy!

StarVertices = (radius,line=false)->
	a = math.rad 36
	c = math.rad 72
	f = math.sin(a)*math.tan(c)+math.cos(a)
	R = radius
	r = R/f
	return for i = 9,line and -1 or 0,-1
		angle = i*a
		cr = i%2 == 1 and r or R
		Vec2 cr*math.sin(angle), cr*math.cos(angle)

-- example A

maskA = with DrawNode!
	\drawPolygon StarVertices(160)

targetA = with Model "Model/xiaoli.model"
	.look = "happy"
	.loop = true
	.faceRight = true
	\play "walk"
	turn = Call -> .faceRight = not .faceRight
	\runAction Sequence X(1.5,-200,200),turn,X(1.5,200,-200),turn
	\slot "ActionEnd",(action)-> \runAction action

exampleA = with Node!
	\addChild with ClipNode maskA
		\addChild targetA
		.inverted = true
	\addChild with Line StarVertices(160,true),Color(0xff00ffff)
		.visible = false
	\addTo Director.entry
	.visible = false

-- example B

maskB = with Model "Model/xiaoli.model"
	.look = "happy"
	.loop = true
	.faceRight = true
	\play "walk"

targetB = with DrawNode!
	\drawPolygon StarVertices(160)
	\runAction Sequence X(1.5,-200,200),X(1.5,200,-200)
	\slot "ActionEnd",(action)-> \runAction action

exampleB = with Node!
	\addChild with ClipNode maskB
		\addChild targetB
		.inverted = true
		.alphaThreshold = 0.3
	\addTo Director.entry

-- example codes ends here, some test ui below --

Dorothy builtin.ImGui

inverted = true
withAlphaThreshold = true
Director.entry\addChild with Node!
	\schedule ->
		{:width,:height} = App.visualSize
		SetNextWindowPos Vec2(width-250,10), "FirstUseEver"
		SetNextWindowSize Vec2(240,180), "FirstUseEver"
		if Begin "Clip Node", "NoResize|NoSavedSettings"
			TextWrapped "Render children nodes with mask!"
			changed, inverted = Checkbox "Inverted", inverted
			if changed
				exampleA.children.first.inverted = inverted
				exampleB.children.first.inverted = inverted
				exampleA.children.last.visible = not inverted
			changed, withAlphaThreshold = Checkbox "With alphaThreshold", withAlphaThreshold
			if changed
				exampleB.visible = withAlphaThreshold
				exampleA.visible = not withAlphaThreshold
		End!
