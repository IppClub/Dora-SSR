/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import React, { memo, useCallback, useEffect, useMemo, useRef, useState } from 'react';
import { Box, Button, FormControlLabel, IconButton, Stack, Switch, TextField, Tooltip, Typography } from '@mui/material';
import PlayArrowIcon from '@mui/icons-material/PlayArrow';
import CodeIcon from '@mui/icons-material/Code';
import RestartAltIcon from '@mui/icons-material/RestartAlt';
import AddIcon from '@mui/icons-material/Add';
import DeleteIcon from '@mui/icons-material/Delete';
import ImageIcon from '@mui/icons-material/Image';
import TextFieldsIcon from '@mui/icons-material/TextFields';
import AccountTreeIcon from '@mui/icons-material/AccountTree';
import PhotoCameraIcon from '@mui/icons-material/PhotoCamera';
import VisibilityIcon from '@mui/icons-material/Visibility';
import VisibilityOffIcon from '@mui/icons-material/VisibilityOff';
import type { SceneCodeLanguage } from './sceneCodegen';
import type { DoraSceneNode, DoraSceneNodeType } from './sceneTypes';
import type { SceneEditorController } from './useSceneEditorController';
import { getDefaultScriptPath, inspectorDebounceMs, isImageResource, toNumber } from './sceneEditorUtils';
import { panelSx, sceneEditorColors } from './sceneEditorStyles';

const nodeIcon = (type: DoraSceneNodeType) => {
	switch (type) {
		case 'Sprite': return <ImageIcon fontSize="small"/>;
		case 'Label': return <TextFieldsIcon fontSize="small"/>;
		default: return <AccountTreeIcon fontSize="small"/>;
	}
};

const PanelHeader = ({title, action}: {title: string; action?: React.ReactNode}) => (
	<Box sx={{height: 42, px: 1.5, display: 'flex', alignItems: 'center', justifyContent: 'space-between', borderBottom: `1px solid ${sceneEditorColors.line}`, background: `linear-gradient(180deg, ${sceneEditorColors.panelHeader} 0%, rgba(0,0,0,0.18) 100%)`, backdropFilter: 'blur(14px)'}}>
		<Typography sx={{fontWeight: 800, color: sceneEditorColors.text}}>{title}</Typography>
		{action}
	</Box>
);

const HeaderButton = ({children, icon, primary, disabled, onClick}: {children: React.ReactNode; icon?: React.ReactNode; primary?: boolean; disabled?: boolean; onClick?: () => void}) => (
	<Button
		size="small"
		variant={primary ? 'contained' : 'outlined'}
		disabled={disabled}
		startIcon={icon}
		onClick={onClick}
		sx={{
			textTransform: 'none',
			fontWeight: 700,
			borderRadius: 1.25,
			px: 1.4,
			minWidth: 0,
			color: primary ? '#171717' : sceneEditorColors.text,
			background: primary ? `linear-gradient(180deg, ${sceneEditorColors.primary} 0%, ${sceneEditorColors.primaryDark} 100%)` : 'rgba(255,255,255,0.035)',
			borderColor: primary ? 'rgba(255,210,26,0.70)' : sceneEditorColors.lineStrong,
			boxShadow: primary ? 'inset 0 1px 0 rgba(255,255,255,0.35), 0 10px 24px rgba(0,0,0,0.35)' : 'none',
			'&:hover': {backgroundColor: primary ? sceneEditorColors.primary : 'rgba(255,255,255,0.095)', borderColor: primary ? sceneEditorColors.primary : 'rgba(255,255,255,0.34)'},
		}}
	>
		{children}
	</Button>
);

