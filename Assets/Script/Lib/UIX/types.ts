import type * as Dora from "Dora";

export type AlignStyle = AnyTable;
export type UiSize = "sm" | "md" | "lg";
export type UiVariant = "default" | "primary" | "secondary" | "danger" | "ghost" | "glass";
export type ProgressVariant = "health" | "mana" | "shield" | "neutral" | "warm";
export type ItemQuality = "empty" | "common" | "rare" | "epic" | "legendary";
export type UiInputMode = "pointer" | "keyboard" | "controller";

export type UiIcon =
	| string
	| { kind: "sprite"; file: string }
	| { kind: "painter"; name: string };

export interface UiNodeProps {
	key?: string | number;
	ref?: { readonly current?: Dora.Node.Type };
	style?: AlignStyle;
	order?: number;
	renderOrder?: number;
	visible?: boolean;
	opacity?: number;
	disabled?: boolean;
	testId?: string;
	children?: unknown;
}

export interface Rect {
	x: number;
	y: number;
	width: number;
	height: number;
}

export interface InteractionState {
	hovered: boolean;
	pressed: boolean;
	focused: boolean;
	selected: boolean;
	disabled: boolean;
	loading: boolean;
}

export function defaultInteractionState(this: void): InteractionState {
	return {
		hovered: false,
		pressed: false,
		focused: false,
		selected: false,
		disabled: false,
		loading: false,
	};
}

export function mergeInteractionState(this: void, state?: Partial<InteractionState>): InteractionState {
	const base = defaultInteractionState();
	if (state === undefined) return base;
	base.hovered = state.hovered === true;
	base.pressed = state.pressed === true;
	base.focused = state.focused === true;
	base.selected = state.selected === true;
	base.disabled = state.disabled === true;
	base.loading = state.loading === true;
	return base;
}

export function clamp(this: void, value: number, min: number, max: number): number {
	return math.max(min, math.min(max, value));
}
