import { TextAlign } from "Dora";
import { React } from "DoraX";
import { getUiContext } from "UIX/context";
import { Text, wrapTextLines } from "UIX/foundation/Text";
import { Column } from "UIX/layout/Column";
import { PaintNode } from "UIX/paint/PaintNode";
import { roundedPanel } from "UIX/paint/primitives";
import { mergeStyle } from "UIX/layout/helpers";
import type { UiNodeProps } from "UIX/types";

export interface TooltipProps extends UiNodeProps {
	title?: string;
	text?: string;
	width?: number;
}

export function Tooltip(this: void, props: TooltipProps): React.Element {
	const theme = getUiContext().theme;
	const width = props.width ?? 220;
	const hasTitle = props.title !== undefined && props.title !== "";
	const textFontSize = theme.font.size.sm;
	const textLineHeight = textFontSize * 1.25;
	const textWidth = width - theme.space.md * 2;
	const textLines = props.text !== undefined ? wrapTextLines(props.text, textWidth, textFontSize) : [];
	const textHeight = props.text !== undefined ? math.max(textLineHeight, textLines.length * textLineHeight) : 0;
	return (
		<align-node
			key={props.key}
			ref={props.ref as JSX.Ref<import("Dora").AlignNode.Type> | undefined}
			style={mergeStyle({
				position: "absolute",
				width,
				height: (hasTitle ? 30 : 0) + textHeight + theme.space.md * 2,
				padding: theme.space.md,
				gap: theme.space.xs,
			}, props.style)}
			visible={props.visible}
			opacity={props.opacity}
			touchEnabled={false}
		>
			<PaintNode painter={(ctx) => roundedPanel(ctx, { x: 0, y: 0, width: ctx.width, height: ctx.height }, {
				variant: "solid",
				radius: theme.radius.sm,
			})} />
			<Column style={{ width: "100%", height: "100%", gap: theme.space.xs }}>
				{hasTitle ?
					<Text text={props.title} fontSize={theme.font.size.md} color={theme.colors.text.primary} style={{ width: "100%", height: 26 }} /> : undefined}
				{props.text !== undefined ?
					<Text
						text={props.text}
						fontSize={textFontSize}
						lineHeight={textLineHeight}
						wrap
						alignment={TextAlign.Left}
						color={theme.colors.text.secondary}
						style={{ width: "100%", height: math.max(textLineHeight, textHeight) }}
					/> : undefined}
				{props.children}
			</Column>
		</align-node>
	);
}
