local type Keyboard = require("Keyboard")
local type Controller = require("Controller")
local type Node = require("Node")

local type KeyName = Keyboard.KeyName;
local type ButtonName = Controller.ButtonName;
local type AxisName = Controller.AxisName;

-- `InputManager` is a class for managing input contexts and actions. Input events can be listened for and handled by creating input contexts and actions, and then adding them to the input manager. Specific combinations of input contexts can be activated and deactivated by calling the `pushContext` and `popContext` methods. When an event is triggered, input events can be handled by registering global input event listeners.
-- @usage
-- local InputManager = require("InputManager")
-- local inputManager = InputManager.CreateManager({
-- 	context1 = {
-- 		action1 = Trigger.KeyDown("W"),
-- 	},
-- })
-- -- activate context1
-- inputManager:pushContext("context1")
-- -- add prefix "Input." to the listened action name
-- node:gslot("Input.action1", function()
-- 	print("action1 triggered")
-- end)
-- -- remove context1 from the context stack
-- inputManager:popContext()
-- inputManager:destroy()
local record InputManager

	-- Gets the current input node. The input node is used to receive input events. It will be added to `Director.entry` automatically.
	-- @return (Node) The input node.
	getNode: function(self: InputManager): Node.Type

	-- Adds an input context to the context stack. Temporarily disables the previous context, then activates the actions in the new context.
	-- @param contextNames (string | {string}) The name of the context or a list of context names.
	-- @return (boolean) Whether the context is successfully pushed.
	pushContext: function(self: InputManager, contextNames: string | {string}): boolean

	-- Removes the current input context from the context stack. Activates the previous context.
	-- @param count (number) [optional] The number of contexts to be popped. Default is 1.
	-- @return (boolean) Whether the context is successfully popped.
	popContext: function(self: InputManager, count?: number): boolean

	-- Emits a key down event for input simulation.
	-- @param keyName (KeyName) The name of the key.
	emitKeyDown: function(self: InputManager, keyName: KeyName)

	-- Emits a key up event for input simulation.
	-- @param keyName (KeyName) The name of the key.
	emitKeyUp: function(self: InputManager, keyName: KeyName)

	-- Emits a button down event for input simulation.
	-- @param buttonName (ButtonName) The name of the button.
	-- @param controllerId (number) [optional] The ID of the gamepad controller. Default is 0.
	emitButtonDown: function(self: InputManager, buttonName: ButtonName, controllerId?: number)

	-- Emits a button up event for input simulation.
	-- @param buttonName (ButtonName) The name of the button.
	-- @param controllerId (number) [optional] The ID of the gamepad controller. Default is 0.
	emitButtonUp: function(self: InputManager, buttonName: ButtonName, controllerId?: number)

	-- Emits an axis event for input simulation.
	-- @param axisName (AxisName) The name of the axis.
	-- @param value (number) The value of the axis, ranging from -1 to 1.
	-- @param controllerId (number) [optional] The ID of the gamepad controller. Default is 0.
	emitAxis: function(self: InputManager, axisName: AxisName, value: number, controllerId?: number)

	-- Destroys the input manager and clears input event listeners.
	destroy: function(self: InputManager)
end

