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
	screenToModel,
	screenDeltaToNodeLocalDelta,
} from "./ActionRender";
import {ActionImGuiRuntime, ActionImGuiFrame} from "./ActionImGuiRuntime";

export type ActionEditorMode = "pose" | "look" | "animation";
export type ActionDocumentChangeOptions = {
	history?: "push" | "replace";
};

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
	clipFiles: string[];
	selectedClipsDir?: string;
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
	gizmoMode: "select" | "move" | "scale" | "rotate";
	fixedSnap: boolean;
	lastDragDelta: {x: number; y: number};
	viewportDragButton: 0 | 1 | null;
	viewportDragAction: "pan" | "edit" | null;
	viewportArea: {x: number; y: number; width: number; height: number};
	imguiCapturesPointer: boolean;
	dragNodeId: string | null;
	dragStartPosition: {x: number; y: number} | null;
	dragHistoryStarted: boolean;
	inputHistoryStarted: Record<string, boolean>;
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
const nodeTreeHeight = 420;
const lookListHeight = 180;
const animationLookListHeight = 120;
const animationListHeight = 180;

const snapValue = (value: number, fixed: boolean, step: number) => fixed ? Math.round(value / step) * step : value;

const withAlpha = (color: number, opacity: number) => {
	const alpha = Math.max(0, Math.min(255, Math.round(Math.max(0, Math.min(1, opacity)) * 255)));
	return ((color & 0x00ffffff) | (alpha << 24)) >>> 0;
};

