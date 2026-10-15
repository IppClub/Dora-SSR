import type { ButtonName, Node } from "Dora";

export function findGamepadNode(this: void, host: Node.Type, tag: string): Node.Type | undefined;
export function selectGamepadNode(this: void, host: Node.Type, tag: string): boolean;

/** Go UI focus routing. The last visible attached screen owns controller input. */
export function attachGamepad(this: void, host: Node.Type, options: {
	initialTag?: string;
	isEnabled?(this: void): boolean;
	onBack(this: void): void;
	onButton?(this: void, button: ButtonName, controllerId: number): boolean;
	onScroll?(this: void, amount: number): void;
	onActivate?(this: void, target: Node.Type): void;
	onActive?(this: void): void;
}): void;
