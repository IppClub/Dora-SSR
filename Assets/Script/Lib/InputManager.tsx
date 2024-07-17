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
	constructor() {
		this.state = TriggerState.None;
		this.progress = 0;
		this.value = false;
	}
	state: TriggerState;
	value: number | Vec2.Type | boolean | (number | Vec2.Type | boolean)[];
	progress: number;
	onChange?(): void;
	onUpdate?(deltaTime: number): void;
	abstract start(manager: Node.Type): void;
	abstract stop(manager: Node.Type): void;
}

class KeyDownTrigger extends Trigger {
	private keys: KeyName[];
	private keyStates: LuaTable<KeyName, boolean>;
	private onKeyDown: (this: void, keyName: KeyName) => void;
	private onKeyUp: (this: void, keyName: KeyName) => void;

	constructor(keys: KeyName[]) {
		super();
		this.keys = keys;
		this.keyStates = new LuaTable;
		this.onKeyDown = (keyName: KeyName) => {
			if (this.state === TriggerState.Completed) {
				return;
			}
			if (!this.keyStates.has(keyName)) {
				return;
			}
			let oldState = true;
			for (let [, state] of this.keyStates) {
				oldState &&= state;
			}
			this.keyStates.set(keyName, true);
			if (!oldState) {
				let newState = true;
				for (let [, state] of this.keyStates) {
					newState &&= state;
				}
				if (newState) {
					this.state = TriggerState.Completed;
					this.progress = 1;
					if (this.onChange) {
						this.onChange();
					}
					this.progress = 0;
					this.state = TriggerState.None;
				}
			}
		};
		this.onKeyUp = (keyName: KeyName) => {
			if (this.state === TriggerState.Completed) {
				return;
			}
			if (!this.keyStates.has(keyName)) {
				return;
			}
			this.keyStates.set(keyName, false);
		};
	}
	start(manager: Node.Type) {
		manager.keyboardEnabled = true;
		for (let k of this.keys) {
			this.keyStates.set(k, false);
		}
		manager.slot(Slot.KeyDown, this.onKeyDown);
		manager.slot(Slot.KeyUp, this.onKeyUp);
		this.state = TriggerState.None;
		this.progress = 0;
	}
	stop(manager: Node.Type) {
		manager.slot(Slot.KeyDown).remove(this.onKeyDown);
		manager.slot(Slot.KeyUp).remove(this.onKeyUp);
		this.state = TriggerState.None;
		this.progress = 0;
	}
}

class KeyUpTrigger extends Trigger {
	private keys: KeyName[];
	private keyStates: LuaTable<KeyName, boolean>;
	private onKeyDown: (this: void, keyName: KeyName) => void;
	private onKeyUp: (this: void, keyName: KeyName) => void;

	constructor(keys: KeyName[]) {
		super();
		this.keys = keys;
		this.keyStates = new LuaTable;
		this.onKeyDown = (keyName: KeyName) => {
			if (this.state === TriggerState.Completed) {
				return;
			}
			if (!this.keyStates.has(keyName)) {
				return;
			}
			this.keyStates.set(keyName, true);
		};
		this.onKeyUp = (keyName: KeyName) => {
			if (this.state === TriggerState.Completed) {
				return;
			}
			if (!this.keyStates.has(keyName)) {
				return;
			}
			let oldState = true;
			for (let [, state] of this.keyStates) {
				oldState &&= state;
			}
			this.keyStates.set(keyName, false);
			if (oldState) {
					this.state = TriggerState.Completed;
					this.progress = 1;
					if (this.onChange) {
						this.onChange();
					}
					this.progress = 0;
					this.state = TriggerState.None;
			}
		};
	}
	start(manager: Node.Type) {
		manager.keyboardEnabled = true;
		for (let k of this.keys) {
			this.keyStates.set(k, false);
		}
		manager.slot(Slot.KeyDown, this.onKeyDown);
		manager.slot(Slot.KeyUp, this.onKeyUp);
		this.state = TriggerState.None;
		this.progress = 0;
	}
	stop(manager: Node.Type) {
		manager.slot(Slot.KeyDown).remove(this.onKeyDown);
		manager.slot(Slot.KeyUp).remove(this.onKeyUp);
		this.state = TriggerState.None;
		this.progress = 0;
	}
}

class KeyPressedTrigger extends Trigger {
	private keys: KeyName[];
	private keyStates: LuaTable<KeyName, boolean>;
	private onKeyDown: (this: void, keyName: KeyName) => void;
	private onKeyUp: (this: void, keyName: KeyName) => void;

	constructor(keys: KeyName[]) {
		super();
		this.keys = keys;
		this.keyStates = new LuaTable;
		this.onKeyDown = (keyName: KeyName) => {
			if (!this.keyStates.has(keyName)) {
				return;
			}
			this.keyStates.set(keyName, true);
		};
		this.onKeyUp = (keyName: KeyName) => {
			if (!this.keyStates.has(keyName)) {
				return;
			}
			this.keyStates.set(keyName, false);
		};
	}
	onUpdate(_: number) {
		let allDown = true;
		for (let [, down] of this.keyStates) {
			allDown &&= down;
		}
		if (allDown) {
			this.state = TriggerState.Completed;
			this.progress = 1;
			if (this.onChange) {
				this.onChange();
			}
			this.progress = 0;
			this.state = TriggerState.None;
		}
	}
	start(manager: Node.Type) {
		manager.keyboardEnabled = true;
		for (let k of this.keys) {
			this.keyStates.set(k, false);
		}
		manager.slot(Slot.KeyDown, this.onKeyDown);
		manager.slot(Slot.KeyUp, this.onKeyUp);
		this.state = TriggerState.None;
		this.progress = 0;
	}
	stop(manager: Node.Type) {
		manager.slot(Slot.KeyDown).remove(this.onKeyDown);
		manager.slot(Slot.KeyUp).remove(this.onKeyUp);
		this.state = TriggerState.None;
		this.progress = 0;
	}
}

class KeyHoldTrigger extends Trigger {
	private key: KeyName;
	private holdTime: number;
	private time: number;
	private onKeyDown: (this: void, keyName: KeyName) => void;
	private onKeyUp: (this: void, keyName: KeyName) => void;

