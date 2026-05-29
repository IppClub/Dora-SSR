/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import type { ImageSpriteFrame, ImageSpriteFrameRect } from './SpriteDocument';

export type ImageSpriteQualityStatus = "pass" | "fixable" | "fail";

export interface ImageSpriteQualityInput {
	imageDataUrl: string;
	imageWidth: number;
	imageHeight: number;
	frames: ImageSpriteFrame[];
}

export interface ImageSpriteQualityOptions {
	alphaThreshold?: number;
	passBottomJitterPx?: number;
	passAnchorXJitterPx?: number;
	fixableShiftPx?: number;
	failBottomJitterPx?: number;
	failAnchorXJitterPx?: number;
	duplicateMotionScore?: number;
	minNonStaticMotionScore?: number;
	maxMotionImbalanceRatio?: number;
	maxLoopSpikeRatio?: number;
}

export interface ImageSpriteFrameAnalysis {
	index: number;
	rect: ImageSpriteFrameRect;
	empty: boolean;
	opaquePixels: number;
	bbox?: {
		left: number;
		top: number;
		right: number;
		bottom: number;
		width: number;
		height: number;
	};
	centroid?: {
		x: number;
		y: number;
	};
	anchor?: {
		x: number;
		y: number;
	};
	bboxCenterX?: number;
	fillRatio?: number;
}

export interface ImageSpriteTransitionAnalysis {
	fromFrameIndex: number;
	toFrameIndex: number;
	isLoop: boolean;
	maskIoU: number;
	meanAbsRgba: number;
	changedPixelRatio: number;
	motionScore: number;
}

export interface ImageSpriteQualityReport {
	status: ImageSpriteQualityStatus;
	ok: boolean;
	fixable: boolean;
	metrics: {
		frameCount: number;
		visibleFrameCount: number;
		imageWidth: number;
		imageHeight: number;
		alphaThreshold: number;
		bottomJitterPx: number;
		anchorXJitterPx: number;
		bboxCenterXJitterPx: number;
		centroidXJitterPx: number;
		maxSuggestedShiftPx: number;
		temporalMinMotionScore: number;
		temporalMaxMotionScore: number;
		temporalMedianMotionScore: number;
		temporalMotionImbalanceRatio: number;
		loopMotionScore: number;
		loopSpikeRatio: number;
		duplicateTransitionCount: number;
	};
	reference: {
		anchorX: number;
		anchorY: number;
	};
	shifts: Array<{
		frameIndex: number;
		dx: number;
		dy: number;
	}>;
	frames: ImageSpriteFrameAnalysis[];
	temporalPairs: ImageSpriteTransitionAnalysis[];
	warnings: string[];
	issues: string[];
}

const defaultAlphaThreshold = 8;
const defaultPassBottomJitter = 0;
const defaultPassAnchorXJitter = 1.5;
const defaultFixableShift = 3;
const defaultFailBottomJitter = 4;
const defaultFailAnchorXJitter = 6;
const defaultDuplicateMotionScore = 0.05;
const defaultMinNonStaticMotionScore = 0.12;
const defaultMaxMotionImbalanceRatio = 6;
const defaultMaxLoopSpikeRatio = 2.5;

const defaultMimeType = "image/png";

const median = (values: number[]) => {
	if (values.length === 0) return 0;
	const sorted = [...values].sort((a, b) => a - b);
	const middle = Math.floor(sorted.length / 2);
	return sorted.length % 2 === 0 ? (sorted[middle - 1] + sorted[middle]) / 2 : sorted[middle];
};

const range = (values: number[]) => {
	if (values.length === 0) return 0;
	return Math.max(...values) - Math.min(...values);
};

const roundMetric = (value: number, digits = 4) => {
	if (!Number.isFinite(value)) return 0;
	const factor = 10 ** digits;
	return Math.round(value * factor) / factor;
};

const clampInteger = (value: number, min: number, max: number) => {
	if (!Number.isFinite(value)) return min;
	return Math.max(min, Math.min(max, Math.round(value)));
};

const normalizeRect = (rect: ImageSpriteFrameRect, imageWidth: number, imageHeight: number): ImageSpriteFrameRect => {
	const x = clampInteger(rect.x, 0, Math.max(0, imageWidth - 1));
	const y = clampInteger(rect.y, 0, Math.max(0, imageHeight - 1));
	const width = clampInteger(rect.width, 1, Math.max(1, imageWidth - x));
	const height = clampInteger(rect.height, 1, Math.max(1, imageHeight - y));
	return { x, y, width, height };
};

