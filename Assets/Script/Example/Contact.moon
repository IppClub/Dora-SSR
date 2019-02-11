Dorothy!

gravity = Vec2 0,-10

world = with PhysicsWorld!
	\setShouldContact 0,0,true
	.showDebug = true

label = with Label "NotoSansHans-Regular",30
	\addTo world

terrainDef = with BodyDef!
	count = 50
	radius = 300
	vertices = for i = 1,count+1
		angle = 2*math.pi*i/count
		Vec2 radius*math.cos(angle),radius*math.sin(angle)
	\attachChain vertices,0.4,0
	\attachDisk Vec2(0,-270),30,1,0,1.0
	\attachPolygon Vec2(0,80),120,30,0,1,0,1.0

terrain = with Body terrainDef,world
	\addTo world

drawNode = with Line {Vec2(-20,0),Vec2(20,0),Vec2.zero,Vec2(0,-20),Vec2(0,20)},Color(0xff00ffff)
	\addTo world

diskDef = with BodyDef!
	.type = BodyType.Dynamic
	.linearAcceleration = gravity
	\attachDisk 20,5,0.8,1

disk = with Body diskDef,world,Vec2(100,200)
	\addTo world
	.angularRate = -1800
	.receivingContact = true
	\slot "ContactStart",(body,point)->
		drawNode.position = point
		label.text = "Contact: "..string.format("[%d,%d]",point.x,point.y)

Director.entry\addChild world

-- example codes ends here, some test ui below --

Dorothy builtin.ImGui

Director.entry\addChild with Node!
	\schedule ->
		{:width,:height} = App.visualSize
		SetNextWindowPos Vec2(width-250,10), "FirstUseEver"
		SetNextWindowSize Vec2(240,140), "FirstUseEver"
		if Begin "Contact", "NoResize|NoSavedSettings"
			TextWrapped "Recieve events when physics bodies contact."
			changed, disk.receivingContact = Checkbox "Receiving Contact", disk.receivingContact
			label.text = "" if changed
		End!
