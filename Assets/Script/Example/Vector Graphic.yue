_ENV = Dorothy!

drawHeart = -> with nvg
	.BeginPath!
	.MoveTo 36.29, 0
	.BezierTo 32.5244, 0.0, 28.9316, 1.3173, 26.0742, 3.7275
	.BezierTo 23.2168, 1.3173, 19.624, 0, 15.8593, 0
	.BezierTo 5.4843, 0, 0, 5.4838, 0, 15.8588
	.BezierTo 0.0, 23.5278, 9.248, 33.1123, 14.7607, 38.143
	.BezierTo 17.2099, 40.3779, 23.8379, 46.0322, 25.9765, 46.2172
	.BezierTo 26.0097, 46.2207, 26.0478, 46.2226, 26.08, 46.2216
	.BezierTo 26.1093, 46.2216, 26.1377, 46.2207, 26.165, 46.2177
	.LineTo 26.165, 46.2163
	.BezierTo 28.2246, 46.0263, 34.748, 40.4858, 37.165, 38.2939
	.BezierTo 42.7607, 33.2197, 52.1484, 23.5581, 52.1484, 15.8588
	.BezierTo 52.1484, 5.4838, 46.665, 0, 36.29, 0
	.ClosePath!
	.FillColor Color 253, 90, 90, 255
	.Fill!

stopRendering = false

Director.entry\addChild with VGNode 60,50,5
	\render drawHeart
	\slot "Cleanup",-> stopRendering = true
	\runAction Sequence Scale(0.2,1.0,0.3),Scale(0.5,0.3,1.0,Ease.OutBack)
	\slot "ActionEnd",=> \runAction @

drawAnimated = loop ->
	cycle 0.2,(time)->
		scale = 1-time*0.7
		nvg.Scale scale,scale
		drawHeart!
	cycle 0.5,(time)->
		scale = 0.3+Ease\func(Ease.OutBack,time)*0.7
		nvg.Scale scale,scale
		drawHeart!
threadLoop ->
	nvg.Scale 2,2
	drawAnimated!
	stopRendering

-- example codes ends here, some test ui below --

_ENV = Dorothy builtin.ImGui

Director.entry\addChild with Node!
	\schedule ->
		:width,:height = App.visualSize
		SetNextWindowPos Vec2(width-250,10), "FirstUseEver"
		SetNextWindowSize Vec2(240,120), "FirstUseEver"
		Begin "Vector Graphic Rendering", "NoResize|NoSavedSettings", ->
			TextWrapped "Use nanoVG lib to do vector graphic rendering, render to a texture or do instant render!"
