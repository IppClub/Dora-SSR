import { React, useRef } from 'DoraX';
import { AxisName, ButtonName, DrawNode, KeyName, Node, Slot, Vec2, emit } from 'Dora';

export const enum TriggerState {
	/// 无状态：当前暂未获得输入状态。
	None = "None",
	/// 已开始：发生了开始触发器求值的某个事件。例如，"双击"触发器的第一次按键将调用一次"已开始"状态。
	Started = "Started",
	/// 进行中：触发器仍在进行处理。例如，当用户按下按钮时，在达到指定持续时间之前，"按住"动作处于进行中状态。根据触发器，此事件将在收到输入值之后在对动作求值时，每次更新触发一次。
	Ongoing = "Ongoing",
	/// 已完成：触发器求值过程已完成。
	Completed = "Completed",
	/// 已取消：触发已取消。例如，在"按住"动作还没触发之前，用户就松开了按钮。
	Canceled = "Canceled",
}

export abstract class Trigger {
	constructor();
	state: TriggerState;
	value: number | Vec2.Type | boolean | (number | Vec2.Type | boolean)[];
	progress: number;
	onChange?(): void;
	onUpdate?(deltaTime: number): void;
	abstract start(manager: Node.Type): void;
	abstract stop(manager: Node.Type): void;
}

export const enum JoyStickType {
	Left = "Left",
	Right = "Right",
}

export namespace Trigger {
	export function KeyDown(this: void, combineKeys: KeyName | KeyName[]): Trigger;
	export function KeyUp(this: void, combineKeys: KeyName | KeyName[]): Trigger;
	export function KeyPressed(this: void, combineKeys: KeyName | KeyName[]): Trigger;
	export function KeyHold(this: void, keyName: KeyName, holdTime: number): Trigger;
	export function KeyTimed(this: void, keyName: KeyName, timeWindow: number): Trigger;
	export function ButtonDown(this: void, combineButtons: ButtonName | ButtonName[], controllerId?: number): Trigger;
	export function ButtonUp(this: void, combineButtons: ButtonName | ButtonName[], controllerId?: number): Trigger;
	export function ButtonPressed(this: void, combineButtons: ButtonName | ButtonName[], controllerId?: number): Trigger;
	export function ButtonHold(this: void, buttonName: ButtonName, holdTime: number, controllerId?: number): Trigger;
	export function ButtonTimed(this: void, buttonName: ButtonName, timeWindow: number, controllerId?: number): Trigger;
	export function JoyStick(this: void, joyStickType: JoyStickType, controllerId?: number): Trigger;
	export function JoyStickThreshold(this: void, joyStickType: JoyStickType, threshold: number, controllerId?: number): Trigger;
	export function JoyStickDirectional(this: void, joyStickType: JoyStickType, angle: number, tolerance: number, controllerId?: number): Trigger;
	export function JoyStickRange(this: void, joyStickType: JoyStickType, minRange: number, maxRange: number, controllerId?: number): Trigger;
	export function Sequence(this: void, triggers: Trigger[]): Trigger;
	export function Selector(this: void, triggers: Trigger[]): Trigger;
	export function Block(this: void, trigger: Trigger): Trigger;
}

export interface InputAction {
	name: string;
	trigger: Trigger;
}

export interface InputContext {
	name: string;
	actions: InputAction[];
}

export class InputManager {
	constructor(contexts: InputContext[]);
	getNode(): Node.Type;
	pushContext(contextNames: string[]): boolean;
	popContext(): boolean;
	emitKeyDown(keyName: KeyName): void;
	emitKeyUp(keyName: KeyName): void;
	emitButtonDown(buttonName: ButtonName, controllerId?: number): void;
	emitButtonUp(buttonName: ButtonName, controllerId?: number): void;
	emitAxis(axisName: AxisName, value: number, controllerId?: number): void;
}

export function CreateInputManager(this: void, contexts: InputContext[]): InputManager;

export interface DPadProps {
	width?: number;
	height?: number;
	offset?: number;
	inputManager: InputManager;
}

export function DPad(props: DPadProps): React.Element;

export interface JoyStickProps {
	stickType?: JoyStickType;
	moveSize?: number;
	hatSize?: number;
	inputManager: InputManager;
}

export function JoyStick(props: JoyStickProps): React.Element;

export interface ButtonPadProps {
	buttonSize?: number;
	buttonPadding?: number;
	fontName?: string;
	inputManager: InputManager;
}

export function ButtonPad(props: ButtonPadProps): React.Element;

export interface GamePadProp {
	noDPad?: boolean;
	noLeftStick?: boolean;
	noRightStick?: boolean;
	noButtonPad?: boolean;
	noTriggerPad?: boolean;
	noControlPad?: boolean;
	color?: number;
	primaryOpacity?: number;
	secondaryOpacity?: number;
	inputManager: InputManager;
}

export function GamePad(props: GamePadProp): React.Element;
