/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import type { PixelDocument, PixelFrame } from './PixelDocument';
import { defaultPixelPalette } from './PixelDocument';
import type { PixelMotionCategory, PixelMotionFrame, PixelMotionTemplate } from './PixelMotionTemplate';
import { getPixelMotionTemplate } from './PixelMotionTemplate';
import { analyzeReferenceSpriteSheet, selectLargestSpriteSheetRegions } from './SpriteSheetAnalysis';
import { extractFramesFromGeneratedSpriteSheet } from './SpriteSheetExtraction';

export type PixelGenerationProviderId = "draft" | "google_gemini_3_pro_image" | "google_vertex";
export type PixelGenerationOutputMode = "replace" | "append";

export interface PixelGenerationProvider {
	id: PixelGenerationProviderId;
	name: string;
	description: string;
	defaultEndpoint?: string;
}

export interface PixelGenerationStep {
	index: number;
	name: string;
	prompt: string;
	bodyOffsetX: number;
	bodyOffsetY: number;
	footAnchorX: number;
	footAnchorY: number;
}

export interface PixelGenerationPlan {
	providerId: PixelGenerationProviderId;
	providerName: string;
	templateId: string;
	templateName: string;
	category: PixelMotionCategory;
	identityReferenceImage?: string;
	motionReferenceImage?: string;
	width: number;
	height: number;
	fps: number;
	consistencyPrompt: string;
	steps: PixelGenerationStep[];
}

export interface PixelGenerationResult {
	width?: number;
	height?: number;
	palette: string[];
	frames: PixelFrame[];
}

export interface GoogleVertexGenerationOptions {
	endpoint: string;
	identityReferenceImage?: string;
	motionReferenceImage?: string;
	onProgress?: (message: string, frameIndex: number, frameCount: number) => void;
}

interface GoogleVertexFrameResponse {
	success?: unknown;
	message?: unknown;
	mimeType?: unknown;
	imageBase64?: unknown;
	text?: unknown;
	usage?: unknown;
}

interface PixelBuffer {
	width: number;
	height: number;
	pixels: number[];
}

interface CharacterPalette {
	outline: number;
	clothes: number;
	skin: number;
	accent: number;
	shadow: number;
}

interface PoseGeometry {
	centerX: number;
	groundY: number;
	unit: number;
	bodyOffsetY: number;
}

const sourceTemplateSize = 32;
const googleGemini3ProImageDefaultEndpoint = "http://127.0.0.1:8877/api/google-gemini/generate-sprite";
const googleVertexDefaultEndpoint = "http://127.0.0.1:8877/api/google-vertex/generate-frame";

export const pixelGenerationProviders: PixelGenerationProvider[] = [
	{
		id: "draft",
		name: "Draft Renderer",
		description: "Deterministic offline frame draft for testing timeline and export flow.",
	},
	{
		id: "google_gemini_3_pro_image",
		name: "Gemini 3 Pro Image",
		description: "Generate a reference-guided sprite sheet with Gemini 3 Pro Image, then auto-detect and extract the largest pose frames.",
		defaultEndpoint: googleGemini3ProImageDefaultEndpoint,
	},
	{
		id: "google_vertex",
		name: "Google Vertex Custom",
		description: "Generate one complete sprite sheet through a custom Google Vertex provider endpoint, then extract pose slots into frames.",
		defaultEndpoint: googleVertexDefaultEndpoint,
	},
];

const clampNumber = (value: number, min: number, max: number) => Math.max(min, Math.min(max, value));

const clampInteger = (value: number, min: number, max: number) => {
	return Math.round(clampNumber(value, min, max));
};

const minimumGoogleVertexFrameSize = 64;
const maximumGoogleVertexFrameSize = 128;

const createFrameId = (templateId: string, index: number) => {
	return `generated-${templateId}-${index + 1}-${Date.now().toString(36)}-${Math.random().toString(36).slice(2, 7)}`;
};

const createPixelBuffer = (width: number, height: number): PixelBuffer => ({
	width,
	height,
	pixels: new Array<number>(width * height).fill(0),
});

const getPixelIndex = (buffer: PixelBuffer, x: number, y: number) => y * buffer.width + x;

const setPixel = (buffer: PixelBuffer, x: number, y: number, colorIndex: number) => {
	if (x < 0 || y < 0 || x >= buffer.width || y >= buffer.height) return;
	buffer.pixels[getPixelIndex(buffer, x, y)] = colorIndex;
};

