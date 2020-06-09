_ENV = Dorothy!

sprite = Sprite "Image/logo.png"

Director.entry\addChild with Node!
	.touchEnabled = true
	\slot "TapMoved",(touch)->
		return unless touch.id == 0
		sprite.position += touch.delta
	\addChild sprite

-- example codes ends here, test ui codes below --

_ENV = Dorothy builtin.ImGui

Director.entry\addChild with Node!
	\schedule ->
		:width,:height = App.visualSize
		SetNextWindowPos Vec2(width-250,10), "FirstUseEver"
		SetNextWindowSize Vec2(240,520), "FirstUseEver"
		Begin "Sprite", "NoResize|NoSavedSettings", ->
			BeginChild "SpriteSetting", Vec2(-1,-40), ->
				_,sprite.z = DragFloat "Z", sprite.z, 1, -1000, 1000, "%.2f"
				anchor = sprite.anchor
				DragFloat2 "Anchor", anchor, 0.01, 0, 1, "%.2f"
				sprite.anchor = anchor
				sizeVec = Vec2 sprite.size
				DragFloat2 "Size", sizeVec, 0.1, 0, 1000, "%.f"
				sprite.size = Size sizeVec
				scale = Vec2(sprite.scaleX, sprite.scaleY)
				DragFloat2 "Scale", scale, 0.01, -2, 2, "%.2f"
				sprite.scaleX = scale.x
				sprite.scaleY = scale.y
				PushItemWidth -60,->
					_, sprite.angle = DragInt "Angle", sprite.angle, 1, -360, 360
				PushItemWidth -60,->
					_, sprite.angleX = DragInt "AngleX", sprite.angleX, 1, -360, 360
				PushItemWidth -60,->
					_, sprite.angleY = DragInt "AngleY", sprite.angleY, 1, -360, 360
				skew = Vec2 sprite.skewX, sprite.skewY
				DragInt2 "Skew", skew, 1, -360, 360
				sprite.skewX = skew.x
				sprite.skewY = skew.y
				PushItemWidth -70,->
					_, sprite.opacity = DragFloat "Opacity", sprite.opacity, 0.01, 0, 1, "%.2f"
				color3 = sprite.color3
				PushItemWidth -1,->
					SetColorEditOptions "RGB"
					if ColorEdit3 "", color3
						sprite.color3 = color3
			if Button "Reset", Vec2 140,30
				parentNode = sprite.parent
				sprite\removeFromParent!
				sprite = Sprite "Image/logo.png"
				parentNode\addChild sprite
