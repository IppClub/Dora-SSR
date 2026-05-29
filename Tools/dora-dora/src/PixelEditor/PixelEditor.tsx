/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import { useCallback, useEffect, useMemo, useState } from 'react';
import { AlertColor, Box, Button, ButtonGroup, Slider, Stack, Typography } from '@mui/material';
import BrushIcon from '@mui/icons-material/Brush';
import AutoFixOffIcon from '@mui/icons-material/AutoFixOff';
import ColorizeIcon from '@mui/icons-material/Colorize';
import FormatColorFillIcon from '@mui/icons-material/FormatColorFill';
import FileDownloadIcon from '@mui/icons-material/FileDownload';
import type { PixelDocument, PixelTool } from './PixelDocument';
import { readPixelDocument, writePixelDocument } from './PixelDocument';
import PixelCanvas from './PixelCanvas';
import PixelPalette from './PixelPalette';
import PixelTimeline from './PixelTimeline';
import PixelMotionPanel from './PixelMotionPanel';
import PixelReferencePanel from './PixelReferencePanel';
import PixelGeneratePanel from './PixelGeneratePanel';
import { getPixelMotionTemplate } from './PixelMotionTemplate';
import { exportPixelSprite } from './PixelExport';
import './PixelEditor.css';

interface PixelEditorProps {
	filePath: string;
	resourceBasePath: string;
	sourceContent: string;
	width: number;
	height: number;
	active: boolean;
	readOnly: boolean;
	onChange: (content: string) => void;
	addAlert?: (message: string, severity: AlertColor, raw?: boolean) => void;
}

interface PixelToolInfo {
	name: PixelTool;
	label: string;
	icon: React.ReactNode;
}

const pixelTools: PixelToolInfo[] = [
	{ name: "pencil", label: "Pencil", icon: <BrushIcon fontSize="small" /> },
	{ name: "eraser", label: "Eraser", icon: <AutoFixOffIcon fontSize="small" /> },
	{ name: "fill", label: "Fill", icon: <FormatColorFillIcon fontSize="small" /> },
	{ name: "eyedropper", label: "Pick", icon: <ColorizeIcon fontSize="small" /> },
];

export default function PixelEditor(props: PixelEditorProps) {
	const { filePath, resourceBasePath, sourceContent, width, height, active, readOnly, onChange, addAlert } = props;
	const [document, setDocument] = useState<PixelDocument>(() => readPixelDocument(sourceContent));
	const [tool, setTool] = useState<PixelTool>("pencil");
	const [selectedColorIndex, setSelectedColorIndex] = useState(1);
	const [zoom, setZoom] = useState(12);
	const [exporting, setExporting] = useState(false);
	const [status, setStatus] = useState('Ready');

	useEffect(() => {
		setDocument(readPixelDocument(sourceContent));
	}, [filePath, sourceContent]);

	const applyDocumentChange = useCallback((nextDocument: PixelDocument) => {
		setDocument(nextDocument);
		onChange(writePixelDocument(nextDocument));
	}, [onChange]);

	const activeFrameIndex = Math.max(0, Math.min(document.frames.length - 1, document.selectedFrame));
	const activeFrameName = document.frames[activeFrameIndex]?.name ?? 'Frame 1';
	const motionTemplate = getPixelMotionTemplate(document.motionTemplate);
	const viewportStyle = useMemo(() => ({ width, height }), [height, width]);

	return <Box className="pixel-editor-root" style={viewportStyle} hidden={!active}>
		<Box className="pixel-toolbar">
			<Stack spacing={0.1} sx={{ minWidth: 180 }}>
				<Typography variant="subtitle1" sx={{ fontWeight: 800, color: '#ffd54a', lineHeight: 1.15 }}>Pixel Sprite</Typography>
				<Typography variant="caption" sx={{ color: 'rgba(255,255,255,0.56)' }}>{document.width}×{document.height} · {document.frames.length} frame(s) · {motionTemplate.name}</Typography>
			</Stack>
			<ButtonGroup variant="outlined" size="small" disabled={readOnly}>
				{pixelTools.map((toolInfo) => (
					<Button
						key={toolInfo.name}
						variant={tool === toolInfo.name ? "contained" : "outlined"}
						startIcon={toolInfo.icon}
						onClick={() => setTool(toolInfo.name)}
					>
						{toolInfo.label}
					</Button>
				))}
			</ButtonGroup>
			<Box sx={{ display: 'flex', alignItems: 'center', gap: 1.5, width: 220, marginLeft: 'auto' }}>
				<Typography variant="caption" sx={{ color: 'rgba(255,255,255,0.62)' }}>Zoom</Typography>
				<Slider
					value={zoom}
					min={4}
					max={32}
					step={1}
					onChange={(_event, value) => setZoom(typeof value === "number" ? value : value[0] ?? zoom)}
				/>
			</Box>
			<Button
				variant="contained"
				startIcon={<FileDownloadIcon />}
				disabled={readOnly || exporting}
				onClick={() => {
					setExporting(true);
					setStatus('Exporting sprite sheet...');
					exportPixelSprite(filePath, document).then((result) => {
						setStatus(`Exported ${result.texturePath}`);
						addAlert?.(`Exported ${result.texturePath}`, 'success', true);
					}).catch((error: unknown) => {
						const message = error instanceof Error ? error.message : 'Failed to export pixel sprite';
						setStatus(message);
						addAlert?.(message, 'error', true);
					}).finally(() => {
						setExporting(false);
					});
				}}
			>
				Export PNG
			</Button>
		</Box>
		<Box className="pixel-editor-body">
			<PixelTimeline
				document={document}
				frameIndex={activeFrameIndex}
				readOnly={readOnly}
				onSelectFrame={(nextFrameIndex) => {
					const nextDocument = { ...document, selectedFrame: nextFrameIndex };
					applyDocumentChange(nextDocument);
				}}
				onDocumentChange={applyDocumentChange}
			/>
			<Box className="pixel-stage">
				<PixelCanvas
					document={document}
					frameIndex={activeFrameIndex}
					selectedColorIndex={selectedColorIndex}
					tool={tool}
					zoom={zoom}
					readOnly={readOnly}
					onDocumentChange={applyDocumentChange}
					onPickColor={setSelectedColorIndex}
				/>
			</Box>
			<Stack spacing={1.5} className="pixel-inspector-column">
				<PixelReferencePanel
					document={document}
					filePath={filePath}
					resourceBasePath={resourceBasePath}
					readOnly={readOnly}
					onDocumentChange={applyDocumentChange}
					addAlert={addAlert}
				/>
				<PixelGeneratePanel
					document={document}
					filePath={filePath}
					resourceBasePath={resourceBasePath}
					readOnly={readOnly}
					onDocumentChange={applyDocumentChange}
					onStatusChange={setStatus}
					addAlert={addAlert}
				/>
				<PixelMotionPanel
					document={document}
					readOnly={readOnly}
					onDocumentChange={applyDocumentChange}
				/>
				<PixelPalette
					document={document}
					selectedColorIndex={selectedColorIndex}
					readOnly={readOnly}
					onSelectColor={setSelectedColorIndex}
					onDocumentChange={applyDocumentChange}
				/>
			</Stack>
		</Box>
		<Box className="pixel-status">
			<span>{filePath}</span>
			<span>{activeFrameName} · {tool} · {status}</span>
		</Box>
	</Box>;
}
