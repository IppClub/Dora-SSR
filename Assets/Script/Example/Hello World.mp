_ENV = Dorothy!

Director.entry\addChild with Node!
	\slot "Enter",-> print "on enter event"
	\slot "Exit",-> print "on exit event"
	\slot "Cleanup",-> print "on node destoyed event"
	\schedule once ->
		for i = 5,1,-1
			print i
			sleep 1
		print "Hello World!"

-- example codes ends here, some test ui below --

_ENV = Dorothy builtin.ImGui

Director.entry\addChild with Node!
	\schedule ->
		:width,:height = App.visualSize
		SetNextWindowPos Vec2(width-250,10), "FirstUseEver"
		SetNextWindowSize Vec2(240,120), "FirstUseEver"
		Begin "Hello World", "NoResize|NoSavedSettings",->
			TextWrapped "Basic Dorothy schedule and signal function usage. View outputs in log window!"
