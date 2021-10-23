local Body = require("Body").Type
local Playable = require("Playable").Type
local Sensor = require("Sensor").Type
local Dictionary = require("Dictionary").Type
local Entity = require("Entity").Type
local UnitAction = require("Platformer.UnitActionBase")
local PhysicsWorld = require("PhysicsWorld").Type
local Vec2 = require("Vec2").Type
local Size = require("Size").Type
local record Unit
	embed Body
	playable: Playable
	detectDistance: number
	attackRange: Size
	faceRight: boolean
	receivingDecisionTrace: boolean
	decisionTree: string
	const onSurface: boolean
	const groundSensor: Sensor
	const detectSensor: Sensor
	const attackSensor: Sensor
	const unitDef: Dictionary
	const currentAction: UnitAction
	const width: number
	const height: number
	const entity: Entity
	attachAction: function(self: Unit, name: string): UnitAction
	removeAction: function(self: Unit, name: string)
	removeAllActions: function(self: Unit)
	getAction: function(self: Unit, name: string): UnitAction
	eachAction: function(self: Unit, func: function(UnitAction))
	start: function(self: Unit, name: string): boolean
	stop: function(self: Unit)
	isDoing: function(self: Unit, name: string): boolean
end
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
local unitClass: UnitClass
return unitClass
