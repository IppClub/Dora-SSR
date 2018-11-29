Dorothy!

groupZero = 0
groupOne = 1
groupTwo = 2

terrainDef = with BodyDef!
	.type = BodyType.Static
	\attachPolygon 800,10

polygonDef = with BodyDef!
	.type = BodyType.Dynamic
	\attachPolygon {
		Vec2 60,0
		Vec2 30,-30
		Vec2 -30,-30
		Vec2 -60,0
		Vec2 -30,30
		Vec2 30,30
	},1,0.4,0.4

circleDef = with BodyDef!
	.type = BodyType.Dynamic
	\attachCircle 60,1,0.4,0.4

world = with PhysicsWorld!
	.y = -200
	\setShouldContact groupZero,groupOne,false
	\setShouldContact groupZero,groupTwo,true
	\setShouldContact groupOne,groupTwo,true
	.showDebug = true

Director.entry\addChild with world
	\addChild with Body terrainDef,world,Vec2.zero
		.group = groupTwo

	\addChild with Body polygonDef,world,Vec2(0,500),15
		.group = groupOne

	\addChild with Body circleDef,world,Vec2(50,800)
		.group = groupZero
		.angularRate = 90

-- example codes ends here, some test ui below --

Dorothy builtin.ImGui

Director.entry\addChild with Node!
	\schedule ->
		{:width,:height} = App.designSize
		SetNextWindowPos Vec2(width-250,10), "FirstUseEver"
		SetNextWindowSize Vec2(240,120), "FirstUseEver"
		if Begin "Body", "NoResize|NoSavedSettings"
			TextWrapped "Basic usage to create physics bodies!"
		End!
