/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import { Box, Button, Stack, Typography } from '@mui/material';
import type { PixelDocument } from './PixelDocument';
import { clonePixelDocument, transparentColor } from './PixelDocument';

interface PixelPaletteProps {
	document: PixelDocument;
	selectedColorIndex: number;
	readOnly: boolean;
	onSelectColor: (colorIndex: number) => void;
	onDocumentChange: (document: PixelDocument) => void;
}

const colorToInputValue = (color: string) => {
	if (/^#[0-9a-fA-F]{8}$/.test(color)) return color.slice(0, 7);
	if (/^#[0-9a-fA-F]{6}$/.test(color)) return color;
	return '#000000';
};

export default function PixelPalette(props: PixelPaletteProps) {
	const { document, selectedColorIndex, readOnly, onSelectColor, onDocumentChange } = props;
	const selectedColor = document.palette[selectedColorIndex] ?? transparentColor;
	return <Stack spacing={2} className="pixel-panel">
		<Typography variant="subtitle2" className="pixel-panel-title">Palette</Typography>
		<Box className="pixel-palette-grid">
			{document.palette.map((color, index) => (
				<button
					key={`${color}-${index}`}
					className={index === selectedColorIndex ? 'pixel-swatch pixel-swatch-selected' : 'pixel-swatch'}
					title={index === 0 ? 'Transparent' : color}
					onClick={() => onSelectColor(index)}
				>
					<span style={{ background: color }} />
				</button>
			))}
		</Box>
		<Stack spacing={1}>
			<Typography variant="caption" sx={{ color: 'rgba(255,255,255,0.62)' }}>Selected color</Typography>
			<input
				type="color"
				value={colorToInputValue(selectedColor)}
				disabled={readOnly || selectedColorIndex === 0}
				onChange={(event) => {
					const nextDocument = clonePixelDocument(document);
					nextDocument.palette[selectedColorIndex] = `${event.target.value}ff`;
					onDocumentChange(nextDocument);
				}}
				className="pixel-color-input"
			/>
		</Stack>
		<Button
			variant="outlined"
			disabled={readOnly || document.palette.length >= 64}
			onClick={() => {
				const nextDocument = clonePixelDocument(document);
				nextDocument.palette.push('#ffffffff');
				onDocumentChange(nextDocument);
				onSelectColor(nextDocument.palette.length - 1);
			}}
		>
			Add Color
		</Button>
	</Stack>;
}
