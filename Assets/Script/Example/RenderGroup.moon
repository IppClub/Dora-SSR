Dorothy!

Item = Class Node,
	__init:=>
		@width = 144
		@height = 144
		@anchor = Vec2.zero

		@addChild with Sprite "Image/logo.png"
			.renderOrder = 1

		@addChild with DrawNode!
			\drawPolygon {
					Vec2 -50,-50
					Vec2 50,-50
					Vec2 50,50
					Vec2 -50,50
				},Color 0x3000ffff
			.renderOrder = 2
			.angle = 45

		@addChild with Line {
					Vec2 -50,-50
					Vec2 50,-50
					Vec2 50,50
					Vec2 -50,50
					Vec2 -50,-50
				},Color 0xffff0080
			.renderOrder = 3
			.angle = 45

		@runAction Angle 5,0,360
		@slot "ActionEnd",(action)-> @runAction action

Director\pushEntry with Node!
	.renderGroup = true
	.size = Size 750,750
	for i = 1,16 do \addChild Item!
	\alignItems!

-- example codes ends here, some test ui below --

Dorothy builtin.ImGui

currentEntry = Director.currentEntry
threadLoop ->
	{:width,:height} = Application.designSize
	SetNextWindowPos Vec2(width-250,10), "FirstUseEver"
	SetNextWindowSize Vec2(240,260), "FirstUseEver"
	if Begin "Draw Node", "NoResize|NoSavedSettings"
		if BeginChild "scroll"
			TextWrapped "When render group is enabled, the nodes in the sub render tree will be grouped by \"renderOrder\" property, and get rendered in ascending order!\nNotice the draw call changes in stats window."
			_, currentEntry.renderGroup = Checkbox "Grouped", currentEntry.renderGroup
		EndChild!
	End!
	Director.currentEntry != currentEntry
