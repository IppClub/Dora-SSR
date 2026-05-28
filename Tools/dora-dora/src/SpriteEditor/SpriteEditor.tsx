/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import { Box, Button, Chip, Slider, Stack, Typography } from '@mui/material';
import type { AlertColor } from '@mui/material';
import ImageIcon from '@mui/icons-material/Image';
import Info from '../Info';
import * as Service from '../Service';
import type { ImageSpriteAction, ImageSpriteDocument, ImageSpriteFrame } from './SpriteDocument';
import { cloneImageSpriteDocument, readImageSpriteDocument, writeImageSpriteDocument } from './SpriteDocument';
import SpriteReferencePanel from './SpriteReferencePanel';
import SpriteGeneratePanel from './SpriteGeneratePanel';
import './SpriteEditor.css';

interface SpriteEditorProps {
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

interface FramePreviewProps {
	imageUrl?: string;
	frame?: ImageSpriteFrame;
	zoom: number;
}

const { path } = Info;

const toWebPath = (filePath: string) => filePath.split("\\").join("/");

const getProjectImageUrl = (resourceBasePath: string, filePath: string, imageName: string | undefined, previewRevision: number) => {
	if (imageName === undefined || resourceBasePath === "") return undefined;
	const imagePath = path.join(path.dirname(filePath), imageName);
	return Service.addr(`/${toWebPath(path.relative(resourceBasePath, imagePath))}?t=${previewRevision}`);
};

const FramePreview = (props: FramePreviewProps) => {
	const { imageUrl, frame, zoom } = props;
	const canvasRef = useRef<HTMLCanvasElement | null>(null);
	useEffect(() => {
		const canvas = canvasRef.current;
		if (canvas === null || imageUrl === undefined || frame === undefined) return;
		let cancelled = false;
		const image = new Image();
		image.onload = () => {
			if (cancelled) return;
			canvas.width = Math.max(1, Math.round(frame.rect.width * zoom));
			canvas.height = Math.max(1, Math.round(frame.rect.height * zoom));
			const context = canvas.getContext("2d");
			if (context === null) return;
			context.imageSmoothingEnabled = false;
			context.clearRect(0, 0, canvas.width, canvas.height);
			context.drawImage(
				image,
				frame.rect.x,
				frame.rect.y,
				frame.rect.width,
				frame.rect.height,
				0,
				0,
				canvas.width,
				canvas.height,
			);
		};
		image.src = imageUrl;
		return () => {
			cancelled = true;
		};
	}, [frame, imageUrl, zoom]);
	if (imageUrl === undefined || frame === undefined) {
		return <Box className="image-sprite-empty-preview"><Typography variant="caption">Generate a sprite sheet to preview frames.</Typography></Box>;
	}
	return <canvas ref={canvasRef} />;
};

const getSafeAction = (document: ImageSpriteDocument): ImageSpriteAction | undefined => {
	return document.actions[document.selectedAction] ?? document.actions[0];
};

export default function SpriteEditor(props: SpriteEditorProps) {
	const { filePath, resourceBasePath, sourceContent, width, height, active, readOnly, onChange, addAlert } = props;
	const [document, setDocument] = useState<ImageSpriteDocument>(() => readImageSpriteDocument(sourceContent));
	const [status, setStatus] = useState("Ready");
	const [zoom, setZoom] = useState(3);
	const [previewRevision, setPreviewRevision] = useState(0);

	useEffect(() => {
		setDocument(readImageSpriteDocument(sourceContent));
		setPreviewRevision((revision) => revision + 1);
	}, [filePath, sourceContent]);

	const applyDocumentChange = useCallback((nextDocument: ImageSpriteDocument) => {
		setDocument(nextDocument);
		onChange(writeImageSpriteDocument(nextDocument));
		setPreviewRevision((revision) => revision + 1);
	}, [onChange]);

	const action = getSafeAction(document);
	const frameIndex = action === undefined ? 0 : Math.max(0, Math.min(action.frames.length - 1, document.selectedFrame));
	const frame = action?.frames[frameIndex];
	const imageUrl = useMemo(() => {
		return getProjectImageUrl(resourceBasePath, filePath, action?.image, previewRevision);
	}, [action?.image, filePath, previewRevision, resourceBasePath]);
	const viewportStyle = useMemo(() => ({ width, height }), [height, width]);

	return <Box className="image-sprite-editor-root" style={viewportStyle} hidden={!active}>
		<Box className="image-sprite-toolbar">
			<Stack spacing={0.1} sx={{ minWidth: 220 }}>
				<Typography variant="subtitle1" sx={{ fontWeight: 800, color: '#ffd54a', lineHeight: 1.15 }}>Image Sprite</Typography>
				<Typography variant="caption" sx={{ color: 'rgba(255,255,255,0.56)' }}>
					{action?.name ?? "No Action"} · {action?.direction ?? "front"} · {action?.frames.length ?? 0} frame(s) · {action?.fps ?? 0} fps
				</Typography>
			</Stack>
			<Chip size="small" icon={<ImageIcon fontSize="small" />} label={action?.image ?? "no generated sheet"} />
			<Box sx={{ display: 'flex', alignItems: 'center', gap: 1.5, width: 220, marginLeft: 'auto' }}>
				<Typography variant="caption" sx={{ color: 'rgba(255,255,255,0.62)' }}>Preview</Typography>
				<Slider value={zoom} min={1} max={6} step={0.5} onChange={(_event, value) => setZoom(typeof value === "number" ? value : value[0] ?? zoom)} />
			</Box>
		</Box>
		<Box className="image-sprite-body">
			<Box className="image-sprite-sidebar">
				<Stack spacing={1.25}>
					<Typography variant="subtitle2" className="image-sprite-panel-title">Frames</Typography>
					<Box className="image-sprite-frame-list">
						{action?.frames.map((item, index) => (
							<Button
								key={item.id}
								className="image-sprite-frame-item"
								variant={index === frameIndex ? "contained" : "outlined"}
								disabled={readOnly}
								onClick={() => {
									const nextDocument = cloneImageSpriteDocument(document);
									nextDocument.selectedFrame = index;
									applyDocumentChange(nextDocument);
								}}
							>
								{index + 1}. {item.name}
							</Button>
						))}
					</Box>
				</Stack>
			</Box>
			<Box className="image-sprite-stage">
				<Box className="image-sprite-frame-preview">
					<FramePreview imageUrl={imageUrl} frame={frame} zoom={zoom} />
				</Box>
				<Box className="image-sprite-sheet-preview">
					{imageUrl === undefined ? <Typography variant="caption" sx={{ color: 'rgba(255,255,255,0.48)' }}>No sprite sheet generated yet.</Typography> : <img src={imageUrl} alt="Generated sprite sheet" />}
				</Box>
			</Box>
			<Stack spacing={1.5} className="image-sprite-inspector">
				<SpriteReferencePanel
					document={document}
					filePath={filePath}
					resourceBasePath={resourceBasePath}
					readOnly={readOnly}
					onDocumentChange={applyDocumentChange}
					addAlert={addAlert}
				/>
				<SpriteGeneratePanel
					document={document}
					filePath={filePath}
					resourceBasePath={resourceBasePath}
					readOnly={readOnly}
					onDocumentChange={applyDocumentChange}
					onStatusChange={setStatus}
					addAlert={addAlert}
				/>
				<Box className="image-sprite-panel">
					<Typography variant="subtitle2" className="image-sprite-panel-title">Runtime Data</Typography>
					<Typography variant="caption" sx={{ color: 'rgba(255,255,255,0.62)', lineHeight: 1.6, display: 'block', mt: 1 }}>
						Image: {action?.image ?? "none"}<br />
						Direction: {action?.direction ?? "front"}<br />
						Sheet: {action?.imageWidth ?? 0}×{action?.imageHeight ?? 0}<br />
						Frame: {frame === undefined ? "none" : `${frame.rect.x},${frame.rect.y},${frame.rect.width},${frame.rect.height}`}
					</Typography>
				</Box>
			</Stack>
		</Box>
		<Box className="image-sprite-status">
			<span>{filePath}</span>
			<span>{frame?.name ?? "No frame"} · {status}</span>
		</Box>
	</Box>;
}
