/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import type { PixelDocument } from './PixelDocument';
import {
	detectDominantEdgeColor,
	findForegroundBoundsInRect,
	isForegroundPixel,
	loadImageDataFromSource,
	type PixelRect,
	type SpriteSheetAnalysisResult,
	type SpriteSheetFrameRegion,
} from './SpriteSheetAnalysis';

export interface ExtractedSpriteFrame {
	name: string;
	pixels: number[];
	sourceRegion: SpriteSheetFrameRegion;
	detectedBounds?: PixelRect;
}

export interface SpriteSheetExtractionOptions {
	imageBase64: string;
	mimeType: string;
	document: PixelDocument;
	palette: string[];
	analysis: SpriteSheetAnalysisResult;
	namePrefix: string;
}

interface RgbColor {
	r: number;
	g: number;
	b: number;
}

const frameFillRatio = 0.88;
const maximumUpscale = 2;
const backgroundDistanceThreshold = 30;

const clampInteger = (value: number, min: number, max: number) => {
	if (!Number.isFinite(value)) return min;
	return Math.max(min, Math.min(max, Math.round(value)));
};

const getPixelOffset = (width: number, x: number, y: number) => (y * width + x) * 4;

const parseHexColor = (color: string) => {
	const match = color.match(/^#([0-9a-fA-F]{6})([0-9a-fA-F]{2})?$/);
	if (match === null) return undefined;
	const hex = match[1];
	return {
		r: Number.parseInt(hex.slice(0, 2), 16),
		g: Number.parseInt(hex.slice(2, 4), 16),
		b: Number.parseInt(hex.slice(4, 6), 16),
	};
};

const getPaletteRgb = (palette: string[]) => palette.map(parseHexColor);

const colorDistanceSquared = (left: RgbColor, right: RgbColor) => {
	const red = left.r - right.r;
	const green = left.g - right.g;
	const blue = left.b - right.b;
	return red * red + green * green + blue * blue;
};

const findNearestPaletteColor = (paletteRgb: ReturnType<typeof getPaletteRgb>, color: RgbColor) => {
	let bestIndex = 1;
	let bestDistance = Number.POSITIVE_INFINITY;
	for (let index = 1; index < paletteRgb.length; index++) {
		const paletteColor = paletteRgb[index];
		if (paletteColor === undefined) continue;
		const distance = colorDistanceSquared(color, paletteColor);
		if (distance < bestDistance) {
			bestIndex = index;
			bestDistance = distance;
		}
	}
	return bestIndex;
};

const scaleRect = (rect: PixelRect, scaleX: number, scaleY: number, maxWidth: number, maxHeight: number): PixelRect => {
	const x = clampInteger(rect.x * scaleX, 0, Math.max(0, maxWidth - 1));
	const y = clampInteger(rect.y * scaleY, 0, Math.max(0, maxHeight - 1));
	const right = clampInteger((rect.x + rect.width) * scaleX, x + 1, maxWidth);
	const bottom = clampInteger((rect.y + rect.height) * scaleY, y + 1, maxHeight);
	return {
		x,
		y,
		width: Math.max(1, right - x),
		height: Math.max(1, bottom - y),
	};
};

const expandRect = (rect: PixelRect, amount: number, maxWidth: number, maxHeight: number): PixelRect => {
	const x = clampInteger(rect.x - amount, 0, Math.max(0, maxWidth - 1));
	const y = clampInteger(rect.y - amount, 0, Math.max(0, maxHeight - 1));
	const right = clampInteger(rect.x + rect.width + amount, x + 1, maxWidth);
	const bottom = clampInteger(rect.y + rect.height + amount, y + 1, maxHeight);
	return {
		x,
		y,
		width: Math.max(1, right - x),
		height: Math.max(1, bottom - y),
	};
};

const drawRegionToFrame = (
	sourceImage: HTMLImageElement,
	bounds: PixelRect,
	document: PixelDocument,
) => {
	const canvas = window.document.createElement("canvas");
	canvas.width = document.width;
	canvas.height = document.height;
	const context = canvas.getContext("2d", { willReadFrequently: true });
	if (context === null) {
		throw new Error("failed to create sprite sheet extraction context");
	}
	context.imageSmoothingEnabled = false;
	context.clearRect(0, 0, canvas.width, canvas.height);
	const fitScale = Math.min(
		(document.width * frameFillRatio) / bounds.width,
		(document.height * frameFillRatio) / bounds.height,
	);
	const scale = Math.min(maximumUpscale, fitScale);
	const drawWidth = Math.max(1, Math.round(bounds.width * scale));
	const drawHeight = Math.max(1, Math.round(bounds.height * scale));
	const drawX = Math.round((document.width - drawWidth) / 2);
	const drawY = Math.round(document.height - drawHeight - 1);
	context.drawImage(sourceImage, bounds.x, bounds.y, bounds.width, bounds.height, drawX, drawY, drawWidth, drawHeight);
	return context.getImageData(0, 0, document.width, document.height);
};

const imageDataToPalettePixels = (imageData: ImageData, palette: string[], background: RgbColor) => {
	const paletteRgb = getPaletteRgb(palette);
	const pixels = new Array<number>(imageData.width * imageData.height).fill(0);
	for (let y = 0; y < imageData.height; y++) {
		for (let x = 0; x < imageData.width; x++) {
			const pixelIndex = y * imageData.width + x;
			if (!isForegroundPixel(imageData, pixelIndex, background, backgroundDistanceThreshold)) {
				continue;
			}
			const offset = getPixelOffset(imageData.width, x, y);
			pixels[pixelIndex] = findNearestPaletteColor(paletteRgb, {
				r: imageData.data[offset],
				g: imageData.data[offset + 1],
				b: imageData.data[offset + 2],
			});
		}
	}
	return pixels;
};

const createImageElement = (source: string) => {
	return new Promise<HTMLImageElement>((resolve, reject) => {
		const image = new Image();
		image.onload = () => resolve(image);
		image.onerror = () => reject(new Error("failed to decode generated sprite sheet"));
		image.src = source;
	});
};

export const extractFramesFromGeneratedSpriteSheet = async (options: SpriteSheetExtractionOptions) => {
	const { imageBase64, mimeType, document, palette, analysis, namePrefix } = options;
	const source = `data:${mimeType};base64,${imageBase64}`;
	const sourceImage = await createImageElement(source);
	const imageData = await loadImageDataFromSource(source);
	const background = detectDominantEdgeColor(imageData);
	const scaleX = imageData.width / analysis.width;
	const scaleY = imageData.height / analysis.height;
	const extractedFrames: ExtractedSpriteFrame[] = [];
	for (const region of analysis.regions) {
		const slot = scaleRect(region.slot, scaleX, scaleY, imageData.width, imageData.height);
		const detectedBounds = findForegroundBoundsInRect(imageData, slot, background, backgroundDistanceThreshold);
		const fallbackBounds = scaleRect(region.bounds, scaleX, scaleY, imageData.width, imageData.height);
		const spriteBounds = expandRect(detectedBounds ?? fallbackBounds, 1, imageData.width, imageData.height);
		const frameImageData = drawRegionToFrame(sourceImage, spriteBounds, document);
		const pixels = imageDataToPalettePixels(frameImageData, palette, background);
		extractedFrames.push({
			name: `${namePrefix}_${region.index + 1}_r${region.row + 1}c${region.column + 1}`,
			pixels,
			sourceRegion: region,
			detectedBounds: detectedBounds === undefined ? undefined : {
				x: detectedBounds.x,
				y: detectedBounds.y,
				width: detectedBounds.width,
				height: detectedBounds.height,
			},
		});
	}
	return extractedFrames;
};
