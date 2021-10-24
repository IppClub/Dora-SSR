local ActionDef = require("ActionDefBase")
local Object = require("Object").Type
local record Action
	embed Object
	const duration: number
	const running: boolean
	const paused: boolean
	reversed: boolean
	speed: number
	pause: function(self: Action)
	resume: function(self: Action)
	updateTo: function(
		self: Action,
		eclapsed: number,
		reversed?: boolean --[[false]]
	)
end
local record ActionClass
	type Type = Action
	metamethod __call: function(cls: ActionClass, actionDef: ActionDef): Action
end
local actionClass: ActionClass
return actionClass
