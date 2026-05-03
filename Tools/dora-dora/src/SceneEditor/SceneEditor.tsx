/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import React, { useCallback, useEffect, useRef, useState } from 'react';
import { Box } from '@mui/material';
import * as Service from '../Service';
import type { SceneCodeLanguage } from './sceneCodegen';
import { SceneHierarchyPanel, SceneInspectorPanel, SceneTopBar, SceneViewportPanel } from './SceneEditorPanels';
import type { EnginePreviewState } from './SceneEditorPanels';
import { sceneEditorColors, sceneEditorLayout } from './sceneEditorStyles';
import { useSceneEditorController } from './useSceneEditorController';

export interface SceneEditorProps {
	content: string;
	title: string;
	height: number;
	readOnly?: boolean;
	resolveResourcePath: (filePath: string) => string;
	getResourceUrl: (resourcePath: string) => string;
	onChange: (content: string) => void;
	onGenerateCode: (language: SceneCodeLanguage, code: string, options?: {run?: boolean}) => void;
	onCreateScript: (scriptPath: string, language: SceneCodeLanguage) => void;
	onKeydown?: (event: React.KeyboardEvent) => void;
}

const clamp = (value: number, min: number, max: number) => Math.max(min, Math.min(max, value));

type ResizeSide = 'left' | 'right';

const isTextEditingTarget = (target: EventTarget | null) => {
	if (!(target instanceof HTMLElement)) return false;
	if (target.isContentEditable) return true;
	const tagName = target.tagName.toLowerCase();
	return tagName === 'input' || tagName === 'textarea' || tagName === 'select';
};