	constructor(key: KeyName, holdTime: number) {
		super();
		this.key = key;
		this.holdTime = holdTime;
		this.time = 0;
		this.onKeyDown = (keyName: KeyName) => {
			if (this.key === keyName) {
				this.time = 0;
				this.state = TriggerState.Started;
				this.progress = 0;
				if (this.onChange) {
					this.onChange();
				}
			}
		};
		this.onKeyUp = (keyName: KeyName) => {
			switch (this.state) {
				case TriggerState.Started:
				case TriggerState.Ongoing:
				case TriggerState.Completed:
					break;
				default:
					return;
			}
			if (this.key === keyName) {
				if (this.state === TriggerState.Completed) {
					this.state = TriggerState.None;
				} else {
					this.state = TriggerState.Canceled;
				}
				this.progress = 0;
				if (this.onChange) {
					this.onChange();
				}
			}
		}
	}
	start(manager: Node.Type) {
		manager.keyboardEnabled = true;
		manager.slot(Slot.KeyDown, this.onKeyDown);
		manager.slot(Slot.KeyUp, this.onKeyUp);
		this.state = TriggerState.None;
		this.progress = 0;
	}
	onUpdate(deltaTime: number) {
		switch (this.state) {
			case TriggerState.Started:
			case TriggerState.Ongoing:
				break;
			default:
				return;
		}
		this.time += deltaTime;
		if (this.time >= this.holdTime) {
			this.state = TriggerState.Completed;
			this.progress = 1;
		} else {
			this.state = TriggerState.Ongoing;
			this.progress = math.min(this.time / this.holdTime, 1);
		}
		if (this.onChange) {
			this.onChange();
		}
	}
	stop(manager: Node.Type) {
		manager.slot(Slot.KeyDown).remove(this.onKeyDown);
		manager.slot(Slot.KeyUp).remove(this.onKeyUp);
		this.state = TriggerState.None;
		this.progress = 0;
	}
}

class KeyTimedTrigger extends Trigger {
	private key: KeyName;
	private timeWindow: number;
	private time: number;
	private onKeyDown: (this: void, keyName: KeyName) => void;

	constructor(key: KeyName, timeWindow: number) {
		super();
		this.key = key;
		this.timeWindow = timeWindow;
		this.time = 0;
		this.onKeyDown = (keyName: KeyName) => {
			switch (this.state) {
				case TriggerState.Started:
				case TriggerState.Ongoing:
				case TriggerState.Completed:
					break;
				default:
					return;
			}
			if (this.key === keyName && this.time <= this.timeWindow) {
				this.state = TriggerState.Completed;
				this.value = this.time;
				if (this.onChange) {
					this.onChange();
				}
			}
		};
	}
	start(manager: Node.Type) {
		manager.keyboardEnabled = true;
		manager.slot(Slot.KeyDown, this.onKeyDown);
		this.state = TriggerState.Started;
		this.progress = 0;
		this.value = false;
		if (this.onChange) {
			this.onChange();
		}
	}
	onUpdate(deltaTime: number) {
		switch (this.state) {
			case TriggerState.Started:
			case TriggerState.Ongoing:
			case TriggerState.Completed:
				break;
			default:
				return;
		}
		this.time += deltaTime;
		if (this.time >= this.timeWindow) {
			if (this.state === TriggerState.Completed) {
				this.state = TriggerState.None;
				this.progress = 0;
			} else {
				this.state = TriggerState.Canceled;
				this.progress = 1;
			}
		} else {
			this.state = TriggerState.Ongoing;
			this.progress = math.min(this.time / this.timeWindow, 1);
		}
		if (this.onChange) {
			this.onChange();
		}
	}
	stop(manager: Node.Type) {
		manager.slot(Slot.KeyDown).remove(this.onKeyDown);
		this.state = TriggerState.None;
		this.value = false;
		this.progress = 0;
	}
}

class ButtonDownTrigger extends Trigger {
	private buttons: ButtonName[];
	private controllerId: number;
	private buttonStates: LuaTable<ButtonName, boolean>;
	private onButtonDown: (this: void, controllerId: number, buttonName: ButtonName) => void;
	private onButtonUp: (this: void, controllerId: number, buttonName: ButtonName) => void;

	constructor(buttons: ButtonName[], controllerId: number) {
		super();
		this.controllerId = controllerId;
		this.buttons = buttons;
		this.buttonStates = new LuaTable;
		this.onButtonDown = (controllerId: number, buttonName: ButtonName) => {
			if (this.state === TriggerState.Completed) {
				return;
			}
			if (this.controllerId !== controllerId) {
				return;
			}
			if (!this.buttonStates.has(buttonName)) {
				return;
			}
			let oldState = true;
			for (let [, state] of this.buttonStates) {
				oldState &&= state;
			}
			this.buttonStates.set(buttonName, true);
			if (!oldState) {
				let newState = true;
				for (let [, state] of this.buttonStates) {
					newState &&= state;
				}
				if (newState) {
					this.state = TriggerState.Completed;
					this.progress = 1;
					if (this.onChange) {
						this.onChange();
					}
					this.progress = 0;
					this.state = TriggerState.None;
				}
			}
		};
		this.onButtonUp = (controllerId: number, buttonName: ButtonName) => {
			if (this.state === TriggerState.Completed) {
				return;
			}
			if (this.controllerId !== controllerId) {
				return;
			}
			if (!this.buttonStates.has(buttonName)) {
				return;
			}
			this.buttonStates.set(buttonName, false);
		};
	}
	start(manager: Node.Type) {
		manager.controllerEnabled = true;
		for (let k of this.buttons) {
			this.buttonStates.set(k, false);
		}
		manager.slot(Slot.ButtonDown, this.onButtonDown);
		manager.slot(Slot.ButtonUp, this.onButtonUp);
		this.state = TriggerState.None;
		this.progress = 0;
	}
	stop(manager: Node.Type) {
		manager.slot(Slot.ButtonDown).remove(this.onButtonDown);
		manager.slot(Slot.ButtonUp).remove(this.onButtonUp);
		this.state = TriggerState.None;
		this.progress = 0;
		this.value = false;
	}
}

class ButtonUpTrigger extends Trigger {
	private buttons: ButtonName[];
	private controllerId: number;
	private buttonStates: LuaTable<ButtonName, boolean>;
	private onButtonDown: (this: void, controllerId: number, buttonName: ButtonName) => void;
	private onButtonUp: (this: void, controllerId: number, buttonName: ButtonName) => void;

