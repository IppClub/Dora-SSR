import { React } from "DoraX";
import { Color } from "Dora";
import * as nvg from "nvg";
import { getUiContext } from "UIX/context";
import { Text } from "UIX/foundation/Text";
import { FocusRing } from "UIX/foundation/FocusRing";
import { Row } from "UIX/layout/Row";
import { PaintNode } from "UIX/paint/PaintNode";
import { useInteraction } from "UIX/input/Interaction";
import type { UiNodeProps } from "UIX/types";
import { withAlpha } from "UIX/paint/color";
import { mergeStyle } from "UIX/layout/helpers";

export interface ToggleProps extends UiNodeProps {
	checked: boolean;
	label?: string;
	focused?: boolean;
	onChange?: (this: void, checked: boolean) => void;
}

function togglePainter(this: void, checked: boolean) {
	return (ctx: import("UIX/paint/PaintNode").PaintContext) => {
		const theme = ctx.theme;
		const disabled = ctx.state.disabled;
		const w = ctx.width;
		const h = ctx.height;
		const radius = h * 0.5;
		const fill = disabled
			? withAlpha(theme.colors.surface.sunken, theme.painter.disabledAlpha)
			: checked ? withAlpha(theme.colors.accent.primary, 0.88) : theme.colors.surface.sunken;
		const stroke = checked ? theme.colors.accent.primary : theme.colors.line.normal;
		nvg.BeginPath();
		nvg.RoundedRect(0, 0, w, h, radius);
		nvg.FillColor(Color(withAlpha(fill, ctx.opacity)));
		nvg.Fill();
		nvg.StrokeWidth(theme.stroke.hairline);
		nvg.StrokeColor(Color(withAlpha(stroke, disabled ? 0.45 : ctx.opacity)));
		nvg.Stroke();
		const knobSize = h - 8;
		const knobX = checked ? w - knobSize - 4 : 4;
		nvg.BeginPath();
		nvg.Circle(knobX + knobSize * 0.5, h * 0.5, knobSize * 0.5);
		nvg.FillColor(Color(withAlpha(disabled ? theme.colors.text.disabled : theme.colors.text.primary, ctx.opacity)));
		nvg.Fill();
	};
}

export function Toggle(this: void, props: ToggleProps): React.Element {
	const theme = getUiContext().theme;
	const interaction = useInteraction({ disabled: props.disabled });
	if (props.focused === true && !interaction.state.focused) {
		interaction.setFocused(true);
	}
	const disabled = props.disabled === true;
	const control = (
		<align-node
			ref={props.ref as JSX.Ref<import("Dora").AlignNode.Type> | undefined}
			style={{ position: "relative", width: 54, height: 30 }}
			touchEnabled={!disabled}
			swallowTouches
			onTapBegan={() => interaction.setPressed(true)}
			onTapEnded={() => interaction.setPressed(false)}
			onTapped={() => {
				if (!disabled) props.onChange?.(!props.checked);
			}}
			onUnmount={() => interaction.reset()}
		>
			<PaintNode state={interaction.state} painter={togglePainter(props.checked)} />
			<FocusRing active={interaction.state.focused} disabled={disabled} />
		</align-node>
	);
	return (
		<Row
			key={props.key}
			style={mergeStyle({ height: theme.size.control.sm, alignItems: "center", gap: theme.space.sm }, props.style)}
			visible={props.visible}
			opacity={props.opacity}
		>
			{control}
			{props.label !== undefined ?
				<Text text={props.label} fontSize={theme.font.size.sm} color={disabled ? theme.colors.text.disabled : theme.colors.text.primary} /> : undefined}
		</Row>
	);
}
