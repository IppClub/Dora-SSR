import { React } from "DoraX";
import { Button } from "UIX/controls/Button";
import { Row } from "UIX/layout/Row";
import { getUiContext } from "UIX/context";
import { mergeStyle } from "UIX/layout/helpers";
import type { UiNodeProps } from "UIX/types";

export interface TabItem {
	id: string;
	label: string;
	disabled?: boolean;
}

export interface TabsProps extends UiNodeProps {
	items: TabItem[];
	value: string;
	onValueChange?: (this: void, value: string) => void;
}

export function Tabs(this: void, props: TabsProps): React.Element {
	const theme = getUiContext().theme;
	return (
		<Row
			key={props.key}
			ref={props.ref}
			gap={theme.space.xs}
			style={mergeStyle({
				height: theme.size.control.md,
				alignItems: "center",
			}, props.style)}
			visible={props.visible}
			opacity={props.opacity}
		>
			{props.items.map(item => (
				<Button
					key={item.id}
					size="sm"
					variant={item.id === props.value ? "primary" : "ghost"}
					selected={item.id === props.value}
					disabled={props.disabled === true || item.disabled === true}
					style={{ minWidth: 72 }}
					onClick={() => {
						if (item.id !== props.value) props.onValueChange?.(item.id);
					}}
				>
					{item.label}
				</Button>
			))}
		</Row>
	);
}
