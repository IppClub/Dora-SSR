Dorothy!

CircleVertices = (radius,verts = 20)->
	newV = (index,radius)->
		angle = 2*math.pi*index/verts
		Vec2(radius*math.cos(angle),radius*math.sin(angle)) + Vec2(radius,radius)
	[newV index, radius for index = 0, verts]

StarVertices = (radius)->
	a = math.rad 36
	c = math.rad 72
	f = math.sin(a)*math.tan(c)+math.cos(a)
	R = radius
	r = R/f
	return for i = 9,0,-1
		angle = i*a
		cr = i%2 == 1 and r or R
		Vec2 cr*math.sin(angle), cr*math.cos(angle)

Director.entry\addChild with Node!
	\addChild with DrawNode!
		.position = Vec2 200,200
		\drawPolygon StarVertices(60),Color(0x80ff0080),1,Color(0xffff0080)

	\addChild with Line CircleVertices(60),Color(0xff00ffff)
		.position = Vec2 -200,200

	\addChild with Node!
		.color = Color 0xff00ffff
		.scaleX = 2
		.scaleY = 2
		\addChild with DrawNode!
			.opacity = 0.5
			\drawPolygon {
				Vec2 -20,-10
				Vec2 20,-10
				Vec2 20,10
				Vec2 -20,10
			}
			\drawPolygon {
				Vec2 20,3
				Vec2 32,10
				Vec2 32,-10
				Vec2 20,-3
			}
			\drawDot Vec2(-11,20),10
			\drawDot Vec2(11,20),10
		\addChild with Line {
				Vec2 0,0
				Vec2 40,0
				Vec2 40,20
				Vec2 0,20
				Vec2 0,0
			}
			.position = Vec2 -20,-10
		\addChild with Line CircleVertices(10)
			.position = Vec2 -21,10
		\addChild with Line CircleVertices(10)
			.position = Vec2 1,10
		\addChild Line {
			Vec2 20,3
			Vec2 32,10
			Vec2 32,-10
			Vec2 20,-3
		}

-- example codes ends here, some test ui below --

Dorothy builtin.ImGui

Director.entry\addChild with Node!
	\schedule ->
		:width,:height = App.visualSize
		SetNextWindowPos Vec2(width-250,10), "FirstUseEver"
		SetNextWindowSize Vec2(240,120), "FirstUseEver"
		Begin "Draw Node", "NoResize|NoSavedSettings", ->
			TextWrapped "Draw shapes and lines!"
