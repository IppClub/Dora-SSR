local Object = require("Object").Type
local record ActionDef end

-- Represents an action that can be run on a node.
local record Action

	-- Inherited fields from Object
	embed Object

	-- The duration of the action.
	const duration: number

	-- Whether the action is currently running.
	const running: boolean

	-- Whether the action is currently paused.
	const paused: boolean

	-- Whether the action should be run in reverse.
	reversed: boolean

	-- The speed at which the action should be run.
	-- Set to 1.0 to get normal speed, Set to 2.0 to get two times faster.
	speed: number

	-- Pauses the action.
	pause: function(self: Action)

	-- Resumes the action.
	resume: function(self: Action)

	-- Updates the state of the Action.
	-- @param elapsed (number) The amount of time in seconds that has elapsed to update action to.
	-- @param reversed (boolean) Whether or not to update the Action in reverse (default is false).
	updateTo: function(
		self: Action,
		elapsed: number,
		reversed?: boolean --[[false]]
	)
end

-- A class for creating an action that can be run on a Node.
local record ActionClass
	type Type = Action
	type Def = ActionDef

	-- Creates a new Action from the given definition.
	-- @param actionDef (ActionDef) The definition of the Action.
	-- @return (Action) The new Action object.
	metamethod __call: function(self: ActionClass, actionDef: ActionDef): Action
end

local actionClass: ActionClass
return actionClass
