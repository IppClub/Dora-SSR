Dorothy builtin.ImGui

model = with Model "Model/jixienv.model"
	.loop = true
	.look = "happy"
	.recovery = 0.2
	\play "walk"

label = Label "NotoSansHans-Regular", 18
model\addChild label
model\slot "AnimationEnd",(name)->
	print name,"end!"

buffer = with Buffer 100
	\setString "attack"

LoadFontTTF "Font/fangzhen16.ttf", 16, "Chinese"

--SetStyleVar "AntiAliasedLines", false
--SetStyleVar "AntiAliasedShapes", false

Director.scheduler\schedule ->
	ShowStats!
	ShowLog!
	SetNextWindowSize Vec2(100,100), "FirstUseEver"
	if Begin "Test"
		if InputText "", buffer
			label.text = buffer\toString!
		if Button "Hit me!"
			model\play buffer\toString!
			--Audio\play "Audio/hero_win.wav"
			emit "GlobalEvent", 123, "abc"
	End!

Director\pushEntry model

thread ->
	sleep 1
	_G.x = 998
