/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import { analyzeReferenceSpriteSheet, selectLargestSpriteSheetRegions, type RgbColor, type SpriteSheetAnalysisResult } from '../PixelEditor/SpriteSheetAnalysis';
import type { ImageSpriteFrame, ImageSpriteFrameRect } from './SpriteDocument';

export interface SpriteGenerationOptions {
	endpoint: string;
	identityReferenceImage: string;
	motionReferenceImage: string;
	expectedFrameCount: number;
	frameSize: number;
	motionName: string;
	facingPrompt: string;
	frameNamePrefix: string;
	frameDurationMs?: number;
	onProgress?: (message: string, stepIndex: number, stepCount: number) => void;
}

export interface SpriteGenerationResult {
	imageDataUrl: string;
	imageBlob: Blob;
	imageWidth: number;
	imageHeight: number;
	frames: ImageSpriteFrame[];
}

interface GoogleImageResponse {
	success?: unknown;
	message?: unknown;
	mimeType?: unknown;
	imageBase64?: unknown;
	text?: unknown;
}

const defaultMimeType = "image/png";
const cropPadding = 12;
const frameFillRatio = 0.9;
const transparentColorBleedPasses = 8;

const isRecord = (value: unknown): value is Record<string, unknown> => typeof value === "object" && value !== null;

const createFrameId = (index: number) => `generated-${Date.now().toString(36)}-${index + 1}`;

const parseGoogleImageResponse = (value: unknown): GoogleImageResponse => {
	if (!isRecord(value)) {
		throw new Error("Google image provider returned an invalid response");
	}
	return {
		success: value.success,
		message: value.message,
		mimeType: value.mimeType,
		imageBase64: value.imageBase64,
		text: value.text,
	};
};

const createImageElement = (source: string) => {
	return new Promise<HTMLImageElement>((resolve, reject) => {
		const image = new Image();
		image.onload = () => resolve(image);
		image.onerror = () => reject(new Error("failed to decode generated sprite image"));
		image.src = source;
	});
};

const dataUrlToBlob = async (dataUrl: string) => {
	const response = await fetch(dataUrl);
	return response.blob();
};

const colorDistanceSquared = (red: number, green: number, blue: number, background: RgbColor) => {
	const redDelta = red - background.r;
	const greenDelta = green - background.g;
	const blueDelta = blue - background.b;
	return redDelta * redDelta + greenDelta * greenDelta + blueDelta * blueDelta;
};

const isGeneratedBackgroundPixel = (red: number, green: number, blue: number, background: RgbColor) => {
	const closeToEdgeBackground = colorDistanceSquared(red, green, blue, background) < 42 * 42;
	const greenDominant = green > red + 32 && green > blue + 32 && green > 120;
	return closeToEdgeBackground || greenDominant;
};

const getImageDataOffset = (imageData: ImageData, x: number, y: number) => (y * imageData.width + x) * 4;

const hasTransparentNeighbour = (imageData: ImageData, x: number, y: number) => {
	for (let offsetY = -1; offsetY <= 1; offsetY += 1) {
		for (let offsetX = -1; offsetX <= 1; offsetX += 1) {
			if (offsetX === 0 && offsetY === 0) continue;
			const nextX = x + offsetX;
			const nextY = y + offsetY;
			if (nextX < 0 || nextY < 0 || nextX >= imageData.width || nextY >= imageData.height) return true;
			if (imageData.data[getImageDataOffset(imageData, nextX, nextY) + 3] === 0) return true;
		}
	}
	return false;
};

const removeGreenFringePixels = (imageData: ImageData) => {
	for (let y = 0; y < imageData.height; y += 1) {
		for (let x = 0; x < imageData.width; x += 1) {
			const offset = getImageDataOffset(imageData, x, y);
			const alpha = imageData.data[offset + 3];
			if (alpha === 0) {
				imageData.data[offset] = 0;
				imageData.data[offset + 1] = 0;
				imageData.data[offset + 2] = 0;
				continue;
			}
			const red = imageData.data[offset];
			const green = imageData.data[offset + 1];
			const blue = imageData.data[offset + 2];
			const greenDominant = green > red + 8 && green > blue + 8;
			const backgroundLike = greenDominant && red < 96 && blue < 96 && hasTransparentNeighbour(imageData, x, y);
			if (!backgroundLike) continue;
			if (green < 72) {
				imageData.data[offset] = 0;
				imageData.data[offset + 1] = 0;
				imageData.data[offset + 2] = 0;
				imageData.data[offset + 3] = 0;
			} else {
				imageData.data[offset + 1] = Math.max(red, blue);
			}
		}
	}
};

