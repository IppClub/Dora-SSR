_ENV = Dorothy builtin.Platformer

store:Store = Data
{
	:MaxBunnies
	:GroupPlayer
	:GroupEnemyPoke
} = Store

heroes = Group {"hero"}

lastAction = "idle"
lastActionFrame = App.frame
data = {}
row = nil
Do = (name)-> Seq {
	Con "Collect data", =>
		if @isDoing name
			row = nil
			return true

		unless AI\getNearestUnit(Relation.Enemy)?
			row = nil
			return true

		attack_ready = do
			attackUnits = AI\getUnitsInAttackRange!
			ready = false
			for unit in *attackUnits
				if Relation.Enemy == Data\getRelation(@,unit) and
					(@x < unit.x) == @faceRight
					ready = true
					break
			ready

		not_facing_enemy = heroes\each (hero)->
			{:unit} = hero
			if Relation.Enemy == Data\getRelation unit,@
				if (@x > unit.x) == @faceRight
					return true

		enemy_in_attack_range = do
			enemy = AI\getNearestUnit Relation.Enemy
			attackUnits = AI\getUnitsInAttackRange!
			attackUnits and attackUnits\contains(enemy) or false

		nearest_enemy_distance = do
			enemy = AI\getNearestUnit Relation.Enemy
			if enemy?
				math.abs enemy.x - @x
			else
				999999

		enemy_hero_action = do
			enemies = AI\getUnitsByRelation Relation.Enemy
			actionName = "unknown"
			for enemy in *enemies
				if enemy.entity.hero
					actionName = enemy.currentAction?.name or "unknown"
					break
			actionName

		hero_hp = @entity.hp

		last_action = lastAction

		last_action_interval = (App.frame - lastActionFrame) / 60

		see_enemy = AI\getNearestUnit(Relation.Enemy)?

		reach_map_limit = (@x < 100 and not @faceRight) or (@x > 3990 and @faceRight)

		hero_ep = @entity.ep

		switch_available = heroes\each (hero)->
			return false if @group ~= hero.group
			needEP,available = switch @entity.targetSwitch
				when "Switch"
					bunnyCount = 0
					Group({"bunny"})\each (bunny)->
						bunnyCount += 1 if bunny.group == @group
					1,bunnyCount < MaxBunnies
				when "SwitchG"
					2,hero.defending
				else
					0,false
			if hero.ep >= needEP and available
				if not @entity.atSwitch\isDoing "pushed"
					hero.defending = false if @entity.targetSwitch == "SwitchG"
					return true

		is_at_switch = do
			theSwitch = @entity.atSwitch
			theSwitch? and not theSwitch.entity.pushed and
			(@x < theSwitch.x == @faceRight)

		facing_enemy_base = @faceRight

		enemy_base_distance = math.abs 3990 - @x

		poke_is_around, nearest_poke_distance, poke_coming_at_face = do
			is_around = false
			distance = 999999
			coming_at_face = false
			for body in *AI\getDetectedBodies!
				if body.group == GroupEnemyPoke
					is_around = true
					distance = math.min(math.abs body.x - @x, distance)
					coming_at_face or= (@faceRight == (body.velocityX < 0))
			is_around, distance, coming_at_face

		row = {
			--:is_at_switch
			--:switch_available
			--:see_enemy
			:not_facing_enemy
			:enemy_in_attack_range
			:attack_ready
			:enemy_hero_action
			:nearest_enemy_distance
			:hero_hp
			--:hero_ep
			:last_action
			:last_action_interval
			--:reach_map_limit
			--:facing_enemy_base
			--:enemy_base_distance
			:poke_is_around
			:nearest_poke_distance
			:poke_coming_at_face
			action:name
		}
		true
	Sel {
		Con "is doing",=> @isDoing name
		Seq {
			Act name
			Con "action succeeded",=>
				lastAction = name
				lastActionFrame = App.frame
				true
		}
	}
	Con "Save data",=>
		return true if row == nil
		table.insert data,row
		emit "CollectedData",#data
		true
}

