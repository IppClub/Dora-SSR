import React, { memo, useCallback, useEffect, useMemo, useRef } from "react";
import { ImGui, ImGui_Impl } from "@zhobo63/imgui-ts";
import type { ActionClipDocument } from "./ActionClip";
import type { ActionDocument, ActionDiagnostic, ActionFrameTrack, ActionKeyFrame, ActionNode } from "./ActionDocument";
import type { ActionViewport } from "./ActionEditorState";
import {
	addActionLook,
	addChildActionNode,
	addActionKeyPoint,
	cloneActionDocument,
	countActionNodes,
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
	pasteActionKeyFrame,
	parseActionFrameSpec,
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
	screenToModel,
	screenDeltaToNodeLocalDelta,
} from "./ActionRender";
import { ActionImGuiRuntime, ActionImGuiFrame } from "./ActionImGuiRuntime";

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

const tr = (props: ActionEditorCanvasProps, key: string, options?: Record<string, unknown>) => props.t(`actionEditor.${key}`, options);

type PanelState = {
	moveSourceId: string | null;
	copiedKeyFrame: ActionKeyFrame | null;
	movingKeyTime: number | null;
	gizmoMode: "select" | "move" | "scale" | "rotate";
	fixedSnap: boolean;
	anisotropicFiltering: boolean;
	lastDragDelta: { x: number; y: number };
	viewportDragButton: 0 | 1 | null;
	viewportDragAction: "pan" | "edit" | null;
	viewportArea: { x: number; y: number; width: number; height: number };
	imguiCapturesPointer: boolean;
	dragNodeId: string | null;
	dragStartPosition: { x: number; y: number } | null;
	dragStartRotation: number | null;
	dragStartPointer: { x: number; y: number } | null;
	dragStartPointerAngle: number | null;
	dragLastPointerAngle: number | null;
	dragAccumulatedRotationDelta: number;
	dragAnchorScreen: { x: number; y: number } | null;
	timelineDragMode: "scrub" | "scroll" | null;
	timelineDragStartMouseX: number;
	timelineDragStartOffsetFrame: number;
	timelineOffsetFrame: number;
	timelineFollowCursor: boolean;
	modeTabsNeedSync: boolean;
	dragHistoryStarted: boolean;
	inputHistoryStarted: Record<string, boolean>;
	previewHiddenNodeIds: Set<string>;
	visibleKeyPointIndexes: Set<number>;
};

type ActionAtlasTexture = {
	path: string;
	width: number;
	height: number;
	anisotropicFiltering: boolean;
	texture: WebGLTexture;
	native: any;
};

const gray = 0xff1f1f1f;
const grid = 0xff303030;
const normalNode = 0xff8f6c3d;
const missingNode = 0xff4060bf;
const selectedNode = 0xff4cc6ff;
const nodeBorder = 0xff0b0b0b;
const originColor = 0xff585858;
const modelBoundsColor = 0xff3d6c8f;
const keyPointColor = 0xff42d6ff;
const gizmoColor = 0xffffffff;
const gizmoAccentColor = 0xff00c8ff;
const timelineBgColor = 0xff101010;
const timelineBorderColor = 0xffffffff;
const timelineProgressColor = 0xffffffff;
const timelineTickColor = 0xffd6d6d6;
const timelineCursorColor = 0xffffffff;
const timelineKeyColor = 0xff3dc0fa;
const lookListHeight = 180;
const animationLookListHeight = 120;
const animationListHeight = 180;
const treeIndentWidth = 14;
const treeEyeWidth = 22;
const treePreviewSize = 30;
const treeLabelGap = 10;
const easeNames = [
	"Linear",
	"InQuad",
	"OutQuad",
	"InOutQuad",
	"InCubic",
	"OutCubic",
	"InOutCubic",
	"InQuart",
	"OutQuart",
	"InOutQuart",
	"InQuint",
	"OutQuint",
	"InOutQuint",
	"InSine",
	"OutSine",
	"InOutSine",
	"InExpo",
	"OutExpo",
	"InOutExpo",
	"InCirc",
	"OutCirc",
	"InOutCirc",
	"InElastic",
	"OutElastic",
	"InOutElastic",
	"InBack",
	"OutBack",
	"InOutBack",
	"InBounce",
	"OutBounce",
	"InOutBounce",
	"OutInQuad",
	"OutInCubic",
	"OutInQuart",
	"OutInQuint",
	"OutInSine",
	"OutInExpo",
	"OutInCirc",
	"OutInElastic",
	"OutInBack",
	"OutInBounce",
];

const vec4 = (x: number, y: number, z: number, w: number) => ({ x, y, z, w });
const themeColor = vec4(0xfa / 0xff, 0xc0 / 0xff, 0x3d / 0xff, 1);
const activeButtonColor = vec4(themeColor.x * 0.62, themeColor.y * 0.62, themeColor.z * 0.62, 0.95);
const activeButtonHoveredColor = vec4(themeColor.x * 0.72, themeColor.y * 0.72, themeColor.z * 0.72, 1);
const activeButtonPressedColor = vec4(themeColor.x * 0.9, themeColor.y * 0.9, themeColor.z * 0.9, 1);

const snapValue = (value: number, fixed: boolean, step: number) => fixed ? Math.round(value / step) * step : value;

const pointerAngleStepDelta = (degrees: number) => {
	let result = degrees;
	while (result > 180) result -= 360;
	while (result < -180) result += 360;
	return result;
};

const pointerAngleDegrees = (center: { x: number; y: number }, point: { x: number; y: number }) => {
	return Math.atan2(point.y - center.y, point.x - center.x) * 180 / Math.PI;
};

const secondsToFrame = (time: number) => Math.max(0, Math.round(time * 60));

const frameToSeconds = (frame: number) => Math.max(0, frame) / 60;

const withAlpha = (color: number, opacity: number) => {
	const alpha = Math.max(0, Math.min(255, Math.round(Math.max(0, Math.min(1, opacity)) * 255)));
	return ((color & 0x00ffffff) | (alpha << 24)) >>> 0;
};

const activeButton = (
	imgui: ActionImGuiFrame,
	label: string,
	size: {x: number; y: number},
) => {
	imgui.PushStyleColor(imgui.Col.Button, activeButtonColor);
	imgui.PushStyleColor(imgui.Col.ButtonHovered, activeButtonHoveredColor);
	imgui.PushStyleColor(imgui.Col.ButtonActive, activeButtonPressedColor);
	try {
		return imgui.Button(label, size);
	} finally {
		imgui.PopStyleColor(3);
	}
};

const boundedChildHeight = (imgui: ActionImGuiFrame, preferred: number, reserve = 0) => Math.max(80, Math.min(preferred, imgui.GetContentRegionAvail().y - reserve));

const isPreviewHidden = (panelState: PanelState, nodeId: string) => panelState.previewHiddenNodeIds.has(nodeId);

const isPreviewHiddenInherited = (node: ActionNode, nodeId: string, hiddenIds: Set<string>, inherited = false): boolean | null => {
	const hidden = inherited || hiddenIds.has(node.id);
	if (node.id === nodeId) return hidden;
	for (const child of node.children) {
		const result = isPreviewHiddenInherited(child, nodeId, hiddenIds, hidden);
		if (result !== null) return result;
	}
	return null;
};

const isNodePreviewVisible = (props: ActionEditorCanvasProps, panelState: PanelState, nodeId: string) => {
	return !(isPreviewHiddenInherited(props.document.root, nodeId, panelState.previewHiddenNodeIds) ?? false);
};

const getTreeNodeLabel = (props: ActionEditorCanvasProps, node: ActionNode) => node.name || (node.id === props.document.root.id ? tr(props, "rootNode") : tr(props, "node"));

const measureTreeContentWidth = (imgui: ActionImGuiFrame, props: ActionEditorCanvasProps, node: ActionNode, depth = 0): number => {
	const labelWidth = imgui.CalcTextSize(getTreeNodeLabel(props, node)).x;
	const rowWidth = depth * treeIndentWidth + treeEyeWidth + 2 + treePreviewSize + treeLabelGap + labelWidth + 48;
	return node.children.reduce(
		(width, child) => Math.max(width, measureTreeContentWidth(imgui, props, child, depth + 1)),
		rowWidth,
	);
};

const fitTextWidth = (imgui: ActionImGuiFrame, text: string, maxWidth: number) => {
	if (imgui.CalcTextSize(text).x <= maxWidth) return text;
	const ellipsis = "...";
	if (imgui.CalcTextSize(ellipsis).x >= maxWidth) return ellipsis;
	const chars = Array.from(text);
	let low = 0;
	let high = chars.length;
	while (low < high) {
		const mid = Math.ceil((low + high) / 2);
		const candidate = `${chars.slice(0, mid).join("")}${ellipsis}`;
		if (imgui.CalcTextSize(candidate).x <= maxWidth) low = mid;
		else high = mid - 1;
	}
	return `${chars.slice(0, low).join("")}${ellipsis}`;
};

const diagnosticsPanelMaxHeight = 120;

const estimateWrappedTextHeight = (imgui: ActionImGuiFrame, text: string, wrapWidth: number) => {
	const lineHeight = imgui.GetTextLineHeightWithSpacing();
	return text.split("\n").reduce((height, line) => {
		const lineWidth = imgui.CalcTextSize(line || " ").x;
		return height + Math.max(1, Math.ceil(lineWidth / Math.max(1, wrapWidth))) * lineHeight;
	}, 0);
};

const renderDiagnosticsPanel = (
	imgui: ActionImGuiFrame,
	props: ActionEditorCanvasProps,
) => {
	const entries: Array<{ message: string; color: { x: number; y: number; z: number; w: number } }> = [];
	if (props.diagnostics.length > 0) {
		entries.push(
			{ message: tr(props, "loadFailedNewModel"), color: { x: 0.9, y: 0.52, z: 0.45, w: 1 } },
			{ message: props.diagnostics[0].message, color: { x: 0.9, y: 0.52, z: 0.45, w: 1 } },
		);
	}
	for (const message of props.runtimeDiagnostics) {
		entries.push({ message, color: { x: 0.9, y: 0.52, z: 0.45, w: 1 } });
	}
	for (const message of props.clipDiagnostics) {
		entries.push({ message, color: { x: 0.9, y: 0.72, z: 0.32, w: 1 } });
	}
	if (entries.length === 0) return;

	const style = imgui.GetStyle();
	const wrapWidth = Math.max(80, imgui.GetContentRegionAvail().x - style.WindowPadding.x * 2 - 8);
	const contentHeight = entries.reduce((height, entry) => height + estimateWrappedTextHeight(imgui, entry.message, wrapWidth), 0);
	const panelHeight = Math.min(diagnosticsPanelMaxHeight, Math.max(imgui.GetTextLineHeightWithSpacing(), contentHeight + style.WindowPadding.y * 2));
	imgui.BeginChild("diagnostics-panel", { x: 0, y: panelHeight }, false, imgui.WindowFlags.AlwaysUseWindowPadding);
	try {
		for (const entry of entries) {
			imgui.PushStyleColor(imgui.Col.Text, entry.color);
			imgui.PushTextWrapPos(wrapWidth);
			imgui.TextWrapped(entry.message);
			imgui.PopTextWrapPos();
			imgui.PopStyleColor();
		}
	} finally {
		imgui.EndChild();
	}
};