export const SceneTopBar = memo((props: {
	title: string;
	readOnly: boolean;
	onRun: () => void;
	onGenerateTS: () => void;
	onGenerateLua: () => void;
	onEnginePreview: () => void;
	onClearEnginePreview: () => void;
	onResetView: () => void;
	onReset: () => void;
	enginePreviewActive: boolean;
	enginePreviewLoading: boolean;
}) => {
	const {title, readOnly, onRun, onGenerateTS, onGenerateLua, onEnginePreview, onClearEnginePreview, onResetView, onReset, enginePreviewActive, enginePreviewLoading} = props;
	return (
		<Box sx={{height: 54, px: 1.5, display: 'flex', alignItems: 'center', gap: 1, borderBottom: `1px solid ${sceneEditorColors.line}`, background: 'linear-gradient(180deg, rgba(16,18,20,0.88) 0%, rgba(5,6,7,0.92) 100%)', backdropFilter: 'blur(18px) saturate(130%)', boxShadow: 'inset 0 1px 0 rgba(255,255,255,0.06)'}}>
			<Stack direction="row" spacing={1} alignItems="center" sx={{mr: 1.5, minWidth: 0}}>
				<AccountTreeIcon sx={{color: sceneEditorColors.primaryDark}}/>
				<Typography sx={{fontWeight: 900, color: sceneEditorColors.text, whiteSpace: 'nowrap'}}>Scene Editor</Typography>
				<Typography variant="caption" noWrap sx={{maxWidth: 260, color: sceneEditorColors.muted}}>{title}</Typography>
			</Stack>
			<HeaderButton primary icon={<PlayArrowIcon/>} onClick={onRun}>Run Scene</HeaderButton>
			<HeaderButton icon={<CodeIcon/>} onClick={onGenerateTS}>Generate TS</HeaderButton>
			<HeaderButton icon={<CodeIcon/>} onClick={onGenerateLua}>Generate Lua</HeaderButton>
			<HeaderButton icon={<PhotoCameraIcon/>} disabled={enginePreviewLoading} onClick={onEnginePreview}>{enginePreviewLoading ? 'Rendering…' : 'Engine Preview'}</HeaderButton>
			{enginePreviewActive ? <HeaderButton onClick={onClearEnginePreview}>CSS Preview</HeaderButton> : null}
			<HeaderButton icon={<RestartAltIcon/>} onClick={onResetView}>Reset View</HeaderButton>
			<Box sx={{flex: 1}}/>
			<Typography variant="caption" sx={{color: sceneEditorColors.muted}}>{readOnly ? 'Read only' : 'Saved with normal IDE save'}</Typography>
			<Tooltip title="Create a fresh scene. Confirmation required.">
				<span>
					<Button
						size="small"
						disabled={readOnly}
						onClick={onReset}
						sx={{textTransform: 'none', minWidth: 0, color: sceneEditorColors.muted, opacity: 0.72, '&:hover': {opacity: 1, color: sceneEditorColors.text, backgroundColor: 'rgba(255,255,255,0.055)'}}}
					>
						New Scene…
					</Button>
				</span>
			</Tooltip>
		</Box>
	);
});
SceneTopBar.displayName = 'SceneTopBar';