	constructor(buttons: ButtonName[], controllerId: number) {
		super();
		this.controllerId = controllerId;
		this.buttons = buttons;
		this.buttonStates = new LuaTable;
		this.onButtonDown = (controllerId: number, buttonName: ButtonName) => {
			if (this.state === TriggerState.Completed) {
				return;
			}
			if (this.controllerId !== controllerId) {
				return;
			}
			if (!this.buttonStates.has(buttonName)) {
				return;
			}
			this.buttonStates.set(buttonName, true);
		};
		this.onButtonUp = (controllerId: number, buttonName: ButtonName) => {
			if (this.state === TriggerState.Completed) {
				return;
			}
			if (this.controllerId !== controllerId) {
				return;
			}
			if (!this.buttonStates.has(buttonName)) {
				return;
			}
			let oldState = true;
			for (let [, state] of this.buttonStates) {
				oldState &&= state;
			}
			this.buttonStates.set(buttonName, false);
			if (oldState) {
					this.state = TriggerState.Completed;
					this.progress = 1;
					if (this.onChange) {
						this.onChange();
					}
					this.progress = 0;
					this.state = TriggerState.None;
			}
		};
	}
	start(manager: Node.Type) {
		manager.controllerEnabled = true;
		for (let k of this.buttons) {
			this.buttonStates.set(k, false);
		}
		manager.slot(Slot.ButtonDown, this.onButtonDown);
		manager.slot(Slot.ButtonUp, this.onButtonUp);
		this.state = TriggerState.None;
		this.progress = 0;
	}
	stop(manager: Node.Type) {
		manager.slot(Slot.ButtonDown).remove(this.onButtonDown);
		manager.slot(Slot.ButtonUp).remove(this.onButtonUp);
		this.state = TriggerState.None;
		this.progress = 0;
	}
}

class ButtonPressedTrigger extends Trigger {
	private controllerId: number;
	private buttons: ButtonName[];
	private buttonStates: LuaTable<ButtonName, boolean>;
	private onButtonDown: (this: void, controllerId: number, buttonName: ButtonName) => void;
	private onButtonUp: (this: void, controllerId: number, buttonName: ButtonName) => void;

	constructor(buttons: ButtonName[], controllerId: number) {
		super();
		this.controllerId = controllerId;
		this.buttons = buttons;
		this.buttonStates = new LuaTable;
		this.onButtonDown = (controllerId: number, buttonName: ButtonName) => {
			if (this.controllerId !== controllerId) {
				return;
			}
			if (!this.buttonStates.has(buttonName)) {
				return;
			}
			this.buttonStates.set(buttonName, true);
		};
		this.onButtonUp = (controllerId: number, buttonName: ButtonName) => {
			if (this.controllerId !== controllerId) {
				return;
			}
			if (!this.buttonStates.has(buttonName)) {
				return;
			}
			this.buttonStates.set(buttonName, false);
		};
	}
	onUpdate(_: number) {
		let allDown = true;
		for (let [, down] of this.buttonStates) {
			allDown &&= down;
		}
		if (allDown) {
			this.state = TriggerState.Completed;
			this.progress = 1;
			if (this.onChange) {
				this.onChange();
			}
			this.progress = 0;
			this.state = TriggerState.None;
		}
	}
	start(manager: Node.Type) {
		manager.controllerEnabled = true;
		for (let k of this.buttons) {
			this.buttonStates.set(k, false);
		}
		manager.slot(Slot.ButtonDown, this.onButtonDown);
		manager.slot(Slot.ButtonUp, this.onButtonUp);
		this.state = TriggerState.None;
		this.progress = 0;
	}
	stop(manager: Node.Type) {
		manager.slot(Slot.ButtonDown).remove(this.onButtonDown);
		manager.slot(Slot.ButtonUp).remove(this.onButtonUp);
		this.state = TriggerState.None;
		this.progress = 0;
	}
}

class ButtonHoldTrigger extends Trigger {
	private controllerId: number;
	private button: ButtonName;
	private holdTime: number;
	private time: number;
	private onButtonDown: (this: void, controllerId: number, buttonName: ButtonName) => void;
	private onButtonUp: (this: void, controllerId: number, buttonName: ButtonName) => void;

	constructor(button: ButtonName, holdTime: number, controllerId: number) {
		super();
		this.controllerId = controllerId;
		this.button = button;
		this.holdTime = holdTime;
		this.time = 0;
		this.onButtonDown = (controllerId: number, buttonName: ButtonName) => {
			if (this.controllerId !== controllerId) {
				return;
			}
			if (this.button === buttonName) {
				this.time = 0;
				this.state = TriggerState.Started;
				this.progress = 0;
				if (this.onChange) {
					this.onChange();
				}
			}
		};
		this.onButtonUp = (controllerId: number, buttonName: ButtonName) => {
			if (this.controllerId !== controllerId) {
				return;
			}
			switch (this.state) {
				case TriggerState.Started:
				case TriggerState.Ongoing:
				case TriggerState.Completed:
					break;
				default:
					return;
			}
			if (this.button === buttonName) {
				if (this.state === TriggerState.Completed) {
					this.state = TriggerState.None;
				} else {
					this.state = TriggerState.Canceled;
				}
				this.progress = 0;
				if (this.onChange) {
					this.onChange();
				}
			}
		}
	}
	start(manager: Node.Type) {
		manager.controllerEnabled = true;
		manager.slot(Slot.ButtonDown, this.onButtonDown);
		manager.slot(Slot.ButtonUp, this.onButtonUp);
		this.state = TriggerState.None;
		this.progress = 0;
	}
	onUpdate(deltaTime: number) {
		switch (this.state) {
			case TriggerState.Started:
			case TriggerState.Ongoing:
				break;
			default:
				return;
		}
		this.time += deltaTime;
		if (this.time >= this.holdTime) {
			this.state = TriggerState.Completed;
			this.progress = 1;
		} else {
			this.state = TriggerState.Ongoing;
			this.progress = math.min(this.time / this.holdTime, 1);
		}
		if (this.onChange) {
			this.onChange();
		}
	}
	stop(manager: Node.Type) {
		manager.slot(Slot.ButtonDown).remove(this.onButtonDown);
		manager.slot(Slot.ButtonUp).remove(this.onButtonUp);
		this.state = TriggerState.None;
		this.progress = 0;
	}
}

class ButtonTimedTrigger extends Trigger {
	private controllerId: number;
	private button: ButtonName;
	private timeWindow: number;
	private time: number;
	private onButtonDown: (this: void, controllerId: number, buttonName: ButtonName) => void;

