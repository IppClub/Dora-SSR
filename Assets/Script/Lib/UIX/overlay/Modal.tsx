import { App, Color } from "Dora";
import type * as Dora from "Dora";
import { React, useRef } from "DoraX";
import * as nvg from "nvg";
import { Button } from "UIX/controls/Button";
import { getUiContext } from "UIX/context";
import { Text } from "UIX/foundation/Text";
import { Column } from "UIX/layout/Column";
import { Row } from "UIX/layout/Row";
import { Panel } from "UIX/layout/Panel";
import { withAlpha } from "UIX/paint/color";
import { PaintNode } from "UIX/paint/PaintNode";
import type { UiNodeProps } from "UIX/types";

export interface ModalAction {
	id: string;
	label: string;
	variant?: "primary" | "secondary" | "danger" | "ghost";
	disabled?: boolean;
}

export interface ModalProps extends UiNodeProps {
	open: boolean;
	title?: string;
	message?: string;
	width?: number;
	height?: number;
	backdropColor?: number;
	backdropOpacity?: number;
	closeOnBackdrop?: boolean;
	actions?: ModalAction[];
	onClose?: (this: void) => void;
	onAction?: (this: void, id: string) => void;
}

export function Modal(this: void, props: ModalProps): React.Element | React.Element[] {
	const internalRef = useRef<Dora.AlignNode.Type>();
	if (!props.open) return [];
	const theme = getUiContext().theme;
	const rootRef = (props.ref ?? internalRef) as JSX.Ref<Dora.AlignNode.Type>;
	const width = props.width ?? 320;
	const height = props.height ?? 188;
	const screen = App.visualSize;
	const backdropColor = props.backdropColor ?? 0xff000000;
	const backdropOpacity = props.backdropOpacity ?? 0.58;
	const actions = props.actions ?? [];
	const messageHeight = props.message !== undefined ? 34 : 0;
	const bodyHeight = props.children !== undefined ? theme.size.control.sm : 0;
	const actionsHeight = actions.length > 0 ? theme.size.control.md : 0;
	return (
		<align-node
			key={props.key}
			ref={rootRef}
			windowRoot
			order={props.order ?? 10000}
			renderOrder={props.renderOrder}
			style={{
				width: screen.width,
				height: screen.height,
				alignItems: "center",
				justifyContent: "center",
			}}
			visible={props.visible}
			opacity={props.opacity}
			touchEnabled
			swallowTouches
			onTapped={() => {
				if (props.closeOnBackdrop !== false) props.onClose?.();
			}}
		>
			<align-node
				key="__uix_modal_backdrop"
				order={0}
				renderOrder={0}
				style={{
					position: "absolute",
					left: 0,
					top: 0,
					width: screen.width,
					height: screen.height,
				}}
				touchEnabled={false}
			>
				<PaintNode
					key="__uix_modal_backdrop_paint"
					painter={(ctx) => {
						nvg.BeginPath();
						nvg.Rect(0, 0, ctx.width, ctx.height);
						nvg.FillColor(Color(withAlpha(backdropColor, backdropOpacity * (props.opacity ?? 1))));
						nvg.Fill();
					}}
				/>
			</align-node>
			<align-node
				key="__uix_modal_panel"
				order={10}
				renderOrder={10}
				style={{ width, height }}
				touchEnabled
				swallowTouches
			>
				<Panel
					title={props.title}
					variant="solid"
					padding={theme.space.lg}
					headerHeight={props.title !== undefined ? 34 : 0}
					style={{ width, height }}
				>
					<Column style={{ width: "100%", height: "100%", gap: theme.space.sm }}>
						{props.message !== undefined ?
							<Text text={props.message} fontSize={theme.font.size.sm} color={theme.colors.text.secondary} style={{ width: "100%", height: messageHeight }} /> : undefined}
						{bodyHeight > 0 ?
							<align-node style={{ width: "100%", height: bodyHeight, alignItems: "center", justifyContent: "center" }}>
								{props.children}
							</align-node> : undefined}
						{actions.length > 0 ?
							<Row gap={theme.space.sm} style={{ width: "100%", height: actionsHeight, justifyContent: "center", alignItems: "center" }}>
								{actions.map(action => (
									<Button
										key={action.id}
										variant={action.variant ?? "secondary"}
										disabled={action.disabled}
										style={{ width: 96 }}
										onClick={() => props.onAction?.(action.id)}
									>
										{action.label}
									</Button>
								))}
							</Row> : undefined}
					</Column>
				</Panel>
			</align-node>
		</align-node>
	);
}