const SceneEditor = (props: SceneEditorProps) => {
	const {content, title, height, readOnly = false, resolveResourcePath, getResourceUrl, onChange, onGenerateCode, onCreateScript, onKeydown} = props;
	const controller = useSceneEditorController({content, title, readOnly, resolveResourcePath, onChange, onGenerateCode});
	const [panelWidths, setPanelWidths] = useState({left: sceneEditorLayout.leftWidth, right: sceneEditorLayout.rightWidth});
	const [enginePreview, setEnginePreview] = useState<EnginePreviewState | undefined>(undefined);
	const [enginePreviewLoading, setEnginePreviewLoading] = useState(false);
	const [enginePreviewError, setEnginePreviewError] = useState<string | undefined>(undefined);
	const resizeRef = useRef<null | {side: ResizeSide; startX: number; left: number; right: number}>(null);
	const beginResize = useCallback((side: ResizeSide, event: React.PointerEvent) => {
		event.preventDefault();
		resizeRef.current = {side, startX: event.clientX, left: panelWidths.left, right: panelWidths.right};
		document.body.style.cursor = 'col-resize';
		document.body.style.userSelect = 'none';
	}, [panelWidths]);
	useEffect(() => {
		const move = (event: PointerEvent) => {
			const resizing = resizeRef.current;
			if (resizing === null) return;
			const delta = event.clientX - resizing.startX;
			setPanelWidths({
				left: resizing.side === 'left' ? clamp(resizing.left + delta, 140, 620) : resizing.left,
				right: resizing.side === 'right' ? clamp(resizing.right - delta, 220, 680) : resizing.right,
			});
		};
		const up = () => {
			resizeRef.current = null;
			document.body.style.cursor = '';
			document.body.style.userSelect = '';
		};
		window.addEventListener('pointermove', move);
		window.addEventListener('pointerup', up);
		return () => {
			window.removeEventListener('pointermove', move);
			window.removeEventListener('pointerup', up);
			document.body.style.cursor = '';
			document.body.style.userSelect = '';
		};
	}, []);
	useEffect(() => {
		const handleSceneShortcut = (event: KeyboardEvent) => {
			if (isTextEditingTarget(event.target)) return;
			const usesCommandKey = event.metaKey || event.ctrlKey;
			const key = event.key.toLowerCase();
			if (usesCommandKey && !event.altKey) {
				switch (key) {
					case 'z':
						event.preventDefault();
						if (event.shiftKey) controller.redoSceneChange();
						else controller.undoSceneChange();
						break;
					case 'y':
						event.preventDefault();
						controller.redoSceneChange();
						break;
					case '=':
					case '+':
						event.preventDefault();
						controller.zoomIn();
						break;
					case '-':
					case '_':
						event.preventDefault();
						controller.zoomOut();
						break;
					case '0':
						event.preventDefault();
						controller.resetView();
						break;
				}
				return;
			}
			if (!event.altKey && !event.shiftKey && (event.key === 'Delete' || event.key === 'Backspace')) {
				event.preventDefault();
				controller.deleteSelectedNode();
			}
		};
		window.addEventListener('keydown', handleSceneShortcut);
		return () => window.removeEventListener('keydown', handleSceneShortcut);
	}, [controller]);
	const renderEnginePreview = useCallback(() => {
		const viewport = controller.viewportRef.current;
		const width = clamp(Math.round(viewport?.clientWidth ?? 960), 64, 2048);
		const height = clamp(Math.round(viewport?.clientHeight ?? 540), 64, 2048);
		setEnginePreviewLoading(true);
		setEnginePreviewError(undefined);
		void Service.renderScene({
			scene: controller.scene,
			width,
			height,
			background: 0,
		}).then((result) => {
			if (result.success) {
				setEnginePreview({
					url: `${Service.addr(result.url)}?v=${Date.now()}`,
					width: result.width,
					height: result.height,
				});
			} else {
				setEnginePreviewError(result.message ?? 'failed to render scene');
			}
		}).catch((error: unknown) => {
			setEnginePreviewError(error instanceof Error ? error.message : String(error));
		}).finally(() => {
			setEnginePreviewLoading(false);
		});
	}, [controller.scene, controller.viewportRef]);
	const clearEnginePreview = useCallback(() => {
		setEnginePreview(undefined);
		setEnginePreviewError(undefined);
	}, []);
	const divider = (side: ResizeSide) => <Box title="Drag to resize panels" onPointerDown={(event) => beginResize(side, event)} sx={{cursor: 'col-resize', borderRadius: 1, background: 'linear-gradient(180deg, rgba(255,255,255,0.05), rgba(255,255,255,0.015))', border: `1px solid ${sceneEditorColors.line}`, '&:hover': {background: 'rgba(255,210,26,0.16)', borderColor: 'rgba(255,210,26,0.42)'}}}/>;
	return (
		<Box
			onKeyDown={onKeydown}
			sx={{
				height,
				width: '100%',
				minWidth: 0,
				display: 'grid',
				gridTemplateRows: `${sceneEditorLayout.topBarHeight}px minmax(0, 1fr)`,
				backgroundColor: sceneEditorColors.background,
				color: sceneEditorColors.text,
				overflow: 'hidden',
				'& .MuiInputBase-root': {color: sceneEditorColors.text, backgroundColor: 'rgba(255,255,255,0.035)'},
				'& .MuiInputLabel-root': {color: sceneEditorColors.muted},
				'& .MuiOutlinedInput-notchedOutline': {borderColor: sceneEditorColors.lineStrong},
				'& .MuiButton-outlined': {borderColor: sceneEditorColors.lineStrong, color: sceneEditorColors.text},
			}}
		>
			<SceneTopBar title={title} readOnly={readOnly} onRun={() => void controller.generateCode('lua', true)} onGenerateTS={() => void controller.generateCode('typescript')} onGenerateLua={() => void controller.generateCode('lua')} onEnginePreview={renderEnginePreview} onClearEnginePreview={clearEnginePreview} enginePreviewActive={enginePreview !== undefined} enginePreviewLoading={enginePreviewLoading} onResetView={controller.resetView} onReset={controller.resetScene}/>
			<Box sx={{display: 'grid', gridTemplateColumns: `${panelWidths.left}px 8px minmax(160px, 1fr) 8px ${panelWidths.right}px`, gap: 0.75, p: 1, minHeight: 0}}>
				<SceneHierarchyPanel nodes={controller.scene.nodes} selectedNodeId={controller.selectedNodeId} readOnly={readOnly} onSelectNode={controller.setSelectedNodeId} onAddNode={controller.addNode} onDeleteNode={controller.deleteNode} onReparentNode={controller.reparentNode}/>
				{divider('left')}
				<SceneViewportPanel controller={controller} getResourceUrl={getResourceUrl} enginePreview={enginePreview} enginePreviewLoading={enginePreviewLoading} enginePreviewError={enginePreviewError}/>
				{divider('right')}
				<SceneInspectorPanel controller={controller} readOnly={readOnly} getResourceUrl={getResourceUrl} onCreateScript={onCreateScript}/>
			</Box>
		</Box>
	);
};

export default SceneEditor;
