import { React } from "DoraX";
import { getUiContext } from "UIX/context";
import { Text } from "UIX/foundation/Text";
import { Column } from "UIX/layout/Column";
import { Panel } from "UIX/layout/Panel";
import type { UiNodeProps, UiVariant } from "UIX/types";
import { mergeStyle } from "UIX/layout/helpers";

export interface ToastItem {
	id: string | number;
	title?: string;
	message: string;
	variant?: UiVariant;
}

export interface ToastStackProps extends UiNodeProps {
	items: ToastItem[];
	width?: number;
	maxVisible?: number;
}

export function ToastStack(this: void, props: ToastStackProps): React.Element {
	const theme = getUiContext().theme;
	const width = props.width ?? 280;
	const maxVisible = props.maxVisible ?? 4;
	const items: ToastItem[] = [];
	for (let i of $range(1, math.min(props.items.length, maxVisible))) {
		items.push(props.items[i - 1]);
	}
	return (
		<Column
			key={props.key}
			ref={props.ref}
			gap={theme.space.sm}
			style={mergeStyle({
				position: "absolute",
				right: theme.space.lg,
				top: theme.space.lg,
				width,
			}, props.style)}
			visible={props.visible}
			opacity={props.opacity}
		>
			{items.map(item => (
				<Panel
					key={item.id}
					variant={item.variant === "glass" ? "glass" : "solid"}
					padding={theme.space.sm}
					headerHeight={0}
					style={{ width, minHeight: item.title !== undefined ? 72 : 52 }}
				>
					<Column style={{ width: "100%", gap: theme.space.xs }}>
						{item.title !== undefined ?
							<Text text={item.title} fontSize={theme.font.size.sm} color={theme.colors.text.primary} style={{ width: "100%", height: 20 }} /> : undefined}
						<Text text={item.message} fontSize={theme.font.size.sm} color={theme.colors.text.secondary} style={{ width: "100%", height: 24 }} />
					</Column>
				</Panel>
			))}
		</Column>
	);
}
