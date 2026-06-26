import { React } from "DoraX";
import { Box } from "UIX/layout/Box";
import { mergeStyle } from "UIX/layout/helpers";
import type { BoxProps } from "UIX/layout/Box";

export interface StackProps extends BoxProps {
	clip?: boolean;
}

export function Stack(this: void, props: StackProps): React.Element {
	return (
		<Box
			{...props}
			style={mergeStyle({
				position: "relative",
				overflow: props.clip === true ? "hidden" : undefined,
			}, props.style)}
		/>
	);
}