const renderFallback = (
	canvas: HTMLCanvasElement,
	t: ActionEditorTranslate,
	document: ActionDocument,
	diagnostics: ActionDiagnostic[],
	runtimeDiagnostics: string[],
	clipDiagnostics: string[],
	readOnly: boolean,
) => {
	const ctx = canvas.getContext("2d");
	if (!ctx) return;
	const ratio = window.devicePixelRatio || 1;
	const width = canvas.clientWidth;
	const height = canvas.clientHeight;
	const targetWidth = Math.max(1, Math.floor(width * ratio));
	const targetHeight = Math.max(1, Math.floor(height * ratio));
	if (canvas.width !== targetWidth || canvas.height !== targetHeight) {
		canvas.width = targetWidth;
		canvas.height = targetHeight;
	}
	ctx.setTransform(ratio, 0, 0, ratio, 0, 0);
	ctx.clearRect(0, 0, width, height);
	ctx.fillStyle = "#1f1f1f";
	ctx.fillRect(0, 0, width, height);
	ctx.fillStyle = "#252525";
	ctx.fillRect(0, 0, width, 44);
	ctx.fillStyle = "#ffffff";
	ctx.font = "14px sans-serif";
	ctx.fillText(t("actionEditor.title"), 18, 28);
	ctx.fillStyle = readOnly ? "#c8b188" : "#cfcfcf";
	ctx.fillText(readOnly ? t("actionEditor.readOnly") : t("actionEditor.canvasRuntime"), width - 130, 28);
	ctx.font = "13px sans-serif";
	const messages = diagnostics.length > 0
		? [t("actionEditor.loadFailedNewModel"), diagnostics[0].message]
		: [
			t("actionEditor.modelValue", { model: document.modelPath ?? "" }),
			t("actionEditor.clipValue", { clip: document.clipFile || t("actionEditor.none") }),
			t("actionEditor.nodesValue", { count: countActionNodes(document.root) }),
			t("actionEditor.animationsValue", { count: document.animations.length }),
			t("actionEditor.looksValue", { count: document.looks.length }),
		];
	const allMessages = [...messages, ...clipDiagnostics, ...runtimeDiagnostics];
	allMessages.forEach((message, index) => {
		ctx.fillStyle = index < messages.length && diagnostics.length > 0 ? "#e98574" : "#cfcfcf";
		ctx.fillText(message, 18, 74 + index * 24);
	});
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

const renderTreeNode = (
	imgui: ActionImGuiFrame,
	props: ActionEditorCanvasProps,
	panelState: PanelState,
	node: ActionNode,
	depth: number,
	atlasTexture: ActionAtlasTexture | null,
) => {
	const selected = props.selectedNodeId === node.id;
	const directlyHidden = isPreviewHidden(panelState, node.id);
	const previewVisible = isNodePreviewVisible(props, panelState, node.id);
	const label = `${getTreeNodeLabel(props, node)}##${node.id}`;
	const clipRect = node.clip ? props.clipDocument?.rects[node.clip] : undefined;
	const rowHeight = 34;
	const eyeSize = treeEyeWidth;
	const previewSize = treePreviewSize;
	if (depth > 0) {
		imgui.Indent(depth * treeIndentWidth);
	}
	const rowStart = imgui.GetCursorScreenPos();
	imgui.PushID(`tree-eye.${node.id}`);
	if (imgui.InvisibleButton("preview-visibility", { x: eyeSize, y: previewSize }, 0)) {
		if (directlyHidden) {
			panelState.previewHiddenNodeIds.delete(node.id);
		} else {
			panelState.previewHiddenNodeIds.add(node.id);
		}
	}
	imgui.PopID();
	imgui.PushID(`tree-preview.${node.id}`);
	imgui.SameLine();
	imgui.SetCursorScreenPos({ x: rowStart.x + eyeSize + 2, y: rowStart.y });
	if (imgui.InvisibleButton("preview", { x: previewSize, y: previewSize }, 0)) {
		props.onSelectionChange(node.id);
	}
	imgui.PopID();
	const drawList = imgui.GetWindowDrawList();
	const eyeCenter = { x: rowStart.x + eyeSize * 0.5, y: rowStart.y + previewSize * 0.5 };
	const eyeColor = previewVisible ? 0xffd6d6d6 : 0xff686868;
	drawList.AddLine({ x: eyeCenter.x - 8, y: eyeCenter.y }, { x: eyeCenter.x, y: eyeCenter.y - 5 }, eyeColor, 1.2);
	drawList.AddLine({ x: eyeCenter.x, y: eyeCenter.y - 5 }, { x: eyeCenter.x + 8, y: eyeCenter.y }, eyeColor, 1.2);
	drawList.AddLine({ x: eyeCenter.x + 8, y: eyeCenter.y }, { x: eyeCenter.x, y: eyeCenter.y + 5 }, eyeColor, 1.2);
	drawList.AddLine({ x: eyeCenter.x, y: eyeCenter.y + 5 }, { x: eyeCenter.x - 8, y: eyeCenter.y }, eyeColor, 1.2);
	if (previewVisible) {
		drawList.AddCircleFilled(eyeCenter, 2.3, eyeColor, 12);
	} else {
		drawList.AddLine(
			{ x: eyeCenter.x - 8, y: eyeCenter.y + 6 },
			{ x: eyeCenter.x + 8, y: eyeCenter.y - 6 },
			eyeColor,
			1.5,
		);
	}
	const previewStart = { x: rowStart.x + eyeSize + 2, y: rowStart.y };
	drawList.AddRectFilled(
		previewStart,
		{ x: previewStart.x + previewSize, y: previewStart.y + previewSize },
		node.clip === "" ? 0xff252525 : 0xff303030,
		0,
		0,
	);
	if (node.clip === "") {
		drawList.AddRect(
			{ x: previewStart.x + 6, y: previewStart.y + 6 },
			{ x: previewStart.x + previewSize - 6, y: previewStart.y + previewSize - 6 },
			0xff686868,
			3,
			0,
			1,
		);
	}
	if (atlasTexture && clipRect && clipRect.width > 0 && clipRect.height > 0) {
		const scale = Math.min(previewSize / clipRect.width, previewSize / clipRect.height);
		const imageWidth = Math.max(1, clipRect.width * scale);
		const imageHeight = Math.max(1, clipRect.height * scale);
		const imagePos = {
			x: previewStart.x + (previewSize - imageWidth) / 2,
			y: previewStart.y + (previewSize - imageHeight) / 2,
		};
		drawList.AddImage(
			atlasTexture.texture,
			imagePos,
			{ x: imagePos.x + imageWidth, y: imagePos.y + imageHeight },
			{ x: clipRect.x / atlasTexture.width, y: clipRect.y / atlasTexture.height },
			{ x: (clipRect.x + clipRect.width) / atlasTexture.width, y: (clipRect.y + clipRect.height) / atlasTexture.height },
			0xffffffff,
		);
	}
	imgui.SameLine();
	imgui.SetCursorScreenPos({ x: rowStart.x + eyeSize + previewSize + treeLabelGap, y: rowStart.y + 4 });
	if (imgui.Selectable(label, selected, 0, { x: 0, y: 22 })) {
		props.onSelectionChange(node.id);
	}
	imgui.SetCursorScreenPos({ x: rowStart.x, y: rowStart.y + rowHeight });
	if (depth > 0) {
		imgui.Unindent(depth * treeIndentWidth);
	}
	for (const child of node.children) {
		renderTreeNode(imgui, props, panelState, child, depth + 1, atlasTexture);
	}
};

const renderNodeCommands = (
	imgui: ActionImGuiFrame,
	props: ActionEditorCanvasProps,
	panelState: PanelState,
) => {
	const selected = findActionNode(props.document.root, props.selectedNodeId) ?? props.document.root;
	if (!props.readOnly && imgui.Button(tr(props, "addChild"), { x: 86, y: 0 })) {
		const next = addChildActionNode(props.document, selected.id);
		props.onDocumentChange(next);
	}
	if (panelState.previewHiddenNodeIds.size > 0) {
		imgui.SameLine();
		if (imgui.Button(tr(props, "showAll"), { x: 78, y: 0 })) {
			panelState.previewHiddenNodeIds.clear();
		}
	}
	const rootSelected = selected.id === props.document.root.id;
	if (!rootSelected) {
		imgui.SameLine();
		if (!props.readOnly && imgui.Button(tr(props, "delete"), { x: 72, y: 0 })) {
			props.onDocumentChange(removeActionNode(props.document, selected.id));
			props.onSelectionChange(props.document.root.id);
		}
		if (!props.readOnly && imgui.Button(tr(props, "up"), { x: 50, y: 0 })) {
			props.onDocumentChange(reorderActionNode(props.document, selected.id, -1));
		}
		imgui.SameLine();
		if (!props.readOnly && imgui.Button(tr(props, "down"), { x: 62, y: 0 })) {
			props.onDocumentChange(reorderActionNode(props.document, selected.id, 1));
		}
		imgui.SameLine();
		const movingSelected = panelState.moveSourceId === selected.id;
		const moveClicked = !props.readOnly && (movingSelected
			? activeButton(imgui, `${tr(props, "cancelMove")}##node-move`, { x: 96, y: 0 })
			: imgui.Button(tr(props, "move"), { x: 96, y: 0 }));
		if (moveClicked) {
			panelState.moveSourceId = panelState.moveSourceId === selected.id ? null : selected.id;
		}
	}
	if (panelState.moveSourceId && panelState.moveSourceId !== selected.id) {
		if (!rootSelected) imgui.SameLine();
		if (activeButton(imgui, tr(props, "moveHere"), { x: 96, y: 0 })) {
			props.onDocumentChange(moveActionNodeToParent(props.document, panelState.moveSourceId, selected.id));
			panelState.moveSourceId = null;
		}
	}
};

const inputText = (
	imgui: ActionImGuiFrame,
	label: string,
	value: string,
	readOnly: boolean,
) => {
	const box = [value];
	const changed = imgui.InputText(label, box, 256, readOnly ? imgui.InputTextFlags.ReadOnly : 0, null, null);
	return changed && !readOnly ? box[0] : null;
};

const getInputHistoryOptions = (
	imgui: ActionImGuiFrame,
	panelState: PanelState,
	id: string,
	changed: boolean,
): ActionDocumentChangeOptions | undefined => {
	if (imgui.IsItemDeactivated()) {
		delete panelState.inputHistoryStarted[id];
	}
	if (!changed) return undefined;
	if (!imgui.IsItemActive()) return { history: "push" };
	const history: ActionDocumentChangeOptions["history"] = panelState.inputHistoryStarted[id] ? "replace" : "push";
	panelState.inputHistoryStarted[id] = true;
	return { history };
};

const inputNumber = (
	imgui: ActionImGuiFrame,
	label: string,
	value: number,
	readOnly: boolean,
	step = 1,
	panelState?: PanelState,
) => {
	const box = [value];
	const changed = imgui.InputDouble(label, box, step, step * 10, "%.3f", readOnly ? imgui.InputTextFlags.ReadOnly : 0);
	const options = panelState ? getInputHistoryOptions(imgui, panelState, label, changed && !readOnly) : undefined;
	if (!changed || readOnly) return null;
	return {
		value: box[0],
		options,
	};
};

const inputEase = (
	imgui: ActionImGuiFrame,
	label: string,
	value: number,
	readOnly: boolean,
) => {
	const box = [Math.max(0, Math.min(easeNames.length - 1, Math.round(value)))];
	const changed = imgui.Combo(label, box, easeNames, easeNames.length, 10);
	return changed && !readOnly ? box[0] : null;
};

const renderNodeClipSelector = (
	imgui: ActionImGuiFrame,
	props: ActionEditorCanvasProps,
	selected: ActionNode,
	atlasTexture: ActionAtlasTexture | null,
) => {
	imgui.Text(`${tr(props, "clip")}:`);
	imgui.SameLine();
	if (imgui.Button(`${selected.clip || tr(props, "none")}##node-clip`, { x: 160, y: 0 }) && !props.readOnly) {
		imgui.OpenPopup(tr(props, "selectNodeClip"), 0);
	}
	const modalFlags = imgui.WindowFlags.NoResize | imgui.WindowFlags.AlwaysAutoResize | imgui.WindowFlags.NoSavedSettings;
	if (imgui.BeginPopupModal(tr(props, "selectNodeClip"), null, modalFlags)) {
		try {
			imgui.Separator();
			if (!props.clipDocument || !atlasTexture) {
				imgui.TextDisabled(tr(props, "noClipAtlasLoaded"));
			}
			const names = props.clipDocument ? Object.keys(props.clipDocument.rects).sort((a, b) => a.localeCompare(b)) : [];
			const items = ["", ...names];
			const previewSize = 64;
			const cellWidth = 86;
			const cellHeight = 92;
			const columns = 4;
			const listHeight = Math.min(390, Math.max(cellHeight, Math.ceil(items.length / columns) * cellHeight));
			imgui.BeginChild("node-clip-list", { x: columns * cellWidth + 18, y: listHeight }, true, 0);
			try {
				if (imgui.BeginTable("node-clip-grid", columns, 0, { x: columns * cellWidth, y: 0 }, 0)) {
					try {
						for (let row = 0; row < Math.ceil(items.length / columns); row += 1) {
							imgui.TableNextRow(0, cellHeight);
							for (let column = 0; column < columns; column += 1) {
								const index = row * columns + column;
								imgui.TableNextColumn();
								if (index >= items.length) continue;
								const name = items[index];
								const isEmpty = name === "";
								const selectedItem = selected.clip === name;
								imgui.PushID(`node-clip.${isEmpty ? "empty" : name}`);
								try {
									const cellStart = imgui.GetCursorScreenPos();
									if (imgui.Button("##clip-cell", { x: previewSize, y: previewSize }) && !props.readOnly) {
										emitNodeChange(props, selected.id, (node) => ({ ...node, clip: name }));
										imgui.CloseCurrentPopup();
									}
									const drawList = imgui.GetWindowDrawList();
									const frameColor = selectedItem ? selectedNode : 0xff686868;
									drawList.AddRect(
										cellStart,
										{ x: cellStart.x + previewSize, y: cellStart.y + previewSize },
										frameColor,
										4,
										0,
										selectedItem ? 3 : 1,
									);
									if (isEmpty) {
										drawList.AddRect(
											{ x: cellStart.x + 18, y: cellStart.y + 18 },
											{ x: cellStart.x + previewSize - 18, y: cellStart.y + previewSize - 18 },
											0xff8a8a8a,
											3,
											0,
											1,
										);
									} else if (props.clipDocument && atlasTexture) {
										const rect = props.clipDocument.rects[name];
										const scale = Math.min(previewSize / rect.width, previewSize / rect.height);
										const imageWidth = Math.max(1, rect.width * scale);
										const imageHeight = Math.max(1, rect.height * scale);
										const imagePos = {
											x: cellStart.x + (previewSize - imageWidth) / 2,
											y: cellStart.y + (previewSize - imageHeight) / 2,
										};
										drawList.AddImage(
											atlasTexture.texture,
											imagePos,
											{ x: imagePos.x + imageWidth, y: imagePos.y + imageHeight },
											{ x: rect.x / atlasTexture.width, y: rect.y / atlasTexture.height },
											{ x: (rect.x + rect.width) / atlasTexture.width, y: (rect.y + rect.height) / atlasTexture.height },
											0xffffffff,
										);
									}
									const label = isEmpty ? tr(props, "none") : name;
									imgui.Text(label.length > 9 ? `${label.slice(0, 8)}...` : label);
								} finally {
									imgui.PopID();
								}
							}
						}
					} finally {
						imgui.EndTable();
					}
				}
			} finally {
				imgui.EndChild();
			}
			imgui.Separator();
			if (imgui.Button(tr(props, "cancel"), { x: 86, y: 0 })) {
				imgui.CloseCurrentPopup();
			}
		} finally {
			imgui.EndPopup();
		}
	}
};

const renderProperties = (
	imgui: ActionImGuiFrame,
	props: ActionEditorCanvasProps,
	panelState: PanelState,
	atlasTexture: ActionAtlasTexture | null,
) => {
	const selected = findActionNode(props.document.root, props.selectedNodeId) ?? props.document.root;
	const isRoot = selected.id === props.document.root.id;
	if (!isRoot) {
		const nextName = inputText(imgui, tr(props, "name"), selected.name, props.readOnly);
		if (nextName !== null) {
			emitNodeChange(props, selected.id, (node) => ({ ...node, name: nextName }));
		}
		renderNodeClipSelector(imgui, props, selected, atlasTexture);
		const front = [selected.front];
		if (imgui.Checkbox(tr(props, "front"), front) && !props.readOnly) {
			emitNodeChange(props, selected.id, (node) => ({ ...node, front: front[0] }));
		}
	}
	if (isRoot) {
		const width = inputNumber(imgui, tr(props, "width"), props.document.size.width, props.readOnly, 1, panelState);
		if (width !== null) {
			const next = cloneActionDocument(props.document);
			next.size.width = Math.max(0, Math.round(width.value));
			props.onDocumentChange(next, width.options);
		}
		const height = inputNumber(imgui, tr(props, "height"), props.document.size.height, props.readOnly, 1, panelState);
		if (height !== null) {
			const next = cloneActionDocument(props.document);
			next.size.height = Math.max(0, Math.round(height.value));
			props.onDocumentChange(next, height.options);
		}
		return;
	}
	const updateTransform = (updater: (node: ActionNode) => ActionNode, options?: ActionDocumentChangeOptions) => emitNodeChange(props, selected.id, updater, options);
	const x = inputNumber(imgui, tr(props, "x"), selected.transform.position.x, props.readOnly, 1, panelState);
	if (x !== null) updateTransform((node) => ({ ...node, transform: { ...node.transform, position: { ...node.transform.position, x: x.value } } }), x.options);
	const y = inputNumber(imgui, tr(props, "y"), selected.transform.position.y, props.readOnly, 1, panelState);
	if (y !== null) updateTransform((node) => ({ ...node, transform: { ...node.transform, position: { ...node.transform.position, y: y.value } } }), y.options);
	const scaleX = inputNumber(imgui, tr(props, "scaleX"), selected.transform.scale.x, props.readOnly, 0.1, panelState);
	if (scaleX !== null) updateTransform((node) => ({ ...node, transform: { ...node.transform, scale: { ...node.transform.scale, x: scaleX.value } } }), scaleX.options);
	const scaleY = inputNumber(imgui, tr(props, "scaleY"), selected.transform.scale.y, props.readOnly, 0.1, panelState);
	if (scaleY !== null) updateTransform((node) => ({ ...node, transform: { ...node.transform, scale: { ...node.transform.scale, y: scaleY.value } } }), scaleY.options);
	const rotation = inputNumber(imgui, tr(props, "angle"), selected.transform.rotation, props.readOnly, 1, panelState);
	if (rotation !== null) updateTransform((node) => ({ ...node, transform: { ...node.transform, rotation: rotation.value } }), rotation.options);
	const skewX = inputNumber(imgui, tr(props, "skewX"), selected.transform.skew.x, props.readOnly, 0.1, panelState);
	if (skewX !== null) updateTransform((node) => ({ ...node, transform: { ...node.transform, skew: { ...node.transform.skew, x: skewX.value } } }), skewX.options);
	const skewY = inputNumber(imgui, tr(props, "skewY"), selected.transform.skew.y, props.readOnly, 0.1, panelState);
	if (skewY !== null) updateTransform((node) => ({ ...node, transform: { ...node.transform, skew: { ...node.transform.skew, y: skewY.value } } }), skewY.options);
	const opacity = inputNumber(imgui, tr(props, "opacity"), selected.transform.opacity, props.readOnly, 0.05, panelState);
	if (opacity !== null) updateTransform((node) => ({ ...node, transform: { ...node.transform, opacity: Math.max(0, Math.min(1, opacity.value)) } }), opacity.options);
	const anchorX = inputNumber(imgui, tr(props, "anchorX"), selected.transform.anchor.x, props.readOnly, 0.05, panelState);
	if (anchorX !== null) updateTransform((node) => ({ ...node, transform: { ...node.transform, anchor: { ...node.transform.anchor, x: anchorX.value } } }), anchorX.options);
	const anchorY = inputNumber(imgui, tr(props, "anchorY"), selected.transform.anchor.y, props.readOnly, 0.05, panelState);
	if (anchorY !== null) updateTransform((node) => ({ ...node, transform: { ...node.transform, anchor: { ...node.transform.anchor, y: anchorY.value } } }), anchorY.options);
};

const renderAnimationKeyFrameProperties = (
	imgui: ActionImGuiFrame,
	props: ActionEditorCanvasProps,
	panelState: PanelState,
) => {
	const selected = findActionNode(props.document.root, props.selectedNodeId) ?? props.document.root;
	if (props.selectedAnimation === null || selected.id === props.document.root.id) {
		imgui.TextDisabled(tr(props, "selectNodeKeyframe"));
		return;
	}
	const front = [selected.front];
	if (imgui.Checkbox(tr(props, "front"), front) && !props.readOnly) {
		emitNodeChange(props, selected.id, (node) => ({ ...node, front: front[0] }));
	}
	const frame = getSelectedAnimationKeyFrame(props, selected.id);
	if (!frame) {
		imgui.PushTextWrapPos(250);
		imgui.TextDisabled(tr(props, "moveTimeHeadToKeyframe"));
		imgui.PopTextWrapPos();
		return;
	}
	imgui.Text(tr(props, "keyFrameAt", { frame: secondsToFrame(frame.time) }));
	const visible = [frame.visible];
	if (imgui.Checkbox(tr(props, "visible"), visible) && !props.readOnly) {
		emitKeyFrameChange(props, selected.id, (item) => ({ ...item, visible: visible[0] }));
	}
	const update = (updater: (frame: ActionKeyFrame) => ActionKeyFrame, options?: ActionDocumentChangeOptions) => {
		emitKeyFrameChange(props, selected.id, updater, options);
	};
	const x = inputNumber(imgui, tr(props, "x"), frame.transform.position.x, props.readOnly, 1, panelState);
	if (x !== null) update((item) => ({ ...item, transform: { ...item.transform, position: { ...item.transform.position, x: x.value } } }), x.options);
	const y = inputNumber(imgui, tr(props, "y"), frame.transform.position.y, props.readOnly, 1, panelState);
	if (y !== null) update((item) => ({ ...item, transform: { ...item.transform, position: { ...item.transform.position, y: y.value } } }), y.options);
	const scaleX = inputNumber(imgui, tr(props, "scaleX"), frame.transform.scale.x, props.readOnly, 0.1, panelState);
	if (scaleX !== null) update((item) => ({ ...item, transform: { ...item.transform, scale: { ...item.transform.scale, x: scaleX.value } } }), scaleX.options);
	const scaleY = inputNumber(imgui, tr(props, "scaleY"), frame.transform.scale.y, props.readOnly, 0.1, panelState);
	if (scaleY !== null) update((item) => ({ ...item, transform: { ...item.transform, scale: { ...item.transform.scale, y: scaleY.value } } }), scaleY.options);
	const rotation = inputNumber(imgui, tr(props, "angle"), frame.transform.rotation, props.readOnly, 1, panelState);
	if (rotation !== null) update((item) => ({ ...item, transform: { ...item.transform, rotation: rotation.value } }), rotation.options);
	const skewX = inputNumber(imgui, tr(props, "skewX"), frame.transform.skew.x, props.readOnly, 0.1, panelState);
	if (skewX !== null) update((item) => ({ ...item, transform: { ...item.transform, skew: { ...item.transform.skew, x: skewX.value } } }), skewX.options);
	const skewY = inputNumber(imgui, tr(props, "skewY"), frame.transform.skew.y, props.readOnly, 0.1, panelState);
	if (skewY !== null) update((item) => ({ ...item, transform: { ...item.transform, skew: { ...item.transform.skew, y: skewY.value } } }), skewY.options);
	const opacity = inputNumber(imgui, tr(props, "opacity"), frame.transform.opacity, props.readOnly, 0.05, panelState);
	if (opacity !== null) update((item) => ({ ...item, transform: { ...item.transform, opacity: Math.max(0, Math.min(1, opacity.value)) } }), opacity.options);
	const firstKeyFrame = props.selectedAnimation !== null && isFirstActionKeyFrame(props.document, selected.id, props.selectedAnimation, frame.time);
	if (!firstKeyFrame) {
		const easePosition = inputEase(imgui, `${tr(props, "moveEase")}##ease-position`, frame.ease.position, props.readOnly);
		if (easePosition !== null) update((item) => ({ ...item, ease: { ...item.ease, position: easePosition } }));
		const easeScale = inputEase(imgui, `${tr(props, "scaleEase")}##ease-scale`, frame.ease.scale, props.readOnly);
		if (easeScale !== null) update((item) => ({ ...item, ease: { ...item.ease, scale: easeScale } }));
		const easeSkew = inputEase(imgui, `${tr(props, "skewEase")}##ease-skew`, frame.ease.skew, props.readOnly);
		if (easeSkew !== null) update((item) => ({ ...item, ease: { ...item.ease, skew: easeSkew } }));
		const easeRotation = inputEase(imgui, `${tr(props, "angleEase")}##ease-rotation`, frame.ease.rotation, props.readOnly);
		if (easeRotation !== null) update((item) => ({ ...item, ease: { ...item.ease, rotation: easeRotation } }));
		const easeOpacity = inputEase(imgui, `${tr(props, "opacityEase")}##ease-opacity`, frame.ease.opacity, props.readOnly);
		if (easeOpacity !== null) update((item) => ({ ...item, ease: { ...item.ease, opacity: easeOpacity } }));
	}
	const event = inputText(imgui, tr(props, "event"), frame.event ?? "", props.readOnly);
	if (event !== null) {
		update((item) => ({ ...item, event: event === "" ? undefined : event }));
	}
};

const renderAnimationFrameTrackProperties = (
	imgui: ActionImGuiFrame,
	props: ActionEditorCanvasProps,
	panelState: PanelState,
	selected: ActionNode,
	track: ActionFrameTrack,
) => {
	if (props.selectedAnimation === null) return;
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
	const updateTrack = (
		updater: (item: typeof spec, delay: number) => { spec: typeof spec; delay: number },
		options?: ActionDocumentChangeOptions,
	) => {
		const next = updater(spec, track.delay);
		props.onDocumentChange(setActionFrameTrack(props.document, selected.id, props.selectedAnimation!, {
			type: "frame",
			file: formatActionFrameSpec(next.spec),
			delay: Math.max(0, next.delay),
		}), options);
	};
	if (!parsed) {
		imgui.PushTextWrapPos(250);
		imgui.TextDisabled(tr(props, "invalidFrameTrack"));
		imgui.PopTextWrapPos();
	}
	imgui.Text(`${tr(props, "clip")}:`);
	imgui.SameLine();
	const clipNames = Object.keys(props.clipDocument?.rects ?? {}).sort((a, b) => a.localeCompare(b));
	const selectedIndex = Math.max(0, clipNames.indexOf(spec.clipName));
	const clipIndex = [selectedIndex];
	imgui.PushItemWidth(150);
	const changedClip = clipNames.length > 0
		? imgui.Combo("##frame-track-clip", clipIndex, clipNames, clipNames.length, 10)
		: false;
	imgui.PopItemWidth();
	if (changedClip && !props.readOnly) {
		const clipName = clipNames[clipIndex[0]] ?? spec.clipName;
		updateTrack((item, delay) => ({ spec: { ...item, clipFile: props.document.clipFile, clipName }, delay }));
	}
	imgui.SameLine();
	if (!props.readOnly && imgui.Button(tr(props, "fit"), { x: 54, y: 0 })) {
		const base = props.clipDocument?.rects[spec.clipName];
		if (base) {
			const frameHeight = Math.max(1, spec.frameHeight);
			const frameWidth = Math.max(1, Math.min(base.width, spec.frameWidth || frameHeight));
			const columns = Math.max(1, Math.floor(base.width / frameWidth));
			const rows = Math.max(1, Math.floor(base.height / frameHeight));
			updateTrack((item, delay) => ({
				spec: {
					...item,
					frameWidth,
					frameHeight,
					frameCount: Math.max(1, columns * rows),
				},
				delay,
			}));
		}
	}
	const frameWidth = inputNumber(imgui, tr(props, "frameW"), spec.frameWidth, props.readOnly, 1, panelState);
	if (frameWidth !== null) {
		updateTrack((item, delay) => ({ spec: { ...item, frameWidth: Math.max(1, frameWidth.value) }, delay }), frameWidth.options);
	}
	const frameHeight = inputNumber(imgui, tr(props, "frameH"), spec.frameHeight, props.readOnly, 1, panelState);
	if (frameHeight !== null) {
		updateTrack((item, delay) => ({ spec: { ...item, frameHeight: Math.max(1, frameHeight.value) }, delay }), frameHeight.options);
	}
	const frameCount = inputNumber(imgui, tr(props, "count"), spec.frameCount, props.readOnly, 1, panelState);
	if (frameCount !== null) {
		updateTrack((item, delay) => ({ spec: { ...item, frameCount: Math.max(1, Math.round(frameCount.value)) }, delay }), frameCount.options);
	}
	const duration = inputNumber(imgui, tr(props, "duration"), spec.duration, props.readOnly, 1 / 60, panelState);
	if (duration !== null) {
		updateTrack((item, delay) => ({ spec: { ...item, duration: Math.max(1 / 60, duration.value) }, delay }), duration.options);
	}
	const delay = inputNumber(imgui, tr(props, "delay"), track.delay, props.readOnly, 1 / 60, panelState);
	if (delay !== null) {
		updateTrack((item) => ({ spec: item, delay: delay.value }), delay.options);
	}
	if (rect) {
		const columns = Math.max(1, Math.floor(rect.width / Math.max(1, spec.frameWidth)));
		const rows = Math.max(1, Math.floor(rect.height / Math.max(1, spec.frameHeight)));
		imgui.TextDisabled(tr(props, "atlasInfo", { width: Math.round(rect.width), height: Math.round(rect.height), columns, rows }));
	}
};

const renderKeyPoints = (
	imgui: ActionImGuiFrame,
	props: ActionEditorCanvasProps,
	panelState: PanelState,
) => {
	if (!props.readOnly && imgui.Button(tr(props, "addPoint"), { x: 92, y: 0 })) {
		props.onDocumentChange(addActionKeyPoint(props.document));
	}
	for (let index = 0; index < props.document.keyPoints.length; index += 1) {
		const point = props.document.keyPoints[index];
		imgui.Separator();
		imgui.Text(tr(props, "pointIndex", { index: index + 1 }));
		const preview = [panelState.visibleKeyPointIndexes.has(index)];
		if (imgui.Checkbox(`${tr(props, "preview")}##kp-preview-${index}`, preview)) {
			if (preview[0]) {
				panelState.visibleKeyPointIndexes.add(index);
			} else {
				panelState.visibleKeyPointIndexes.delete(index);
			}
		}
		const name = inputText(imgui, `${tr(props, "name")}##kp-name-${index}`, point.name, props.readOnly);
		if (name !== null) {
			props.onDocumentChange(updateActionKeyPoint(props.document, index, (item) => ({ ...item, name })));
		}
		const x = inputNumber(imgui, `${tr(props, "x")}##kp-x-${index}`, point.x, props.readOnly, 1, panelState);
		if (x !== null) {
			props.onDocumentChange(updateActionKeyPoint(props.document, index, (item) => ({ ...item, x: x.value })), x.options);
		}
		const y = inputNumber(imgui, `${tr(props, "y")}##kp-y-${index}`, point.y, props.readOnly, 1, panelState);
		if (y !== null) {
			props.onDocumentChange(updateActionKeyPoint(props.document, index, (item) => ({ ...item, y: y.value })), y.options);
		}
		if (!props.readOnly && imgui.Button(`${tr(props, "deletePoint")}##kp-del-${index}`, { x: 116, y: 0 })) {
			props.onDocumentChange(removeActionKeyPoint(props.document, index));
			const nextVisible = new Set<number>();
			for (const visibleIndex of panelState.visibleKeyPointIndexes) {
				if (visibleIndex < index) nextVisible.add(visibleIndex);
				else if (visibleIndex > index) nextVisible.add(visibleIndex - 1);
			}
			panelState.visibleKeyPointIndexes = nextVisible;
		}
	}
};

const renderLooks = (
	imgui: ActionImGuiFrame,
	props: ActionEditorCanvasProps,
) => {
	if (!props.readOnly && imgui.Button(tr(props, "addLook"), { x: 90, y: 0 })) {
		const next = addActionLook(props.document);
		const added = next.looks.find((look) => props.document.looks.indexOf(look) < 0) ?? next.looks[next.looks.length - 1] ?? null;
		props.onDocumentChange(next);
		if (added !== null) {
			props.onLookSelect(added);
			props.onAnimationSelect(null);
		}
	}
	if (props.selectedLook !== null) {
		imgui.SameLine();
		if (!props.readOnly && imgui.Button(tr(props, "deleteLook"), { x: 106, y: 0 })) {
			props.onDocumentChange(removeActionLook(props.document, props.selectedLook));
			props.onLookSelect(null);
		}
	}
	imgui.BeginChild("look-list", { x: 0, y: boundedChildHeight(imgui, lookListHeight, 150) }, true, 0);
	try {
		for (const look of props.document.looks) {
			if (imgui.Selectable(`${look}##look.${look}`, props.selectedLook === look, 0, { x: 0, y: 22 })) {
				props.onLookSelect(look);
				props.onAnimationSelect(null);
				props.onPlaybackPlayingChange(false);
			}
		}
	} finally {
		imgui.EndChild();
	}
	if (props.selectedLook !== null) {
		imgui.Separator();
		imgui.Text(tr(props, "lookValue", { look: props.selectedLook }));
		const selected = findActionNode(props.document.root, props.selectedNodeId) ?? props.document.root;
		if (selected.id !== props.document.root.id) {
			const hidden = [selected.hiddenInLooks.indexOf(props.selectedLook) >= 0];
			if (imgui.Checkbox(tr(props, "hide"), hidden) && !props.readOnly) {
				props.onDocumentChange(setActionNodeLookHidden(props.document, selected.id, props.selectedLook, hidden[0]));
			}
		}
	} else {
		imgui.Separator();
		imgui.TextDisabled(tr(props, "selectLookHint"));
	}
};

const renderAnimations = (
	imgui: ActionImGuiFrame,
	props: ActionEditorCanvasProps,
	panelState: PanelState,
) => {
	if (!props.readOnly && imgui.Button(tr(props, "addAnimation"), { x: 124, y: 0 })) {
		const result = addActionAnimation(props.document);
		props.onDocumentChange(result.document);
		props.onAnimationSelect(result.animation);
		props.onPlaybackTimeChange(0);
	}
	if (props.selectedAnimation !== null) {
		imgui.SameLine();
		if (!props.readOnly && imgui.Button(tr(props, "deleteAnimation"))) {
			props.onDocumentChange(removeActionAnimation(props.document, props.selectedAnimation));
			props.onAnimationSelect(null);
			props.onPlaybackTimeChange(0);
		}
	}
	imgui.Separator();
	const listHeight = boundedChildHeight(imgui, Math.max(animationLookListHeight, animationListHeight), 260);
	imgui.Columns(2, "animation-look-columns", false);
	try {
		imgui.TextColored(themeColor, tr(props, "animation"));
		imgui.BeginChild("animation-list", { x: 0, y: listHeight }, true, 0);
		try {
			for (const animation of props.document.animations) {
				if (imgui.Selectable(`${animation}##anim.${animation}`, props.selectedAnimation === animation, 0, { x: 0, y: 22 })) {
					props.onAnimationSelect(animation);
					props.onPlaybackTimeChange(0);
				}
			}
		} finally {
			imgui.EndChild();
		}
		imgui.NextColumn();
		imgui.TextColored(themeColor, tr(props, "look"));
		imgui.BeginChild("animation-look-list", { x: 0, y: listHeight }, true, 0);
		try {
			if (imgui.Selectable(`${tr(props, "defaultLook")}##anim-look.default`, props.selectedLook === null, 0, { x: 0, y: 22 })) {
				props.onLookSelect(null);
			}
			for (const look of props.document.looks) {
				if (imgui.Selectable(`${look}##anim-look.${look}`, props.selectedLook === look, 0, { x: 0, y: 22 })) {
					props.onLookSelect(look);
				}
			}
		} finally {
			imgui.EndChild();
		}
	} finally {
		imgui.Columns(1, null, false);
	}
	if (props.selectedAnimation === null) return;
	imgui.Separator();
	imgui.BeginChild(
		"animation-detail-scroll",
		{ x: 0, y: Math.max(1, imgui.GetContentRegionAvail().y) },
		false,
		imgui.WindowFlags.AlwaysUseWindowPadding,
	);
	try {
		imgui.Text(`${tr(props, "animation")}:`);
		imgui.SameLine();
		const animationName = [props.selectedAnimation];
		imgui.PushItemWidth(-5);
		const renameChanged = imgui.InputText(
			"##selected-animation-name",
			animationName,
			256,
			props.readOnly ? imgui.InputTextFlags.ReadOnly : 0,
			null,
			null,
		);
		imgui.PopItemWidth();
		if (renameChanged && !props.readOnly) {
			const nextName = animationName[0].trim();
			const options = getInputHistoryOptions(imgui, panelState, "selected-animation-name", nextName !== "" && nextName !== props.selectedAnimation);
			const nextDocument = renameActionAnimation(props.document, props.selectedAnimation, nextName);
			if (nextDocument !== props.document) {
				props.onDocumentChange(nextDocument, options);
				props.onAnimationSelect(nextName);
			}
		}
		const duration = getActionAnimationDuration(props.document, props.selectedAnimation);
		if (imgui.Button(props.playbackPlaying ? tr(props, "pause") : tr(props, "play"), { x: 64, y: 0 })) {
			props.onPlaybackPlayingChange(!props.playbackPlaying);
		}
		imgui.SameLine();
		const loop = [props.playbackLoop];
		if (imgui.Checkbox(tr(props, "loop"), loop)) {
			props.onPlaybackLoopChange(loop[0]);
		}
		const time = inputNumber(imgui, tr(props, "time"), props.playbackTime, props.readOnly, 1 / 60);
		if (time !== null) {
			props.onPlaybackTimeChange(Math.max(0, time.value));
		}
		imgui.Text(tr(props, "frameCounter", { current: Math.round(props.playbackTime * 60), total: Math.round(duration * 60) }));
		if (props.playbackPlaying) return;
		const selected = findActionNode(props.document.root, props.selectedNodeId) ?? props.document.root;
		if (selected.id === props.document.root.id) {
			return;
		}
		const track = selected.tracks[props.selectedAnimation];
		imgui.Separator();
		imgui.Text(tr(props, "track"));
		imgui.SameLine();
		const isFrameTrack = track?.type === "frame";
		if (imgui.RadioButton(tr(props, "key"), !isFrameTrack) && isFrameTrack && !props.readOnly) {
			props.onDocumentChange(upsertActionKeyFrame(props.document, selected.id, props.selectedAnimation, props.playbackTime));
			return;
		}
		imgui.SameLine();
		if (imgui.RadioButton(tr(props, "sequence"), isFrameTrack) && !isFrameTrack && !props.readOnly) {
			props.onDocumentChange(setActionFrameTrack(props.document, selected.id, props.selectedAnimation, createDefaultFrameTrack(props, selected)));
			return;
		}
		if (track?.type === "frame") {
			renderAnimationFrameTrackProperties(imgui, props, panelState, selected, track);
			return;
		}
		const currentFrame = track?.type === "key"
			? track.keyframes.find((frame) => Math.abs(frame.time - props.playbackTime) < 1 / 120)
			: undefined;
		if (!currentFrame && !props.readOnly && imgui.Button(tr(props, "addKey"), { x: 96, y: 0 })) {
			props.onDocumentChange(upsertActionKeyFrame(props.document, selected.id, props.selectedAnimation, props.playbackTime));
		}
		if (!currentFrame) imgui.SameLine();
		if (!props.readOnly && imgui.Button(tr(props, "deleteKey"), { x: 96, y: 0 })) {
			props.onDocumentChange(deleteActionKeyFrame(props.document, selected.id, props.selectedAnimation, props.playbackTime));
		}
		if (panelState.copiedKeyFrame !== null) {
			if (!props.readOnly && activeButton(imgui, tr(props, "cancelCopy"), { x: 96, y: 0 })) {
				panelState.copiedKeyFrame = null;
			}
		} else if (panelState.movingKeyTime !== null) {
			const text = tr(props, "movingKey", { frame: secondsToFrame(panelState.movingKeyTime) });
			if (!props.readOnly && activeButton(imgui, tr(props, "cancelMove"), { x: 96, y: 0 })) {
				panelState.movingKeyTime = null;
			}
			imgui.Text(text);
		} else if (currentFrame) {
			if (!props.readOnly && imgui.Button(tr(props, "copyKey"), { x: 96, y: 0 })) {
				panelState.copiedKeyFrame = copyActionKeyFrame(props.document, selected.id, props.selectedAnimation, props.playbackTime);
				panelState.movingKeyTime = null;
			}
			imgui.SameLine();
			if (!props.readOnly && imgui.Button(tr(props, "moveKey"), { x: 96, y: 0 })) {
				panelState.movingKeyTime = props.playbackTime;
				panelState.copiedKeyFrame = null;
			}
		}
		if (panelState.copiedKeyFrame !== null) {
			const text = tr(props, "copyingKey", { frame: secondsToFrame(panelState.copiedKeyFrame.time) });
			imgui.SameLine();
			if (!props.readOnly && activeButton(imgui, tr(props, "pasteKey"), { x: 96, y: 0 })) {
				props.onDocumentChange(pasteActionKeyFrame(props.document, selected.id, props.selectedAnimation, props.playbackTime, panelState.copiedKeyFrame));
				panelState.copiedKeyFrame = null;
			}
			ImGui.Text(text);
		}
		if (!props.playbackPlaying) {
			imgui.Separator();
			renderViewportTools(imgui, props, panelState);
		}
	} finally {
		imgui.EndChild();
	}
};

const renderModeTabs = (
	imgui: ActionImGuiFrame,
	props: ActionEditorCanvasProps,
	panelState: PanelState,
	atlasTexture: ActionAtlasTexture | null,
) => {
	const drawTab = (label: string, mode: ActionEditorMode, renderContent: () => void) => {
		const flags = panelState.modeTabsNeedSync && props.editMode === mode
			? imgui.TabItemFlags.SetSelected
			: imgui.TabItemFlags.None;
		if (imgui.BeginTabItem(label, null, flags)) {
			const restoringModeTab = panelState.modeTabsNeedSync && props.editMode !== mode;
			if (props.editMode !== mode && !panelState.modeTabsNeedSync) {
				props.onEditModeChange(mode);
			}
			try {
				if (restoringModeTab) return;
				const contentFlags = mode === "animation"
					? imgui.WindowFlags.AlwaysUseWindowPadding | imgui.WindowFlags.NoScrollbar | imgui.WindowFlags.NoScrollWithMouse
					: imgui.WindowFlags.AlwaysUseWindowPadding;
				imgui.BeginChild(`right-tab-content.${mode}`, { x: 0, y: Math.max(1, imgui.GetContentRegionAvail().y) }, false, contentFlags);
				try {
					renderContent();
					if (mode !== "animation" && !props.playbackPlaying) {
						imgui.Separator();
						renderViewportTools(imgui, props, panelState);
					}
				} finally {
					imgui.EndChild();
				}
			} finally {
				imgui.EndTabItem();
			}
		}
	};
	if (imgui.BeginTabBar("action-editor-mode-tabs", imgui.TabBarFlags.FittingPolicyResizeDown)) {
		try {
			drawTab(`${tr(props, "pose")}###pose-tab`, "pose", () => renderProperties(imgui, props, panelState, atlasTexture));
			drawTab(`${tr(props, "look")}###look-tab`, "look", () => renderLooks(imgui, props));
			drawTab(`${tr(props, "animation")}###animation-tab`, "animation", () => renderAnimations(imgui, props, panelState));
		} finally {
			imgui.EndTabBar();
			panelState.modeTabsNeedSync = false;
		}
	}
};

const renderViewportTools = (
	imgui: ActionImGuiFrame,
	props: ActionEditorCanvasProps,
	panelState: PanelState,
) => {
	const rootSelected = props.selectedNodeId === props.document.root.id;
	const selectedAnimationKeyFrame = props.editMode === "animation" ? getSelectedAnimationKeyFrame(props) : null;
	if (props.editMode === "animation" && selectedAnimationKeyFrame === null) return;
	const selectOnly = props.editMode === "look" || rootSelected;
	if (selectOnly && panelState.gizmoMode !== "select") {
		panelState.gizmoMode = "select";
	}
	imgui.Text(tr(props, "tool"));
	const modes = ["select", "move", "scale", "rotate"] as const;
	const visibleModes = modes.filter((mode) => {
		if (mode === "select") return true;
		if (selectOnly) return false;
		return true;
	});
	for (let index = 0; index < visibleModes.length; index += 1) {
		const mode = visibleModes[index];
		if (mode !== "select" && selectOnly) continue;
		if (imgui.RadioButton(`${tr(props, `toolMode.${mode}`)}##tool-${mode}`, panelState.gizmoMode === mode)) {
			panelState.gizmoMode = mode;
		}
		if (index % 2 === 0 && index + 1 < visibleModes.length) {
			imgui.SameLine();
		}
	}
	if (!selectOnly) {
		const fixed = [panelState.fixedSnap];
		if (imgui.Checkbox(tr(props, "fixed"), fixed)) {
			panelState.fixedSnap = fixed[0];
		}
	}
	if (props.editMode === "animation") {
		imgui.Separator();
		renderAnimationKeyFrameProperties(imgui, props, panelState);
	}
};

const renderClipFileSelector = (
	imgui: ActionImGuiFrame,
	props: ActionEditorCanvasProps,
) => {
	imgui.Text(`${tr(props, "clip")}:`);
	imgui.SameLine();
	if (imgui.Button(`${props.document.clipFile || tr(props, "none")}##model-clip`, { x: 160, y: 0 }) && !props.readOnly) {
		imgui.OpenPopup(tr(props, "selectModelClip"), 0);
	}
	const modalFlags = imgui.WindowFlags.NoResize | imgui.WindowFlags.AlwaysAutoResize | imgui.WindowFlags.NoSavedSettings;
	if (imgui.BeginPopupModal(tr(props, "selectModelClip"), null, modalFlags)) {
		try {
			imgui.Separator();
			if (props.clipFiles.length === 0) {
				imgui.TextDisabled(tr(props, "noClipFileFound"));
			} else {
				const listHeight = Math.min(320, Math.max(40, props.clipFiles.length * 26));
				imgui.BeginChild("model-clip-list", { x: 280, y: listHeight }, true, 0);
				try {
					for (const clipFile of props.clipFiles) {
						if (imgui.Selectable(`${clipFile}##model-clip.${clipFile}`, props.document.clipFile === clipFile, 0, { x: 0, y: 24 })) {
							props.onClipFileSelect(clipFile);
							imgui.CloseCurrentPopup();
						}
					}
				} finally {
					imgui.EndChild();
				}
			}
			imgui.Separator();
			if (imgui.Button(tr(props, "cancel"), { x: 86, y: 0 })) {
				imgui.CloseCurrentPopup();
			}
		} finally {
			imgui.EndPopup();
		}
	}
};

const drawGrid = (
	drawList: any,
	area: { x: number; y: number; width: number; height: number },
	viewport: ActionViewport,
) => {
	drawList.AddRectFilled({ x: area.x, y: area.y }, { x: area.x + area.width, y: area.y + area.height }, gray, 0, 0);
	const step = Math.max(16, 100 * viewport.zoom);
	const center = modelToScreen({ x: 0, y: 0 }, viewport, area);
	for (let x = center.x % step; x < area.x + area.width; x += step) {
		if (x >= area.x) drawList.AddLine({ x, y: area.y }, { x, y: area.y + area.height }, grid, 1);
	}
	for (let y = center.y % step; y < area.y + area.height; y += step) {
		if (y >= area.y) drawList.AddLine({ x: area.x, y }, { x: area.x + area.width, y }, grid, 1);
	}
	drawList.AddLine({ x: area.x, y: center.y }, { x: area.x + area.width, y: center.y }, originColor, 1);
	drawList.AddLine({ x: center.x, y: area.y }, { x: center.x, y: area.y + area.height }, originColor, 1);
};

const collectAnimationFrames = (
	node: ActionNode,
	animation: string,
	selectedNodeId: string,
	result: { selected: number[]; other: number[] },
) => {
	const track = node.tracks[animation];
	if (track?.type === "key") {
		for (const frame of track.keyframes) {
			const target = node.id === selectedNodeId ? result.selected : result.other;
			target.push(secondsToFrame(frame.time));
		}
	}
	for (const child of node.children) {
		collectAnimationFrames(child, animation, selectedNodeId, result);
	}
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
			const target = node.id === selectedNodeId ? result.selected : result.other;
			target.push({
				start: secondsToFrame(track.delay),
				end: secondsToFrame(track.delay + spec.duration),
			});
		}
	}
	for (const child of node.children) {
		collectAnimationFrameRanges(child, animation, selectedNodeId, result);
	}
};

