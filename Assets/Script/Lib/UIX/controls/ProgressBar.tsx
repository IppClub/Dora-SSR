import { React } from "DoraX";
import { Color } from "Dora";
import * as nvg from "nvg";
import { getUiContext } from "UIX/context";
import { PaintNode } from "UIX/paint/PaintNode";
import { progressFill, progressTrack } from "UIX/paint/primitives";
import type { ProgressVariant, UiNodeProps } from "UIX/types";
import { clamp } from "UIX/types";
import { mergeStyle } from "UIX/layout/helpers";

export interface ProgressBarProps extends UiNodeProps {
	value: number;
	max?: number;
	min?: number;
	variant?: ProgressVariant;
	showValue?: boolean;
	animated?: boolean;
}

let progressFontId = 0;

export function ProgressBar(this: void, props: ProgressBarProps): React.Element {
	const min = props.min ?? 0;
	const max = props.max ?? 1;
	const progress = max === min ? 0 : clamp((props.value - min) / (max - min), 0, 1);
	return (
		<align-node
			key={props.key}
			ref={props.ref as JSX.Ref<import("Dora").AlignNode.Type> | undefined}
			style={mergeStyle({
				position: "relative",
				height: 18,
				minWidth: 80,
				alignItems: "center",
				justifyContent: "center",
			}, props.style)}
			visible={props.visible}
			opacity={props.opacity}
		>
			<PaintNode
				order={-10}
				renderOrder={-10}
				state={{ disabled: props.disabled === true }}
				painter={(ctx) => {
					const r = { x: 0, y: 0, width: ctx.width, height: ctx.height };
					progressTrack(ctx, r);
					progressFill(ctx, r, progress, props.variant ?? "neutral");
					if (props.showValue === true) {
						if (progressFontId === 0) progressFontId = nvg.CreateFont(ctx.theme.font.name);
						nvg.FontFaceId(progressFontId);
						nvg.FontSize(ctx.theme.font.size.xs);
						nvg.TextAlign(nvg.TextHAlign.Center, nvg.TextVAlign.Middle);
						nvg.FillColor(Color(ctx.theme.colors.text.primary));
						nvg.Save();
						nvg.Scale(1, -1);
						nvg.Text(ctx.width * 0.5, -ctx.height * 0.5, `${math.floor(progress * 100)}%`);
						nvg.Restore();
					}
				}}
			/>
		</align-node>
	);
}
