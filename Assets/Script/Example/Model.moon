Dorothy!

model = with Model "Model/xiaoli.model"
	.loop = true
	.recovery = 0.2
	.look = "happy"
	\play "walk"
	\slot "AnimationEnd",(name)->
		print name, "end"

Director\pushEntry model

-- example ends here, test ui codes below --

Dorothy builtin.ImGui

looks = Model\getLooks "Model/xiaoli.model"
animations = Model\getAnimations "Model/xiaoli.model"
currentLook = 1
currentAnim = 3
model\schedule ->
	{:width,:height} = Application.designSize
	SetNextWindowPos Vec2(width-250,10), "FirstUseEver"
	SetNextWindowSize Vec2(240,325), "FirstUseEver"
	if Begin "Model", "NoResize|NoSavedSettings"
		changed,currentLook = Combo "Look",currentLook, looks
		model.look = looks[currentLook] if changed
		changed,currentAnim = Combo "Anim",currentAnim, animations
		model\play animations[currentAnim] if changed
		changed, model.loop = Checkbox "Loop", model.loop
		model\play animations[currentAnim] if changed
		SameLine!
		changed, model.reversed = Checkbox "Reversed", model.reversed
		model\play animations[currentAnim] if changed
		PushItemWidth -70
		changed, model.speed = DragFloat "Speed", model.speed, 0.01, 0, 10, "%.2f"
		PopItemWidth!
		PushItemWidth -70
		changed, model.recovery = DragFloat "Recovery", model.recovery, 0.01, 0, 10, "%.2f"
		PopItemWidth!
		scale = model.scaleX
		_,scale = DragFloat "Scale", scale, 0.01, 0.5, 2, "%.2f"
		model.scaleX = scale
		model.scaleY = scale
		if Button "Play", Vec2 140,30
			model\play animations[currentAnim]
	End!