const drawDisc = (buffer: PixelBuffer, centerX: number, centerY: number, radius: number, colorIndex: number) => {
	const safeRadius = Math.max(0, radius);
	const minX = Math.floor(centerX - safeRadius);
	const maxX = Math.ceil(centerX + safeRadius);
	const minY = Math.floor(centerY - safeRadius);
	const maxY = Math.ceil(centerY + safeRadius);
	const radiusSquared = safeRadius * safeRadius;
	for (let y = minY; y <= maxY; y++) {
		for (let x = minX; x <= maxX; x++) {
			const dx = x - centerX;
			const dy = y - centerY;
			if (dx * dx + dy * dy <= radiusSquared) {
				setPixel(buffer, x, y, colorIndex);
			}
		}
	}
};

const drawEllipse = (buffer: PixelBuffer, centerX: number, centerY: number, radiusX: number, radiusY: number, colorIndex: number) => {
	const safeRadiusX = Math.max(1, radiusX);
	const safeRadiusY = Math.max(1, radiusY);
	const minX = Math.floor(centerX - safeRadiusX);
	const maxX = Math.ceil(centerX + safeRadiusX);
	const minY = Math.floor(centerY - safeRadiusY);
	const maxY = Math.ceil(centerY + safeRadiusY);
	for (let y = minY; y <= maxY; y++) {
		for (let x = minX; x <= maxX; x++) {
			const dx = (x - centerX) / safeRadiusX;
			const dy = (y - centerY) / safeRadiusY;
			if (dx * dx + dy * dy <= 1) {
				setPixel(buffer, x, y, colorIndex);
			}
		}
	}
};

const drawRect = (buffer: PixelBuffer, left: number, top: number, width: number, height: number, colorIndex: number) => {
	const startX = Math.round(left);
	const startY = Math.round(top);
	const endX = Math.round(left + width);
	const endY = Math.round(top + height);
	for (let y = startY; y < endY; y++) {
		for (let x = startX; x < endX; x++) {
			setPixel(buffer, x, y, colorIndex);
		}
	}
};

const drawLine = (buffer: PixelBuffer, fromX: number, fromY: number, toX: number, toY: number, thickness: number, colorIndex: number) => {
	const steps = Math.max(Math.abs(toX - fromX), Math.abs(toY - fromY), 1);
	const radius = Math.max(0, thickness / 2);
	for (let step = 0; step <= steps; step++) {
		const t = step / steps;
		const x = fromX + (toX - fromX) * t;
		const y = fromY + (toY - fromY) * t;
		drawDisc(buffer, x, y, radius, colorIndex);
	}
};

const drawOutlinedLine = (
	buffer: PixelBuffer,
	fromX: number,
	fromY: number,
	toX: number,
	toY: number,
	thickness: number,
	colorIndex: number,
	outlineIndex: number,
) => {
	drawLine(buffer, fromX, fromY, toX, toY, thickness + 2, outlineIndex);
	drawLine(buffer, fromX, fromY, toX, toY, thickness, colorIndex);
};

const ensureGenerationPalette = (palette: string[]) => {
	const nextPalette = [...palette];
	defaultPixelPalette.forEach((color) => {
		if (!nextPalette.includes(color)) {
			nextPalette.push(color);
		}
	});
	return nextPalette;
};

const findPaletteIndex = (palette: string[], color: string, fallbackIndex: number) => {
	const index = palette.findIndex((item) => item.toLowerCase() === color.toLowerCase());
	return index >= 0 ? index : clampInteger(fallbackIndex, 0, Math.max(0, palette.length - 1));
};

const buildCharacterPalette = (palette: string[]): CharacterPalette => ({
	outline: findPaletteIndex(palette, "#101820ff", 1),
	clothes: findPaletteIndex(palette, "#2f80edff", 4),
	skin: findPaletteIndex(palette, "#f2994aff", 7),
	accent: findPaletteIndex(palette, "#f2aa4cff", 2),
	shadow: findPaletteIndex(palette, "#333333ff", 10),
});

export const buildPixelGenerationPlan = (document: PixelDocument, providerId: PixelGenerationProviderId = "draft"): PixelGenerationPlan => {
	const template = getPixelMotionTemplate(document.motionTemplate);
	const provider = pixelGenerationProviders.find((item) => item.id === providerId) ?? pixelGenerationProviders[0];
	return {
		providerId: provider.id,
		providerName: provider.name,
		templateId: template.id,
		templateName: template.name,
		category: template.category,
		identityReferenceImage: document.identityReferenceImage,
		motionReferenceImage: document.motionReferenceImage,
		width: document.width,
		height: document.height,
		fps: template.fps,
		consistencyPrompt: [
			"same character identity",
			"same outfit and colors",
			"same pixel art scale",
			"solid green background",
			`${document.width}x${document.height} canvas`,
		].join(", "),
		steps: template.frames.map((frame, index) => ({
			index,
			name: frame.name,
			prompt: frame.prompt,
			bodyOffsetX: frame.bodyOffsetX,
			bodyOffsetY: frame.bodyOffsetY,
			footAnchorX: frame.footAnchorX,
			footAnchorY: frame.footAnchorY,
		})),
	};
};

