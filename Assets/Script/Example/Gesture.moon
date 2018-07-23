Dorothy!

sprite = Sprite "Image/logo.png"

Director\pushEntry with Node!
	\addChild sprite
	length = (Vec2 View.size).length
	{:width,:height} = sprite
	size = Vec2(width,height).length
	scaledSize = size
	.touchEnabled = true
	\slot "Gesture",(center,touches,delta,theta)->
		-- center: center from all touches` position
		-- delta: changed motion ratio (compare to screen size) along the x-axes and y-axes
		-- theta:  rotated angle along the touches` center
		sprite.position = center
		sprite.angle += theta
		scaledSize += delta * length
		sprite.scaleX = scaledSize / size
		sprite.scaleY = scaledSize / size

-- example codes ends here, some test ui below --

Dorothy builtin.ImGui

currentEntry = Director.currentEntry
threadLoop ->
	{:width,:height} = Application.designSize
	SetNextWindowPos Vec2(width-250,10), "FirstUseEver"
	SetNextWindowSize Vec2(240,120), "FirstUseEver"
	if Begin "Gesture", "NoResize|NoSavedSettings"
		TextWrapped "Interact with multi-touches!"
	End!
	Director.currentEntry != currentEntry
