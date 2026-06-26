import { React } from "DoraX";
import { doraPrismTheme, mergeTheme, PartialTheme, Theme } from "UIX/theme";
import type { UiInputMode } from "UIX/types";
import { FocusManager } from "UIX/input/FocusManager";

export interface UiContext {
	theme: Theme;
	inputMode: UiInputMode;
	focusManager: FocusManager;
	scale: number;
}

const defaultFocusManager = new FocusManager();

let currentContext: UiContext = {
	theme: doraPrismTheme,
	inputMode: "pointer",
	focusManager: defaultFocusManager,
	scale: 1,
};

export function getUiContext(this: void): UiContext {
	return currentContext;
}

export interface UiProviderProps {
	theme?: PartialTheme;
	inputMode?: UiInputMode;
	scale?: number;
	children?: unknown;
}

export function UiProvider(this: void, props: UiProviderProps): React.Element | React.Element[] {
	currentContext = {
		theme: mergeTheme(doraPrismTheme, props.theme),
		inputMode: props.inputMode ?? "pointer",
		focusManager: currentContext.focusManager,
		scale: props.scale ?? 1,
	};
	return props.children as React.Element | React.Element[];
}

export interface ThemeScopeProps {
	theme: PartialTheme;
	children?: unknown;
}

export function ThemeScope(this: void, props: ThemeScopeProps): React.Element | React.Element[] {
	const previous = currentContext;
	currentContext = {
		theme: mergeTheme(previous.theme, props.theme),
		inputMode: previous.inputMode,
		focusManager: previous.focusManager,
		scale: previous.scale,
	};
	return props.children as React.Element | React.Element[];
}
