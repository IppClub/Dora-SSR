import { React } from "DoraX";
import type { UiNodeProps } from "UIX/types";

export interface BoxProps extends UiNodeProps {
	onLayout?: (this: void, width: number, height: number) => void;
	showDebug?: boolean;
}

export function Box(this: void, props: BoxProps): React.Element {
	return (
		<align-node
			key={props.key}
			ref={props.ref as JSX.Ref<import("Dora").AlignNode.Type> | undefined}
			style={props.style}
			visible={props.visible}
			opacity={props.opacity}
			onLayout={props.onLayout}
			showDebug={props.showDebug}
		>
			{props.children}
		</align-node>
	);
}

