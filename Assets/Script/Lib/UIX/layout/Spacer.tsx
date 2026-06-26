import { React } from "DoraX";

export interface SpacerProps {
	flex?: number;
	width?: number;
	height?: number;
}

export function Spacer(this: void, props: SpacerProps): React.Element {
	return <align-node style={{ flex: props.flex ?? 1, width: props.width, height: props.height }} />;
}