-- The input manager class.
local record InputManagerClass

	-- The enumeration defining the joystick types.
	enum JoyStickType
		"Left"
		"Right"
	end

	-- `Trigger` is a record that defines various input triggers for keyboard keys, gamepad buttons, and joysticks.
	record Trigger

		-- Create a trigger that triggers when all of the specified keys are pressed down.
		-- @param combineKeys (KeyName | {KeyName}) The key or combined keys to be checked.
		-- @return (Trigger) The trigger object.
		KeyDown: function(combineKeys: KeyName | {KeyName}): Trigger

		-- Create a trigger that triggers when all of the specified keys are pressed down and then any of them is released.
		-- @param combineKeys (KeyName | {KeyName}) The key or combined keys to be checked.
		-- @return (Trigger) The trigger object.
		KeyUp: function(combineKeys: KeyName | {KeyName}): Trigger

		-- Create a trigger that triggers when all of the specified keys are being pressed.
		-- @param combineKeys (KeyName | {KeyName}) The key or combined keys to be checked.
		-- @return (Trigger) The trigger object.
		KeyPressed: function(combineKeys: KeyName | {KeyName}): Trigger

		-- Create a trigger that triggers when a specific key is held down for a specified duration.
		-- @param keyName (KeyName) The key to be checked.
		-- @param holdTime (number) The duration in seconds.
		-- @return (Trigger) The trigger object.
		KeyHold: function(keyName: KeyName, holdTime: number): Trigger

		-- Create a trigger that triggers when a specific key is pressed within a specified time window.
		-- @param keyName (KeyName) The key to be checked.
		-- @param timeWindow (number) The time window in seconds.
		-- @return (Trigger) The trigger object.
		KeyTimed: function(keyName: KeyName, timeWindow: number): Trigger

		-- Create a trigger that triggers when a specific key is double-pressed within a specified time window.
		-- @param key (KeyName) The key to be checked.
		-- @param threshold (number) [optional] The time window in seconds. Default is 0.3.
		-- @return (Trigger) The trigger object.
		KeyDoubleDown: function(key: KeyName, threshold?: number): Trigger

		-- Create a trigger that triggers when any key is being pressed down.
		-- @return (Trigger) The trigger object.
		AnyKeyPressed: function(): Trigger

		-- Create a trigger that triggers when all of the specified gamepad buttons are pressed down.
		-- @param combineButtons (ButtonName | {ButtonName}) The gamepad button or combined buttons to be checked.
		-- @param controllerId (number) [optional] The ID of the gamepad controller. Default is 0.
		-- @return (Trigger) The trigger object.
		ButtonDown: function(combineButtons: ButtonName | {ButtonName}, controllerId?: number): Trigger

		-- Create a trigger that triggers when all of the specified gamepad buttons are pressed down and then any of them is released.
		-- @param combineButtons (ButtonName | {ButtonName}) The gamepad button or combined buttons to be checked.
		-- @param controllerId (number) [optional] The ID of the gamepad controller. Default is 0.
		-- @return (Trigger) The trigger object.
		ButtonUp: function(combineButtons: ButtonName | {ButtonName}, controllerId?: number): Trigger

		-- Create a trigger that triggers when all of the specified gamepad buttons are being pressed.
		-- @param combineButtons (ButtonName | {ButtonName}) The gamepad button or combined buttons to be checked.
		-- @param controllerId (number) [optional] The ID of the gamepad controller. Default is 0.
		-- @return (Trigger) The trigger object.
		ButtonPressed: function(combineButtons: ButtonName | {ButtonName}, controllerId?: number): Trigger

		-- Create a trigger that triggers when a specific gamepad button is held down for a specified duration.
		-- @param buttonName (ButtonName) The gamepad button to be checked.
		-- @param holdTime (number) The duration in seconds.
		-- @param controllerId (number) [optional] The ID of the gamepad controller. Default is 0.
		-- @return (Trigger) The trigger object.
		ButtonHold: function(buttonName: ButtonName, holdTime: number, controllerId?: number): Trigger

		-- Create a trigger that triggers when a specific gamepad button is pressed within a specified time window.
		-- @param buttonName (ButtonName) The gamepad button to be checked.
		-- @param timeWindow (number) The time window in seconds.
		-- @param controllerId (number) [optional] The ID of the gamepad controller. Default is 0.
		-- @return (Trigger) The trigger object.
		ButtonTimed: function(buttonName: ButtonName, timeWindow: number, controllerId?: number): Trigger

		-- Create a trigger that triggers when a specific gamepad button is double-pressed within a specified time window.
		-- @param button (ButtonName) The gamepad button to be checked.
		-- @param threshold (number) [optional] The time window in seconds. Default is 0.3.
		-- @param controllerId (number) [optional] The ID of the gamepad controller. Default is 0.
		ButtonDoubleDown: function(button: ButtonName, threshold?: number, controllerId?: number): Trigger

		-- Create a trigger that triggers when any gamepad button is being pressed down.
		-- @param controllerId (number) [optional] The ID of the gamepad controller. Default is 0.
		-- @return (Trigger) The trigger object.
		AnyButtonPressed: function(controllerId?: number): Trigger

		-- Create a trigger that triggers based on joystick movement.
		-- @param joyStickType (JoyStickType) The type of joystick to be checked.
		-- @param controllerId (number) [optional] The ID of the gamepad controller. Default is 0.
		-- @return (Trigger) The trigger object.
		JoyStick: function(joyStickType: JoyStickType, controllerId?: number): Trigger

		-- Create a trigger that triggers when a joystick moves beyond a specified threshold.
		-- @param joyStickType (JoyStickType) The type of joystick to be checked.
		-- @param threshold (number) The threshold value, ranging from 0 to 1.
		-- @param controllerId (number) [optional] The ID of the gamepad controller. Default is 0.
		-- @return (Trigger) The trigger object.
		JoyStickThreshold: function(joyStickType: JoyStickType, threshold: number, controllerId?: number): Trigger

		-- Create a trigger that triggers when a joystick is moved in a specific direction within a tolerance angle.
		-- @param joyStickType (JoyStickType) The type of joystick to be checked.
		-- @param angle (number) The angle of the direction in degrees.
		-- @param tolerance (number) The tolerance angle in degrees.
		-- @param controllerId (number) [optional] The ID of the gamepad controller. Default is 0.
		-- @return (Trigger) The trigger object.
		JoyStickDirectional: function(joyStickType: JoyStickType, angle: number, tolerance: number, controllerId?: number): Trigger

		-- Create a trigger that triggers when a joystick is within a specified range.
		-- @param joyStickType (JoyStickType) The type of joystick to be checked.
		-- @param minRange (number) The minimum range value, ranging from 0 to 1.
		-- @param maxRange (number) The maximum range value, ranging from 0 to 1.
		-- @param controllerId (number) [optional] The ID of the gamepad controller. Default is 0.
		-- @return (Trigger) The trigger object.
		JoyStickRange: function(joyStickType: JoyStickType, minRange: number, maxRange: number, controllerId?: number): Trigger

		-- Create a trigger that triggers when a sequence of other triggers are completed at the same time.
		-- @param triggers ({Trigger}) The triggers to be checked.
		-- @return (Trigger) The trigger object.
		Sequence: function(triggers: {Trigger}): Trigger

		-- Create a trigger that triggers when any of the specified triggers is completed.
		-- @param triggers ({Trigger}) The triggers to be checked.
		-- @return (Trigger) The trigger object.
		Selector: function(triggers: {Trigger}): Trigger

		-- Create a trigger when a sub-trigger is in completed state, it will report canceled state instead for blocking.
		-- @param trigger (Trigger) The trigger to be blocked.
		-- @return (Trigger) The trigger object.
		Block: function(trigger: Trigger): Trigger
	end

	-- The trigger state enumeration.
	enum TriggerState

		-- Currently no input state has been acquired.
		"None"

		-- An event that initiates the evaluation of the trigger has occurred. For example, the first press in a "hold" trigger will call the "Started" state once.
		"Started"

		-- The trigger is still being processed. For example, when a button is pressed, before reaching the specified duration, the "hold" action is in an ongoing state. Depending on the trigger, this event will trigger every time it updates during the evaluation of the action after receiving an input value.
		"Ongoing"

		-- The evaluation process of the trigger has been completed.
		"Completed"

		-- The trigger has been canceled. For example, the user releases the button before the "hold" action is triggered.
		"Canceled"
	end

	-- Creates an input manager with the specified input contexts.
	-- @param contexts ({string: {string: Trigger}}) The input contexts to be created.
	-- @return (InputManager) The input manager.
	CreateManager: function(contexts: {--[[contextName]] string: {--[[actionName]] string: Trigger}}): InputManager

	-- The virtual directional pad (D-pad) properties.
	record DPadProps

		-- The button width of the D-pad. [optional]
		width: number

		-- The button height of the D-pad. [optional]
		height: number

		-- The button padding of the D-pad. [optional]
		offset: number

		-- The input manager for the D-pad. [required]
		inputManager: InputManager
	end

	-- Creates a virtual directional pad (D-pad) for input.
	-- @param props (DPadProps) The properties of the D-pad.
	-- @return (Node) The D-pad node.
	CreateDPad: function(props: DPadProps): Node.Type

	-- The virtual joystick properties.
	record JoyStickProps

		-- The type of joystick. [required]
		stickType: JoyStickType

		-- The size of the joystick. [optional]
		moveSize: number

		-- The size of the hat. [optional]
		hatSize: number

		-- The font name of the joystick. [optional]
		fontName: string

		-- The stick button size of the joystick. [optional]
		buttonSize: number

		-- The input manager for the joystick. [required]
		inputManager: InputManager

		-- The color of the joystick. [optional]
		color: number

		-- The primary opacity of the joystick. [optional]
		primaryOpacity: number

		-- The secondary opacity of the joystick. [optional]
		secondaryOpacity: number

		-- Whether to hide the stick button. [optional]
		noStickButton: boolean
	end

	-- Creates a virtual joystick (L, LS or R, RS) for input.
	-- @param props (JoyStickProps) The properties of the joystick.
	-- @return (Node) The joystick node.
	CreateJoyStick: function(props: JoyStickProps): Node.Type

	-- The virtual button pad properties.
	record ButtonPadProps

		-- The size of the button. [optional]
		buttonSize: number

		-- The padding of the buttons. [optional]
		buttonPadding: number

		-- The font name of the button pad. [optional]
		fontName: string

		-- The input manager for the button pad. [required]
		inputManager: InputManager
	end

	-- Creates a virtual button pad (A, B, X, Y) for input.
	-- @param props (ButtonPadProps) The properties of the button pad.
	-- @return (Node) The button pad node.
	CreateButtonPad: function(props: ButtonPadProps): Node.Type

	-- The virtual control pad properties.
	record ControlPadProps

		-- The size of the button. [optional]
		buttonSize: number

		-- The font name of the control pad. [optional]
		fontName: string

		-- The input manager for the control pad. [required]
		inputManager: InputManager

		-- The color of the control pad. [optional]
		color: number

		-- The primary opacity of the control pad. [optional]
		primaryOpacity: number
	end

	-- Creates a virtual control pad (Start and Back buttons) for input.
	-- @param props (ControlPadProps) The properties of the control pad.
	-- @return (Node) The control pad node.
	CreateControlPad: function(props: ControlPadProps): Node.Type

	-- The virtual trigger pad properties.
	record TriggerPadProps

		-- The size of the button. [optional]
		buttonSize: number

		-- The padding of the buttons. [optional]
		fontName: string

		-- The input manager for the trigger pad. [required]
		inputManager: InputManager

		-- The color of the trigger pad. [optional]
		color: number

		-- The primary opacity of the trigger pad. [optional]
		primaryOpacity: number

		-- Whether to hide the shoulder buttons (LB, RB). [optional]
		noShoulder: boolean
	end

	-- Creates a virtual trigger pad (LB, LT, RB, RT) for input.
	-- @param props (TriggerPadProps) The properties of the trigger pad.
	-- @return (Node) The trigger pad node.
	CreateTriggerPad: function(props: TriggerPadProps): Node.Type

	-- The virtual gamepad properties.
	record GamePadProps

		-- Whether to hide the directional pad (D-pad). [optional]
		noDPad: boolean

		-- Whether to hide the left stick (L, LS). [optional]
		noLeftStick: boolean

		-- Whether to hide the right stick (R, RS). [optional]
		noRightStick: boolean

		-- Whether to hide the button pad (A, B, X, Y). [optional]
		noButtonPad: boolean

		-- Whether to hide the trigger pad (LB, LT, RB, RT). [optional]
		noTriggerPad: boolean

		-- Whether to hide the control pad (Start and Back buttons). [optional]
		noControlPad: boolean

		-- Whether to hide the shoulder buttons (LB, RB). [optional]
		noShoulder: boolean

		-- Whether to hide the trigger buttons (LS, RS). [optional]
		noStickButton: boolean

		-- The color of the gamepad. [optional]
		color: number

		-- The primary opacity of the gamepad. [optional]
		primaryOpacity: number

		-- The secondary opacity of the gamepad. [optional]
		secondaryOpacity: number

		-- The input manager for the gamepad. [required]
		inputManager: InputManager
	end

	-- Creates a virtual gamepad for input.
	-- @param props (GamePadProps) The properties of the gamepad.
	-- @return (Node) The gamepad node.
	CreateGamePad: function(props: GamePadProps): Node.Type
end

local inputManagerClass: InputManagerClass
return inputManagerClass
