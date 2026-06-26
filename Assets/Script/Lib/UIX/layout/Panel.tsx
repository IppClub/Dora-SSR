import { React } from "DoraX";
import { getUiContext } from "UIX/context";
import { PaintNode } from "UIX/paint/PaintNode";
import { roundedPanel } from "UIX/paint/primitives";
import { Column } from "UIX/layout/Column";
import { Box } from "UIX/layout/Box";
import { ScrollView } from "UIX/layout/ScrollView";
import { Text } from "UIX/foundation/Text";
import type { UiNodeProps } from "UIX/types";
import { mergeStyle } from "UIX/layout/helpers";

export interface PanelProps extends UiNodeProps {
	title?: string;
	variant?: "default" | "glass" | "solid";
	padding?: number;
	headerHeight?: number;
	elevated?: boolean;
	scroll?: boolean;
	scrollContentHeight?: number;
	scrollWheelSpeed?: number;
	onScroll?: (this: void, offsetY: number) => void;
	onLayout?: (this: void, width: number, height: number) => void;
}

export function Panel(this: void, props: PanelProps): React.Element {
	const theme = getUiContext().theme;
	const headerHeight = props.headerHeight ?? (props.title !== undefined ? 36 : 0);
	const padding = props.padding ?? theme.space.lg;
	const panelWidth = props.style?.width as number | undefined;
	const panelHeight = props.style?.height as number | undefined;
	const contentWidth = panelWidth !== undefined ? math.max(0, panelWidth - padding * 2) : undefined;
	const contentHeight = panelHeight !== undefined
		? math.max(0, panelHeight - padding * 2 - headerHeight - (props.title !== undefined ? theme.space.sm : 0))
		: undefined;
	const scrollContentHeight = props.scrollContentHeight ?? contentHeight ?? 0;
	return (
		<Column
			key={props.key}
			ref={props.ref}
			style={mergeStyle({
				position: "relative",
				padding,
				gap: theme.space.sm,
			}, props.style)}
			visible={props.visible}
			opacity={props.opacity}
			onLayout={props.onLayout}
		>
			<PaintNode
				painter={(ctx) => roundedPanel(ctx, { x: 0, y: 0, width: ctx.width, height: ctx.height }, {
					variant: props.variant ?? "default",
					elevated: props.elevated,
				})}
			/>
			{props.title !== undefined ?
				<Box key="header" style={{ height: headerHeight, alignItems: "center", justifyContent: "center" }}>
					<Text text={props.title} fontSize={theme.font.size.lg} color={theme.colors.text.primary} />
				</Box> : undefined
			}
			{props.scroll === true && contentWidth !== undefined && contentHeight !== undefined ?
				<ScrollView
					key="content-scroll"
					width={contentWidth}
					height={contentHeight}
					contentHeight={math.max(contentHeight, scrollContentHeight)}
					wheelSpeed={props.scrollWheelSpeed}
					onScroll={props.onScroll}
					style={{ flex: 1 }}
				>
					{props.children}
				</ScrollView> :
				<Box key="content" style={{ flex: 1 }}>
					{props.children}
				</Box>
			}
		</Column>
	);
}
