Dorothy!

texture = GetDorothySSRWhite!
sprite = Sprite texture
length = (Vec2 View.size).length
:width,:height = sprite
size = Vec2(width,height).length
scaledSize = size

Director.entry\addChild with Node!
	\addChild sprite
	.touchEnabled = true
	\slot "Gesture",(center,touches,delta,theta)->
		-- center: center of all touch positions
		-- delta: changed motion ratio (compare to screen size) along the x-axes and y-axes
		-- theta:  rotated angle along the touches` center
		sprite.position = center
		sprite.angle += theta
		scaledSize += delta * length
		sprite.scaleX = scaledSize / size
		sprite.scaleY = scaledSize / size

-- example codes ends here, some test ui below --

Dorothy builtin.ImGui

Director.entry\addChild with Node!
	\schedule ->
		:width,:height = App.visualSize
		SetNextWindowPos Vec2(width-250,10), "FirstUseEver"
		SetNextWindowSize Vec2(240,120), "FirstUseEver"
		Begin "Gesture", "NoResize|NoSavedSettings", ->
			TextWrapped "Interact with multi-touches!"
