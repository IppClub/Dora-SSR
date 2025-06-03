declare module 'InputManager' {

import { React } from 'DoraX';
import { AxisName, ButtonName, KeyName, Node } from 'Dora';

/** The enumeration defining the trigger states. */
export const enum TriggerState {
	/** Currently no input state has been acquired. */
	None = "None",
	/** An event that initiates the evaluation of the trigger has occurred. For example, the first press in a "hold" trigger will call the "Started" state once. */
	Started = "Started",
	/** The trigger is still being processed. For example, when a button is pressed, before reaching the specified duration, the "hold" action is in an ongoing state. Depending on the trigger, this event will trigger every time it updates during the evaluation of the action after receiving an input value. */
	Ongoing = "Ongoing",
	/** The evaluation process of the trigger has been completed. */
	Completed = "Completed",
	/** The trigger has been canceled. For example, the user releases the button before the "hold" action is triggered. */
	Canceled = "Canceled",
}

/** A class that defines various input triggers for keyboard keys, gamepad buttons, and joysticks. */
export abstract class Trigger {
	private constructor();
}

/** The enumeration defining the joystick types. */
export const enum JoyStickType {
	Left = "Left",
	Right = "Right",
}

/** A module for creating various input triggers for keyboard keys, gamepad buttons, and joysticks. */
export namespace Trigger {
	/**
	 * Create a trigger that triggers when all of the specified keys are pressed down.
	 * @param combineKeys The key or combined keys to be checked.
	 * @returns The trigger object.
	 */
	export function KeyDown(this: void, combineKeys: KeyName | KeyName[]): Trigger;
	/**
	 * Create a trigger that triggers when all of the specified keys are pressed down and then any of them is released.
	 * @param combineKeys The key or combined keys to be checked.
	 * @returns The trigger object.
	 */
	export function KeyUp(this: void, combineKeys: KeyName | KeyName[]): Trigger;
	/**
	 * Create a trigger that triggers when all of the specified keys are being pressed.
	 * @param combineKeys The key or combined keys to be checked.
	 * @returns The trigger object.
	 */
	export function KeyPressed(this: void, combineKeys: KeyName | KeyName[]): Trigger;
	/**
	 * Create a trigger that triggers when a specific key is held down for a specified duration.
	 * @param keyName The key to be checked.
	 * @param holdTime The duration in seconds.
	 * @returns The trigger object.
	 */
	export function KeyHold(this: void, keyName: KeyName, holdTime: number): Trigger;
	/**
	 * Create a trigger that triggers when a specific key is pressed within a specified time window.
	 * @param keyName The key to be checked.
	 * @param timeWindow The time window in seconds.
	 * @returns The trigger object.
	 */
	export function KeyTimed(this: void, keyName: KeyName, timeWindow: number): Trigger;
	/**
	 * Create a trigger that triggers when a specific key is double pressed within a specified time window.
	 * @param key The key to be checked.
	 * @param threshold The time window in seconds. Default is 0.3.
	 * @returns The trigger object.
	 */
	export function KeyDoubleDown(this: void, key: KeyName, threshold?: number): Trigger;
	/**
	 * Create a trigger that triggers when any key is being pressed down.
	 * @returns The trigger object.
	 */
	export function AnyKeyPressed(this: void): Trigger;
	/**
	 * Create a trigger that triggers when all of the specified gamepad buttons are pressed down.
	 * @param combineButtons The gamepad button or combined buttons to be checked.
	 * @param controllerId The ID of the gamepad controller. Default is 0.
	 * @returns The trigger object.
	 */
	export function ButtonDown(this: void, combineButtons: ButtonName | ButtonName[], controllerId?: number): Trigger;
	/**
	 * Create a trigger that triggers when all of the specified gamepad buttons are pressed down and then any of them is released.
	 * @param combineButtons The gamepad button or combined buttons to be checked.
	 * @param controllerId The ID of the gamepad controller. Default is 0.
	 * @returns The trigger object.
	 */
	export function ButtonUp(this: void, combineButtons: ButtonName | ButtonName[], controllerId?: number): Trigger;
	/**
	 * Create a trigger that triggers when all of the specified gamepad buttons are being pressed.
	 * @param combineButtons The gamepad button or combined buttons to be checked.
	 * @param controllerId The ID of the gamepad controller. Default is 0.
	 * @returns The trigger object.
	 */
	export function ButtonPressed(this: void, combineButtons: ButtonName | ButtonName[], controllerId?: number): Trigger;
	/**
	 * Create a trigger that triggers when a specific gamepad button is held down for a specified duration.
	 * @param buttonName The gamepad button to be checked.
	 * @param holdTime The duration in seconds.
	 * @param controllerId The ID of the gamepad controller. Default is 0.
	 * @returns The trigger object.
	 */
	export function ButtonHold(this: void, buttonName: ButtonName, holdTime: number, controllerId?: number): Trigger;
	/**
	 * Create a trigger that triggers when a specific gamepad button is pressed within a specified time window.
	 * @param buttonName The gamepad button to be checked.
	 * @param timeWindow The time window in seconds.
	 * @param controllerId The ID of the gamepad controller. Default is 0.
	 * @returns The trigger object.
	 */
	export function ButtonTimed(this: void, buttonName: ButtonName, timeWindow: number, controllerId?: number): Trigger;
	/**
	 * Create a trigger that triggers when a specific gamepad button is double pressed within a specified time window.
	 * @param button The gamepad button to be checked.
	 * @param threshold The time window in seconds. Default is 0.3.
	 * @param controllerId The ID of the gamepad controller. Default is 0.
	 * @returns The trigger object.
	 */
	export function ButtonDoubleDown(this: void, button: ButtonName, threshold?: number, controllerId?: number): Trigger;
	/**
	 * Create a trigger that triggers when any gamepad button is being pressed down.
	 * @param controllerId The ID of the gamepad controller. Default is 0.
	 * @returns The trigger object.
	 */
	export function AnyButtonPressed(this: void, controllerId?: number): Trigger;
	/**
	 * Create a trigger that triggers based on joystick movement.
	 * @param joyStickType The type of joystick to be checked.
	 * @param controllerId The ID of the gamepad controller. Default is 0.
	 * @returns The trigger object.
	 */
	export function JoyStick(this: void, joyStickType: JoyStickType, controllerId?: number): Trigger;
	/**
	 * Create a trigger that triggers when a joystick moves beyond a specified threshold.
	 * @param joyStickType The type of joystick to be checked.
	 * @param threshold The threshold value, between 0 and 1.
	 * @param controllerId The ID of the gamepad controller. Default is 0.
	 * @returns The trigger object.
	 */
	export function JoyStickThreshold(this: void, joyStickType: JoyStickType, threshold: number, controllerId?: number): Trigger;
	/**
	 * Create a trigger that triggers when a joystick is moved in a specific direction within a tolerance angle.
	 * @param joyStickType The type of joystick to be checked.
	 * @param angle The angle of the direction in degrees.
	 * @param tolerance The tolerance angle in degrees.
	 * @param controllerId The ID of the gamepad controller. Default is 0.
	 * @returns The trigger object.
	 */
	export function JoyStickDirectional(this: void, joyStickType: JoyStickType, angle: number, tolerance: number, controllerId?: number): Trigger;
	/**
	 * Create a trigger that triggers when a joystick is within a specified range.
	 * @param joyStickType The type of joystick to be checked.
	 * @param minRange The minimum range value, between 0 and 1.
	 * @param maxRange The maximum range value, between 0 and 1.
	 * @param controllerId The ID of the gamepad controller. Default is 0.
	 * @returns The trigger object.
	 */
	export function JoyStickRange(this: void, joyStickType: JoyStickType, minRange: number, maxRange: number, controllerId?: number): Trigger;
	/**
	 * Create a trigger that triggers when a sequence of other triggers are completed at the same time.
	 * @param triggers The triggers to be checked.
	 * @returns The trigger object.
	 */
	export function Sequence(this: void, triggers: Trigger[]): Trigger;
	/**
	 * Create a trigger that triggers when any of the specified triggers is completed.
	 * @param triggers The triggers to be checked.
	 * @returns The trigger object.
	 */
	export function Selector(this: void, triggers: Trigger[]): Trigger;
	/**
	 * Create a trigger when a sub-trigger is in completed state, it will report canceled state instead for blocking.
	 * @param trigger The trigger to be blocked.
	 * @returns The trigger object.
	 */
	export function Block(this: void, trigger: Trigger): Trigger;
}

/**
 * `InputManager` is a class for managing input contexts and actions. Input events can be listened for and handled by creating input contexts and actions, and then adding them to the input manager. Specific combinations of input contexts can be activated and deactivated by calling the `pushContext` and `popContext` methods. When an event is triggered, input events can be handled by registering global input event listeners.
 * @usage
 * import { CreateManager, Trigger } from "InputManager";
 * const inputManager = CreateManager([
 * 	context1: {
 * 		action1: Trigger.KeyDown(KeyName.W),
 * 	},
 * ]);
 * // activate context1
 * inputManager.pushContext("context1");
 * // add prefix "Input." to the listened action name
 * node.gslot("Input.action1", () => {
 * 	print("action1 triggered");
 * });
 * // remove context1 from the context stack
 * inputManager.popContext();
 * // destroy the input manager
 * inputManager.destroy();
 */
export class InputManager {
	private constructor(contexts: {[contextName: string]: {[actionName: string]: Trigger}});
	/**
	 * Gets the current input node. The input node is used to receive input events. It will be added to `Director.entry` automatically.
	 * @returns The input node.
	 */
	getNode(): Node.Type;
	/**
	 * Adds an input context to the context stack. Temporarily disables the previous context, then activates the actions in the new context.
	 * @param contextNames The name of the context or a list of context names.
	 * @returns Whether the context is successfully pushed.
	 * @returns The input node.
	 */
	pushContext(contextNames: string | string[]): boolean;
	/**
	 * Removes the current input context from the context stack. Activates the previous context.
	 * @param count The number of contexts to be popped. Default is 1.
	 * @returns Whether the context is successfully popped.
	 */
	popContext(count?: number): boolean;
	/**
	 * Emits a key down event for input simulation.
	 * @param keyName The name of the key.
	 */
	emitKeyDown(keyName: KeyName): void;
	/**
	 * Emits a key up event for input simulation.
	 * @param keyName The name of the key.
	 */
	emitKeyUp(keyName: KeyName): void;
	/**
	 * Emits a button down event for input simulation.
	 * @param buttonName The name of the button.
	 * @param controllerId The ID of the gamepad controller. Default is 0.
	 */
	emitButtonDown(buttonName: ButtonName, controllerId?: number): void;
	/**
	 * Emits a button up event for input simulation.
	 * @param buttonName The name of the button.
	 * @param controllerId The ID of the gamepad controller. Default is 0.
	 */
	emitButtonUp(buttonName: ButtonName, controllerId?: number): void;
	/**
	 * Emits an axis event for input simulation.
	 * @param axisName The name of the axis.
	 * @param value The value of the axis, between -1 and 1.
	 * @param controllerId The ID of the gamepad controller. Default is 0.
	 */
	emitAxis(axisName: AxisName, value: number, controllerId?: number): void;
	/**
	 * Destroys the input manager and clears input event listeners.
	 */
	destroy(): void;
}

/**
 * Creates an input manager with the specified input contexts.
 * @param contexts The input contexts to be created.
 * @returns The input manager.
 */
export function CreateManager(this: void, contexts: {[contextName: string]: {[actionName: string]: Trigger}}): InputManager;

/** The virtual directional pad (D-pad) properties. */
export interface DPadProps {
	/** The button width of the D-pad. [optional] */
	width?: number;
	/** The button height of the D-pad. [optional] */
	height?: number;
	/** The button padding of the D-pad. [optional] */
	offset?: number;
	/** The input manager for the D-pad. [required] */
	inputManager: InputManager;
}

/** A virtual directional pad (D-pad) TSX element for input. */
export function DPad(props: DPadProps): React.Element;

/**
 * Creates a virtual directional pad (D-pad) for input.
 * @param props The properties of the D-pad.
 * @returns The D-pad node.
 */
export function CreateDPad(this: void, props: DPadProps): Node.Type;

/** The virtual joystick properties. */
export interface JoyStickProps {
	/** The type of joystick. [required] */
	stickType?: JoyStickType;
	/** The size of the joystick. [optional] */
	moveSize?: number;
	/** The size of the hat. [optional] */
	hatSize?: number;
	/** The font name of the joystick. [optional] */
	fontName?: string;
	/** The stick button size of the joystick. [optional] */
	buttonSize?: number;
	/** The input manager for the joystick. [required] */
	inputManager: InputManager;
	/** The color of the joystick. [optional] */
	color?: number;
	/** The primary opacity of the joystick. [optional] */
	primaryOpacity?: number;
	/** The secondary opacity of the joystick. [optional] */
	secondaryOpacity?: number;
	/** Whether to hide the stick button. [optional] */
	noStickButton?: boolean;
}

/** A virtual joystick (L, LS or R, RS) TSX element for input. */
export function JoyStick(props: JoyStickProps): React.Element;

/**
 * Creates a virtual joystick (L, LS or R, RS) for input.
 * @param props The properties of the joystick.
 * @returns The joystick node.
 */
export function CreateJoyStick(this: void, props: JoyStickProps): Node.Type;

/** The virtual button pad properties. */
export interface ButtonPadProps {
	/** The size of the button. [optional] */
	buttonSize?: number;
	/** The padding of the buttons. [optional] */
	buttonPadding?: number;
	/** The font name of the button pad. [optional] */
	fontName?: string;
	/** The input manager for the button pad. [required] */
	inputManager: InputManager;
}

/** A virtual button pad (A, B, X, Y) TSX element for input. */
export function ButtonPad(props: ButtonPadProps): React.Element;

/**
 * Creates a virtual button pad (A, B, X, Y) for input.
 * @param props The properties of the button pad.
 * @returns The button pad node.
 */
export function CreateButtonPad(this: void, props: ButtonPadProps): Node.Type;

/** The virtual control pad properties. */
export interface ControlPadProps {
	/** The button size of the control pad. [optional] */
	buttonSize?: number;
	/** The font name of the control pad. [optional] */
	fontName?: string;
	/** The input manager for the control pad. [required] */
	inputManager: InputManager;
	/** The color of the control pad. [optional] */
	color?: number;
	/** The primary opacity of the control pad. [optional] */
	primaryOpacity?: number;
}

/** A virtual control pad (Start and Back buttons) TSX element for input. */
export function ControlPad(props: ControlPadProps): React.Element;

/**
 * Creates a virtual control pad (Start and Back buttons) for input.
 * @param props The properties of the control pad.
 * @returns The control pad node.
 */
export function CreateControlPad(this: void, props: ControlPadProps): Node.Type

/** The virtual trigger pad properties. */
export interface TriggerPadProps {
	/** The button size of the trigger pad. [optional] */
	buttonSize?: number;
	/** The font name of the trigger pad. [optional] */
	fontName?: string;
	/** The input manager for the trigger pad. [required] */
	inputManager: InputManager;
	/** The color of the trigger pad. [optional] */
	color?: number;
	/** The primary opacity of the trigger pad. [optional] */
	primaryOpacity?: number;
	/** Whether to hide the shoulder buttons (LB, RB). [optional] */
	noShoulder?: boolean;
}

/** A virtual trigger pad (LB, LT, RB, RT) TSX element for input. */
export function TriggerPad(props: TriggerPadProps): React.Element;

/**
 * Creates a virtual trigger pad (LB, LT, RB, RT) for input.
 * @param props The properties of the trigger pad.
 * @returns The trigger pad node.
 */
export function CreateTriggerPad(this: void, props: TriggerPadProps): Node.Type;

/** The virtual gamepad properties. */
export interface GamePadProps {
	/** Whether to hide the directional pad (D-pad). [optional] */
	noDPad?: boolean;
	/** Whether to hide the left stick (L, LS). [optional] */
	noLeftStick?: boolean;
	/** Whether to hide the right stick (R, RS). [optional] */
	noRightStick?: boolean;
	/** Whether to hide the button pad (A, B, X, Y). [optional] */
	noButtonPad?: boolean;
	/** Whether to hide the trigger pad (LB, LT, RB, RT). [optional] */
	noTriggerPad?: boolean;
	/** Whether to hide the control pad (Start and Back buttons). [optional] */
	noControlPad?: boolean;
	/** Whether to hide the shoulder buttons (LB, RB). [optional] */
	noShoulder?: boolean;
	/** Whether to hide the trigger buttons (LS, RS). [optional] */
	noStickButton?: boolean;
	/** The color of the gamepad. [optional] */
	color?: number;
	/** The primary opacity of the gamepad. [optional] */
	primaryOpacity?: number;
	/** The secondary opacity of the gamepad. [optional] */
	secondaryOpacity?: number;
	/** The input manager for the gamepad. [required] */
	inputManager: InputManager;
}

/** A virtual gamepad TSX element for input. */
export function GamePad(props: GamePadProps): React.Element;

/**
 * Creates a virtual gamepad for input.
 * @param props The properties of the gamepad.
 * @returns The gamepad node.
 */
export function CreateGamePad(this: void, props: GamePadProps): Node.Type;

} // module "InputManager"