export const getPixelGenerationProvider = (id: PixelGenerationProviderId) => {
	return pixelGenerationProviders.find((provider) => provider.id === id) ?? pixelGenerationProviders[0];
};

export const isPixelGenerationProviderId = (id: string): id is PixelGenerationProviderId => {
	return pixelGenerationProviders.some((provider) => provider.id === id);
};

const scaleFromTemplate = (value: number, size: number) => value * size / sourceTemplateSize;

const createPoseGeometry = (document: PixelDocument, frame: PixelMotionFrame): PoseGeometry => {
	const unit = Math.max(1, Math.min(document.width, document.height) / sourceTemplateSize);
	const centerX = clampNumber(
		scaleFromTemplate(frame.footAnchorX + frame.bodyOffsetX, document.width),
		4 * unit,
		document.width - 4 * unit,
	);
	const groundY = clampNumber(
		scaleFromTemplate(frame.footAnchorY, document.height),
		12 * unit,
		document.height - 1,
	);
	return {
		centerX,
		groundY,
		unit,
		bodyOffsetY: frame.bodyOffsetY * unit,
	};
};

const drawShadow = (buffer: PixelBuffer, geometry: PoseGeometry, palette: CharacterPalette) => {
	drawEllipse(buffer, geometry.centerX, geometry.groundY + geometry.unit, 6 * geometry.unit, 1.2 * geometry.unit, palette.shadow);
};

const drawStandingCharacter = (
	buffer: PixelBuffer,
	geometry: PoseGeometry,
	palette: CharacterPalette,
	category: PixelMotionCategory,
	frameIndex: number,
	frameCount: number,
) => {
	const phase = frameCount <= 0 ? 0 : frameIndex / frameCount * Math.PI * 2;
	const strideUnit = category === "run" ? 5 : category === "walk" ? 3 : 1.2;
	const armUnit = category === "run" ? 5 : category === "walk" ? 3.4 : 1;
	const bounce = category === "run" ? Math.abs(Math.sin(phase)) * -1.4 : category === "walk" ? Math.abs(Math.sin(phase)) * -0.7 : Math.sin(phase) * -0.4;
	const centerX = geometry.centerX;
	const groundY = geometry.groundY;
	const unit = geometry.unit;
	const torsoCenterY = groundY - 13 * unit + geometry.bodyOffsetY + bounce * unit;
	const hipY = groundY - 8 * unit + geometry.bodyOffsetY + bounce * unit;
	const shoulderY = torsoCenterY - 3 * unit;
	const headY = torsoCenterY - 9 * unit;
	const legSwing = Math.sin(phase) * strideUnit * unit;
	const armSwing = -Math.sin(phase) * armUnit * unit;
	const limbThickness = Math.max(1, unit * 1.3);

	drawShadow(buffer, geometry, palette);
	drawOutlinedLine(buffer, centerX - unit, hipY, centerX + legSwing, groundY, limbThickness, palette.clothes, palette.outline);
	drawOutlinedLine(buffer, centerX + unit, hipY, centerX - legSwing * 0.9, groundY, limbThickness, palette.clothes, palette.outline);
	drawOutlinedLine(buffer, centerX - 2 * unit, shoulderY, centerX + armSwing, hipY + 2 * unit, limbThickness, palette.skin, palette.outline);
	drawOutlinedLine(buffer, centerX + 2 * unit, shoulderY, centerX - armSwing * 0.85, hipY + 2 * unit, limbThickness, palette.skin, palette.outline);
	drawRect(buffer, centerX - 4.5 * unit, torsoCenterY - 5 * unit, 9 * unit, 11 * unit, palette.outline);
	drawRect(buffer, centerX - 3.5 * unit, torsoCenterY - 4 * unit, 7 * unit, 9 * unit, palette.clothes);
	drawEllipse(buffer, centerX + 0.5 * unit, headY, 4.8 * unit, 5 * unit, palette.outline);
	drawEllipse(buffer, centerX + 0.5 * unit, headY + 0.4 * unit, 3.7 * unit, 3.8 * unit, palette.skin);
	drawRect(buffer, centerX + 2.4 * unit, headY - unit, 1.2 * unit, 1.2 * unit, palette.outline);
	drawRect(buffer, centerX - 2 * unit, torsoCenterY + 2 * unit, 4 * unit, 1.5 * unit, palette.accent);
};