const createImageElement = (source: string) => {
	return new Promise<HTMLImageElement>((resolve, reject) => {
		const image = new Image();
		image.onload = () => resolve(image);
		image.onerror = () => reject(new Error("failed to decode sprite sheet for quality evaluation"));
		image.src = source;
	});
};

const loadImageData = async (source: string) => {
	const image = await createImageElement(source);
	const canvas = window.document.createElement("canvas");
	canvas.width = image.naturalWidth;
	canvas.height = image.naturalHeight;
	const context = canvas.getContext("2d", { willReadFrequently: true });
	if (context === null) {
		throw new Error("failed to create sprite quality canvas context");
	}
	context.imageSmoothingEnabled = false;
	context.clearRect(0, 0, canvas.width, canvas.height);
	context.drawImage(image, 0, 0);
	return context.getImageData(0, 0, canvas.width, canvas.height);
};

const canvasToPngBlob = (canvas: HTMLCanvasElement) => {
	return new Promise<Blob>((resolve, reject) => {
		canvas.toBlob((blob) => {
			if (blob === null) reject(new Error("failed to encode aligned sprite sheet"));
			else resolve(blob);
		}, defaultMimeType);
	});
};

const getOffset = (imageData: ImageData, x: number, y: number) => (y * imageData.width + x) * 4;

const getAlpha = (imageData: ImageData, x: number, y: number) => imageData.data[getOffset(imageData, x, y) + 3];

const copyPixel = (source: ImageData, sx: number, sy: number, target: ImageData, tx: number, ty: number) => {
	if (tx < 0 || ty < 0 || tx >= target.width || ty >= target.height) return;
	const sourceOffset = getOffset(source, sx, sy);
	const targetOffset = getOffset(target, tx, ty);
	target.data[targetOffset] = source.data[sourceOffset];
	target.data[targetOffset + 1] = source.data[sourceOffset + 1];
	target.data[targetOffset + 2] = source.data[sourceOffset + 2];
	target.data[targetOffset + 3] = source.data[sourceOffset + 3];
};

const analyzeFrame = (imageData: ImageData, frame: ImageSpriteFrame, index: number, alphaThreshold: number): ImageSpriteFrameAnalysis => {
	const rect = normalizeRect(frame.rect, imageData.width, imageData.height);
	const xs: number[] = [];
	const ys: number[] = [];
	let sumX = 0;
	let sumY = 0;
	for (let y = rect.y; y < rect.y + rect.height; y += 1) {
		for (let x = rect.x; x < rect.x + rect.width; x += 1) {
			if (getAlpha(imageData, x, y) > alphaThreshold) {
				const localX = x - rect.x;
				const localY = y - rect.y;
				xs.push(localX);
				ys.push(localY);
				sumX += localX;
				sumY += localY;
			}
		}
	}
	if (xs.length === 0) {
		return {
			index,
			rect,
			empty: true,
			opaquePixels: 0,
		};
	}
	const left = Math.min(...xs);
	const right = Math.max(...xs);
	const top = Math.min(...ys);
	const bottom = Math.max(...ys);
	const height = bottom - top + 1;
	const lowerTop = Math.max(top, bottom - Math.max(3, Math.round(height * 0.3)) + 1);
	const lowerXs: number[] = [];
	for (let y = rect.y + lowerTop; y <= rect.y + bottom; y += 1) {
		for (let x = rect.x + left; x <= rect.x + right; x += 1) {
			if (getAlpha(imageData, x, y) > alphaThreshold) {
				lowerXs.push(x - rect.x);
			}
		}
	}
	const bboxCenterX = (left + right) / 2;
	return {
		index,
		rect,
		empty: false,
		opaquePixels: xs.length,
		bbox: {
			left,
			top,
			right,
			bottom,
			width: right - left + 1,
			height,
		},
		centroid: {
			x: sumX / xs.length,
			y: sumY / xs.length,
		},
		anchor: {
			x: lowerXs.length > 0 ? median(lowerXs) : bboxCenterX,
			y: bottom,
		},
		bboxCenterX,
		fillRatio: xs.length / (rect.width * rect.height),
	};
};

