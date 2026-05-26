import React, { memo, useCallback, useEffect, useMemo, useRef, useState } from "react";
import RedoIcon from "@mui/icons-material/Redo";
import UndoIcon from "@mui/icons-material/Undo";
import { IconButton, Stack, Tooltip } from "@mui/material";
import { MacScrollbar } from "mac-scrollbar";
import { BodyIconName, drawBodyIcon } from "../BodyEditor/BodyIcons";
import ClipSliceDialog from "../ClipSliceDialog";
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
	getActionNodeAnchor,
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
type ActionViewToolName = Extract<BodyIconName, "origin" | "zoom">;

type DragState = {
	mode: "pan" | "edit";
	startPointer: { x: number; y: number };
	startPan: { x: number; y: number };
	nodeId: string | null;
	startPosition: { x: number; y: number } | null;
	startScale: { x: number; y: number } | null;
	startRotation: number | null;
	anchorScreen: { x: number; y: number } | null;
	lastPointerAngle: number | null;
	accumulatedRotation: number;
	historyStarted: boolean;
};

const tr = (props: ActionEditorCanvasProps, key: string, options?: Record<string, unknown>) => props.t(`actionEditor.${key}`, options);
const secondsToFrame = (time: number) => Math.max(0, Math.round(time * 60));
const frameToSeconds = (frame: number) => Math.max(0, frame) / 60;
const actionViewToolNames: readonly ActionViewToolName[] = ["origin", "zoom"];

const BodyIconGlyph = memo(function BodyIconGlyph(props: { name: BodyIconName; active?: boolean }) {
	const { name, active } = props;
	const ref = useRef<HTMLCanvasElement | null>(null);
	useEffect(() => {
		const canvas = ref.current;
		const context = canvas?.getContext("2d");
		if (!canvas || !context) return;
		const ratio = window.devicePixelRatio || 1;
		canvas.width = 24 * ratio;
		canvas.height = 24 * ratio;
		canvas.style.width = "24px";
		canvas.style.height = "24px";
		context.setTransform(ratio, 0, 0, ratio, 0, 0);
		context.clearRect(0, 0, 24, 24);
		drawBodyIcon(context, name, 0, 0, 24, active ? "#fac03d" : "#d7d7d7");
	}, [active, name]);
	return <canvas ref={ref} aria-hidden="true" />;
});
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

const themeColor = "#fac03d";
const themeTextColor = "#ffe7ad";
const themePanelBg = "#5f4917";
const themeRangeBg = "rgba(250, 192, 61, 0.35)";

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
		border: `1px solid ${themeColor}`,
		background: themePanelBg,
		color: themeTextColor,
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

const drawAnchorCross = (ctx: CanvasRenderingContext2D, center: { x: number; y: number }, color: string) => {
	ctx.strokeStyle = color;
	ctx.lineWidth = 2;
	ctx.beginPath();
	ctx.moveTo(center.x - 7, center.y);
	ctx.lineTo(center.x + 7, center.y);
	ctx.moveTo(center.x, center.y - 7);
	ctx.lineTo(center.x, center.y + 7);
	ctx.stroke();
};

const getScreenBounds = (points: Array<{ x: number; y: number }>) => {
	const minX = Math.min(...points.map((point) => point.x));
	const maxX = Math.max(...points.map((point) => point.x));
	const minY = Math.min(...points.map((point) => point.y));
	const maxY = Math.max(...points.map((point) => point.y));
	return {
		minX,
		maxX,
		minY,
		maxY,
		width: maxX - minX,
		height: maxY - minY,
		center: { x: (minX + maxX) * 0.5, y: (minY + maxY) * 0.5 },
	};
};