export const SceneHierarchyPanel = memo((props: {
	nodes: DoraSceneNode[];
	selectedNodeId: string;
	readOnly: boolean;
	onSelectNode: (nodeId: string) => void;
	onAddNode: (type: DoraSceneNodeType) => void;
	onDeleteNode: (nodeId: string) => void;
	onReparentNode: (nodeId: string, parentId: string) => boolean;
}) => {
	const {nodes, selectedNodeId, readOnly, onSelectNode, onAddNode, onDeleteNode, onReparentNode} = props;
	const childCount = useMemo(() => {
		const counts = new Map<string, number>();
		for (const node of nodes) if (node.parentId) counts.set(node.parentId, (counts.get(node.parentId) ?? 0) + 1);
		return counts;
	}, [nodes]);
	const rows = useMemo(() => {
		const byParent = new Map<string | null, DoraSceneNode[]>();
		for (const node of nodes) {
			const siblings = byParent.get(node.parentId) ?? [];
			siblings.push(node);
			byParent.set(node.parentId, siblings);
		}
		const root = nodes.find(node => node.parentId === null) ?? nodes[0];
		const result: Array<{node: DoraSceneNode; depth: number}> = [];
		const visit = (node: DoraSceneNode, depth: number) => {
			result.push({node, depth});
			for (const child of byParent.get(node.id) ?? []) visit(child, depth + 1);
		};
		if (root !== undefined) visit(root, 0);
		return result;
	}, [nodes]);
	const handleDragStart = useCallback((event: React.DragEvent, node: DoraSceneNode) => {
		if (readOnly || node.parentId === null) return;
		event.dataTransfer.effectAllowed = 'move';
		event.dataTransfer.setData('application/x-dora-scene-node', node.id);
	}, [readOnly]);
	const handleDropOnNode = useCallback((event: React.DragEvent, targetNode: DoraSceneNode) => {
		event.preventDefault();
		event.stopPropagation();
		const draggingNodeId = event.dataTransfer.getData('application/x-dora-scene-node');
		if (draggingNodeId.length === 0) return;
		onReparentNode(draggingNodeId, targetNode.id);
	}, [onReparentNode]);
	return (
		<Box sx={{...panelSx, display: 'flex', flexDirection: 'column', minHeight: 0}}>
			<PanelHeader title="Hierarchy" action={<Stack direction="row" spacing={0.5}><Tooltip title="Add Node"><span><IconButton size="small" disabled={readOnly} onClick={() => onAddNode('Node')}><AddIcon fontSize="small"/></IconButton></span></Tooltip><Tooltip title="Add Sprite"><span><IconButton size="small" disabled={readOnly} onClick={() => onAddNode('Sprite')}><ImageIcon fontSize="small"/></IconButton></span></Tooltip><Tooltip title="Add Label"><span><IconButton size="small" disabled={readOnly} onClick={() => onAddNode('Label')}><TextFieldsIcon fontSize="small"/></IconButton></span></Tooltip></Stack>}/>
			<Box sx={{p: 1, overflow: 'auto'}}>
				{rows.map(({node, depth}) => (
					<Box
						key={node.id}
						draggable={!readOnly && node.parentId !== null}
						onDragStart={(event) => handleDragStart(event, node)}
						onDragOver={(event) => {if (!readOnly) event.preventDefault();}}
						onDrop={(event) => handleDropOnNode(event, node)}
						onClick={() => onSelectNode(node.id)}
						sx={{
							height: 38, px: 1, ml: depth * 2, display: 'flex', alignItems: 'center', gap: 1,
							borderRadius: 1, cursor: 'pointer', color: node.visible ? sceneEditorColors.text : sceneEditorColors.muted,
							backgroundColor: node.id === selectedNodeId ? sceneEditorColors.selected : 'transparent',
							border: node.id === selectedNodeId ? `1px solid ${sceneEditorColors.selectedBorder}` : '1px solid transparent',
							'&:hover': {backgroundColor: node.id === selectedNodeId ? sceneEditorColors.selected : 'rgba(255,255,255,0.06)'},
						}}
					>
						{nodeIcon(node.type)}
						<Box sx={{minWidth: 0, flex: 1}}>
							<Typography noWrap sx={{fontSize: 14, fontWeight: node.id === selectedNodeId ? 800 : 500}}>{node.name}</Typography>
							<Typography variant="caption" sx={{display: 'block', mt: -0.4, color: sceneEditorColors.muted}}>{node.type} · {childCount.get(node.id) ?? 0} child</Typography>
						</Box>
						{node.visible ? <VisibilityIcon sx={{fontSize: 15, color: sceneEditorColors.mutedStrong}}/> : <VisibilityOffIcon sx={{fontSize: 15, color: sceneEditorColors.muted}}/>}
						{node.parentId !== null ? <Tooltip title="Delete node"><IconButton size="small" disabled={readOnly} onClick={(event) => {event.stopPropagation(); onDeleteNode(node.id);}}><DeleteIcon sx={{fontSize: 15}}/></IconButton></Tooltip> : null}
					</Box>
				))}
			</Box>
			<Typography variant="caption" sx={{px: 1.5, pb: 1, color: sceneEditorColors.muted}}>Drag a node onto another node to change parent.</Typography>
		</Box>
	);
});
SceneHierarchyPanel.displayName = 'SceneHierarchyPanel';

const RelationshipLine = memo((props: {from: {x: number; y: number}; to: {x: number; y: number}; pan: {x: number; y: number}; zoom: number}) => {
	const {from, to, pan, zoom} = props;
	const dx = (to.x - from.x) * zoom;
	const dy = -(to.y - from.y) * zoom;
	const length = Math.sqrt(dx * dx + dy * dy);
	const angle = Math.atan2(dy, dx) * 180 / Math.PI;
	return <Box sx={{position: 'absolute', left: `calc(50% + ${pan.x + from.x * zoom}px)`, top: `calc(50% + ${pan.y - from.y * zoom}px)`, width: length, height: '1px', background: 'linear-gradient(90deg, rgba(255,255,255,0.08), rgba(255,255,255,0.30), rgba(255,255,255,0.08))', transform: `rotate(${angle}deg)`, transformOrigin: '0 50%', pointerEvents: 'none'}}/>;
});
RelationshipLine.displayName = 'RelationshipLine';

