import { React } from "DoraX";
import { PaintNode } from "UIX/paint/PaintNode";
import { focusRing } from "UIX/paint/primitives";
import type { UiNodeProps } from "UIX/types";

export interface FocusRingProps extends UiNodeProps {
	active: boolean;
	radius?: number;
	inset?: number;
	color?: number;
}

export function FocusRing(this: void, props: FocusRingProps): React.Element {
	return (
		<PaintNode
			key={props.key ?? "focus-ring-paint"}
			style={props.style}
			visible={props.visible}
			opacity={props.opacity}
			state={{ focused: props.active, disabled: props.disabled === true }}
			painter={(ctx) => focusRing(ctx, { x: 0, y: 0, width: ctx.width, height: ctx.height }, {
				radius: props.radius,
				inset: props.inset,
				color: props.color,
			})}
		/>
	);
}