const uniqueSortedFrames = (frames: number[]) => [...new Set(frames)].sort((a, b) => a - b);

const renderAnimationTimeline = (
	imgui: ActionImGuiFrame,
	props: ActionEditorCanvasProps,
	panelState: PanelState,
	area: { x: number; y: number; width: number; height: number },
) => {
	if (props.editMode !== "animation" || props.selectedAnimation === null) return;
	const drawList = imgui.GetWindowDrawList();
	const durationFrame = secondsToFrame(getActionAnimationDuration(props.document, props.selectedAnimation));
	const currentFrame = secondsToFrame(props.playbackTime);
	const frameSets = { selected: [] as number[], other: [] as number[] };
	collectAnimationFrames(props.document.root, props.selectedAnimation, props.selectedNodeId, frameSets);
	const frameRanges = { selected: [] as Array<{ start: number; end: number }>, other: [] as Array<{ start: number; end: number }> };
	collectAnimationFrameRanges(props.document.root, props.selectedAnimation, props.selectedNodeId, frameRanges);
	const keyFrames = uniqueSortedFrames(frameSets.selected);
	const rangeFrames = [...frameRanges.selected, ...frameRanges.other].flatMap((range) => [range.start, range.end]);
	const visibleFrames = 60;
	const contentMaxFrame = Math.max(0, durationFrame, currentFrame, ...keyFrames, ...rangeFrames);
	if (panelState.timelineFollowCursor && currentFrame < panelState.timelineOffsetFrame) {
		panelState.timelineOffsetFrame = Math.max(0, currentFrame);
	} else if (panelState.timelineFollowCursor && currentFrame > panelState.timelineOffsetFrame + visibleFrames) {
		panelState.timelineOffsetFrame = currentFrame - visibleFrames;
	}
	const timelineMaxFrame = Math.max(visibleFrames, contentMaxFrame, panelState.timelineOffsetFrame + visibleFrames);
	const windowStart = Math.max(0, Math.min(panelState.timelineOffsetFrame, timelineMaxFrame - visibleFrames));
	panelState.timelineOffsetFrame = windowStart;
	const windowEnd = windowStart + visibleFrames;
	const rulerY = area.y + 34;
	const left = area.x + 28;
	const right = area.x + area.width - 28;
	const width = Math.max(1, right - left);
	const frameToX = (frame: number) => left + ((frame - windowStart) / visibleFrames) * width;
	const xToFrame = (x: number) => Math.max(0, windowStart + Math.round(((x - left) / width) * visibleFrames));
	imgui.SetCursorScreenPos({ x: area.x, y: area.y });
	imgui.InvisibleButton("animation-timeline", { x: area.width, y: area.height }, 0);
	const io = imgui.GetIO();
	const mouse = { x: io.MousePos.x, y: io.MousePos.y };
	if (imgui.IsItemActivated()) {
		const cursorX = frameToX(currentFrame);
		const doubleClicked = imgui.IsMouseDoubleClicked(0);
		panelState.timelineDragStartMouseX = mouse.x;
		panelState.timelineDragStartOffsetFrame = windowStart;
		panelState.timelineDragMode = doubleClicked || Math.abs(mouse.x - cursorX) <= 50 ? "scrub" : "scroll";
		panelState.timelineFollowCursor = panelState.timelineDragMode !== "scroll";
		props.onPlaybackPlayingChange(false);
	}
	if (imgui.IsItemActive()) {
		if (panelState.timelineDragMode === "scroll") {
			const deltaFrame = Math.round(((mouse.x - panelState.timelineDragStartMouseX) / width) * visibleFrames * 2);
			panelState.timelineOffsetFrame = Math.max(0, panelState.timelineDragStartOffsetFrame - deltaFrame);
			panelState.timelineFollowCursor = false;
		} else {
			panelState.timelineFollowCursor = true;
			props.onPlaybackTimeChange(frameToSeconds(xToFrame(mouse.x)));
		}
	}
	if (imgui.IsItemDeactivated()) {
		if (
			panelState.timelineDragMode === "scrub"
			&& panelState.movingKeyTime !== null
			&& !props.readOnly
			&& props.selectedAnimation !== null
			&& props.selectedNodeId !== props.document.root.id
		) {
			const nextFrame = xToFrame(mouse.x);
			const movingFrame = secondsToFrame(panelState.movingKeyTime);
			if (nextFrame !== movingFrame) {
				props.onDocumentChange(moveActionKeyFrame(
					props.document,
					props.selectedNodeId,
					props.selectedAnimation,
					panelState.movingKeyTime,
					frameToSeconds(nextFrame),
				));
			}
			panelState.movingKeyTime = null;
		}
		panelState.timelineDragMode = null;
	}

	drawList.AddRectFilled({ x: area.x, y: area.y }, { x: area.x + area.width, y: area.y + area.height }, timelineBgColor, 0, 0);
	drawList.AddRect({ x: area.x, y: area.y }, { x: area.x + area.width, y: area.y + area.height }, withAlpha(timelineBorderColor, 0.85), 0, 0, 1);
	drawList.AddRectFilled({ x: left, y: rulerY + 12 }, { x: right, y: rulerY + 18 }, withAlpha(timelineProgressColor, 0.22), 0, 0);
	drawList.AddRectFilled(
		{ x: left, y: rulerY + 12 },
		{ x: frameToX(Math.max(windowStart, Math.min(currentFrame, windowEnd))), y: rulerY + 18 },
		timelineProgressColor,
		0,
		0,
	);
	for (let frame = windowStart; frame <= windowEnd; frame += 1) {
		const x = frameToX(frame);
		const major = frame % 10 === 0;
		const height = major ? 12 : 6;
		drawList.AddLine({ x, y: rulerY }, { x, y: rulerY + height }, timelineTickColor, major ? 1.4 : 1);
		if (major) {
			drawList.AddText({ x: x - 4, y: area.y + 6 }, timelineTickColor, `${frame}`);
		}
	}
	for (const range of frameRanges.other) {
		if (range.end < windowStart || range.start > windowEnd) continue;
		drawList.AddRectFilled(
			{ x: frameToX(Math.max(windowStart, range.start)), y: rulerY + 21 },
			{ x: frameToX(Math.min(windowEnd, range.end)), y: rulerY + 25 },
			withAlpha(timelineKeyColor, 0.35),
			0,
			0,
		);
	}
	for (const range of frameRanges.selected) {
		if (range.end < windowStart || range.start > windowEnd) continue;
		drawList.AddRectFilled(
			{ x: frameToX(Math.max(windowStart, range.start)), y: rulerY + 20 },
			{ x: frameToX(Math.min(windowEnd, range.end)), y: rulerY + 27 },
			timelineKeyColor,
			0,
			0,
		);
	}
	for (const frame of keyFrames) {
		if (frame < windowStart || frame > windowEnd) continue;
		const x = frameToX(frame);
		const isSelectedFrame = frame === currentFrame;
		const halfWidth = isSelectedFrame ? 3 : 1;
		drawList.AddRectFilled(
			{ x: x - halfWidth, y: isSelectedFrame ? rulerY - 12 : rulerY - 10 },
			{ x: x + halfWidth, y: rulerY + 18 },
			timelineKeyColor,
			0,
			0,
		);
	}
	if (currentFrame >= windowStart && currentFrame <= windowEnd) {
		const cursorX = frameToX(currentFrame);
		drawList.AddTriangleFilled(
			{ x: cursorX, y: rulerY + 23 },
			{ x: cursorX - 6, y: rulerY + 31 },
			{ x: cursorX + 6, y: rulerY + 31 },
			timelineCursorColor,
		);
	}
};

