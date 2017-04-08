Dorothy builtin.ImGui

model = with Model "Model/jixienv.model"
	.loop = true
	.look = "happy"
	.recovery = 0.2
	\play "walk"

label = Label "NotoSansHans-Regular", 18
model\addChild label

buffer = Buffer 4*100

LoadFontTTF "Font/fangzhen16.ttf", 16, "Chinese"

--SetStyleVar "AntiAliasedLines", false
--SetStyleVar "AntiAliasedShapes", false

model\schedule ->
	ShowStats!
	SetNextWindowSize Vec2(100,100), "FirstUseEver"
	if Begin "Test", "MenuBar"
		if InputText "", buffer
			label.text = buffer\toString!
		if Button "Hit me!"
			model\play label.text
			Audio\play "Audio/hero_win.wav"
	End!

Director\pushEntry model
