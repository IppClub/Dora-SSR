_ENV = Dorothy builtin.ImGui,builtin.Platformer
import "UI.View.Shape.Star"

store:Store = Data
{
	:world
	:ZombieLayer
	:PlayerGroup
} = Store

playerGroup = Group {"player"}
zombieGroup = Group {"zombie"}
userControl = false
playerChoice = 1
controlChoice = switch App.platform
	when "iOS","Android" then 0
	else 1
camZoom = world.camera.zoom
decisions = {}
showDecisionTrace = false
lastDecisionTree = ""
world\schedule ->
	:width,:height = App.visualSize
	SetNextWindowPos Vec2(width-250,10), "FirstUseEver"
	SetNextWindowSize Vec2(240,userControl and 500 or 300)
	Begin "Zombie Game Demo", "NoResize|NoSavedSettings", ->
		TextWrapped "Zombie Killed: #{Store.zombieKilled}"
		SameLine!
		if Button "Army"
			for i = 0,10
				available = false
				pos = Vec2.zero
				while not available
					pos = Vec2 App.rand%2400-1200,-430
					available = not world\query Rect(pos,Size(5,5)),=> @group == Data.groupTerrain
				with Entity!
					.unitDef = "Unit_Zombie#{App.rand%2 + 1}"
					.order = ZombieLayer
					.position = pos
					.group = PlayerGroup
					.isPlayer = false
					.faceRight = App.rand%2 == 0
					.stared = true
		changed,camZoom = DragFloat "Zoom", camZoom, 0.01, 0.5, 2, "%.2f"
		world.camera.zoom = camZoom if changed
		playerGroup\each => TextWrapped "#{@unit.tag} HP: #{@hp}"
		changed,result = Checkbox "Physics Debug",world.showDebug
		world.showDebug = result if changed
		changed,showDecisionTrace = Checkbox "AI Debug",showDecisionTrace
		if changed
			playerGroup\each => @unit.receivingDecisionTrace = showDecisionTrace
		changed,userControl = Checkbox "Take Control",userControl
		if userControl
			if Store.controlPlayer == "Zombie" and
				not playerGroup\each =>
					if @unit.tag == "Zombie"
						if @hp <= 0
							@player = nil
							@unit.children.last\removeFromParent!
							@unit.decisionTree = ""
							@unit.tag = "ZombieDead"
							return false
						else return true
					return false
				zombieGroup\each =>
					return false if @hp <= 0
					@player = true
					@zombie = nil
					world.camera.followTarget = with @unit
						.tag = "Zombie"
						.group = PlayerGroup
						.decisionTree = "AI_PlayerControl"
						.sensity = 0
						\addChild Star {
							y: 100
							size: 18
							borderColor: 0xffff8800
							fillColor: 0x66ff8800
							fillOrder: 1
							lineOrder: 2
						}
					true
			Separator!
			pressedA,choice = RadioButton "Male",playerChoice,0
			playerChoice = choice if pressedA
			pressedB,choice = RadioButton "Female",playerChoice,1
			playerChoice = choice if pressedB
			pressedC,choice = RadioButton "Zombie",playerChoice,2
			playerChoice = choice if pressedC
			if pressedA or pressedB or pressedC or changed
				Store.controlPlayer = switch playerChoice
					when 0 then "KidM"
					when 1 then "KidW"
					when 2 then "Zombie"
				if Store.controlPlayer == "Zombie" and
					not playerGroup\each => @unit.tag == "Zombie"
					zombieGroup\each =>
						@player = true
						@zombie = nil
						with @unit
							.tag = "Zombie"
							.group = PlayerGroup
							\addChild Star {
								y: 100
								size: 18
								borderColor: 0xffff8800
								fillColor: 0x66ff8800
								fillOrder: 1
								lineOrder: 2
							}
						true
				playerGroup\each =>
					if @unit.tag == Store.controlPlayer
						@unit.decisionTree = "AI_PlayerControl"
						@unit.sensity = 0
						world.camera.followTarget = @unit
					else
						@unit.decisionTree = switch @unit.tag
							when "KidM" then "AI_KidFollow"
							when "KidW" then "AI_KidSearch"
							when "Zombie" then "AI_Zombie"
						@unit.sensity = 0.1
			if changed
				Store.keyboardEnabled = controlChoice == 1
				Director.ui.children.first.visible = controlChoice == 0
			Separator!
			TextWrapped if controlChoice == 1
				"Keyboard: Left(A), Right(D), Shoot(J), Jump(K)"
			else "TouchPad: Use buttons in lower screen to control unit."
			Separator!
			pressedA,choice = RadioButton "TouchPad",controlChoice,0
			if pressedA
				controlChoice = choice
				Store.keyboardEnabled = false
				Director.ui\eachChild => @visible = true
			pressedB,choice = RadioButton "Keyboard",controlChoice,1
			if pressedB
				controlChoice = choice
				Store.keyboardEnabled = true
				Director.ui.children.first.visible = false
		elseif changed
			playerGroup\each =>
				@unit.decisionTree = switch @unit.tag
					when "KidM" then "AI_KidFollow"
					when "KidW" then "AI_KidSearch"
					when "Zombie" then "AI_Zombie"
				@unit.sensity = 0.1
			Store.keyboardEnabled = false
			Director.ui.children.first.visible = false

	target = world.camera.followTarget
	if target
		player = target.entity
		decisionTrace = player.decisionTrace
		lastDecision = decisions[#decisions]
		if lastDecision ~= decisionTrace
			table.insert decisions,decisionTrace
		table.remove decisions,1 if #decisions > 5
		lastDecisionTree = target.decisionTree

	if showDecisionTrace
		SetNextWindowPos Vec2(width/2-200,10), "FirstUseEver"
		SetNextWindowSize Vec2(400,160), "FirstUseEver"
		Begin "Decision Trace (#{lastDecisionTree})", "NoSavedSettings", ->
			Text table.concat decisions,"\n"

with Observer "Add", {"unitDef","position","order","group","isPlayer","faceRight","stared"}
	\every =>
		{:group,:unit} = @
		unit\addChild Star {
			y: 100
			size: 18
			borderColor: 0xff66ccff
			fillColor: 0x6666ccff
			fillOrder: 1
			lineOrder: 2
		}

with Observer "Add", {"player"}
	\every => @unit.receivingDecisionTrace = true
