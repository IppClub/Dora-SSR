import { React } from "DoraX";
import { ProgressBar, ProgressBarProps } from "UIX/controls/ProgressBar";

export interface HealthBarProps extends Omit<ProgressBarProps, "variant"> {
	dangerThreshold?: number;
	delayedValue?: number;
}

export function HealthBar(this: void, props: HealthBarProps): React.Element {
	const min = props.min ?? 0;
	const max = props.max ?? 1;
	const threshold = props.dangerThreshold ?? 0.3;
	const progress = max === min ? 0 : (props.value - min) / (max - min);
	return (
		<ProgressBar
			{...props}
			variant={progress <= threshold ? "health" : "warm"}
		/>
	);
}

