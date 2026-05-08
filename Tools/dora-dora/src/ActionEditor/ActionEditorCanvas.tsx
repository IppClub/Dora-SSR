import React, {memo, useEffect, useMemo, useRef} from "react";
import {ImGui_Impl} from "@zhobo63/imgui-ts";
import type {ActionClipDocument} from "./ActionClip";
import type {ActionDocument, ActionDiagnostic, ActionKeyFrame, ActionNode} from "./ActionDocument";
import type {ActionViewport} from "./ActionEditorState";
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
	getActionAnimationDuration,
	moveActionKeyFrame,
	pasteActionKeyFrame,
	removeActionAnimation,
	setActionKeyFrameEvent,
	upsertActionKeyFrame,
} from "./ActionPlayback";
import {
	ActionRenderRect,
	buildActionRenderRects,
	hitTestActionRenderRects,
	modelToScreen,
	renderRectCornersToViewport,
	renderRectToViewport,
	screenToModel,
} from "./ActionRender";
import {ActionImGuiRuntime, ActionImGuiFrame} from "./ActionImGuiRuntime";

export type ActionEditorMode = "pose" | "look" | "animation";

export type ActionEditorCanvasProps = {
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
	selectedClipsDir?: string;
	selectedNodeId: string;
	editMode: ActionEditorMode;
	selectedLook: string | null;
	selectedAnimation: string | null;
	playbackTime: number;
	playbackPlaying: boolean;
	playbackLoop: boolean;
	viewport: ActionViewport;
	onDocumentChange: (document: ActionDocument) => void;
	onClipsDirSelect: (clipsDir: string) => void;
	onPackClipsDir: () => void;
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

type PanelState = {
	moveSourceId: string | null;
	copiedKeyFrame: ActionKeyFrame | null;
	movingKeyTime: number | null;
	gizmoMode: "move" | "scale" | "rotate" | "anchor" | "size";
	fixedSnap: boolean;
	lastDragDelta: {x: number; y: number};
	viewportDragButton: 0 | 1 | null;
};

type ActionAtlasTexture = {
	path: string;
	width: number;
	height: number;
	texture: WebGLTexture;
	native: any;
};

const gray = 0xff3a3a3a;
const grid = 0xff343434;
const text = 0xffd6d6d6;
const normalNode = 0xff8f6c3d;
const missingNode = 0xff4060bf;
const selectedNode = 0xff4cc6ff;
const originColor = 0xff5f5f5f;

const snapValue = (value: number, fixed: boolean, step: number) => fixed ? Math.round(value / step) * step : value;

const renderFallback = (
	canvas: HTMLCanvasElement,
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
	ctx.fillText("ActionEditor", 18, 28);
	ctx.fillStyle = readOnly ? "#c8b188" : "#cfcfcf";
	ctx.fillText(readOnly ? "Read Only" : "Canvas Runtime", width - 130, 28);
	ctx.font = "13px sans-serif";
	const messages = diagnostics.length > 0
		? ["加载失败，已创建空对象，保存将写入新的 .model。", diagnostics[0].message]
		: [
			`Model: ${document.modelPath ?? ""}`,
			`Clip: ${document.clipFile || "(none)"}`,
			`Nodes: ${countActionNodes(document.root)}`,
			`Animations: ${document.animations.length}`,
			`Looks: ${document.looks.length}`,
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
) => {
	props.onDocumentChange(setActionNode(props.document, nodeId, updater));
};

const renderTreeNode = (
	imgui: ActionImGuiFrame,
	props: ActionEditorCanvasProps,
	node: ActionNode,
	depth: number,
	atlasTexture: ActionAtlasTexture | null,
) => {
	const selected = props.selectedNodeId === node.id;
	const label = `${node.name || (node.id === props.document.root.id ? "Root" : "Node")}##${node.id}`;
	const clipRect = node.clip ? props.clipDocument?.rects[node.clip] : undefined;
	const rowHeight = 34;
	const previewSize = 30;
	if (depth > 0) {
		imgui.Indent(depth * 14);
	}
	const rowStart = imgui.GetCursorScreenPos();
	imgui.PushID(`tree-preview.${node.id}`);
	if (imgui.InvisibleButton("preview", {x: previewSize, y: previewSize}, 0)) {
		props.onSelectionChange(node.id);
	}
	const drawList = imgui.GetWindowDrawList();
	drawList.AddRectFilled(
		rowStart,
		{x: rowStart.x + previewSize, y: rowStart.y + previewSize},
		0xff303030,
		0,
		0,
	);
	if (atlasTexture && clipRect && clipRect.width > 0 && clipRect.height > 0) {
		const scale = Math.min(previewSize / clipRect.width, previewSize / clipRect.height);
		const imageWidth = Math.max(1, clipRect.width * scale);
		const imageHeight = Math.max(1, clipRect.height * scale);
		const imagePos = {
			x: rowStart.x + (previewSize - imageWidth) / 2,
			y: rowStart.y + (previewSize - imageHeight) / 2,
		};
		drawList.AddImage(
			atlasTexture.texture,
			imagePos,
			{x: imagePos.x + imageWidth, y: imagePos.y + imageHeight},
			{x: clipRect.x / atlasTexture.width, y: clipRect.y / atlasTexture.height},
			{x: (clipRect.x + clipRect.width) / atlasTexture.width, y: (clipRect.y + clipRect.height) / atlasTexture.height},
			0xffffffff,
		);
	}
	imgui.PopID();
	imgui.SameLine();
	imgui.SetCursorScreenPos({x: rowStart.x + previewSize + 8, y: rowStart.y + 4});
	if (imgui.Selectable(label, selected, 0, {x: 0, y: 22})) {
		props.onSelectionChange(node.id);
	}
	imgui.SetCursorScreenPos({x: rowStart.x, y: rowStart.y + rowHeight});
	if (depth > 0) {
		imgui.Unindent(depth * 14);
	}
	for (const child of node.children) {
		renderTreeNode(imgui, props, child, depth + 1, atlasTexture);
	}
};

const renderNodeCommands = (
	imgui: ActionImGuiFrame,
	props: ActionEditorCanvasProps,
	panelState: PanelState,
) => {
	const selected = findActionNode(props.document.root, props.selectedNodeId) ?? props.document.root;
	if (!props.readOnly && imgui.Button("Add Child", {x: 86, y: 0})) {
		const next = addChildActionNode(props.document, selected.id);
		props.onDocumentChange(next);
	}
	if (selected.id !== props.document.root.id) {
		imgui.SameLine();
		if (!props.readOnly && imgui.Button("Delete", {x: 72, y: 0})) {
			props.onDocumentChange(removeActionNode(props.document, selected.id));
			props.onSelectionChange(props.document.root.id);
		}
		if (!props.readOnly && imgui.Button("Up", {x: 50, y: 0})) {
			props.onDocumentChange(reorderActionNode(props.document, selected.id, -1));
		}
		imgui.SameLine();
		if (!props.readOnly && imgui.Button("Down", {x: 62, y: 0})) {
			props.onDocumentChange(reorderActionNode(props.document, selected.id, 1));
		}
		imgui.SameLine();
		if (!props.readOnly && imgui.Button(panelState.moveSourceId === selected.id ? "Cancel Move" : "Move", {x: 96, y: 0})) {
			panelState.moveSourceId = panelState.moveSourceId === selected.id ? null : selected.id;
		}
		if (panelState.moveSourceId && panelState.moveSourceId !== selected.id) {
			if (imgui.Button("Move Here", {x: 96, y: 0})) {
				props.onDocumentChange(moveActionNodeToParent(props.document, panelState.moveSourceId, selected.id));
				panelState.moveSourceId = null;
			}
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

const inputNumber = (
	imgui: ActionImGuiFrame,
	label: string,
	value: number,
	readOnly: boolean,
	step = 1,
) => {
	const box = [value];
	const changed = imgui.InputDouble(label, box, step, step * 10, "%.3f", readOnly ? imgui.InputTextFlags.ReadOnly : 0);
	return changed && !readOnly ? box[0] : null;
};

const propertyLabel = (imgui: ActionImGuiFrame, label: string) => {
	imgui.SameLine();
	imgui.Text(label);
};

const propertyText = (
	imgui: ActionImGuiFrame,
	label: string,
	id: string,
	value: string,
	readOnly: boolean,
) => {
	const inputWidth = Math.max(80, imgui.GetContentRegionAvail().x - 68);
	imgui.SetNextItemWidth(inputWidth);
	const next = inputText(imgui, `##${id}`, value, readOnly);
	propertyLabel(imgui, label);
	return next;
};

const propertyNumber = (
	imgui: ActionImGuiFrame,
	label: string,
	id: string,
	value: number,
	readOnly: boolean,
	step = 1,
) => {
	const inputWidth = Math.max(80, imgui.GetContentRegionAvail().x - 68);
	imgui.SetNextItemWidth(inputWidth);
	const next = inputNumber(imgui, `##${id}`, value, readOnly, step);
	propertyLabel(imgui, label);
	return next;
};

const propertyNumberPair = (
	imgui: ActionImGuiFrame,
	label: string,
	id: string,
	first: number,
	second: number,
	readOnly: boolean,
	step = 1,
) => {
	const inputArea = Math.max(120, imgui.GetContentRegionAvail().x - 68);
	const gap = 8;
	const inputWidth = Math.max(48, (inputArea - gap) / 2);
	imgui.SetNextItemWidth(inputWidth);
	const firstNext = inputNumber(imgui, `##${id}.0`, first, readOnly, step);
	imgui.SameLine(0, gap);
	imgui.SetNextItemWidth(inputWidth);
	const secondNext = inputNumber(imgui, `##${id}.1`, second, readOnly, step);
	propertyLabel(imgui, label);
	return [firstNext, secondNext] as const;
};

const renderProperties = (
	imgui: ActionImGuiFrame,
	props: ActionEditorCanvasProps,
) => {
	const selected = findActionNode(props.document.root, props.selectedNodeId) ?? props.document.root;
	const nextName = propertyText(imgui, "Name", "prop.name", selected.name, props.readOnly);
	if (nextName !== null) {
		emitNodeChange(props, selected.id, (node) => ({...node, name: nextName}));
	}
	const nextClip = propertyText(imgui, "Clip", "prop.clip", selected.clip, props.readOnly);
	if (nextClip !== null) {
		emitNodeChange(props, selected.id, (node) => ({...node, clip: nextClip}));
	}
	const front = [selected.front];
	if (imgui.Checkbox("Face Right / Front", front) && !props.readOnly) {
		emitNodeChange(props, selected.id, (node) => ({...node, front: front[0]}));
	}
	const updateTransform = (updater: (node: ActionNode) => ActionNode) => emitNodeChange(props, selected.id, updater);
	const [x, y] = propertyNumberPair(imgui, "Position", "prop.position", selected.transform.position.x, selected.transform.position.y, props.readOnly);
	if (x !== null) updateTransform((node) => ({...node, transform: {...node.transform, position: {...node.transform.position, x}}}));
	if (y !== null) updateTransform((node) => ({...node, transform: {...node.transform, position: {...node.transform.position, y}}}));
	const [scaleX, scaleY] = propertyNumberPair(imgui, "Scale", "prop.scale", selected.transform.scale.x, selected.transform.scale.y, props.readOnly, 0.1);
	if (scaleX !== null) updateTransform((node) => ({...node, transform: {...node.transform, scale: {...node.transform.scale, x: scaleX}}}));
	if (scaleY !== null) updateTransform((node) => ({...node, transform: {...node.transform, scale: {...node.transform.scale, y: scaleY}}}));
	const rotation = propertyNumber(imgui, "Rotation", "prop.rotation", selected.transform.rotation, props.readOnly);
	if (rotation !== null) updateTransform((node) => ({...node, transform: {...node.transform, rotation}}));
	const [skewX, skewY] = propertyNumberPair(imgui, "Skew", "prop.skew", selected.transform.skew.x, selected.transform.skew.y, props.readOnly, 0.1);
	if (skewX !== null) updateTransform((node) => ({...node, transform: {...node.transform, skew: {...node.transform.skew, x: skewX}}}));
	if (skewY !== null) updateTransform((node) => ({...node, transform: {...node.transform, skew: {...node.transform.skew, y: skewY}}}));
	const opacity = propertyNumber(imgui, "Opacity", "prop.opacity", selected.transform.opacity, props.readOnly, 0.05);
	if (opacity !== null) updateTransform((node) => ({...node, transform: {...node.transform, opacity: Math.max(0, Math.min(1, opacity))}}));
	const [anchorX, anchorY] = propertyNumberPair(imgui, "Anchor", "prop.anchor", selected.transform.anchor.x, selected.transform.anchor.y, props.readOnly, 0.05);
	if (anchorX !== null) updateTransform((node) => ({...node, transform: {...node.transform, anchor: {...node.transform.anchor, x: anchorX}}}));
	if (anchorY !== null) updateTransform((node) => ({...node, transform: {...node.transform, anchor: {...node.transform.anchor, y: anchorY}}}));
	if (selected.id === props.document.root.id) {
		const [width, height] = propertyNumberPair(imgui, "Model Size", "prop.model-size", props.document.size.width, props.document.size.height, props.readOnly);
		if (width !== null) {
			const next = cloneActionDocument(props.document);
			next.size.width = Math.max(0, Math.round(width));
			props.onDocumentChange(next);
		}
		if (height !== null) {
			const next = cloneActionDocument(props.document);
			next.size.height = Math.max(0, Math.round(height));
			props.onDocumentChange(next);
		}
	}
};

const renderKeyPoints = (
	imgui: ActionImGuiFrame,
	props: ActionEditorCanvasProps,
) => {
	if (!props.readOnly && imgui.Button("Add Point", {x: 92, y: 0})) {
		props.onDocumentChange(addActionKeyPoint(props.document));
	}
	for (let index = 0; index < props.document.keyPoints.length; index += 1) {
		const point = props.document.keyPoints[index];
		imgui.Separator();
		imgui.Text(`Point ${index + 1}`);
		const name = inputText(imgui, `Name##kp-name-${index}`, point.name, props.readOnly);
		if (name !== null) {
			props.onDocumentChange(updateActionKeyPoint(props.document, index, (item) => ({...item, name})));
		}
		const x = inputNumber(imgui, `X##kp-x-${index}`, point.x, props.readOnly);
		if (x !== null) {
			props.onDocumentChange(updateActionKeyPoint(props.document, index, (item) => ({...item, x})));
		}
		const y = inputNumber(imgui, `Y##kp-y-${index}`, point.y, props.readOnly);
		if (y !== null) {
			props.onDocumentChange(updateActionKeyPoint(props.document, index, (item) => ({...item, y})));
		}
		if (!props.readOnly && imgui.Button(`Delete Point##kp-del-${index}`, {x: 116, y: 0})) {
			props.onDocumentChange(removeActionKeyPoint(props.document, index));
		}
	}
};

const renderLooks = (
	imgui: ActionImGuiFrame,
	props: ActionEditorCanvasProps,
) => {
	if (!props.readOnly && imgui.Button("Add Look", {x: 90, y: 0})) {
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
		if (!props.readOnly && imgui.Button("Delete Look", {x: 106, y: 0})) {
			props.onDocumentChange(removeActionLook(props.document, props.selectedLook));
			props.onLookSelect(null);
		}
	}
	for (const look of props.document.looks) {
		if (imgui.Selectable(`${look}##look.${look}`, props.selectedLook === look, 0, {x: 0, y: 22})) {
			props.onLookSelect(look);
			props.onAnimationSelect(null);
			props.onPlaybackPlayingChange(false);
		}
	}
	if (props.selectedLook !== null) {
		imgui.Separator();
		imgui.Text(`Look: ${props.selectedLook}`);
		const selected = findActionNode(props.document.root, props.selectedNodeId) ?? props.document.root;
		const hidden = [selected.hiddenInLooks.indexOf(props.selectedLook) >= 0];
		if (imgui.Checkbox("Hide selected node in look", hidden) && !props.readOnly) {
			props.onDocumentChange(setActionNodeLookHidden(props.document, selected.id, props.selectedLook, hidden[0]));
		}
	} else {
		imgui.Separator();
		imgui.TextDisabled("Select or add a look to edit node visibility.");
	}
};

const renderAnimations = (
	imgui: ActionImGuiFrame,
	props: ActionEditorCanvasProps,
	panelState: PanelState,
) => {
	imgui.Text("Look");
	if (imgui.Selectable("Default##anim-look.default", props.selectedLook === null, 0, {x: 0, y: 22})) {
		props.onLookSelect(null);
	}
	for (const look of props.document.looks) {
		if (imgui.Selectable(`${look}##anim-look.${look}`, props.selectedLook === look, 0, {x: 0, y: 22})) {
			props.onLookSelect(look);
		}
	}
	imgui.Separator();
	if (!props.readOnly && imgui.Button("Add Animation", {x: 124, y: 0})) {
		const result = addActionAnimation(props.document);
		props.onDocumentChange(result.document);
		props.onAnimationSelect(result.animation);
		props.onPlaybackTimeChange(0);
	}
	if (props.selectedAnimation !== null) {
		imgui.SameLine();
		if (!props.readOnly && imgui.Button("Delete Animation", {x: 142, y: 0})) {
			props.onDocumentChange(removeActionAnimation(props.document, props.selectedAnimation));
			props.onAnimationSelect(null);
			props.onPlaybackTimeChange(0);
		}
	}
	for (const animation of props.document.animations) {
		if (imgui.Selectable(`${animation}##anim.${animation}`, props.selectedAnimation === animation, 0, {x: 0, y: 22})) {
			props.onAnimationSelect(animation);
			props.onPlaybackTimeChange(0);
		}
	}
	if (props.selectedAnimation === null) return;
	imgui.Separator();
	imgui.Text(`Animation: ${props.selectedAnimation}`);
	const duration = getActionAnimationDuration(props.document, props.selectedAnimation);
	if (imgui.Button(props.playbackPlaying ? "Pause" : "Play", {x: 64, y: 0})) {
		props.onPlaybackPlayingChange(!props.playbackPlaying);
	}
	imgui.SameLine();
	const loop = [props.playbackLoop];
	if (imgui.Checkbox("Loop", loop)) {
		props.onPlaybackLoopChange(loop[0]);
	}
	const time = inputNumber(imgui, "Time", props.playbackTime, props.readOnly, 1 / 60);
	if (time !== null) {
		props.onPlaybackTimeChange(Math.max(0, time));
	}
	imgui.Text(`Frame ${Math.round(props.playbackTime * 60)} / ${Math.round(duration * 60)}`);
	const selected = findActionNode(props.document.root, props.selectedNodeId) ?? props.document.root;
	const track = selected.tracks[props.selectedAnimation];
	const currentFrame = track?.type === "key"
		? track.keyframes.find((frame) => Math.abs(frame.time - props.playbackTime) < 1 / 120)
		: undefined;
	if (!props.readOnly && imgui.Button(currentFrame ? "Update Key" : "Add Key", {x: 96, y: 0})) {
		props.onDocumentChange(upsertActionKeyFrame(props.document, selected.id, props.selectedAnimation, props.playbackTime));
	}
	imgui.SameLine();
	if (!props.readOnly && imgui.Button("Delete Key", {x: 96, y: 0})) {
		props.onDocumentChange(deleteActionKeyFrame(props.document, selected.id, props.selectedAnimation, props.playbackTime));
	}
	if (currentFrame) {
		if (!props.readOnly && imgui.Button("Copy Key", {x: 88, y: 0})) {
			panelState.copiedKeyFrame = copyActionKeyFrame(props.document, selected.id, props.selectedAnimation, props.playbackTime);
		}
		imgui.SameLine();
		if (!props.readOnly && imgui.Button(panelState.movingKeyTime === null ? "Move Key" : "Cancel Move", {x: 110, y: 0})) {
			panelState.movingKeyTime = panelState.movingKeyTime === null ? props.playbackTime : null;
		}
	}
	if (panelState.copiedKeyFrame !== null) {
		if (!props.readOnly && imgui.Button("Paste Key Here", {x: 126, y: 0})) {
			props.onDocumentChange(pasteActionKeyFrame(props.document, selected.id, props.selectedAnimation, props.playbackTime, panelState.copiedKeyFrame));
		}
	}
	if (panelState.movingKeyTime !== null && Math.abs(panelState.movingKeyTime - props.playbackTime) >= 1 / 120) {
		imgui.SameLine();
		if (!props.readOnly && imgui.Button("Move Here", {x: 92, y: 0})) {
			props.onDocumentChange(moveActionKeyFrame(props.document, selected.id, props.selectedAnimation, panelState.movingKeyTime, props.playbackTime));
			panelState.movingKeyTime = null;
		}
	}
	if (currentFrame) {
		const event = inputText(imgui, "Event", currentFrame.event ?? "", props.readOnly);
		if (event !== null) {
			props.onDocumentChange(setActionKeyFrameEvent(props.document, selected.id, props.selectedAnimation, props.playbackTime, event));
		}
	}
	if (track?.type === "key" && track.keyframes.length > 0) {
		imgui.Text("Keys");
		for (const frame of track.keyframes) {
			const label = `${Math.round(frame.time * 60)}f ${frame.event ?? ""}##key.${frame.time}`;
			if (imgui.Selectable(label, Math.abs(frame.time - props.playbackTime) < 1 / 120, 0, {x: 0, y: 22})) {
				props.onPlaybackTimeChange(frame.time);
			}
		}
	}
};

const renderModeTabs = (
	imgui: ActionImGuiFrame,
	props: ActionEditorCanvasProps,
	panelState: PanelState,
) => {
	const drawTab = (label: string, mode: ActionEditorMode, width: number) => {
		if (imgui.Selectable(`${label}##mode.${mode}`, props.editMode === mode, 0, {x: width, y: 28}) && props.editMode !== mode) {
			props.onEditModeChange(mode);
		}
	};
	drawTab("Pose", "pose", 72);
	imgui.SameLine();
	drawTab("Look", "look", 72);
	imgui.SameLine();
	drawTab("Animation", "animation", 116);
	imgui.Separator();
	if (props.editMode === "look") {
		renderLooks(imgui, props);
	} else if (props.editMode === "animation") {
		renderAnimations(imgui, props, panelState);
	} else {
		renderProperties(imgui, props);
	}
};

const drawGrid = (
	drawList: any,
	area: {x: number; y: number; width: number; height: number},
	viewport: ActionViewport,
) => {
	drawList.AddRectFilled({x: area.x, y: area.y}, {x: area.x + area.width, y: area.y + area.height}, gray, 0, 0);
	const step = Math.max(16, 64 * viewport.zoom);
	const center = modelToScreen({x: 0, y: 0}, viewport, area);
	for (let x = center.x % step; x < area.x + area.width; x += step) {
		if (x >= area.x) drawList.AddLine({x, y: area.y}, {x, y: area.y + area.height}, grid, 1);
	}
	for (let y = center.y % step; y < area.y + area.height; y += step) {
		if (y >= area.y) drawList.AddLine({x: area.x, y}, {x: area.x + area.width, y}, grid, 1);
	}
	drawList.AddLine({x: area.x, y: center.y}, {x: area.x + area.width, y: center.y}, originColor, 1);
	drawList.AddLine({x: center.x, y: area.y}, {x: center.x, y: area.y + area.height}, originColor, 1);
};

const drawRenderRects = (
	imgui: ActionImGuiFrame,
	area: {x: number; y: number; width: number; height: number},
	props: ActionEditorCanvasProps,
	rects: ActionRenderRect[],
	atlasTexture: ActionAtlasTexture | null,
) => {
	const drawList = imgui.GetWindowDrawList();
	drawGrid(drawList, area, props.viewport);
	for (const rect of rects) {
		if (!rect.visible) continue;
		const screen = renderRectToViewport(rect, props.viewport, area);
		const corners = renderRectCornersToViewport(rect, props.viewport, area);
		const color = rect.missingClip ? missingNode : normalNode;
		if (atlasTexture && !rect.missingClip && rect.clip) {
			drawList.AddImageQuad(
				atlasTexture.texture,
				corners[0],
				corners[1],
				corners[2],
				corners[3],
				{x: rect.sourceX / atlasTexture.width, y: rect.sourceY / atlasTexture.height},
				{x: (rect.sourceX + rect.sourceWidth) / atlasTexture.width, y: rect.sourceY / atlasTexture.height},
				{x: (rect.sourceX + rect.sourceWidth) / atlasTexture.width, y: (rect.sourceY + rect.sourceHeight) / atlasTexture.height},
				{x: rect.sourceX / atlasTexture.width, y: (rect.sourceY + rect.sourceHeight) / atlasTexture.height},
				0xffffffff,
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
			rect.nodeId === props.selectedNodeId ? selectedNode : 0xff202020,
			rect.nodeId === props.selectedNodeId ? 3 : 1,
		);
	}
};

const handleViewportInput = (
	imgui: ActionImGuiFrame,
	props: ActionEditorCanvasProps,
	panelState: PanelState,
	rects: ActionRenderRect[],
	area: {x: number; y: number; width: number; height: number},
) => {
	imgui.SetCursorScreenPos({x: area.x, y: area.y});
	imgui.InvisibleButton("viewport-hit", {x: area.width, y: area.height}, 0);
	const hovered = imgui.IsItemHovered();
	const io = imgui.GetIO();
	if (hovered && io.MouseWheel !== 0) {
		const nextZoom = Math.max(0.1, Math.min(8, props.viewport.zoom + io.MouseWheel * 0.1));
		props.onViewportChange({...props.viewport, zoom: nextZoom});
	}
	if (hovered && imgui.IsMouseClicked(0)) {
		const point = screenToModel(io.MousePos, props.viewport, area);
		const nodeId = hitTestActionRenderRects(rects, point);
		if (nodeId) props.onSelectionChange(nodeId);
		panelState.lastDragDelta = {x: 0, y: 0};
		panelState.viewportDragButton = 0;
	}
	if (hovered && imgui.IsMouseClicked(1)) {
		panelState.lastDragDelta = {x: 0, y: 0};
		panelState.viewportDragButton = 1;
	}
	if (panelState.viewportDragButton === 1 && imgui.IsMouseDragging(1, 0)) {
		const delta = imgui.GetMouseDragDelta(1, 0);
		const diff = {
			x: delta.x - panelState.lastDragDelta.x,
			y: delta.y - panelState.lastDragDelta.y,
		};
		if (diff.x !== 0 || diff.y !== 0) {
			props.onViewportChange({
				...props.viewport,
				pan: {x: props.viewport.pan.x + diff.x, y: props.viewport.pan.y + diff.y},
			});
			panelState.lastDragDelta = {x: delta.x, y: delta.y};
		}
	}
	if (!props.readOnly && props.editMode !== "look" && panelState.viewportDragButton === 0 && imgui.IsMouseDragging(0, 0)) {
		const delta = imgui.GetMouseDragDelta(0, 0);
		const diff = {
			x: (delta.x - panelState.lastDragDelta.x) / props.viewport.zoom,
			y: -(delta.y - panelState.lastDragDelta.y) / props.viewport.zoom,
		};
		if (diff.x !== 0 || diff.y !== 0) {
			const selectedRect = rects.find((rect) => rect.nodeId === props.selectedNodeId);
			if (panelState.gizmoMode === "size" && props.selectedNodeId === props.document.root.id) {
				const next = cloneActionDocument(props.document);
				next.size.width = Math.max(0, Math.round(snapValue(next.size.width + diff.x, panelState.fixedSnap, 1)));
				next.size.height = Math.max(0, Math.round(snapValue(next.size.height + diff.y, panelState.fixedSnap, 1)));
				props.onDocumentChange(next);
			} else {
				emitNodeChange(props, props.selectedNodeId, (node) => {
					if (panelState.gizmoMode === "scale") {
						return {
							...node,
							transform: {
								...node.transform,
								scale: {
									x: Math.max(0.01, snapValue(node.transform.scale.x + diff.x / 100, panelState.fixedSnap, 0.1)),
									y: Math.max(0.01, snapValue(node.transform.scale.y + diff.y / 100, panelState.fixedSnap, 0.1)),
								},
							},
						};
					}
					if (panelState.gizmoMode === "rotate") {
						return {
							...node,
							transform: {
								...node.transform,
								rotation: snapValue(node.transform.rotation + diff.x, panelState.fixedSnap, 5),
							},
						};
					}
					if (panelState.gizmoMode === "anchor" && selectedRect) {
						return {
							...node,
							transform: {
								...node.transform,
								anchor: {
									x: snapValue(node.transform.anchor.x + diff.x / Math.max(1, selectedRect.width), panelState.fixedSnap, 0.05),
									y: snapValue(node.transform.anchor.y + diff.y / Math.max(1, selectedRect.height), panelState.fixedSnap, 0.05),
								},
							},
						};
					}
					return {
						...node,
						transform: {
							...node.transform,
							position: {
								x: snapValue(node.transform.position.x + diff.x, panelState.fixedSnap, 1),
								y: snapValue(node.transform.position.y + diff.y, panelState.fixedSnap, 1),
							},
						},
					};
				});
			}
			panelState.lastDragDelta = {x: delta.x, y: delta.y};
		}
	}
	if (!imgui.IsMouseDown(0) && !imgui.IsMouseDown(1)) {
		panelState.lastDragDelta = {x: 0, y: 0};
		panelState.viewportDragButton = null;
	}
};

const drawEditor = (
	imgui: ActionImGuiFrame,
	props: ActionEditorCanvasProps,
	panelState: PanelState,
	atlasTexture: ActionAtlasTexture | null,
) => {
	const {
		document,
		diagnostics,
		runtimeDiagnostics,
		clipDiagnostics,
		width,
		height,
		clipsDirs,
		selectedClipsDir,
		onClipsDirSelect,
	} = props;
	const rects = buildActionRenderRects(document, props.clipDocument, props.selectedLook, props.selectedAnimation, props.playbackTime);
	imgui.SetNextWindowPos({x: 0, y: 0}, imgui.Cond.Always, {x: 0, y: 0});
	imgui.SetNextWindowSize({x: width, y: height}, imgui.Cond.Always);
	const rootWindowFlags = imgui.WindowFlags.NoTitleBar
		| imgui.WindowFlags.NoCollapse
		| imgui.WindowFlags.NoResize
		| imgui.WindowFlags.NoMove
		| imgui.WindowFlags.NoScrollbar
		| imgui.WindowFlags.NoScrollWithMouse;
	imgui.Begin("ActionEditor", null, rootWindowFlags);
	try {
		if (diagnostics.length > 0) {
			imgui.TextColored({x: 0.9, y: 0.52, z: 0.45, w: 1}, "加载失败，已创建空对象，保存将写入新的 .model。");
			imgui.TextWrapped(diagnostics[0].message);
		}
		for (const message of runtimeDiagnostics) {
			imgui.TextColored({x: 0.9, y: 0.52, z: 0.45, w: 1}, message);
		}
		for (const message of clipDiagnostics) {
			imgui.TextColored({x: 0.9, y: 0.72, z: 0.32, w: 1}, message);
		}
		const windowPos = imgui.GetWindowPos();
		const contentPos = imgui.GetCursorScreenPos();
		const panelTop = contentPos.y;
		const panelHeight = Math.max(1, imgui.GetContentRegionAvail().y);
		const leftPanelWidth = 250;
		const rightPanelWidth = 310;
		const viewportWidth = Math.max(1, width - leftPanelWidth - rightPanelWidth);
		const panelFlags = imgui.WindowFlags.AlwaysUseWindowPadding;
		imgui.SetCursorScreenPos({x: windowPos.x, y: panelTop});
		imgui.BeginChild("left-panel", {x: leftPanelWidth, y: panelHeight}, false, panelFlags);
		try {
			imgui.Text(`Clip: ${document.clipFile || "(none)"}`);
			imgui.Text(`Nodes: ${countActionNodes(document.root)}`);
			imgui.Separator();
			renderNodeCommands(imgui, props, panelState);
			imgui.Separator();
			renderTreeNode(imgui, props, document.root, 0, atlasTexture);
			imgui.Separator();
			imgui.Text("Key Points");
			renderKeyPoints(imgui, props);
			imgui.Separator();
			imgui.Text(".clips directories");
			if (clipsDirs.length === 0) {
				imgui.TextDisabled("No .clips directory found beside the .model file.");
			} else {
				for (const dir of clipsDirs) {
					const label = dir === selectedClipsDir ? `* ${dir}` : dir;
					if (imgui.Button(label, {x: 220, y: 0}) && !props.readOnly) {
						onClipsDirSelect(dir);
					}
				}
				if (!props.readOnly && imgui.Button(props.packing ? "Packing..." : "Pack Atlas", {x: 120, y: 0}) && !props.packing) {
					props.onPackClipsDir();
				}
			}
		} finally {
			imgui.EndChild();
		}
		imgui.SetCursorScreenPos({x: windowPos.x + leftPanelWidth, y: panelTop});
		imgui.BeginChild("viewport-panel", {x: viewportWidth, y: panelHeight}, false, panelFlags);
		try {
			if (imgui.Button("Undo", {x: 58, y: 0}) && props.canUndo) {
				props.onUndo();
			}
			imgui.SameLine();
			if (imgui.Button("Redo", {x: 58, y: 0}) && props.canRedo) {
				props.onRedo();
			}
			imgui.SameLine();
			if (imgui.Button("Origin", {x: 72, y: 0})) {
				props.onViewportChange(defaultActionViewport());
			}
			imgui.SameLine();
			if (imgui.Button("-", {x: 28, y: 0})) {
				props.onViewportChange({...props.viewport, zoom: Math.max(0.1, props.viewport.zoom - 0.1)});
			}
			imgui.SameLine();
			imgui.Text(`Zoom ${(props.viewport.zoom * 100).toFixed(0)}%`);
			imgui.SameLine();
			if (imgui.Button("+", {x: 28, y: 0})) {
				props.onViewportChange({...props.viewport, zoom: Math.min(8, props.viewport.zoom + 0.1)});
			}
			if (props.editMode !== "look") {
				for (const mode of ["move", "scale", "rotate", "anchor", "size"] as const) {
					imgui.SameLine();
					if (imgui.Button(`${panelState.gizmoMode === mode ? "*" : ""}${mode}`, {x: 72, y: 0})) {
						panelState.gizmoMode = mode;
					}
				}
				imgui.SameLine();
				const fixed = [panelState.fixedSnap];
				if (imgui.Checkbox("Fixed", fixed)) {
					panelState.fixedSnap = fixed[0];
				}
			} else {
				imgui.SameLine();
				imgui.Text(props.selectedLook === null ? "Look" : `Look ${props.selectedLook}`);
			}
			const pos = imgui.GetCursorScreenPos();
			const area = {
				x: pos.x,
				y: pos.y,
				width: Math.max(1, imgui.GetContentRegionAvail().x),
				height: Math.max(1, imgui.GetContentRegionAvail().y),
			};
			drawRenderRects(imgui, area, props, rects, atlasTexture);
			handleViewportInput(imgui, props, panelState, rects, area);
		} finally {
			imgui.EndChild();
		}
		imgui.SetCursorScreenPos({x: windowPos.x + leftPanelWidth + viewportWidth, y: panelTop});
		imgui.BeginChild("right-panel", {x: rightPanelWidth, y: panelHeight}, false, panelFlags);
		try {
			renderModeTabs(imgui, props, panelState);
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
		gizmoMode: "move",
		fixedSnap: false,
		lastDragDelta: {x: 0, y: 0},
		viewportDragButton: null,
	});
	propsRef.current = props;

	const fallbackDiagnostics = useMemo(() => props.runtimeDiagnostics, [props.runtimeDiagnostics]);

	const disposeAtlasTexture = () => {
		if (atlasTextureRef.current) {
			atlasTextureRef.current.native.Destroy();
			atlasTextureRef.current = null;
		}
	};

	const getAtlasTexture = () => {
		const atlasImage = propsRef.current.atlasImage;
		if (!atlasImage) {
			disposeAtlasTexture();
			return null;
		}
		if (atlasTextureRef.current?.path === atlasImage.path) {
			return atlasTextureRef.current;
		}
		disposeAtlasTexture();
		const native = new ImGui_Impl.Texture();
		native.Update(atlasImage.image);
		if (!native._texture) return null;
		atlasTextureRef.current = {
			path: atlasImage.path,
			width: atlasImage.width,
			height: atlasImage.height,
			texture: native._texture,
			native,
		};
		return atlasTextureRef.current;
	};

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
					renderFallback(canvas, current.document, current.diagnostics, [message], current.clipDiagnostics, current.readOnly);
				}
				frame = window.requestAnimationFrame(loop);
			};
			frame = window.requestAnimationFrame(loop);
		}).catch((error) => {
			const message = error instanceof Error ? error.message : "ActionEditor ImGui runtime failed";
			propsRef.current.onRuntimeDiagnostics([message]);
			renderFallback(canvas, propsRef.current.document, propsRef.current.diagnostics, [message], propsRef.current.clipDiagnostics, propsRef.current.readOnly);
		});
		return () => {
			disposed = true;
			if (frame) window.cancelAnimationFrame(frame);
			disposeAtlasTexture();
			runtime.dispose();
			runtimeRef.current = null;
		};
	}, [props.active]);

	useEffect(() => {
		const canvas = canvasRef.current;
		if (!canvas || runtimeRef.current) return;
		renderFallback(canvas, props.document, props.diagnostics, fallbackDiagnostics, props.clipDiagnostics, props.readOnly);
	}, [props, fallbackDiagnostics]);

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