	constructor(button: ButtonName, timeWindow: number, controllerId: number) {
		super();
		this.controllerId = controllerId;
		this.button = button;
		this.timeWindow = timeWindow;
		this.time = 0;
		this.onButtonDown = (controllerId: number, buttonName: ButtonName) => {
			if (this.controllerId !== controllerId) {
				return;
			}
			switch (this.state) {
				case TriggerState.Started:
				case TriggerState.Ongoing:
				case TriggerState.Completed:
					break;
				default:
					return;
			}
			if (this.button === buttonName && this.time <= this.timeWindow) {
				this.state = TriggerState.Completed;
				this.value = this.time;
				if (this.onChange) {
					this.onChange();
				}
			}
		};
	}
	start(manager: Node.Type) {
		manager.controllerEnabled = true;
		manager.slot(Slot.ButtonDown, this.onButtonDown);
		this.state = TriggerState.Started;
		this.progress = 0;
		this.value = false;
		if (this.onChange) {
			this.onChange();
		}
	}
	onUpdate(deltaTime: number) {
		switch (this.state) {
			case TriggerState.Started:
			case TriggerState.Ongoing:
			case TriggerState.Completed:
				break;
			default:
				return;
		}
		this.time += deltaTime;
		if (this.time >= this.timeWindow) {
			if (this.state === TriggerState.Completed) {
				this.state = TriggerState.None;
				this.progress = 0;
			} else {
				this.state = TriggerState.Canceled;
				this.progress = 1;
			}
		} else {
			this.state = TriggerState.Ongoing;
			this.progress = math.min(this.time / this.timeWindow, 1);
		}
		if (this.onChange) {
			this.onChange();
		}
	}
	stop(manager: Node.Type) {
		manager.slot(Slot.ButtonDown).remove(this.onButtonDown);
		this.state = TriggerState.None;
		this.progress = 0;
	}
}

export const enum JoyStickType {
	Left = "Left",
	Right = "Right",
}

class JoyStickTrigger extends Trigger {
	private controllerId: number;
	protected axis: Vec2.Type;
	private joyStickType: JoyStickType;
	private onAxis: (this: void, controllerId: number, axisName: AxisName, value: number) => void;

	constructor(joyStickType: JoyStickType, controllerId: number) {
		super();
		this.joyStickType = joyStickType;
		this.controllerId = controllerId;
		this.axis = Vec2.zero;
		this.onAxis = (controllerId: number, axisName: AxisName, value: number) => {
			if (this.controllerId !== controllerId) {
				return;
			}
			switch (this.joyStickType) {
				case JoyStickType.Left: {
					switch (axisName) {
						case AxisName.leftx:
							this.axis = Vec2(value, this.axis.y);
							break;
						case AxisName.lefty:
							this.axis = Vec2(this.axis.x, value);
							break;
					}
					break;
				}
				case JoyStickType.Right: {
					switch (axisName) {
						case AxisName.rightx:
							this.axis = Vec2(value, this.axis.y);
							break;
						case AxisName.righty:
							this.axis = Vec2(this.axis.x, value);
							break;
					}
					break;
				}
			}
			this.value = this.axis;
			if (this.filterAxis()) {
				this.state = TriggerState.Completed;
			} else {
				this.state = TriggerState.None;
			}
			if (this.onChange) {
				this.onChange();
			}
		};
	}
	filterAxis() {
		return true;
	}
	start(manager: Node.Type) {
		this.state = TriggerState.None;
		this.value = Vec2.zero;
		manager.slot(Slot.Axis, this.onAxis);
	}
	stop(manager: Node.Type) {
		this.state = TriggerState.None;
		this.value = Vec2.zero;
		manager.slot(Slot.Axis).remove(this.onAxis);
	}
}

class JoyStickThresholdTrigger extends JoyStickTrigger {
	private threshold: number;

	constructor(joyStickType: JoyStickType, threshold: number, controllerId: number) {
		super(joyStickType, controllerId);
		this.threshold = threshold;
	}
	override filterAxis() {
		return this.axis.length > this.threshold;
	}
}

class JoyStickDirectionalTrigger extends JoyStickTrigger {
	private direction: number;
	private tolerance: number;

	constructor(joyStickType: JoyStickType, angle: number, tolerance: number, controllerId: number) {
		super(joyStickType, controllerId);
		this.direction = angle;
		this.tolerance = tolerance;
	}
	override filterAxis() {
		const currentAngle = -math.deg(math.atan(this.axis.y, this.axis.x));
		return math.abs(currentAngle - this.direction) <= this.tolerance;
	}
}

class JoyStickRangeTrigger extends JoyStickTrigger {
	private minRange: number;
	private maxRange: number;

	constructor(joyStickType: JoyStickType, minRange: number, maxRange: number, controllerId: number) {
		super(joyStickType, controllerId);
		this.minRange = math.min(minRange, maxRange);
		this.maxRange = math.max(minRange, maxRange);
	}
	override filterAxis() {
		const magnitude = this.axis.length;
		return magnitude >= this.minRange && magnitude <= this.maxRange;
	}
}

class SequenceTrigger extends Trigger {
	private triggers: Trigger[];

