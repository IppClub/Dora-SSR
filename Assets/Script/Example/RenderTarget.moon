Dorothy!

node = with Node!
	\addChild with Model "Model/xiaoli.model"
		.y = -80
		.look = "happy"
		.loop = true
		.faceRight = true
		\play "walk"
		turn = Call -> .faceRight = not .faceRight
		\runAction Sequence X(2,-150,150),turn,X(2,150,-150),turn
		\slot "ActionEnd",(action)-> \runAction action

renderTarget = with RenderTarget 300,400
	.z = 300
	.angleY = 25
	\addChild Line {
			Vec2.zero
			Vec2 300,0
			Vec2 300,400
			Vec2 0,400
			Vec2.zero
		},Color 0xff00ffff
	\schedule ->
		node.y = 200
		\renderWithClear node,Color 0xff8a8a8a
		node.y = 0

Director\pushEntry with Node!
	\addChild renderTarget
	\addChild node

-- example codes ends here, some test ui below --

Dorothy builtin.ImGui

currentEntry = Director.currentEntry
threadLoop ->
	{:width,:height} = Application.designSize
	SetNextWindowPos Vec2(width-250,10), "FirstUseEver"
	SetNextWindowSize Vec2(240,120), "FirstUseEver"
	if Begin "Render Target", "NoResize|NoSavedSettings"
		TextWrapped "Use render target node as a mirror!"
	End!
	Director.currentEntry != currentEntry