const boundedChildHeight = (imgui: ActionImGuiFrame, preferred: number, reserve = 0) => Math.max(80, Math.min(preferred, imgui.GetContentRegionAvail().y - reserve));

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
	options?: ActionDocumentChangeOptions,
) => {
	props.onDocumentChange(setActionNode(props.document, nodeId, updater), options);
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
		node.clip === "" ? 0xff252525 : 0xff303030,
		0,
		0,
	);
	if (node.clip === "") {
		drawList.AddRect(
			{x: rowStart.x + 6, y: rowStart.y + 6},
			{x: rowStart.x + previewSize - 6, y: rowStart.y + previewSize - 6},
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
	if (!imgui.IsItemActive()) return {history: "push"};
	const history: ActionDocumentChangeOptions["history"] = panelState.inputHistoryStarted[id] ? "replace" : "push";
	panelState.inputHistoryStarted[id] = true;
	return {history};
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

const renderNodeClipSelector = (
	imgui: ActionImGuiFrame,
	props: ActionEditorCanvasProps,
	selected: ActionNode,
	atlasTexture: ActionAtlasTexture | null,
) => {
	imgui.Text("Clip:");
	imgui.SameLine();
	if (imgui.Button(`${selected.clip || "None"}##node-clip`, {x: 160, y: 0}) && !props.readOnly) {
		imgui.OpenPopup("Select Node Clip", 0);
	}
	const modalFlags = imgui.WindowFlags.NoResize | imgui.WindowFlags.AlwaysAutoResize | imgui.WindowFlags.NoSavedSettings;
	if (imgui.BeginPopupModal("Select Node Clip", null, modalFlags)) {
		try {
			imgui.Text("Select node clip");
			imgui.Separator();
			if (!props.clipDocument || !atlasTexture) {
				imgui.TextDisabled("No clip atlas loaded.");
			}
			const names = props.clipDocument ? Object.keys(props.clipDocument.rects).sort((a, b) => a.localeCompare(b)) : [];
			const items = ["", ...names];
			const previewSize = 64;
			const cellWidth = 86;
			const cellHeight = 92;
			const columns = 4;
			const listHeight = Math.min(390, Math.max(cellHeight, Math.ceil(items.length / columns) * cellHeight));
			imgui.BeginChild("node-clip-list", {x: columns * cellWidth + 18, y: listHeight}, true, 0);
			try {
				if (imgui.BeginTable("node-clip-grid", columns, 0, {x: columns * cellWidth, y: 0}, 0)) {
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
									if (imgui.Button("##clip-cell", {x: previewSize, y: previewSize}) && !props.readOnly) {
										emitNodeChange(props, selected.id, (node) => ({...node, clip: name}));
										imgui.CloseCurrentPopup();
									}
									const drawList = imgui.GetWindowDrawList();
									const frameColor = selectedItem ? selectedNode : 0xff686868;
									drawList.AddRect(
										cellStart,
										{x: cellStart.x + previewSize, y: cellStart.y + previewSize},
										frameColor,
										4,
										0,
										selectedItem ? 3 : 1,
									);
									if (isEmpty) {
										drawList.AddRect(
											{x: cellStart.x + 18, y: cellStart.y + 18},
											{x: cellStart.x + previewSize - 18, y: cellStart.y + previewSize - 18},
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
											{x: imagePos.x + imageWidth, y: imagePos.y + imageHeight},
											{x: rect.x / atlasTexture.width, y: rect.y / atlasTexture.height},
											{x: (rect.x + rect.width) / atlasTexture.width, y: (rect.y + rect.height) / atlasTexture.height},
											0xffffffff,
										);
									}
									const label = isEmpty ? "None" : name;
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
			if (imgui.Button("Cancel", {x: 86, y: 0})) {
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
		const nextName = inputText(imgui, "Name", selected.name, props.readOnly);
		if (nextName !== null) {
			emitNodeChange(props, selected.id, (node) => ({...node, name: nextName}));
		}
		renderNodeClipSelector(imgui, props, selected, atlasTexture);
	}
	const front = [selected.front];
	if (imgui.Checkbox("Face Right / Front", front) && !props.readOnly) {
		emitNodeChange(props, selected.id, (node) => ({...node, front: front[0]}));
	}
	const updateTransform = (updater: (node: ActionNode) => ActionNode, options?: ActionDocumentChangeOptions) => emitNodeChange(props, selected.id, updater, options);
	const x = inputNumber(imgui, "Position X", selected.transform.position.x, props.readOnly, 1, panelState);
	if (x !== null) updateTransform((node) => ({...node, transform: {...node.transform, position: {...node.transform.position, x: x.value}}}), x.options);
	const y = inputNumber(imgui, "Position Y", selected.transform.position.y, props.readOnly, 1, panelState);
	if (y !== null) updateTransform((node) => ({...node, transform: {...node.transform, position: {...node.transform.position, y: y.value}}}), y.options);
	const scaleX = inputNumber(imgui, "Scale X", selected.transform.scale.x, props.readOnly, 0.1, panelState);
	if (scaleX !== null) updateTransform((node) => ({...node, transform: {...node.transform, scale: {...node.transform.scale, x: scaleX.value}}}), scaleX.options);
	const scaleY = inputNumber(imgui, "Scale Y", selected.transform.scale.y, props.readOnly, 0.1, panelState);
	if (scaleY !== null) updateTransform((node) => ({...node, transform: {...node.transform, scale: {...node.transform.scale, y: scaleY.value}}}), scaleY.options);
	const rotation = inputNumber(imgui, "Rotation", selected.transform.rotation, props.readOnly, 1, panelState);
	if (rotation !== null) updateTransform((node) => ({...node, transform: {...node.transform, rotation: rotation.value}}), rotation.options);
	const skewX = inputNumber(imgui, "Skew X", selected.transform.skew.x, props.readOnly, 0.1, panelState);
	if (skewX !== null) updateTransform((node) => ({...node, transform: {...node.transform, skew: {...node.transform.skew, x: skewX.value}}}), skewX.options);
	const skewY = inputNumber(imgui, "Skew Y", selected.transform.skew.y, props.readOnly, 0.1, panelState);
	if (skewY !== null) updateTransform((node) => ({...node, transform: {...node.transform, skew: {...node.transform.skew, y: skewY.value}}}), skewY.options);
	const opacity = inputNumber(imgui, "Opacity", selected.transform.opacity, props.readOnly, 0.05, panelState);
	if (opacity !== null) updateTransform((node) => ({...node, transform: {...node.transform, opacity: Math.max(0, Math.min(1, opacity.value))}}), opacity.options);
	const anchorX = inputNumber(imgui, "Anchor X", selected.transform.anchor.x, props.readOnly, 0.05, panelState);
	if (anchorX !== null) updateTransform((node) => ({...node, transform: {...node.transform, anchor: {...node.transform.anchor, x: anchorX.value}}}), anchorX.options);
	const anchorY = inputNumber(imgui, "Anchor Y", selected.transform.anchor.y, props.readOnly, 0.05, panelState);
	if (anchorY !== null) updateTransform((node) => ({...node, transform: {...node.transform, anchor: {...node.transform.anchor, y: anchorY.value}}}), anchorY.options);
	if (isRoot) {
		const width = inputNumber(imgui, "Model Width", props.document.size.width, props.readOnly, 1, panelState);
		if (width !== null) {
			const next = cloneActionDocument(props.document);
			next.size.width = Math.max(0, Math.round(width.value));
			props.onDocumentChange(next, width.options);
		}
		const height = inputNumber(imgui, "Model Height", props.document.size.height, props.readOnly, 1, panelState);
		if (height !== null) {
			const next = cloneActionDocument(props.document);
			next.size.height = Math.max(0, Math.round(height.value));
			props.onDocumentChange(next, height.options);
		}
	}
};

const renderKeyPoints = (
	imgui: ActionImGuiFrame,
	props: ActionEditorCanvasProps,
	panelState: PanelState,
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
		const x = inputNumber(imgui, `X##kp-x-${index}`, point.x, props.readOnly, 1, panelState);
		if (x !== null) {
			props.onDocumentChange(updateActionKeyPoint(props.document, index, (item) => ({...item, x: x.value})), x.options);
		}
		const y = inputNumber(imgui, `Y##kp-y-${index}`, point.y, props.readOnly, 1, panelState);
		if (y !== null) {
			props.onDocumentChange(updateActionKeyPoint(props.document, index, (item) => ({...item, y: y.value})), y.options);
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
	imgui.BeginChild("look-list", {x: 0, y: boundedChildHeight(imgui, lookListHeight, 150)}, true, 0);
	try {
		for (const look of props.document.looks) {
			if (imgui.Selectable(`${look}##look.${look}`, props.selectedLook === look, 0, {x: 0, y: 22})) {
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
	imgui.BeginChild("animation-look-list", {x: 0, y: boundedChildHeight(imgui, animationLookListHeight, 260)}, true, 0);
	try {
		if (imgui.Selectable("Default##anim-look.default", props.selectedLook === null, 0, {x: 0, y: 22})) {
			props.onLookSelect(null);
		}
		for (const look of props.document.looks) {
			if (imgui.Selectable(`${look}##anim-look.${look}`, props.selectedLook === look, 0, {x: 0, y: 22})) {
				props.onLookSelect(look);
			}
		}
	} finally {
		imgui.EndChild();
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
	imgui.BeginChild("animation-list", {x: 0, y: boundedChildHeight(imgui, animationListHeight, 220)}, true, 0);
	try {
		for (const animation of props.document.animations) {
			if (imgui.Selectable(`${animation}##anim.${animation}`, props.selectedAnimation === animation, 0, {x: 0, y: 22})) {
				props.onAnimationSelect(animation);
				props.onPlaybackTimeChange(0);
			}
		}
	} finally {
		imgui.EndChild();
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
		props.onPlaybackTimeChange(Math.max(0, time.value));
	}
	imgui.Text(`Frame ${Math.round(props.playbackTime * 60)} / ${Math.round(duration * 60)}`);
	const selected = findActionNode(props.document.root, props.selectedNodeId) ?? props.document.root;
	if (selected.id === props.document.root.id) {
		return;
	}
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
	atlasTexture: ActionAtlasTexture | null,
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
		renderProperties(imgui, props, panelState, atlasTexture);
	}
};

const renderViewportTools = (
	imgui: ActionImGuiFrame,
	props: ActionEditorCanvasProps,
	panelState: PanelState,
) => {
	if (props.editMode === "look" && panelState.gizmoMode !== "select") {
		panelState.gizmoMode = "select";
	}
	imgui.Text("Tool");
	const modes = ["select", "move", "scale", "rotate"] as const;
	const visibleModes = modes.filter((mode) => {
		if (mode === "select") return true;
		if (props.editMode === "look") return false;
		return true;
	});
	for (let index = 0; index < visibleModes.length; index += 1) {
		const mode = visibleModes[index];
		if (mode !== "select" && props.editMode === "look") continue;
		if (imgui.Button(`${panelState.gizmoMode === mode ? "*" : ""}${mode}`, {x: 84, y: 0})) {
			panelState.gizmoMode = mode;
		}
		if (index % 2 === 0 && index + 1 < visibleModes.length) {
			imgui.SameLine();
		}
	}
	if (props.editMode !== "look") {
		const fixed = [panelState.fixedSnap];
		if (imgui.Checkbox("Fixed", fixed)) {
			panelState.fixedSnap = fixed[0];
		}
	}
};

const renderClipFileSelector = (
	imgui: ActionImGuiFrame,
	props: ActionEditorCanvasProps,
) => {
	imgui.Text("Clip:");
	imgui.SameLine();
	if (imgui.Button(`${props.document.clipFile || "(none)"}##model-clip`, {x: 160, y: 0}) && !props.readOnly) {
		imgui.OpenPopup("Select Model Clip", 0);
	}
	const modalFlags = imgui.WindowFlags.NoResize | imgui.WindowFlags.AlwaysAutoResize | imgui.WindowFlags.NoSavedSettings;
	if (imgui.BeginPopupModal("Select Model Clip", null, modalFlags)) {
		try {
			imgui.Text("Select .clip file");
			imgui.Separator();
			if (props.clipFiles.length === 0) {
				imgui.TextDisabled("No .clip file found beside the .model file.");
			} else {
				const listHeight = Math.min(320, Math.max(40, props.clipFiles.length * 26));
				imgui.BeginChild("model-clip-list", {x: 280, y: listHeight}, true, 0);
				try {
					for (const clipFile of props.clipFiles) {
						if (imgui.Selectable(`${clipFile}##model-clip.${clipFile}`, props.document.clipFile === clipFile, 0, {x: 0, y: 24})) {
							props.onClipFileSelect(clipFile);
							imgui.CloseCurrentPopup();
						}
					}
				} finally {
					imgui.EndChild();
				}
			}
			imgui.Separator();
			if (imgui.Button("Cancel", {x: 86, y: 0})) {
				imgui.CloseCurrentPopup();
			}
		} finally {
			imgui.EndPopup();
		}
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
	drawList.PushClipRect(
		{x: area.x, y: area.y},
		{x: area.x + area.width, y: area.y + area.height},
		true,
	);
	try {
		drawGrid(drawList, area, props.viewport);
		for (const rect of rects) {
			if (!rect.visible) continue;
			const corners = renderRectCornersToViewport(rect, props.viewport, area);
			const color = withAlpha(rect.missingClip ? missingNode : normalNode, rect.opacity);
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
				rect.nodeId === props.selectedNodeId ? selectedNode : withAlpha(0xff202020, Math.max(0.25, rect.opacity)),
				rect.nodeId === props.selectedNodeId ? 3 : 1,
			);
		}
	} finally {
		drawList.PopClipRect();
	}
};

const canSelectRenderRect = (props: ActionEditorCanvasProps, rect: ActionRenderRect) => rect.nodeId !== props.document.root.id
	&& rect.clip !== ""
	&& !rect.missingClip;

const handleViewportInput = (
	props: ActionEditorCanvasProps,
	panelState: PanelState,
	rects: ActionRenderRect[],
	pointer: {x: number; y: number},
) => {
	const point = screenToModel(pointer, props.viewport, panelState.viewportArea);
	const nodeId = hitTestActionRenderRects(
		rects,
		point,
		(rect) => canSelectRenderRect(props, rect),
	);
	if (nodeId) props.onSelectionChange(nodeId);
	panelState.lastDragDelta = {x: 0, y: 0};
	panelState.viewportDragButton = 0;
	panelState.viewportDragAction = panelState.gizmoMode === "select"
		? "pan"
		: "edit";
	const dragNodeId = panelState.gizmoMode === "select" ? null : (nodeId ?? props.selectedNodeId);
	const dragNode = dragNodeId ? findActionNode(props.document.root, dragNodeId) : null;
	panelState.dragNodeId = dragNodeId;
	panelState.dragStartPosition = dragNode ? {...dragNode.transform.position} : null;
};

const dragViewportInput = (
	props: ActionEditorCanvasProps,
	panelState: PanelState,
	rects: ActionRenderRect[],
	delta: {x: number; y: number},
) => {
	if (panelState.viewportDragAction === "pan" && panelState.viewportDragButton !== null) {
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
	if (!props.readOnly && props.editMode !== "look" && panelState.viewportDragAction === "edit" && panelState.viewportDragButton === 0) {
		const diff = {
			x: (delta.x - panelState.lastDragDelta.x) / props.viewport.zoom,
			y: -(delta.y - panelState.lastDragDelta.y) / props.viewport.zoom,
		};
		if (diff.x !== 0 || diff.y !== 0) {
			const historyOptions = getDragHistoryOptions(panelState);
			const targetNodeId = panelState.dragNodeId ?? props.selectedNodeId;
			emitNodeChange(props, targetNodeId, (node) => {
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
					if (panelState.gizmoMode === "move" && panelState.dragStartPosition) {
						const positionDelta = screenDeltaToNodeLocalDelta(props.document, props.clipDocument, node.id, delta, props.viewport);
						return {
							...node,
							transform: {
								...node.transform,
								position: {
									x: snapValue(panelState.dragStartPosition.x + positionDelta.x, panelState.fixedSnap, 1),
									y: snapValue(panelState.dragStartPosition.y + positionDelta.y, panelState.fixedSnap, 1),
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
			}, historyOptions);
			panelState.lastDragDelta = {x: delta.x, y: delta.y};
		}
	}
};

const getDragHistoryOptions = (panelState: PanelState): ActionDocumentChangeOptions => {
	const history: ActionDocumentChangeOptions["history"] = panelState.dragHistoryStarted ? "replace" : "push";
	panelState.dragHistoryStarted = true;
	return {history};
};

const endViewportInput = (panelState: PanelState) => {
	panelState.lastDragDelta = {x: 0, y: 0};
	panelState.viewportDragButton = null;
	panelState.viewportDragAction = null;
	panelState.dragNodeId = null;
	panelState.dragStartPosition = null;
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

const pointInArea = (point: {x: number; y: number}, area: {x: number; y: number; width: number; height: number}) => point.x >= area.x
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
	const mousePos = {x: io.MousePos.x, y: io.MousePos.y};
	const inViewport = pointInArea(mousePos, panelState.viewportArea);
	const uiCaptured = isImGuiPointerCaptured(imgui);
	if (inViewport && !uiCaptured && io.MouseWheel !== 0) {
		const nextZoom = Math.max(0.1, Math.min(8, props.viewport.zoom + io.MouseWheel * 0.1));
		props.onViewportChange({...props.viewport, zoom: nextZoom});
	}
	if (inViewport && !uiCaptured && imgui.IsMouseClicked(0)) {
		handleViewportInput(props, panelState, rects, mousePos);
	}
	if (panelState.viewportDragButton === 0 && imgui.IsMouseDragging(0, 0)) {
		const delta = imgui.GetMouseDragDelta(0, 0);
		dragViewportInput(props, panelState, rects, {
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
		const sidePanelFlags = panelState.viewportDragAction !== null
			? (panelFlags | imgui.WindowFlags.NoInputs | imgui.WindowFlags.NoScrollWithMouse)
			: panelFlags;
		imgui.SetCursorScreenPos({x: windowPos.x, y: panelTop});
		imgui.BeginChild("left-panel", {x: leftPanelWidth, y: panelHeight}, false, sidePanelFlags);
		try {
			renderClipFileSelector(imgui, props);
			imgui.Text(`Nodes: ${countActionNodes(document.root)}`);
			imgui.Separator();
			renderNodeCommands(imgui, props, panelState);
			imgui.Separator();
			imgui.BeginChild("node-tree", {x: 0, y: boundedChildHeight(imgui, nodeTreeHeight, 240)}, true, 0);
			try {
				renderTreeNode(imgui, props, document.root, 0, atlasTexture);
			} finally {
				imgui.EndChild();
			}
			imgui.Separator();
			imgui.Text("Key Points");
			renderKeyPoints(imgui, props, panelState);
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
			if (props.editMode === "look") {
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
			panelState.viewportArea = area;
			drawRenderRects(imgui, area, props, rects, atlasTexture);
			handleViewportFrameInput(imgui, props, panelState, rects);
		} finally {
			imgui.EndChild();
		}
		imgui.SetCursorScreenPos({x: windowPos.x + leftPanelWidth + viewportWidth, y: panelTop});
		imgui.BeginChild("right-panel", {x: rightPanelWidth, y: panelHeight}, false, sidePanelFlags);
		try {
			renderModeTabs(imgui, props, panelState, atlasTexture);
			imgui.Separator();
			renderViewportTools(imgui, props, panelState);
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
		lastDragDelta: {x: 0, y: 0},
		viewportDragButton: null,
		viewportDragAction: null,
		viewportArea: {x: 0, y: 0, width: 1, height: 1},
		imguiCapturesPointer: false,
		dragNodeId: null,
		dragStartPosition: null,
		dragHistoryStarted: false,
		inputHistoryStarted: {},
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

	const eventPoint = (event: {clientX: number; clientY: number}) => {
		const canvas = canvasRef.current;
		if (!canvas) return {x: event.clientX, y: event.clientY};
		const rect = canvas.getBoundingClientRect();
		return {
			x: event.clientX - rect.left,
			y: event.clientY - rect.top,
		};
	};

	const pointInViewport = (point: {x: number; y: number}) => {
		const area = panelStateRef.current.viewportArea;
		return point.x >= area.x
			&& point.x <= area.x + area.width
			&& point.y >= area.y
			&& point.y <= area.y + area.height;
	};

	const buildCurrentRects = () => {
		const current = propsRef.current;
		return buildActionRenderRects(
			current.document,
			current.clipDocument,
			current.selectedLook,
			current.selectedAnimation,
			current.playbackTime,
		);
	};

	const handleContextMenu = (event: MouseEvent) => {
		const point = eventPoint(event);
		if (pointInViewport(point)) {
			event.preventDefault();
			event.stopPropagation();
			endViewportInput(panelStateRef.current);
		}
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

	useEffect(() => {
		const canvas = canvasRef.current;
		if (!canvas || !props.active) return;
		const onContextMenu = (event: MouseEvent) => handleContextMenu(event);
		canvas.addEventListener("contextmenu", onContextMenu, true);
		return () => {
			canvas.removeEventListener("contextmenu", onContextMenu, true);
		};
	}, [props.active]);

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