	constructor(triggers: Trigger[]) {
		super();
		this.triggers = triggers;
		const self = this;
		const onStateChanged = () => {
			self.onStateChanged();
		};
		for (let trigger of triggers) {
			trigger.onChange = onStateChanged;
		}
	}
	private onStateChanged() {
		let completed = true;
		for (let trigger of this.triggers) {
			if (trigger.state !== TriggerState.Completed) {
				completed = false;
				break;
			}
		}
		if (completed) {
			this.state = TriggerState.Completed;
			let newValue: (number | Vec2.Type | boolean)[] = [];
			for (let trigger of this.triggers) {
				if (typeof trigger.value === 'object') {
					if (type(trigger.value) === 'userdata') {
						newValue.push(trigger.value as Vec2.Type);
					} else {
						newValue = newValue.concat(trigger.value);
					}
				} else {
					newValue.push(trigger.value);
				}
			}
			this.value = newValue;
			this.progress = 1;
			if (this.onChange) {
				this.onChange();
			}
			return;
		}
		let onGoing = false;
		let minProgress = -1;
		for (let trigger of this.triggers) {
			if (trigger.state === TriggerState.Ongoing) {
				minProgress = minProgress < 0 ? trigger.progress : math.min(minProgress, trigger.progress);
				onGoing = true;
			}
		}
		if (onGoing) {
			this.state = TriggerState.Ongoing;
			this.progress = minProgress;
			if (this.onChange) {
				this.onChange();
			}
			return;
		}
		for (let trigger of this.triggers) {
			if (trigger.state === TriggerState.Started) {
				this.state = TriggerState.Started;
				this.progress = 0;
				if (this.onChange) {
					this.onChange();
				}
				return;
			}
		}
		let canceled = false;
		for (let trigger of this.triggers) {
			if (trigger.state === TriggerState.Canceled) {
				canceled = true;
				break;
			}
		}
		if (canceled) {
			this.state = TriggerState.Canceled;
			this.progress = 0;
			if (this.onChange) {
				this.onChange();
			}
			return;
		}
		this.state = TriggerState.None;
		this.progress = 0;
		if (this.onChange) {
			this.onChange();
		}
	}
	start(manager: Node.Type) {
		for (let trigger of this.triggers) {
			trigger.start(manager);
		}
	}
	onUpdate(deltaTime: number) {
		for (let trigger of this.triggers) {
			if (trigger.onUpdate) {
				trigger.onUpdate(deltaTime);
			}
		}
	}
	stop(manager: Node.Type) {
		for (let trigger of this.triggers) {
			trigger.stop(manager);
		}
	}
}

class SelectorTrigger extends Trigger {
	private triggers: Trigger[];

	constructor(triggers: Trigger[]) {
		super();
		this.triggers = triggers;
		const self = this;
		const onStateChanged = () => {
			self.onStateChanged();
		};
		for (let trigger of triggers) {
			trigger.onChange = onStateChanged;
		}
	}
	private onStateChanged() {
		for (let trigger of this.triggers) {
			if (trigger.state === TriggerState.Completed) {
				this.state = TriggerState.Completed;
				this.progress = trigger.progress;
				this.value = trigger.value;
				if (this.onChange) {
					this.onChange();
				}
				return;
			}
		}
		let onGoing = false;
		let maxProgress = 0;
		for (let trigger of this.triggers) {
			if (trigger.state === TriggerState.Ongoing) {
				maxProgress = math.max(maxProgress, trigger.progress);
				onGoing = true;
			}
		}
		if (onGoing) {
			this.state = TriggerState.Ongoing;
			this.progress = maxProgress;
			if (this.onChange) {
				this.onChange();
			}
			return;
		}
		for (let trigger of this.triggers) {
			if (trigger.state === TriggerState.Started) {
				this.state = TriggerState.Started;
				this.progress = 0;
				if (this.onChange) {
					this.onChange();
				}
				return;
			}
		}
		let canceled = false;
		for (let trigger of this.triggers) {
			if (trigger.state === TriggerState.Canceled) {
				canceled = true;
				break;
			}
		}
		if (canceled) {
			this.state = TriggerState.Canceled;
			this.progress = 0;
			if (this.onChange) {
				this.onChange();
			}
		}
	}
	start(manager: Node.Type) {
		for (let trigger of this.triggers) {
			trigger.start(manager);
		}
	}
	onUpdate(deltaTime: number) {
		for (let trigger of this.triggers) {
			if (trigger.onUpdate) {
				trigger.onUpdate(deltaTime);
			}
		}
	}
	stop(manager: Node.Type) {
		for (let trigger of this.triggers) {
			trigger.stop(manager);
		}
	}
}

class BlockTrigger extends Trigger {
	private trigger: Trigger;
	
	constructor(trigger: Trigger) {
		super();
		this.trigger = trigger;
		const self = this;
		trigger.onChange = () => {
			self.onStateChanged();
		};
	}
	private onStateChanged() {
		if (this.trigger.state === TriggerState.Completed) {
			this.state = TriggerState.Canceled;
		} else {
			this.state = TriggerState.Completed;
		}
		if (this.onChange) {
			this.onChange();
		}
	}
	start(manager: Node.Type) {
		this.state = TriggerState.Completed;
		this.trigger.start(manager);
	}
	onUpdate(deltaTime: number) {
		if (this.trigger.onUpdate) {
			this.trigger.onUpdate(deltaTime);
		}
	}
	stop(manager: Node.Type) {
		this.state = TriggerState.Completed;
		this.trigger.stop(manager);
	}
}

export namespace Trigger {
	export function KeyDown(this: void, combineKeys: KeyName | KeyName[]) {
		if (typeof combineKeys === 'string') {
			combineKeys = [combineKeys];
		}
		return new KeyDownTrigger(combineKeys);
	}
	export function KeyUp(this: void, combineKeys: KeyName | KeyName[]) {
		if (typeof combineKeys === 'string') {
			combineKeys = [combineKeys];
		}
		return new KeyUpTrigger(combineKeys);
	}
	export function KeyPressed(this: void, combineKeys: KeyName | KeyName[]) {
		if (typeof combineKeys === 'string') {
			combineKeys = [combineKeys];
		}
		return new KeyPressedTrigger(combineKeys);
	}
	export function KeyHold(this: void, keyName: KeyName, holdTime: number) {
		return new KeyHoldTrigger(keyName, holdTime);
	}
	export function KeyTimed(this: void, keyName: KeyName, timeWindow: number) {
		return new KeyTimedTrigger(keyName, timeWindow);
	}
	export function ButtonDown(this: void, combineButtons: ButtonName | ButtonName[], controllerId?: number) {
		if (typeof combineButtons === 'string') {
			combineButtons = [combineButtons];
		}
		return new ButtonDownTrigger(combineButtons, controllerId ?? 0);
	}
	export function ButtonUp(this: void, combineButtons: ButtonName | ButtonName[], controllerId?: number) {
		if (typeof combineButtons === 'string') {
			combineButtons = [combineButtons];
		}
		return new ButtonUpTrigger(combineButtons, controllerId ?? 0);
	}
	export function ButtonPressed(this: void, combineButtons: ButtonName | ButtonName[], controllerId?: number) {
		if (typeof combineButtons === 'string') {
			combineButtons = [combineButtons];
		}
		return new ButtonPressedTrigger(combineButtons, controllerId ?? 0);
	}
	export function ButtonHold(this: void, buttonName: ButtonName, holdTime: number, controllerId?: number) {
		return new ButtonHoldTrigger(buttonName, holdTime, controllerId ?? 0);
	}
	export function ButtonTimed(this: void, buttonName: ButtonName, timeWindow: number, controllerId?: number) {
		return new ButtonTimedTrigger(buttonName, timeWindow, controllerId ?? 0);
	}
	export function JoyStick(this: void, joyStickType: JoyStickType, controllerId?: number) {
		return new JoyStickTrigger(joyStickType, controllerId ?? 0);
	}
	export function JoyStickThreshold(this: void, joyStickType: JoyStickType, threshold: number, controllerId?: number) {
		return new JoyStickThresholdTrigger(joyStickType, threshold, controllerId ?? 0);
	}
	export function JoyStickDirectional(this: void, joyStickType: JoyStickType, angle: number, tolerance: number, controllerId?: number) {
		return new JoyStickDirectionalTrigger(joyStickType, angle, tolerance, controllerId ?? 0);
	}
	export function JoyStickRange(this: void, joyStickType: JoyStickType, minRange: number, maxRange: number, controllerId?: number) {
		return new JoyStickRangeTrigger(joyStickType, minRange, maxRange, controllerId ?? 0);
	}
	export function Sequence(this: void, triggers: Trigger[]) {
		return new SequenceTrigger(triggers);
	}
	export function Selector(this: void, triggers: Trigger[]) {
		return new SelectorTrigger(triggers);
	}
	export function Block(this: void, trigger: Trigger) {
		return new BlockTrigger(trigger);
	}
}

