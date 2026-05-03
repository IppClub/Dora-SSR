/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import type React from 'react';
import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import { createDefaultScene, createSceneNode, parseSceneContent, stringifySceneContent } from './sceneDefaults';
import type { SceneCodeLanguage } from './sceneCodegen';
import type { DoraScene, DoraSceneNode, DoraSceneNodeType } from './sceneTypes';
import { getDroppedFilePath, getSceneNameFromTitle, isImageResource } from './sceneEditorUtils';

interface DragState {
	id: string;
	startX: number;
	startY: number;
	worldX: number;
	worldY: number;
}

interface PanDragState {
	startX: number;
	startY: number;
	panX: number;
	panY: number;
}

interface DragPosition {
	x: number;
	y: number;
}

interface WorldTransform {
	x: number;
	y: number;
	scaleX: number;
	scaleY: number;
	rotation: number;
}

const identityWorldTransform: WorldTransform = {x: 0, y: 0, scaleX: 1, scaleY: 1, rotation: 0};

const computeWorldTransforms = (nodes: DoraSceneNode[]) => {
	const byId = new Map(nodes.map(node => [node.id, node]));
	const transforms = new Map<string, WorldTransform>();
	const visiting = new Set<string>();
	const visit = (node: DoraSceneNode): WorldTransform => {
		const cached = transforms.get(node.id);
		if (cached !== undefined) return cached;
		if (visiting.has(node.id)) return identityWorldTransform;
		visiting.add(node.id);
		const parent = node.parentId !== null ? byId.get(node.parentId) : undefined;
		const parentTransform = parent !== undefined && parent.id !== node.id ? visit(parent) : identityWorldTransform;
		const radians = parentTransform.rotation * Math.PI / 180;
		const cos = Math.cos(radians);
		const sin = Math.sin(radians);
		const scaledLocalX = node.x * parentTransform.scaleX;
		const scaledLocalY = node.y * parentTransform.scaleY;
		const transform = {
			x: parentTransform.x + scaledLocalX * cos - scaledLocalY * sin,
			y: parentTransform.y + scaledLocalX * sin + scaledLocalY * cos,
			scaleX: parentTransform.scaleX * node.scaleX,
			scaleY: parentTransform.scaleY * node.scaleY,
			rotation: parentTransform.rotation + node.rotation,
		};
		visiting.delete(node.id);
		transforms.set(node.id, transform);
		return transform;
	};
	for (const node of nodes) visit(node);
	return transforms;
};

const computeWorldPositions = (nodes: DoraSceneNode[]) => {
	const transforms = computeWorldTransforms(nodes);
	const positions = new Map<string, DragPosition>();
	for (const [id, transform] of transforms) {
		positions.set(id, {x: transform.x, y: transform.y});
	}
	return positions;
};

const toLocalPosition = (worldPosition: DragPosition, parentTransform?: WorldTransform) => {
	if (parentTransform === undefined) return worldPosition;
	const radians = parentTransform.rotation * Math.PI / 180;
	const cos = Math.cos(radians);
	const sin = Math.sin(radians);
	const dx = worldPosition.x - parentTransform.x;
	const dy = worldPosition.y - parentTransform.y;
	const scaledLocalX = dx * cos + dy * sin;
	const scaledLocalY = -dx * sin + dy * cos;
	return {
		x: Math.round(scaledLocalX / (Math.abs(parentTransform.scaleX) < 0.0001 ? 1 : parentTransform.scaleX)),
		y: Math.round(scaledLocalY / (Math.abs(parentTransform.scaleY) < 0.0001 ? 1 : parentTransform.scaleY)),
	};
};

const isDescendantNode = (nodes: DoraSceneNode[], nodeId: string, possibleDescendantId: string) => {
	let current = nodes.find(node => node.id === possibleDescendantId);
	while (current !== undefined && current.parentId !== null) {
		if (current.parentId === nodeId) return true;
		current = nodes.find(node => node.id === current?.parentId);
	}
	return false;
};

const minZoom = 0.25;
const maxZoom = 4;
const clampZoom = (value: number) => Math.max(minZoom, Math.min(maxZoom, value));
const maxHistorySteps = 80;

const scenesEqual = (left: DoraScene, right: DoraScene) =>
	stringifySceneContent(left) === stringifySceneContent(right);

export interface UseSceneEditorControllerOptions {
	content: string;
	title: string;
	readOnly: boolean;
	resolveResourcePath: (filePath: string) => string;
	onChange: (content: string) => void;
	onGenerateCode: (language: SceneCodeLanguage, code: string, options?: {run?: boolean}) => void;
}

