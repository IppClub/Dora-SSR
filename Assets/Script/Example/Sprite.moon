Dorothy!

sprite = Sprite "Image/logo.png"

entry = with Node!
	.touchEnabled = true
	\slot "TapMoved",(touch)->
		return unless touch.id == 1
		sprite.position += touch.delta
	\addChild sprite

Director\pushEntry entry

-- example ends here, just some test ui codes below --

Dorothy builtin.ImGui

entry\schedule ->
	{:width,:height} = Application
	SetNextWindowPos Vec2(width-220,10), "FirstUseEver"
	SetNextWindowSize Vec2(220,400),"FirstUseEver"
	if Begin "Sprite", "NoResize|NoSavedSettings"
		if BeginChild "scroll", Vec2 -1,-40
			_,sprite.z = DragFloat "Z", sprite.z, 1, -1000, 1000, "%.2f"
			anchor = sprite.anchor
			DragFloat2 "Anchor", anchor, 0.01, 0, 1, "%.2f"
			sprite.anchor = anchor
			scale = Vec2(sprite.scaleX, sprite.scaleY)
			DragFloat2 "Scale", scale, 0.01, -2, 2, "%.2f"
			sprite.scaleX = scale.x
			sprite.scaleY = scale.y
			PushItemWidth -60
			_, sprite.angle = DragInt "Angle", sprite.angle, 1, -360, 360
			PopItemWidth!
			PushItemWidth -60
			_, sprite.angleX = DragInt "AngleX", sprite.angleX, 1, -360, 360
			PopItemWidth!
			PushItemWidth -60
			_, sprite.angleY = DragInt "AngleY", sprite.angleY, 1, -360, 360
			PopItemWidth!
			skew = Vec2 sprite.skewX, sprite.skewY
			DragInt2 "Skew", skew, 1, -360, 360
			sprite.skewX = skew.x
			sprite.skewY = skew.y
			PushItemWidth -60
			_, sprite.opacity = DragFloat "Opacity", sprite.opacity, 0.01, 0, 1, "%.2f"
			PopItemWidth!
			color3 = sprite.color3
			PushItemWidth -50
			if ColorEdit3 "Color", color3
				sprite.color3 = color3
			PopItemWidth!
		EndChild!
		if Button "Reset", Vec2 140,30
			sprite = Sprite "Image/logo.png"
			entry\removeAllChildren!
			entry\addChild sprite
	End!