const drawModelBounds = (
	drawList: any,
	area: { x: number; y: number; width: number; height: number },
	props: ActionEditorCanvasProps,
) => {
	const size = props.document.size;
	if (size.width <= 0 || size.height <= 0) return;
	const left = -size.width * 0.5;
	const right = size.width * 0.5;
	const bottom = -size.height * 0.5;
	const top = size.height * 0.5;
	const min = modelToScreen({ x: left, y: top }, props.viewport, area);
	const max = modelToScreen({ x: right, y: bottom }, props.viewport, area);
	drawList.AddRectFilled(min, max, withAlpha(modelBoundsColor, 0.08), 0, 0);
	drawList.AddRect(min, max, withAlpha(modelBoundsColor, 0.55), 0, 0, 1.5);
};

const drawKeyPointMarkers = (
	imgui: ActionImGuiFrame,
	drawList: any,
	area: { x: number; y: number; width: number; height: number },
	props: ActionEditorCanvasProps,
	panelState: PanelState,
) => {
	for (const index of panelState.visibleKeyPointIndexes) {
		const point = props.document.keyPoints[index];
		if (!point) continue;
		const pos = modelToScreen(point, props.viewport, area);
		drawList.AddCircleFilled(pos, 4.5, keyPointColor, 16);
		drawList.AddCircle(pos, 8, withAlpha(keyPointColor, 0.85), 18, 1.5);
		drawList.AddLine({ x: pos.x - 12, y: pos.y }, { x: pos.x + 12, y: pos.y }, keyPointColor, 1.5);
		drawList.AddLine({ x: pos.x, y: pos.y - 12 }, { x: pos.x, y: pos.y + 12 }, keyPointColor, 1.5);
		if (point.name) {
			drawList.AddText(
				{ x: pos.x + 10, y: pos.y - imgui.GetTextLineHeight() * 0.5 },
				withAlpha(0xffffffff, 0.92),
				point.name,
			);
		}
	}
};

