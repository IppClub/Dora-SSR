/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import { Box, Chip, FormControl, InputLabel, MenuItem, Select, Stack, Typography } from '@mui/material';
import type { SelectChangeEvent } from '@mui/material/Select';
import type { PixelDocument } from './PixelDocument';
import { clonePixelDocument } from './PixelDocument';
import { defaultPixelMotionTemplateId, getPixelMotionTemplate, isPixelMotionTemplateId, pixelMotionTemplates } from './PixelMotionTemplate';

interface PixelMotionPanelProps {
	document: PixelDocument;
	readOnly: boolean;
	onDocumentChange: (document: PixelDocument) => void;
}

export default function PixelMotionPanel(props: PixelMotionPanelProps) {
	const { document, readOnly, onDocumentChange } = props;
	const selectedTemplateId = isPixelMotionTemplateId(document.motionTemplate) ? document.motionTemplate : defaultPixelMotionTemplateId;
	const selectedTemplate = getPixelMotionTemplate(selectedTemplateId);
	const handleTemplateChange = (event: SelectChangeEvent<string>) => {
		const templateId = event.target.value;
		if (!isPixelMotionTemplateId(templateId)) return;
		const nextDocument = clonePixelDocument(document);
		nextDocument.motionTemplate = templateId;
		onDocumentChange(nextDocument);
	};

	return <Stack spacing={1.25} className="pixel-panel pixel-motion-panel">
		<Typography variant="subtitle2" className="pixel-panel-title">Motion Template</Typography>
		<FormControl size="small" fullWidth disabled={readOnly}>
			<InputLabel id="pixel-motion-template-label">Template</InputLabel>
			<Select
				labelId="pixel-motion-template-label"
				label="Template"
				value={selectedTemplateId}
				onChange={handleTemplateChange}
			>
				{pixelMotionTemplates.map((template) => (
					<MenuItem key={template.id} value={template.id}>{template.name}</MenuItem>
				))}
			</Select>
		</FormControl>
		<Stack direction="row" flexWrap="wrap" gap={0.75} useFlexGap>
			<Chip size="small" label={`${selectedTemplate.frameCount} frames`} />
			<Chip size="small" label={`${selectedTemplate.fps} fps`} />
			<Chip size="small" label={selectedTemplate.direction} />
			<Chip size="small" label={selectedTemplate.category} />
		</Stack>
		<Typography variant="caption" sx={{ color: 'rgba(255,255,255,0.62)', lineHeight: 1.45 }}>
			{selectedTemplate.description}
		</Typography>
		<Box className="pixel-motion-frame-list">
			{selectedTemplate.frames.map((frame, index) => (
				<Box key={frame.name} className="pixel-motion-frame-card">
					<Stack direction="row" justifyContent="space-between" alignItems="center" gap={1}>
						<Typography variant="caption" className="pixel-motion-frame-name">
							{index + 1}. {frame.name}
						</Typography>
						<Typography variant="caption" className="pixel-motion-frame-anchor">
							anchor {frame.footAnchorX},{frame.footAnchorY}
						</Typography>
					</Stack>
					<Typography variant="caption" sx={{ color: 'rgba(255,255,255,0.58)', lineHeight: 1.35 }}>
						{frame.prompt}
					</Typography>
					<Typography variant="caption" sx={{ color: 'rgba(255,213,74,0.58)', lineHeight: 1.35 }}>
						body offset {frame.bodyOffsetX},{frame.bodyOffsetY}
					</Typography>
				</Box>
			))}
		</Box>
	</Stack>;
}
