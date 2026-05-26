import React, { memo, useCallback, useEffect, useMemo, useRef, useState } from "react";
import { MacScrollbar } from "mac-scrollbar";
import type { ActionClipDocument } from "./ActionClip";
import type { ActionDocument, ActionDiagnostic, ActionFrameTrack, ActionKeyFrame, ActionNode } from "./ActionDocument";
import type { ActionViewport } from "./ActionEditorState";
import {
	addActionLook,
	addChildActionNode,
	addActionKeyPoint,
	cloneActionDocument,
	defaultActionViewport,
	findActionNode,
	moveActionNodeToParent,
	removeActionLook,
	removeActionKeyPoint,
	removeActionNode,
	reorderActionNode,
	setActionNode,
	setActionNodeLookHidden,
	updateActionKeyPoint,
} from "./ActionEditorState";
import {
	addActionAnimation,
	copyActionKeyFrame,
	deleteActionKeyFrame,
	formatActionFrameSpec,
	getActionAnimationDuration,
	isFirstActionKeyFrame,
	moveActionKeyFrame,
	parseActionFrameSpec,
	pasteActionKeyFrame,
	removeActionAnimation,
	renameActionAnimation,
	setActionFrameTrack,
	updateActionKeyFrame,
	upsertActionKeyFrame,
} from "./ActionPlayback";
import {
	ActionRenderRect,
	buildActionRenderRects,
	hitTestActionRenderRects,
	modelToScreen,
	renderRectCornersToViewport,
	screenDeltaToNodeLocalDelta,
	screenToModel,
} from "./ActionRender";

export type ActionEditorMode = "pose" | "look" | "animation";
export type ActionDocumentChangeOptions = {
	history?: "push" | "replace";
};

type ActionEditorTranslate = (key: string, options?: Record<string, unknown>) => string;

export type ActionEditorCanvasProps = {
	t: ActionEditorTranslate;
	document: ActionDocument;
	diagnostics: ActionDiagnostic[];
	runtimeDiagnostics: string[];
	clipDocument: ActionClipDocument | null;
	atlasImage: {
		path: string;
		image: HTMLImageElement;
		width: number;
		height: number;
	} | null;
	clipDiagnostics: string[];
	packing: boolean;
	width: number;
	height: number;
	active: boolean;
	readOnly: boolean;
	clipsDirs: string[];
	clipFiles: string[];
	clipsPackErrors: Record<string, string>;
	selectedNodeId: string;
	editMode: ActionEditorMode;
	selectedLook: string | null;
	selectedAnimation: string | null;
	playbackTime: number;
	playbackPlaying: boolean;
	playbackLoop: boolean;
	viewport: ActionViewport;
	onDocumentChange: (document: ActionDocument, options?: ActionDocumentChangeOptions) => void;
	onClipFileSelect: (clipFile: string) => void;
	onClipsDirClipBind: (clipsDir: string) => void;
	onPackClipsDir: (clipsDir: string) => void;
	onPackAllClipsDirs: () => void;
	onRefreshClipsDirs: () => void;
	onSelectionChange: (nodeId: string) => void;
	onEditModeChange: (mode: ActionEditorMode) => void;
	onLookSelect: (look: string | null) => void;
	onAnimationSelect: (animation: string | null) => void;
	onPlaybackTimeChange: (time: number) => void;
	onPlaybackPlayingChange: (playing: boolean) => void;
	onPlaybackLoopChange: (loop: boolean) => void;
	onViewportChange: (viewport: ActionViewport) => void;
	canUndo: boolean;
	canRedo: boolean;
	onUndo: () => void;
	onRedo: () => void;
	onRuntimeDiagnostics: (diagnostics: string[]) => void;
};

type GizmoMode = "select" | "move" | "scale" | "rotate";
type LeftTab = "tree" | "keyPoints" | "clips";

type DragState = {
	mode: "pan" | "edit";
	startPointer: { x: number; y: number };
	startPan: { x: number; y: number };
	nodeId: string | null;
	startPosition: { x: number; y: number } | null;
	startRotation: number | null;
	anchorScreen: { x: number; y: number } | null;
	lastPointerAngle: number | null;
	accumulatedRotation: number;
	historyStarted: boolean;
};

const tr = (props: ActionEditorCanvasProps, key: string, options?: Record<string, unknown>) => props.t(`actionEditor.${key}`, options);
const secondsToFrame = (time: number) => Math.max(0, Math.round(time * 60));
const frameToSeconds = (frame: number) => Math.max(0, frame) / 60;
const snapValue = (value: number, fixed: boolean, step: number) => fixed ? Math.round(value / step) * step : value;
const pointerAngleDegrees = (center: { x: number; y: number }, point: { x: number; y: number }) => Math.atan2(point.y - center.y, point.x - center.x) * 180 / Math.PI;
const pointerAngleStepDelta = (degrees: number) => {
	let result = degrees;
	while (result > 180) result -= 360;
	while (result < -180) result += 360;
	return result;
};

const easeNames = [
	"Linear", "InQuad", "OutQuad", "InOutQuad", "InCubic", "OutCubic", "InOutCubic", "InQuart", "OutQuart", "InOutQuart",
	"InQuint", "OutQuint", "InOutQuint", "InSine", "OutSine", "InOutSine", "InExpo", "OutExpo", "InOutExpo", "InCirc",
	"OutCirc", "InOutCirc", "InElastic", "OutElastic", "InOutElastic", "InBack", "OutBack", "InOutBack", "InBounce",
	"OutBounce", "InOutBounce", "OutInQuad", "OutInCubic", "OutInQuart", "OutInQuint", "OutInSine", "OutInExpo",
	"OutInCirc", "OutInElastic", "OutInBack", "OutInBounce",
];

const styles = {
	panel: {
		background: "#1a1a1a",
		borderColor: "#2b2b2b",
		color: "#d7d7d7",
	},
	button: {
		height: 28,
		border: "1px solid #343434",
		background: "#303030",
		color: "#d7d7d7",
		cursor: "pointer",
		boxSizing: "border-box" as const,
	},
	buttonActive: {
		border: "1px solid #fac03d",
		background: "#5f4917",
		color: "#ffe7ad",
	},
	input: {
		width: "100%",
		height: 26,
		boxSizing: "border-box" as const,
		background: "#181818",
		color: "#d7d7d7",
		border: "1px solid #343434",
		padding: "2px 6px",
	},
	label: {
		color: "#9aa4af",
		fontSize: 12,
		lineHeight: "18px",
	},
};

const withAlpha = (color: string, alpha: number) => {
	const value = Math.max(0, Math.min(1, alpha));
	if (color.startsWith("#") && color.length === 7) {
		const r = Number.parseInt(color.slice(1, 3), 16);
		const g = Number.parseInt(color.slice(3, 5), 16);
		const b = Number.parseInt(color.slice(5, 7), 16);
		return `rgba(${r}, ${g}, ${b}, ${value})`;
	}
	return color;
};

const emitNodeChange = (
	props: ActionEditorCanvasProps,
	nodeId: string,
	updater: (node: ActionNode) => ActionNode,
	options?: ActionDocumentChangeOptions,
) => {
	props.onDocumentChange(setActionNode(props.document, nodeId, updater), options);
};

const getSelectedAnimationKeyFrame = (
	props: ActionEditorCanvasProps,
	nodeId = props.selectedNodeId,
): ActionKeyFrame | null => {
	if (props.editMode !== "animation" || props.selectedAnimation === null) return null;
	const selected = findActionNode(props.document.root, nodeId);
	const track = selected?.tracks[props.selectedAnimation];
	if (track?.type !== "key") return null;
	return track.keyframes.find((frame) => Math.abs(frame.time - props.playbackTime) < 1 / 120) ?? null;
};

const emitKeyFrameChange = (
	props: ActionEditorCanvasProps,
	nodeId: string,
	updater: (frame: ActionKeyFrame) => ActionKeyFrame,
	options?: ActionDocumentChangeOptions,
) => {
	if (props.selectedAnimation === null) return;
	props.onDocumentChange(updateActionKeyFrame(props.document, nodeId, props.selectedAnimation, props.playbackTime, updater), options);
};

const createDefaultFrameTrack = (
	props: ActionEditorCanvasProps,
	selected: ActionNode,
): Omit<ActionFrameTrack, "animation"> => {
	const clipName = selected.clip || (Object.keys(props.clipDocument?.rects ?? {})[0] ?? "");
	const rect = clipName ? props.clipDocument?.rects[clipName] : undefined;
	const frameWidth = Math.max(1, rect?.height ?? rect?.width ?? 30);
	const frameHeight = Math.max(1, rect?.height ?? 30);
	const frameCount = Math.max(1, rect ? Math.floor(rect.width / frameWidth) : 1);
	return {
		type: "frame",
		file: formatActionFrameSpec({
			clipFile: props.document.clipFile,
			clipName,
			frameWidth,
			frameHeight,
			frameCount,
			duration: Math.max(1 / 60, frameCount / 10),
		}),
		delay: 0,
	};
};

const canSelectRenderRect = (props: ActionEditorCanvasProps, rect: ActionRenderRect) => rect.nodeId !== props.document.root.id
	&& rect.clip !== ""
	&& !rect.missingClip
	&& rect.sourceWidth > 0
	&& rect.sourceHeight > 0
	&& rect.width > 0
	&& rect.height > 0;

const getTreeNodeLabel = (props: ActionEditorCanvasProps, node: ActionNode) => node.name || (node.id === props.document.root.id ? tr(props, "rootNode") : tr(props, "node"));

const isPreviewHiddenInherited = (node: ActionNode, nodeId: string, hiddenIds: Set<string>, inherited = false): boolean | null => {
	const hidden = inherited || hiddenIds.has(node.id);
	if (node.id === nodeId) return hidden;
	for (const child of node.children) {
		const result = isPreviewHiddenInherited(child, nodeId, hiddenIds, hidden);
		if (result !== null) return result;
	}
	return null;
};

const isNodePreviewVisible = (props: ActionEditorCanvasProps, hiddenIds: Set<string>, nodeId: string) => !(isPreviewHiddenInherited(props.document.root, nodeId, hiddenIds) ?? false);

const drawPath = (ctx: CanvasRenderingContext2D, corners: ActionRenderRect["corners"]) => {
	ctx.beginPath();
	ctx.moveTo(corners[0].x, corners[0].y);
	ctx.lineTo(corners[1].x, corners[1].y);
	ctx.lineTo(corners[2].x, corners[2].y);
	ctx.lineTo(corners[3].x, corners[3].y);
	ctx.closePath();
};

