Dorothy!

sprite = Sprite "Image/logo.png"

sprite.touchEnabled = true
sprite\slot "TapMoved",(touch)->
	sprite.position += touch.delta

Director\pushEntry sprite
