import { React } from "DoraX";
import { Button, ButtonProps } from "UIX/controls/Button";
import { getUiContext } from "UIX/context";
import { mergeStyle } from "UIX/layout/helpers";
import type { UiIcon } from "UIX/types";

export interface IconButtonProps extends ButtonProps {
	icon: UiIcon;
	label?: string;
}

export function IconButton(this: void, props: IconButtonProps): React.Element {
	const theme = getUiContext().theme;
	const size = props.size ?? "md";
	const controlSize = theme.size.control[size];
	const { children, style, ...buttonProps } = props;
	return (
		<Button
			{...buttonProps}
			icon={props.icon}
			style={mergeStyle({
				width: controlSize,
				height: controlSize,
				minWidth: controlSize,
			}, style)}
		>
			{children ?? ""}
		</Button>
	);
}
