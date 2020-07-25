_ENV = Dorothy builtin.Platformer
{store:Store} = Data

import "Platformer" as {Act:Do}

lastAction = "idle"
lastActionFrame = App.frame
data = {}
row = nil
Act = (name)-> Seq {
	Con "Collect data", =>
		switch name
			when "fallOff","cancel"
				return true
		return true if @decisionTree ~= "AI_KidSearch"
		sensor = @getSensorByTag UnitDef.AttackSensorTag
		attack_path_blocked = if sensor.sensedBodies\each (body)->
				body.group == Data.groupTerrain and
				(@x > body.x) ~= @faceRight and
				body.tag == "Obstacle"
			faceObstacle = true
			start = @position
			stop = Vec2 start.x+(@faceRight and 1 or -1)*@unitDef.attackRange.width,start.y
			Store.world\raycast start,stop,true,(b)->
				return false if b.group == Data.groupDetection
				faceObstacle = false if Relation.Enemy == Data\getRelation @,b
				true
			faceObstacle
		else false

		face_right = @faceRight

		obstacle_distance = 999999
		obstacle_ahead = do
			start = @position
			stop = Vec2 start.x+(@faceRight and 140 or -140),start.y
			Store.world\raycast start,stop,false,(b,p)->
				if b.group == Data.groupTerrain and b.tag == "Obstacle"
					obstacle_distance = math.abs p.x-start.x
					true
				else false

		has_forward_speed = math.abs(@velocityX) > 0

		see_enemy = AI\getNearestUnit(Relation.Enemy)?

		evade_right = nil

		need_evade = do
			return false if not @getAction "rangeAttack" or not @onSurface
			evadeLeftEnemy = false
			evadeRightEnemy = false
			sensor = @getSensorByTag UnitDef.AttackSensorTag
			sensor.sensedBodies\each (body)->
				if Relation.Enemy == Data\getRelation @,body
					distance = math.abs @x - body.x
					if distance < 80
						evadeRightEnemy = false
						evadeLeftEnemy = false
						return true
					elseif distance < 200
						evadeRightEnemy = true if body.x > @x
						evadeLeftEnemy = true if body.x <= @x
			needEvade = not (evadeLeftEnemy == evadeRightEnemy) and math.abs(@x) < 1000
			evade_right = evadeRightEnemy if needEvade
			needEvade

		face_enemy = evade_right? and not @isDoing("backJump") and evade_right == @faceRight

		last_action = lastAction

		last_action_interval = (App.frame - lastActionFrame) / 60

		not_facing_nearest_enemy = do
			enemy = AI\getNearestUnit Relation.Enemy
			if enemy?
				(@x > enemy.x) == @faceRight

		enemy_in_attack_range = do
			enemy = AI\getNearestUnit Relation.Enemy
			attackUnits = AI\getUnitsInAttackRange!
			attackUnits and attackUnits\contains(enemy) or false

		reach_search_limit = math.abs(@x) > 1150 and (@x > 0 == @faceRight)

		row = {:attack_path_blocked,:face_right,:obstacle_ahead,:obstacle_distance,:has_forward_speed,:see_enemy,:evade_right,:need_evade,:face_enemy,:last_action,:last_action_interval,:not_facing_nearest_enemy,:enemy_in_attack_range,:reach_search_limit,action:name}

		lastAction = name
		lastActionFrame = App.frame
		true
	Do name
	Con "Save data",=>
		switch name
			when "fallOff","cancel"
				return true
		return true if @decisionTree ~= "AI_KidSearch"
		table.insert data,row
		true
}

rowNames = {'attack_path_blocked','face_right','obstacle_ahead','obstacle_distance','has_forward_speed','see_enemy','evade_right','need_evade','face_enemy','last_action','last_action_interval','not_facing_nearest_enemy','enemy_in_attack_range','reach_search_limit','action'}

rowTypes = {'C','C','C','N','C','C','C','C','C','C','N','C','C','C','C'}

