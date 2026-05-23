/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import { Box, Button, IconButton, Stack, TextField, Typography } from '@mui/material';
import AddIcon from '@mui/icons-material/Add';
import ContentCopyIcon from '@mui/icons-material/ContentCopy';
import DeleteIcon from '@mui/icons-material/Delete';
import type { PixelDocument, PixelFrame } from './PixelDocument';
import { clonePixelDocument, createPixelFrame } from './PixelDocument';

interface PixelTimelineProps {
	document: PixelDocument;
	frameIndex: number;
	readOnly: boolean;
	onSelectFrame: (frameIndex: number) => void;
	onDocumentChange: (document: PixelDocument) => void;
}

const cloneFrame = (frame: PixelFrame, index: number): PixelFrame => ({
	id: `frame-${Date.now().toString(36)}-${Math.random().toString(36).slice(2, 8)}`,
	name: `${frame.name} Copy ${index + 1}`,
	pixels: [...frame.pixels],
});

export default function PixelTimeline(props: PixelTimelineProps) {
	const { document, frameIndex, readOnly, onSelectFrame, onDocumentChange } = props;
	return <Stack spacing={1.5} className="pixel-panel pixel-timeline">
		<Stack direction="row" justifyContent="space-between" alignItems="center">
			<Typography variant="subtitle2" className="pixel-panel-title">Frames</Typography>
			<Stack direction="row" spacing={0.5}>
				<IconButton size="small" disabled={readOnly} onClick={() => {
					const nextDocument = clonePixelDocument(document);
					nextDocument.frames.push(createPixelFrame(`Frame ${nextDocument.frames.length + 1}`, nextDocument.width, nextDocument.height));
					nextDocument.selectedFrame = nextDocument.frames.length - 1;
					onDocumentChange(nextDocument);
				}}>
					<AddIcon fontSize="small" />
				</IconButton>
				<IconButton size="small" disabled={readOnly || document.frames.length === 0} onClick={() => {
					const activeFrame = document.frames[frameIndex];
					if (activeFrame === undefined) return;
					const nextDocument = clonePixelDocument(document);
					nextDocument.frames.splice(frameIndex + 1, 0, cloneFrame(activeFrame, frameIndex));
					nextDocument.selectedFrame = frameIndex + 1;
					onDocumentChange(nextDocument);
				}}>
					<ContentCopyIcon fontSize="small" />
				</IconButton>
			</Stack>
		</Stack>
		<Box className="pixel-frame-list">
			{document.frames.map((frame, index) => (
				<button
					key={frame.id}
					className={index === frameIndex ? 'pixel-frame-button pixel-frame-selected' : 'pixel-frame-button'}
					onClick={() => onSelectFrame(index)}
				>
					<span>{index + 1}</span>
					<strong>{frame.name}</strong>
				</button>
			))}
		</Box>
		<TextField
			size="small"
			label="FPS"
			type="number"
			value={document.fps}
			disabled={readOnly}
			onChange={(event) => {
				const nextDocument = clonePixelDocument(document);
				const fps = Number.parseInt(event.target.value, 10);
				nextDocument.fps = Number.isFinite(fps) ? Math.max(1, Math.min(60, fps)) : document.fps;
				onDocumentChange(nextDocument);
			}}
		/>
		<Button
			variant="outlined"
			color="error"
			startIcon={<DeleteIcon />}
			disabled={readOnly || document.frames.length <= 1}
			onClick={() => {
				const nextDocument = clonePixelDocument(document);
				nextDocument.frames.splice(frameIndex, 1);
				nextDocument.selectedFrame = Math.max(0, Math.min(nextDocument.frames.length - 1, frameIndex));
				onDocumentChange(nextDocument);
			}}
		>
			Delete Frame
		</Button>
	</Stack>;
}
