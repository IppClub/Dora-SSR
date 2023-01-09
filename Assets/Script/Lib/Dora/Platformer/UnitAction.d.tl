local Routine = require("Routine")
local type UnitAction = require("Platformer.UnitActionType")
local type Unit = require("Platformer.UnitType")
local record UnitActionParam
	priority: integer
	reaction: number
	recovery: number
	queued: boolean
	available: function(owner: Unit, action: UnitAction): boolean
	create: function(owner: Unit, action: UnitAction): (
		function(owner: Unit, action: UnitAction, deltaTime: number): (boolean)
		| Routine.Job
	)
	stop: function(owner: Unit) --[[nil]]
end
local record UnitActionClass
	type Type = UnitAction
	add: function(
		cls: UnitActionClass,
		name: string,
		param: UnitActionParam
	)
	clear: function(cls: UnitActionClass)
end
print(UnitAction.owner)
local unitActionClass: UnitActionClass
return unitActionClass
