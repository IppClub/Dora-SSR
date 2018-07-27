Dorothy!

Attrs = {
	Angle: {"B","float"}
	AngleVariance: {"C","float"}
	BlendFuncDestination: {"D","BlendFunc"}
	BlendFuncSource: {"E"," BlendFunc"}
	Duration: {"F","floatN"}
	EmissionRate: {"G","float"}
	FinishColor: {"H","Color"}
	FinishColorVariance: {"I","Color"}
	RotationStart: {"J","float"}
	RotationStartVariance: {"K","float"}
	RotationEnd: {"L","float"}
	RotationEndVariance: {"M","float"}
	FinishParticleSize: {"N","floatN"}
	FinishParticleSizeVariance: {"O","float"}
	MaxParticles: {"P","Uint32"}
	ParticleLifespan: {"Q","float"}
	ParticleLifespanVariance: {"R","float"}
	StartPosition: {"S","Vec2"}
	StartPositionVariance: {"T","Vec2"}
	StartColor: {"U","Color"}
	StartColorVariance: {"V","Color"}
	StartParticleSize: {"W","float"}
	StartParticleSizeVariance: {"X","float"}
	TextureName: {"Y","string"}
	TextureRect: {"Z","Rect"}
	EmitterMode: {"a","EmitterType"}
	-- gravity
	RotationIsDir: {"b","bool"}
	Gravity: {"c","Vec2"}
	Speed: {"d","float"}
	SpeedVariance: {"e","float"}
	RadialAcceleration: {"f","float"}
	RadialAccelVariance: {"g","float"}
	TangentialAcceleration: {"h","float"}
	TangentialAccelVariance: {"i","float"}
	-- radius
	StartRadius: {"j","float"}
	StartRadiusVariance: {"k","float"}
	FinishRadius: {"l","floatN"}
	FinishRadiusVariance: {"m","float"}
	RotatePerSecond: {"n","float"}
	RotatePerSecondVariance: {"o","float"}
}

Data = {
	Angle:90
	AngleVariance:360
	BlendFuncDestination:BlendFunc\get "One"
	BlendFuncSource:BlendFunc\get "SrcAlpha"
	Duration:-1
	EmissionRate:350
	FinishColor:Color 0xff000000
	FinishColorVariance:Color 0x0
	RotationStart:0
	RotationStartVariance:0
	RotationEnd:0
	RotationEndVariance:0
	FinishParticleSize:-1
	FinishParticleSizeVariance:0
	MaxParticles:100
	ParticleLifespan:1
	ParticleLifespanVariance:0.5
	StartPosition:Vec2 0,0
	StartPositionVariance:Vec2 0,0
	StartColor:Color 194,64,31,255
	StartColorVariance:Color 0x0
	StartParticleSize:30
	StartParticleSizeVariance:10
	TextureName:""
	TextureRect:Rect 0,0,0,0
	EmitterMode:0
	RotationIsDir:false
	Gravity:Vec2 0,100
	Speed:20
	SpeedVariance:5
	RadialAcceleration:0
	RadialAccelVariance:0
	TangentialAcceleration:0
	TangentialAccelVariance:0

	-- radius emitter available
	--StartRadius:0
	--StartRadiusVariance:0
	--FinishRadius:-1
	--FinishRadiusVariance:0
	--RotatePerSecond:0
	--RotatePerSecondVariance:0
}

toString = (value)->
	switch tolua.type value
		when "number"
			"#{value}"
		when "string"
			value
		when "Rect"
			"#{value.x},#{value.y},#{value.width},#{value.height}"
		when "boolean"
			value and "1" or "0"
		when "Vec2"
			"#{value.x},#{value.y}"
		when "Color"
			string.format "%.2f,%.2f,%.2f,%.2f",value.r/255,value.g/255,value.b/255,value.a/255

Cache\update "__test__.par", "<A>"..table.concat(["<#{Attrs[k][1]} A=\"#{toString v}\"/>" for k,v in pairs Data]).."</A>"

particle = with Particle "__test__.par"
	\start!

Director.entry\addChild with Node!
	.scaleX = 2
	.scaleY = 2
	\addChild particle
	.touchEnabled = true
	\slot "TapMoved",(touch)->
		return unless touch.id == 0
		particle.position += touch.delta/2

-- example codes ends here, some test ui below --

Dorothy builtin.ImGui

DataDirty = false

Item = (name,value)->
	PushItemWidth -180
	switch Attrs[name][2]
		when "float"
			changed, Data[name] = DragFloat name, Data[name], 0.1, 0, 1000
			DataDirty = true if changed
		when "floatN"
			changed, Data[name] = DragFloat name, Data[name], 0.1, -1, 1000
			DataDirty = true if changed
		when "Uint32"
			changed, Data[name] = DragInt name, Data[name], 1, 0, 1000
			DataDirty = true if changed
		when "EmitterType"
			LabelText "EmitterType","Gravity"
		when "BlendFunc"
			LabelText "BlendFunc","Additive"
		when "Vec2"
			changed = DragInt2 name, Data[name], 1, -1000, 1000
			DataDirty = true if changed
		when "Color"
			PushItemWidth -150
			SetColorEditOptions "RGB"
			changed = ColorEdit4 name, Data[name]
			DataDirty = true if changed
			PopItemWidth!
		when "bool"
			changed, Data[name] = Checkbox name, Data[name]
			DataDirty = true if changed
		else
			nil
	PopItemWidth!

work = loop ->
	sleep 1
	if DataDirty
		DataDirty = false
		Cache\update "__test__.par", "<A>"..table.concat(["<#{Attrs[k][1]} A=\"#{toString v}\"/>" for k,v in pairs Data]).."</A>"
		particle\removeFromParent!
		particle = with Particle "__test__.par"
			\start!
		Director.entry.children.first\addChild particle

Director.entry\addChild with Node!
	\schedule ->
		{:width,:height} = Application.designSize
		SetNextWindowPos Vec2(width-400,10), "FirstUseEver"
		SetNextWindowSize Vec2(390,height-80), "FirstUseEver"
		if Begin "Particle", "NoResize|NoSavedSettings"
			for k,v in pairs Data
				Item k,v
		End!
		work!
