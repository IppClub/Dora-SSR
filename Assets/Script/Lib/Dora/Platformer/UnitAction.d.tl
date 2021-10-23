local Unit = require("Platformer.Unit").Type
local UnitActionBase = require("Platformer.UnitActionBase")
local Routine = require("Routine")
local record UnitAction
	embed UnitActionBase
	reaction: number
	recovery: number
	const name: string
	const doing: boolean
	const eclapsedTime: number
	const owner: Unit
end
local record UnitActionClass
	type Type = UnitAction
	add: function(
		cls: UnitActionClass,
		name: string,
		priority: integer,
		reaction: number,
		recovery: number,
		queued: boolean,
		available: function(owner: Unit, action: UnitAction): (boolean),
		create: function(owner: Unit, action: UnitAction): (
			function(owner: Unit, action: UnitAction, deltaTime: number): (boolean)
			| Routine.Job
		),
		stop?: function(owner: Unit) --[[nil]]
	)
	clear: function(cls: UnitActionClass)
end
print(UnitAction.owner)
local unitActionClass: UnitActionClass
return unitActionClass