export interface InputAction {
	name: string;
	trigger: Trigger;
}

export interface InputContext {
	name: string;
	actions: InputAction[];
}

class InputManager {
	private manager: Node.Type;
	private contextMap: Map<string, InputAction[]>;
	private contextStack: string[][];

	constructor(contexts: InputContext[]) {
		this.manager = Node();
		this.contextMap = new Map(contexts.map(ctx => {
			for (let action of ctx.actions) {
				const eventName = `Input.${action.name}`;
				action.trigger.onChange = () => {
					const {state, progress, value} = action.trigger;
					emit(eventName, state, progress, value);
				};
			}
			return [ctx.name, ctx.actions];
		}));
		this.contextStack = [];
		if (this.contextMap.has("Default")) {
			this.pushContext(["Default"]);
		}
		this.manager.schedule((deltaTime) => {
			if (this.contextStack.length > 0) {
				const lastNames = this.contextStack[this.contextStack.length - 1];
				for (let name of lastNames) {
					const actions = this.contextMap.get(name);
					if (actions === undefined) {
						continue;
					}
					for (let action of actions) {
						if (action.trigger.onUpdate) {
							action.trigger.onUpdate(deltaTime);
						}
					}
				}
			}
			return false;
		})
	}

	getNode() {
		return this.manager;
	}

	pushContext(contextNames: string[]): boolean {
		let exist = true;
		for (let name of contextNames) {
			exist &&= this.contextMap.has(name);
		}
		if (!exist) {
			print(`[Dora Error] got non-existed context name from ${contextNames.join(', ')}`);
			return false;
		} else {
			if (this.contextStack.length > 0) {
				const lastNames = this.contextStack[this.contextStack.length - 1];
				for (let name of lastNames) {
					const actions = this.contextMap.get(name);
					if (actions === undefined) {
						continue;
					}
					for (let action of actions) {
						action.trigger.stop(this.manager);
					}
				}
			}
			this.contextStack.push(contextNames);
			for (let name of contextNames) {
				const actions = this.contextMap.get(name);
				if (actions === undefined) {
					continue;
				}
				for (let action of actions) {
					action.trigger.start(this.manager);
				}
			}
			return true;
		}
	}

	popContext(): boolean {
		if (this.contextStack.length === 0) {
			return false;
		}
		const lastNames = this.contextStack[this.contextStack.length - 1];
		for (let name of lastNames) {
			const actions = this.contextMap.get(name);
			if (actions === undefined) {
				continue;
			}
			for (let action of actions) {
				action.trigger.stop(this.manager);
			}
		}
		this.contextStack.pop();
		if (this.contextStack.length > 0) {
			const lastNames = this.contextStack[this.contextStack.length - 1];
			for (let name of lastNames) {
				const actions = this.contextMap.get(name);
				if (actions === undefined) {
					continue;
				}
				for (let action of actions) {
					action.trigger.start(this.manager);
				}
			}
		}
		return true;
	}

	emitKeyDown(keyName: KeyName) {
		this.manager.emit(Slot.KeyDown, keyName);
	}

	emitKeyUp(keyName: KeyName) {
		this.manager.emit(Slot.KeyUp, keyName);
	}

	emitButtonDown(buttonName: ButtonName, controllerId?: number) {
		this.manager.emit(Slot.ButtonDown, controllerId ?? 0, buttonName);
	}

	emitButtonUp(buttonName: ButtonName, controllerId?: number) {
		this.manager.emit(Slot.ButtonUp, controllerId ?? 0, buttonName);
	}

	emitAxis(axisName: AxisName, value: number, controllerId?: number) {
		this.manager.emit(Slot.Axis, controllerId ?? 0, axisName, value);
	}
}

export function CreateInputManager(this: void, contexts: InputContext[]) {
	return new InputManager(contexts);
}

export interface DPadProps {
	width?: number;
	height?: number;
	offset?: number;
	inputManager: InputManager;
	color?: number;
	primaryOpacity?: number;
}

export function DPad(props: DPadProps) {
	const {
		width = 40,
		height = 40,
		offset = 5,
		color = 0xffffffff,
		primaryOpacity = 0.3,
	} = props;
	const halfSize = height + width / 2 + offset;
	const dOffset = height / 2 + width / 2 + offset;

	function DPadButton(props: JSX.Node) {
		const hw = width / 2;
		const drawNode = useRef<DrawNode.Type>();
		return (
			<node {...props} width={width} height={height}
				onTapBegan={() => {
					if (drawNode.current) {
						drawNode.current.opacity = 1;
					}
				}}
				onTapEnded={() => {
					if (drawNode.current) {
						drawNode.current.opacity = primaryOpacity;
					}
				}}
			>
				<draw-node ref={drawNode} y={-hw} x={hw} opacity={primaryOpacity}>
					<polygon-shape verts={[
						Vec2(-hw, hw + height),
						Vec2(hw, hw + height),
						Vec2(hw, hw),
						Vec2.zero,
						Vec2(-hw, hw)
					]} fillColor={color}/>
				</draw-node>
			</node>
		);
	}

	function onMount(this: void, buttonName: ButtonName) {
		return function(this: void, node: Node.Type) {
			node.slot(Slot.TapBegan, () => props.inputManager.emitButtonDown(buttonName));
			node.slot(Slot.TapEnded, () => props.inputManager.emitButtonUp(buttonName));
		};
	}

	return (
		<align-node style={{width: halfSize * 2, height: halfSize * 2}}>
			<menu x={halfSize} y={halfSize} width={halfSize * 2} height={halfSize * 2}>
				<DPadButton x={halfSize} y={dOffset + halfSize} onMount={onMount(ButtonName.dpup)}/>
				<DPadButton x={halfSize} y={-dOffset + halfSize} angle={180} onMount={onMount(ButtonName.dpdown)}/>
				<DPadButton x={dOffset + halfSize} y={halfSize} angle={90} onMount={onMount(ButtonName.dpright)}/>
				<DPadButton x={-dOffset + halfSize} y={halfSize} angle={-90} onMount={onMount(ButtonName.dpleft)}/>
			</menu>
		</align-node>
	);
}