const drawGrid = (ctx: CanvasRenderingContext2D, area: { x: number; y: number; width: number; height: number }, viewport: ActionViewport) => {
	ctx.fillStyle = "#1f1f1f";
	ctx.fillRect(area.x, area.y, area.width, area.height);
	const step = Math.max(16, 100 * viewport.zoom);
	const center = modelToScreen({ x: 0, y: 0 }, viewport, area);
	ctx.strokeStyle = "#303030";
	ctx.lineWidth = 1;
	ctx.beginPath();
	for (let x = center.x % step; x < area.x + area.width; x += step) {
		if (x >= area.x) {
			ctx.moveTo(x, area.y);
			ctx.lineTo(x, area.y + area.height);
		}
	}
	for (let y = center.y % step; y < area.y + area.height; y += step) {
		if (y >= area.y) {
			ctx.moveTo(area.x, y);
			ctx.lineTo(area.x + area.width, y);
		}
	}
	ctx.stroke();
	ctx.strokeStyle = "#585858";
	ctx.beginPath();
	ctx.moveTo(area.x, center.y);
	ctx.lineTo(area.x + area.width, center.y);
	ctx.moveTo(center.x, area.y);
	ctx.lineTo(center.x, area.y + area.height);
	ctx.stroke();
};

const drawModelBounds = (ctx: CanvasRenderingContext2D, props: ActionEditorCanvasProps, area: { x: number; y: number; width: number; height: number }) => {
	const size = props.document.size;
	if (size.width <= 0 || size.height <= 0) return;
	const min = modelToScreen({ x: -size.width * 0.5, y: size.height * 0.5 }, props.viewport, area);
	const max = modelToScreen({ x: size.width * 0.5, y: -size.height * 0.5 }, props.viewport, area);
	ctx.fillStyle = "rgba(61, 108, 143, 0.08)";
	ctx.strokeStyle = "rgba(61, 108, 143, 0.55)";
	ctx.lineWidth = 1.5;
	ctx.fillRect(min.x, min.y, max.x - min.x, max.y - min.y);
	ctx.strokeRect(min.x, min.y, max.x - min.x, max.y - min.y);
};

const drawImageQuad = (ctx: CanvasRenderingContext2D, image: HTMLImageElement, rect: ActionRenderRect, corners: ActionRenderRect["corners"]) => {
	const sw = Math.max(1, rect.sourceWidth);
	const sh = Math.max(1, rect.sourceHeight);
	const a = (corners[1].x - corners[0].x) / sw;
	const b = (corners[1].y - corners[0].y) / sw;
	const c = (corners[3].x - corners[0].x) / sh;
	const d = (corners[3].y - corners[0].y) / sh;
	const e = corners[0].x - a * rect.sourceX - c * rect.sourceY;
	const f = corners[0].y - b * rect.sourceX - d * rect.sourceY;
	ctx.save();
	drawPath(ctx, corners);
	ctx.clip();
	ctx.transform(a, b, c, d, e, f);
	ctx.drawImage(image, rect.sourceX, rect.sourceY, sw, sh, rect.sourceX, rect.sourceY, sw, sh);
	ctx.restore();
};

const drawArrow = (ctx: CanvasRenderingContext2D, from: { x: number; y: number }, to: { x: number; y: number }, color: string) => {
	const dx = to.x - from.x;
	const dy = to.y - from.y;
	const length = Math.max(0.0001, Math.hypot(dx, dy));
	const ux = dx / length;
	const uy = dy / length;
	const px = -uy;
	const py = ux;
	ctx.strokeStyle = color;
	ctx.fillStyle = color;
	ctx.lineWidth = 2;
	ctx.beginPath();
	ctx.moveTo(from.x, from.y);
	ctx.lineTo(to.x, to.y);
	ctx.stroke();
	ctx.beginPath();
	ctx.moveTo(to.x, to.y);
	ctx.lineTo(to.x - ux * 8 + px * 5, to.y - uy * 8 + py * 5);
	ctx.lineTo(to.x - ux * 8 - px * 5, to.y - uy * 8 - py * 5);
	ctx.closePath();
	ctx.fill();
};

const drawToolGizmo = (
	ctx: CanvasRenderingContext2D,
	props: ActionEditorCanvasProps,
	hiddenIds: Set<string>,
	gizmoMode: GizmoMode,
	rects: ActionRenderRect[],
	area: { x: number; y: number; width: number; height: number },
) => {
	if (props.editMode === "look" || gizmoMode === "select" || props.selectedNodeId === props.document.root.id) return;
	const rect = rects.find((item) => item.nodeId === props.selectedNodeId);
	if (!rect || !rect.visible || !isNodePreviewVisible(props, hiddenIds, rect.nodeId)) return;
	const corners = renderRectCornersToViewport(rect, props.viewport, area);
	const anchor = modelToScreen(rect.anchor, props.viewport, area);
	ctx.save();
	ctx.strokeStyle = "#ffffff";
	ctx.fillStyle = "#ffffff";
	ctx.lineWidth = 1.5;
	if (gizmoMode === "move") {
		const radius = Math.max(28, Math.min(72, Math.max(rect.width, rect.height) * props.viewport.zoom * 0.35));
		ctx.beginPath();
		ctx.arc(anchor.x, anchor.y, 4, 0, Math.PI * 2);
		ctx.fill();
		drawArrow(ctx, anchor, { x: anchor.x + radius, y: anchor.y }, "#00c8ff");
		drawArrow(ctx, anchor, { x: anchor.x, y: anchor.y - radius }, "#00c8ff");
	} else if (gizmoMode === "scale") {
		drawPath(ctx, corners);
		ctx.stroke();
		for (const point of corners) {
			ctx.fillStyle = "#00c8ff";
			ctx.fillRect(point.x - 5, point.y - 5, 10, 10);
			ctx.strokeRect(point.x - 5, point.y - 5, 10, 10);
		}
	} else if (gizmoMode === "rotate") {
		const radius = Math.max(32, Math.max(...corners.map((point) => Math.hypot(point.x - anchor.x, point.y - anchor.y))) + 22);
		ctx.beginPath();
		ctx.arc(anchor.x, anchor.y, radius, 0, Math.PI * 2);
		ctx.stroke();
		const end = { x: anchor.x + Math.cos(-Math.PI * 0.18) * radius, y: anchor.y + Math.sin(-Math.PI * 0.18) * radius };
		drawArrow(ctx, anchor, end, "#00c8ff");
	}
	ctx.restore();
};

const drawKeyPointMarkers = (
	ctx: CanvasRenderingContext2D,
	props: ActionEditorCanvasProps,
	visibleKeyPointIndexes: Set<number>,
	area: { x: number; y: number; width: number; height: number },
) => {
	ctx.save();
	ctx.font = "12px sans-serif";
	for (const index of visibleKeyPointIndexes) {
		const point = props.document.keyPoints[index];
		if (!point) continue;
		const pos = modelToScreen(point, props.viewport, area);
		ctx.fillStyle = "#42d6ff";
		ctx.strokeStyle = "rgba(66, 214, 255, 0.85)";
		ctx.beginPath();
		ctx.arc(pos.x, pos.y, 4.5, 0, Math.PI * 2);
		ctx.fill();
		ctx.beginPath();
		ctx.arc(pos.x, pos.y, 8, 0, Math.PI * 2);
		ctx.stroke();
		ctx.beginPath();
		ctx.moveTo(pos.x - 12, pos.y);
		ctx.lineTo(pos.x + 12, pos.y);
		ctx.moveTo(pos.x, pos.y - 12);
		ctx.lineTo(pos.x, pos.y + 12);
		ctx.stroke();
		if (point.name) {
			ctx.fillStyle = "rgba(255, 255, 255, 0.92)";
			ctx.fillText(point.name, pos.x + 10, pos.y + 4);
		}
	}
	ctx.restore();
};

const drawActionCanvas = (
	ctx: CanvasRenderingContext2D,
	props: ActionEditorCanvasProps,
	hiddenIds: Set<string>,
	visibleKeyPointIndexes: Set<number>,
	gizmoMode: GizmoMode,
	width: number,
	height: number,
) => {
	const area = { x: 0, y: 0, width, height };
	const rects = buildActionRenderRects(props.document, props.clipDocument, props.selectedLook, props.selectedAnimation, props.playbackTime);
	ctx.clearRect(0, 0, width, height);
	drawGrid(ctx, area, props.viewport);
	drawModelBounds(ctx, props, area);
	for (const rect of rects) {
		if (!rect.visible || !isNodePreviewVisible(props, hiddenIds, rect.nodeId)) continue;
		const corners = renderRectCornersToViewport(rect, props.viewport, area);
		ctx.save();
		ctx.globalAlpha = rect.opacity;
		if (props.atlasImage && !rect.missingClip && rect.clip) {
			drawImageQuad(ctx, props.atlasImage.image, rect, corners);
		} else {
			ctx.fillStyle = rect.missingClip ? "#4060bf" : "#8f6c3d";
			drawPath(ctx, corners);
			ctx.fill();
		}
		ctx.restore();
		ctx.strokeStyle = rect.nodeId === props.selectedNodeId ? "#4cc6ff" : withAlpha("#0b0b0b", Math.max(0.45, rect.opacity));
		ctx.lineWidth = rect.nodeId === props.selectedNodeId ? 3 : 1;
		drawPath(ctx, corners);
		ctx.stroke();
	}
	drawToolGizmo(ctx, props, hiddenIds, gizmoMode, rects, area);
	drawKeyPointMarkers(ctx, props, visibleKeyPointIndexes, area);
};

const collectAnimationFrames = (node: ActionNode, animation: string, selectedNodeId: string, result: { selected: number[]; other: number[] }) => {
	const track = node.tracks[animation];
	if (track?.type === "key") {
		for (const frame of track.keyframes) {
			(node.id === selectedNodeId ? result.selected : result.other).push(secondsToFrame(frame.time));
		}
	}
	for (const child of node.children) collectAnimationFrames(child, animation, selectedNodeId, result);
};

