import { React } from "DoraX";
import { getUiContext } from "UIX/context";
import { Icon } from "UIX/foundation/Icon";
import { Text } from "UIX/foundation/Text";
import { Row } from "UIX/layout/Row";
import type { UiIcon, UiNodeProps } from "UIX/types";
import { mergeStyle } from "UIX/layout/helpers";

export interface ResourceCounterProps extends UiNodeProps {
	icon?: UiIcon;
	value: number | string;
	prefix?: string;
	suffix?: string;
	variant?: "default" | "warm" | "success" | "danger";
}

export function ResourceCounter(this: void, props: ResourceCounterProps): React.Element {
	const theme = getUiContext().theme;
	let color = theme.colors.text.primary;
	if (props.variant === "warm") color = theme.colors.accent.warm;
	if (props.variant === "success") color = theme.colors.state.success;
	if (props.variant === "danger") color = theme.colors.state.danger;
	const text = `${props.prefix ?? ""}${tostring(props.value)}${props.suffix ?? ""}`;
	return (
		<Row
			key={props.key}
			ref={props.ref}
			gap={theme.space.sm}
			align="center"
			style={mergeStyle({
				height: theme.size.control.sm,
				padding: [0, theme.space.sm],
			}, props.style)}
			visible={props.visible}
			opacity={props.opacity}
		>
			{props.icon !== undefined ? <Icon icon={props.icon} size={theme.size.icon.sm} color={color} /> : undefined}
			<Text text={text} color={color} fontSize={theme.font.size.md} />
		</Row>
	);
}

