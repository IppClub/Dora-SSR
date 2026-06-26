import type * as Dora from "Dora";
import { React, useRef } from "DoraX";
import { getUiContext } from "UIX/context";
import { Icon } from "UIX/foundation/Icon";
import { FocusRing } from "UIX/foundation/FocusRing";
import { Text } from "UIX/foundation/Text";
import { Row } from "UIX/layout/Row";
import { mergeStyle, textFromChildren } from "UIX/layout/helpers";
import { PaintNode } from "UIX/paint/PaintNode";
import { buttonSurface } from "UIX/paint/primitives";
import { useInteraction } from "UIX/input/Interaction";
import type { UiIcon, UiNodeProps, UiSize, UiVariant } from "UIX/types";

export interface ButtonProps extends UiNodeProps {
	variant?: UiVariant;
	size?: UiSize;
	icon?: UiIcon;
	iconPosition?: "left" | "right";
	loading?: boolean;
	selected?: boolean;
	focused?: boolean;
	focusable?: boolean;
	swallowTouches?: boolean;
	onClick?: (this: void) => void;
}

export function Button(this: void, props: ButtonProps): React.Element {
	const ui = getUiContext();
	const theme = ui.theme;
	const size = props.size ?? "md";
	const height = theme.size.control[size];
	const interaction = useInteraction({
		disabled: props.disabled,
		loading: props.loading,
		selected: props.selected,
	});
	const tapMoveDistance = useRef(0);
	const tapCancelled = useRef(false);
	if (props.focused === true && !interaction.state.focused) {
		interaction.setFocused(true);
	}
	const disabled = props.disabled === true || props.loading === true;
	const text = textFromChildren(props.children);
	const overlayChildren = text === "" ? props.children : undefined;
	const iconSize = theme.size.icon[size];
	const content = (
		<Row
			style={{
				width: "100%",
				height: "100%",
				padding: [0, theme.space.md],
				alignItems: "center",
				justifyContent: "center",
				gap: theme.space.sm,
			}}
		>
			{props.icon !== undefined && props.iconPosition !== "right" ?
				<Icon icon={props.icon} size={iconSize} disabled={disabled} color={disabled ? theme.colors.text.disabled : theme.colors.text.primary} /> : undefined}
			{text !== "" ?
				<Text text={props.loading === true ? "..." : text} fontSize={theme.font.size.md} color={disabled ? theme.colors.text.disabled : theme.colors.text.primary} /> : undefined}
			{props.icon !== undefined && props.iconPosition === "right" ?
				<Icon icon={props.icon} size={iconSize} disabled={disabled} color={disabled ? theme.colors.text.disabled : theme.colors.text.primary} /> : undefined}
		</Row>
	);
	return (
		<align-node
			key={props.key}
			ref={props.ref as JSX.Ref<import("Dora").AlignNode.Type> | undefined}
			style={mergeStyle({
				position: "relative",
				height,
				minWidth: height,
				alignItems: "center",
				justifyContent: "center",
			}, props.style)}
			visible={props.visible}
			opacity={props.opacity}
			touchEnabled={!disabled}
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
				if (!disabled && !tapCancelled.current) props.onClick?.();
				(tapCancelled as AnyTable).current = false;
			}}
			onUnmount={() => interaction.reset()}
		>
			<PaintNode
				key="button-surface"
				state={interaction.state}
				painter={(ctx) => buttonSurface(ctx, { x: 0, y: 0, width: ctx.width, height: ctx.height }, {
					variant: props.variant ?? "primary",
				})}
			/>
			{content}
			{overlayChildren !== undefined ?
				<align-node
					style={{
						position: "absolute",
						left: 0,
						right: 0,
						top: 0,
						bottom: 0,
						alignItems: "center",
						justifyContent: "center",
					}}
					>
					{overlayChildren}
				</align-node> : undefined}
			<FocusRing key="button-focus-ring" active={interaction.state.focused} disabled={disabled} />
		</align-node>
	);
}