const averagePoints = (points: Array<{ x: number; y: number }>) => ({
	x: points.reduce((sum, point) => sum + point.x, 0) / points.length,
	y: points.reduce((sum, point) => sum + point.y, 0) / points.length,
});

const pointDistance = (a: { x: number; y: number }, b: { x: number; y: number }) => {
	const dx = a.x - b.x;
	const dy = a.y - b.y;
	return Math.sqrt(dx * dx + dy * dy);
};

const drawArrow = (
	drawList: any,
	from: { x: number; y: number },
	to: { x: number; y: number },
	color: number,
) => {
	const dx = to.x - from.x;
	const dy = to.y - from.y;
	const length = Math.max(0.0001, Math.sqrt(dx * dx + dy * dy));
	const ux = dx / length;
	const uy = dy / length;
	const px = -uy;
	const py = ux;
	const head = 8;
	const width = 5;
	drawList.AddLine(from, to, color, 2);
	drawList.AddTriangleFilled(
		to,
		{ x: to.x - ux * head + px * width, y: to.y - uy * head + py * width },
		{ x: to.x - ux * head - px * width, y: to.y - uy * head - py * width },
		color,
	);
};

const drawScaleHandle = (drawList: any, point: { x: number; y: number }) => {
	const size = 5;
	drawList.AddRectFilled(
		{ x: point.x - size, y: point.y - size },
		{ x: point.x + size, y: point.y + size },
		gizmoAccentColor,
		1,
		0,
	);
	drawList.AddRect(
		{ x: point.x - size, y: point.y - size },
		{ x: point.x + size, y: point.y + size },
		gizmoColor,
		1,
		0,
		1,
	);
};

