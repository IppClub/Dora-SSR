Dorothy!

sprite = Sprite "Image/logo.png"

Director\pushEntry with Node!
	\addChild sprite
	.touchEnabled = true
	{:width,:height} = sprite
	length = (Vec2 View.size).length
	size = Vec2(width,height).length
	scaleSize = size
	\slot "Gesture",(pos,touches,dist,theta)->
		sprite.position = pos
		sprite.angle += theta
		scaleSize += dist * length
		sprite.scaleX = scaleSize / size
		sprite.scaleY = scaleSize / size