const drawAttackCharacter = (
	buffer: PixelBuffer,
	geometry: PoseGeometry,
	palette: CharacterPalette,
	frameIndex: number,
	frameCount: number,
) => {
	const progress = frameCount <= 1 ? 1 : frameIndex / (frameCount - 1);
	const unit = geometry.unit;
	const centerX = geometry.centerX + progress * 2 * unit;
	const groundY = geometry.groundY;
	const torsoCenterY = groundY - 13 * unit + geometry.bodyOffsetY;
	const hipY = groundY - 8 * unit + geometry.bodyOffsetY;
	const shoulderY = torsoCenterY - 3 * unit;
	const headY = torsoCenterY - 9 * unit;
	const reach = [-3, 5, 8, 2][frameIndex] ?? Math.round(progress * 6);
	const limbThickness = Math.max(1, unit * 1.3);

	drawShadow(buffer, geometry, palette);
	drawOutlinedLine(buffer, centerX - 1.5 * unit, hipY, centerX - 4 * unit, groundY, limbThickness, palette.clothes, palette.outline);
	drawOutlinedLine(buffer, centerX + unit, hipY, centerX + 4 * unit, groundY, limbThickness, palette.clothes, palette.outline);
	drawOutlinedLine(buffer, centerX - 2 * unit, shoulderY, centerX - 4 * unit, hipY, limbThickness, palette.skin, palette.outline);
	drawOutlinedLine(buffer, centerX + 2 * unit, shoulderY, centerX + reach * unit, shoulderY + unit, limbThickness, palette.skin, palette.outline);
	drawOutlinedLine(buffer, centerX + reach * unit, shoulderY + unit, centerX + (reach + 5) * unit, shoulderY - unit, Math.max(1, unit), palette.accent, palette.outline);
	drawRect(buffer, centerX - 4.5 * unit, torsoCenterY - 5 * unit, 9 * unit, 11 * unit, palette.outline);
	drawRect(buffer, centerX - 3.5 * unit, torsoCenterY - 4 * unit, 7 * unit, 9 * unit, palette.clothes);
	drawEllipse(buffer, centerX + 0.8 * unit, headY, 4.8 * unit, 5 * unit, palette.outline);
	drawEllipse(buffer, centerX + 0.8 * unit, headY + 0.4 * unit, 3.7 * unit, 3.8 * unit, palette.skin);
};

const drawHurtCharacter = (buffer: PixelBuffer, geometry: PoseGeometry, palette: CharacterPalette, frameIndex: number) => {
	const unit = geometry.unit;
	const recoil = (frameIndex === 0 ? -3 : -1) * unit;
	const centerX = geometry.centerX + recoil;
	const groundY = geometry.groundY;
	const torsoCenterY = groundY - 12 * unit + geometry.bodyOffsetY;
	const hipY = groundY - 7 * unit + geometry.bodyOffsetY;
	const shoulderY = torsoCenterY - 3 * unit;
	const headY = torsoCenterY - 9 * unit;
	const limbThickness = Math.max(1, unit * 1.3);

	drawShadow(buffer, geometry, palette);
	drawOutlinedLine(buffer, centerX - unit, hipY, centerX - 3 * unit, groundY, limbThickness, palette.clothes, palette.outline);
	drawOutlinedLine(buffer, centerX + unit, hipY, centerX + 2 * unit, groundY, limbThickness, palette.clothes, palette.outline);
	drawOutlinedLine(buffer, centerX - 2 * unit, shoulderY, centerX - 5 * unit, shoulderY - 2 * unit, limbThickness, palette.skin, palette.outline);
	drawOutlinedLine(buffer, centerX + 2 * unit, shoulderY, centerX - unit, shoulderY - 3 * unit, limbThickness, palette.skin, palette.outline);
	drawRect(buffer, centerX - 4.5 * unit, torsoCenterY - 5 * unit, 9 * unit, 11 * unit, palette.outline);
	drawRect(buffer, centerX - 3.5 * unit, torsoCenterY - 4 * unit, 7 * unit, 9 * unit, palette.clothes);
	drawEllipse(buffer, centerX - unit, headY, 4.8 * unit, 5 * unit, palette.outline);
	drawEllipse(buffer, centerX - unit, headY + 0.4 * unit, 3.7 * unit, 3.8 * unit, palette.skin);
};