const drawToolGizmo = (
	drawList: any,
	props: ActionEditorCanvasProps,
	panelState: PanelState,
	rects: ActionRenderRect[],
	area: { x: number; y: number; width: number; height: number },
) => {
	if (props.editMode === "look" || panelState.gizmoMode === "select" || props.selectedNodeId === props.document.root.id) return;
	const rect = rects.find((item) => item.nodeId === props.selectedNodeId);
	if (!rect || !rect.visible || !isNodePreviewVisible(props, panelState, rect.nodeId)) return;
	const corners = renderRectCornersToViewport(rect, props.viewport, area);
	const boxCenter = averagePoints(corners);
	const anchor = modelToScreen(rect.anchor, props.viewport, area);
	const center = panelState.gizmoMode === "move" || panelState.gizmoMode === "rotate" ? anchor : boxCenter;
	if (panelState.gizmoMode === "move") {
		const radius = Math.max(28, Math.min(72, Math.max(rect.width, rect.height) * props.viewport.zoom * 0.35));
		drawList.AddCircleFilled(center, 4, gizmoColor, 16);
		drawArrow(drawList, center, { x: center.x + radius, y: center.y }, gizmoAccentColor);
		drawArrow(drawList, center, { x: center.x, y: center.y - radius }, gizmoAccentColor);
		drawList.AddLine({ x: center.x - radius * 0.55, y: center.y }, { x: center.x, y: center.y }, withAlpha(gizmoColor, 0.7), 1.5);
		drawList.AddLine({ x: center.x, y: center.y }, { x: center.x, y: center.y + radius * 0.55 }, withAlpha(gizmoColor, 0.7), 1.5);
	} else if (panelState.gizmoMode === "scale") {
		const mids = [
			{ x: (corners[0].x + corners[1].x) * 0.5, y: (corners[0].y + corners[1].y) * 0.5 },
			{ x: (corners[1].x + corners[2].x) * 0.5, y: (corners[1].y + corners[2].y) * 0.5 },
			{ x: (corners[2].x + corners[3].x) * 0.5, y: (corners[2].y + corners[3].y) * 0.5 },
			{ x: (corners[3].x + corners[0].x) * 0.5, y: (corners[3].y + corners[0].y) * 0.5 },
		];
		drawList.AddQuad(corners[0], corners[1], corners[2], corners[3], gizmoColor, 2);
		for (const point of [...corners, ...mids]) {
			drawScaleHandle(drawList, point);
		}
	} else if (panelState.gizmoMode === "rotate") {
		const radius = Math.max(32, Math.max(...corners.map((point) => pointDistance(point, anchor))) + 22);
		drawList.AddCircle(center, radius, gizmoColor, 72, 1.5);
		const angle = -Math.PI * 0.18;
		const end = { x: center.x + Math.cos(angle) * radius, y: center.y + Math.sin(angle) * radius };
		drawList.AddLine(center, end, gizmoColor, 1.5);
		drawArrow(drawList, end, {
			x: end.x + Math.cos(angle + Math.PI * 0.35) * 18,
			y: end.y + Math.sin(angle + Math.PI * 0.35) * 18,
		}, gizmoAccentColor);
		drawList.AddCircleFilled(center, 4, gizmoColor, 16);
	}
};

const drawRenderRects = (
	imgui: ActionImGuiFrame,
	area: { x: number; y: number; width: number; height: number },
	props: ActionEditorCanvasProps,
	panelState: PanelState,
	rects: ActionRenderRect[],
	atlasTexture: ActionAtlasTexture | null,
) => {
	const drawList = imgui.GetWindowDrawList();
	drawList.PushClipRect(
		{ x: area.x, y: area.y },
		{ x: area.x + area.width, y: area.y + area.height },
		true,
	);
	try {
		drawGrid(drawList, area, props.viewport);
		drawModelBounds(drawList, area, props);
		for (const rect of rects) {
			if (!rect.visible) continue;
			if (!isNodePreviewVisible(props, panelState, rect.nodeId)) continue;
			const corners = renderRectCornersToViewport(rect, props.viewport, area);
			const color = withAlpha(rect.missingClip ? missingNode : normalNode, rect.opacity);
			if (atlasTexture && !rect.missingClip && rect.clip) {
				drawList.AddImageQuad(
					atlasTexture.texture,
					corners[0],
					corners[1],
					corners[2],
					corners[3],
					{ x: rect.sourceX / atlasTexture.width, y: rect.sourceY / atlasTexture.height },
					{ x: (rect.sourceX + rect.sourceWidth) / atlasTexture.width, y: rect.sourceY / atlasTexture.height },
					{ x: (rect.sourceX + rect.sourceWidth) / atlasTexture.width, y: (rect.sourceY + rect.sourceHeight) / atlasTexture.height },
					{ x: rect.sourceX / atlasTexture.width, y: (rect.sourceY + rect.sourceHeight) / atlasTexture.height },
					withAlpha(0xffffffff, rect.opacity),
				);
			} else {
				drawList.AddQuadFilled(
					corners[0],
					corners[1],
					corners[2],
					corners[3],
					color,
				);
			}
			drawList.AddQuad(
				corners[0],
				corners[1],
				corners[2],
				corners[3],
				rect.nodeId === props.selectedNodeId ? selectedNode : withAlpha(nodeBorder, Math.max(0.45, rect.opacity)),
				rect.nodeId === props.selectedNodeId ? 3 : 1,
			);
		}
		drawToolGizmo(drawList, props, panelState, rects, area);
		drawKeyPointMarkers(imgui, drawList, area, props, panelState);
	} finally {
		drawList.PopClipRect();
	}
};

const canSelectRenderRect = (props: ActionEditorCanvasProps, rect: ActionRenderRect) => rect.nodeId !== props.document.root.id
	&& rect.clip !== ""
	&& !rect.missingClip
	&& rect.sourceWidth > 0
	&& rect.sourceHeight > 0
	&& rect.width > 0
	&& rect.height > 0;

