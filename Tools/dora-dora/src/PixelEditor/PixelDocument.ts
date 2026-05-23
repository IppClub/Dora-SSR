/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import { defaultPixelMotionTemplateId, isPixelMotionTemplateId } from './PixelMotionTemplate';

export type PixelTool = "pencil" | "eraser" | "eyedropper" | "fill";

export interface PixelFrame {
	id: string;
	name: string;
	pixels: number[];
}

export interface PixelDocument {
	version: 1;
	width: number;
	height: number;
	fps: number;
	identityReferenceImage?: string;
	motionReferenceImage?: string;
	motionTemplate: string;
	palette: string[];
	frames: PixelFrame[];
	selectedFrame: number;
}

export const transparentColor = "#00000000";
export const defaultPixelPalette = [
	transparentColor,
	"#101820ff",
	"#f2aa4cff",
	"#f6f7f8ff",
	"#2f80edff",
	"#eb5757ff",
	"#27ae60ff",
	"#f2994aff",
	"#9b51e0ff",
	"#56ccf2ff",
	"#333333ff",
	"#ffffffff",
];

const maxCanvasSize = 256;
const minCanvasSize = 1;
const maxFrames = 256;

const clampInteger = (value: number, min: number, max: number) => {
	if (!Number.isFinite(value)) return min;
	return Math.max(min, Math.min(max, Math.floor(value)));
};

const normalizePaletteColor = (color: unknown) => {
	if (typeof color !== "string") return transparentColor;
	const trimmed = color.trim();
	if (/^#[0-9a-fA-F]{6}$/.test(trimmed)) return `${trimmed}ff`;
	if (/^#[0-9a-fA-F]{8}$/.test(trimmed)) return trimmed;
	return transparentColor;
};

const normalizeOptionalString = (value: unknown) => {
	if (typeof value !== "string") return undefined;
	const trimmed = value.trim();
	return trimmed === "" ? undefined : trimmed;
};

const createFramePixels = (width: number, height: number) => new Array<number>(width * height).fill(0);

export const createPixelFrame = (name: string, width: number, height: number): PixelFrame => ({
	id: `frame-${Date.now().toString(36)}-${Math.random().toString(36).slice(2, 8)}`,
	name,
	pixels: createFramePixels(width, height),
});

export const createEmptyPixelDocument = (width = 32, height = 32, frames = 1): PixelDocument => {
	const safeWidth = clampInteger(width, minCanvasSize, maxCanvasSize);
	const safeHeight = clampInteger(height, minCanvasSize, maxCanvasSize);
	const frameCount = clampInteger(frames, 1, maxFrames);
	return {
		version: 1,
		width: safeWidth,
		height: safeHeight,
		fps: 8,
		motionTemplate: defaultPixelMotionTemplateId,
		palette: [...defaultPixelPalette],
		frames: Array.from({ length: frameCount }, (_, index) => createPixelFrame(`Frame ${index + 1}`, safeWidth, safeHeight)),
		selectedFrame: 0,
	};
};

const isRecord = (value: unknown): value is Record<string, unknown> => {
	return typeof value === "object" && value !== null;
};

const normalizeFrame = (value: unknown, index: number, width: number, height: number, paletteLength: number): PixelFrame => {
	const expectedPixels = width * height;
	const fallbackPixels = createFramePixels(width, height);
	if (!isRecord(value)) {
		return {
			id: `frame-${index + 1}`,
			name: `Frame ${index + 1}`,
			pixels: fallbackPixels,
		};
	}
	const sourcePixels = Array.isArray(value.pixels) ? value.pixels : [];
	const pixels = fallbackPixels.map((_, pixelIndex) => {
		const pixel = sourcePixels[pixelIndex];
		if (typeof pixel !== "number") return 0;
		return clampInteger(pixel, 0, Math.max(0, paletteLength - 1));
	});
	if (pixels.length !== expectedPixels) {
		return {
			id: typeof value.id === "string" && value.id !== "" ? value.id : `frame-${index + 1}`,
			name: typeof value.name === "string" && value.name !== "" ? value.name : `Frame ${index + 1}`,
			pixels: fallbackPixels,
		};
	}
	return {
		id: typeof value.id === "string" && value.id !== "" ? value.id : `frame-${index + 1}`,
		name: typeof value.name === "string" && value.name !== "" ? value.name : `Frame ${index + 1}`,
		pixels,
	};
};

export const normalizePixelDocument = (value: unknown): PixelDocument => {
	if (!isRecord(value)) return createEmptyPixelDocument();
	const width = clampInteger(typeof value.width === "number" ? value.width : 32, minCanvasSize, maxCanvasSize);
	const height = clampInteger(typeof value.height === "number" ? value.height : 32, minCanvasSize, maxCanvasSize);
	const palette = Array.isArray(value.palette) ? value.palette.map(normalizePaletteColor) : [...defaultPixelPalette];
	if (palette.length === 0 || palette[0] !== transparentColor) {
		palette.unshift(transparentColor);
	}
	const sourceFrames = Array.isArray(value.frames) ? value.frames.slice(0, maxFrames) : [];
	const frames = sourceFrames.length > 0 ?
		sourceFrames.map((frame, index) => normalizeFrame(frame, index, width, height, palette.length)) :
		[createPixelFrame("Frame 1", width, height)];
	const selectedFrame = clampInteger(
		typeof value.selectedFrame === "number" ? value.selectedFrame : 0,
		0,
		Math.max(0, frames.length - 1),
	);
	const motionTemplate = typeof value.motionTemplate === "string" && isPixelMotionTemplateId(value.motionTemplate) ?
		value.motionTemplate :
		defaultPixelMotionTemplateId;
	const legacyReferenceImage = normalizeOptionalString(value.referenceImage);
	const identityReferenceImage = normalizeOptionalString(value.identityReferenceImage) ?? legacyReferenceImage;
	const motionReferenceImage = normalizeOptionalString(value.motionReferenceImage);
	return {
		version: 1,
		width,
		height,
		fps: clampInteger(typeof value.fps === "number" ? value.fps : 8, 1, 60),
		identityReferenceImage,
		motionReferenceImage,
		motionTemplate,
		palette,
		frames,
		selectedFrame,
	};
};

export const readPixelDocument = (source: string): PixelDocument => {
	try {
		return normalizePixelDocument(JSON.parse(source));
	} catch (_error) {
		return createEmptyPixelDocument();
	}
};

export const writePixelDocument = (document: PixelDocument) => {
	return JSON.stringify(normalizePixelDocument(document), undefined, "\t");
};

export const isPixelDocumentFile = (filePath: string) => filePath.toLowerCase().endsWith(".pixel.json");

export const clonePixelDocument = (document: PixelDocument): PixelDocument => normalizePixelDocument(document);
