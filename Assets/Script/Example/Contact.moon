Dorothy!

world = with World!
	\setShouldContact 0,0,true
	.showDebug = true

label = Label "NotoSansHans-Regular",30
world\addChild label

terrainDef = with BodyDef!
	count = 50
	radius = 300
	vertices = for i = 1,count
		angle = 2*math.pi*i/count
		Vec2 radius*math.cos(angle),radius*math.sin(angle)
	\attachLoop vertices,0.4,0
	\attachCircle Vec2(0,-270),30,1,0,1.0
	\attachPolygon Vec2(0,80),120,30,0,1,0,1.0

circleDef = with BodyDef!
	.type = BodyType.Dynamic
	\attachCircle 20,5,0.8,1

terrain = Body terrainDef,world
world\addChild terrain

circle = with Body circleDef,world,Vec2(100,200)
	.angularRate = -1800
world\addChild circle

drawNode = Line {Vec2(-20,0),Vec2(20,0),Vec2.zero,Vec2(0,-20),Vec2(0,20)},Color(0xff00ffff)
world\addChild drawNode

circle.receivingContact = true
circle\slot "ContactStart",(body,point)->
	drawNode.position = point
	label.text = "Contact: "..string.format("[%d,%d]",point.x,point.y)

Director.entry\addChild world

-- example codes ends here, some test ui below --

Dorothy builtin.ImGui

Director.entry\addChild with Node!
	\schedule ->
		{:width,:height} = Application.designSize
		SetNextWindowPos Vec2(width-250,10), "FirstUseEver"
		SetNextWindowSize Vec2(240,140), "FirstUseEver"
		if Begin "Contact", "NoResize|NoSavedSettings"
			TextWrapped "Recieve events when physics bodies contact."
			changed, circle.receivingContact = Checkbox "Receiving Contact", circle.receivingContact
			label.text = "" if changed
		End!