const analyzeFrameTransition = (
	imageData: ImageData,
	fromFrame: ImageSpriteFrame,
	fromFrameIndex: number,
	toFrame: ImageSpriteFrame,
	toFrameIndex: number,
	alphaThreshold: number,
	isLoop: boolean,
): ImageSpriteTransitionAnalysis => {
	const fromRect = normalizeRect(fromFrame.rect, imageData.width, imageData.height);
	const toRect = normalizeRect(toFrame.rect, imageData.width, imageData.height);
	const width = Math.min(fromRect.width, toRect.width);
	const height = Math.min(fromRect.height, toRect.height);
	let intersectionPixels = 0;
	let unionPixels = 0;
	let changedPixels = 0;
	let rgbaDeltaSum = 0;
	for (let localY = 0; localY < height; localY += 1) {
		for (let localX = 0; localX < width; localX += 1) {
			const fromOffset = getOffset(imageData, fromRect.x + localX, fromRect.y + localY);
			const toOffset = getOffset(imageData, toRect.x + localX, toRect.y + localY);
			const fromVisible = imageData.data[fromOffset + 3] > alphaThreshold;
			const toVisible = imageData.data[toOffset + 3] > alphaThreshold;
			if (!fromVisible && !toVisible) continue;
			unionPixels += 1;
			if (fromVisible && toVisible) intersectionPixels += 1;
			const redDelta = Math.abs(imageData.data[fromOffset] - imageData.data[toOffset]);
			const greenDelta = Math.abs(imageData.data[fromOffset + 1] - imageData.data[toOffset + 1]);
			const blueDelta = Math.abs(imageData.data[fromOffset + 2] - imageData.data[toOffset + 2]);
			const alphaDelta = Math.abs(imageData.data[fromOffset + 3] - imageData.data[toOffset + 3]);
			const delta = redDelta + greenDelta + blueDelta + alphaDelta;
			rgbaDeltaSum += delta;
			if (delta > 32) changedPixels += 1;
		}
	}
	const maskIoU = unionPixels > 0 ? intersectionPixels / unionPixels : 1;
	const meanAbsRgba = unionPixels > 0 ? rgbaDeltaSum / (unionPixels * 4) : 0;
	const changedPixelRatio = unionPixels > 0 ? changedPixels / unionPixels : 0;
	const motionScore = (1 - maskIoU) + (meanAbsRgba / 255);
	return {
		fromFrameIndex,
		toFrameIndex,
		isLoop,
		maskIoU: roundMetric(maskIoU),
		meanAbsRgba: roundMetric(meanAbsRgba, 2),
		changedPixelRatio: roundMetric(changedPixelRatio),
		motionScore: roundMetric(motionScore),
	};
};

const analyzeTemporalContinuity = (imageData: ImageData, frames: ImageSpriteFrame[], alphaThreshold: number, duplicateMotionScore: number) => {
	if (frames.length < 2) {
		return {
			pairs: [] as ImageSpriteTransitionAnalysis[],
			duplicatePairs: [] as ImageSpriteTransitionAnalysis[],
			minMotionScore: 0,
			maxMotionScore: 0,
			medianMotionScore: 0,
			nonLoopMedianMotionScore: 0,
			motionImbalanceRatio: 0,
			loopMotionScore: 0,
			loopSpikeRatio: 0,
		};
	}
	const pairs: ImageSpriteTransitionAnalysis[] = [];
	for (let index = 0; index < frames.length; index += 1) {
		const nextIndex = (index + 1) % frames.length;
		pairs.push(analyzeFrameTransition(
			imageData,
			frames[index],
			index,
			frames[nextIndex],
			nextIndex,
			alphaThreshold,
			nextIndex === 0,
		));
	}
	const scores = pairs.map((pair) => pair.motionScore);
	const nonLoopScores = pairs.filter((pair) => !pair.isLoop).map((pair) => pair.motionScore);
	const minMotionScore = Math.min(...scores);
	const maxMotionScore = Math.max(...scores);
	const medianMotionScore = median(scores);
	const nonLoopMedianMotionScore = median(nonLoopScores);
	const loopMotionScore = pairs.find((pair) => pair.isLoop)?.motionScore ?? 0;
	const motionImbalanceRatio = maxMotionScore / Math.max(minMotionScore, 0.001);
	const loopSpikeRatio = loopMotionScore / Math.max(nonLoopMedianMotionScore, 0.001);
	return {
		pairs,
		duplicatePairs: pairs.filter((pair) => pair.motionScore <= duplicateMotionScore),
		minMotionScore: roundMetric(minMotionScore),
		maxMotionScore: roundMetric(maxMotionScore),
		medianMotionScore: roundMetric(medianMotionScore),
		nonLoopMedianMotionScore: roundMetric(nonLoopMedianMotionScore),
		motionImbalanceRatio: roundMetric(motionImbalanceRatio, 2),
		loopMotionScore: roundMetric(loopMotionScore),
		loopSpikeRatio: roundMetric(loopSpikeRatio, 2),
	};
};

