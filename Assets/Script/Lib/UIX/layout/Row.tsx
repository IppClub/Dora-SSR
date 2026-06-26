import { React } from "DoraX";
import { Box } from "UIX/layout/Box";
import { mergeStyle } from "UIX/layout/helpers";
import type { BoxProps } from "UIX/layout/Box";

export interface RowProps extends BoxProps {
	gap?: number;
	align?: JSX.StyleAlign;
	justify?: JSX.StyleJustifyContent;
}

export function Row(this: void, props: RowProps): React.Element {
	return (
		<Box
			{...props}
			style={mergeStyle({
				flexDirection: "row",
				gap: props.gap,
				alignItems: props.align,
				justifyContent: props.justify,
			}, props.style)}
		/>
	);
}

