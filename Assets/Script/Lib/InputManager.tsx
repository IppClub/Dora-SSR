import { React, toNode, useRef } from 'DoraX';
import { AxisName, ButtonName, DrawNode, KeyName, Node, Slot, Touch, Vec2, emit } from 'Dora';

export const enum TriggerState {
	None = "None",
	Started = "Started",
	Ongoing = "Ongoing",
	Completed = "Completed",
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
					if (this.onChange) {
						this.onChange();
					}
					this.state = TriggerState.None;
				}
			}
		};
		this.onKeyUp = (keyName: KeyName) => {
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
	}
	stop(manager: Node.Type) {
		manager.slot(Slot.KeyDown).remove(this.onKeyDown);
		manager.slot(Slot.KeyUp).remove(this.onKeyUp);
		this.state = TriggerState.None;
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
			if (!this.keyStates.has(keyName)) {
				return;
			}
			this.keyStates.set(keyName, true);
		};
		this.onKeyUp = (keyName: KeyName) => {
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
					if (this.onChange) {
						this.onChange();
					}
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
	}
	stop(manager: Node.Type) {
		manager.slot(Slot.KeyDown).remove(this.onKeyDown);
		manager.slot(Slot.KeyUp).remove(this.onKeyUp);
		this.state = TriggerState.None;
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
			let allDown = true;
			for (let [, down] of this.keyStates) {
				allDown &&= down;
			}
			if (allDown) {
				this.state = TriggerState.Completed;
			}
		};
		this.onKeyUp = (keyName: KeyName) => {
			if (!this.keyStates.has(keyName)) {
				return;
			}
			this.keyStates.set(keyName, false);
			let allDown = true;
			for (let [, down] of this.keyStates) {
				allDown &&= down;
			}
			if (!allDown) {
				this.state = TriggerState.None;
			}
		};
	}
	onUpdate(_: number) {
		if (this.state === TriggerState.Completed) {
			if (this.onChange) {
				this.onChange();
			}
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
	}
	stop(manager: Node.Type) {
		manager.slot(Slot.KeyDown).remove(this.onKeyDown);
		manager.slot(Slot.KeyUp).remove(this.onKeyUp);
		this.state = TriggerState.None;
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
		this.time = 0;
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

class KeyDoubleDownTrigger extends Trigger {
	private key: KeyName;
	private threshold: number;
	private time: number;
	private onKeyDown: (this: void, keyName: KeyName) => void;

	constructor(key: KeyName, threshold: number) {
		super();
		this.key = key;
		this.threshold = threshold;
		this.time = 0;
		this.onKeyDown = (keyName: KeyName) => {
			if (this.key === keyName) {
				if (this.state === TriggerState.None) {
					this.time = 0;
					this.state = TriggerState.Started;
					this.progress = 0;
					if (this.onChange) {
						this.onChange();
					}
				} else {
					this.state = TriggerState.Completed;
					if (this.onChange) {
						this.onChange();
					}
					this.state = TriggerState.None;
				}
			}
		};
	}
	start(manager: Node.Type) {
		manager.keyboardEnabled = true;
		manager.slot(Slot.KeyDown, this.onKeyDown);
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
		if (this.time >= this.threshold) {
			this.state = TriggerState.None;
			this.progress = 1;
		} else {
			this.state = TriggerState.Ongoing;
			this.progress = math.min(this.time / this.threshold, 1);
		}
		if (this.onChange) {
			this.onChange();
		}
	}
	stop(manager: Node.Type) {
		manager.slot(Slot.KeyDown).remove(this.onKeyDown);
		this.state = TriggerState.None;
		this.progress = 0;
	}
}

class AnyKeyPressedTrigger extends Trigger {
	private onKeyDown: (this: void, keyName: KeyName) => void;
	private onKeyUp: (this: void, keyName: KeyName) => void;
	private keyStates: LuaTable<KeyName, boolean>;

	constructor() {
		super();
		this.keyStates = new LuaTable;
		this.onKeyDown = (keyName: KeyName) => {
			this.keyStates.set(keyName, true);
			this.state = TriggerState.Completed;
		};
		this.onKeyUp = (keyName: KeyName) => {
			this.keyStates.set(keyName, false);
			let down = false;
			for (let [, state] of this.keyStates) {
				down ||= state;
			}
			if (!down) {
				this.state = TriggerState.None;
			}
		};
	}
	onUpdate(_: number) {
		if (this.state === TriggerState.Completed) {
			if (this.onChange) {
				this.onChange();
			}
		}
	}
	start(manager: Node.Type) {
		manager.keyboardEnabled = true;
		manager.slot(Slot.KeyDown, this.onKeyDown);
		manager.slot(Slot.KeyUp, this.onKeyUp);
		this.state = TriggerState.None;
	}
	stop(manager: Node.Type) {
		manager.slot(Slot.KeyDown).remove(this.onKeyDown);
		manager.slot(Slot.KeyUp, this.onKeyUp);
		this.state = TriggerState.None;
		this.keyStates = new LuaTable;
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
					if (this.onChange) {
						this.onChange();
					}
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
	}
	stop(manager: Node.Type) {
		manager.slot(Slot.ButtonDown).remove(this.onButtonDown);
		manager.slot(Slot.ButtonUp).remove(this.onButtonUp);
		this.state = TriggerState.None;
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
			let oldState = true;
			for (let [, state] of this.buttonStates) {
				oldState &&= state;
			}
			this.buttonStates.set(buttonName, false);
			if (oldState) {
					this.state = TriggerState.Completed;
					if (this.onChange) {
						this.onChange();
					}
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
	}
	stop(manager: Node.Type) {
		manager.slot(Slot.ButtonDown).remove(this.onButtonDown);
		manager.slot(Slot.ButtonUp).remove(this.onButtonUp);
		this.state = TriggerState.None;
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
			let allDown = true;
			for (let [, down] of this.buttonStates) {
				allDown &&= down;
			}
			if (allDown) {
				this.state = TriggerState.Completed;
			}
		};
		this.onButtonUp = (controllerId: number, buttonName: ButtonName) => {
			if (this.controllerId !== controllerId) {
				return;
			}
			if (!this.buttonStates.has(buttonName)) {
				return;
			}
			this.buttonStates.set(buttonName, false);
			this.state = TriggerState.None;
		};
	}
	onUpdate(_: number) {
		let allDown = true;
		for (let [, down] of this.buttonStates) {
			allDown &&= down;
		}
		if (allDown) {
			this.state = TriggerState.Completed;
			if (this.onChange) {
				this.onChange();
			}
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
	}
	stop(manager: Node.Type) {
		manager.slot(Slot.ButtonDown).remove(this.onButtonDown);
		manager.slot(Slot.ButtonUp).remove(this.onButtonUp);
		this.state = TriggerState.None;
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
		this.time = 0;
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

class ButtonDoubleDownTrigger extends Trigger {
	private controllerId: number;
	private button: ButtonName;
	private threshold: number;
	private time: number;
	private onButtonDown: (this: void, controllerId: number, buttonName: ButtonName) => void;

	constructor(button: ButtonName, threshold: number, controllerId: number) {
		super();
		this.controllerId = controllerId;
		this.button = button;
		this.threshold = threshold;
		this.time = 0;
		this.onButtonDown = (controllerId: number, buttonName: ButtonName) => {
			if (this.controllerId !== controllerId) {
				return;
			}
			if (this.button === buttonName) {
				if (this.state === TriggerState.None) {
					this.time = 0;
					this.state = TriggerState.Started;
					this.progress = 0;
					if (this.onChange) {
						this.onChange();
					}
				} else {
					this.state = TriggerState.Completed;
					if (this.onChange) {
						this.onChange();
					}
					this.state = TriggerState.None;
				}
			}
		};
	}
	start(manager: Node.Type) {
		manager.controllerEnabled = true;
		manager.slot(Slot.ButtonDown, this.onButtonDown);
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
		if (this.time >= this.threshold) {
			this.state = TriggerState.None;
			this.progress = 1;
		} else {
			this.state = TriggerState.Ongoing;
			this.progress = math.min(this.time / this.threshold, 1);
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

class AnyButtonPressedTrigger extends Trigger {
	private controllerId: number;
	private onButtonDown: (this: void, controllerId: number, buttonName: ButtonName) => void;
	private onButtonUp: (this: void, controllerId: number, buttonName: ButtonName) => void;
	private buttonStates: LuaTable<ButtonName, boolean>;

	constructor(controllerId: number) {
		super();
		this.controllerId = controllerId;
		this.buttonStates = new LuaTable;
		this.onButtonDown = (controllerId: number, buttonName: ButtonName) => {
			if (this.controllerId !== controllerId) {
				return;
			}
			this.buttonStates.set(buttonName, true);
			this.state = TriggerState.Completed;
		};
		this.onButtonUp = (controllerId: number, buttonName: ButtonName) => {
			if (this.controllerId !== controllerId) {
				return;
			}
			this.buttonStates.set(buttonName, false);
			let down = false;
			for (let [, state] of this.buttonStates) {
				down ||= state;
			}
			if (!down) {
				this.state = TriggerState.None;
			}
		};
	}
	onUpdate(_: number) {
		if (this.state === TriggerState.Completed) {
			if (this.onChange) {
				this.onChange();
			}
		}
	}
	start(manager: Node.Type) {
		manager.keyboardEnabled = true;
		manager.slot(Slot.ButtonDown, this.onButtonDown);
		manager.slot(Slot.ButtonUp, this.onButtonUp);
		this.state = TriggerState.None;
	}
	stop(manager: Node.Type) {
		manager.slot(Slot.ButtonDown).remove(this.onButtonDown);
		manager.slot(Slot.ButtonUp, this.onButtonUp);
		this.state = TriggerState.None;
		this.buttonStates = new LuaTable;
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
						case AxisName.LeftX:
							this.axis = Vec2(value, this.axis.y);
							break;
						case AxisName.LeftY:
							this.axis = Vec2(this.axis.x, value);
							break;
					}
					break;
				}
				case JoyStickType.Right: {
					switch (axisName) {
						case AxisName.RightX:
							this.axis = Vec2(value, this.axis.y);
							break;
						case AxisName.RightY:
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
			if (this.onChange) {
				this.onChange();
			}
			return;
		}
		let canceled = false;
		for (let trigger of this.triggers) {
			this.progress = math.max(trigger.progress, this.progress);
			if (trigger.state === TriggerState.Canceled) {
				canceled = true;
				break;
			}
		}
		if (canceled) {
			this.state = TriggerState.Canceled;
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
		this.state = TriggerState.None;
		if (this.onChange) {
			this.onChange();
		}
	}
	start(manager: Node.Type) {
		for (let trigger of this.triggers) {
			trigger.start(manager);
		}
		this.state = TriggerState.None;
		this.progress = 0;
		this.value = false;
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
		this.state = TriggerState.None;
		this.progress = 0;
		this.value = false;
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
			this.progress = math.max(trigger.progress, this.progress);
			if (trigger.state === TriggerState.Canceled) {
				canceled = true;
				break;
			}
		}
		if (canceled) {
			this.state = TriggerState.Canceled;
			if (this.onChange) {
				this.onChange();
			}
		}
	}
	start(manager: Node.Type) {
		for (let trigger of this.triggers) {
			trigger.start(manager);
		}
		this.state = TriggerState.None;
		this.progress = 0;
		this.value = false;
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
		this.state = TriggerState.None;
		this.progress = 0;
		this.value = false;
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
		this.state = TriggerState.Completed;
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
	export function KeyDoubleDown(this: void, key: KeyName, threshold?: number) {
		return new KeyDoubleDownTrigger(key, threshold ?? 0.3);
	}
	export function AnyKeyPressed(this: void) {
		return new AnyKeyPressedTrigger();
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
	export function ButtonDoubleDown(this: void, button: ButtonName, threshold?: number, controllerId?: number) {
		return new ButtonDoubleDownTrigger(button, threshold ?? 0.3, controllerId ?? 0);
	}
	export function AnyButtonPressed(this: void, controllerId?: number) {
		return new AnyButtonPressedTrigger(controllerId ?? 0);
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

class InputManager {
	private manager: Node.Type;
	private contextMap: Map<string, InputAction[]>;
	private contextStack: string[][];

	constructor(contexts: {[contextName: string]: {[actionName: string]: Trigger}}) {
		this.manager = Node();
		this.contextMap = new Map();
		for (let [contextName, actionMap] of pairs(contexts)) {
			let actions: InputAction[] = [];
			for (let [actionName, trigger] of pairs(actionMap)) {
				const name = actionName as string;
				const eventName = `Input.${name}`;
				trigger.onChange = () => {
					const {state, progress, value} = trigger;
					emit(eventName, state, progress, value);
				};
				actions.push({name, trigger});
			}
			this.contextMap.set(contextName as string, actions);
		}
		this.contextStack = [];
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

	getNode(): Node.Type {
		return this.manager;
	}

	pushContext(contextNames: string | string[]): boolean {
		if (typeof contextNames === 'string') {
			contextNames = [contextNames];
		}
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

	popContext(count?: number): boolean {
		count ??= 1;
		if (this.contextStack.length < count) {
			return false;
		}
		for (let i of $range(1, count)) {
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

	destroy() {
		this.getNode().removeFromParent();
		this.contextStack = [];
	}
}

export function CreateManager(this: void, contexts: {[contextName: string]: {[actionName: string]: Trigger}}): InputManager {
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

	const up = useRef<Node.Type>();
	const down = useRef<Node.Type>();
	const left = useRef<Node.Type>();
	const right = useRef<Node.Type>();
	const center = useRef<Node.Type>();

	let current: Node.Type | null = null;

	const clearButton = () => {
		if (current) {
			current.emit("TapEnded");
			current = null;
		}
	};

	const changeToButton = (node: Node.Type) => {
		if (current !== node) {
			clearButton();
			current = node;
			current.emit("TapBegan");
		}
	};

	const touchForButton = (touch: Touch.Type) => {
		if (!up.current || !down.current || !left.current || !right.current || !center.current) return;
		const menu = up.current.parent;
		if (!menu) return;
		const wp = menu.convertToWorldSpace(touch.location);
		let {x, y} = center.current.convertToNodeSpace(wp);
		const hw = (width + offset * 2) / 2;
		x -= hw; y -= hw;
		const angle = math.deg(math.atan(y, x));
		if (45 <= angle && angle < 145) {
			changeToButton(up.current);
		} else if (-45 <= angle && angle < 45) {
			changeToButton(right.current);
		} else if (-145 <= angle && angle < -45) {
			changeToButton(down.current);
		} else {
			changeToButton(left.current);
		}
	};

	return (
		<align-node style={{width: halfSize * 2, height: halfSize * 2}}>
			<menu x={halfSize} y={halfSize} width={halfSize * 2} height={halfSize * 2}>
				<DPadButton ref={up} x={halfSize} y={dOffset + halfSize} onMount={onMount(ButtonName.Up)}/>
				<DPadButton ref={down} x={halfSize} y={-dOffset + halfSize} angle={180} onMount={onMount(ButtonName.Down)}/>
				<DPadButton ref={right} x={dOffset + halfSize} y={halfSize} angle={90} onMount={onMount(ButtonName.Right)}/>
				<DPadButton ref={left} x={-dOffset + halfSize} y={halfSize} angle={-90} onMount={onMount(ButtonName.Left)}/>
				<node ref={center} x={halfSize} y={halfSize} width={width + offset * 2} height={width + offset * 2}
					onTapBegan={touch => touchForButton(touch)}
					onTapMoved={touch => touchForButton(touch)}
					onTapEnded={() => clearButton()}
				/>
			</menu>
		</align-node>
	);
}

export function CreateDPad(this: void, props: DPadProps): Node.Type {
	return toNode(
		<DPad {...props}/>
	) as Node.Type;
}

interface ButtonProps {
	x?: number;
	y?: number;
	onMount?: (this: void, node: Node.Type) => void;
	text: string;
	fontName?: string;
	buttonSize: number;
	color?: number;
	primaryOpacity?: number;
}

function Button(props: ButtonProps) {
	const {
		x, y, onMount,
		text,
		fontName = 'sarasa-mono-sc-regular',
		buttonSize,
		color = 0xffffffff,
		primaryOpacity = 0.3
	} = props;
	const drawNode = useRef<DrawNode.Type>();
	return (
		<node x={x} y={y} onMount={onMount} width={buttonSize * 2} height={buttonSize * 2}
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
				fontName={fontName} fontSize={buttonSize * 2}>{text}</label>
		</node>
	);
}

export interface JoyStickProps {
	stickType?: JoyStickType;
	moveSize?: number;
	hatSize?: number;
	fontName?: string;
	buttonSize?: number;
	inputManager: InputManager;
	color?: number;
	primaryOpacity?: number;
	secondaryOpacity?: number;
	noStickButton?: boolean;
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
		fontName = 'sarasa-mono-sc-regular',
		buttonSize = 20,
	} = props;
	const visualBound = math.max(moveSize - hatSize, 0);
	const stickButton = stickType === JoyStickType.Left ? ButtonName.LeftStick : ButtonName.RightStick;

	function updatePosition(this: void, node: DrawNode.Type, location: Vec2.Type) {
		if (location.length > visualBound) {
			node.position = location.normalize().mul(visualBound);
		} else {
			node.position = location;
		}
		switch (stickType) {
			case JoyStickType.Left:
				props.inputManager.emitAxis(AxisName.LeftX, node.x / visualBound);
				props.inputManager.emitAxis(AxisName.LeftY, node.y / visualBound);
				break;
			case JoyStickType.Right:
				props.inputManager.emitAxis(AxisName.RightX, node.x / visualBound);
				props.inputManager.emitAxis(AxisName.RightY, node.y / visualBound);
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
			{props.noStickButton ? null :
				<Button
					buttonSize={buttonSize}
					x={moveSize}
					y={moveSize * 2 + buttonSize / 2 + 20}
					text={stickType === JoyStickType.Left? "LS" : "RS"}
					fontName={fontName}
					color={color}
					primaryOpacity={primaryOpacity}
					onMount={(node) => {
						node.slot(Slot.TapBegan, () => props.inputManager.emitButtonDown(stickButton));
						node.slot(Slot.TapEnded, () => props.inputManager.emitButtonUp(stickButton));
					}}
				/>
			}
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
				<Button text='X' fontName={fontName}
					color={color} primaryOpacity={primaryOpacity}
					buttonSize={buttonSize}
					x={-buttonSize * 2 - buttonPadding}
					onMount={onMount(ButtonName.X)}
				/>
				<Button text='Y' fontName={fontName}
					color={color} primaryOpacity={primaryOpacity}
					buttonSize={buttonSize}
					onMount={onMount(ButtonName.Y)}/>
				<Button text='A' fontName={fontName}
					color={color} primaryOpacity={primaryOpacity}
					buttonSize={buttonSize}
					x={-buttonSize - buttonPadding / 2}
					y={-buttonSize * 2 - buttonPadding}
					onMount={onMount(ButtonName.A)}
				/>
				<Button text='B' fontName={fontName}
					color={color} primaryOpacity={primaryOpacity}
					buttonSize={buttonSize}
					x={buttonSize + buttonPadding / 2}
					y={-buttonSize * 2 - buttonPadding}
					onMount={onMount(ButtonName.B)}
				/>
			</node>
		</align-node>
	);
}

export function CreateButtonPad(this: void, props: ButtonPadProps): Node.Type {
	return toNode(
		<ButtonPad {...props}/>
	) as Node.Type;
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
					onMount={onMount(ButtonName.Start)}
				/>
			</align-node>
			<align-node style={{width: buttonSize * 2, height: buttonSize}}>
				<Button text='Back'
					x={buttonSize} y={buttonSize / 2}
					onMount={onMount(ButtonName.Back)}
				/>
			</align-node>
		</align-node>
	);
}

export function CreateControlPad(this: void, props: ControlPadProps): Node.Type {
	return toNode(
		<ControlPad {...props}/>
	) as Node.Type;
}

export interface TriggerPadProps {
	buttonSize?: number;
	fontName?: string;
	inputManager: InputManager;
	color?: number;
	primaryOpacity?: number;
	noShoulder?: boolean;
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
	function onMountAxis(this: void, axisName: AxisName) {
		return function(this: void, node: Node.Type) {
			node.slot(Slot.TapBegan, () => props.inputManager.emitAxis(axisName, 1, 0));
			node.slot(Slot.TapEnded, () => props.inputManager.emitAxis(axisName, 0, 0));
		};
	}
	function onMountButton(this: void, buttonName: ButtonName) {
		return function(this: void, node: Node.Type) {
			node.slot(Slot.TapBegan, () => props.inputManager.emitButtonDown(buttonName, 0));
			node.slot(Slot.TapEnded, () => props.inputManager.emitButtonUp(buttonName, 0));
		};
	}
	return (
		<align-node style={{minWidth: buttonSize * 4 + 20, justifyContent: 'space-between', flexDirection: 'row'}}>
			<align-node style={{width: buttonSize * 4 + 10, height: buttonSize}}>
				<Button text='LT'
					x={buttonSize} y={buttonSize / 2}
					onMount={onMountAxis(AxisName.LeftTrigger)}
				/>
				{props.noShoulder ? null :
					<Button text='LB'
						x={buttonSize * 3 + 10} y={buttonSize / 2}
						onMount={onMountButton(ButtonName.LeftShoulder)}
					/>
				}
			</align-node>
			<align-node style={{width: buttonSize * 4 + 10, height: buttonSize}}>
				{props.noShoulder ? null :
					<Button text='RB'
						x={buttonSize} y={buttonSize / 2}
						onMount={onMountButton(ButtonName.RightShoulder)}
					/>
				}
				<Button text='RT'
					x={buttonSize * 3 + 10} y={buttonSize / 2}
					onMount={onMountAxis(AxisName.RightTrigger)}
				/>
			</align-node>
		</align-node>
	);
}

export function CreateTriggerPad(this: void, props: TriggerPadProps): Node.Type {
	return toNode(
		<TriggerPad {...props}/>
	) as Node.Type;
}

export interface GamePadProps {
	noDPad?: boolean;
	noLeftStick?: boolean;
	noRightStick?: boolean;
	noButtonPad?: boolean;
	noTriggerPad?: boolean;
	noControlPad?: boolean;
	noShoulder?: boolean;
	noStickButton?: boolean;
	color?: number;
	primaryOpacity?: number;
	secondaryOpacity?: number;
	inputManager: InputManager;
}

export function GamePad(props: GamePadProps) {
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
							noStickButton={props.noStickButton}
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
							secondaryOpacity={secondaryOpacity}
							inputManager={inputManager}
							noStickButton={props.noStickButton}
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
						noShoulder={props.noShoulder}
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

export function CreateGamePad(this: void, props: GamePadProps): Node.Type {
	return toNode(
		<GamePad {...props}/>
	) as Node.Type;
}