const handleViewportInput = (
	props: ActionEditorCanvasProps,
	panelState: PanelState,
	rects: ActionRenderRect[],
	pointer: { x: number; y: number },
) => {
	const point = screenToModel(pointer, props.viewport, panelState.viewportArea);
	const nodeId = hitTestActionRenderRects(
		rects,
		point,
		(rect) => canSelectRenderRect(props, rect) && isNodePreviewVisible(props, panelState, rect.nodeId),
	);
	if (nodeId) props.onSelectionChange(nodeId);
	panelState.lastDragDelta = { x: 0, y: 0 };
	panelState.viewportDragButton = 0;
	const selectedVisible = isNodePreviewVisible(props, panelState, props.selectedNodeId);
	const requestedDragNodeId = panelState.gizmoMode === "select" ? null : (nodeId ?? (selectedVisible ? props.selectedNodeId : null));
	const dragFrame = requestedDragNodeId ? getSelectedAnimationKeyFrame(props, requestedDragNodeId) : null;
	const dragNodeId = props.editMode === "animation" && requestedDragNodeId !== null && dragFrame === null
		? null
		: requestedDragNodeId;
	panelState.viewportDragAction = panelState.gizmoMode === "select" || dragNodeId === null
		? "pan"
		: "edit";
	const dragNode = dragNodeId ? findActionNode(props.document.root, dragNodeId) : null;
	const dragRect = dragNodeId ? rects.find((rect) => rect.nodeId === dragNodeId) ?? null : null;
	const dragAnchorScreen = dragRect ? modelToScreen(dragRect.anchor, props.viewport, panelState.viewportArea) : null;
	panelState.dragNodeId = dragNodeId;
	panelState.dragStartPosition = dragFrame ? { ...dragFrame.transform.position } : (dragNode ? { ...dragNode.transform.position } : null);
	panelState.dragStartRotation = dragFrame ? dragFrame.transform.rotation : (dragNode ? dragNode.transform.rotation : null);
	panelState.dragStartPointer = { ...pointer };
	panelState.dragAnchorScreen = dragAnchorScreen;
	panelState.dragStartPointerAngle = dragAnchorScreen ? pointerAngleDegrees(dragAnchorScreen, pointer) : null;
	panelState.dragLastPointerAngle = panelState.dragStartPointerAngle;
	panelState.dragAccumulatedRotationDelta = 0;
};

const dragViewportInput = (
	props: ActionEditorCanvasProps,
	panelState: PanelState,
	delta: { x: number; y: number },
) => {
	if (panelState.viewportDragAction === "pan" && panelState.viewportDragButton !== null) {
		const diff = {
			x: delta.x - panelState.lastDragDelta.x,
			y: delta.y - panelState.lastDragDelta.y,
		};
		if (diff.x !== 0 || diff.y !== 0) {
			props.onViewportChange({
				...props.viewport,
				pan: { x: props.viewport.pan.x + diff.x, y: props.viewport.pan.y + diff.y },
			});
			panelState.lastDragDelta = { x: delta.x, y: delta.y };
		}
	}
	if (!props.readOnly && props.editMode !== "look" && panelState.viewportDragAction === "edit" && panelState.viewportDragButton === 0) {
		const diff = {
			x: (delta.x - panelState.lastDragDelta.x) / props.viewport.zoom,
			y: -(delta.y - panelState.lastDragDelta.y) / props.viewport.zoom,
		};
		if (diff.x !== 0 || diff.y !== 0) {
			const historyOptions = getDragHistoryOptions(panelState);
			const targetNodeId = panelState.dragNodeId ?? props.selectedNodeId;
			const updateTransform = (updater: (transform: ActionKeyFrame["transform"]) => ActionKeyFrame["transform"]) => {
				if (props.editMode === "animation") {
					emitKeyFrameChange(props, targetNodeId, (frame) => ({
						...frame,
						transform: updater(frame.transform),
					}), historyOptions);
				} else {
					emitNodeChange(props, targetNodeId, (node) => ({
						...node,
						transform: { ...node.transform, ...updater(node.transform) },
					}), historyOptions);
				}
			};
			updateTransform((transform) => {
				if (panelState.gizmoMode === "scale") {
					return {
						...transform,
						scale: {
							x: Math.max(0.01, snapValue(transform.scale.x + diff.x / 100, panelState.fixedSnap, 0.1)),
							y: Math.max(0.01, snapValue(transform.scale.y + diff.y / 100, panelState.fixedSnap, 0.1)),
						},
					};
				}
				if (panelState.gizmoMode === "rotate") {
					if (
						panelState.dragStartRotation === null
						|| panelState.dragStartPointer === null
						|| panelState.dragStartPointerAngle === null
						|| panelState.dragLastPointerAngle === null
						|| panelState.dragAnchorScreen === null
					) {
						return transform;
					}
					const pointer = {
						x: panelState.dragStartPointer.x + delta.x,
						y: panelState.dragStartPointer.y + delta.y,
					};
					const angle = pointerAngleDegrees(panelState.dragAnchorScreen, pointer);
					panelState.dragAccumulatedRotationDelta += pointerAngleStepDelta(angle - panelState.dragLastPointerAngle);
					panelState.dragLastPointerAngle = angle;
					return {
						...transform,
						rotation: snapValue(panelState.dragStartRotation + panelState.dragAccumulatedRotationDelta, panelState.fixedSnap, 5),
					};
				}
				if (panelState.gizmoMode === "move" && panelState.dragStartPosition) {
					const positionDelta = screenDeltaToNodeLocalDelta(props.document, props.clipDocument, targetNodeId, delta, props.viewport);
					return {
						...transform,
						position: {
							x: snapValue(panelState.dragStartPosition.x + positionDelta.x, panelState.fixedSnap, 1),
							y: snapValue(panelState.dragStartPosition.y + positionDelta.y, panelState.fixedSnap, 1),
						},
					};
				}
				return {
					...transform,
					position: {
						x: snapValue(transform.position.x + diff.x, panelState.fixedSnap, 1),
						y: snapValue(transform.position.y + diff.y, panelState.fixedSnap, 1),
					},
				};
			});
			panelState.lastDragDelta = { x: delta.x, y: delta.y };
		}
	}
};

const getDragHistoryOptions = (panelState: PanelState): ActionDocumentChangeOptions => {
	const history: ActionDocumentChangeOptions["history"] = panelState.dragHistoryStarted ? "replace" : "push";
	panelState.dragHistoryStarted = true;
	return { history };
};

const endViewportInput = (panelState: PanelState) => {
	panelState.lastDragDelta = { x: 0, y: 0 };
	panelState.viewportDragButton = null;
	panelState.viewportDragAction = null;
	panelState.dragNodeId = null;
	panelState.dragStartPosition = null;
	panelState.dragStartRotation = null;
	panelState.dragStartPointer = null;
	panelState.dragStartPointerAngle = null;
	panelState.dragLastPointerAngle = null;
	panelState.dragAccumulatedRotationDelta = 0;
	panelState.dragAnchorScreen = null;
	panelState.dragHistoryStarted = false;
};

const isImGuiPointerCaptured = (imgui: ActionImGuiFrame) => {
	const popupFlags = ((imgui.PopupFlags?.AnyPopupId ?? (1 << 7)) | (imgui.PopupFlags?.AnyPopupLevel ?? (1 << 8)));
	try {
		return imgui.IsAnyItemHovered()
			|| imgui.IsAnyItemActive()
			|| imgui.IsPopupOpen("", popupFlags);
	} catch {
		return imgui.IsAnyItemHovered();
	}
};

const pointInArea = (point: { x: number; y: number }, area: { x: number; y: number; width: number; height: number }) => point.x >= area.x
	&& point.x <= area.x + area.width
	&& point.y >= area.y
	&& point.y <= area.y + area.height;

const handleViewportFrameInput = (
	imgui: ActionImGuiFrame,
	props: ActionEditorCanvasProps,
	panelState: PanelState,
	rects: ActionRenderRect[],
) => {
	const io = imgui.GetIO();
	const mousePos = { x: io.MousePos.x, y: io.MousePos.y };
	const inViewport = pointInArea(mousePos, panelState.viewportArea);
	const uiCaptured = isImGuiPointerCaptured(imgui);
	if (inViewport && !uiCaptured && io.MouseWheel !== 0) {
		const nextZoom = Math.max(0.1, Math.min(8, props.viewport.zoom + io.MouseWheel * 0.1));
		props.onViewportChange({ ...props.viewport, zoom: nextZoom });
	}
	if (inViewport && !uiCaptured && imgui.IsMouseClicked(0)) {
		handleViewportInput(props, panelState, rects, mousePos);
	}
	if (panelState.viewportDragButton === 0 && imgui.IsMouseDragging(0, 0)) {
		const delta = imgui.GetMouseDragDelta(0, 0);
		dragViewportInput(props, panelState, {
			x: delta.x,
			y: delta.y,
		});
	}
	if (!imgui.IsMouseDown(0)) {
		endViewportInput(panelState);
	}
	panelState.imguiCapturesPointer = uiCaptured;
};

