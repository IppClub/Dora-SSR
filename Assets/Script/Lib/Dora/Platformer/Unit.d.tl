local Dictionary = require("Dictionary").Type
local Entity = require("Entity").Type
local PhysicsWorld = require("PhysicsWorld").Type
local Vec2 = require("Vec2").Type
local type Unit = require("Platformer.UnitType")
local record UnitClass
	type Type = Unit
	const GroundSensorTag: integer
	const DetectSensorTag: integer
	const AttackSensorTag: integer
	metamethod __call: function(
		cls: UnitClass,
		unitDef: Dictionary,
		physicsworld: PhysicsWorld,
		entity: Entity,
		pos: Vec2,
		rot?: number --[[0.0]]
	): Unit
end
print(Unit.playable)
print(Unit.attackRange)
print(Unit.groundSensor)
print(Unit.detectSensor)
print(Unit.attackSensor)
print(Unit.unitDef)
print(Unit.currentAction)
print(Unit.entity)
print(Unit:attachAction(nil))
print(Unit:getAction(nil))
print(UnitClass.Type)
local unitClass: UnitClass
return unitClass
