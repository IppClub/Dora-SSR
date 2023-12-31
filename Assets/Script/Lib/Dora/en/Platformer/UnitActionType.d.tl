local type Unit = require("Platformer.UnitType")

-- A record that represents an action that can be performed by a "Unit".
local record UnitAction
	userdata

	-- The length of the reaction time for the "UnitAction", in seconds.
	-- The reaction time will affect the AI check cycling time.
	reaction: number

	-- The length of the recovery time for the "UnitAction", in seconds.
	-- The recovery time will mainly affect how long the `Playable` animation model will do transitions between animations played by different actions.
	recovery: number

	-- The name of the "UnitAction".
	const name: string

	-- Whether the "Unit" is currently performing the "UnitAction" or not.
	const doing: boolean

	-- The elapsed time since the "UnitAction" was started, in seconds.
	const elapsedTime: number

	-- The "Unit" that owns this "UnitAction".
	const owner: Unit
end

return UnitAction