const bleedTransparentPixelColors = (imageData: ImageData, passes = transparentColorBleedPasses) => {
	for (let pass = 0; pass < passes; pass += 1) {
		const source = new Uint8ClampedArray(imageData.data);
		let changed = false;
		for (let y = 0; y < imageData.height; y += 1) {
			for (let x = 0; x < imageData.width; x += 1) {
				const offset = getImageDataOffset(imageData, x, y);
				if (source[offset + 3] !== 0) continue;
				let red = 0;
				let green = 0;
				let blue = 0;
				let count = 0;
				for (let offsetY = -1; offsetY <= 1; offsetY += 1) {
					for (let offsetX = -1; offsetX <= 1; offsetX += 1) {
						if (offsetX === 0 && offsetY === 0) continue;
						const nextX = x + offsetX;
						const nextY = y + offsetY;
						if (nextX < 0 || nextY < 0 || nextX >= imageData.width || nextY >= imageData.height) continue;
						const nextOffset = getImageDataOffset(imageData, nextX, nextY);
						if (source[nextOffset + 3] === 0) continue;
						red += source[nextOffset];
						green += source[nextOffset + 1];
						blue += source[nextOffset + 2];
						count += 1;
					}
				}
				if (count === 0) continue;
				imageData.data[offset] = Math.round(red / count);
				imageData.data[offset + 1] = Math.round(green / count);
				imageData.data[offset + 2] = Math.round(blue / count);
				imageData.data[offset + 3] = 0;
				changed = true;
			}
		}
		if (!changed) break;
	}
};

const clampInteger = (value: number, min: number, max: number) => {
	if (!Number.isFinite(value)) return min;
	return Math.max(min, Math.min(max, Math.round(value)));
};

