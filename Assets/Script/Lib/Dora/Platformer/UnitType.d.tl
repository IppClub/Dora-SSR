local Body = require("Body").Type
local Playable = require("Playable").Type
local Sensor = require("Sensor").Type
local Dictionary = require("Dictionary").Type
local Entity = require("Entity").Type
local Size = require("Size").Type
local type UnitAction = require("Platformer.UnitActionType")
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
return Unit