export const evaluateImageSpriteQuality = async (
	input: ImageSpriteQualityInput,
	options: ImageSpriteQualityOptions = {},
): Promise<ImageSpriteQualityReport> => {
	const alphaThreshold = options.alphaThreshold ?? defaultAlphaThreshold;
	const passBottomJitterPx = options.passBottomJitterPx ?? defaultPassBottomJitter;
	const passAnchorXJitterPx = options.passAnchorXJitterPx ?? defaultPassAnchorXJitter;
	const fixableShiftPx = options.fixableShiftPx ?? defaultFixableShift;
	const failBottomJitterPx = options.failBottomJitterPx ?? defaultFailBottomJitter;
	const failAnchorXJitterPx = options.failAnchorXJitterPx ?? defaultFailAnchorXJitter;
	const duplicateMotionScore = options.duplicateMotionScore ?? defaultDuplicateMotionScore;
	const minNonStaticMotionScore = options.minNonStaticMotionScore ?? defaultMinNonStaticMotionScore;
	const maxMotionImbalanceRatio = options.maxMotionImbalanceRatio ?? defaultMaxMotionImbalanceRatio;
	const maxLoopSpikeRatio = options.maxLoopSpikeRatio ?? defaultMaxLoopSpikeRatio;
	const imageData = await loadImageData(input.imageDataUrl);
	const issues: string[] = [];
	const warnings: string[] = [];
	if (input.imageWidth !== imageData.width) {
		issues.push(`metadata imageWidth=${input.imageWidth} but PNG width=${imageData.width}`);
	}
	if (input.imageHeight !== imageData.height) {
		issues.push(`metadata imageHeight=${input.imageHeight} but PNG height=${imageData.height}`);
	}
	if (input.frames.length === 0) {
		issues.push("sprite action has no frames");
	}
	const analyses = input.frames.map((frame, index) => analyzeFrame(imageData, frame, index, alphaThreshold));
	for (const analysis of analyses) {
		if (analysis.empty) {
			issues.push(`frame ${analysis.index + 1} has no visible pixels`);
		}
	}
	const visible = analyses.filter((analysis) => !analysis.empty);
	const bottoms = visible.map((analysis) => analysis.anchor?.y ?? 0);
	const anchorXs = visible.map((analysis) => analysis.anchor?.x ?? 0);
	const bboxCenterXs = visible.map((analysis) => analysis.bboxCenterX ?? 0);
	const centroidXs = visible.map((analysis) => analysis.centroid?.x ?? 0);
	const temporal = analyzeTemporalContinuity(imageData, input.frames, alphaThreshold, duplicateMotionScore);
	const metrics = {
		frameCount: input.frames.length,
		visibleFrameCount: visible.length,
		imageWidth: imageData.width,
		imageHeight: imageData.height,
		alphaThreshold,
		bottomJitterPx: range(bottoms),
		anchorXJitterPx: range(anchorXs),
		bboxCenterXJitterPx: range(bboxCenterXs),
		centroidXJitterPx: range(centroidXs),
		maxSuggestedShiftPx: 0,
		temporalMinMotionScore: temporal.minMotionScore,
		temporalMaxMotionScore: temporal.maxMotionScore,
		temporalMedianMotionScore: temporal.medianMotionScore,
		temporalMotionImbalanceRatio: temporal.motionImbalanceRatio,
		loopMotionScore: temporal.loopMotionScore,
		loopSpikeRatio: temporal.loopSpikeRatio,
		duplicateTransitionCount: temporal.duplicatePairs.length,
	};
	const reference = {
		anchorX: median(anchorXs),
		anchorY: median(bottoms),
	};
	const shifts = visible.map((analysis) => ({
		frameIndex: analysis.index,
		dx: Math.round(reference.anchorX - (analysis.anchor?.x ?? reference.anchorX)),
		dy: Math.round(reference.anchorY - (analysis.anchor?.y ?? reference.anchorY)),
	}));
	metrics.maxSuggestedShiftPx = shifts.reduce((max, shift) => Math.max(max, Math.abs(shift.dx), Math.abs(shift.dy)), 0);
	if (visible.length !== input.frames.length) {
		issues.push(`only ${visible.length}/${input.frames.length} frames contain visible pixels`);
	}
	if (metrics.bottomJitterPx > passBottomJitterPx) {
		warnings.push(`foot/bottom jitter ${metrics.bottomJitterPx.toFixed(2)}px exceeds pass threshold ${passBottomJitterPx}px`);
	}
	if (metrics.anchorXJitterPx > passAnchorXJitterPx) {
		warnings.push(`lower-body anchor X jitter ${metrics.anchorXJitterPx.toFixed(2)}px exceeds pass threshold ${passAnchorXJitterPx}px`);
	}
	if (metrics.bottomJitterPx > failBottomJitterPx) {
		issues.push(`foot/bottom jitter ${metrics.bottomJitterPx.toFixed(2)}px exceeds fail threshold ${failBottomJitterPx}px`);
	}
	if (metrics.anchorXJitterPx > failAnchorXJitterPx) {
		issues.push(`lower-body anchor X jitter ${metrics.anchorXJitterPx.toFixed(2)}px exceeds fail threshold ${failAnchorXJitterPx}px`);
	}
	const hasNonStaticMotion = metrics.temporalMaxMotionScore >= minNonStaticMotionScore;
	const transitionLabel = (pair: ImageSpriteTransitionAnalysis) => `F${pair.fromFrameIndex + 1}->F${pair.toFrameIndex + 1}`;
	if (hasNonStaticMotion && temporal.duplicatePairs.length > 0) {
		issues.push(`near-duplicate transition(s) ${temporal.duplicatePairs.map(transitionLabel).join(", ")} while other transitions move`);
	}
	if (hasNonStaticMotion && metrics.temporalMotionImbalanceRatio > maxMotionImbalanceRatio) {
		issues.push(`temporal motion imbalance ${metrics.temporalMotionImbalanceRatio.toFixed(2)}x exceeds threshold ${maxMotionImbalanceRatio}x`);
	}
	if (hasNonStaticMotion && metrics.loopSpikeRatio > maxLoopSpikeRatio) {
		issues.push(`loop transition spike ${metrics.loopSpikeRatio.toFixed(2)}x exceeds threshold ${maxLoopSpikeRatio}x`);
	}
	const needsFix = warnings.length > 0;
	const fixable = issues.length === 0 && needsFix && metrics.maxSuggestedShiftPx <= fixableShiftPx;
	let status: ImageSpriteQualityStatus = "pass";
	if (issues.length > 0) status = "fail";
	else if (needsFix) status = fixable ? "fixable" : "fail";
	if (needsFix && !fixable && status === "fail" && metrics.maxSuggestedShiftPx > fixableShiftPx) {
		issues.push(`suggested registration shift ${metrics.maxSuggestedShiftPx}px exceeds fixable threshold ${fixableShiftPx}px`);
	}
	return {
		status,
		ok: status === "pass",
		fixable,
		metrics,
		reference,
		shifts,
		frames: analyses,
		temporalPairs: temporal.pairs,
		warnings,
		issues,
	};
};