export const useSceneEditorController = (options: UseSceneEditorControllerOptions) => {
	const { content, title, readOnly, resolveResourcePath, onChange, onGenerateCode } = options;
	const fallbackName = useMemo(() => getSceneNameFromTitle(title), [title]);
	const [scene, setScene] = useState<DoraScene>(() => parseSceneContent(content, fallbackName));
	const [viewportNodes, setViewportNodes] = useState<DoraSceneNode[]>(() => scene.nodes);
	const [selectedNodeId, setSelectedNodeId] = useState(scene.rootId);
	const [pan, setPanState] = useState<DragPosition>({x: 0, y: 0});
	const [zoom, setZoomState] = useState(1);
	const viewportRef = useRef<HTMLDivElement | null>(null);
	const sceneRef = useRef(scene);
	const viewportNodesRef = useRef(viewportNodes);
	const worldPositionsRef = useRef(computeWorldPositions(viewportNodes));
	const worldTransformsRef = useRef(computeWorldTransforms(viewportNodes));
	const selectedNodeIdRef = useRef(selectedNodeId);
	const panRef = useRef(pan);
	const zoomRef = useRef(zoom);
	const dragStateRef = useRef<DragState | null>(null);
	const panDragStateRef = useRef<PanDragState | null>(null);
	const pendingDragPositionRef = useRef<DragPosition | null>(null);
	const dragFrameRef = useRef<number | null>(null);
	const lastCommittedContent = useRef(content);
	const undoStackRef = useRef<DoraScene[]>([]);
	const redoStackRef = useRef<DoraScene[]>([]);

	const setViewportNodesAndRef = useCallback((nodes: DoraSceneNode[]) => {
		viewportNodesRef.current = nodes;
		worldPositionsRef.current = computeWorldPositions(nodes);
		worldTransformsRef.current = computeWorldTransforms(nodes);
		setViewportNodes(nodes);
	}, []);

	const setPan = useCallback((nextPan: DragPosition) => {
		panRef.current = nextPan;
		setPanState(nextPan);
	}, []);

	const setZoom = useCallback((nextZoom: number) => {
		const clampedZoom = clampZoom(nextZoom);
		zoomRef.current = clampedZoom;
		setZoomState(clampedZoom);
	}, []);

	const worldPositions = useMemo(() => computeWorldPositions(viewportNodes), [viewportNodes]);
	const worldTransforms = useMemo(() => computeWorldTransforms(viewportNodes), [viewportNodes]);

	useEffect(() => {
		sceneRef.current = scene;
	}, [scene]);

	useEffect(() => {
		selectedNodeIdRef.current = selectedNodeId;
	}, [selectedNodeId]);

	useEffect(() => {
		worldPositionsRef.current = worldPositions;
	}, [worldPositions]);

	useEffect(() => {
		worldTransformsRef.current = worldTransforms;
	}, [worldTransforms]);

	useEffect(() => {
		panRef.current = pan;
	}, [pan]);

	useEffect(() => {
		zoomRef.current = zoom;
	}, [zoom]);

	useEffect(() => {
		if (content === lastCommittedContent.current) return;
		const nextScene = parseSceneContent(content, fallbackName);
		sceneRef.current = nextScene;
		setScene(nextScene);
		setViewportNodesAndRef(nextScene.nodes);
		setSelectedNodeId(nextScene.nodes.some(node => node.id === selectedNodeIdRef.current) ? selectedNodeIdRef.current : nextScene.rootId);
		lastCommittedContent.current = content;
		undoStackRef.current = [];
		redoStackRef.current = [];
	}, [content, fallbackName, setViewportNodesAndRef]);

	useEffect(() => () => {
		if (dragFrameRef.current !== null) {
			cancelAnimationFrame(dragFrameRef.current);
			dragFrameRef.current = null;
		}
	}, []);

	const commitScene = useCallback((nextScene: DoraScene, options?: {recordHistory?: boolean}) => {
		const currentScene = sceneRef.current;
		if (scenesEqual(currentScene, nextScene)) return;
		if (options?.recordHistory !== false) {
			undoStackRef.current = [...undoStackRef.current.slice(-(maxHistorySteps - 1)), currentScene];
			redoStackRef.current = [];
		}
		sceneRef.current = nextScene;
		setScene(nextScene);
		setViewportNodesAndRef(nextScene.nodes);
		const nextContent = stringifySceneContent(nextScene);
		lastCommittedContent.current = nextContent;
		onChange(nextContent);
	}, [onChange, setViewportNodesAndRef]);

	const applyDragPositionToViewport = useCallback((position: DragPosition) => {
		const dragState = dragStateRef.current;
		if (dragState === null) return;
		const nodes = viewportNodesRef.current;
		const movingNode = nodes.find(node => node.id === dragState.id);
		if (movingNode === undefined) return;
		const localPosition = toLocalPosition(position, movingNode.parentId !== null ? worldTransformsRef.current.get(movingNode.parentId) : undefined);
		const nextNodes = nodes.map(node => node.id === dragState.id ? {...node, x: localPosition.x, y: localPosition.y} : node);
		setViewportNodesAndRef(nextNodes);
	}, [setViewportNodesAndRef]);

	const flushDragFrame = useCallback(() => {
		dragFrameRef.current = null;
		const position = pendingDragPositionRef.current;
		if (position === null) return;
		pendingDragPositionRef.current = null;
		applyDragPositionToViewport(position);
	}, [applyDragPositionToViewport]);

	const selectedNode = scene.nodes.find(node => node.id === selectedNodeId) ?? scene.nodes.find(node => node.id === scene.rootId) ?? scene.nodes[0];

	const updateSelectedNode = useCallback((update: Partial<DoraSceneNode>) => {
		if (readOnly) return;
		const nodeId = selectedNodeIdRef.current;
		const currentScene = sceneRef.current;
		if (!currentScene.nodes.some(node => node.id === nodeId)) return;
		const nextNodes = currentScene.nodes.map(node => node.id === nodeId ? {...node, ...update} : node);
		commitScene({...currentScene, nodes: nextNodes});
	}, [commitScene, readOnly]);

	const addNode = useCallback((type: DoraSceneNodeType) => {
		if (readOnly) return;
		const currentScene = sceneRef.current;
		const parentId = selectedNodeIdRef.current ?? currentScene.rootId;
		const node = createSceneNode(type, currentScene.nodes.length, parentId);
		node.x = type === 'Label' ? 0 : 80;
		node.y = type === 'Label' ? 100 : 0;
		commitScene({...currentScene, nodes: [...currentScene.nodes, node]});
		setSelectedNodeId(node.id);
	}, [commitScene, readOnly]);

	const deleteNode = useCallback((nodeId: string) => {
		if (readOnly) return;
		const currentScene = sceneRef.current;
		if (nodeId === currentScene.rootId) return;
		const selected = currentScene.nodes.find(node => node.id === nodeId);
		if (selected === undefined) return;
		const removing = new Set<string>([selected.id]);
		let changed = true;
		while (changed) {
			changed = false;
			for (const node of currentScene.nodes) {
				if (node.parentId !== null && removing.has(node.parentId) && !removing.has(node.id)) {
					removing.add(node.id);
					changed = true;
				}
			}
		}
		commitScene({...currentScene, nodes: currentScene.nodes.filter(node => !removing.has(node.id))});
		setSelectedNodeId(currentScene.rootId);
	}, [commitScene, readOnly]);

	const deleteSelectedNode = useCallback(() => {
		deleteNode(selectedNodeIdRef.current);
	}, [deleteNode]);

	const reparentNode = useCallback((nodeId: string, parentId: string) => {
		if (readOnly || nodeId === parentId) return false;
		const currentScene = sceneRef.current;
		if (nodeId === currentScene.rootId) return false;
		const node = currentScene.nodes.find(item => item.id === nodeId);
		const parent = currentScene.nodes.find(item => item.id === parentId);
		if (node === undefined || parent === undefined || isDescendantNode(currentScene.nodes, nodeId, parentId)) return false;
		const nodeWorld = worldPositionsRef.current.get(nodeId) ?? {x: node.x, y: node.y};
		const localPosition = toLocalPosition(nodeWorld, worldTransformsRef.current.get(parentId));
		const nextNodes = currentScene.nodes.map(item => item.id === nodeId ? {...item, parentId, x: localPosition.x, y: localPosition.y} : item);
		commitScene({...currentScene, nodes: nextNodes});
		setSelectedNodeId(nodeId);
		return true;
	}, [commitScene, readOnly]);

	const beginDrag = useCallback((event: React.PointerEvent, node: DoraSceneNode) => {
		event.stopPropagation();
		setSelectedNodeId(node.id);
		if (readOnly || node.id === sceneRef.current.rootId) return;
		event.currentTarget.setPointerCapture(event.pointerId);
		const worldPosition = worldPositionsRef.current.get(node.id) ?? {x: node.x, y: node.y};
		dragStateRef.current = {
			id: node.id,
			startX: event.clientX,
			startY: event.clientY,
			worldX: worldPosition.x,
			worldY: worldPosition.y,
		};
		pendingDragPositionRef.current = null;
	}, [readOnly]);

	const moveDrag = useCallback((event: React.PointerEvent) => {
		const dragState = dragStateRef.current;
		if (dragState === null || readOnly) return;
		const currentZoom = zoomRef.current;
		pendingDragPositionRef.current = {
			x: Math.round(dragState.worldX + (event.clientX - dragState.startX) / currentZoom),
			y: Math.round(dragState.worldY - (event.clientY - dragState.startY) / currentZoom),
		};
		if (dragFrameRef.current === null) {
			dragFrameRef.current = requestAnimationFrame(flushDragFrame);
		}
	}, [flushDragFrame, readOnly]);

	const endDrag = useCallback(() => {
		if (dragStateRef.current === null) return;
		if (dragFrameRef.current !== null) {
			cancelAnimationFrame(dragFrameRef.current);
			dragFrameRef.current = null;
		}
		const pendingPosition = pendingDragPositionRef.current;
		pendingDragPositionRef.current = null;
		if (pendingPosition !== null) {
			applyDragPositionToViewport(pendingPosition);
		}
		dragStateRef.current = null;
		commitScene({...sceneRef.current, nodes: viewportNodesRef.current});
	}, [applyDragPositionToViewport, commitScene]);

	const beginPan = useCallback((event: React.PointerEvent) => {
		if (event.button !== 0) return;
		event.currentTarget.setPointerCapture(event.pointerId);
		panDragStateRef.current = {
			startX: event.clientX,
			startY: event.clientY,
			panX: panRef.current.x,
			panY: panRef.current.y,
		};
	}, []);

	const movePan = useCallback((event: React.PointerEvent) => {
		const panDragState = panDragStateRef.current;
		if (panDragState === null) return;
		setPan({
			x: Math.round(panDragState.panX + event.clientX - panDragState.startX),
			y: Math.round(panDragState.panY + event.clientY - panDragState.startY),
		});
	}, [setPan]);

	const endPan = useCallback(() => {
		panDragStateRef.current = null;
	}, []);

	const screenToWorld = useCallback((event: React.DragEvent | React.PointerEvent): DragPosition => {
		const rect = viewportRef.current?.getBoundingClientRect();
		if (rect === undefined) return {x: 0, y: 0};
		const currentZoom = zoomRef.current;
		return {
			x: Math.round((event.clientX - rect.left - rect.width / 2 - panRef.current.x) / currentZoom),
			y: Math.round((rect.height / 2 + panRef.current.y - (event.clientY - rect.top)) / currentZoom),
		};
	}, []);

	const handleViewportWheel = useCallback((event: React.WheelEvent) => {
		if (!event.ctrlKey) return;
		event.preventDefault();
		event.stopPropagation();
		const rect = viewportRef.current?.getBoundingClientRect();
		if (rect === undefined) return;
		const oldZoom = zoomRef.current;
		const nextZoom = clampZoom(oldZoom * Math.exp(-event.deltaY * 0.0015));
		if (Math.abs(nextZoom - oldZoom) < 0.001) return;
		const screenX = event.clientX - rect.left - rect.width / 2;
		const screenY = event.clientY - rect.top - rect.height / 2;
		const worldX = (screenX - panRef.current.x) / oldZoom;
		const worldY = (panRef.current.y - screenY) / oldZoom;
		setPan({
			x: Math.round(screenX - worldX * nextZoom),
			y: Math.round(screenY + worldY * nextZoom),
		});
		setZoom(nextZoom);
	}, [setPan, setZoom]);

	const resetView = useCallback(() => {
		setPan({x: 0, y: 0});
		setZoom(1);
	}, [setPan, setZoom]);

	const zoomIn = useCallback(() => {
		setZoom(zoomRef.current * 1.15);
	}, [setZoom]);

	const zoomOut = useCallback(() => {
		setZoom(zoomRef.current / 1.15);
	}, [setZoom]);

	const resetScene = useCallback(() => {
		if (readOnly) return;
		if (!window.confirm("Reset the whole scene? This will remove the current nodes.")) return;
		const nextScene = createDefaultScene(fallbackName);
		commitScene(nextScene);
		setSelectedNodeId(nextScene.rootId);
	}, [commitScene, fallbackName, readOnly]);

	const restoreScene = useCallback((nextScene: DoraScene) => {
		sceneRef.current = nextScene;
		setScene(nextScene);
		setViewportNodesAndRef(nextScene.nodes);
		const nextContent = stringifySceneContent(nextScene);
		lastCommittedContent.current = nextContent;
		onChange(nextContent);
		const selectedId = selectedNodeIdRef.current;
		setSelectedNodeId(nextScene.nodes.some(node => node.id === selectedId) ? selectedId : nextScene.rootId);
	}, [onChange, setViewportNodesAndRef]);

	const undoSceneChange = useCallback(() => {
		if (readOnly) return;
		const previousScene = undoStackRef.current.pop();
		if (previousScene === undefined) return;
		redoStackRef.current = [...redoStackRef.current.slice(-(maxHistorySteps - 1)), sceneRef.current];
		restoreScene(previousScene);
	}, [readOnly, restoreScene]);

	const redoSceneChange = useCallback(() => {
		if (readOnly) return;
		const nextScene = redoStackRef.current.pop();
		if (nextScene === undefined) return;
		undoStackRef.current = [...undoStackRef.current.slice(-(maxHistorySteps - 1)), sceneRef.current];
		restoreScene(nextScene);
	}, [readOnly, restoreScene]);

	const generateCode = useCallback(async (language: SceneCodeLanguage, run?: boolean) => {
		const { generateSceneLua, generateSceneTypeScript } = await import('./sceneCodegen');
		const code = language === 'lua' ? generateSceneLua(sceneRef.current) : generateSceneTypeScript(sceneRef.current);
		onGenerateCode(language, code, run ? {run: true} : undefined);
	}, [onGenerateCode]);

	const bindTextureToNode = useCallback((targetNode: DoraSceneNode, resourcePath: string) => {
		if (readOnly || !isImageResource(resourcePath)) return false;
		const currentScene = sceneRef.current;
		const currentTarget = currentScene.nodes.find(node => node.id === targetNode.id);
		if (currentTarget === undefined || currentTarget.type !== 'Sprite') return false;
		const nextNodes = currentScene.nodes.map(node => node.id === currentTarget.id ? {...node, texture: resourcePath} : node);
		commitScene({...currentScene, nodes: nextNodes});
		setSelectedNodeId(currentTarget.id);
		return true;
	}, [commitScene, readOnly]);

	const addSpriteFromDrop = useCallback((event: React.DragEvent, resourcePath: string) => {
		if (readOnly || !isImageResource(resourcePath)) return;
		const currentScene = sceneRef.current;
		const node = createSceneNode('Sprite', currentScene.nodes.length, currentScene.rootId);
		const worldPosition = screenToWorld(event);
		node.x = worldPosition.x;
		node.y = worldPosition.y;
		node.texture = resourcePath;
		node.name = resourcePath.split(/[\\/]/).pop()?.replace(/\.[^.]+$/, '') || node.name;
		commitScene({...currentScene, nodes: [...currentScene.nodes, node]});
		setSelectedNodeId(node.id);
	}, [commitScene, readOnly, screenToWorld]);

	const handleTextureDrop = useCallback((event: React.DragEvent, targetNode?: DoraSceneNode) => {
		event.preventDefault();
		event.stopPropagation();
		if (readOnly) return;
		const filePath = getDroppedFilePath(event);
		if (filePath.length === 0) return;
		const resourcePath = resolveResourcePath(filePath);
		if (!isImageResource(resourcePath)) return;
		if (targetNode !== undefined) {
			bindTextureToNode(targetNode, resourcePath);
			return;
		}
		const selected = sceneRef.current.nodes.find(node => node.id === selectedNodeIdRef.current);
		if (selected !== undefined && bindTextureToNode(selected, resourcePath)) return;
		addSpriteFromDrop(event, resourcePath);
	}, [addSpriteFromDrop, bindTextureToNode, readOnly, resolveResourcePath]);

	const handleTextureDragOver = useCallback((event: React.DragEvent) => {
		event.preventDefault();
		event.dataTransfer.dropEffect = readOnly ? 'none' : 'copy';
	}, [readOnly]);

	return {
		scene,
		viewportNodes,
		worldPositions,
		worldTransforms,
		selectedNode,
		selectedNodeId,
		pan,
		zoom,
		viewportRef,
		setSelectedNodeId,
		updateSelectedNode,
		addNode,
		deleteNode,
		deleteSelectedNode,
		reparentNode,
		beginDrag,
		moveDrag,
		endDrag,
		beginPan,
		movePan,
		endPan,
		handleViewportWheel,
		resetView,
		zoomIn,
		zoomOut,
		resetScene,
		undoSceneChange,
		redoSceneChange,
		generateCode,
		handleTextureDrop,
		handleTextureDragOver,
	};
};

export type SceneEditorController = ReturnType<typeof useSceneEditorController>;
