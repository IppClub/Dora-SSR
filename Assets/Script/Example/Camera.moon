Dorothy!

Director\pushEntry with Node!
	\addChild with Model "Model/xiaoli.model"
		.look = "happy"
		.loop = true
		\play "idle"

	\addChild with Sprite "Image/logo.png"
		.position = Vec2 200,-100
		.angleY = 45
		.z = -300

	\schedule once -> with Director.currentCamera
		cycle 1.5,(dt)-> .position = Vec2 200*Ease\func(Ease.InOutQuad,dt),0
		cycle 0.1,(dt)-> .rotation = 25*Ease\func Ease.OutSine,dt
		cycle 0.2,(dt)-> .rotation = 25-50*Ease\func Ease.InOutQuad,dt
		cycle 0.1,(dt)-> .rotation = -25+25*Ease\func Ease.OutSine,dt
		cycle 1.5,(dt)-> .position = Vec2 200*Ease\func(Ease.InOutQuad,1-dt),0
		cycle 2.5,(dt)-> .zoom = 1+Ease\func Ease.InOutQuad,dt

-- example codes ends here, some test ui below --

Dorothy builtin.ImGui

currentEntry = Director.currentEntry
threadLoop ->
	{:width,:height} = Application.designSize
	SetNextWindowPos Vec2(width-250,10), "FirstUseEver"
	SetNextWindowSize Vec2(240,120), "FirstUseEver"
	if Begin "Camera", "NoResize|NoSavedSettings"
		TextWrapped "View camera motions, use 3D camera as default!"
	End!
	Director.currentEntry != currentEntry
