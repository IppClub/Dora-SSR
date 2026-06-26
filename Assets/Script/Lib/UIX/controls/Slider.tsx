import { React } from "DoraX";
import { Color } from "Dora";
import type * as Dora from "Dora";
import * as nvg from "nvg";
import { PaintNode } from "UIX/paint/PaintNode";
import { clamp, UiNodeProps } from "UIX/types";
import { mergeStyle } from "UIX/layout/helpers";
import { withAlpha } from "UIX/paint/color";

export interface SliderProps extends UiNodeProps {
	value: number;
	min?: number;
	max?: number;
	step?: number;
	showValue?: boolean;
	valueWidth?: number;
	onValueChange?: (this: void, value: number) => void;
}

let sliderFontId = 0;

function valueFromTouch(this: void, touch: Dora.Touch.Type | undefined, width: number, min: number, max: number, step?: number): number | undefined {
	if (touch === undefined) return undefined;
	const raw = min + clamp(touch.location.x / math.max(1, width), 0, 1) * (max - min);
	if (step !== undefined && step > 0) {
		return min + math.floor((raw - min) / step + 0.5) * step;
	}
	return raw;
}

export function Slider(this: void, props: SliderProps): React.Element {
	const min = props.min ?? 0;
	const max = props.max ?? 1;
	const value = clamp(props.value, min, max);
	const progress = max === min ? 0 : (value - min) / (max - min);
	const disabled = props.disabled === true;
	const valueWidth = props.showValue === true ? props.valueWidth ?? 42 : 0;
	let width = 160;
	const emitFromTouch = (touch?: Dora.Touch.Type) => {
		if (disabled) return;
		const next = valueFromTouch(touch, math.max(1, width - valueWidth), min, max, props.step);
		if (next !== undefined) props.onValueChange?.(clamp(next, min, max));
	};
	return (
		<align-node
			key={props.key}
			ref={props.ref as JSX.Ref<Dora.AlignNode.Type> | undefined}
			style={mergeStyle({
				position: "relative",
				width,
				height: 32,
				minWidth: 96,
			}, props.style)}
			visible={props.visible}
			opacity={props.opacity}
			touchEnabled={!disabled}
			swallowTouches
			onLayout={(w) => width = w}
			onTapBegan={emitFromTouch}
			onTapMoved={emitFromTouch}
			onTapped={emitFromTouch}
		>
			<PaintNode
				state={{ disabled }}
				painter={(ctx) => {
					const theme = ctx.theme;
					const trackH = 6;
					const y = ctx.height * 0.5 - trackH * 0.5;
					const radius = trackH * 0.5;
					const trackWidth = math.max(trackH, ctx.width - valueWidth);
					nvg.BeginPath();
					nvg.RoundedRect(0, y, trackWidth, trackH, radius);
					nvg.FillColor(Color(withAlpha(theme.colors.surface.sunken, ctx.opacity)));
					nvg.Fill();
					nvg.BeginPath();
					nvg.RoundedRect(0, y, math.max(trackH, trackWidth * progress), trackH, radius);
					nvg.FillColor(Color(withAlpha(disabled ? theme.colors.text.disabled : theme.colors.accent.primary, ctx.opacity)));
					nvg.Fill();
					const knobX = clamp(trackWidth * progress, 8, trackWidth - 8);
					nvg.BeginPath();
					nvg.Circle(knobX, ctx.height * 0.5, 8);
					nvg.FillColor(Color(withAlpha(disabled ? theme.colors.text.disabled : theme.colors.text.primary, ctx.opacity)));
					nvg.Fill();
					if (props.showValue === true) {
						if (sliderFontId === 0) sliderFontId = nvg.CreateFont(theme.font.name);
						nvg.FontFaceId(sliderFontId);
						nvg.FontSize(theme.font.size.xs);
						nvg.TextAlign(nvg.TextHAlign.Right, nvg.TextVAlign.Middle);
						nvg.FillColor(Color(theme.colors.text.secondary));
						nvg.Save();
						nvg.Scale(1, -1);
						nvg.Text(ctx.width, -ctx.height * 0.5, tostring(math.floor(value * 100) / 100));
						nvg.Restore();
					}
				}}
			/>
		</align-node>
	);
}