const drawDeathCharacter = (
	buffer: PixelBuffer,
	geometry: PoseGeometry,
	palette: CharacterPalette,
	frameIndex: number,
	frameCount: number,
) => {
	const unit = geometry.unit;
	const progress = frameCount <= 1 ? 1 : frameIndex / (frameCount - 1);
	const centerX = geometry.centerX - progress * 2 * unit;
	const groundY = geometry.groundY;
	const standingAmount = 1 - progress;
	const torsoCenterY = groundY - (13 * standingAmount + 3 * progress) * unit + geometry.bodyOffsetY * progress;
	const limbThickness = Math.max(1, unit * 1.3);

	drawShadow(buffer, geometry, palette);
	if (progress < 0.5) {
		drawStandingCharacter(buffer, geometry, palette, "hurt", frameIndex, frameCount);
		return;
	}
	drawOutlinedLine(buffer, centerX - 8 * unit, torsoCenterY, centerX + 7 * unit, torsoCenterY + 2 * unit, 5 * unit, palette.clothes, palette.outline);
	drawOutlinedLine(buffer, centerX + 4 * unit, torsoCenterY + 2 * unit, centerX + 10 * unit, groundY, limbThickness, palette.clothes, palette.outline);
	drawOutlinedLine(buffer, centerX - 2 * unit, torsoCenterY + unit, centerX - 7 * unit, groundY, limbThickness, palette.clothes, palette.outline);
	drawOutlinedLine(buffer, centerX + 2 * unit, torsoCenterY - unit, centerX + 9 * unit, torsoCenterY - 3 * unit, limbThickness, palette.skin, palette.outline);
	drawEllipse(buffer, centerX - 10 * unit, torsoCenterY - unit, 5 * unit, 4 * unit, palette.outline);
	drawEllipse(buffer, centerX - 10 * unit, torsoCenterY - unit, 3.8 * unit, 3 * unit, palette.skin);
};

const drawDraftFrame = (
	document: PixelDocument,
	template: PixelMotionTemplate,
	motionFrame: PixelMotionFrame,
	frameIndex: number,
	palette: CharacterPalette,
) => {
	const buffer = createPixelBuffer(document.width, document.height);
	const geometry = createPoseGeometry(document, motionFrame);
	switch (template.category) {
		case "attack":
			drawAttackCharacter(buffer, geometry, palette, frameIndex, template.frames.length);
			break;
		case "hurt":
			drawHurtCharacter(buffer, geometry, palette, frameIndex);
			break;
		case "death":
			drawDeathCharacter(buffer, geometry, palette, frameIndex, template.frames.length);
			break;
		default:
			drawStandingCharacter(buffer, geometry, palette, template.category, frameIndex, template.frames.length);
			break;
	}
	return buffer.pixels;
};

export const generateDraftAnimation = async (document: PixelDocument, plan: PixelGenerationPlan): Promise<PixelGenerationResult> => {
	const template = getPixelMotionTemplate(plan.templateId);
	const palette = ensureGenerationPalette(document.palette);
	const characterPalette = buildCharacterPalette(palette);
	const frames = template.frames.map((frame, index) => ({
		id: createFrameId(template.id, index),
		name: `${template.category}_${index + 1}_${frame.name}`,
		pixels: drawDraftFrame({ ...document, palette }, template, frame, index, characterPalette),
	}));
	return { palette, frames };
};

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

const getPaletteRgb = (palette: string[]) => {
	return palette.map(parseHexColor);
};

const colorDistanceSquared = (r1: number, g1: number, b1: number, r2: number, g2: number, b2: number) => {
	const dr = r1 - r2;
	const dg = g1 - g2;
	const db = b1 - b2;
	return dr * dr + dg * dg + db * db;
};

const findNearestPaletteColor = (paletteRgb: ReturnType<typeof getPaletteRgb>, r: number, g: number, b: number) => {
	let bestIndex = 1;
	let bestDistance = Number.POSITIVE_INFINITY;
	for (let index = 1; index < paletteRgb.length; index++) {
		const color = paletteRgb[index];
		if (color === undefined) continue;
		const distance = colorDistanceSquared(r, g, b, color.r, color.g, color.b);
		if (distance < bestDistance) {
			bestIndex = index;
			bestDistance = distance;
		}
	}
	return bestIndex;
};

const createImageElement = (source: string) => {
	return new Promise<HTMLImageElement>((resolve, reject) => {
		const image = new Image();
		image.onload = () => resolve(image);
		image.onerror = () => reject(new Error("failed to decode generated image"));
		image.src = source;
	});
};