rowNames = {
	--"is_at_switch"
	--"switch_available"
	--"see_enemy"
	"not_facing_enemy"
	"enemy_in_attack_range"

	"attack_ready"
	"enemy_hero_action"
	"nearest_enemy_distance"
	"hero_hp"
	--"hero_ep"

	"last_action"
	"last_action_interval"
	--"reach_map_limit"
	--"facing_enemy_base"
	--"enemy_base_distance"

	"poke_is_around"
	"nearest_poke_distance"
	"poke_coming_at_face"

	"action"
}

rowTypes = {
	--'C','C',
	--'C'
	'C','C'
	'C','C','N','N'
	--'N'
	'C','N'
	--'C','C','N'
	'C','N','C'
	'C'
}

learnedAI = -> "unknown"

Director.entry\addChild with Node!
	\gslot "TrainAI",->
		csvData = for row in *data
			rd = for name in *rowNames
				val = if row[name]? then row[name] else "N"
				if "boolean" == type val
					val = if val then "T" else "F"
				tostring val
			table.concat rd,","
		names = "#{table.concat rowNames,','}\n"
		dataStr = "#{names}#{table.concat rowTypes,','}\n#{table.concat csvData,'\n'}"
		data = {}
		Content\save Path(Content.writablePath,"loliwar.csv"),dataStr
		print "#{#csvData} records saved!"
		thread ->
			lines = {"(_ENV)->"}
			accuracy = ML\buildDecisionTreeAsync dataStr,0,(depth,name,op,value)->
				line = string.rep("\t",depth+1) .. if name ~= "" then
					"if #{name} #{op} #{op=='==' and "\"#{value}\"" or value}"
				else
					"#{op} \"#{value}\""
				lines[#lines+1] = line
			lines[#lines+1] = "\treturn \"unknown\""
			codes = table.concat lines,"\n"
			print "accuracy: #{accuracy}"
			import "moonp"
			luaCodes = moonp.to_lua codes,{reserve_line_number:false}
			learnedAI = load(luaCodes)!
			print codes
			wait -> heroes\each (hero)->
				:unit = hero
				if unit.group == GroupPlayer
					unit.decisionTree = "HeroLearnedAI"
					return true
				false
			print "Done!"

gameEndWait = Seq {
	Con "game end",=> Store.winner?
	Sel {
		Seq {
			Con "need wait",=> @onSurface and not @isDoing "wait"
			Act "cancel"
			Act "wait"
		}
		Pass!
	}
}

Store["PlayerControlAI"] = Sel {
	Seq {
		Con "is dead",=> @entity.hp <= 0
		Pass!
	}
	Seq {
		Con "pushing switch",=> @isDoing "pushSwitch"
		Pass!
	}
	Seq {
		Seq {
			Con "move key down",=>
				not (@entity.keyLeft and @entity.keyRight) and
				(
					(@entity.keyLeft and @faceRight) or
					(@entity.keyRight and not @faceRight)
				)
			Act "turn"
		}
		Reject!
	}
	Seq {
		Con "attack key down",=> Store.winner == nil and @entity.keyF
		Sel {
			Seq {
				Con "at switch",=>
					theSwitch = @entity.atSwitch
					theSwitch? and not theSwitch.entity.pushed and
					(@x < theSwitch.x == @faceRight)
				Act "pushSwitch"
			}
			Do "villyAttack"
			Do "meleeAttack"
			Do "rangeAttack"
		}
	}
	Sel {
		Seq {
			Con "is falling",=> not @onSurface
			Act "fallOff"
		}
		Seq {
			Con "jump key down",=> @entity.keyUp
			Do "jump"
		}
	}
	Seq {
		Con "move key down",=> @entity.keyLeft or @entity.keyRight
		Act "walk"
	}
	Act "idle"
}

learnedAction = "unknown"
Store["HeroLearnedAI"] = Sel {
	Seq {
		Con "is dead",=> @entity.hp <= 0
		Pass!
	}
	Seq {
		Con "is falling",=> not @onSurface
		Act "fallOff"
	}
	gameEndWait
	Seq {
		Con "run learned AI", =>
			@entity.lastActionTime or= 0

			return false unless AI\getNearestUnit(Relation.Enemy)?

			if App.totalTime - @entity.lastActionTime < 0.1
				return false
			else
				@entity.lastActionTime = App.totalTime

			is_at_switch = do
				theSwitch = @entity.atSwitch
				if theSwitch? and not theSwitch.entity.pushed and
					(@x < theSwitch.x == @faceRight)
					"T"
				else
					"F"

			attack_ready = do
				attackUnits = AI\getUnitsInAttackRange!
				ready = "F"
				for unit in *attackUnits
					if Relation.Enemy == Data\getRelation(@,unit) and
						(@x < unit.x) == @faceRight
						ready = "T"
						break
				ready

			not_facing_enemy = (heroes\each (hero)->
				{:unit} = hero
				if Relation.Enemy == Data\getRelation unit,@
					if (@x > unit.x) == @faceRight
						return true) and "T" or "F"

			enemy_in_attack_range = do
				enemy = AI\getNearestUnit Relation.Enemy
				attackUnits = AI\getUnitsInAttackRange!
				(attackUnits and attackUnits\contains(enemy)) and "T" or "F"

			nearest_enemy_distance = do
				enemy = AI\getNearestUnit Relation.Enemy
				if enemy?
					math.abs enemy.x - @x
				else
					999999

			enemy_hero_action = do
				enemies = AI\getUnitsByRelation Relation.Enemy
				actionName = "unknown"
				for enemy in *enemies
					if enemy.entity.hero
						actionName = enemy.currentAction?.name
						break
				actionName

			hero_hp = @entity.hp

			hero_ep = @entity.ep

			last_action = lastAction

			last_action_interval = (App.frame - lastActionFrame) / 60

			reach_map_limit = ((@x < 100 and not @faceRight) or (@x > 3990 and @faceRight)) and "T" or "F"

			switch_available = (heroes\each (hero)->
				return false if @group ~= hero.group
				needEP,available = switch @entity.targetSwitch
					when "Switch"
						bunnyCount = 0
						Group({"bunny"})\each (bunny)->
							bunnyCount += 1 if bunny.group == @group
						1,bunnyCount < MaxBunnies
					when "SwitchG"
						2,hero.defending
					else
						0,false
				if hero.ep >= needEP and available
					if not @entity.atSwitch\isDoing "pushed"
						hero.defending = false if @entity.targetSwitch == "SwitchG"
						return true) and "T" or "F"

			facing_enemy_base = @faceRight and "T" or "F"

			enemy_base_distance = math.abs 3990 - @x

			poke_is_around, nearest_poke_distance, poke_coming_at_face = do
				is_around = false
				distance = 999999
				coming_at_face = false
				for body in *AI\getDetectedBodies!
					if body.group == GroupEnemyPoke
						is_around = true
						distance = math.min(math.abs body.x - @x, distance)
						coming_at_face or= (@faceRight == (body.velocityX < 0))
				is_around and "T" or "F", distance, coming_at_face and "T" or "F"

			learnedAction = learnedAI {
				--:is_at_switch
				--:switch_available
				--:see_enemy
				:not_facing_enemy
				:enemy_in_attack_range
				:attack_ready
				:enemy_hero_action
				:nearest_enemy_distance
				:hero_hp
				--:hero_ep
				:last_action
				:last_action_interval
				--:reach_map_limit
				--:facing_enemy_base
				--:enemy_base_distance
				:poke_is_around
				:nearest_poke_distance
				:poke_coming_at_face
			}
			true
		Sel {
			Con "is doing",=> @isDoing learnedAction
			Seq {
				Act => learnedAction
				Con "Succeeded prediction",=>
					emit "Prediction",true
					true
			}
			Con "Failed prediction",=>
				emit "Prediction",false
				false
		}
	}
	Seq {
		Con "not facing enemy",=> heroes\each (hero)->
			{:unit} = hero
			if Relation.Enemy == Data\getRelation unit,@
				if (@x > unit.x) == @faceRight
					return true
		Act "turn"
	}
	Seq {
		Con "need turn",=>
			(@x < 100 and not @faceRight) or (@x > 3990 and @faceRight)
		Act "turn"
	}
	Act "walk"
}

Store["HeroAI"] = Sel {
	Seq {
		Con "is dead",=> @entity.hp <= 0
		Pass!
	}
	Seq {
		Con "is falling",=> not @onSurface
		Act "fallOff"
	}
	gameEndWait
	Seq {
		Con "need attack",=>
			attackUnits = AI\getUnitsInAttackRange!
			for unit in *attackUnits
				if Relation.Enemy == Data\getRelation(@,unit) and
					(@x < unit.x) == @faceRight
					return true
			false
		Sel {
			Act "villyAttack"
			Act "rangeAttack"
			Act "meleeAttack"
		}
	}
	Seq {
		Con "not facing enemy",=> heroes\each (hero)->
			{:unit} = hero
			if Relation.Enemy == Data\getRelation unit,@
				if (@x > unit.x) == @faceRight
					return true
		Act "turn"
	}
	Seq {
		Con "need turn",=> 
			(@x < 100 and not @faceRight) or (@x > 3990 and @faceRight)
		Act "turn"
	}
	Seq {
		Con "wanna jump",=> App.rand % 20 == 0
		Act "jump"
	}
	Seq {
		Con "is at enemy side",=> heroes\each (hero)->
			{:unit} = hero
			if Relation.Enemy == Data\getRelation unit,@
				if math.abs(@x - unit.x) < 50
					return true
		Act "idle"
	}
	Act "walk"
}

Store["BunnyForwardReturnAI"] = Sel {
	Seq {
		Con "is dead",=> @entity.hp <= 0
		Pass!
	}
	Seq {
		Con "is falling",=> not @onSurface
		Act "fallOff"
	}
	gameEndWait
	Seq {
		Con "need attack",=>
			attackUnits = AI\getUnitsInAttackRange!
			for unit in *attackUnits
				if Relation.Enemy == Data\getRelation(@,unit) and
					(@x < unit.x) == @faceRight
					return App.rand % 5 ~= 0
			false
		Act "meleeAttack"
	}
	Seq {
		Con "need turn",=>
			(@x < 100 and not @faceRight) or (@x > 3990 and @faceRight)
		Act "turn"
	}
	Act "walk"
}

Store["SwitchAI"] = Sel {
	Seq {
		Con "is pushed",=> @entity.pushed
		Act "pushed"
	}
	Act "waitUser"
}

switches = Group {"switch_"}
turnToSwitch = Seq {
	Con "go to switch",=> switches\each (switch_)->
		if switch_.group == @group and @entity.targetSwitch == switch_.switch_
			return (@x > switch_.unit.x) == @faceRight
	Act "turn"
	Reject!
}
Store["BunnySwitcherAI"] = Sel {
	Seq {
		Con "is dead",=> @entity.hp <= 0
		Pass!
	}
	Seq {
		Con "is falling",=> not @onSurface
		Act "fallOff"
	}
	gameEndWait
	Seq {
		Con "need attack",=>
			attackUnits = AI\getUnitsInAttackRange!
			for unit in *attackUnits
				if Relation.Enemy == Data\getRelation(@,unit) and
					(@x < unit.x) == @faceRight
					return App.rand % 5 ~= 0
			false
		Act "meleeAttack"
	}
	Seq {
		Con "at switch",=> with @entity
			return .atSwitch? and .atSwitch.entity.switch_ == .targetSwitch
		Sel {
			Seq {
				Con "switch available",=> heroes\each (hero)->
					return false if @group ~= hero.group
					needEP,available = switch @entity.targetSwitch
						when "Switch"
							bunnyCount = 0
							Group({"bunny"})\each (bunny)->
								bunnyCount += 1 if bunny.group == @group
							1,bunnyCount < MaxBunnies
						when "SwitchG"
							2,hero.defending
					if hero.ep >= needEP and available
						if not @entity.atSwitch\isDoing "pushed"
							hero.defending = false if @entity.targetSwitch == "SwitchG"
							return true
				Act "pushSwitch"
			}
			turnToSwitch
			Act "idle"
		}
	}
	Seq {
		Con "need turn",=>
			(@x < 100 and not @faceRight) or (@x > 3990 and @faceRight)
		Act "turn"
	}
	turnToSwitch
	Act "walk"
}