export interface EnginePreviewState {
	url: string;
	width: number;
	height: number;
	message?: string;
}

export const SceneViewportPanel = memo((props: {controller: SceneEditorController; getResourceUrl: (resourcePath: string) => string; enginePreview?: EnginePreviewState; enginePreviewLoading?: boolean; enginePreviewError?: string}) => {
	const {controller, getResourceUrl, enginePreview, enginePreviewLoading, enginePreviewError} = props;
	const hasEnginePreview = enginePreview !== undefined;
	const visibleNodes = useMemo(() => controller.viewportNodes.filter(node => node.id !== controller.scene.rootId && node.visible), [controller.viewportNodes, controller.scene.rootId]);
	const relationshipLines = useMemo(() => visibleNodes.flatMap(node => {
		if (node.parentId === null) return [];
		const parent = controller.viewportNodes.find(item => item.id === node.parentId);
		if (parent === undefined || (!parent.visible && parent.id !== controller.scene.rootId)) return [];
		const from = controller.worldPositions.get(parent.id);
		const to = controller.worldPositions.get(node.id);
		return from !== undefined && to !== undefined ? [{id: `${parent.id}-${node.id}`, from, to}] : [];
	}), [controller.scene.rootId, controller.viewportNodes, controller.worldPositions, visibleNodes]);
	return (
		<Box sx={{...panelSx, position: 'relative', minHeight: 0}}>
			<Box
				ref={controller.viewportRef}
				onPointerDown={controller.beginPan}
				onPointerMove={(event) => {controller.moveDrag(event); controller.movePan(event);}}
				onPointerUp={() => {controller.endDrag(); controller.endPan();}}
				onPointerCancel={() => {controller.endDrag(); controller.endPan();}}
				onWheel={controller.handleViewportWheel}
				onDragOver={controller.handleTextureDragOver}
				onDrop={(event) => controller.handleTextureDrop(event)}
				sx={{
					position: 'absolute', inset: 0, overflow: 'hidden', backgroundColor: '#050607',
					backgroundImage: `radial-gradient(circle at 50% 50%, rgba(255,255,255,0.055), transparent 58%), linear-gradient(${sceneEditorColors.grid} 1px, transparent 1px), linear-gradient(90deg, ${sceneEditorColors.grid} 1px, transparent 1px)`,
					backgroundSize: `100% 100%, ${Math.max(8, 32 * controller.zoom)}px ${Math.max(8, 32 * controller.zoom)}px, ${Math.max(8, 32 * controller.zoom)}px ${Math.max(8, 32 * controller.zoom)}px`,
					backgroundPosition: `center center, ${controller.pan.x}px ${controller.pan.y}px, ${controller.pan.x}px ${controller.pan.y}px`,
				}}
			>
				<Box sx={{position: 'absolute', left: `calc(50% + ${controller.pan.x}px)`, top: 0, bottom: 0, width: '1px', backgroundColor: sceneEditorColors.yAxis}}/>
				<Box sx={{position: 'absolute', left: 0, right: 0, top: `calc(50% + ${controller.pan.y}px)`, height: '1px', backgroundColor: sceneEditorColors.xAxis}}/>
				{enginePreview !== undefined ? <Box component="img" src={enginePreview.url} alt="Dora engine preview" draggable={false} sx={{position: 'absolute', left: `calc(50% + ${controller.pan.x}px)`, top: `calc(50% + ${controller.pan.y}px)`, width: `${enginePreview.width * controller.zoom}px`, height: `${enginePreview.height * controller.zoom}px`, transform: 'translate(-50%, -50%)', objectFit: 'contain', pointerEvents: 'none', boxShadow: '0 18px 60px rgba(0,0,0,0.45)', border: `1px solid ${sceneEditorColors.lineStrong}`}}/> : null}
				{relationshipLines.map(line => <Box key={line.id} sx={{opacity: hasEnginePreview ? 0.28 : 1}}><RelationshipLine from={line.from} to={line.to} pan={controller.pan} zoom={controller.zoom}/></Box>)}
				<Box sx={{position: 'absolute', left: 16, top: 14, px: 1, py: 0.4, borderRadius: 1, backgroundColor: 'rgba(0,0,0,0.28)', color: enginePreviewError ? '#ff8f8f' : sceneEditorColors.muted}}><Typography variant="caption">{enginePreviewLoading ? 'Rendering with Dora engine…' : enginePreviewError ? `Engine Preview failed: ${enginePreviewError}` : hasEnginePreview ? 'Engine Preview active. CSS nodes are dimmed.' : 'Drop png/jpg here. Drag blank area to pan. Ctrl/Pinch to zoom.'}</Typography></Box>
				{visibleNodes.map(node => {
					const worldTransform = controller.worldTransforms.get(node.id) ?? {x: node.x, y: node.y, scaleX: node.scaleX, scaleY: node.scaleY, rotation: node.rotation};
					const hasSpriteTexture = node.type === 'Sprite' && node.texture !== undefined && isImageResource(node.texture);
					return <Box
						key={node.id}
						onPointerDown={(event) => controller.beginDrag(event, node)}
						onDragOver={node.type === 'Sprite' ? controller.handleTextureDragOver : undefined}
						onDrop={node.type === 'Sprite' ? (event) => controller.handleTextureDrop(event, node) : undefined}
						sx={{
							position: 'absolute', left: `calc(50% + ${controller.pan.x + worldTransform.x * controller.zoom}px)`, top: `calc(50% + ${controller.pan.y - worldTransform.y * controller.zoom}px)`,
							transform: `translate(-50%, -50%) rotate(${worldTransform.rotation}deg) scale(${worldTransform.scaleX * controller.zoom}, ${worldTransform.scaleY * controller.zoom})`, transformOrigin: 'center',
							minWidth: hasSpriteTexture ? 0 : (node.type === 'Label' ? 72 : 78), minHeight: hasSpriteTexture ? 0 : (node.type === 'Label' ? 32 : 78), px: node.type === 'Label' ? 1 : 0,
							display: 'flex', alignItems: 'center', justifyContent: 'center', userSelect: 'none', cursor: 'grab',
							opacity: hasEnginePreview ? 0.22 : 1,
							border: node.id === controller.selectedNodeId ? `2px solid ${sceneEditorColors.selectedBorder}` : `1px solid ${sceneEditorColors.lineStrong}`,
							boxShadow: node.id === controller.selectedNodeId ? '0 0 0 4px rgba(255,255,255,0.10), 0 16px 38px rgba(0,0,0,0.45)' : '0 10px 28px rgba(0,0,0,0.30)',
							background: hasSpriteTexture ? 'transparent' : (node.type === 'Sprite' ? 'linear-gradient(180deg, rgba(255,255,255,0.085), rgba(255,255,255,0.035))' : 'linear-gradient(180deg, rgba(28,30,33,0.86), rgba(10,11,12,0.86))'), backdropFilter: hasSpriteTexture ? 'none' : 'blur(10px)', borderRadius: 1,
						}}
					>
						{hasSpriteTexture ? <Box component="img" src={getResourceUrl(node.texture ?? '')} alt={node.name} draggable={false} sx={{display: 'block', width: 'auto', height: 'auto', maxWidth: 'none', maxHeight: 'none', objectFit: 'contain', imageRendering: 'auto', pointerEvents: 'none'}}/> : <Typography sx={{pointerEvents: 'none', color: sceneEditorColors.text, fontSize: node.type === 'Label' ? (node.fontSize ?? 32) : 13, lineHeight: 1, textShadow: '0 2px 4px #000'}}>{node.type === 'Label' ? (node.text ?? node.name) : node.name}</Typography>}
						{node.id === controller.selectedNodeId ? <Typography sx={{position: 'absolute', left: '50%', top: '100%', mt: 0.7, transform: 'translateX(-50%)', px: 0.8, py: 0.15, borderRadius: 0.7, backgroundColor: 'rgba(20,22,24,0.78)', backdropFilter: 'blur(10px)', border: `1px solid ${sceneEditorColors.lineStrong}`, color: sceneEditorColors.text, fontSize: 12}}>{node.name}</Typography> : null}
					</Box>;
				})}
			</Box>
		</Box>
	);
});
SceneViewportPanel.displayName = 'SceneViewportPanel';

