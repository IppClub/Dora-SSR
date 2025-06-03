declare module 'InputManager' {

import { React } from 'DoraX';
import { AxisName, ButtonName, KeyName, Node } from 'Dora';

/** 触发器状态的枚举。 */
export const enum TriggerState {
	/** 无状态：当前暂未获得输入状态。 */
	None = "None",
	/** 已开始：发生了开始触发器求值的某个事件。例如，"按住"触发器的第一次按键将调用一次"已开始"状态。 */
	Started = "Started",
	/** 进行中：触发器仍在进行处理。例如，当用户按下按钮时，在达到指定持续时间之前，"按住"动作处于进行中状态。根据触发器，此事件将在收到输入值之后在对动作求值时，每次更新触发一次。 */
	Ongoing = "Ongoing",
	/** 已完成：触发器求值过程已完成。 */
	Completed = "Completed",
	/** 已取消：触发已取消。例如，在"按住"动作还没触发之前，用户就松开了按钮。 */
	Canceled = "Canceled",
}

/** 输入触发器类，可以是键盘键、游戏手柄按钮和摇杆各种输入的触发器。 */
export abstract class Trigger {
	private constructor();
}

/** 摇杆类型的枚举。 */
export const enum JoyStickType {
	Left = "Left",
	Right = "Right",
}

/** 输入触发器的管理模块，用于创建键盘键、游戏手柄按钮和摇杆的各种输入触发器。 */
export namespace Trigger {
	/**
	 * 创建一个触发器，当所有指定的键被按下时触发。
	 * @param combineKeys 要检查的单个键或组合键。
	 * @returns 触发器对象。
	 */
	export function KeyDown(this: void, combineKeys: KeyName | KeyName[]): Trigger;
	/**
	 * 创建一个触发器，当所有指定的键被按下并且其中任何一个被释放时触发。
	 * @param combineKeys 要检查的单个键或组合键。
	 * @returns 触发器对象。
	 */
	export function KeyUp(this: void, combineKeys: KeyName | KeyName[]): Trigger;
	/**
	 * 创建一个触发器，当所有指定的键正在被按下时触发。
	 * @param combineKeys 要检查的单个键或组合键。
	 * @returns 触发器对象。
	 */
	export function KeyPressed(this: void, combineKeys: KeyName | KeyName[]): Trigger;
	/**
	 * 创建一个触发器，当特定键被按下并且保持按下指定的持续时间时触发。
	 * @param keyName 要检查的键。
	 * @param holdTime 持续时间，以秒为单位。
	 * @returns 触发器对象。
	 */
	export function KeyHold(this: void, keyName: KeyName, holdTime: number): Trigger;
	/**
	 * 创建一个触发器，当特定键在指定的时间窗口内被按下时触发。
	 * @param keyName 要检查的键。
	 * @param timeWindow 时间窗口，以秒为单位。
	 * @returns 触发器对象。
	 */
	export function KeyTimed(this: void, keyName: KeyName, timeWindow: number): Trigger;
	/**
	 * 创建一个触发器，当特定键被按下两次时触发。
	 * @param key 要检查的键。
	 * @param threshold 两次按下之间的时间阈值，以秒为单位, 默认为0.3。
	 * @returns 触发器对象。
	 */
	export function KeyDoubleDown(this: void, key: KeyName, threshold?: number): Trigger;
	/**
	 * 创建一个触发器，当任意键被持续按下时触发。
	 * @returns 触发器对象。
	 */
	export function AnyKeyPressed(this: void): Trigger;
	/**
	 * 创建一个触发器，当所有指定的游戏手柄按钮被按下时触发。
	 * @param combineButtons 要检查的游戏手柄按钮或组合按钮。
	 * @param controllerId 游戏手柄控制器的ID。默认为0。
	 * @returns 触发器对象。
	 */
	export function ButtonDown(this: void, combineButtons: ButtonName | ButtonName[], controllerId?: number): Trigger;
	/**
	 * 创建一个触发器，当所有指定的游戏手柄按钮被按下并且其中任何一个被释放时触发。
	 * @param combineButtons 要检查的游戏手柄按钮或组合按钮。
	 * @param controllerId 游戏手柄控制器的ID。默认为0。
	 * @returns 触发器对象。
	 */
	export function ButtonUp(this: void, combineButtons: ButtonName | ButtonName[], controllerId?: number): Trigger;
	/**
	 * 创建一个触发器，当所有指定的游戏手柄按钮正在被按下时触发。
	 * @param combineButtons 要检查的游戏手柄按钮或组合按钮。
	 * @param controllerId 游戏手柄控制器的ID。默认为0。
	 * @returns 触发器对象。
	 */
	export function ButtonPressed(this: void, combineButtons: ButtonName | ButtonName[], controllerId?: number): Trigger;
	/**
	 * 创建一个触发器，当特定的游戏手柄按钮被按下并且保持按下指定的持续时间后触发。
	 * @param buttonName 要检查的游戏手柄按钮。
	 * @param holdTime 持续时间，以秒为单位。
	 * @param controllerId 游戏手柄控制器的ID。默认为0。
	 * @returns 触发器对象。
	 */
	export function ButtonHold(this: void, buttonName: ButtonName, holdTime: number, controllerId?: number): Trigger;
	/**
	 * 创建一个触发器，当特定的游戏手柄按钮在指定的时间窗口内被按下时触发。
	 * @param buttonName 要检查的游戏手柄按钮。
	 * @param timeWindow 时间窗口，以秒为单位。
	 * @param controllerId 游戏手柄控制器的ID。默认为0。
	 * @returns 触发器对象。
	 */
	export function ButtonTimed(this: void, buttonName: ButtonName, timeWindow: number, controllerId?: number): Trigger;
	/**
	 * 创建一个触发器，当特定的游戏手柄按钮被按下两次时触发。
	 * @param button 要检查的游戏手柄按钮。
	 * @param threshold 两次按下之间的时间阈值，以秒为单位, 默认为0.3。
	 * @param controllerId 游戏手柄控制器的ID。默认为0。
	 * @returns 触发器对象。
	 */
	export function ButtonDoubleDown(this: void, button: ButtonName, threshold?: number, controllerId?: number): Trigger;
	/**
	 * 创建一个触发器，当任意游戏手柄按钮被持续按下时触发。
	 * @param controllerId 游戏手柄控制器的ID。默认为0。
	 * @returns 触发器对象。
	 */
	export function AnyButtonPressed(this: void, controllerId?: number): Trigger;
	/**
	 * 创建一个触发器，当特定的游戏手柄轴被移动时触发。
	 * @param joyStickType 要检查的操纵杆类型。
	 * @param controllerId 游戏手柄控制器的ID。默认为0。
	 * @returns 触发器对象。
	 */
	export function JoyStick(this: void, joyStickType: JoyStickType, controllerId?: number): Trigger;
	/**
	 * 创建一个触发器，当操纵杆移动超过指定阈值时触发。
	 * @param joyStickType 要检查的操纵杆类型。
	 * @param threshold 阈值，取值范围为0到1。
	 * @param controllerId 游戏手柄控制器的ID。默认为0。
	 * @returns 触发器对象。
	 */
	export function JoyStickThreshold(this: void, joyStickType: JoyStickType, threshold: number, controllerId?: number): Trigger;
	/**
	 * 创建一个触发器，当操纵杆在容忍的偏差角度内朝特定方向移动时触发。
	 * @param joyStickType 要检查的操纵杆类型。
	 * @param angle 方向的角度，以度为单位。
	 * @param tolerance 容忍角度，以度为单位。
	 * @param controllerId 游戏手柄控制器的ID。默认为0。
	 * @returns 触发器对象。
	 */
	export function JoyStickDirectional(this: void, joyStickType: JoyStickType, angle: number, tolerance: number, controllerId?: number): Trigger;
	/**
	 * 创建一个触发器，当操纵杆在指定范围内时触发。
	 * @param joyStickType 要检查的操纵杆类型。
	 * @param minRange 最小范围值，取值范围为0到1。
	 * @param maxRange 最大范围值，取值范围为0到1。
	 * @param controllerId 游戏手柄控制器的ID。默认为0。
	 * @returns 触发器对象。
	 */
	export function JoyStickRange(this: void, joyStickType: JoyStickType, minRange: number, maxRange: number, controllerId?: number): Trigger;
	/**
	 * 创建一个触发器，当一组其他触发器同时进入完成状态时触发。
	 * @param triggers 要检查的触发器。
	 * @returns 触发器对象。
	 */
	export function Sequence(this: void, triggers: Trigger[]): Trigger;
	/**
	 * 创建一个触发器，当一组其他触发器中的任何一个进入完成状态时触发。
	 * @param triggers 要检查的触发器。
	 * @returns 触发器对象。
	 */
	export function Selector(this: void, triggers: Trigger[]): Trigger;
	/**
	 * 当子触发器处于完成状态时，它将反过来报告为取消状态，用于阻塞触发器的事件。
	 * @param trigger 要被阻塞的触发器。
	 * @returns 触发器对象。
	 */
	export function Block(this: void, trigger: Trigger): Trigger;
}

/**
 * `InputManager` 是一个用于管理输入上下文和动作的类。可以通过创建输入上下文和动作，然后将它们添加到输入管理器中，来实现输入事件的监听和处理。可以通过调用 `pushContext` 和 `popContext` 方法来激活和停用特定组合的输入上下文。在触发事件时，可以通过注册全局输入事件监听器来处理输入事件。
 * @usage
 * import { CreateManager, Trigger } from "InputManager";
 * const inputManager = CreateManager([
 * 	context1: {
 * 		action1: Trigger.KeyDown(KeyName.W),
 * 	},
 * ]);
 * // 激活上下文 context1
 * inputManager.pushContext("context1");
 * // 要监听的输入事件名需要加上 `Input.` 前缀
 * node.gslot("Input.action1", () => {
 * 	print("action1 triggered");
 * });
 * // 从上下文栈中删除 context1
 * inputManager.popContext();
 * // 销毁输入管理器
 * inputManager.destroy();
 */
export class InputManager {
	private constructor(contexts: {[contextName: string]: {[actionName: string]: Trigger}});
	/**
	 * 获取当前输入系统使用的场景节点。该节点用于接收输入事件。它在创建后，如果没有被添加到指定的父节点，会在稍后被自动添加到 `Director.entry` 中。
	 * @returns 输入系统的场景节点。
	 */
	getNode(): Node.Type;
	/**
	 * 将指定名称的上下文添加到上下文栈中。会暂时禁用之前生效的上下文，然后激活新上下文中会触发的动作和事件。
	 * @param contextNames 单个上下文的名称或是上下文名称的数组。
	 * @returns 上下文是否成功添加和生效。
	 */
	pushContext(contextNames: string | string[]): boolean;
	/**
	 * 从上下文栈中移除并停止当前栈顶在生效的上下文。然后激活前一组上下文。
	 * @param count 要移除的上下文数量。默认为1。
	 * @returns 栈顶上下文是否成功移除。
	 */
	popContext(count?: number): boolean;
	/**
	 * 发送按键按下事件到输入系统以模拟输入。
	 * @param keyName 键的名称。
	 */
	emitKeyDown(keyName: KeyName): void;
	/**
	 * 发送按键释放事件到输入系统以模拟输入。
	 * @param keyName 键的名称。
	 */
	emitKeyUp(keyName: KeyName): void;
	/**
	 * 发送按键按住事件到输入系统以模拟输入。
	 * @param buttonName 按钮的名称。
	 * @param controllerId 游戏手柄控制器的ID。默认为0。
	 */
	emitButtonDown(buttonName: ButtonName, controllerId?: number): void;
	/**
	 * 发送按键释放事件到输入系统以模拟输入。
	 * @param buttonName 按钮的名称。
	 * @param controllerId 游戏手柄控制器的ID。默认为0。
	 */
	emitButtonUp(buttonName: ButtonName, controllerId?: number): void;
	/**
	 * 发送摇杆变动的事件到输入系统以模拟输入。
	 * @param axisName 轴的名称。
	 * @param value 轴的值，取值范围为-1到1。
	 * @param controllerId 游戏手柄控制器的ID。默认为0。
	 */
	emitAxis(axisName: AxisName, value: number, controllerId?: number): void;
	/**
	 * 销毁输入管理器并清除在生效的输入事件监听器。
	 */
	destroy(): void;
}

/**
 * 使用指定的输入上下文创建输入管理器。
 * @param contexts 要创建的一组输入上下文。
 * @returns 输入管理器。
 */
export function CreateManager(this: void, contexts: {[contextName: string]: {[actionName: string]: Trigger}}): InputManager;

/** 虚拟方向键（D-pad）的属性。 */
export interface DPadProps {
	/** D-pad的按钮宽度。[可选] */
	width?: number;
	/** D-pad的按钮高度。[可选] */
	height?: number;
	/** D-pad的按钮间距。[可选] */
	offset?: number;
	/** D-pad的输入管理器。[必需] */
	inputManager: InputManager;
}

/** 虚拟方向键（D-pad）的TSX组件。 */
export function DPad(props: DPadProps): React.Element;

/**
 * 创建一个虚拟方向键（D-pad）的UI节点。
 * @param props D-pad的属性。
 * @returns D-pad节点。
 */
export function CreateDPad(this: void, props: DPadProps): Node.Type;

/** 虚拟操纵杆UI的属性。 */
export interface JoyStickProps {
	/** 操纵杆的类型。[必需] */
	stickType?: JoyStickType;
	/** 操纵杆的移动大小。[可选] */
	moveSize?: number;
	/** 帽子的大小。[可选] */
	hatSize?: number;
	/** 操纵杆的字体名称。[可选] */
	fontName?: string;
	/** 操纵杆按钮的大小。[可选] */
	buttonSize?: number;
	/** 操纵杆的输入管理器。[必需] */
	inputManager: InputManager;
	/** 操纵杆的颜色。[可选] */
	color?: number;
	/** 操纵杆的主要透明度。[可选] */
	primaryOpacity?: number;
	/** 操纵杆的次要透明度。[可选] */
	secondaryOpacity?: number;
	/** 是否隐藏操纵杆按钮。[可选] */
	noStickButton?: boolean;
}

/** 虚拟操纵杆UI（L、LS 或是 R、RS）的TSX组件。 */
export function JoyStick(props: JoyStickProps): React.Element;

/**
 * 创建一个虚拟摇杆的UI节点（L、LS 或是 R、RS）。
 * @param props 操纵杆的属性。
 * @returns 操纵杆节点。
 */
export function CreateJoyStick(this: void, props: JoyStickProps): Node.Type;

/** 虚拟按钮盘UI的属性。 */
export interface ButtonPadProps {
	/** 按钮的大小。[可选] */
	buttonSize?: number;
	/** 按钮的间距。[可选] */
	buttonPadding?: number;
	/** 按钮盘的字体名称。[可选] */
	fontName?: string;
	/** 按钮盘的输入管理器。[必需] */
	inputManager: InputManager;
}

/** 虚拟按钮盘UI（A、B、X、Y）的TSX组件。 */
export function ButtonPad(props: ButtonPadProps): React.Element;

/**
 * 创建一个虚拟按钮盘的UI节点（A、B、X、Y）。
 * @param props 按钮盘的属性。
 * @returns 按钮盘节点。
 */
export function CreateButtonPad(this: void, props: ButtonPadProps): Node.Type;

/** 虚拟控制盘UI的属性。 */
export interface ControlPadProps {
	/** 按钮的大小。[可选] */
	buttonSize?: number;
	/** 按钮盘的字体名称。[可选] */
	fontName?: string;
	/** 按钮盘的输入管理器。[必需] */
	inputManager: InputManager;
	/** 控制盘的颜色。[可选] */
	color?: number;
	/** 控制盘的主要透明度。[可选] */
	primaryOpacity?: number;
}

/** 虚拟控制盘UI（开始和返回按钮）的TSX组件。 */
export function ControlPad(props: ControlPadProps): React.Element;

/**
 * 创建一个虚拟控制盘（开始和返回按钮）的UI节点。
 * @param props 控制盘的属性。
 * @returns 控制盘节点。
 */
export function CreateControlPad(this: void, props: ControlPadProps): Node.Type

/** 虚拟触发器按钮UI的属性。 */
export interface TriggerPadProps {
	/** 按钮的大小。[可选] */
	buttonSize?: number;
	/** 按钮盘的字体名称。[可选] */
	fontName?: string;
	/** 按钮盘的输入管理器。[必需] */
	inputManager: InputManager;
	/** 触发器的颜色。[可选] */
	color?: number;
	/** 触发器的主要透明度。[可选] */
	primaryOpacity?: number;
	/** 是否隐藏肩部按钮（LB、RB）。[可选] */
	noShoulder?: boolean;
}

/** 虚拟触发器按钮UI（LB、LT、RB、RT）的TSX组件。 */
export function TriggerPad(props: TriggerPadProps): React.Element;

/**
 * 创建一个虚拟触发器盘的UI节点（LB、LT、RB、RT）。
 * @param props 触发器盘的属性。
 * @returns 触发器盘节点。
 */
export function CreateTriggerPad(this: void, props: TriggerPadProps): Node.Type;

/** 虚拟游戏手柄UI的属性。 */
export interface GamePadProps {
	/** 是否隐藏方向键盘（D-pad）。[可选] */
	noDPad?: boolean;
	/** 是否隐藏左摇杆（L、LS）。[可选] */
	noLeftStick?: boolean;
	/** 是否隐藏右摇杆（R、RS）。[可选] */
	noRightStick?: boolean;
	/** 是否隐藏按钮盘（A、B、X、Y）。[可选] */
	noButtonPad?: boolean;
	/** 是否隐藏触发器盘（LB、LT、RB、RT）。[可选] */
	noTriggerPad?: boolean;
	/** 是否隐藏控制盘（开始和返回按钮）。[可选] */
	noControlPad?: boolean;
	/** 是否隐藏肩部按钮（LB、RB）。[可选] */
	noShoulder?: boolean;
	/** 是否隐藏摇杆按钮（LS、RS）。[可选] */
	noStickButton?: boolean;
	/** 游戏手柄的颜色。[可选] */
	color?: number;
	/** 游戏手柄的主要透明度。[可选] */
	primaryOpacity?: number;
	/** 游戏手柄的次要透明度。[可选] */
	secondaryOpacity?: number;
	/** 游戏手柄的输入管理器。[必需] */
	inputManager: InputManager;
}

/** 虚拟游戏手柄UI的TSX组件。 */
export function GamePad(props: GamePadProps): React.Element;

/**
 * 创建一个虚拟游戏手柄的UI节点。
 * @param props 游戏手柄的属性。
 * @returns 游戏手柄节点。
 */
export function CreateGamePad(this: void, props: GamePadProps): Node.Type;

} // module "InputManager"