const drawEditor = (
	imgui: ActionImGuiFrame,
	props: ActionEditorCanvasProps,
	panelState: PanelState,
	atlasTexture: ActionAtlasTexture | null,
) => {
	const {
		document,
		width,
		height,
		clipsDirs,
		clipsPackErrors,
		onClipsDirClipBind,
	} = props;
	const rects = buildActionRenderRects(document, props.clipDocument, props.selectedLook, props.selectedAnimation, props.playbackTime);
	imgui.SetNextWindowPos({ x: 0, y: 0 }, imgui.Cond.Always, { x: 0, y: 0 });
	imgui.SetNextWindowSize({ x: width, y: height }, imgui.Cond.Always);
	const rootWindowFlags = imgui.WindowFlags.NoTitleBar
		| imgui.WindowFlags.NoCollapse
		| imgui.WindowFlags.NoResize
		| imgui.WindowFlags.NoMove
		| imgui.WindowFlags.NoScrollbar
		| imgui.WindowFlags.NoScrollWithMouse;
	imgui.Begin("ActionEditor", null, rootWindowFlags);
	try {
		renderDiagnosticsPanel(imgui, props);
		const windowPos = imgui.GetWindowPos();
		const contentPos = imgui.GetCursorScreenPos();
		const panelTop = contentPos.y;
		const panelHeight = Math.max(1, imgui.GetContentRegionAvail().y);
		const leftPanelWidth = 250;
		const rightPanelWidth = 290;
		const viewportWidth = Math.max(1, width - leftPanelWidth - rightPanelWidth);
		const panelFlags = imgui.WindowFlags.AlwaysUseWindowPadding;
		const fixedPanelFlags = panelFlags | imgui.WindowFlags.NoScrollbar | imgui.WindowFlags.NoScrollWithMouse;
		const sidePanelFlags = panelState.viewportDragAction !== null
			? (fixedPanelFlags | imgui.WindowFlags.NoInputs)
			: fixedPanelFlags;
		imgui.SetCursorScreenPos({ x: windowPos.x, y: panelTop });
		imgui.BeginChild("left-panel", { x: leftPanelWidth, y: panelHeight }, false, sidePanelFlags);
		try {
			renderClipFileSelector(imgui, props);
			imgui.Separator();
			if (imgui.BeginTabBar("action-editor-left-tabs", imgui.TabBarFlags.FittingPolicyResizeDown)) {
				try {
					if (imgui.BeginTabItem(`${tr(props, "tree")}###tree-tab`)) {
						try {
							imgui.BeginChild(
								"left-tab-content.tree",
								{ x: 0, y: Math.max(1, imgui.GetContentRegionAvail().y) },
								false,
								imgui.WindowFlags.NoScrollbar | imgui.WindowFlags.NoScrollWithMouse,
							);
							try {
								renderNodeCommands(imgui, props, panelState);
								imgui.Separator();
								imgui.SetNextWindowContentSize({
									x: Math.max(imgui.GetContentRegionAvail().x, measureTreeContentWidth(imgui, props, document.root)),
									y: 0,
								});
								imgui.BeginChild(
									"node-tree",
									{ x: 0, y: Math.max(1, imgui.GetContentRegionAvail().y) },
									false,
									imgui.WindowFlags.HorizontalScrollbar,
								);
								try {
									renderTreeNode(imgui, props, panelState, document.root, 0, atlasTexture);
								} finally {
									imgui.EndChild();
								}
							} finally {
								imgui.EndChild();
							}
						} finally {
							imgui.EndTabItem();
						}
					}
					if (imgui.BeginTabItem(`${tr(props, "keyPoints")}###key-points-tab`)) {
						try {
							imgui.BeginChild("left-tab-content.key-points", { x: 0, y: Math.max(1, imgui.GetContentRegionAvail().y) }, false, 0);
							try {
								renderKeyPoints(imgui, props, panelState);
							} finally {
								imgui.EndChild();
							}
						} finally {
							imgui.EndTabItem();
						}
					}
					if (imgui.BeginTabItem(`${tr(props, "clips")}###clips-tab`)) {
						try {
							imgui.BeginChild("left-tab-content.clips", { x: 0, y: Math.max(1, imgui.GetContentRegionAvail().y) }, false, 0);
							try {
								if (!props.readOnly && imgui.Button(props.packing ? tr(props, "packing") : tr(props, "packAll"), { x: 120, y: 0 }) && !props.packing) {
									props.onPackAllClipsDirs();
								}
								if (!props.readOnly) imgui.SameLine();
								if (!props.readOnly && imgui.Button(tr(props, "refresh"), { x: 92, y: 0 })) {
									props.onRefreshClipsDirs();
								}
								imgui.Separator();
								if (clipsDirs.length === 0) {
									imgui.TextDisabled(tr(props, "noClipsDirectoryFound"));
								} else {
									for (const dir of clipsDirs) {
										const rowStart = imgui.GetCursorScreenPos();
										const setButtonWidth = 48;
										const packButtonWidth = 58;
										const buttonGap = 10;
										const nameWidth = props.readOnly
											? imgui.GetContentRegionAvail().x
											: Math.max(60, imgui.GetContentRegionAvail().x - setButtonWidth - packButtonWidth - buttonGap * 2);
										const displayDir = fitTextWidth(imgui, dir, nameWidth);
										imgui.Text(displayDir);
										if (displayDir !== dir && imgui.IsItemHovered()) {
											imgui.SetTooltip(dir);
										}
										if (!props.readOnly) {
											imgui.SetCursorScreenPos({ x: rowStart.x + nameWidth + buttonGap, y: rowStart.y });
											if (imgui.Button(`${tr(props, "set")}##clips-dir-set.${dir}`, { x: setButtonWidth, y: 0 })) {
												onClipsDirClipBind(dir);
											}
											imgui.SetCursorScreenPos({ x: rowStart.x + nameWidth + buttonGap + setButtonWidth + buttonGap, y: rowStart.y });
											if (imgui.Button(`${tr(props, "pack")}##clips-dir-pack.${dir}`, { x: packButtonWidth, y: 0 }) && !props.packing) {
												props.onPackClipsDir(dir);
											}
										}
										const error = clipsPackErrors[dir];
										if (error) {
											imgui.PushTextWrapPos(Math.max(120, imgui.GetContentRegionAvail().x));
											imgui.TextColored({ x: 0.9, y: 0.35, z: 0.25, w: 1 }, error);
											imgui.PopTextWrapPos();
										}
									}
								}
							} finally {
								imgui.EndChild();
							}
						} finally {
							imgui.EndTabItem();
						}
					}
				} finally {
					imgui.EndTabBar();
				}
			}
		} finally {
			imgui.EndChild();
		}
		imgui.SetCursorScreenPos({ x: windowPos.x + leftPanelWidth, y: panelTop });
		imgui.BeginChild("viewport-panel", { x: viewportWidth, y: panelHeight }, false, panelFlags);
		try {
			if (imgui.Button(tr(props, "undo"), { x: 58, y: 0 }) && props.canUndo) {
				props.onUndo();
			}
			imgui.SameLine();
			if (imgui.Button(tr(props, "redo"), { x: 58, y: 0 }) && props.canRedo) {
				props.onRedo();
			}
			imgui.SameLine();
			if (imgui.Button(tr(props, "origin"), { x: 72, y: 0 })) {
				props.onViewportChange(defaultActionViewport());
			}
			imgui.SameLine();
			if (imgui.Button("-", { x: 28, y: 0 })) {
				props.onViewportChange({ ...props.viewport, zoom: Math.max(0.1, props.viewport.zoom - 0.1) });
			}
			imgui.SameLine();
			imgui.Text(tr(props, "zoomValue", { zoom: (props.viewport.zoom * 100).toFixed(0) }));
			imgui.SameLine();
			if (imgui.Button("+", { x: 28, y: 0 })) {
				props.onViewportChange({ ...props.viewport, zoom: Math.min(8, props.viewport.zoom + 0.1) });
			}
			imgui.SameLine();
			const anisotropicFiltering = [panelState.anisotropicFiltering];
			if (imgui.Checkbox(tr(props, "anisotropic"), anisotropicFiltering)) {
				panelState.anisotropicFiltering = anisotropicFiltering[0];
			}
			const timelineHeight = props.editMode === "animation" && props.selectedAnimation !== null ? 72 : 0;
			const pos = imgui.GetCursorScreenPos();
			const area = {
				x: pos.x,
				y: pos.y,
				width: Math.max(1, imgui.GetContentRegionAvail().x),
				height: Math.max(1, imgui.GetContentRegionAvail().y - timelineHeight),
			};
			panelState.viewportArea = area;
			drawRenderRects(imgui, area, props, panelState, rects, atlasTexture);
			if (timelineHeight > 0) {
				renderAnimationTimeline(imgui, props, panelState, {
					x: area.x,
					y: area.y + area.height,
					width: area.width,
					height: timelineHeight,
				});
			}
			handleViewportFrameInput(imgui, props, panelState, rects);
		} finally {
			imgui.EndChild();
		}
		imgui.SetCursorScreenPos({ x: windowPos.x + leftPanelWidth + viewportWidth, y: panelTop });
		imgui.BeginChild("right-panel", { x: rightPanelWidth, y: panelHeight }, false, sidePanelFlags);
		try {
			renderModeTabs(imgui, props, panelState, atlasTexture);
		} finally {
			imgui.EndChild();
		}
	} finally {
		imgui.End();
	}
};

export default memo(function ActionEditorCanvas(props: ActionEditorCanvasProps) {
	const canvasRef = useRef<HTMLCanvasElement | null>(null);
	const runtimeRef = useRef<ActionImGuiRuntime | null>(null);
	const atlasTextureRef = useRef<ActionAtlasTexture | null>(null);
	const propsRef = useRef(props);
	const panelStateRef = useRef<PanelState>({
		moveSourceId: null,
		copiedKeyFrame: null,
		movingKeyTime: null,
		gizmoMode: "select",
		fixedSnap: false,
		anisotropicFiltering: true,
		lastDragDelta: { x: 0, y: 0 },
		viewportDragButton: null,
		viewportDragAction: null,
		viewportArea: { x: 0, y: 0, width: 1, height: 1 },
		imguiCapturesPointer: false,
		dragNodeId: null,
		dragStartPosition: null,
		dragStartRotation: null,
		dragStartPointer: null,
		dragStartPointerAngle: null,
		dragLastPointerAngle: null,
		dragAccumulatedRotationDelta: 0,
		dragAnchorScreen: null,
		timelineDragMode: null,
		timelineDragStartMouseX: 0,
		timelineDragStartOffsetFrame: 0,
		timelineOffsetFrame: 0,
		timelineFollowCursor: true,
		modeTabsNeedSync: true,
		dragHistoryStarted: false,
		inputHistoryStarted: {},
		previewHiddenNodeIds: new Set<string>(),
		visibleKeyPointIndexes: new Set<number>(),
	});
	propsRef.current = props;

	const fallbackDiagnostics = useMemo(() => props.runtimeDiagnostics, [props.runtimeDiagnostics]);

	useEffect(() => {
		panelStateRef.current.previewHiddenNodeIds.clear();
		panelStateRef.current.visibleKeyPointIndexes.clear();
		panelStateRef.current.timelineOffsetFrame = 0;
		panelStateRef.current.timelineFollowCursor = true;
	}, [props.document.modelPath]);

	const disposeAtlasTexture = useCallback(() => {
		if (atlasTextureRef.current) {
			atlasTextureRef.current.native.Destroy();
			atlasTextureRef.current = null;
		}
	}, []);

	const applyAtlasTextureFilter = useCallback((native: any, anisotropicFiltering: boolean) => {
		const gl = ImGui_Impl.gl;
		const texture = native._texture as WebGLTexture | undefined;
		if (!gl || !texture) return;
		const minFilter = anisotropicFiltering ? gl.LINEAR : gl.NEAREST;
		const magFilter = anisotropicFiltering ? gl.LINEAR : gl.NEAREST;
		native._minFilter = minFilter;
		native._magFilter = magFilter;
		gl.bindTexture(gl.TEXTURE_2D, texture);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, minFilter);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, magFilter);
		const ext = gl.getExtension("EXT_texture_filter_anisotropic")
			|| gl.getExtension("MOZ_EXT_texture_filter_anisotropic")
			|| gl.getExtension("WEBKIT_EXT_texture_filter_anisotropic");
		if (ext) {
			const max = anisotropicFiltering ? gl.getParameter(ext.MAX_TEXTURE_MAX_ANISOTROPY_EXT) : 1;
			gl.texParameterf(gl.TEXTURE_2D, ext.TEXTURE_MAX_ANISOTROPY_EXT, Math.max(1, max));
		}
	}, []);

	const getAtlasTexture = useCallback(() => {
		const atlasImage = propsRef.current.atlasImage;
		const anisotropicFiltering = panelStateRef.current.anisotropicFiltering;
		if (!atlasImage) {
			disposeAtlasTexture();
			return null;
		}
		if (atlasTextureRef.current?.path === atlasImage.path) {
			if (atlasTextureRef.current.anisotropicFiltering !== anisotropicFiltering) {
				applyAtlasTextureFilter(atlasTextureRef.current.native, anisotropicFiltering);
				atlasTextureRef.current.anisotropicFiltering = anisotropicFiltering;
			}
			return atlasTextureRef.current;
		}
		disposeAtlasTexture();
		const native = new ImGui_Impl.Texture();
		const gl = ImGui_Impl.gl;
		if (gl) {
			native._minFilter = anisotropicFiltering ? gl.LINEAR : gl.NEAREST;
			native._magFilter = anisotropicFiltering ? gl.LINEAR : gl.NEAREST;
		}
		native.Update(atlasImage.image);
		if (!native._texture) return null;
		applyAtlasTextureFilter(native, anisotropicFiltering);
		atlasTextureRef.current = {
			path: atlasImage.path,
			width: atlasImage.width,
			height: atlasImage.height,
			anisotropicFiltering,
			texture: native._texture,
			native,
		};
		return atlasTextureRef.current;
	}, [applyAtlasTextureFilter, disposeAtlasTexture]);

	const eventPoint = useCallback((event: { clientX: number; clientY: number }) => {
		const canvas = canvasRef.current;
		if (!canvas) return { x: event.clientX, y: event.clientY };
		const rect = canvas.getBoundingClientRect();
		return {
			x: event.clientX - rect.left,
			y: event.clientY - rect.top,
		};
	}, []);

	const pointInViewport = useCallback((point: { x: number; y: number }) => {
		const area = panelStateRef.current.viewportArea;
		return point.x >= area.x
			&& point.x <= area.x + area.width
			&& point.y >= area.y
			&& point.y <= area.y + area.height;
	}, []);

	const handleContextMenu = useCallback((event: MouseEvent) => {
		const point = eventPoint(event);
		if (pointInViewport(point)) {
			event.preventDefault();
			event.stopPropagation();
			endViewportInput(panelStateRef.current);
		}
	}, [eventPoint, pointInViewport]);

	useEffect(() => {
		const canvas = canvasRef.current;
		if (!canvas || !props.active) return;
		let disposed = false;
		let frame = 0;
		const runtime = new ActionImGuiRuntime();
		runtimeRef.current = runtime;
		runtime.init(canvas).then((status) => {
			if (disposed) {
				runtime.dispose();
				return;
			}
			if (!status.ready) {
				return;
			}
			panelStateRef.current.modeTabsNeedSync = true;
			propsRef.current.onRuntimeDiagnostics(status.diagnostics);
			const loop = (time: number) => {
				if (disposed) return;
				const current = propsRef.current;
				try {
					runtime.render(time, (imgui) => drawEditor(imgui, current, panelStateRef.current, getAtlasTexture()));
				} catch (error) {
					const message = error instanceof Error ? error.message : "ActionEditor ImGui render failed";
					console.error("ActionEditor ImGui render failed", error);
					current.onRuntimeDiagnostics([message]);
					renderFallback(canvas, current.t, current.document, current.diagnostics, [message], current.clipDiagnostics, current.readOnly);
				}
				frame = window.requestAnimationFrame(loop);
			};
			frame = window.requestAnimationFrame(loop);
		}).catch((error) => {
			const message = error instanceof Error ? error.message : "ActionEditor ImGui runtime failed";
			propsRef.current.onRuntimeDiagnostics([message]);
			renderFallback(canvas, propsRef.current.t, propsRef.current.document, propsRef.current.diagnostics, [message], propsRef.current.clipDiagnostics, propsRef.current.readOnly);
		});
		return () => {
			disposed = true;
			if (frame) window.cancelAnimationFrame(frame);
			disposeAtlasTexture();
			runtime.dispose();
			runtimeRef.current = null;
		};
	}, [disposeAtlasTexture, getAtlasTexture, props.active]);

	useEffect(() => {
		const canvas = canvasRef.current;
		if (!canvas || !props.active || runtimeRef.current) return;
		renderFallback(canvas, props.t, props.document, props.diagnostics, fallbackDiagnostics, props.clipDiagnostics, props.readOnly);
	}, [props, fallbackDiagnostics]);

	useEffect(() => {
		const canvas = canvasRef.current;
		if (!canvas || !props.active) return;
		const onContextMenu = (event: MouseEvent) => handleContextMenu(event);
		canvas.addEventListener("contextmenu", onContextMenu, true);
		return () => {
			canvas.removeEventListener("contextmenu", onContextMenu, true);
		};
	}, [handleContextMenu, props.active]);

	return (
		<canvas
			ref={canvasRef}
			tabIndex={0}
			width={props.width}
			height={props.height}
			style={{
				display: "block",
				width: props.width,
				height: props.height,
				background: "#1f1f1f",
				outline: "none",
			}}
		/>
	);
});