const getImageDataFromImage = (image: HTMLImageElement) => {
	const canvas = document.createElement("canvas");
	canvas.width = image.naturalWidth;
	canvas.height = image.naturalHeight;
	const context = canvas.getContext("2d", { willReadFrequently: true });
	if (context === null) {
		throw new Error("failed to create image processing context");
	}
	context.drawImage(image, 0, 0);
	return context.getImageData(0, 0, canvas.width, canvas.height);
};

const getPixelOffset = (width: number, x: number, y: number) => (y * width + x) * 4;

const sampleBackgroundColor = (imageData: ImageData) => {
	const { width, height, data } = imageData;
	const points = [
		{ x: 0, y: 0 },
		{ x: width - 1, y: 0 },
		{ x: 0, y: height - 1 },
		{ x: width - 1, y: height - 1 },
	];
	const total = points.reduce((accumulator, point) => {
		const offset = getPixelOffset(width, point.x, point.y);
		return {
			r: accumulator.r + data[offset],
			g: accumulator.g + data[offset + 1],
			b: accumulator.b + data[offset + 2],
		};
	}, { r: 0, g: 0, b: 0 });
	return {
		r: total.r / points.length,
		g: total.g / points.length,
		b: total.b / points.length,
	};
};

const isForegroundPixel = (imageData: ImageData, offset: number, background: { r: number; g: number; b: number }) => {
	const { data } = imageData;
	const alpha = data[offset + 3];
	if (alpha < 32) return false;
	const red = data[offset];
	const green = data[offset + 1];
	const blue = data[offset + 2];
	const brightness = (red + green + blue) / 3;
	const chroma = Math.max(red, green, blue) - Math.min(red, green, blue);
	if (brightness > 245 && chroma < 12) return false;
	return colorDistanceSquared(red, green, blue, background.r, background.g, background.b) > 32 * 32;
};

const findSubjectBounds = (imageData: ImageData) => {
	const { width, height } = imageData;
	const background = sampleBackgroundColor(imageData);
	let minX = width;
	let minY = height;
	let maxX = -1;
	let maxY = -1;
	for (let y = 0; y < height; y++) {
		for (let x = 0; x < width; x++) {
			const offset = getPixelOffset(width, x, y);
			if (!isForegroundPixel(imageData, offset, background)) continue;
			minX = Math.min(minX, x);
			minY = Math.min(minY, y);
			maxX = Math.max(maxX, x);
			maxY = Math.max(maxY, y);
		}
	}
	if (maxX < minX || maxY < minY) {
		return { x: 0, y: 0, width, height };
	}
	const padding = Math.round(Math.max(maxX - minX + 1, maxY - minY + 1) * 0.12);
	const x = clampInteger(minX - padding, 0, width - 1);
	const y = clampInteger(minY - padding, 0, height - 1);
	const right = clampInteger(maxX + padding, 0, width - 1);
	const bottom = clampInteger(maxY + padding, 0, height - 1);
	return {
		x,
		y,
		width: Math.max(1, right - x + 1),
		height: Math.max(1, bottom - y + 1),
	};
};

const generatedImageToPixels = async (imageBase64: string, mimeType: string, pixelDocument: PixelDocument, palette: string[]) => {
	const image = await createImageElement(`data:${mimeType};base64,${imageBase64}`);
	const sourceImageData = getImageDataFromImage(image);
	const bounds = findSubjectBounds(sourceImageData);
	const canvas = document.createElement("canvas");
	canvas.width = pixelDocument.width;
	canvas.height = pixelDocument.height;
	const context = canvas.getContext("2d", { willReadFrequently: true });
	if (context === null) {
		throw new Error("failed to create pixel conversion context");
	}
	context.imageSmoothingEnabled = false;
	context.clearRect(0, 0, canvas.width, canvas.height);
	const scale = Math.min(pixelDocument.width / bounds.width, pixelDocument.height / bounds.height) * 0.86;
	const drawWidth = Math.max(1, Math.round(bounds.width * scale));
	const drawHeight = Math.max(1, Math.round(bounds.height * scale));
	const drawX = Math.round((pixelDocument.width - drawWidth) / 2);
	const drawY = Math.round((pixelDocument.height - drawHeight) / 2);
	context.drawImage(image, bounds.x, bounds.y, bounds.width, bounds.height, drawX, drawY, drawWidth, drawHeight);
	const targetImageData = context.getImageData(0, 0, pixelDocument.width, pixelDocument.height);
	const background = sampleBackgroundColor(targetImageData);
	const paletteRgb = getPaletteRgb(palette);
	const pixels = new Array<number>(pixelDocument.width * pixelDocument.height).fill(0);
	for (let y = 0; y < pixelDocument.height; y++) {
		for (let x = 0; x < pixelDocument.width; x++) {
			const offset = getPixelOffset(pixelDocument.width, x, y);
			if (!isForegroundPixel(targetImageData, offset, background)) {
				pixels[y * pixelDocument.width + x] = 0;
				continue;
			}
			pixels[y * pixelDocument.width + x] = findNearestPaletteColor(
				paletteRgb,
				targetImageData.data[offset],
				targetImageData.data[offset + 1],
				targetImageData.data[offset + 2],
			);
		}
	}
	return pixels;
};

