import type * as Dora from "Dora";
import { React, useRef } from "DoraX";
import { getUiContext } from "UIX/context";
import { Icon } from "UIX/foundation/Icon";
import { Text } from "UIX/foundation/Text";
import { PaintNode } from "UIX/paint/PaintNode";
import { useInteraction } from "UIX/input/Interaction";
import { clamp } from "UIX/types";
import { mergeStyle } from "UIX/layout/helpers";

type UiIcon = string | { kind: "sprite"; file: string } | { kind: "painter"; name: string };
type ItemSlotQuality = "empty" | "common" | "rare" | "epic" | "legendary";
interface UiNodeProps {
	key?: string | number;
	ref?: { readonly current?: unknown };
	style?: AnyTable;
	order?: number;
	renderOrder?: number;
	visible?: boolean;
	opacity?: number;
	disabled?: boolean;
	testId?: string;
	children?: unknown;
}
const primitivePainters = require("UIX.paint.primitives") as AnyTable;

export interface ItemSlotProps extends UiNodeProps {
	id?: string;
	icon?: UiIcon;
	quality?: ItemSlotQuality;
	count?: number;
	selected?: boolean;
	cooldown?: number;
	maxCooldown?: number;
	swallowTouches?: boolean;
	onClick?: (this: void, id?: string) => void;
}

export function ItemSlot(this: void, props: ItemSlotProps): React.Element {
	const theme = getUiContext().theme;
	const interaction = useInteraction({
		disabled: props.disabled,
		selected: props.selected,
	});
	const tapMoveDistance = useRef(0);
	const tapCancelled = useRef(false);
	const size = props.style?.width as number | undefined ?? theme.size.control.lg;
	const disabled = props.disabled === true;
	const quality = props.icon === undefined ? "empty" : props.quality ?? "common";
	const cooldownProgress = props.cooldown !== undefined && props.maxCooldown !== undefined && props.maxCooldown > 0
		? clamp(props.cooldown / props.maxCooldown, 0, 1)
		: 0;
	return (
		<align-node
			key={props.key}
			ref={props.ref as JSX.Ref<import("Dora").AlignNode.Type> | undefined}
			style={mergeStyle({
				position: "relative",
				width: size,
				height: size,
				alignItems: "center",
				justifyContent: "center",
			}, props.style)}
			visible={props.visible}
			opacity={props.opacity}
			touchEnabled={!disabled && props.icon !== undefined}
			swallowTouches={props.swallowTouches ?? true}
			onTapBegan={() => {
				(tapMoveDistance as AnyTable).current = 0;
				(tapCancelled as AnyTable).current = false;
				interaction.setPressed(true);
			}}
			onTapMoved={(touch: Dora.Touch.Type) => {
				const nextDistance = (tapMoveDistance.current ?? 0) + touch.delta.length;
				(tapMoveDistance as AnyTable).current = nextDistance;
				if (nextDistance > 10) {
					(tapCancelled as AnyTable).current = true;
					interaction.setPressed(false);
				}
			}}
			onTapEnded={() => interaction.setPressed(false)}
			onTapped={() => {
				if (!disabled && props.icon !== undefined && !tapCancelled.current) props.onClick?.(props.id);
				(tapCancelled as AnyTable).current = false;
			}}
			onUnmount={() => interaction.reset()}
		>
			<PaintNode
				key="item-slot-surface"
				state={interaction.state}
				painter={(ctx) => primitivePainters.itemSlotSurface(ctx, { x: 0, y: 0, width: ctx.width, height: ctx.height }, quality, props.selected)}
			/>
			{props.icon !== undefined ?
				<Icon icon={props.icon} size={size * 0.44} disabled={disabled} /> : undefined}
			{props.count !== undefined && props.count > 1 ?
				<Text
					text={props.count}
					fontSize={theme.font.size.xs}
					color={disabled ? theme.colors.text.disabled : theme.colors.text.primary}
					style={{ position: "absolute", right: 4, bottom: 3, width: size * 0.5, height: 16 }}
				/> : undefined}
			{cooldownProgress > 0 ?
				<PaintNode
					key="item-slot-cooldown-mask"
					order={10}
					renderOrder={10}
					painter={(ctx) => primitivePainters.cooldownMask(ctx, { x: 0, y: 0, width: ctx.width, height: ctx.height }, cooldownProgress)}
				/> : undefined}
		</align-node>
	);
}