export interface JoyStickProps {
	stickType?: JoyStickType;
	moveSize?: number;
	hatSize?: number;
	inputManager: InputManager;
	color?: number;
	primaryOpacity?: number;
	secondaryOpacity?: number;
}

export function JoyStick(props: JoyStickProps) {
	const hat = useRef<DrawNode.Type>();
	const {
		moveSize = 70,
		hatSize = 40,
		stickType = JoyStickType.Left,
		color = 0xffffffff,
		primaryOpacity = 0.3,
		secondaryOpacity = 0.1,
	} = props;
	const visualBound = math.max(moveSize - hatSize, 0);

	function updatePosition(this: void, node: DrawNode.Type, location: Vec2.Type) {
		if (location.length > visualBound) {
			node.position = location.normalize().mul(visualBound);
		} else {
			node.position = location;
		}
		switch (stickType) {
			case JoyStickType.Left:
				props.inputManager.emitAxis(AxisName.leftx, node.x / visualBound);
				props.inputManager.emitAxis(AxisName.lefty, node.y / visualBound);
				break;
			case JoyStickType.Right:
				props.inputManager.emitAxis(AxisName.rightx, node.x / visualBound);
				props.inputManager.emitAxis(AxisName.righty, node.y / visualBound);
				break;
		}
	}

	return (
		<align-node style={{width: moveSize * 2, height: moveSize * 2}}>
			<node x={moveSize} y={moveSize}
				onTapFilter={(touch) => {
					const {location} = touch;
					if (location.length > moveSize) {
						touch.enabled = false;
					}
				}}
				onTapBegan={(touch) => {
					if (hat.current) {
						hat.current.opacity = 1;
						updatePosition(hat.current, touch.location);
					}
				}}
				onTapMoved={(touch) => {
					if (hat.current) {
						hat.current.opacity = 1;
						updatePosition(hat.current, touch.location);
					}
				}}
				onTapped={() => {
					if (hat.current) {
						hat.current.opacity = primaryOpacity;
						updatePosition(hat.current, Vec2.zero);
					}
				}}
			>
				<draw-node opacity={secondaryOpacity}>
					<dot-shape radius={moveSize} color={color}/>
				</draw-node>
				<draw-node ref={hat} opacity={primaryOpacity}>
					<dot-shape radius={hatSize} color={color}/>
				</draw-node>
			</node>
		</align-node>
	);
}

export interface ButtonPadProps {
	buttonSize?: number;
	buttonPadding?: number;
	fontName?: string;
	inputManager: InputManager;
	color?: number;
	primaryOpacity?: number;
}

export function ButtonPad(props: ButtonPadProps) {
	const {
		buttonSize = 30,
		buttonPadding = 10,
		fontName = 'sarasa-mono-sc-regular',
		color = 0xffffffff,
		primaryOpacity = 0.3,
	} = props;
	function Button(props: JSX.Node & {text: string}) {
		const drawNode = useRef<DrawNode.Type>();
		return (
			<node {...props} width={buttonSize * 2} height={buttonSize * 2}
				onTapBegan={() => {
					if (drawNode.current) {
						drawNode.current.opacity = 1;
					}
				}}
				onTapEnded={() => {
					if (drawNode.current) {
						drawNode.current.opacity = primaryOpacity;
					}
				}}
			>
				<draw-node ref={drawNode} x={buttonSize} y={buttonSize} opacity={primaryOpacity}>
					<dot-shape radius={buttonSize} color={color}/>
				</draw-node>
				<label x={buttonSize} y={buttonSize} scaleX={0.5} scaleY={0.5} color3={color} opacity={primaryOpacity + 0.2}
					fontName={fontName} fontSize={buttonSize * 2}>{props.text}</label>
			</node>
		);
	}
	const width = buttonSize * 5 + buttonPadding * 3 / 2;
	const height = buttonSize * 4 + buttonPadding;
	function onMount(this: void, buttonName: ButtonName) {
		return function(this: void, node: Node.Type) {
			node.slot(Slot.TapBegan, () => props.inputManager.emitButtonDown(buttonName));
			node.slot(Slot.TapEnded, () => props.inputManager.emitButtonUp(buttonName));
		};
	}
	return (
		<align-node style={{width, height}}>
			<node
				x={(buttonSize + buttonPadding / 2) / 2 + width / 2}
				y={buttonSize + buttonPadding / 2 + height / 2}
			>
				<Button text='B'
					x={-buttonSize * 2 - buttonPadding}
					onMount={onMount(ButtonName.b)}
				/>
				<Button text='Y' onMount={onMount(ButtonName.y)}/>
				<Button text='A'
					x={-buttonSize - buttonPadding / 2}
					y={-buttonSize * 2 - buttonPadding}
					onMount={onMount(ButtonName.a)}
				/>
				<Button text='X'
					x={buttonSize + buttonPadding / 2}
					y={-buttonSize * 2 - buttonPadding}
					onMount={onMount(ButtonName.x)}
				/>
			</node>
		</align-node>
	);
}

export interface ControlPadProps {
	buttonSize?: number;
	fontName?: string;
	inputManager: InputManager;
	color?: number;
	primaryOpacity?: number;
}

