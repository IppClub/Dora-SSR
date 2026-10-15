local Routine = require("Routine")
local type UnitAction = require("Platformer.UnitActionType")
local type Unit = require("Platformer.UnitType")

-- A record that defines the parameters for a "UnitAction".
local record UnitActionParam

	-- The priority level for the "UnitAction".
	-- `UnitAction` with higher priority (larger number) will replace the running lower priority `UnitAction`.
	-- If performing `UnitAction` having the same priority with the running `UnitAction` and the `UnitAction` to perform having the param 'queued' to be true, the running `UnitAction` won't be replaced.
	priority: integer

	-- The length of the reaction time for the "UnitAction", in seconds.
	-- The reaction time will affect the AI check cycling time.
	-- Set to 0.0 to make AI check run in every update.
	reaction: number

	-- The length of the recovery time for the "UnitAction", in seconds.
	-- The recovery time will mainly affect how long the `Playable` animation model will do transitions between animations played by different actions.
	recovery: number

	-- Whether the "UnitAction" is currently queued or not. The queued "UnitAction" won't replace the running "UnitAction" with a same priority. [optional]
	queued: boolean

	-- A function that determines whether the "UnitAction" is currently available for the specified "Unit". [optional]
	-- @param owner (Unit) The "Unit" that owns the "UnitAction".
	-- @param action (UnitAction) The "UnitAction" to check availability for.
	-- @return (boolean) True if the "UnitAction" is available for the "Unit", false otherwise.
	available: function(owner: Unit, action: UnitAction): boolean

	-- A function that creates a new function or "Routine.Job" that represents the processing of the "UnitAction".
	-- @param owner (Unit) The "Unit" that will own the "UnitAction".
	-- @param action (UnitAction) The "UnitAction" to create the processing function or "Routine.Job" for.
	-- @return (function or Routine.Job) A function or a "Routine.Job" that returns or yields true if the "UnitAction" is complete.
	create: function(owner: Unit, action: UnitAction): (
		function(owner: Unit, action: UnitAction, deltaTime: number): (boolean)
		| Routine.Job
	)

	-- A function that gets invoked when the specified "Unit" stops performing the "UnitAction". [optional]
	-- @param owner (Unit) The "Unit" is stoping the "UnitAction".
	stop: function(owner: Unit)
end

-- A record that defines and stores the behavior and properties of the "UnitAction" class.
-- It is a singleton object that manages all "UnitAction" objects.
local record UnitActionClass
	type Type = UnitAction

	-- Adds a new "UnitAction" to the "UnitActionClass" with the specified name and parameters.
	-- @param name (string) The name of the new "UnitAction".
	-- @param param (UnitActionParam) The parameters for the new "UnitAction".
	add: function(
		self: UnitActionClass,
		name: string,
		param: UnitActionParam
	)

	-- Removes all "UnitAction" objects from the "UnitActionClass".
	clear: function(self: UnitActionClass)
end

local unitActionClass: UnitActionClass
return unitActionClass
