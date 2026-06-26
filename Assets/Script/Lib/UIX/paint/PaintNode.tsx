import { App, Node, Size, Vec2 } from "Dora";
import type * as Dora from "Dora";
import { React, useCallback, useRef } from "DoraX";
import * as nvg from "nvg";
import { getUiContext } from "UIX/context";
import { applyAncestorClips } from "UIX/paint/clip";
import { InteractionState, mergeInteractionState, UiNodeProps } from "UIX/types";
import type { Theme } from "UIX/theme";

export interface PaintContext {
	width: number;
	height: number;
	theme: Theme;
	pixelRatio: number;
	opacity: number;
	state: InteractionState;
	time: number;
	data?: unknown;
	node: Dora.Node.Type;
}

export type Painter = (this: void, ctx: PaintContext) => void;

export interface PaintNodeProps extends UiNodeProps {
	width?: number;
	height?: number;
	painter: Painter;
	state?: Partial<InteractionState>;
	data?: unknown;
	onMountNode?: (this: void, node: Dora.Node.Type) => void;
}

export function PaintNode(this: void, props: PaintNodeProps): React.Element {
	const holder = useRef<PaintNodeProps>();
	(holder as unknown as AnyTable).current = props;
	const onCreate = useCallback(() => {
		const node = Node();
		node.anchor = Vec2(0, 0);
		node.onRender(() => {
			const latest = (holder as unknown as AnyTable).current as PaintNodeProps;
			const ui = getUiContext();
			const parent = node.parent;
			const width = latest.width ?? parent?.width ?? node.width;
			const height = latest.height ?? parent?.height ?? node.height;
			node.size = Size(width, height);
			nvg.Save();
			nvg.ApplyTransform(node);
			applyAncestorClips(node);
			latest.painter({
				width,
				height,
				theme: ui.theme,
				pixelRatio: ui.scale,
				opacity: latest.opacity ?? 1,
				state: mergeInteractionState(latest.state),
				time: App.elapsedTime,
				data: latest.data,
				node,
			});
			nvg.Restore();
			return false;
		});
		((holder as unknown as AnyTable).current as PaintNodeProps).onMountNode?.(node);
		return node;
	}, [holder]);
	return (
		<custom-node
			ref={props.ref as JSX.Ref<Dora.Node.Type> | undefined}
			key={props.key}
			order={props.order}
			renderOrder={props.renderOrder}
			visible={props.visible}
			opacity={props.opacity}
			onCreate={onCreate}
			onUnmount={(self) => {
				const clearRender = (self as AnyTable).clearRender;
				if (type(clearRender) === "function") {
					(clearRender as (node: Dora.Node.Type) => void)(self);
				}
			}}
		/>
	);
}
