import { React } from "DoraX";
import { IconButton, IconButtonProps } from "UIX/controls/IconButton";
import { PaintNode } from "UIX/paint/PaintNode";
import { cooldownMask } from "UIX/paint/primitives";
import { Text } from "UIX/foundation/Text";
import { clamp } from "UIX/types";

export interface CooldownButtonProps extends IconButtonProps {
	cooldown: number;
	maxCooldown: number;
	hotkey?: string;
	count?: number;
	onCast?: (this: void) => void;
}

export function CooldownButton(this: void, props: CooldownButtonProps): React.Element {
	const progress = props.maxCooldown <= 0 ? 0 : clamp(props.cooldown / props.maxCooldown, 0, 1);
	const cooling = progress > 0;
	return (
		<IconButton
			{...props}
			disabled={props.disabled === true || cooling}
			onClick={() => {
				if (!cooling) {
					props.onCast?.();
					props.onClick?.();
				}
			}}
		>
			<PaintNode
				key="cooldown-mask"
				order={-10}
				renderOrder={-10}
				state={{ disabled: cooling }}
				painter={(ctx) => cooldownMask(ctx, { x: 0, y: 0, width: ctx.width, height: ctx.height }, progress)}
			/>
			{cooling ?
				<Text key="cooldown-count" text={`${math.ceil(props.cooldown)}`} fontSize={16} color={0xfff4f8ff} /> : undefined}
		</IconButton>
	);
}