Director.entry\addChild with Node!
	\slot "Cleanup",->
		csvData = for row in *data
			rd = for name in *rowNames
				val = if row[name]? then row[name] else "N"
				if "boolean" == type val
					val = if val then "T" else "F"
				tostring val
			table.concat rd,","
		names = table.concat([string.upper n for n in *rowNames],",").."\n"
		data = names..table.concat(rowTypes,",").."\n"..table.concat(csvData,"\n")
		Content\save Path(Content.writablePath,"zombie.csv"),data
		print "#{#csvData} records saved!"
		thread ->
			lines = {}
			accuracy = ML\buildDecisionTreeAsync data,0,(depth,name,op,value)->
				line = string.rep("\t",depth) .. if name ~= "" then
					"if #{name} #{op} #{op=='==' and "\"#{value}\"" or value}"
				else
					"#{op} \"#{value}\""
				lines[#lines+1] = line
			print table.concat lines,"\n"
			print "accuracy: #{accuracy}"

rangeAttack = Sel {
	Seq {
		Con "attack path blocked", =>
			sensor = @getSensorByTag UnitDef.AttackSensorTag
			if sensor.sensedBodies\each (body)->
					body.group == Data.groupTerrain and
					(@x > body.x) ~= @faceRight and
					body.tag == "Obstacle"
				faceObstacle = true
				start = @position
				stop = Vec2 start.x+(@faceRight and 1 or -1)*@unitDef.attackRange.width,start.y
				Store.world\raycast start,stop,true,(b)->
					return false if b.group == Data.groupDetection
					faceObstacle = false if Relation.Enemy == Data\getRelation @,b
					true
				faceObstacle
			else false
		Act "jump"
		Reject!
	}
	Act "rangeAttack"
}

walk = Sel {
	Seq {
		Con "obstacles ahead",=>
			start = @position
			stop = Vec2 start.x+(@faceRight and 140 or -140),start.y
			Store.world\raycast start,stop,false,(b,p)->
				if b.group == Data.groupTerrain and b.tag == "Obstacle"
					@entity.obstacleDistance = math.abs p.x-start.x
					true
				else false
		Sel {
			Seq {
				Con "obstacle distance <= 80",=> @entity.obstacleDistance <= 80
				Act "backJump"
			}
			Seq {
				Con "has forward speed",=> math.abs(@velocityX) > 0
				Act "jump"
			}
		}
	}
	Act "walk"
}

fightDecision = Seq {
	Con "see enemy",=> AI\getNearestUnit(Relation.Enemy)?
	Sel {
		Seq {
			Con "need evade",=>
				return false if not @getAction "rangeAttack" or not @onSurface
				evadeLeftEnemy = false
				evadeRightEnemy = false
				sensor = @getSensorByTag UnitDef.AttackSensorTag
				sensor.sensedBodies\each (body)->
					if Relation.Enemy == Data\getRelation @,body
						distance = math.abs @x - body.x
						if distance < 80
							evadeRightEnemy = false
							evadeLeftEnemy = false
							return true
						elseif distance < 200
							evadeRightEnemy = true if body.x > @x
							evadeLeftEnemy = true if body.x <= @x
				needEvade = not (evadeLeftEnemy == evadeRightEnemy) and math.abs(@x) < 1000
				@entity.evadeRight = evadeRightEnemy if needEvade
				needEvade
			Sel {
				Seq {
					Con "face enemy",=>
						not @isDoing("backJump") and @entity.evadeRight == @faceRight
					Act "turn"
					walk
				}
				walk
			}
		}
		Seq {
			Con "not facing nearest enemy",=>
				enemy = AI\getNearestUnit Relation.Enemy
				(@x > enemy.x) == @faceRight
			Act "turn"
		}
		Seq {
			Con "enemy in attack range",=>
				enemy = AI\getNearestUnit Relation.Enemy
				attackUnits = AI\getUnitsInAttackRange!
				attackUnits and attackUnits\contains(enemy) or false
			Sel {
				rangeAttack
				Act "meleeAttack"
			}
		}
		Seq {
			Con "wanna jump", => App.rand % 5 == 0
			Act "jump"
		}
		walk
	}
}

Store["AI_Zombie"] = Sel {
	Seq {
		Con "is dead",=> @entity.hp <= 0
		Pass!
	}
	Seq {
		Con "not entered",=> not @entity.entered
		Act "groundEntrance"
	}
	fightDecision
	Seq {
		Con "need stop",=> not @isDoing "idle"
		Act "cancel"
		Act "idle"
	}
}

playerGroup = Group {"player"}

Store["AI_KidFollow"] = Sel {
	Seq {
		Con "is dead",=> @entity.hp <= 0
		Pass!
	}
	fightDecision
	Seq {
		Con "is falling",=> not @onSurface
		Act "fallOff"
	}
	Seq {
		Con "follow target is away",=>
			target = nil
			playerGroup\each (e)-> target = e.unit if e.unit ~= @
			@entity.followTarget = target
			target? and math.abs(@x-target.x) > 50
		Sel {
			Seq {
				Con "not facing target",=> (@x > @entity.followTarget.x) == @faceRight
				Act "turn"
			}
			Pass!
		}
		walk
	}
	Seq {
		Con "need stop",=> not @isDoing "idle"
		Act "cancel"
		Act "idle"
	}
}

Store["AI_KidSearch"] = Sel {
	Seq {
		Con "is dead",=> @entity.hp <= 0
		Pass!
	}
	fightDecision
	Seq {
		Con "is falling",=> not @onSurface
		Act "fallOff"
	}
	Seq {
		Con "reach search limit",=> math.abs(@x) > 1150 and (@x > 0 == @faceRight)
		Act "turn"
	}
	Seq {
		Con "continue search",-> true
		walk
	}
}

Store["AI_PlayerControl"] = Sel {
	Seq {
		Con "is dead",=> @entity.hp <= 0
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
		Con "attack key down",=> @entity.keyShoot
		Sel {
			Act "meleeAttack"
			Act "rangeAttack"
		}
	}
	Sel {
		Seq {
			Con "is falling",=> not @onSurface
			Act "fallOff"
		}
		Seq {
			Con "jump key down",=> @entity.keyUp
			Act "jump"
		}
	}
	Seq {
		Con "move key down",=> @entity.keyLeft or @entity.keyRight
		Act "walk"
	}
	Seq {
		Con "need stop",=> not @isDoing "idle"
		Act "cancel"
		Act "idle"
	}
}