const collectAnimationFrameRanges = (
	node: ActionNode,
	animation: string,
	selectedNodeId: string,
	result: { selected: Array<{ start: number; end: number }>; other: Array<{ start: number; end: number }> },
) => {
	const track = node.tracks[animation];
	if (track?.type === "frame") {
		const spec = parseActionFrameSpec(track.file);
		if (spec) {
			(node.id === selectedNodeId ? result.selected : result.other).push({
				start: secondsToFrame(track.delay),
				end: secondsToFrame(track.delay + spec.duration),
			});
		}
	}
	for (const child of node.children) collectAnimationFrameRanges(child, animation, selectedNodeId, result);
};

const NumberField = memo(function NumberField(props: {
	label: string;
	value: number;
	step?: number;
	readOnly?: boolean;
	onChange: (value: number, options?: ActionDocumentChangeOptions) => void;
}) {
	const { label, value, step = 1, readOnly, onChange } = props;
	const [text, setText] = useState(String(value));
	const startedRef = useRef(false);
	useEffect(() => setText(String(value)), [value]);
	const commit = (raw: string, replace: boolean) => {
		const next = Number(raw);
		if (!Number.isFinite(next) || next === value || readOnly) return;
		onChange(next, { history: replace && startedRef.current ? "replace" : "push" });
		startedRef.current = true;
	};
	return (
		<label style={{ display: "grid", gridTemplateColumns: "88px minmax(0, 1fr)", alignItems: "center", gap: 6, marginBottom: 6 }}>
			<span style={styles.label}>{label}</span>
			<input
				type="number"
				step={step}
				value={text}
				disabled={readOnly}
				onFocus={() => { startedRef.current = false; }}
				onChange={(event) => {
					setText(event.currentTarget.value);
					commit(event.currentTarget.value, true);
				}}
				onBlur={(event) => {
					commit(event.currentTarget.value, false);
					startedRef.current = false;
				}}
				style={styles.input}
			/>
		</label>
	);
});

const TextField = memo(function TextField(props: {
	label: string;
	value: string;
	readOnly?: boolean;
	onChange: (value: string) => void;
}) {
	const { label, value, readOnly, onChange } = props;
	const [text, setText] = useState(value);
	useEffect(() => setText(value), [value]);
	return (
		<label style={{ display: "grid", gridTemplateColumns: "88px minmax(0, 1fr)", alignItems: "center", gap: 6, marginBottom: 6 }}>
			<span style={styles.label}>{label}</span>
			<input
				type="text"
				value={text}
				disabled={readOnly}
				onChange={(event) => setText(event.currentTarget.value)}
				onBlur={() => {
					if (text !== value && !readOnly) onChange(text);
				}}
				style={styles.input}
			/>
		</label>
	);
});

const CheckField = memo(function CheckField(props: {
	label: string;
	checked: boolean;
	readOnly?: boolean;
	onChange: (checked: boolean) => void;
}) {
	return (
		<label style={{ display: "flex", alignItems: "center", gap: 6, marginBottom: 6, color: "#d7d7d7", fontSize: 12 }}>
			<input
				type="checkbox"
				checked={props.checked}
				disabled={props.readOnly}
				onChange={(event) => props.onChange(event.currentTarget.checked)}
			/>
			{props.label}
		</label>
	);
});

const TabButton = (props: { active: boolean; onClick: () => void; children: React.ReactNode }) => (
	<button
		type="button"
		onClick={props.onClick}
		style={{
			...styles.button,
			...(props.active ? styles.buttonActive : null),
			flex: 1,
			minWidth: 0,
			overflow: "hidden",
			textOverflow: "ellipsis",
			whiteSpace: "nowrap",
		}}
	>
		{props.children}
	</button>
);

const NodeTree = memo(function NodeTree(props: {
	editor: ActionEditorCanvasProps;
	node: ActionNode;
	depth: number;
	hiddenIds: Set<string>;
	moveSourceId: string | null;
	onHiddenChange: (next: Set<string>) => void;
	onMoveSourceChange: (id: string | null) => void;
}) {
	const { editor, node, depth, hiddenIds, onHiddenChange } = props;
	const selected = editor.selectedNodeId === node.id;
	const directHidden = hiddenIds.has(node.id);
	const previewVisible = isNodePreviewVisible(editor, hiddenIds, node.id);
	return (
		<div>
			<div style={{ display: "flex", alignItems: "center", gap: 4, paddingLeft: depth * 14, minHeight: 30 }}>
				<button
					type="button"
					title={previewVisible ? tr(editor, "hide") : tr(editor, "showAll")}
					onClick={() => {
						const next = new Set(hiddenIds);
						if (directHidden) next.delete(node.id);
						else next.add(node.id);
						onHiddenChange(next);
					}}
					style={{ ...styles.button, width: 24, height: 24, padding: 0 }}
				>
					{previewVisible ? "o" : "/"}
				</button>
				<button
					type="button"
					onClick={() => editor.onSelectionChange(node.id)}
					style={{
						...styles.button,
						...(selected ? styles.buttonActive : null),
						flex: 1,
						minWidth: 0,
						textAlign: "left",
						padding: "0 8px",
						overflow: "hidden",
						textOverflow: "ellipsis",
						whiteSpace: "nowrap",
					}}
				>
					{getTreeNodeLabel(editor, node)}
				</button>
			</div>
			{node.children.map((child) => (
				<NodeTree
					key={child.id}
					editor={editor}
					node={child}
					depth={depth + 1}
					hiddenIds={hiddenIds}
					moveSourceId={props.moveSourceId}
					onHiddenChange={props.onHiddenChange}
					onMoveSourceChange={props.onMoveSourceChange}
				/>
			))}
		</div>
	);
});

const ClipChooser = memo(function ClipChooser(props: {
	editor: ActionEditorCanvasProps;
	selectedClip: string;
	onSelect: (clip: string) => void;
}) {
	const { editor, selectedClip, onSelect } = props;
	const names = useMemo(() => Object.keys(editor.clipDocument?.rects ?? {}).sort((a, b) => a.localeCompare(b)), [editor.clipDocument]);
	return (
		<select
			value={selectedClip}
			disabled={editor.readOnly}
			onChange={(event) => onSelect(event.currentTarget.value)}
			style={styles.input}
		>
			<option value="">{tr(editor, "none")}</option>
			{names.map((name) => <option key={name} value={name}>{name}</option>)}
		</select>
	);
});

const EaseField = memo(function EaseField(props: {
	label: string;
	value: number;
	readOnly?: boolean;
	onChange: (value: number) => void;
}) {
	return (
		<label style={{ display: "grid", gridTemplateColumns: "88px minmax(0, 1fr)", alignItems: "center", gap: 6, marginBottom: 6 }}>
			<span style={styles.label}>{props.label}</span>
			<select
				value={Math.max(0, Math.min(easeNames.length - 1, Math.round(props.value)))}
				disabled={props.readOnly}
				onChange={(event) => props.onChange(Number(event.currentTarget.value))}
				style={styles.input}
			>
				{easeNames.map((name, index) => <option key={name} value={index}>{name}</option>)}
			</select>
		</label>
	);
});

