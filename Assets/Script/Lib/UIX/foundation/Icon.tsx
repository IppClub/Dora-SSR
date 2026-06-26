import { React } from "DoraX";
import { getUiContext } from "UIX/context";
import { PaintNode } from "UIX/paint/PaintNode";
import { drawIcon } from "UIX/paint/icons";
import type { UiIcon, UiNodeProps } from "UIX/types";

export interface IconProps extends UiNodeProps {
	icon: UiIcon;
	size?: number;
	color?: number;
	disabledColor?: number;
}

export function Icon(this: void, props: IconProps): React.Element {
	const theme = getUiContext().theme;
	const size = props.size ?? theme.size.icon.md;
	const color = props.disabled === true ? props.disabledColor ?? theme.colors.text.disabled : props.color ?? theme.colors.text.primary;
	if (type(props.icon) === "table" && (props.icon as { kind: string }).kind === "sprite") {
		const icon = props.icon as { kind: "sprite"; file: string };
		return <sprite file={icon.file} width={size} height={size} color3={color} opacity={props.opacity} />;
	}
	const name = type(props.icon) === "string" ? props.icon as string : (props.icon as { name: string }).name;
	return (
		<align-node key={props.key} style={{ width: size, height: size }}>
			<PaintNode
				key="icon-paint"
				painter={(ctx) => drawIcon(name, ctx, { x: 0, y: 0, width: ctx.width, height: ctx.height }, color)}
				state={{ disabled: props.disabled === true }}
				opacity={props.opacity}
			/>
		</align-node>
	);
}
