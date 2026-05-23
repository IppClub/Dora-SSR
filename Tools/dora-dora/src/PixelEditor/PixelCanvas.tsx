/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import { useCallback, useEffect, useRef, useState } from 'react';
import type { PixelDocument, PixelFrame, PixelTool } from './PixelDocument';
import { clonePixelDocument } from './PixelDocument';

interface PixelCanvasProps {
	document: PixelDocument;
	frameIndex: number;
	selectedColorIndex: number;
	tool: PixelTool;
	zoom: number;
	readOnly: boolean;
	onDocumentChange: (document: PixelDocument) => void;
	onPickColor: (colorIndex: number) => void;
}

interface PixelPoint {
	x: number;
	y: number;
}

const checkerSize = 8;
const gridColor = 'rgba(255,255,255,0.14)';
const heavyGridColor = 'rgba(255,255,255,0.24)';

const getPixelIndex = (x: number, y: number, width: number) => y * width + x;

const getCanvasPoint = (canvas: HTMLCanvasElement, event: React.PointerEvent<HTMLCanvasElement>, zoom: number): PixelPoint => {
	const rect = canvas.getBoundingClientRect();
	return {
		x: Math.floor((event.clientX - rect.left) / zoom),
		y: Math.floor((event.clientY - rect.top) / zoom),
	};
};

const drawChecker = (context: CanvasRenderingContext2D, width: number, height: number) => {
	context.fillStyle = '#222831';
	context.fillRect(0, 0, width, height);
	for (let y = 0; y < height; y += checkerSize) {
		for (let x = 0; x < width; x += checkerSize) {
			context.fillStyle = ((x / checkerSize + y / checkerSize) % 2 === 0) ? '#2f3642' : '#20262f';
			context.fillRect(x, y, checkerSize, checkerSize);
		}
	}
};

const drawFramePixels = (
	context: CanvasRenderingContext2D,
	frame: PixelFrame,
	palette: string[],
	width: number,
	height: number,
	zoom: number,
	alpha: number,
) => {
	context.globalAlpha = alpha;
	for (let y = 0; y < height; y++) {
		for (let x = 0; x < width; x++) {
			const colorIndex = frame.pixels[getPixelIndex(x, y, width)] ?? 0;
			if (colorIndex === 0) continue;
			context.fillStyle = palette[colorIndex] ?? palette[0] ?? '#00000000';
			context.fillRect(x * zoom, y * zoom, zoom, zoom);
		}
	}
	context.globalAlpha = 1;
};

const drawGrid = (context: CanvasRenderingContext2D, width: number, height: number, zoom: number) => {
	if (zoom < 6) return;
	context.lineWidth = 1;
	for (let x = 0; x <= width; x++) {
		context.strokeStyle = x % 8 === 0 ? heavyGridColor : gridColor;
		context.beginPath();
		context.moveTo(x * zoom + 0.5, 0);
		context.lineTo(x * zoom + 0.5, height * zoom);
		context.stroke();
	}
	for (let y = 0; y <= height; y++) {
		context.strokeStyle = y % 8 === 0 ? heavyGridColor : gridColor;
		context.beginPath();
		context.moveTo(0, y * zoom + 0.5);
		context.lineTo(width * zoom, y * zoom + 0.5);
		context.stroke();
	}
};

const floodFillPixels = (pixels: number[], width: number, height: number, start: PixelPoint, targetColor: number, replacementColor: number) => {
	const startIndex = getPixelIndex(start.x, start.y, width);
	const sourceColor = pixels[startIndex] ?? 0;
	if (sourceColor === replacementColor) return pixels;
	const nextPixels = [...pixels];
	const pending: PixelPoint[] = [start];
	while (pending.length > 0) {
		const point = pending.pop();
		if (point === undefined) break;
		if (point.x < 0 || point.y < 0 || point.x >= width || point.y >= height) continue;
		const index = getPixelIndex(point.x, point.y, width);
		if (nextPixels[index] !== sourceColor) continue;
		nextPixels[index] = targetColor;
		pending.push({ x: point.x + 1, y: point.y });
		pending.push({ x: point.x - 1, y: point.y });
		pending.push({ x: point.x, y: point.y + 1 });
		pending.push({ x: point.x, y: point.y - 1 });
	}
	return nextPixels;
};