const expandRect = (rect: ImageSpriteFrameRect, amount: number, maxWidth: number, maxHeight: number): ImageSpriteFrameRect => {
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

const createCleanCrop = (
	sourceImage: HTMLImageElement,
	cropRect: ImageSpriteFrameRect,
	background: RgbColor,
) => {
	const canvas = window.document.createElement("canvas");
	canvas.width = cropRect.width;
	canvas.height = cropRect.height;
	const context = canvas.getContext("2d", { willReadFrequently: true });
	if (context === null) {
		throw new Error("failed to create generated crop context");
	}
	context.drawImage(sourceImage, cropRect.x, cropRect.y, cropRect.width, cropRect.height, 0, 0, cropRect.width, cropRect.height);
	const imageData = context.getImageData(0, 0, canvas.width, canvas.height);
	for (let offset = 0; offset < imageData.data.length; offset += 4) {
		const red = imageData.data[offset];
		const green = imageData.data[offset + 1];
		const blue = imageData.data[offset + 2];
		if (isGeneratedBackgroundPixel(red, green, blue, background)) {
			imageData.data[offset] = 0;
			imageData.data[offset + 1] = 0;
			imageData.data[offset + 2] = 0;
			imageData.data[offset + 3] = 0;
		}
	}
	removeGreenFringePixels(imageData);
	bleedTransparentPixelColors(imageData);
	context.putImageData(imageData, 0, 0);
	return canvas;
};

const packDetectedFrames = async (
	generatedDataUrl: string,
	analysis: SpriteSheetAnalysisResult,
	frameSize: number,
	frameNamePrefix: string,
	frameDurationMs: number,
) => {
	const sourceImage = await createImageElement(generatedDataUrl);
	const frameCount = analysis.regions.length;
	const canvas = window.document.createElement("canvas");
	canvas.width = Math.max(1, frameCount * frameSize);
	canvas.height = frameSize;
	const context = canvas.getContext("2d", { willReadFrequently: true });
	if (context === null) {
		throw new Error("failed to create clean sprite sheet context");
	}
	context.imageSmoothingEnabled = false;
	context.clearRect(0, 0, canvas.width, canvas.height);
	const frames: ImageSpriteFrame[] = [];
	analysis.regions.forEach((region, index) => {
		const cropRect = expandRect(region.bounds, cropPadding, sourceImage.naturalWidth, sourceImage.naturalHeight);
		const cleanCrop = createCleanCrop(sourceImage, cropRect, analysis.background);
		const scale = Math.min(
			(frameSize * frameFillRatio) / cleanCrop.width,
			(frameSize * frameFillRatio) / cleanCrop.height,
		);
		const drawWidth = Math.max(1, Math.round(cleanCrop.width * scale));
		const drawHeight = Math.max(1, Math.round(cleanCrop.height * scale));
		const drawX = index * frameSize + Math.round((frameSize - drawWidth) / 2);
		const drawY = Math.round(frameSize - drawHeight - 2);
		context.drawImage(cleanCrop, drawX, drawY, drawWidth, drawHeight);
		frames.push({
			id: createFrameId(index),
			name: `${frameNamePrefix}_${index + 1}`,
			rect: {
				x: index * frameSize,
				y: 0,
				width: frameSize,
				height: frameSize,
			},
			duration: frameDurationMs,
			pivotX: 0.5,
			pivotY: 1,
		});
	});
	const packedImageData = context.getImageData(0, 0, canvas.width, canvas.height);
	removeGreenFringePixels(packedImageData);
	bleedTransparentPixelColors(packedImageData);
	context.putImageData(packedImageData, 0, 0);
	const imageDataUrl = canvas.toDataURL(defaultMimeType);
	return {
		imageDataUrl,
		imageBlob: await dataUrlToBlob(imageDataUrl),
		imageWidth: canvas.width,
		imageHeight: canvas.height,
		frames,
	};
};

const buildSpritePrompt = (expectedFrameCount: number, motionName: string, facingPrompt: string) => {
	return [
		"Generate one production game sprite sheet image.",
		"Image 1 is the character identity reference. Preserve hair color, skin tone, outfit, proportions, and recognizable accessories.",
		"Image 2 is a neutral grey mannequin motion template. Use only its idle timing, pose separation, pose silhouette, and facing direction. Do not copy the mannequin identity or grey colors.",
		`Required action: ${motionName}.`,
		`Required facing direction: ${facingPrompt}`,
		`Create exactly ${expectedFrameCount} separated idle animation frames of the same character.`,
		"Treat the frames as one looping animation cycle, not as independent poses.",
		"Sample the motion evenly across the cycle: each adjacent frame should change by a similar small amount.",
		"The last frame must transition smoothly back to the first frame; do not make a large last-to-first jump.",
		"Do not duplicate adjacent frames, and do not copy the first frame as the last frame.",
		"Every frame must keep the same facing direction; do not turn the character between front, side, and back views.",
		"If the identity reference shows a different angle, preserve the identity while redrawing the character in the required facing direction.",
		"Use a plain solid pure green background (#00ff00).",
		"No text, no letters, no numbers, no labels, no UI, no grid, no border, no watermark, no extra objects.",
		"The character must not hold a weapon.",
		"Keep each frame visually separated by green space so the editor can detect and crop each pose.",
		"Style: clean pixel-art game sprite, crisp silhouette, limited palette, sharp blocky edges.",
	].join("\n");
};

const callGoogleImageProvider = async (endpoint: string, prompt: string, referenceImages: string[]) => {
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
	const data = parseGoogleImageResponse(await response.json());
	if (!response.ok || data.success !== true) {
		throw new Error(typeof data.message === "string" ? data.message : `Google image provider failed with HTTP ${response.status}`);
	}
	if (typeof data.imageBase64 !== "string") {
		throw new Error("Google image provider response did not include imageBase64");
	}
	return {
		imageBase64: data.imageBase64,
		mimeType: typeof data.mimeType === "string" ? data.mimeType : defaultMimeType,
	};
};

export const generateImageSpriteSheet = async (options: SpriteGenerationOptions): Promise<SpriteGenerationResult> => {
	options.onProgress?.("Generating sprite sheet with Gemini 3 Pro Image...", 0, 3);
	const prompt = buildSpritePrompt(options.expectedFrameCount, options.motionName, options.facingPrompt);
	const generated = await callGoogleImageProvider(options.endpoint, prompt, [
		options.identityReferenceImage,
		options.motionReferenceImage,
	]);
	const generatedDataUrl = `data:${generated.mimeType};base64,${generated.imageBase64}`;
	options.onProgress?.("Detecting generated frame regions...", 1, 3);
	const analysis = selectLargestSpriteSheetRegions(
		await analyzeReferenceSpriteSheet(generatedDataUrl),
		options.expectedFrameCount,
	);
	if (analysis.regions.length === 0) {
		throw new Error("generated image did not contain detectable sprite frames");
	}
	options.onProgress?.("Packing clean image sprite sheet...", 2, 3);
	return packDetectedFrames(
		generatedDataUrl,
		analysis,
		options.frameSize,
		options.frameNamePrefix,
		options.frameDurationMs ?? 1000 / 8,
	);
};