interface InspectorDraft {name: string; x: string; y: string; scaleX: string; scaleY: string; rotation: string; texture: string; text: string; fontSize: string; script: string;}
const createDraft = (node: DoraSceneNode): InspectorDraft => ({name: node.name, x: String(node.x), y: String(node.y), scaleX: String(node.scaleX), scaleY: String(node.scaleY), rotation: String(node.rotation), texture: node.texture ?? '', text: node.text ?? '', fontSize: String(node.fontSize ?? 32), script: node.script ?? ''});

export const SceneInspectorPanel = memo((props: {controller: SceneEditorController; readOnly: boolean; getResourceUrl: (resourcePath: string) => string; onCreateScript: (scriptPath: string, language: SceneCodeLanguage) => void}) => {
	const {controller, readOnly, getResourceUrl, onCreateScript} = props;
	const selectedNode = controller.selectedNode;
	const [draft, setDraft] = useState<InspectorDraft>(() => selectedNode ? createDraft(selectedNode) : createDraft({id: '', parentId: null, type: 'Node', name: '', x: 0, y: 0, scaleX: 1, scaleY: 1, rotation: 0, visible: true}));
	const pendingRef = useRef<Partial<DoraSceneNode>>({});
	const timerRef = useRef<ReturnType<typeof setTimeout> | null>(null);
	const clearTimer = useCallback(() => {if (timerRef.current !== null) clearTimeout(timerRef.current); timerRef.current = null;}, []);
	const flush = useCallback(() => {clearTimer(); const update = pendingRef.current; pendingRef.current = {}; if (Object.keys(update).length > 0) controller.updateSelectedNode(update);}, [clearTimer, controller]);
	useEffect(() => {clearTimer(); pendingRef.current = {}; if (selectedNode) setDraft(createDraft(selectedNode)); return clearTimer;}, [clearTimer, selectedNode]);
	const updateDraft = useCallback(<Key extends keyof InspectorDraft>(key: Key, value: InspectorDraft[Key], update: Partial<DoraSceneNode>) => {setDraft(current => ({...current, [key]: value})); pendingRef.current = {...pendingRef.current, ...update}; clearTimer(); timerRef.current = setTimeout(flush, inspectorDebounceMs);}, [clearTimer, flush]);
	const createScript = useCallback((language: SceneCodeLanguage) => {if (!selectedNode || readOnly) return; const scriptPath = draft.script.trim().length > 0 ? draft.script.trim() : getDefaultScriptPath(selectedNode, language); setDraft(current => ({...current, script: scriptPath})); flush(); controller.updateSelectedNode({script: scriptPath}); onCreateScript(scriptPath, language);}, [controller, draft.script, flush, onCreateScript, readOnly, selectedNode]);
	return (
		<Box sx={{...panelSx, display: 'flex', flexDirection: 'column', minHeight: 0}}>
			<PanelHeader title="Inspector" action={<Tooltip title="Delete selected node"><span><IconButton size="small" disabled={readOnly || selectedNode === undefined || selectedNode.id === controller.scene.rootId} onClick={controller.deleteSelectedNode}><DeleteIcon fontSize="small"/></IconButton></span></Tooltip>}/>
			{selectedNode === undefined ? <Typography sx={{p: 2, color: sceneEditorColors.muted}}>No node selected.</Typography> : <Box sx={{p: 1.5, overflow: 'auto'}}>
				<Stack spacing={1.5}>
					<Box sx={{p: 1.25, borderRadius: 1, backgroundColor: sceneEditorColors.card, border: `1px solid ${sceneEditorColors.line}`}}><Stack direction="row" spacing={1} alignItems="center"><Box sx={{width: 36, height: 36, borderRadius: 1, display: 'flex', alignItems: 'center', justifyContent: 'center', backgroundColor: 'rgba(255,255,255,0.04)'}}>{nodeIcon(selectedNode.type)}</Box><Box><Typography sx={{fontWeight: 800}}>{selectedNode.name}</Typography><Typography variant="caption" sx={{color: sceneEditorColors.muted}}>{selectedNode.type}</Typography></Box></Stack></Box>
					<TextField size="small" label="Name" value={draft.name} disabled={readOnly} fullWidth onBlur={flush} onChange={(event) => updateDraft('name', event.target.value, {name: event.target.value})}/>
					<Stack direction="row" spacing={1}><TextField size="small" label="X" value={draft.x} disabled={readOnly} type="number" onBlur={flush} onChange={(event) => updateDraft('x', event.target.value, {x: toNumber(event.target.value, selectedNode.x)})}/><TextField size="small" label="Y" value={draft.y} disabled={readOnly} type="number" onBlur={flush} onChange={(event) => updateDraft('y', event.target.value, {y: toNumber(event.target.value, selectedNode.y)})}/></Stack>
					<Stack direction="row" spacing={1}><TextField size="small" label="Scale X" value={draft.scaleX} disabled={readOnly} type="number" onBlur={flush} onChange={(event) => updateDraft('scaleX', event.target.value, {scaleX: toNumber(event.target.value, selectedNode.scaleX)})}/><TextField size="small" label="Scale Y" value={draft.scaleY} disabled={readOnly} type="number" onBlur={flush} onChange={(event) => updateDraft('scaleY', event.target.value, {scaleY: toNumber(event.target.value, selectedNode.scaleY)})}/></Stack>
					<TextField size="small" label="Rotation" value={draft.rotation} disabled={readOnly} type="number" fullWidth onBlur={flush} onChange={(event) => updateDraft('rotation', event.target.value, {rotation: toNumber(event.target.value, selectedNode.rotation)})}/>
					<FormControlLabel control={<Switch size="small" checked={selectedNode.visible} disabled={readOnly} onChange={(event) => controller.updateSelectedNode({visible: event.target.checked})}/>} label={<Typography sx={{color: sceneEditorColors.text}}>Visible</Typography>}/>
					{selectedNode.type === 'Sprite' ? <Box sx={{p: 1.25, borderRadius: 1, backgroundColor: sceneEditorColors.card, border: `1px solid ${sceneEditorColors.line}`}} onDragOver={controller.handleTextureDragOver} onDrop={(event) => controller.handleTextureDrop(event, selectedNode)}><Typography sx={{mb: 1, fontWeight: 800, color: sceneEditorColors.mutedStrong}}>Sprite</Typography><TextField size="small" label="Texture" value={draft.texture} disabled={readOnly} fullWidth onBlur={flush} onChange={(event) => updateDraft('texture', event.target.value, {texture: event.target.value})}/>{draft.texture && isImageResource(draft.texture) ? <Box component="img" src={getResourceUrl(draft.texture)} alt={selectedNode.name} draggable={false} sx={{display: 'block', mt: 1, maxWidth: '100%', maxHeight: 120, objectFit: 'contain', borderRadius: 1, backgroundColor: 'rgba(0,0,0,0.22)'}}/> : <Typography variant="caption" sx={{display: 'block', mt: 1, color: sceneEditorColors.muted}}>Drop a png/jpg here.</Typography>}</Box> : null}
					{selectedNode.type === 'Label' ? <Box sx={{p: 1.25, borderRadius: 1, backgroundColor: sceneEditorColors.card, border: `1px solid ${sceneEditorColors.line}`}}><Typography sx={{mb: 1, fontWeight: 800, color: sceneEditorColors.mutedStrong}}>Label</Typography><TextField size="small" label="Text" value={draft.text} disabled={readOnly} fullWidth onBlur={flush} onChange={(event) => updateDraft('text', event.target.value, {text: event.target.value})}/><TextField size="small" label="Font size" value={draft.fontSize} disabled={readOnly} type="number" fullWidth sx={{mt: 1}} onBlur={flush} onChange={(event) => updateDraft('fontSize', event.target.value, {fontSize: toNumber(event.target.value, selectedNode.fontSize ?? 32)})}/></Box> : null}
					<Box sx={{p: 1.25, borderRadius: 1, backgroundColor: sceneEditorColors.card, border: `1px solid ${sceneEditorColors.line}`}}><Typography sx={{mb: 1, fontWeight: 800, color: sceneEditorColors.mutedStrong}}>Script</Typography><TextField size="small" label="Script path" value={draft.script} disabled={readOnly} fullWidth placeholder={getDefaultScriptPath(selectedNode, 'typescript')} onBlur={flush} onChange={(event) => updateDraft('script', event.target.value, {script: event.target.value})}/><Stack direction="row" spacing={1} sx={{mt: 1}}><Button size="small" variant="outlined" disabled={readOnly} onClick={() => createScript('typescript')}>Create TS</Button><Button size="small" variant="outlined" disabled={readOnly} onClick={() => createScript('lua')}>Create Lua</Button></Stack></Box>
				</Stack>
			</Box>}
		</Box>
	);
});
SceneInspectorPanel.displayName = 'SceneInspectorPanel';
