import { useSignal } from "DoraX";
import type { InteractionState } from "UIX/types";

export interface InteractionController {
	state: InteractionState;
	setPressed(this: void, value: boolean): void;
	setFocused(this: void, value: boolean): void;
	reset(this: void): void;
}

export function useInteraction(this: void, options?: {
	disabled?: boolean;
	loading?: boolean;
	selected?: boolean;
}): InteractionController {
	const pressed = useSignal(false);
	const focused = useSignal(false);
	const disabled = options?.disabled === true;
	const loading = options?.loading === true;
	return {
		state: {
			hovered: false,
			pressed: pressed.value,
			focused: focused.value,
			selected: options?.selected === true,
			disabled,
			loading,
		},
		setPressed(value: boolean) {
			if (!disabled && !loading) {
				pressed.value = value;
			}
		},
		setFocused(value: boolean) {
			focused.value = value;
		},
		reset() {
			pressed.value = false;
			focused.value = false;
		},
	};
}

