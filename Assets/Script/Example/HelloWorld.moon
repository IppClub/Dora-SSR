Dorothy!

Director\pushEntry with Node!
	\slot "Enter",-> print "on enter event"
	\slot "Exit",-> print "on exit event"
	\slot "Cleanup",-> print "on node destoyed event"
	\schedule once ->
		for i = 5, 1, -1
			print i
			sleep 1
		print "Hello World!"

-- example codes ends here, some test ui below --

Dorothy builtin.ImGui

currentEntry = Director.currentEntry
threadLoop ->
	{:width,:height} = Application.designSize
	SetNextWindowPos Vec2(width-250,10), "FirstUseEver"
	SetNextWindowSize Vec2(240,120), "FirstUseEver"
	if Begin "Hello World", "NoResize|NoSavedSettings"
		if BeginChild "scroll", Vec2 -1,-40
			Text "View outputs in log window!"
		EndChild!
	End!
	Director.currentEntry != currentEntry