const drawToolGizmo = (
	ctx: CanvasRenderingContext2D,
	props: ActionEditorCanvasProps,
	hiddenIds: Set<string>,
	gizmoMode: GizmoMode,
	rects: ActionRenderRect[],
	area: { x: number; y: number; width: number; height: number },
) => {
	if (props.editMode === "look" || props.selectedNodeId === props.document.root.id) return;
	const rect = rects.find((item) => item.nodeId === props.selectedNodeId);
	if (rect && (!rect.visible || !isNodePreviewVisible(props, hiddenIds, rect.nodeId))) return;
	if (!rect && !isNodePreviewVisible(props, hiddenIds, props.selectedNodeId)) return;
	const fallbackAnchor = rect ? null : getActionNodeAnchor(props.document, props.clipDocument, props.selectedLook, props.selectedNodeId, props.selectedAnimation, props.playbackTime);
	if (!rect && (!fallbackAnchor || !fallbackAnchor.visible)) return;
	const corners = rect ? renderRectCornersToViewport(rect, props.viewport, area) : null;
	const anchor = rect ? modelToScreen(rect.anchor, props.viewport, area) : modelToScreen(fallbackAnchor!.anchor, props.viewport, area);
	ctx.save();
	ctx.strokeStyle = "#ffffff";
	ctx.fillStyle = "#ffffff";
	ctx.lineWidth = 1.5;
	const selectedPreviewColor = "#65d6ff";
	if (gizmoMode === "select") {
		drawAnchorCross(ctx, anchor, selectedPreviewColor);
	} else if (gizmoMode === "move") {
		const radius = 34;
		ctx.beginPath();
		ctx.arc(anchor.x, anchor.y, 3, 0, Math.PI * 2);
		ctx.fill();
		ctx.strokeStyle = selectedPreviewColor;
		ctx.beginPath();
		ctx.moveTo(anchor.x, anchor.y);
		ctx.lineTo(anchor.x + radius, anchor.y);
		ctx.lineTo(anchor.x + radius - 8, anchor.y - 5);
		ctx.moveTo(anchor.x + radius, anchor.y);
		ctx.lineTo(anchor.x + radius - 8, anchor.y + 5);
		ctx.moveTo(anchor.x - radius * 0.55, anchor.y);
		ctx.lineTo(anchor.x, anchor.y);
		ctx.moveTo(anchor.x, anchor.y);
		ctx.lineTo(anchor.x, anchor.y - radius);
		ctx.lineTo(anchor.x - 5, anchor.y - radius + 8);
		ctx.moveTo(anchor.x, anchor.y - radius);
		ctx.lineTo(anchor.x + 5, anchor.y - radius + 8);
		ctx.moveTo(anchor.x, anchor.y + radius * 0.55);
		ctx.lineTo(anchor.x, anchor.y);
		ctx.stroke();
	} else if (gizmoMode === "scale") {
		if (rect) {
			const box = getScreenBounds(corners!);
			const padding = Math.max(6, Math.min(18, Math.max(box.width, box.height) * 0.12));
			const left = box.minX - padding;
			const right = box.maxX + padding;
			const top = box.minY - padding;
			const bottom = box.maxY + padding;
			ctx.strokeStyle = selectedPreviewColor;
			ctx.strokeRect(left, top, right - left, bottom - top);
			ctx.fillStyle = "#ffffff";
			for (const point of [
				[left, top],
				[(left + right) / 2, top],
				[right, top],
				[right, (top + bottom) / 2],
				[right, bottom],
				[(left + right) / 2, bottom],
				[left, bottom],
				[left, (top + bottom) / 2],
			]) {
				ctx.fillRect(point[0] - 3, point[1] - 3, 6, 6);
			}
		} else {
			drawAnchorCross(ctx, anchor, selectedPreviewColor);
		}
	} else if (gizmoMode === "rotate") {
		const box = rect ? getScreenBounds(corners!) : null;
		const radius = box ? Math.max(28, Math.sqrt(box.width * box.width + box.height * box.height) * 0.5 + 18) : 34;
		ctx.strokeStyle = selectedPreviewColor;
		ctx.beginPath();
		ctx.arc(anchor.x, anchor.y, radius, 0, Math.PI * 2);
		ctx.stroke();
		const angle = -Math.PI * 0.2;
		const end = { x: anchor.x + Math.cos(angle) * radius, y: anchor.y + Math.sin(angle) * radius };
		ctx.beginPath();
		ctx.moveTo(anchor.x, anchor.y);
		ctx.lineTo(end.x, end.y);
		ctx.lineTo(end.x - 9, end.y - 2);
		ctx.moveTo(end.x, end.y);
		ctx.lineTo(end.x - 4, end.y + 8);
		ctx.stroke();
		ctx.fillStyle = "#ffffff";
		ctx.beginPath();
		ctx.arc(anchor.x, anchor.y, 3, 0, Math.PI * 2);
		ctx.fill();
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
		ctx.fillStyle = themeColor;
		ctx.strokeStyle = "rgba(250, 192, 61, 0.85)";
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
		if (rect.nodeId === props.selectedNodeId) {
			const bounds = getScreenBounds(corners);
			const padding = 6;
			ctx.save();
			ctx.strokeStyle = "rgba(170, 176, 184, 0.95)";
			ctx.lineWidth = 1.5;
			ctx.setLineDash([5, 3]);
			ctx.strokeRect(bounds.minX - padding, bounds.minY - padding, bounds.width + padding * 2, bounds.height + padding * 2);
			ctx.restore();
		} else {
			ctx.strokeStyle = withAlpha("#0b0b0b", Math.max(0.45, rect.opacity));
			ctx.lineWidth = 1;
			drawPath(ctx, corners);
			ctx.stroke();
		}
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
	format?: (value: number) => string;
	readOnly?: boolean;
	onChange: (value: number, options?: ActionDocumentChangeOptions) => void;
}) {
	const { label, value, step = 1, format, readOnly, onChange } = props;
	const formatDefault = (item: number) => Number.isInteger(item) ? String(item) : item.toFixed(4).replace(/\.?0+$/, "");
	const displayValue = format ? format(value) : formatDefault(value);
	const [text, setText] = useState(displayValue);
	const startedRef = useRef(false);
	useEffect(() => setText(format ? format(value) : formatDefault(value)), [format, value]);
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

const TreeEyeIcon = memo(function TreeEyeIcon(props: { visible: boolean }) {
	const { visible } = props;
	return (
		<svg width="22" height="22" viewBox="0 0 22 22" aria-hidden="true" style={{ display: "block" }}>
			<path
				d="M2.5 11C4.8 7.8 7.6 6.2 11 6.2S17.2 7.8 19.5 11C17.2 14.2 14.4 15.8 11 15.8S4.8 14.2 2.5 11Z"
				fill="none"
				stroke={visible ? "#d6d6d6" : "#686868"}
				strokeWidth="1.7"
				strokeLinejoin="round"
			/>
			{visible ? (
				<circle cx="11" cy="11" r="2.4" fill="#d6d6d6" />
			) : (
				<line x1="4.2" y1="17" x2="17.8" y2="5" stroke="#686868" strokeWidth="1.8" />
			)}
		</svg>
	);
});

const TreeClipPreview = memo(function TreeClipPreview(props: {
	editor: ActionEditorCanvasProps;
	node: ActionNode;
	onSelect: () => void;
}) {
	const { editor, node, onSelect } = props;
	const canvasRef = useRef<HTMLCanvasElement | null>(null);
	const previewSize = 30;
	const clipRect = node.clip ? editor.clipDocument?.rects[node.clip] : undefined;

	useEffect(() => {
		const canvas = canvasRef.current;
		const context = canvas?.getContext("2d");
		if (!canvas || !context) return;
		const ratio = window.devicePixelRatio || 1;
		canvas.width = previewSize * ratio;
		canvas.height = previewSize * ratio;
		canvas.style.width = `${previewSize}px`;
		canvas.style.height = `${previewSize}px`;
		context.setTransform(ratio, 0, 0, ratio, 0, 0);
		context.clearRect(0, 0, previewSize, previewSize);
		context.fillStyle = node.clip === "" ? "#252525" : "#303030";
		context.fillRect(0, 0, previewSize, previewSize);
		if (node.clip === "") {
			context.strokeStyle = "#686868";
			context.lineWidth = 1;
			context.strokeRect(6.5, 6.5, previewSize - 13, previewSize - 13);
			return;
		}
		if (!editor.atlasImage || !clipRect || clipRect.width <= 0 || clipRect.height <= 0) return;
		const scale = Math.min(previewSize / clipRect.width, previewSize / clipRect.height);
		const imageWidth = Math.max(1, clipRect.width * scale);
		const imageHeight = Math.max(1, clipRect.height * scale);
		const x = (previewSize - imageWidth) / 2;
		const y = (previewSize - imageHeight) / 2;
		context.imageSmoothingEnabled = false;
		context.drawImage(
			editor.atlasImage.image,
			clipRect.x,
			clipRect.y,
			clipRect.width,
			clipRect.height,
			x,
			y,
			imageWidth,
			imageHeight,
		);
	}, [clipRect, editor.atlasImage, node.clip]);

	return (
		<button
			type="button"
			onClick={onSelect}
			style={{
				width: previewSize,
				height: previewSize,
				padding: 0,
				border: 0,
				background: "transparent",
				cursor: "pointer",
				flexShrink: 0,
			}}
		>
			<canvas ref={canvasRef} aria-hidden="true" style={{ display: "block" }} />
		</button>
	);
});

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
		<div style={{ minWidth: "max-content" }}>
			<div style={{ display: "flex", alignItems: "center", gap: 2, paddingLeft: depth * 14, minHeight: 34, width: "max-content", minWidth: "100%" }}>
				<button
					type="button"
					title={previewVisible ? tr(editor, "hide") : tr(editor, "showAll")}
					onClick={() => {
						const next = new Set(hiddenIds);
						if (directHidden) next.delete(node.id);
						else next.add(node.id);
						onHiddenChange(next);
					}}
					style={{
						width: 22,
						height: 30,
						padding: 0,
						border: 0,
						background: "transparent",
						cursor: "pointer",
						flexShrink: 0,
					}}
				>
					<TreeEyeIcon visible={previewVisible} />
				</button>
				<TreeClipPreview
					editor={editor}
					node={node}
					onSelect={() => editor.onSelectionChange(node.id)}
				/>
				<button
					type="button"
					onClick={() => editor.onSelectionChange(node.id)}
					style={{
						flex: 1,
						height: 30,
						minWidth: "max-content",
						textAlign: "left",
						padding: "0 10px",
						overflow: "visible",
						whiteSpace: "nowrap",
						border: "1px solid transparent",
						background: selected ? "#3a3a3a" : "transparent",
						color: "#d7d7d7",
						cursor: "pointer",
						fontSize: 16,
						boxSizing: "border-box",
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
	allowNone?: boolean;
	onSelect: (clip: string) => void;
}) {
	const { editor, selectedClip, allowNone = true, onSelect } = props;
	const [open, setOpen] = useState(false);
	const selectedRect = selectedClip ? editor.clipDocument?.rects[selectedClip] : undefined;
	const rects = useMemo(() => Object.values(editor.clipDocument?.rects ?? {}).sort((a, b) => a.name.localeCompare(b.name)), [editor.clipDocument]);
	const disabled = editor.readOnly || !editor.clipDocument || Object.keys(editor.clipDocument.rects).length === 0;
	return (
		<div style={{ display: "grid", gridTemplateColumns: allowNone ? "minmax(0, 1fr) auto auto" : "minmax(0, 1fr) auto", gap: 4 }}>
			<input
				type="text"
				value={selectedClip || tr(editor, "none")}
				disabled
				style={styles.input}
			/>
			<button type="button" disabled={disabled} onClick={() => setOpen(true)} style={styles.button}>{editor.t("bodyEditor.chooseClipSlice")}</button>
			{allowNone ? <button type="button" disabled={editor.readOnly || selectedClip === ""} onClick={() => onSelect("")} style={styles.button}>{tr(editor, "none")}</button> : null}
			{selectedRect ? <div style={{ gridColumn: "1 / -1", color: "#8f9aa6", fontSize: 11 }}>{selectedRect.width} x {selectedRect.height}</div> : null}
			<ClipSliceDialog
				open={open}
				title={editor.t("bodyEditor.chooseClipSlice")}
				clipLabel={editor.document.clipFile}
				rects={rects}
				atlasImage={editor.atlasImage?.image ?? null}
				filterPlaceholder={editor.t("bodyEditor.filterSlices")}
				noSlicesText={editor.t("bodyEditor.noSlices")}
				cancelText={editor.t("action.cancel")}
				selectedRectName={selectedClip}
				onClose={() => setOpen(false)}
				onSelect={(rect) => {
					onSelect(rect.name);
					setOpen(false);
				}}
			/>
		</div>
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
	const topToolbarHeight = 44;
	const timelineHeight = props.editMode === "animation" && props.selectedAnimation !== null ? 72 : 0;
	const centerWidth = Math.max(1, props.width - leftPanelWidth - rightPanelWidth);
	const canvasHeight = Math.max(1, props.height - topToolbarHeight - timelineHeight);

	const selected = findActionNode(props.document.root, props.selectedNodeId) ?? props.document.root;
	const selectedFrame = getSelectedAnimationKeyFrame(props);
	const selectedTrack = props.selectedAnimation && selected.id !== props.document.root.id ? selected.tracks[props.selectedAnimation] : undefined;
	const toolSelectOnly = props.editMode === "look"
		|| selected.id === props.document.root.id
		|| props.playbackPlaying
		|| (props.editMode === "animation" && selectedTrack?.type === "frame")
		|| (props.editMode === "animation" && selectedFrame === null);
	const rects = useMemo(
		() => buildActionRenderRects(props.document, props.clipDocument, props.selectedLook, props.selectedAnimation, props.playbackTime),
		[props.clipDocument, props.document, props.playbackTime, props.selectedAnimation, props.selectedLook],
	);

	useEffect(() => {
		if (toolSelectOnly && gizmoMode !== "select") setGizmoMode("select");
	}, [gizmoMode, toolSelectOnly]);

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
		const dragAnchor = dragRect
			? dragRect.anchor
			: dragNodeId
				? getActionNodeAnchor(props.document, props.clipDocument, props.selectedLook, dragNodeId, props.selectedAnimation, props.playbackTime)?.anchor ?? null
				: null;
		const dragAnchorScreen = dragAnchor ? modelToScreen(dragAnchor, props.viewport, area) : null;
		dragRef.current = {
			mode: !props.readOnly && props.editMode !== "look" && gizmoMode !== "select" && dragNodeId !== null ? "edit" : "pan",
			startPointer: { x: event.clientX, y: event.clientY },
			startPan: { ...props.viewport.pan },
			nodeId: dragNodeId,
			startPosition: dragFrame ? { ...dragFrame.transform.position } : (dragNode ? { ...dragNode.transform.position } : null),
			startScale: dragFrame ? { ...dragFrame.transform.scale } : (dragNode ? { ...dragNode.transform.scale } : null),
			startRotation: dragFrame ? dragFrame.transform.rotation : (dragNode ? dragNode.transform.rotation : null),
			anchorScreen: dragAnchorScreen,
			lastPointerAngle: dragAnchorScreen ? pointerAngleDegrees(dragAnchorScreen, point) : null,
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
				if (!drag.startScale) return transform;
				return {
					...transform,
					scale: {
						x: Math.max(0.01, snapValue(drag.startScale.x + delta.x / props.viewport.zoom / 100, fixedSnap, 0.1)),
						y: Math.max(0.01, snapValue(drag.startScale.y - delta.y / props.viewport.zoom / 100, fixedSnap, 0.1)),
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

	const runViewTool = useCallback((name: ActionViewToolName) => {
		if (name === "origin") {
			props.onViewportChange(defaultActionViewport());
		} else if (name === "zoom") {
			props.onViewportChange({ ...props.viewport, zoom: props.viewport.zoom >= 2 ? 0.5 : props.viewport.zoom >= 1 ? 2 : 1 });
		}
	}, [props]);

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
			<div style={{ flex: 1, minHeight: 0, display: "flex", flexDirection: "column" }}>
				{leftTab === "tree" ? (
					<>
						{renderNodeCommands()}
						<div style={{ flex: 1, minHeight: 0 }}>
							<MacScrollbar skin="dark" style={{ width: "100%", height: "100%" }}>
								<div style={{ minWidth: "max-content", paddingBottom: 8 }}>
									<NodeTree editor={props} node={props.document.root} depth={0} hiddenIds={previewHiddenNodeIds} moveSourceId={moveSourceId} onHiddenChange={setPreviewHiddenNodeIds} onMoveSourceChange={setMoveSourceId} />
								</div>
							</MacScrollbar>
						</div>
					</>
				) : null}
				{leftTab !== "tree" ? (
					<MacScrollbar skin="dark" style={{ width: "100%", height: "100%" }}>
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
				) : null}
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
			<div style={{ border: "1px solid #2b2b2b", height: 180, marginBottom: 8 }}>
				<MacScrollbar skin="dark" style={{ width: "100%", height: "100%" }}>
					{props.document.looks.map((look) => (
						<button key={look} type="button" onClick={() => { props.onLookSelect(look); props.onAnimationSelect(null); props.onPlaybackPlayingChange(false); }} style={{ ...styles.button, ...(props.selectedLook === look ? styles.buttonActive : null), width: "100%", textAlign: "left", borderWidth: 0, borderBottom: "1px solid #2b2b2b" }}>{look}</button>
					))}
				</MacScrollbar>
			</div>
			{props.selectedLook !== null ? (
				<>
					{selected.id !== props.document.root.id ? (
						<CheckField label={tr(props, "hide")} checked={selected.hiddenInLooks.indexOf(props.selectedLook) >= 0} readOnly={props.readOnly} onChange={(hidden) => props.onDocumentChange(setActionNodeLookHidden(props.document, selected.id, props.selectedLook!, hidden))} />
					) : null}
				</>
			) : <div style={{ color: "#8f9aa6", fontSize: 12 }}>{tr(props, "selectLookHint")}</div>}
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
					<ClipChooser editor={props} selectedClip={spec.clipName} allowNone={false} onSelect={(clipName) => updateTrack((item, delay) => ({ spec: { ...item, clipFile: props.document.clipFile, clipName }, delay }))} />
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
		if (!frame) {
			return (
				<div>
					<div style={{ color: "#8f9aa6", fontSize: 12 }}>{tr(props, "moveTimeHeadToKeyframe")}</div>
				</div>
			);
		}
		const firstKeyFrame = isFirstActionKeyFrame(props.document, selected.id, props.selectedAnimation, frame.time);
		return (
			<div>
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

	const visibleGizmoModes: GizmoMode[] = toolSelectOnly ? ["select"] : ["select", "move", "scale", "rotate"];

	const renderAnimationsPanel = () => {
		const duration = props.selectedAnimation ? getActionAnimationDuration(props.document, props.selectedAnimation) : 0;
		const track = props.selectedAnimation && selected.id !== props.document.root.id ? selected.tracks[props.selectedAnimation] : undefined;
		const currentFrame = track?.type === "key" ? track.keyframes.find((frame) => Math.abs(frame.time - props.playbackTime) < 1 / 120) : undefined;
		const editableTrackContent = props.selectedAnimation !== null && !props.playbackPlaying && selected.id !== props.document.root.id ? (
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
				{renderAnimationKeyFrameProperties()}
			</>
		) : null;
		return (
			<div style={{ height: "100%", minHeight: 0, display: "flex", flexDirection: "column" }}>
				<div style={{ padding: 8, flexShrink: 0 }}>
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
						<div style={{ border: "1px solid #2b2b2b", height: 120 }}>
							<MacScrollbar skin="dark" style={{ width: "100%", height: "100%" }}>
								{props.document.animations.map((animation) => <button key={animation} type="button" onClick={() => { props.onAnimationSelect(animation); props.onPlaybackTimeChange(0); }} style={{ ...styles.button, ...(props.selectedAnimation === animation ? styles.buttonActive : null), width: "100%", textAlign: "left", borderWidth: 0, borderBottom: "1px solid #2b2b2b" }}>{animation}</button>)}
							</MacScrollbar>
						</div>
					</div>
					<div>
						<div style={styles.label}>{tr(props, "look")}</div>
						<div style={{ border: "1px solid #2b2b2b", height: 120 }}>
							<MacScrollbar skin="dark" style={{ width: "100%", height: "100%" }}>
								<button type="button" onClick={() => props.onLookSelect(null)} style={{ ...styles.button, ...(props.selectedLook === null ? styles.buttonActive : null), width: "100%", textAlign: "left", borderWidth: 0, borderBottom: "1px solid #2b2b2b" }}>{tr(props, "defaultLook")}</button>
								{props.document.looks.map((look) => <button key={look} type="button" onClick={() => props.onLookSelect(look)} style={{ ...styles.button, ...(props.selectedLook === look ? styles.buttonActive : null), width: "100%", textAlign: "left", borderWidth: 0, borderBottom: "1px solid #2b2b2b" }}>{look}</button>)}
							</MacScrollbar>
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
						<NumberField label={tr(props, "time")} value={props.playbackTime} step={1 / 60} format={(value) => value.toFixed(2)} readOnly={props.readOnly} onChange={(time) => props.onPlaybackTimeChange(Math.max(0, time))} />
						<div style={{ color: "#8f9aa6", fontSize: 12, marginBottom: 8 }}>{tr(props, "frameCounter", { current: Math.round(props.playbackTime * 60), total: Math.round(duration * 60) })}</div>
					</>
					)}
				</div>
					{editableTrackContent ? (
						<div style={{ flex: 1, minHeight: 0 }}>
							<MacScrollbar skin="dark" style={{ width: "100%", height: "100%" }}>
								<div style={{ padding: "0 8px 80px" }}>{editableTrackContent}</div>
							</MacScrollbar>
						</div>
					) : null}
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
				{props.editMode === "animation" ? renderAnimationsPanel() : (
					<MacScrollbar skin="dark" style={{ width: "100%", height: "100%" }}>
						{props.editMode === "pose" ? renderPosePanel() : null}
						{props.editMode === "look" ? renderLooksPanel() : null}
					</MacScrollbar>
				)}
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
			if (frame % 10 === 0) ticks.push(<div key={`label-${frame}`} style={{ position: "absolute", left: x - 5, top: 6, color: "#d6d6d6", fontSize: 10, userSelect: "none", pointerEvents: "none" }}>{frame}</div>);
		}
		return (
			<div
				onDoubleClick={(event) => {
					const rect = event.currentTarget.getBoundingClientRect();
					const x = event.clientX - rect.left;
					props.onPlaybackPlayingChange(false);
					setTimelineFollowCursor(true);
					props.onPlaybackTimeChange(frameToSeconds(timelineXToFrame(x)));
					event.preventDefault();
					event.stopPropagation();
				}}
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
				style={{ height: timelineHeight, position: "relative", background: "#101010", borderTop: "1px solid #555", touchAction: "none", userSelect: "none" }}
			>
				<div style={{ position: "absolute", left: 28, right: 28, top: rulerY + 12, height: 6, background: "rgba(255,255,255,0.22)" }} />
				<div style={{ position: "absolute", left: 28, top: rulerY + 12, width: Math.max(0, timelineFrameToX(Math.min(timelineInfo.currentFrame, timelineInfo.windowEnd)) - 28), height: 6, background: "#fff" }} />
				{ticks}
				{[...timelineInfo.frameRanges.other, ...timelineInfo.frameRanges.selected].map((range, index) => {
					if (range.end < timelineInfo.windowStart || range.start > timelineInfo.windowEnd) return null;
					const selectedRange = timelineInfo.frameRanges.selected.indexOf(range) >= 0;
					return <div key={`range-${index}`} style={{ position: "absolute", left: timelineFrameToX(Math.max(timelineInfo.windowStart, range.start)), top: selectedRange ? rulerY + 20 : rulerY + 21, width: Math.max(1, timelineFrameToX(Math.min(timelineInfo.windowEnd, range.end)) - timelineFrameToX(Math.max(timelineInfo.windowStart, range.start))), height: selectedRange ? 7 : 4, background: selectedRange ? themeColor : themeRangeBg }} />;
				})}
				{timelineInfo.keyFrames.map((frame) => {
					if (frame < timelineInfo.windowStart || frame > timelineInfo.windowEnd) return null;
					const x = timelineFrameToX(frame);
					const current = frame === timelineInfo.currentFrame;
					return <div key={`key-${frame}`} style={{ position: "absolute", left: x - (current ? 3 : 1), top: current ? rulerY - 12 : rulerY - 10, width: current ? 6 : 2, height: current ? 30 : 28, background: themeColor }} />;
				})}
				{timelineInfo.currentFrame >= timelineInfo.windowStart && timelineInfo.currentFrame <= timelineInfo.windowEnd ? (
					<div style={{ position: "absolute", left: timelineFrameToX(timelineInfo.currentFrame) - 6, top: rulerY + 23, width: 0, height: 0, borderLeft: "6px solid transparent", borderRight: "6px solid transparent", borderBottom: "8px solid #fff" }} />
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
				<div style={{ height: topToolbarHeight, flexShrink: 0, display: "flex", alignItems: "center", gap: 8, paddingTop: 2, paddingLeft: 10, paddingRight: 10, borderBottom: "1px solid #2b2b2b", background: "#1a1a1a", boxSizing: "border-box" }}>
					<div style={{ display: "flex", alignItems: "center", gap: 6 }}>
						<span style={{ color: "#9aa4af", fontSize: 12, marginRight: 2 }}>{props.t("bodyEditor.toolbar.view")}</span>
						{actionViewToolNames.map((name) => (
							<button
								key={name}
								type="button"
								title={tr(props, name)}
								aria-label={tr(props, name)}
								onClick={() => runViewTool(name)}
								style={{
									width: 30,
									height: 30,
									border: "1px solid #343434",
									background: "#303030",
									padding: 3,
									cursor: "pointer",
								}}
							>
								<BodyIconGlyph name={name} />
							</button>
						))}
						<span style={{ color: "#d7d7d7", fontSize: 12, minWidth: 54, textAlign: "center" }}>{tr(props, "zoomValue", { zoom: (props.viewport.zoom * 100).toFixed(0) })}</span>
					</div>
					<div style={{ display: "flex", alignItems: "center", gap: 4, paddingLeft: 4 }}>
						<span style={{ color: "#9aa4af", fontSize: 12, marginRight: 2 }}>{tr(props, "tool")}</span>
						{visibleGizmoModes.map((mode) => {
							const selectedMode = gizmoMode === mode;
							return (
								<button
									key={mode}
									type="button"
									disabled={props.readOnly}
									onClick={() => setGizmoMode(mode)}
									style={{
										height: 30,
										minWidth: 52,
										border: "1px solid " + (selectedMode ? themeColor : "#343434"),
										background: selectedMode ? themePanelBg : "#303030",
										color: selectedMode ? themeTextColor : "#d7d7d7",
										cursor: props.readOnly ? "default" : "pointer",
										opacity: props.readOnly ? 0.55 : 1,
									}}
								>
									{tr(props, `toolMode.${mode}`)}
								</button>
							);
						})}
						{!toolSelectOnly ? (
							<label style={{ display: "flex", alignItems: "center", gap: 4, color: "#d7d7d7", fontSize: 12, marginLeft: 4 }}>
								<input type="checkbox" checked={fixedSnap} disabled={props.readOnly} onChange={(event) => setFixedSnap(event.currentTarget.checked)} />
								{tr(props, "fixed")}
							</label>
						) : null}
					</div>
					<label style={{ color: "#d7d7d7", fontSize: 12, display: "flex", alignItems: "center", gap: 4 }}>
						<input type="checkbox" checked={anisotropicFiltering} onChange={(event) => setAnisotropicFiltering(event.currentTarget.checked)} />
						{tr(props, "anisotropic")}
					</label>
					<Stack direction="row" spacing={1}>
						<Tooltip title={tr(props, "undo")}>
							<span>
								<IconButton
									size="small"
									disabled={props.readOnly || !props.canUndo}
									onClick={props.onUndo}
									sx={{
										width: 30,
										height: 30,
										border: "1px solid #343434",
										borderRadius: 0,
										background: "#303030",
										color: "#d7d7d7",
										"&:hover": { background: "#383838" },
										"&.Mui-disabled": {
											color: "rgba(215, 215, 215, 0.32)",
											borderColor: "#2b2b2b",
											background: "#252525",
										},
									}}
								>
									<UndoIcon fontSize="small" />
								</IconButton>
							</span>
						</Tooltip>
						<Tooltip title={tr(props, "redo")}>
							<span>
								<IconButton
									size="small"
									disabled={props.readOnly || !props.canRedo}
									onClick={props.onRedo}
									sx={{
										width: 30,
										height: 30,
										border: "1px solid #343434",
										borderRadius: 0,
										background: "#303030",
										color: "#d7d7d7",
										"&:hover": { background: "#383838" },
										"&.Mui-disabled": {
											color: "rgba(215, 215, 215, 0.32)",
											borderColor: "#2b2b2b",
											background: "#252525",
										},
									}}
								>
									<RedoIcon fontSize="small" />
								</IconButton>
							</span>
						</Tooltip>
					</Stack>
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