const buildGoogleVertexPrompt = (plan: PixelGenerationPlan, step: PixelGenerationStep) => {
	return [
		"Create one animation frame for a 2D game sprite.",
		"Reference image order when images are provided:",
		"Image 1 is the 256x256 character portrait. Use it as the exact character identity.",
		"Image 2 is the 256x256 motion reference sheet. Use it for layout, pose language and facing direction.",
		"Apply the character from image 1 to the pose/layout guidance from image 2.",
		"Keep the same outfit, skin tone, hair color, proportions, silhouette, and pixel-art scale across frames.",
		`Canvas target after processing: ${plan.width}x${plan.height}.`,
		"Generate a centered full-body sprite pose on a solid green background.",
		"No text, no watermark, no UI, no border, no grid lines, no numbers, no extra objects.",
		"The character must not hold any weapon.",
		"Style: clean readable pixel art, sharp silhouette, side-view game asset.",
		`Motion template: ${plan.templateName}.`,
		`Frame ${step.index + 1}/${plan.steps.length}: ${step.name}.`,
		`Pose requirement: ${step.prompt}.`,
		`Body offset guide: ${step.bodyOffsetX},${step.bodyOffsetY}. Foot anchor guide: ${step.footAnchorX},${step.footAnchorY}.`,
		`Consistency constraints: ${plan.consistencyPrompt}.`,
	].join("\n");
};

const buildGoogleVertexSpriteSheetPrompt = (plan: PixelGenerationPlan, detectedFrameCount: number) => {
	return [
		"Create one complete square pixel art sprite sheet image for a 2D game.",
		"Reference image order:",
		"Image 1 is a compact character portrait. Use it as the exact character identity reference.",
		"Image 2 is the 256x256 neutral grey mannequin motion template. Use it only as the strict pose-slot layout reference.",
		"Do not copy mannequin grey colors, simple body shape, or any visual identity from image 2.",
		"Replace every character pose in image 2 with the character from image 1.",
		"Keep the same pose order, facing direction, character scale, and idle timing as image 2.",
		`The reference sheet analysis detected ${detectedFrameCount} pose slot(s); keep one character per pose slot.`,
		"Prefer one horizontal row when possible, but if the model packs frames differently each frame must remain separated by green space.",
		"When the template or canvas contains unused space, leave that unused area green.",
		"Use one solid pure green background (#00ff00) across the entire sheet.",
		"Do not draw text, numbers, grid lines, UI, watermark, border, labels, or extra objects.",
		"The character must not hold any weapon.",
		"Keep outfit, skin tone, hair color, silhouette, and proportions consistent across all poses.",
		"Output only the final sprite sheet image.",
		`Target editor frame size after extraction: ${plan.width}x${plan.height}.`,
		`Current motion context: ${plan.templateName}.`,
		`Consistency constraints: ${plan.consistencyPrompt}.`,
	].join("\n");
};

const getGoogleVertexReferenceImages = (options: GoogleVertexGenerationOptions) => {
	const referenceImages: string[] = [];
	if (options.identityReferenceImage !== undefined) {
		referenceImages.push(options.identityReferenceImage);
	}
	if (options.motionReferenceImage !== undefined) {
		referenceImages.push(options.motionReferenceImage);
	}
	return referenceImages;
};

const isRecord = (value: unknown): value is Record<string, unknown> => {
	return typeof value === "object" && value !== null;
};

const parseGoogleVertexResponse = (value: unknown): GoogleVertexFrameResponse => {
	if (typeof value !== "object" || value === null) {
		throw new Error("Google Vertex provider returned a non-object response");
	}
	if (!isRecord(value)) {
		throw new Error("Google Vertex provider returned an invalid response");
	}
	return {
		success: value.success,
		message: value.message,
		mimeType: value.mimeType,
		imageBase64: value.imageBase64,
		text: value.text,
		usage: value.usage,
	};
};

