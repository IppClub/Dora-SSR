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

mask = with DrawNode!
	\drawPolygon StarVertices(160)

Director.entry\addChild with Node!
	\addChild with ClipNode mask
		\addChild with Model "Model/xiaoli.model"
			.look = "happy"
			.loop = true
			.faceRight = true
			\play "walk"
			turn = Call -> .faceRight = not .faceRight
			\runAction Sequence X(2,-250,250),turn,X(2,250,-250),turn
			\slot "ActionEnd",(action)-> \runAction action
	\addChild Line StarVertices(160,true),Color(0xff00ffff)

-- example codes ends here, some test ui below --

Dorothy builtin.ImGui

currentEntry = Director.entry.children.first
inverted = false
Director.entry\addChild with Node!
	\schedule ->
		{:width,:height} = App.designSize
		SetNextWindowPos Vec2(width-250,10), "FirstUseEver"
		SetNextWindowSize Vec2(240,140), "FirstUseEver"
		if Begin "Clip Node", "NoResize|NoSavedSettings"
			TextWrapped "Render children nodes with mask!"
			changed, inverted = Checkbox "Inverted", inverted
			if changed
				currentEntry.children.first.inverted = inverted
				currentEntry.children.last.visible = not inverted
		End!