export default memo(function ActionEditorCanvas(props: ActionEditorCanvasProps) {
	const canvasRef = useRef<HTMLCanvasElement | null>(null);
	const dragRef = useRef<DragState | null>(null);
	const timelineDragRef = useRef<{ mode: "scrub" | "scroll"; startX: number; startOffset: number } | null>(null);
	const [leftTab, setLeftTab] = useState<LeftTab>("tree");
	const [gizmoMode, setGizmoMode] = useState<GizmoMode>("select");
	const [fixedSnap, setFixedSnap] = useState(false);
	const [anisotropicFiltering, setAnisotropicFiltering] = useState(true);
	const [previewHiddenNodeIds, setPreviewHiddenNodeIds] = useState<Set<string>>(() => new Set());
	const [visibleKeyPointIndexes, setVisibleKeyPointIndexes] = useState<Set<number>>(() => new Set());
	const [moveSourceId, setMoveSourceId] = useState<string | null>(null);
	const [copiedKeyFrame, setCopiedKeyFrame] = useState<ActionKeyFrame | null>(null);
	const [movingKeyTime, setMovingKeyTime] = useState<number | null>(null);
	const [timelineOffsetFrame, setTimelineOffsetFrame] = useState(0);
	const [timelineFollowCursor, setTimelineFollowCursor] = useState(true);
	const [isPointerDragging, setIsPointerDragging] = useState(false);
	const { onRuntimeDiagnostics } = props;

	useEffect(() => {
		onRuntimeDiagnostics([]);
	}, [onRuntimeDiagnostics]);
	useEffect(() => {
		setPreviewHiddenNodeIds(new Set());
		setVisibleKeyPointIndexes(new Set());
		setTimelineOffsetFrame(0);
		setTimelineFollowCursor(true);
	}, [props.document.modelPath]);

	const showSidePanels = props.width >= 760;
	const leftPanelWidth = showSidePanels ? 250 : 0;
	const rightPanelWidth = showSidePanels ? 290 : 0;
	const topToolbarHeight = 42;
	const timelineHeight = props.editMode === "animation" && props.selectedAnimation !== null ? 72 : 0;
	const centerWidth = Math.max(1, props.width - leftPanelWidth - rightPanelWidth);
	const canvasHeight = Math.max(1, props.height - topToolbarHeight - timelineHeight);

	const selected = findActionNode(props.document.root, props.selectedNodeId) ?? props.document.root;
	const selectedFrame = getSelectedAnimationKeyFrame(props);
	const rects = useMemo(
		() => buildActionRenderRects(props.document, props.clipDocument, props.selectedLook, props.selectedAnimation, props.playbackTime),
		[props.clipDocument, props.document, props.playbackTime, props.selectedAnimation, props.selectedLook],
	);

	useEffect(() => {
		const canvas = canvasRef.current;
		const context = canvas?.getContext("2d");
		if (!canvas || !context) return;
		const ratio = window.devicePixelRatio || 1;
		canvas.width = Math.max(1, Math.floor(centerWidth * ratio));
		canvas.height = Math.max(1, Math.floor(canvasHeight * ratio));
		canvas.style.width = `${centerWidth}px`;
		canvas.style.height = `${canvasHeight}px`;
		context.setTransform(ratio, 0, 0, ratio, 0, 0);
		context.imageSmoothingEnabled = anisotropicFiltering;
		drawActionCanvas(context, props, previewHiddenNodeIds, visibleKeyPointIndexes, gizmoMode, centerWidth, canvasHeight);
	}, [anisotropicFiltering, canvasHeight, centerWidth, gizmoMode, previewHiddenNodeIds, props, visibleKeyPointIndexes]);

	const onKeyDown = useCallback((event: React.KeyboardEvent<HTMLDivElement>) => {
		const target = event.target as HTMLElement | null;
		if (target && ["INPUT", "TEXTAREA", "SELECT"].includes(target.tagName)) return;
		const key = event.key.toLowerCase();
		const command = event.metaKey || event.ctrlKey;
		if (command && key === "z") {
			event.preventDefault();
			if (props.readOnly) return;
			if (event.shiftKey) {
				if (props.canRedo) props.onRedo();
			} else if (props.canUndo) {
				props.onUndo();
			}
		} else if (command && key === "y") {
			event.preventDefault();
			if (!props.readOnly && props.canRedo) props.onRedo();
		} else if (event.key === "Delete" || event.key === "Backspace") {
			if (!props.readOnly && selected.id !== props.document.root.id) {
				event.preventDefault();
				props.onDocumentChange(removeActionNode(props.document, selected.id));
				props.onSelectionChange(props.document.root.id);
			}
		}
	}, [props, selected.id]);

	const onPointerDown = useCallback((event: React.PointerEvent<HTMLCanvasElement>) => {
		event.currentTarget.setPointerCapture(event.pointerId);
		setIsPointerDragging(true);
		const point = { x: event.nativeEvent.offsetX, y: event.nativeEvent.offsetY };
		const area = { x: 0, y: 0, width: centerWidth, height: canvasHeight };
		const model = screenToModel(point, props.viewport, area);
		const hitId = hitTestActionRenderRects(rects, model, (rect) => canSelectRenderRect(props, rect) && isNodePreviewVisible(props, previewHiddenNodeIds, rect.nodeId));
		if (hitId) props.onSelectionChange(hitId);
		const selectedVisible = isNodePreviewVisible(props, previewHiddenNodeIds, props.selectedNodeId);
		const requestedDragNodeId = gizmoMode === "select" ? null : (hitId ?? (selectedVisible ? props.selectedNodeId : null));
		const dragFrame = requestedDragNodeId ? getSelectedAnimationKeyFrame(props, requestedDragNodeId) : null;
		const dragNodeId = props.editMode === "animation" && requestedDragNodeId !== null && dragFrame === null ? null : requestedDragNodeId;
		const dragNode = dragNodeId ? findActionNode(props.document.root, dragNodeId) : null;
		const dragRect = dragNodeId ? rects.find((rect) => rect.nodeId === dragNodeId) ?? null : null;
		dragRef.current = {
			mode: !props.readOnly && props.editMode !== "look" && gizmoMode !== "select" && dragNodeId !== null ? "edit" : "pan",
			startPointer: { x: event.clientX, y: event.clientY },
			startPan: { ...props.viewport.pan },
			nodeId: dragNodeId,
			startPosition: dragFrame ? { ...dragFrame.transform.position } : (dragNode ? { ...dragNode.transform.position } : null),
			startRotation: dragFrame ? dragFrame.transform.rotation : (dragNode ? dragNode.transform.rotation : null),
			anchorScreen: dragRect ? modelToScreen(dragRect.anchor, props.viewport, area) : null,
			lastPointerAngle: dragRect ? pointerAngleDegrees(modelToScreen(dragRect.anchor, props.viewport, area), point) : null,
			accumulatedRotation: 0,
			historyStarted: false,
		};
	}, [canvasHeight, centerWidth, gizmoMode, previewHiddenNodeIds, props, rects]);

	const getDragHistoryOptions = (drag: DragState): ActionDocumentChangeOptions => {
		const history = drag.historyStarted ? "replace" : "push";
		drag.historyStarted = true;
		return { history };
	};

	const onPointerMove = useCallback((event: React.PointerEvent<HTMLCanvasElement>) => {
		const drag = dragRef.current;
		if (!drag) return;
		const delta = { x: event.clientX - drag.startPointer.x, y: event.clientY - drag.startPointer.y };
		if (drag.mode === "pan") {
			props.onViewportChange({ ...props.viewport, pan: { x: drag.startPan.x + delta.x, y: drag.startPan.y + delta.y } });
			return;
		}
		if (!drag.nodeId) return;
		const options = getDragHistoryOptions(drag);
		const updateTransform = (updater: (transform: ActionKeyFrame["transform"]) => ActionKeyFrame["transform"]) => {
			if (props.editMode === "animation") {
				emitKeyFrameChange(props, drag.nodeId!, (frame) => ({ ...frame, transform: updater(frame.transform) }), options);
			} else {
				emitNodeChange(props, drag.nodeId!, (node) => ({ ...node, transform: { ...node.transform, ...updater(node.transform) } }), options);
			}
		};
		updateTransform((transform) => {
			if (gizmoMode === "scale") {
				return {
					...transform,
					scale: {
						x: Math.max(0.01, snapValue(transform.scale.x + delta.x / props.viewport.zoom / 100, fixedSnap, 0.1)),
						y: Math.max(0.01, snapValue(transform.scale.y - delta.y / props.viewport.zoom / 100, fixedSnap, 0.1)),
					},
				};
			}
			if (gizmoMode === "rotate") {
				if (!drag.anchorScreen || drag.startRotation === null || drag.lastPointerAngle === null) return transform;
				const pointer = { x: event.nativeEvent.offsetX, y: event.nativeEvent.offsetY };
				const angle = pointerAngleDegrees(drag.anchorScreen, pointer);
				drag.accumulatedRotation += pointerAngleStepDelta(angle - drag.lastPointerAngle);
				drag.lastPointerAngle = angle;
				return { ...transform, rotation: snapValue(drag.startRotation + drag.accumulatedRotation, fixedSnap, 5) };
			}
			if (gizmoMode === "move" && drag.startPosition) {
				const local = screenDeltaToNodeLocalDelta(props.document, props.clipDocument, drag.nodeId!, delta, props.viewport);
				return {
					...transform,
					position: {
						x: snapValue(drag.startPosition.x + local.x, fixedSnap, 1),
						y: snapValue(drag.startPosition.y + local.y, fixedSnap, 1),
					},
				};
			}
			return transform;
		});
	}, [fixedSnap, gizmoMode, props]);

	const onPointerUp = useCallback((event: React.PointerEvent<HTMLCanvasElement>) => {
		event.currentTarget.releasePointerCapture(event.pointerId);
		dragRef.current = null;
		setIsPointerDragging(false);
	}, []);

	const selectedClipNames = useMemo(() => Object.keys(props.clipDocument?.rects ?? {}).sort((a, b) => a.localeCompare(b)), [props.clipDocument]);

	const renderNodeCommands = () => {
		const rootSelected = selected.id === props.document.root.id;
		return (
			<div style={{ display: "flex", flexWrap: "wrap", gap: 6, padding: "6px 8px" }}>
				<button type="button" disabled={props.readOnly} onClick={() => props.onDocumentChange(addChildActionNode(props.document, selected.id))} style={styles.button}>{tr(props, "addChild")}</button>
				{previewHiddenNodeIds.size > 0 ? (
					<button type="button" onClick={() => setPreviewHiddenNodeIds(new Set())} style={styles.button}>{tr(props, "showAll")}</button>
				) : null}
				{!rootSelected ? (
					<>
						<button type="button" disabled={props.readOnly} onClick={() => { props.onDocumentChange(removeActionNode(props.document, selected.id)); props.onSelectionChange(props.document.root.id); }} style={styles.button}>{tr(props, "delete")}</button>
						<button type="button" disabled={props.readOnly} onClick={() => props.onDocumentChange(reorderActionNode(props.document, selected.id, -1))} style={styles.button}>{tr(props, "up")}</button>
						<button type="button" disabled={props.readOnly} onClick={() => props.onDocumentChange(reorderActionNode(props.document, selected.id, 1))} style={styles.button}>{tr(props, "down")}</button>
						<button type="button" disabled={props.readOnly} onClick={() => setMoveSourceId(moveSourceId === selected.id ? null : selected.id)} style={{ ...styles.button, ...(moveSourceId === selected.id ? styles.buttonActive : null) }}>{moveSourceId === selected.id ? tr(props, "cancelMove") : tr(props, "move")}</button>
					</>
				) : null}
				{moveSourceId && moveSourceId !== selected.id ? (
					<button type="button" onClick={() => { props.onDocumentChange(moveActionNodeToParent(props.document, moveSourceId, selected.id)); setMoveSourceId(null); }} style={{ ...styles.button, ...styles.buttonActive }}>{tr(props, "moveHere")}</button>
				) : null}
			</div>
		);
	};

	const renderLeftPanel = () => (
		<div style={{ width: leftPanelWidth, display: showSidePanels ? "flex" : "none", flexDirection: "column", borderRight: "1px solid #2b2b2b", background: "#1a1a1a", minHeight: 0 }}>
			<div style={{ padding: 8, borderBottom: "1px solid #2b2b2b" }}>
				<label style={styles.label}>{tr(props, "clip")}</label>
				<select
					value={props.document.clipFile}
					disabled={props.readOnly}
					onChange={(event) => props.onClipFileSelect(event.currentTarget.value)}
					style={{ ...styles.input, marginTop: 4 }}
				>
					<option value="">{tr(props, "none")}</option>
					{props.clipFiles.map((clipFile) => <option key={clipFile} value={clipFile}>{clipFile}</option>)}
				</select>
			</div>
			<div style={{ display: "flex", gap: 4, padding: 6, borderBottom: "1px solid #2b2b2b" }}>
				<TabButton active={leftTab === "tree"} onClick={() => setLeftTab("tree")}>{tr(props, "tree")}</TabButton>
				<TabButton active={leftTab === "keyPoints"} onClick={() => setLeftTab("keyPoints")}>{tr(props, "keyPoints")}</TabButton>
				<TabButton active={leftTab === "clips"} onClick={() => setLeftTab("clips")}>{tr(props, "clips")}</TabButton>
			</div>
			<div style={{ flex: 1, minHeight: 0 }}>
				<MacScrollbar skin="dark" style={{ width: "100%", height: "100%" }}>
					{leftTab === "tree" ? (
						<>
							{renderNodeCommands()}
							<NodeTree editor={props} node={props.document.root} depth={0} hiddenIds={previewHiddenNodeIds} moveSourceId={moveSourceId} onHiddenChange={setPreviewHiddenNodeIds} onMoveSourceChange={setMoveSourceId} />
						</>
					) : null}
					{leftTab === "keyPoints" ? (
						<div style={{ padding: 8 }}>
							<button type="button" disabled={props.readOnly} onClick={() => props.onDocumentChange(addActionKeyPoint(props.document))} style={styles.button}>{tr(props, "addPoint")}</button>
							{props.document.keyPoints.map((point, index) => (
								<div key={index} style={{ borderTop: "1px solid #2b2b2b", marginTop: 8, paddingTop: 8 }}>
									<div style={{ color: "#fac03d", fontSize: 12, marginBottom: 6 }}>{tr(props, "pointIndex", { index: index + 1 })}</div>
									<CheckField label={tr(props, "preview")} checked={visibleKeyPointIndexes.has(index)} onChange={(checked) => {
										const next = new Set(visibleKeyPointIndexes);
										if (checked) next.add(index);
										else next.delete(index);
										setVisibleKeyPointIndexes(next);
									}} />
									<TextField label={tr(props, "name")} value={point.name} readOnly={props.readOnly} onChange={(name) => props.onDocumentChange(updateActionKeyPoint(props.document, index, (item) => ({ ...item, name })))} />
									<NumberField label={tr(props, "x")} value={point.x} readOnly={props.readOnly} onChange={(x, options) => props.onDocumentChange(updateActionKeyPoint(props.document, index, (item) => ({ ...item, x })), options)} />
									<NumberField label={tr(props, "y")} value={point.y} readOnly={props.readOnly} onChange={(y, options) => props.onDocumentChange(updateActionKeyPoint(props.document, index, (item) => ({ ...item, y })), options)} />
									<button type="button" disabled={props.readOnly} onClick={() => {
										props.onDocumentChange(removeActionKeyPoint(props.document, index));
										setVisibleKeyPointIndexes((items) => new Set([...items].filter((item) => item !== index).map((item) => item > index ? item - 1 : item)));
									}} style={styles.button}>{tr(props, "deletePoint")}</button>
								</div>
							))}
						</div>
					) : null}
					{leftTab === "clips" ? (
						<div style={{ padding: 8 }}>
							<div style={{ display: "flex", gap: 6, marginBottom: 8 }}>
								<button type="button" disabled={props.readOnly || props.packing} onClick={props.onPackAllClipsDirs} style={styles.button}>{props.packing ? tr(props, "packing") : tr(props, "packAll")}</button>
								<button type="button" disabled={props.readOnly} onClick={props.onRefreshClipsDirs} style={styles.button}>{tr(props, "refresh")}</button>
							</div>
							{props.clipsDirs.length === 0 ? <div style={{ color: "#8f9aa6", fontSize: 12 }}>{tr(props, "noClipsDirectoryFound")}</div> : null}
							{props.clipsDirs.map((dir) => (
								<div key={dir} style={{ borderTop: "1px solid #2b2b2b", padding: "8px 0" }}>
									<div title={dir} style={{ color: "#d7d7d7", fontSize: 12, overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap", marginBottom: 6 }}>{dir}</div>
									<div style={{ display: "flex", gap: 6 }}>
										<button type="button" disabled={props.readOnly} onClick={() => props.onClipsDirClipBind(dir)} style={styles.button}>{tr(props, "set")}</button>
										<button type="button" disabled={props.readOnly || props.packing} onClick={() => props.onPackClipsDir(dir)} style={styles.button}>{tr(props, "pack")}</button>
									</div>
									{props.clipsPackErrors[dir] ? <div style={{ color: "#e98574", fontSize: 12, marginTop: 6 }}>{props.clipsPackErrors[dir]}</div> : null}
								</div>
							))}
						</div>
					) : null}
				</MacScrollbar>
			</div>
		</div>
	);

	const renderPosePanel = () => {
		const isRoot = selected.id === props.document.root.id;
		return (
			<div style={{ padding: 8 }}>
				{!isRoot ? (
					<>
						<TextField label={tr(props, "name")} value={selected.name} readOnly={props.readOnly} onChange={(name) => emitNodeChange(props, selected.id, (node) => ({ ...node, name }))} />
						<label style={{ display: "grid", gridTemplateColumns: "88px minmax(0, 1fr)", alignItems: "center", gap: 6, marginBottom: 6 }}>
							<span style={styles.label}>{tr(props, "clip")}</span>
							<ClipChooser editor={props} selectedClip={selected.clip} onSelect={(clip) => emitNodeChange(props, selected.id, (node) => ({ ...node, clip }))} />
						</label>
						<CheckField label={tr(props, "front")} checked={selected.front} readOnly={props.readOnly} onChange={(front) => emitNodeChange(props, selected.id, (node) => ({ ...node, front }))} />
					</>
				) : null}
				{isRoot ? (
					<>
						<NumberField label={tr(props, "width")} value={props.document.size.width} readOnly={props.readOnly} onChange={(value, options) => {
							const next = cloneActionDocument(props.document);
							next.size.width = Math.max(0, Math.round(value));
							props.onDocumentChange(next, options);
						}} />
						<NumberField label={tr(props, "height")} value={props.document.size.height} readOnly={props.readOnly} onChange={(value, options) => {
							const next = cloneActionDocument(props.document);
							next.size.height = Math.max(0, Math.round(value));
							props.onDocumentChange(next, options);
						}} />
					</>
				) : (
					<>
						<NumberField label={tr(props, "x")} value={selected.transform.position.x} readOnly={props.readOnly} onChange={(x, options) => emitNodeChange(props, selected.id, (node) => ({ ...node, transform: { ...node.transform, position: { ...node.transform.position, x } } }), options)} />
						<NumberField label={tr(props, "y")} value={selected.transform.position.y} readOnly={props.readOnly} onChange={(y, options) => emitNodeChange(props, selected.id, (node) => ({ ...node, transform: { ...node.transform, position: { ...node.transform.position, y } } }), options)} />
						<NumberField label={tr(props, "scaleX")} value={selected.transform.scale.x} step={0.1} readOnly={props.readOnly} onChange={(x, options) => emitNodeChange(props, selected.id, (node) => ({ ...node, transform: { ...node.transform, scale: { ...node.transform.scale, x } } }), options)} />
						<NumberField label={tr(props, "scaleY")} value={selected.transform.scale.y} step={0.1} readOnly={props.readOnly} onChange={(y, options) => emitNodeChange(props, selected.id, (node) => ({ ...node, transform: { ...node.transform, scale: { ...node.transform.scale, y } } }), options)} />
						<NumberField label={tr(props, "angle")} value={selected.transform.rotation} readOnly={props.readOnly} onChange={(rotation, options) => emitNodeChange(props, selected.id, (node) => ({ ...node, transform: { ...node.transform, rotation } }), options)} />
						<NumberField label={tr(props, "skewX")} value={selected.transform.skew.x} step={0.1} readOnly={props.readOnly} onChange={(x, options) => emitNodeChange(props, selected.id, (node) => ({ ...node, transform: { ...node.transform, skew: { ...node.transform.skew, x } } }), options)} />
						<NumberField label={tr(props, "skewY")} value={selected.transform.skew.y} step={0.1} readOnly={props.readOnly} onChange={(y, options) => emitNodeChange(props, selected.id, (node) => ({ ...node, transform: { ...node.transform, skew: { ...node.transform.skew, y } } }), options)} />
						<NumberField label={tr(props, "opacity")} value={selected.transform.opacity} step={0.05} readOnly={props.readOnly} onChange={(opacity, options) => emitNodeChange(props, selected.id, (node) => ({ ...node, transform: { ...node.transform, opacity: Math.max(0, Math.min(1, opacity)) } }), options)} />
						<NumberField label={tr(props, "anchorX")} value={selected.transform.anchor.x} step={0.05} readOnly={props.readOnly} onChange={(x, options) => emitNodeChange(props, selected.id, (node) => ({ ...node, transform: { ...node.transform, anchor: { ...node.transform.anchor, x } } }), options)} />
						<NumberField label={tr(props, "anchorY")} value={selected.transform.anchor.y} step={0.05} readOnly={props.readOnly} onChange={(y, options) => emitNodeChange(props, selected.id, (node) => ({ ...node, transform: { ...node.transform, anchor: { ...node.transform.anchor, y } } }), options)} />
					</>
				)}
				{renderViewportTools()}
			</div>
		);
	};

	const renderLooksPanel = () => (
		<div style={{ padding: 8 }}>
			<div style={{ display: "flex", gap: 6, marginBottom: 8 }}>
				<button type="button" disabled={props.readOnly} onClick={() => {
					const next = addActionLook(props.document);
					const added = next.looks.find((look) => props.document.looks.indexOf(look) < 0) ?? next.looks[next.looks.length - 1] ?? null;
					props.onDocumentChange(next);
					if (added !== null) {
						props.onLookSelect(added);
						props.onAnimationSelect(null);
					}
				}} style={styles.button}>{tr(props, "addLook")}</button>
				{props.selectedLook !== null ? <button type="button" disabled={props.readOnly} onClick={() => { props.onDocumentChange(removeActionLook(props.document, props.selectedLook!)); props.onLookSelect(null); }} style={styles.button}>{tr(props, "deleteLook")}</button> : null}
			</div>
			<div style={{ border: "1px solid #2b2b2b", maxHeight: 180, overflow: "auto", marginBottom: 8 }}>
				{props.document.looks.map((look) => (
					<button key={look} type="button" onClick={() => { props.onLookSelect(look); props.onAnimationSelect(null); props.onPlaybackPlayingChange(false); }} style={{ ...styles.button, ...(props.selectedLook === look ? styles.buttonActive : null), width: "100%", textAlign: "left", borderWidth: 0, borderBottom: "1px solid #2b2b2b" }}>{look}</button>
				))}
			</div>
			{props.selectedLook !== null ? (
				<>
					<div style={{ color: "#fac03d", fontSize: 12, marginBottom: 6 }}>{tr(props, "lookValue", { look: props.selectedLook })}</div>
					{selected.id !== props.document.root.id ? (
						<CheckField label={tr(props, "hide")} checked={selected.hiddenInLooks.indexOf(props.selectedLook) >= 0} readOnly={props.readOnly} onChange={(hidden) => props.onDocumentChange(setActionNodeLookHidden(props.document, selected.id, props.selectedLook!, hidden))} />
					) : null}
				</>
			) : <div style={{ color: "#8f9aa6", fontSize: 12 }}>{tr(props, "selectLookHint")}</div>}
			{renderViewportTools()}
		</div>
	);

	const renderAnimationFrameTrack = (track: ActionFrameTrack) => {
		if (props.selectedAnimation === null) return null;
		const parsed = parseActionFrameSpec(track.file);
		const fallbackClipName = selected.clip || (Object.keys(props.clipDocument?.rects ?? {})[0] ?? "");
		const rect = parsed?.clipName ? props.clipDocument?.rects[parsed.clipName] : undefined;
		const spec = parsed ?? {
			clipFile: props.document.clipFile,
			clipName: fallbackClipName,
			frameWidth: Math.max(1, rect?.height ?? 30),
			frameHeight: Math.max(1, rect?.height ?? 30),
			frameCount: 1,
			duration: 0.1,
		};
		const updateTrack = (updater: (item: typeof spec, delay: number) => { spec: typeof spec; delay: number }, options?: ActionDocumentChangeOptions) => {
			const next = updater(spec, track.delay);
			props.onDocumentChange(setActionFrameTrack(props.document, selected.id, props.selectedAnimation!, {
				type: "frame",
				file: formatActionFrameSpec(next.spec),
				delay: Math.max(0, next.delay),
			}), options);
		};
		return (
			<div>
				{!parsed ? <div style={{ color: "#8f9aa6", fontSize: 12, marginBottom: 6 }}>{tr(props, "invalidFrameTrack")}</div> : null}
				<label style={{ display: "grid", gridTemplateColumns: "88px minmax(0, 1fr)", alignItems: "center", gap: 6, marginBottom: 6 }}>
					<span style={styles.label}>{tr(props, "clip")}</span>
					<select value={spec.clipName} disabled={props.readOnly} onChange={(event) => updateTrack((item, delay) => ({ spec: { ...item, clipFile: props.document.clipFile, clipName: event.currentTarget.value }, delay }))} style={styles.input}>
						{selectedClipNames.map((name) => <option key={name} value={name}>{name}</option>)}
					</select>
				</label>
				<button type="button" disabled={props.readOnly} onClick={() => {
					const base = props.clipDocument?.rects[spec.clipName];
					if (!base) return;
					const frameHeight = Math.max(1, spec.frameHeight);
					const frameWidth = Math.max(1, Math.min(base.width, spec.frameWidth || frameHeight));
					const columns = Math.max(1, Math.floor(base.width / frameWidth));
					const rows = Math.max(1, Math.floor(base.height / frameHeight));
					updateTrack((item, delay) => ({ spec: { ...item, frameWidth, frameHeight, frameCount: Math.max(1, columns * rows) }, delay }));
				}} style={{ ...styles.button, marginBottom: 6 }}>{tr(props, "fit")}</button>
				<NumberField label={tr(props, "frameW")} value={spec.frameWidth} readOnly={props.readOnly} onChange={(frameWidth, options) => updateTrack((item, delay) => ({ spec: { ...item, frameWidth: Math.max(1, frameWidth) }, delay }), options)} />
				<NumberField label={tr(props, "frameH")} value={spec.frameHeight} readOnly={props.readOnly} onChange={(frameHeight, options) => updateTrack((item, delay) => ({ spec: { ...item, frameHeight: Math.max(1, frameHeight) }, delay }), options)} />
				<NumberField label={tr(props, "count")} value={spec.frameCount} readOnly={props.readOnly} onChange={(frameCount, options) => updateTrack((item, delay) => ({ spec: { ...item, frameCount: Math.max(1, Math.round(frameCount)) }, delay }), options)} />
				<NumberField label={tr(props, "duration")} value={spec.duration} step={1 / 60} readOnly={props.readOnly} onChange={(duration, options) => updateTrack((item, delay) => ({ spec: { ...item, duration: Math.max(1 / 60, duration) }, delay }), options)} />
				<NumberField label={tr(props, "delay")} value={track.delay} step={1 / 60} readOnly={props.readOnly} onChange={(delay, options) => updateTrack((item) => ({ spec: item, delay }), options)} />
				{rect ? <div style={{ color: "#8f9aa6", fontSize: 12 }}>{tr(props, "atlasInfo", { width: Math.round(rect.width), height: Math.round(rect.height), columns: Math.max(1, Math.floor(rect.width / Math.max(1, spec.frameWidth))), rows: Math.max(1, Math.floor(rect.height / Math.max(1, spec.frameHeight))) })}</div> : null}
			</div>
		);
	};

	const renderAnimationKeyFrameProperties = () => {
		if (props.selectedAnimation === null || selected.id === props.document.root.id) return <div style={{ color: "#8f9aa6", fontSize: 12 }}>{tr(props, "selectNodeKeyframe")}</div>;
		const frame = selectedFrame;
		const frontField = <CheckField label={tr(props, "front")} checked={selected.front} readOnly={props.readOnly} onChange={(front) => emitNodeChange(props, selected.id, (node) => ({ ...node, front }))} />;
		if (!frame) {
			return (
				<div>
					{frontField}
					<div style={{ color: "#8f9aa6", fontSize: 12 }}>{tr(props, "moveTimeHeadToKeyframe")}</div>
				</div>
			);
		}
		const firstKeyFrame = isFirstActionKeyFrame(props.document, selected.id, props.selectedAnimation, frame.time);
		return (
			<div>
				{frontField}
				<div style={{ color: "#fac03d", fontSize: 12, marginBottom: 6 }}>{tr(props, "keyFrameAt", { frame: secondsToFrame(frame.time) })}</div>
				<CheckField label={tr(props, "visible")} checked={frame.visible} readOnly={props.readOnly} onChange={(visible) => emitKeyFrameChange(props, selected.id, (item) => ({ ...item, visible }))} />
				<NumberField label={tr(props, "x")} value={frame.transform.position.x} readOnly={props.readOnly} onChange={(x, options) => emitKeyFrameChange(props, selected.id, (item) => ({ ...item, transform: { ...item.transform, position: { ...item.transform.position, x } } }), options)} />
				<NumberField label={tr(props, "y")} value={frame.transform.position.y} readOnly={props.readOnly} onChange={(y, options) => emitKeyFrameChange(props, selected.id, (item) => ({ ...item, transform: { ...item.transform, position: { ...item.transform.position, y } } }), options)} />
				<NumberField label={tr(props, "scaleX")} value={frame.transform.scale.x} step={0.1} readOnly={props.readOnly} onChange={(x, options) => emitKeyFrameChange(props, selected.id, (item) => ({ ...item, transform: { ...item.transform, scale: { ...item.transform.scale, x } } }), options)} />
				<NumberField label={tr(props, "scaleY")} value={frame.transform.scale.y} step={0.1} readOnly={props.readOnly} onChange={(y, options) => emitKeyFrameChange(props, selected.id, (item) => ({ ...item, transform: { ...item.transform, scale: { ...item.transform.scale, y } } }), options)} />
				<NumberField label={tr(props, "angle")} value={frame.transform.rotation} readOnly={props.readOnly} onChange={(rotation, options) => emitKeyFrameChange(props, selected.id, (item) => ({ ...item, transform: { ...item.transform, rotation } }), options)} />
				<NumberField label={tr(props, "skewX")} value={frame.transform.skew.x} step={0.1} readOnly={props.readOnly} onChange={(x, options) => emitKeyFrameChange(props, selected.id, (item) => ({ ...item, transform: { ...item.transform, skew: { ...item.transform.skew, x } } }), options)} />
				<NumberField label={tr(props, "skewY")} value={frame.transform.skew.y} step={0.1} readOnly={props.readOnly} onChange={(y, options) => emitKeyFrameChange(props, selected.id, (item) => ({ ...item, transform: { ...item.transform, skew: { ...item.transform.skew, y } } }), options)} />
				<NumberField label={tr(props, "opacity")} value={frame.transform.opacity} step={0.05} readOnly={props.readOnly} onChange={(opacity, options) => emitKeyFrameChange(props, selected.id, (item) => ({ ...item, transform: { ...item.transform, opacity: Math.max(0, Math.min(1, opacity)) } }), options)} />
				{!firstKeyFrame ? (
					<>
						<EaseField label={tr(props, "moveEase")} value={frame.ease.position} readOnly={props.readOnly} onChange={(position) => emitKeyFrameChange(props, selected.id, (item) => ({ ...item, ease: { ...item.ease, position } }))} />
						<EaseField label={tr(props, "scaleEase")} value={frame.ease.scale} readOnly={props.readOnly} onChange={(scale) => emitKeyFrameChange(props, selected.id, (item) => ({ ...item, ease: { ...item.ease, scale } }))} />
						<EaseField label={tr(props, "skewEase")} value={frame.ease.skew} readOnly={props.readOnly} onChange={(skew) => emitKeyFrameChange(props, selected.id, (item) => ({ ...item, ease: { ...item.ease, skew } }))} />
						<EaseField label={tr(props, "angleEase")} value={frame.ease.rotation} readOnly={props.readOnly} onChange={(rotation) => emitKeyFrameChange(props, selected.id, (item) => ({ ...item, ease: { ...item.ease, rotation } }))} />
						<EaseField label={tr(props, "opacityEase")} value={frame.ease.opacity} readOnly={props.readOnly} onChange={(opacity) => emitKeyFrameChange(props, selected.id, (item) => ({ ...item, ease: { ...item.ease, opacity } }))} />
					</>
				) : null}
				<TextField label={tr(props, "event")} value={frame.event ?? ""} readOnly={props.readOnly} onChange={(event) => emitKeyFrameChange(props, selected.id, (item) => ({ ...item, event: event === "" ? undefined : event }))} />
			</div>
		);
	};

	const renderViewportTools = () => {
		const rootSelected = props.selectedNodeId === props.document.root.id;
		const selectOnly = props.editMode === "look" || rootSelected;
		const visibleModes: GizmoMode[] = selectOnly ? ["select"] : ["select", "move", "scale", "rotate"];
		return (
			<div style={{ borderTop: "1px solid #2b2b2b", marginTop: 8, paddingTop: 8 }}>
				<div style={{ ...styles.label, marginBottom: 6 }}>{tr(props, "tool")}</div>
				<div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 6, marginBottom: 6 }}>
					{visibleModes.map((mode) => (
						<button key={mode} type="button" onClick={() => setGizmoMode(mode)} style={{ ...styles.button, ...(gizmoMode === mode ? styles.buttonActive : null) }}>{tr(props, `toolMode.${mode}`)}</button>
					))}
				</div>
				{!selectOnly ? <CheckField label={tr(props, "fixed")} checked={fixedSnap} onChange={setFixedSnap} /> : null}
				{props.editMode === "animation" ? renderAnimationKeyFrameProperties() : null}
			</div>
		);
	};

	const renderAnimationsPanel = () => {
		const duration = props.selectedAnimation ? getActionAnimationDuration(props.document, props.selectedAnimation) : 0;
		const track = props.selectedAnimation && selected.id !== props.document.root.id ? selected.tracks[props.selectedAnimation] : undefined;
		const currentFrame = track?.type === "key" ? track.keyframes.find((frame) => Math.abs(frame.time - props.playbackTime) < 1 / 120) : undefined;
		return (
			<div style={{ padding: 8 }}>
				<div style={{ display: "flex", gap: 6, marginBottom: 8 }}>
					<button type="button" disabled={props.readOnly} onClick={() => {
						const result = addActionAnimation(props.document);
						props.onDocumentChange(result.document);
						props.onAnimationSelect(result.animation);
						props.onPlaybackTimeChange(0);
					}} style={styles.button}>{tr(props, "addAnimation")}</button>
					{props.selectedAnimation !== null ? <button type="button" disabled={props.readOnly} onClick={() => { props.onDocumentChange(removeActionAnimation(props.document, props.selectedAnimation!)); props.onAnimationSelect(null); props.onPlaybackTimeChange(0); }} style={styles.button}>{tr(props, "deleteAnimation")}</button> : null}
				</div>
				<div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 8, marginBottom: 8 }}>
					<div>
						<div style={styles.label}>{tr(props, "animation")}</div>
						<div style={{ border: "1px solid #2b2b2b", maxHeight: 120, overflow: "auto" }}>
							{props.document.animations.map((animation) => <button key={animation} type="button" onClick={() => { props.onAnimationSelect(animation); props.onPlaybackTimeChange(0); }} style={{ ...styles.button, ...(props.selectedAnimation === animation ? styles.buttonActive : null), width: "100%", textAlign: "left", borderWidth: 0, borderBottom: "1px solid #2b2b2b" }}>{animation}</button>)}
						</div>
					</div>
					<div>
						<div style={styles.label}>{tr(props, "look")}</div>
						<div style={{ border: "1px solid #2b2b2b", maxHeight: 120, overflow: "auto" }}>
							<button type="button" onClick={() => props.onLookSelect(null)} style={{ ...styles.button, ...(props.selectedLook === null ? styles.buttonActive : null), width: "100%", textAlign: "left", borderWidth: 0, borderBottom: "1px solid #2b2b2b" }}>{tr(props, "defaultLook")}</button>
							{props.document.looks.map((look) => <button key={look} type="button" onClick={() => props.onLookSelect(look)} style={{ ...styles.button, ...(props.selectedLook === look ? styles.buttonActive : null), width: "100%", textAlign: "left", borderWidth: 0, borderBottom: "1px solid #2b2b2b" }}>{look}</button>)}
						</div>
					</div>
				</div>
				{props.selectedAnimation === null ? null : (
					<>
						<TextField label={tr(props, "animation")} value={props.selectedAnimation} readOnly={props.readOnly} onChange={(nextName) => {
							const trimmed = nextName.trim();
							if (!trimmed || trimmed === props.selectedAnimation) return;
							const nextDocument = renameActionAnimation(props.document, props.selectedAnimation!, trimmed);
							if (nextDocument !== props.document) {
								props.onDocumentChange(nextDocument);
								props.onAnimationSelect(trimmed);
							}
						}} />
						<div style={{ display: "flex", alignItems: "center", gap: 6, marginBottom: 8 }}>
							<button type="button" onClick={() => props.onPlaybackPlayingChange(!props.playbackPlaying)} style={styles.button}>{props.playbackPlaying ? tr(props, "pause") : tr(props, "play")}</button>
							<CheckField label={tr(props, "loop")} checked={props.playbackLoop} onChange={props.onPlaybackLoopChange} />
						</div>
						<NumberField label={tr(props, "time")} value={props.playbackTime} step={1 / 60} readOnly={props.readOnly} onChange={(time) => props.onPlaybackTimeChange(Math.max(0, time))} />
						<div style={{ color: "#8f9aa6", fontSize: 12, marginBottom: 8 }}>{tr(props, "frameCounter", { current: Math.round(props.playbackTime * 60), total: Math.round(duration * 60) })}</div>
						{!props.playbackPlaying && selected.id !== props.document.root.id ? (
							<>
								<div style={{ display: "flex", gap: 8, alignItems: "center", marginBottom: 8 }}>
									<span style={styles.label}>{tr(props, "track")}</span>
									<label style={{ color: "#d7d7d7", fontSize: 12 }}><input type="radio" checked={track?.type !== "frame"} disabled={props.readOnly} onChange={() => props.selectedAnimation && props.onDocumentChange(upsertActionKeyFrame(props.document, selected.id, props.selectedAnimation, props.playbackTime))} /> {tr(props, "key")}</label>
									<label style={{ color: "#d7d7d7", fontSize: 12 }}><input type="radio" checked={track?.type === "frame"} disabled={props.readOnly} onChange={() => props.selectedAnimation && props.onDocumentChange(setActionFrameTrack(props.document, selected.id, props.selectedAnimation, createDefaultFrameTrack(props, selected)))} /> {tr(props, "sequence")}</label>
								</div>
								{track?.type === "frame" ? renderAnimationFrameTrack(track) : (
									<>
										<div style={{ display: "flex", flexWrap: "wrap", gap: 6, marginBottom: 8 }}>
											{!currentFrame ? <button type="button" disabled={props.readOnly} onClick={() => props.onDocumentChange(upsertActionKeyFrame(props.document, selected.id, props.selectedAnimation!, props.playbackTime))} style={styles.button}>{tr(props, "addKey")}</button> : null}
											<button type="button" disabled={props.readOnly} onClick={() => props.onDocumentChange(deleteActionKeyFrame(props.document, selected.id, props.selectedAnimation!, props.playbackTime))} style={styles.button}>{tr(props, "deleteKey")}</button>
											{currentFrame ? <button type="button" disabled={props.readOnly} onClick={() => { setCopiedKeyFrame(copyActionKeyFrame(props.document, selected.id, props.selectedAnimation!, props.playbackTime)); setMovingKeyTime(null); }} style={styles.button}>{tr(props, "copyKey")}</button> : null}
											{currentFrame ? <button type="button" disabled={props.readOnly} onClick={() => { setMovingKeyTime(props.playbackTime); setCopiedKeyFrame(null); }} style={styles.button}>{tr(props, "moveKey")}</button> : null}
											{copiedKeyFrame ? <button type="button" disabled={props.readOnly} onClick={() => setCopiedKeyFrame(null)} style={styles.button}>{tr(props, "cancelCopy")}</button> : null}
											{copiedKeyFrame ? <button type="button" disabled={props.readOnly} onClick={() => { props.onDocumentChange(pasteActionKeyFrame(props.document, selected.id, props.selectedAnimation!, props.playbackTime, copiedKeyFrame)); setCopiedKeyFrame(null); }} style={{ ...styles.button, ...styles.buttonActive }}>{tr(props, "pasteKey")}</button> : null}
											{movingKeyTime !== null ? <button type="button" disabled={props.readOnly} onClick={() => setMovingKeyTime(null)} style={{ ...styles.button, ...styles.buttonActive }}>{tr(props, "cancelMove")}</button> : null}
										</div>
										{copiedKeyFrame ? <div style={{ color: "#8f9aa6", fontSize: 12 }}>{tr(props, "copyingKey", { frame: secondsToFrame(copiedKeyFrame.time) })}</div> : null}
										{movingKeyTime !== null ? <div style={{ color: "#8f9aa6", fontSize: 12 }}>{tr(props, "movingKey", { frame: secondsToFrame(movingKeyTime) })}</div> : null}
									</>
								)}
								{renderViewportTools()}
							</>
						) : null}
					</>
				)}
			</div>
		);
	};

	const renderRightPanel = () => (
		<div style={{ width: rightPanelWidth, display: showSidePanels ? "flex" : "none", flexDirection: "column", borderLeft: "1px solid #2b2b2b", background: "#1a1a1a", minHeight: 0 }}>
			<div style={{ display: "flex", gap: 4, padding: 6, borderBottom: "1px solid #2b2b2b" }}>
				<TabButton active={props.editMode === "pose"} onClick={() => props.onEditModeChange("pose")}>{tr(props, "pose")}</TabButton>
				<TabButton active={props.editMode === "look"} onClick={() => props.onEditModeChange("look")}>{tr(props, "look")}</TabButton>
				<TabButton active={props.editMode === "animation"} onClick={() => props.onEditModeChange("animation")}>{tr(props, "animation")}</TabButton>
			</div>
			<div style={{ flex: 1, minHeight: 0 }}>
				<MacScrollbar skin="dark" style={{ width: "100%", height: "100%" }}>
					{props.editMode === "pose" ? renderPosePanel() : null}
					{props.editMode === "look" ? renderLooksPanel() : null}
					{props.editMode === "animation" ? renderAnimationsPanel() : null}
				</MacScrollbar>
			</div>
		</div>
	);

	const timelineInfo = useMemo(() => {
		if (props.editMode !== "animation" || props.selectedAnimation === null) return null;
		const durationFrame = secondsToFrame(getActionAnimationDuration(props.document, props.selectedAnimation));
		const currentFrame = secondsToFrame(props.playbackTime);
		const frameSets = { selected: [] as number[], other: [] as number[] };
		const frameRanges = { selected: [] as Array<{ start: number; end: number }>, other: [] as Array<{ start: number; end: number }> };
		collectAnimationFrames(props.document.root, props.selectedAnimation, props.selectedNodeId, frameSets);
		collectAnimationFrameRanges(props.document.root, props.selectedAnimation, props.selectedNodeId, frameRanges);
		const keyFrames = [...new Set(frameSets.selected)].sort((a, b) => a - b);
		const rangeFrames = [...frameRanges.selected, ...frameRanges.other].flatMap((range) => [range.start, range.end]);
		const visibleFrames = 60;
		const contentMaxFrame = Math.max(0, durationFrame, currentFrame, ...keyFrames, ...rangeFrames);
		const nextOffset = timelineFollowCursor && currentFrame < timelineOffsetFrame
			? Math.max(0, currentFrame)
			: timelineFollowCursor && currentFrame > timelineOffsetFrame + visibleFrames
				? currentFrame - visibleFrames
				: timelineOffsetFrame;
		const timelineMaxFrame = Math.max(visibleFrames, contentMaxFrame, nextOffset + visibleFrames);
		const windowStart = Math.max(0, Math.min(nextOffset, timelineMaxFrame - visibleFrames));
		const windowEnd = windowStart + visibleFrames;
		return { durationFrame, currentFrame, frameRanges, keyFrames, visibleFrames, windowStart, windowEnd };
	}, [props, timelineFollowCursor, timelineOffsetFrame]);

	useEffect(() => {
		if (timelineInfo && timelineInfo.windowStart !== timelineOffsetFrame) setTimelineOffsetFrame(timelineInfo.windowStart);
	}, [timelineInfo, timelineOffsetFrame]);

	const timelineFrameToX = (frame: number) => {
		if (!timelineInfo) return 0;
		const left = 28;
		const right = centerWidth - 28;
		return left + ((frame - timelineInfo.windowStart) / timelineInfo.visibleFrames) * Math.max(1, right - left);
	};

	const timelineXToFrame = (x: number) => {
		if (!timelineInfo) return 0;
		const left = 28;
		const right = centerWidth - 28;
		return Math.max(0, timelineInfo.windowStart + Math.round(((x - left) / Math.max(1, right - left)) * timelineInfo.visibleFrames));
	};

	const renderTimeline = () => {
		if (!timelineInfo || props.selectedAnimation === null) return null;
		const rulerY = 34;
		const ticks = [];
		for (let frame = timelineInfo.windowStart; frame <= timelineInfo.windowEnd; frame += 1) {
			if (frame % 5 !== 0 && frame !== timelineInfo.currentFrame) continue;
			const x = timelineFrameToX(frame);
			ticks.push(<div key={frame} style={{ position: "absolute", left: x, top: rulerY, width: 1, height: frame % 10 === 0 ? 12 : 6, background: "#d6d6d6" }} />);
			if (frame % 10 === 0) ticks.push(<div key={`label-${frame}`} style={{ position: "absolute", left: x - 5, top: 6, color: "#d6d6d6", fontSize: 10 }}>{frame}</div>);
		}
		return (
			<div
				onPointerDown={(event) => {
					const rect = event.currentTarget.getBoundingClientRect();
					const x = event.clientX - rect.left;
					const cursorX = timelineFrameToX(timelineInfo.currentFrame);
					const mode = Math.abs(x - cursorX) <= 50 || event.detail > 1 ? "scrub" : "scroll";
					timelineDragRef.current = { mode, startX: x, startOffset: timelineInfo.windowStart };
					setTimelineFollowCursor(mode !== "scroll");
					props.onPlaybackPlayingChange(false);
					if (mode === "scrub") props.onPlaybackTimeChange(frameToSeconds(timelineXToFrame(x)));
					event.currentTarget.setPointerCapture(event.pointerId);
				}}
				onPointerMove={(event) => {
					const drag = timelineDragRef.current;
					if (!drag) return;
					const rect = event.currentTarget.getBoundingClientRect();
					const x = event.clientX - rect.left;
					if (drag.mode === "scroll") {
						const deltaFrame = Math.round(((x - drag.startX) / Math.max(1, centerWidth - 56)) * timelineInfo.visibleFrames * 2);
						setTimelineOffsetFrame(Math.max(0, drag.startOffset - deltaFrame));
						setTimelineFollowCursor(false);
					} else {
						props.onPlaybackTimeChange(frameToSeconds(timelineXToFrame(x)));
					}
				}}
				onPointerUp={(event) => {
					const drag = timelineDragRef.current;
					const rect = event.currentTarget.getBoundingClientRect();
					const x = event.clientX - rect.left;
					if (drag?.mode === "scrub" && movingKeyTime !== null && !props.readOnly && props.selectedAnimation !== null && props.selectedNodeId !== props.document.root.id) {
						const nextFrame = timelineXToFrame(x);
						const movingFrame = secondsToFrame(movingKeyTime);
						if (nextFrame !== movingFrame) {
							props.onDocumentChange(moveActionKeyFrame(props.document, props.selectedNodeId, props.selectedAnimation, movingKeyTime, frameToSeconds(nextFrame)));
						}
						setMovingKeyTime(null);
					}
					timelineDragRef.current = null;
					event.currentTarget.releasePointerCapture(event.pointerId);
				}}
				style={{ height: timelineHeight, position: "relative", background: "#101010", borderTop: "1px solid #555", touchAction: "none" }}
			>
				<div style={{ position: "absolute", left: 28, right: 28, top: rulerY + 12, height: 6, background: "rgba(255,255,255,0.22)" }} />
				<div style={{ position: "absolute", left: 28, top: rulerY + 12, width: Math.max(0, timelineFrameToX(Math.min(timelineInfo.currentFrame, timelineInfo.windowEnd)) - 28), height: 6, background: "#fff" }} />
				{ticks}
				{[...timelineInfo.frameRanges.other, ...timelineInfo.frameRanges.selected].map((range, index) => {
					if (range.end < timelineInfo.windowStart || range.start > timelineInfo.windowEnd) return null;
					const selectedRange = timelineInfo.frameRanges.selected.indexOf(range) >= 0;
					return <div key={`range-${index}`} style={{ position: "absolute", left: timelineFrameToX(Math.max(timelineInfo.windowStart, range.start)), top: selectedRange ? rulerY + 20 : rulerY + 21, width: Math.max(1, timelineFrameToX(Math.min(timelineInfo.windowEnd, range.end)) - timelineFrameToX(Math.max(timelineInfo.windowStart, range.start))), height: selectedRange ? 7 : 4, background: selectedRange ? "#3dc0fa" : "rgba(61, 192, 250, 0.35)" }} />;
				})}
				{timelineInfo.keyFrames.map((frame) => {
					if (frame < timelineInfo.windowStart || frame > timelineInfo.windowEnd) return null;
					const x = timelineFrameToX(frame);
					const current = frame === timelineInfo.currentFrame;
					return <div key={`key-${frame}`} style={{ position: "absolute", left: x - (current ? 3 : 1), top: current ? rulerY - 12 : rulerY - 10, width: current ? 6 : 2, height: current ? 30 : 28, background: "#3dc0fa" }} />;
				})}
				{timelineInfo.currentFrame >= timelineInfo.windowStart && timelineInfo.currentFrame <= timelineInfo.windowEnd ? (
					<div style={{ position: "absolute", left: timelineFrameToX(timelineInfo.currentFrame) - 6, top: rulerY + 23, width: 0, height: 0, borderLeft: "6px solid transparent", borderRight: "6px solid transparent", borderTop: "8px solid #fff" }} />
				) : null}
			</div>
		);
	};

	return (
		<div
			tabIndex={0}
			onKeyDown={onKeyDown}
			style={{ display: props.active ? "flex" : "none", width: props.width, height: props.height, minWidth: 0, minHeight: 0, background: "#1f1f1f", color: "#d7d7d7", outline: "none", overflow: "hidden" }}
		>
			{renderLeftPanel()}
			<div style={{ width: centerWidth, display: "flex", flexDirection: "column", minWidth: 0, minHeight: 0 }}>
				{props.diagnostics.length > 0 || props.clipDiagnostics.length > 0 || props.runtimeDiagnostics.length > 0 ? (
					<div style={{ maxHeight: 92, overflow: "auto", borderBottom: "1px solid #4a2b2b", background: "#2a1f1f", color: "#f0b7b7", fontSize: 12, padding: "8px 12px", boxSizing: "border-box" }}>
						{props.diagnostics.length > 0 ? <div>{tr(props, "loadFailedNewModel")}</div> : null}
						{props.diagnostics.map((item, index) => <div key={`diagnostic-${index}`}>{item.message}</div>)}
						{props.clipDiagnostics.map((item, index) => <div key={`clip-${index}`}>{item}</div>)}
						{props.runtimeDiagnostics.map((item, index) => <div key={`runtime-${index}`}>{item}</div>)}
					</div>
				) : null}
				<div style={{ height: topToolbarHeight, display: "flex", alignItems: "center", gap: 6, padding: "0 8px", borderBottom: "1px solid #2b2b2b", background: "#1a1a1a", boxSizing: "border-box" }}>
					<button type="button" disabled={props.readOnly || !props.canUndo} onClick={props.onUndo} style={styles.button}>{tr(props, "undo")}</button>
					<button type="button" disabled={props.readOnly || !props.canRedo} onClick={props.onRedo} style={styles.button}>{tr(props, "redo")}</button>
					<button type="button" onClick={() => props.onViewportChange(defaultActionViewport())} style={styles.button}>{tr(props, "origin")}</button>
					<button type="button" onClick={() => props.onViewportChange({ ...props.viewport, zoom: Math.max(0.1, props.viewport.zoom - 0.1) })} style={{ ...styles.button, width: 28 }}>-</button>
					<span style={{ color: "#d7d7d7", fontSize: 12, minWidth: 54, textAlign: "center" }}>{tr(props, "zoomValue", { zoom: (props.viewport.zoom * 100).toFixed(0) })}</span>
					<button type="button" onClick={() => props.onViewportChange({ ...props.viewport, zoom: Math.min(8, props.viewport.zoom + 0.1) })} style={{ ...styles.button, width: 28 }}>+</button>
					<label style={{ color: "#d7d7d7", fontSize: 12, display: "flex", alignItems: "center", gap: 4 }}>
						<input type="checkbox" checked={anisotropicFiltering} onChange={(event) => setAnisotropicFiltering(event.currentTarget.checked)} />
						{tr(props, "anisotropic")}
					</label>
				</div>
				<canvas
					ref={canvasRef}
					width={centerWidth}
					height={canvasHeight}
					onWheel={(event) => {
						event.preventDefault();
						const wheel = Math.max(-1, Math.min(1, -event.deltaY / 100));
						props.onViewportChange({ ...props.viewport, zoom: Math.max(0.1, Math.min(8, props.viewport.zoom + wheel * 0.1)) });
					}}
					onPointerDown={onPointerDown}
					onPointerMove={onPointerMove}
					onPointerUp={onPointerUp}
					onPointerCancel={onPointerUp}
					onContextMenu={(event) => event.preventDefault()}
					style={{ width: centerWidth, height: canvasHeight, background: "#1f1f1f", cursor: gizmoMode !== "select" ? "crosshair" : isPointerDragging ? "grabbing" : "grab", touchAction: "none" }}
				/>
				{renderTimeline()}
			</div>
			{renderRightPanel()}
		</div>
	);
});
