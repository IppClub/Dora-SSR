local Body = require("Body").Type
local Playable = require("Playable").Type
local Sensor = require("Sensor").Type
local Dictionary = require("Dictionary").Type
local Entity = require("Entity").Type
local Size = require("Size").Type
local type UnitAction = require("Platformer.UnitActionType")

-- A class represents a character or other interactive item in a game scene.
local record Unit

	-- Inherits from `Body`.
	embed Body

	-- A property that references a "Playable" object for managing the animation state and playback of the "Unit".
	playable: Playable

	-- A property that specifies the maximum distance at which the "Unit" can detect other "Unit" or objects.
	detectDistance: number

	-- A property that specifies the size of the attack range for the "Unit".
	attackRange: Size

	-- A boolean property that specifies whether the "Unit" is facing right or not.
	faceRight: boolean

	-- A boolean property that specifies whether the "Unit" is receiving a trace of the decision tree for debugging purposes.
	receivingDecisionTrace: boolean

	-- A string property that specifies the decision tree to use for the "Unit's" AI behavior.
	-- The decision tree object will be searched in The singleton instance Data.store.
	decisionTree: string

	-- Whether the "Unit" is currently on a surface or not.
	const onSurface: boolean

	-- A "Sensor" object for detecting ground surfaces.
	const groundSensor: Sensor

	-- A "Sensor" object for detecting other "Unit" objects or physics bodies in the game world.
	const detectSensor: Sensor

	-- A "Sensor" object for detecting other "Unit" objects within the attack senser area.
	const attackSensor: Sensor

	-- A "Dictionary" object for defining the properties and behavior of the "Unit".
	const unitDef: Dictionary

	-- A property that specifies the current action being performed by the "Unit".
	const currentAction: UnitAction

	-- The width of the "Unit".
	const width: number

	-- The height of the "Unit".
	const height: number

	-- An "Entity" object for representing the "Unit" in the ECS system.
	const entity: Entity

	-- Adds a new "UnitAction" to the "Unit" with the specified name, and returns the new "UnitAction".
	-- @param name (string) The name of the new "UnitAction".
	-- @return (UnitAction) The newly created "UnitAction".
	attachAction: function(self: Unit, name: string): UnitAction

	-- Removes the "UnitAction" with the specified name from the "Unit".
	-- @param name (string) The name of the "UnitAction" to remove.
	removeAction: function(self: Unit, name: string)

	-- Removes all "UnitAction" objects from the "Unit".
	removeAllActions: function(self: Unit)

	-- Returns the "UnitAction" with the specified name, or nil if the "UnitAction" does not exist.
	-- @param name (string) The name of the "UnitAction" to retrieve.
	-- @return (UnitAction or nil) The "UnitAction" with the specified name, or nil.
	getAction: function(self: Unit, name: string): UnitAction

	-- Calls the specified function for each "UnitAction" attached to the "Unit".
	-- @param func (function) A function to call for each "UnitAction".
	eachAction: function(self: Unit, func: function(UnitAction))

	-- Starts the "UnitAction" with the specified name, and returns true if the "UnitAction" was started successfully.
	-- @param name (string) The name of the "UnitAction" to start.
	-- @return (boolean) True if the "UnitAction" was started successfully, false otherwise.
	start: function(self: Unit, name: string): boolean

	-- Stops the currently running "UnitAction".
	stop: function(self: Unit)

	-- Returns true if the "Unit" is currently performing the specified "UnitAction", false otherwise.
	-- @param name (string) The name of the "UnitAction" to check.
	-- @return (boolean) True if the "Unit" is currently performing the specified "UnitAction", false otherwise.
	isDoing: function(self: Unit, name: string): boolean
end

return Unit