const callGoogleVertexFrame = async (endpoint: string, prompt: string, referenceImages?: string[]) => {
	const response = await fetch(endpoint, {
		method: "POST",
		headers: {
			"Content-Type": "application/json",
		},
		body: JSON.stringify({
			prompt,
			referenceImages,
		}),
	});
	const data = parseGoogleVertexResponse(await response.json());
	if (!response.ok || data.success !== true) {
		throw new Error(typeof data.message === "string" ? data.message : `Google Vertex provider failed with HTTP ${response.status}`);
	}
	if (typeof data.imageBase64 !== "string") {
		throw new Error("Google Vertex provider response did not include imageBase64");
	}
	return {
		imageBase64: data.imageBase64,
		mimeType: typeof data.mimeType === "string" ? data.mimeType : "image/png",
	};
};

const callGoogleVertexSpriteSheet = async (endpoint: string, prompt: string, referenceImages: string[]) => {
	return callGoogleVertexFrame(endpoint, prompt, referenceImages);
};

export const generateGoogleVertexAnimation = async (
	document: PixelDocument,
	plan: PixelGenerationPlan,
	options: GoogleVertexGenerationOptions,
): Promise<PixelGenerationResult> => {
	const template = getPixelMotionTemplate(plan.templateId);
	const palette = ensureGenerationPalette(document.palette);
	const frames: PixelFrame[] = [];
	for (let index = 0; index < plan.steps.length; index++) {
		const step = plan.steps[index];
		if (step === undefined) continue;
		options.onProgress?.(`Generating ${step.name} with Google Vertex...`, index, plan.steps.length);
		const prompt = buildGoogleVertexPrompt(plan, step);
		const result = await callGoogleVertexFrame(options.endpoint, prompt, getGoogleVertexReferenceImages(options));
		const pixels = await generatedImageToPixels(result.imageBase64, result.mimeType, { ...document, palette }, palette);
		frames.push({
			id: createFrameId(template.id, index),
			name: `${template.category}_${index + 1}_${step.name}`,
			pixels,
		});
	}
	return { palette, frames };
};

export const generateGoogleVertexSpriteSheetAnimation = async (
	document: PixelDocument,
	plan: PixelGenerationPlan,
	options: GoogleVertexGenerationOptions,
): Promise<PixelGenerationResult> => {
	if (options.identityReferenceImage === undefined) {
		throw new Error("Character portrait reference is required for Google Vertex sprite sheet generation.");
	}
	if (options.motionReferenceImage === undefined) {
		throw new Error("Motion reference sheet is required for Google Vertex sprite sheet generation.");
	}
	options.onProgress?.("Analyzing motion reference sheet...", 0, 3);
	const referenceAnalysis = await analyzeReferenceSpriteSheet(options.motionReferenceImage);
	const expectedFrameCount = Math.max(1, plan.steps.length);
	options.onProgress?.(`Generating one sprite sheet with ${expectedFrameCount} expected pose slot(s)...`, 1, 4);
	const prompt = buildGoogleVertexSpriteSheetPrompt(plan, Math.min(referenceAnalysis.regions.length, expectedFrameCount));
	const result = await callGoogleVertexSpriteSheet(options.endpoint, prompt, getGoogleVertexReferenceImages(options));
	options.onProgress?.("Detecting generated pose regions...", 2, 4);
	const generatedSource = `data:${result.mimeType};base64,${result.imageBase64}`;
	const generatedAnalysis = selectLargestSpriteSheetRegions(
		await analyzeReferenceSpriteSheet(generatedSource),
		expectedFrameCount,
	);
	options.onProgress?.(`Extracting ${generatedAnalysis.regions.length} detected pose region(s) into timeline frames...`, 3, 4);
	const palette = ensureGenerationPalette(document.palette);
	const targetFrameSize = clampInteger(
		Math.max(document.width, document.height, minimumGoogleVertexFrameSize),
		minimumGoogleVertexFrameSize,
		maximumGoogleVertexFrameSize,
	);
	const extractedFrames = await extractFramesFromGeneratedSpriteSheet({
		imageBase64: result.imageBase64,
		mimeType: result.mimeType,
		document: { ...document, width: targetFrameSize, height: targetFrameSize, palette },
		palette,
		analysis: generatedAnalysis,
		namePrefix: getPixelMotionTemplate(plan.templateId).category,
	});
	return {
		width: targetFrameSize,
		height: targetFrameSize,
		palette,
		frames: extractedFrames.map((frame, index) => ({
			id: createFrameId(plan.templateId, index),
			name: frame.name,
			pixels: frame.pixels,
		})),
	};
};
