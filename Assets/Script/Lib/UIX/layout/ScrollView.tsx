import { App, Mouse, Size, Vec2 } from "Dora";
import type * as Dora from "Dora";
import { React, useRef } from "DoraX";
import { registerClip, unregisterClip } from "UIX/paint/clip";
import { mergeStyle } from "UIX/layout/helpers";
import type { UiNodeProps } from "UIX/types";
import { clamp } from "UIX/types";

export interface ScrollViewProps extends UiNodeProps {
	width?: number;
	height?: number;
	contentHeight: number;
	offsetY?: number;
	wheelSpeed?: number;
	inputOverlay?: boolean;
	dragOverlay?: boolean;
	swallowDrag?: boolean;
	onScroll?: (this: void, offsetY: number) => void;
}

export function ScrollView(this: void, props: ScrollViewProps): React.Element {
	const localOffset = useRef(props.offsetY ?? 0);
	const localRef = useRef<Dora.AlignNode.Type>();
	const contentRef = useRef<Dora.AlignNode.Type>();
	const inputRef = useRef<Dora.AlignNode.Type>();
	const dragRef = useRef<Dora.AlignNode.Type>();
	const dragging = useRef(false);
	const scrollActive = useRef(false);
	const dragDistance = useRef(0);
	const lastDragY = useRef(0);
	const rootRef = (props.ref ?? localRef) as JSX.Ref<Dora.AlignNode.Type>;
	const styleWidth = props.style?.width as number | undefined;
	const styleHeight = props.style?.height as number | undefined;
	const width = props.width ?? styleWidth ?? 240;
	const height = props.height ?? styleHeight ?? 160;
	const maxOffset = math.max(0, props.contentHeight - height);
	const offset = clamp(props.offsetY ?? localOffset.current ?? 0, 0, maxOffset);
	const getOffset = () => clamp(props.offsetY ?? localOffset.current ?? 0, 0, maxOffset);
	const applyContentOffset = (next: number) => {
		const node = contentRef.current;
		if (node !== undefined) {
			node.y = next;
		}
	};
	const setOffset = (value: number) => {
		const next = clamp(value, 0, maxOffset);
		if (props.offsetY === undefined) (localOffset as AnyTable).current = next;
		applyContentOffset(next);
		props.onScroll?.(next);
	};
	const scrollByWheel = (deltaY: number) => {
		setOffset(getOffset() + deltaY * (props.wheelSpeed ?? 24));
	};
	const mouseRootLocation = () => {
		const root = rootRef.current;
		if (root === undefined) return undefined;
		const { width: bw, height: bh } = App.bufferSize;
		const { width: vw } = App.visualSize;
		let pos = Mouse.position.mul(bw / vw);
		pos = Vec2(pos.x - bw / 2, bh / 2 - pos.y);
		return root.convertToNodeSpace(pos);
	};
	const touchRootLocation = (touch: Dora.Touch.Type) => {
		const root = rootRef.current;
		if (root !== undefined && touch.worldLocation !== undefined) {
			return root.convertToNodeSpace(touch.worldLocation);
		}
		return touch.location;
	};
	const isInsideTouch = (touch: Dora.Touch.Type) => {
		const location = touchRootLocation(touch);
		return location.x >= 0 && location.x <= width && location.y >= 0 && location.y <= height;
	};
	const filterDrag = (touch: Dora.Touch.Type) => {
		if (!touch.first || !isInsideTouch(touch)) {
			touch.enabled = false;
		}
	};
	const moveDrag = (touch: Dora.Touch.Type) => {
		if (Mouse.leftButtonPressed) return;
		const nextDistance = (dragDistance.current ?? 0) + touch.delta.length;
		(dragDistance as AnyTable).current = nextDistance;
		if (scrollActive.current || nextDistance > 10) {
			(scrollActive as AnyTable).current = true;
			setOffset(getOffset() + touch.delta.y);
		}
	};
	const beginDrag = (touch: Dora.Touch.Type) => {
		const location = touchRootLocation(touch);
		(dragging as AnyTable).current = Mouse.leftButtonPressed;
		(scrollActive as AnyTable).current = false;
		(dragDistance as AnyTable).current = 0;
		(lastDragY as AnyTable).current = location.y;
	};
	const endDrag = () => {
		(dragging as AnyTable).current = false;
		(scrollActive as AnyTable).current = false;
		(dragDistance as AnyTable).current = 0;
	};
	const pollDrag = () => {
		if (!dragging.current) return false;
		if (!Mouse.leftButtonPressed) {
			(dragging as AnyTable).current = false;
			return false;
		}
		const location = mouseRootLocation();
		if (location === undefined) return false;
		const deltaY = location.y - (lastDragY.current ?? location.y);
		(lastDragY as AnyTable).current = location.y;
		const nextDistance = (dragDistance.current ?? 0) + math.abs(deltaY);
		(dragDistance as AnyTable).current = nextDistance;
		if (scrollActive.current || nextDistance > 10) {
			(scrollActive as AnyTable).current = true;
			if (deltaY !== 0) setOffset(getOffset() + deltaY);
		}
		return false;
	};
	const syncClip = (node: Dora.AlignNode.Type | undefined, clipWidth: number, clipHeight: number) => {
		if (node !== undefined) {
			node.size = Size(clipWidth, clipHeight);
			registerClip(node, clipWidth, clipHeight);
		}
	};
	const syncInputSize = (node: Dora.AlignNode.Type | undefined, inputWidth: number, inputHeight: number) => {
		if (node !== undefined) node.size = Size(inputWidth, inputHeight);
	};
	const syncContentNode = (node: Dora.AlignNode.Type | undefined) => {
		if (node !== undefined) {
			node.y = getOffset();
			node.size = Size(width, props.contentHeight);
		}
	};
	return (
		<align-node
			key={props.key}
			ref={rootRef}
			style={mergeStyle({
				position: "relative",
				width,
				height,
			}, props.style)}
			visible={props.visible}
			opacity={props.opacity}
			onLayout={(w, h) => syncClip(rootRef.current, w, h)}
			onUnmount={(node) => {
				unregisterClip(node);
			}}
		>
			<align-node
				key="content"
				ref={contentRef}
				style={{
					position: "absolute",
					width: "100%",
					height: props.contentHeight,
					flexDirection: "column",
					alignItems: "flex-start",
					justifyContent: "flex-start",
				}}
				onLayout={() => syncContentNode(contentRef.current)}
			>
				{props.children}
			</align-node>
			{props.inputOverlay !== false ?
				<align-node
					key="input-overlay"
					ref={inputRef}
					style={{
						position: "absolute",
						left: 0,
						top: 0,
						width,
						height,
					}}
					touchEnabled={!props.disabled}
					swallowTouches={props.dragOverlay === true}
					swallowMouseWheel
					onLayout={(w, h) => syncInputSize(inputRef.current, w, h)}
					onMouseWheel={(delta) => scrollByWheel(delta.y)}
				/> : undefined
			}
			{props.inputOverlay !== false ?
				<align-node
					key="drag-capture"
					ref={dragRef}
					style={{
						position: "absolute",
						left: 0,
						top: 0,
						width,
						height,
					}}
					touchEnabled={!props.disabled}
					swallowTouches={props.swallowDrag ?? false}
					onLayout={(w, h) => syncInputSize(dragRef.current, w, h)}
					onTapFilter={filterDrag}
					onTapBegan={beginDrag}
					onTapMoved={moveDrag}
					onTapEnded={endDrag}
					onUpdate={pollDrag}
				/> : undefined
			}
		</align-node>
	);
}
