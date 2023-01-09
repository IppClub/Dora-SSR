local type Unit = require("Platformer.UnitType")
local record UnitAction
	userdata
	reaction: number
	recovery: number
	const name: string
	const doing: boolean
	const eclapsedTime: number
	const owner: Unit
end
return UnitAction