export default function PixelCanvas(props: PixelCanvasProps) {
	const {
		document,
		frameIndex,
		selectedColorIndex,
		tool,
		zoom,
		readOnly,
		onDocumentChange,
		onPickColor,
	} = props;
	const canvasRef = useRef<HTMLCanvasElement | null>(null);
	const drawingRef = useRef(false);
	const lastPointRef = useRef<PixelPoint | null>(null);
	const [hoverPoint, setHoverPoint] = useState<PixelPoint | null>(null);
	const activeFrame = document.frames[frameIndex] ?? document.frames[0];
	const onionFrame = frameIndex > 0 ? document.frames[frameIndex - 1] : undefined;

	useEffect(() => {
		const canvas = canvasRef.current;
		if (canvas === null || activeFrame === undefined) return;
		const context = canvas.getContext('2d');
		if (context === null) return;
		context.imageSmoothingEnabled = false;
		const canvasWidth = document.width * zoom;
		const canvasHeight = document.height * zoom;
		drawChecker(context, canvasWidth, canvasHeight);
		if (onionFrame !== undefined) {
			drawFramePixels(context, onionFrame, document.palette, document.width, document.height, zoom, 0.28);
		}
		drawFramePixels(context, activeFrame, document.palette, document.width, document.height, zoom, 1);
		drawGrid(context, document.width, document.height, zoom);
		if (hoverPoint !== null && hoverPoint.x >= 0 && hoverPoint.y >= 0 && hoverPoint.x < document.width && hoverPoint.y < document.height) {
			context.strokeStyle = '#ffd54a';
			context.lineWidth = 2;
			context.strokeRect(hoverPoint.x * zoom + 1, hoverPoint.y * zoom + 1, zoom - 2, zoom - 2);
		}
	}, [activeFrame, document.height, document.palette, document.width, hoverPoint, onionFrame, zoom]);

	const paintAt = useCallback((point: PixelPoint) => {
		if (readOnly || activeFrame === undefined) return;
		if (point.x < 0 || point.y < 0 || point.x >= document.width || point.y >= document.height) return;
		const pixelIndex = getPixelIndex(point.x, point.y, document.width);
		const currentColorIndex = activeFrame.pixels[pixelIndex] ?? 0;
		if (tool === "eyedropper") {
			onPickColor(currentColorIndex);
			return;
		}
		const nextDocument = clonePixelDocument(document);
		const nextFrame = nextDocument.frames[frameIndex] ?? nextDocument.frames[0];
		if (nextFrame === undefined) return;
		if (tool === "fill") {
			nextFrame.pixels = floodFillPixels(nextFrame.pixels, nextDocument.width, nextDocument.height, point, selectedColorIndex, selectedColorIndex);
			onDocumentChange(nextDocument);
			return;
		}
		const nextColorIndex = tool === "eraser" ? 0 : selectedColorIndex;
		if (nextFrame.pixels[pixelIndex] === nextColorIndex) return;
		nextFrame.pixels[pixelIndex] = nextColorIndex;
		onDocumentChange(nextDocument);
	}, [activeFrame, document, frameIndex, onDocumentChange, onPickColor, readOnly, selectedColorIndex, tool]);

	const handlePointerDown = useCallback((event: React.PointerEvent<HTMLCanvasElement>) => {
		const canvas = canvasRef.current;
		if (canvas === null) return;
		canvas.setPointerCapture(event.pointerId);
		const point = getCanvasPoint(canvas, event, zoom);
		drawingRef.current = true;
		lastPointRef.current = point;
		setHoverPoint(point);
		paintAt(point);
	}, [paintAt, zoom]);

	const handlePointerMove = useCallback((event: React.PointerEvent<HTMLCanvasElement>) => {
		const canvas = canvasRef.current;
		if (canvas === null) return;
		const point = getCanvasPoint(canvas, event, zoom);
		setHoverPoint(point);
		if (!drawingRef.current) return;
		const lastPoint = lastPointRef.current;
		if (lastPoint !== null && lastPoint.x === point.x && lastPoint.y === point.y) return;
		lastPointRef.current = point;
		paintAt(point);
	}, [paintAt, zoom]);

	const stopDrawing = useCallback(() => {
		drawingRef.current = false;
		lastPointRef.current = null;
	}, []);

	return <canvas
		ref={canvasRef}
		width={document.width * zoom}
		height={document.height * zoom}
		style={{
			width: document.width * zoom,
			height: document.height * zoom,
			cursor: readOnly ? 'default' : 'crosshair',
			boxShadow: '0 24px 60px rgba(0,0,0,0.35)',
			border: '1px solid rgba(255,255,255,0.18)',
			background: '#20262f',
		}}
		onPointerDown={handlePointerDown}
		onPointerMove={handlePointerMove}
		onPointerUp={stopDrawing}
		onPointerCancel={stopDrawing}
		onPointerLeave={() => {
			setHoverPoint(null);
			stopDrawing();
		}}
	/>;
}
