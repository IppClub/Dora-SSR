Dorothy!

Director.entry\addChild with Node!
	\addChild with Label "NotoSansHans-Regular",40
		.batched = false
		.text = "你好，Dorothy！"
		for i = 1,.characterCount
			char = \getCharacter i
			char?\runAction Sequence Delay(i/5),Scale(0.2,1,2),Scale(0.2,2,1)

	\addChild with Label "DroidSansFallback",30
		.text = "-- from Jin."
		.color = Color 0x0000ffff
		.position = Vec2 120,-70
		\runAction Sequence Delay(2),Opacity(0.2,0,1)

-- example codes ends here, some test ui below --

Dorothy builtin.ImGui

Director.entry\addChild with Node!
	\schedule ->
		:width,:height = App.visualSize
		SetNextWindowPos Vec2(width-250,10), "FirstUseEver"
		SetNextWindowSize Vec2(240,120), "FirstUseEver"
		Begin "Label", "NoResize|NoSavedSettings", ->
			TextWrapped "Render labels with unbatched and batched methods!"