export const alignImageSpriteSheet = async (
	input: ImageSpriteQualityInput,
	report: ImageSpriteQualityReport,
) => {
	const source = await loadImageData(input.imageDataUrl);
	const targetCanvas = window.document.createElement("canvas");
	targetCanvas.width = source.width;
	targetCanvas.height = source.height;
	const targetContext = targetCanvas.getContext("2d", { willReadFrequently: true });
	if (targetContext === null) {
		throw new Error("failed to create aligned sprite canvas context");
	}
	const target = targetContext.createImageData(source.width, source.height);
	const shiftByFrame = new Map(report.shifts.map((shift) => [shift.frameIndex, shift]));
	for (const analysis of report.frames) {
		if (analysis.empty) continue;
		const shift = shiftByFrame.get(analysis.index) ?? { dx: 0, dy: 0 };
		const rect = analysis.rect;
		for (let localY = 0; localY < rect.height; localY += 1) {
			for (let localX = 0; localX < rect.width; localX += 1) {
				const sx = rect.x + localX;
				const sy = rect.y + localY;
				const tx = rect.x + localX + shift.dx;
				const ty = rect.y + localY + shift.dy;
				if (tx < rect.x || tx >= rect.x + rect.width || ty < rect.y || ty >= rect.y + rect.height) {
					continue;
				}
				copyPixel(source, sx, sy, target, tx, ty);
			}
		}
	}
	targetContext.putImageData(target, 0, 0);
	return {
		imageDataUrl: targetCanvas.toDataURL(defaultMimeType),
		imageBlob: await canvasToPngBlob(targetCanvas),
		imageWidth: targetCanvas.width,
		imageHeight: targetCanvas.height,
		frames: input.frames,
	};
};

export const formatImageSpriteQualityReport = (report: ImageSpriteQualityReport) => {
	const details = [
		...report.issues,
		...report.warnings,
	];
	if (details.length === 0) {
		return `quality=${report.status}`;
	}
	return details.slice(0, 3).join("; ");
};
