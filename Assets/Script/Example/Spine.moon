_ENV = Dorothy!

size,grid = 1500,50

background = -> with DrawNode!
	.is3D = true
	\drawPolygon {
		Vec2 -size,size
		Vec2 size,size
		Vec2 size,-size
		Vec2 -size,-size
	}, Color 0xff888888
	\addChild with Line!
		.is3D = true
		.z = -10
		for i = -size/grid,size/grid
			\add {
				Vec2 i*grid,size
				Vec2 i*grid,-size
			}, Color 0xff000000
			\add {
				Vec2 -size,i*grid
				Vec2 size,i*grid
			}, Color 0xff000000

Director.entry\addChild with background!
	.z = 600
Director.entry\addChild with background!
	.angleX = 45

Director.entry\addChild with Spine "char_sijin"
	.scaleX = 2
	.scaleY = 2
	.y = -300
	duration = \play "battle_idle", true
	.speed = 0.5
	print duration
	\slot "AnimationEnd", (...)-> print ...