export function ControlPad(props: ControlPadProps) {
	const {
		buttonSize = 35,
		fontName = 'sarasa-mono-sc-regular',
		color = 0xffffffff,
		primaryOpacity = 0.3,
	} = props;
	function Button(props: JSX.Node & {text: string}) {
		const drawNode = useRef<DrawNode.Type>();
		return (
			<node {...props} width={buttonSize * 2} height={buttonSize}
				onTapBegan={() => {
					if (drawNode.current) {
						drawNode.current.opacity = 1;
					}
				}}
				onTapEnded={() => {
					if (drawNode.current) {
						drawNode.current.opacity = primaryOpacity;
					}
				}}
			>
				<draw-node ref={drawNode} x={buttonSize} y={buttonSize / 2} opacity={primaryOpacity}>
					<rect-shape width={buttonSize * 2} height={buttonSize} fillColor={color}/>
				</draw-node>
				<label x={buttonSize} y={buttonSize / 2} scaleX={0.5} scaleY={0.5}
					fontName={fontName}
					fontSize={math.floor(buttonSize * 1.5)} color3={color} opacity={primaryOpacity + 0.2}>{props.text}</label>
			</node>
		);
	}
	function onMount(this: void, buttonName: ButtonName) {
		return function(this: void, node: Node.Type) {
			node.slot(Slot.TapBegan, () => props.inputManager.emitButtonDown(buttonName));
			node.slot(Slot.TapEnded, () => props.inputManager.emitButtonUp(buttonName));
		};
	}
	return (
		<align-node style={{minWidth: buttonSize * 4 + 20, justifyContent: 'space-between', flexDirection: 'row'}}>
			<align-node style={{width: buttonSize * 2, height: buttonSize}}>
				<Button text='Start'
					x={buttonSize} y={buttonSize / 2}
					onMount={onMount(ButtonName.start)}
				/>
			</align-node>
			<align-node style={{width: buttonSize * 2, height: buttonSize}}>
				<Button text='Back'
					x={buttonSize} y={buttonSize / 2}
					onMount={onMount(ButtonName.back)}
				/>
			</align-node>
		</align-node>
	);
}

export interface TriggerPadProps {
	buttonSize?: number;
	fontName?: string;
	inputManager: InputManager;
	color?: number;
	primaryOpacity?: number;
}

export function TriggerPad(props: TriggerPadProps) {
	const {
		buttonSize = 35,
		fontName = 'sarasa-mono-sc-regular',
		color = 0xffffffff,
		primaryOpacity = 0.3,
	} = props;
	function Button(props: JSX.Node & {text: string}) {
		const drawNode = useRef<DrawNode.Type>();
		return (
			<node {...props} width={buttonSize * 2} height={buttonSize}
				onTapBegan={() => {
					if (drawNode.current) {
						drawNode.current.opacity = 1;
					}
				}}
				onTapEnded={() => {
					if (drawNode.current) {
						drawNode.current.opacity = primaryOpacity;
					}
				}}
			>
				<draw-node ref={drawNode} x={buttonSize} y={buttonSize / 2} opacity={primaryOpacity}>
					<rect-shape width={buttonSize * 2} height={buttonSize} fillColor={color}/>
				</draw-node>
				<label x={buttonSize} y={buttonSize / 2} scaleX={0.5} scaleY={0.5}
					fontName={fontName} fontSize={math.floor(buttonSize * 1.5)} color3={color} opacity={primaryOpacity + 0.2}>{props.text}</label>
			</node>
		);
	}
	function onMount(this: void, axisName: AxisName) {
		return function(this: void, node: Node.Type) {
			node.slot(Slot.TapBegan, () => props.inputManager.emitAxis(axisName, 1, 0));
			node.slot(Slot.TapEnded, () => props.inputManager.emitAxis(axisName, 0, 0));
		};
	}
	return (
		<align-node style={{minWidth: buttonSize * 4 + 20, justifyContent: 'space-between', flexDirection: 'row'}}>
			<align-node style={{width: buttonSize * 2, height: buttonSize}}>
				<Button text='LT'
					x={buttonSize} y={buttonSize / 2}
					onMount={onMount(AxisName.lefttrigger)}
				/>
			</align-node>
			<align-node style={{width: buttonSize * 2, height: buttonSize}}>
				<Button text='RT'
					x={buttonSize} y={buttonSize / 2}
					onMount={onMount(AxisName.righttrigger)}
				/>
			</align-node>
		</align-node>
	);
}

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

export function GamePad(props: GamePadProp) {
	const {color, primaryOpacity, secondaryOpacity, inputManager} = props;
	return (
		<align-node style={{flexDirection: 'column-reverse'}} windowRoot>
			<align-node style={{
				margin: 20,
				justifyContent: 'space-between',
				flexDirection: 'row',
				alignItems: 'flex-end'
			}}>
				<align-node style={{
					justifyContent: 'space-between',
					flexDirection: 'row',
					alignItems: 'flex-end'
				}}>
					{props.noDPad ? null :
						<DPad
							color={color}
							primaryOpacity={primaryOpacity}
							inputManager={inputManager}
						/>
					}
					{props.noLeftStick ? null : <>
						<align-node style={{width: 10}}/>
						<JoyStick
							stickType={JoyStickType.Left}
							color={color}
							primaryOpacity={primaryOpacity}
							secondaryOpacity={secondaryOpacity}
							inputManager={inputManager}
						/>
					</>}
				</align-node>
				<align-node style={{
					justifyContent: 'space-between',
					flexDirection: 'row',
					alignItems: 'flex-end'
				}}>
					{props.noRightStick ? null : <>
						<JoyStick
							stickType={JoyStickType.Right}
							color={color}
							primaryOpacity={primaryOpacity}
							inputManager={inputManager}
						/>
						<align-node style={{width: 10}}/>
					</>}
					{props.noButtonPad ? null :
						<ButtonPad
							color={color}
							primaryOpacity={primaryOpacity}
							inputManager={inputManager}
						/>
					}
				</align-node>
			</align-node>
			{props.noTriggerPad ? null :
				<align-node style={{paddingLeft: 20, paddingRight: 20, paddingTop: 20}}>
					<TriggerPad
						color={color}
						primaryOpacity={primaryOpacity}
						inputManager={inputManager}
					/>
				</align-node>
			}
			{props.noControlPad ? null :
				<align-node style={{paddingLeft: 20, paddingRight: 20}}>
					<ControlPad
						color={color}
						primaryOpacity={primaryOpacity}
						inputManager={inputManager}
					/>
				</align-node>
			}
		</align-node>
	);
}
