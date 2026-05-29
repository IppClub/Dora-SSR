import fs from 'node:fs';
import path from 'node:path';
import zlib from 'node:zlib';

const PNG_SIGNATURE = Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]);
const DEFAULT_ALPHA_THRESHOLD = 8;
const DEFAULT_PASS_BOTTOM_JITTER = 0;
const DEFAULT_PASS_ANCHOR_X_JITTER = 1.5;
const DEFAULT_FIXABLE_SHIFT = 3;
const DEFAULT_FAIL_BOTTOM_JITTER = 4;
const DEFAULT_FAIL_ANCHOR_X_JITTER = 6;
const DEFAULT_DUPLICATE_MOTION_SCORE = 0.05;
const DEFAULT_MIN_NON_STATIC_MOTION_SCORE = 0.12;
const DEFAULT_MAX_MOTION_IMBALANCE_RATIO = 6;
const DEFAULT_MAX_LOOP_SPIKE_RATIO = 2.5;
const DEFAULT_GREEN_FRINGE_DARK_CUTOFF = 72;

const assert = (condition, message) => {
	if (!condition) throw new Error(message);
};

const median = (values) => {
	if (values.length === 0) return 0;
	const sorted = [...values].sort((a, b) => a - b);
	const middle = Math.floor(sorted.length / 2);
	return sorted.length % 2 === 0 ? (sorted[middle - 1] + sorted[middle]) / 2 : sorted[middle];
};

const range = (values) => {
	if (values.length === 0) return 0;
	return Math.max(...values) - Math.min(...values);
};

const roundMetric = (value, digits = 4) => {
	if (!Number.isFinite(value)) return 0;
	const factor = 10 ** digits;
	return Math.round(value * factor) / factor;
};

const clampInteger = (value, min, max) => {
	const num = Number(value);
	if (!Number.isFinite(num)) return min;
	return Math.max(min, Math.min(max, Math.round(num)));
};

const paethPredictor = (a, b, c) => {
	const p = a + b - c;
	const pa = Math.abs(p - a);
	const pb = Math.abs(p - b);
	const pc = Math.abs(p - c);
	return pa <= pb && pa <= pc ? a : (pb <= pc ? b : c);
};

export const readPngRgba = (filePath) => {
	const input = fs.readFileSync(filePath);
	assert(input.subarray(0, 8).equals(PNG_SIGNATURE), `${filePath} is not a PNG file`);
	let offset = 8;
	let width = 0;
	let height = 0;
	let bitDepth = 0;
	let colorType = 0;
	let interlace = 0;
	let palette;
	let transparency;
	const idatChunks = [];
	while (offset + 12 <= input.length) {
		const length = input.readUInt32BE(offset);
		const type = input.subarray(offset + 4, offset + 8).toString('ascii');
		const data = input.subarray(offset + 8, offset + 8 + length);
		offset += 12 + length;
		if (type === 'IHDR') {
			width = data.readUInt32BE(0);
			height = data.readUInt32BE(4);
			bitDepth = data[8];
			colorType = data[9];
			interlace = data[12];
		} else if (type === 'PLTE') {
			palette = data;
		} else if (type === 'tRNS') {
			transparency = data;
		} else if (type === 'IDAT') {
			idatChunks.push(data);
		} else if (type === 'IEND') {
			break;
		}
	}
	assert(width > 0 && height > 0, `${filePath} has invalid PNG dimensions`);
	assert(bitDepth === 8, `${filePath} uses unsupported PNG bit depth ${bitDepth}; expected 8`);
	assert(interlace === 0, `${filePath} uses interlaced PNG, which is not supported by this evaluator`);
	const channelCount = ({ 0: 1, 2: 3, 3: 1, 4: 2, 6: 4 })[colorType];
	assert(channelCount !== undefined, `${filePath} uses unsupported PNG color type ${colorType}`);
	const inflated = zlib.inflateSync(Buffer.concat(idatChunks));
	const stride = width * channelCount;
	const rgba = new Uint8Array(width * height * 4);
	let readOffset = 0;
	let previous = new Uint8Array(stride);
	for (let y = 0; y < height; y += 1) {
		const filter = inflated[readOffset];
		readOffset += 1;
		const scanline = inflated.subarray(readOffset, readOffset + stride);
		readOffset += stride;
		const recon = new Uint8Array(stride);
		for (let i = 0; i < stride; i += 1) {
			const left = i >= channelCount ? recon[i - channelCount] : 0;
			const up = previous[i];
			const upLeft = i >= channelCount ? previous[i - channelCount] : 0;
			let value;
			if (filter === 0) value = scanline[i];
			else if (filter === 1) value = (scanline[i] + left) & 255;
			else if (filter === 2) value = (scanline[i] + up) & 255;
			else if (filter === 3) value = (scanline[i] + Math.floor((left + up) / 2)) & 255;
			else if (filter === 4) value = (scanline[i] + paethPredictor(left, up, upLeft)) & 255;
			else throw new Error(`${filePath} uses invalid PNG filter ${filter}`);
			recon[i] = value;
		}
		for (let x = 0; x < width; x += 1) {
			const dst = (y * width + x) * 4;
			const src = x * channelCount;
			if (colorType === 6) {
				rgba[dst] = recon[src];
				rgba[dst + 1] = recon[src + 1];
				rgba[dst + 2] = recon[src + 2];
				rgba[dst + 3] = recon[src + 3];
			} else if (colorType === 2) {
				rgba[dst] = recon[src];
				rgba[dst + 1] = recon[src + 1];
				rgba[dst + 2] = recon[src + 2];
				rgba[dst + 3] = 255;
			} else if (colorType === 4) {
				rgba[dst] = recon[src];
				rgba[dst + 1] = recon[src];
				rgba[dst + 2] = recon[src];
				rgba[dst + 3] = recon[src + 1];
			} else if (colorType === 0) {
				rgba[dst] = recon[src];
				rgba[dst + 1] = recon[src];
				rgba[dst + 2] = recon[src];
				rgba[dst + 3] = 255;
			} else if (colorType === 3) {
				assert(palette !== undefined, `${filePath} is indexed PNG without palette`);
				const index = recon[src];
				const paletteOffset = index * 3;
				rgba[dst] = palette[paletteOffset] ?? 0;
				rgba[dst + 1] = palette[paletteOffset + 1] ?? 0;
				rgba[dst + 2] = palette[paletteOffset + 2] ?? 0;
				rgba[dst + 3] = transparency?.[index] ?? 255;
			}
		}
		previous = recon;
	}
	return { width, height, data: rgba };
};

const pngChunk = (type, data) => {
	const typeBuffer = Buffer.from(type, 'ascii');
	const chunk = Buffer.alloc(8 + data.length + 4);
	chunk.writeUInt32BE(data.length, 0);
	typeBuffer.copy(chunk, 4);
	data.copy(chunk, 8);
	chunk.writeUInt32BE(zlib.crc32 ? zlib.crc32(Buffer.concat([typeBuffer, data])) : crc32(Buffer.concat([typeBuffer, data])), 8 + data.length);
	return chunk;
};

// Fallback CRC32 for Node builds without zlib.crc32.
let crcTable;
const crc32 = (buffer) => {
	if (!crcTable) {
		crcTable = new Uint32Array(256);
		for (let n = 0; n < 256; n += 1) {
			let c = n;
			for (let k = 0; k < 8; k += 1) c = c & 1 ? 0xedb88320 ^ (c >>> 1) : c >>> 1;
			crcTable[n] = c >>> 0;
		}
	}
	let c = 0xffffffff;
	for (const byte of buffer) c = crcTable[(c ^ byte) & 0xff] ^ (c >>> 8);
	return (c ^ 0xffffffff) >>> 0;
};

export const writePngRgba = (filePath, image) => {
	const { width, height, data } = image;
	assert(data.length === width * height * 4, `invalid RGBA buffer size for ${width}x${height}`);
	const raw = Buffer.alloc(height * (1 + width * 4));
	let offset = 0;
	for (let y = 0; y < height; y += 1) {
		raw[offset] = 0;
		offset += 1;
		Buffer.from(data.buffer, data.byteOffset + y * width * 4, width * 4).copy(raw, offset);
		offset += width * 4;
	}
	const ihdr = Buffer.alloc(13);
	ihdr.writeUInt32BE(width, 0);
	ihdr.writeUInt32BE(height, 4);
	ihdr[8] = 8;
	ihdr[9] = 6;
	ihdr[10] = 0;
	ihdr[11] = 0;
	ihdr[12] = 0;
	const output = Buffer.concat([
		PNG_SIGNATURE,
		pngChunk('IHDR', ihdr),
		pngChunk('IDAT', zlib.deflateSync(raw, { level: 9 })),
		pngChunk('IEND', Buffer.alloc(0)),
	]);
	fs.mkdirSync(path.dirname(filePath), { recursive: true });
	fs.writeFileSync(filePath, output);
};

const getAlpha = (image, x, y) => image.data[(y * image.width + x) * 4 + 3];

const getPixelOffset = (image, x, y) => (y * image.width + x) * 4;

const hasTransparentNeighbor = (image, x, y) => {
	for (let dy = -1; dy <= 1; dy += 1) {
		for (let dx = -1; dx <= 1; dx += 1) {
			if (dx === 0 && dy === 0) continue;
			const nx = x + dx;
			const ny = y + dy;
			if (nx < 0 || ny < 0 || nx >= image.width || ny >= image.height) return true;
			if (getAlpha(image, nx, ny) === 0) return true;
		}
	}
	return false;
};

const bleedTransparentPixelColors = (image) => {
	const source = new Uint8Array(image.data);
	let changed = 0;
	for (let y = 0; y < image.height; y += 1) {
		for (let x = 0; x < image.width; x += 1) {
			const offset = getPixelOffset(image, x, y);
			if (source[offset + 3] !== 0) continue;
			let red = 0;
			let green = 0;
			let blue = 0;
			let count = 0;
			for (let dy = -1; dy <= 1; dy += 1) {
				for (let dx = -1; dx <= 1; dx += 1) {
					if (dx === 0 && dy === 0) continue;
					const nx = x + dx;
					const ny = y + dy;
					if (nx < 0 || ny < 0 || nx >= image.width || ny >= image.height) continue;
					const neighborOffset = getPixelOffset(image, nx, ny);
					if (source[neighborOffset + 3] === 0) continue;
					red += source[neighborOffset];
					green += source[neighborOffset + 1];
					blue += source[neighborOffset + 2];
					count += 1;
				}
			}
			if (count === 0) continue;
			image.data[offset] = Math.round(red / count);
			image.data[offset + 1] = Math.round(green / count);
			image.data[offset + 2] = Math.round(blue / count);
			image.data[offset + 3] = 0;
			changed += 1;
		}
	}
	return changed;
};

export const cleanImageSpriteEdges = (image, options = {}) => {
	const greenFringeDarkCutoff = options.greenFringeDarkCutoff ?? DEFAULT_GREEN_FRINGE_DARK_CUTOFF;
	let removedGreenFringePixels = 0;
	let despilledGreenFringePixels = 0;
	let clearedTransparentPixels = 0;
	for (let y = 0; y < image.height; y += 1) {
		for (let x = 0; x < image.width; x += 1) {
			const offset = getPixelOffset(image, x, y);
			const alpha = image.data[offset + 3];
			if (alpha === 0) {
				if (image.data[offset] !== 0 || image.data[offset + 1] !== 0 || image.data[offset + 2] !== 0) {
					clearedTransparentPixels += 1;
				}
				image.data[offset] = 0;
				image.data[offset + 1] = 0;
				image.data[offset + 2] = 0;
				continue;
			}
			const red = image.data[offset];
			const green = image.data[offset + 1];
			const blue = image.data[offset + 2];
			const greenDominant = green > red + 8 && green > blue + 8;
			const backgroundLike = greenDominant && red < 96 && blue < 96 && hasTransparentNeighbor(image, x, y);
			if (!backgroundLike) continue;
			if (green < greenFringeDarkCutoff) {
				image.data[offset] = 0;
				image.data[offset + 1] = 0;
				image.data[offset + 2] = 0;
				image.data[offset + 3] = 0;
				removedGreenFringePixels += 1;
			} else {
				image.data[offset + 1] = Math.max(red, blue);
				despilledGreenFringePixels += 1;
			}
		}
	}
	const bledTransparentPixels = bleedTransparentPixelColors(image);
	return {
		removedGreenFringePixels,
		despilledGreenFringePixels,
		clearedTransparentPixels,
		bledTransparentPixels,
	};
};

const copyPixel = (source, sx, sy, target, tx, ty) => {
	if (tx < 0 || ty < 0 || tx >= target.width || ty >= target.height) return;
	const srcOffset = (sy * source.width + sx) * 4;
	const dstOffset = (ty * target.width + tx) * 4;
	target.data[dstOffset] = source.data[srcOffset];
	target.data[dstOffset + 1] = source.data[srcOffset + 1];
	target.data[dstOffset + 2] = source.data[srcOffset + 2];
	target.data[dstOffset + 3] = source.data[srcOffset + 3];
};

const normalizeRect = (rect, image) => {
	const x = clampInteger(rect?.x, 0, Math.max(0, image.width - 1));
	const y = clampInteger(rect?.y, 0, Math.max(0, image.height - 1));
	const width = clampInteger(rect?.width, 1, Math.max(1, image.width - x));
	const height = clampInteger(rect?.height, 1, Math.max(1, image.height - y));
	return { x, y, width, height };
};

export const analyzeFrame = (image, frame, options = {}) => {
	const alphaThreshold = options.alphaThreshold ?? DEFAULT_ALPHA_THRESHOLD;
	const rect = normalizeRect(frame.rect, image);
	const xs = [];
	const ys = [];
	let sumX = 0;
	let sumY = 0;
	for (let y = rect.y; y < rect.y + rect.height; y += 1) {
		for (let x = rect.x; x < rect.x + rect.width; x += 1) {
			if (getAlpha(image, x, y) > alphaThreshold) {
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
		return { frame, index: frame.index, rect, empty: true, opaquePixels: 0 };
	}
	const left = Math.min(...xs);
	const right = Math.max(...xs);
	const top = Math.min(...ys);
	const bottom = Math.max(...ys);
	const height = bottom - top + 1;
	const lowerTop = Math.max(top, bottom - Math.max(3, Math.round(height * 0.3)) + 1);
	const lowerXs = [];
	for (let y = rect.y + lowerTop; y <= rect.y + bottom; y += 1) {
		for (let x = rect.x + left; x <= rect.x + right; x += 1) {
			if (getAlpha(image, x, y) > alphaThreshold) lowerXs.push(x - rect.x);
		}
	}
	const bboxCenterX = (left + right) / 2;
	return {
		frame,
		index: frame.index,
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

export const analyzeFrameTransition = (image, fromFrame, toFrame, options = {}) => {
	const alphaThreshold = options.alphaThreshold ?? DEFAULT_ALPHA_THRESHOLD;
	const fromRect = normalizeRect(fromFrame.rect, image);
	const toRect = normalizeRect(toFrame.rect, image);
	const width = Math.min(fromRect.width, toRect.width);
	const height = Math.min(fromRect.height, toRect.height);
	let intersectionPixels = 0;
	let unionPixels = 0;
	let changedPixels = 0;
	let rgbaDeltaSum = 0;
	for (let localY = 0; localY < height; localY += 1) {
		for (let localX = 0; localX < width; localX += 1) {
			const fromOffset = getPixelOffset(image, fromRect.x + localX, fromRect.y + localY);
			const toOffset = getPixelOffset(image, toRect.x + localX, toRect.y + localY);
			const fromVisible = image.data[fromOffset + 3] > alphaThreshold;
			const toVisible = image.data[toOffset + 3] > alphaThreshold;
			if (!fromVisible && !toVisible) continue;
			unionPixels += 1;
			if (fromVisible && toVisible) intersectionPixels += 1;
			const dr = Math.abs(image.data[fromOffset] - image.data[toOffset]);
			const dg = Math.abs(image.data[fromOffset + 1] - image.data[toOffset + 1]);
			const db = Math.abs(image.data[fromOffset + 2] - image.data[toOffset + 2]);
			const da = Math.abs(image.data[fromOffset + 3] - image.data[toOffset + 3]);
			const delta = dr + dg + db + da;
			rgbaDeltaSum += delta;
			if (delta > 32) changedPixels += 1;
		}
	}
	const maskIoU = unionPixels > 0 ? intersectionPixels / unionPixels : 1;
	const meanAbsRgba = unionPixels > 0 ? rgbaDeltaSum / (unionPixels * 4) : 0;
	const changedPixelRatio = unionPixels > 0 ? changedPixels / unionPixels : 0;
	const motionScore = (1 - maskIoU) + (meanAbsRgba / 255);
	return {
		fromFrameIndex: fromFrame.index,
		toFrameIndex: toFrame.index,
		isLoop: Boolean(options.isLoop),
		compareWidth: width,
		compareHeight: height,
		maskIoU: roundMetric(maskIoU),
		meanAbsRgba: roundMetric(meanAbsRgba, 2),
		changedPixelRatio: roundMetric(changedPixelRatio),
		motionScore: roundMetric(motionScore),
		unionPixels,
	};
};

export const analyzeTemporalContinuity = (image, frames, options = {}) => {
	const alphaThreshold = options.alphaThreshold ?? DEFAULT_ALPHA_THRESHOLD;
	const duplicateMotionScore = options.duplicateMotionScore ?? DEFAULT_DUPLICATE_MOTION_SCORE;
	if (frames.length < 2) {
		return {
			pairs: [],
			duplicatePairs: [],
			minMotionScore: 0,
			maxMotionScore: 0,
			medianMotionScore: 0,
			nonLoopMedianMotionScore: 0,
			motionImbalanceRatio: 0,
			loopMotionScore: 0,
			loopSpikeRatio: 0,
		};
	}
	const pairs = [];
	for (let index = 0; index < frames.length; index += 1) {
		const nextIndex = (index + 1) % frames.length;
		pairs.push(analyzeFrameTransition(image, frames[index], frames[nextIndex], {
			alphaThreshold,
			isLoop: nextIndex === 0,
		}));
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

export const readImageSpriteDocument = (spriteJsonPath) => {
	const document = JSON.parse(fs.readFileSync(spriteJsonPath, 'utf8'));
	assert(document && document.type === 'dora.imageSprite', `${spriteJsonPath} is not a dora.imageSprite document`);
	assert(Array.isArray(document.actions) && document.actions.length > 0, `${spriteJsonPath} has no actions`);
	return document;
};

export const selectAction = (document, actionSelector) => {
	if (actionSelector === undefined || actionSelector === '') return document.actions[document.selectedAction] ?? document.actions[0];
	const index = Number(actionSelector);
	if (Number.isInteger(index)) return document.actions[index];
	return document.actions.find((action) => action.id === actionSelector || action.name === actionSelector);
};

export const evaluateImageSprite = (spriteJsonPath, options = {}) => {
	const alphaThreshold = options.alphaThreshold ?? DEFAULT_ALPHA_THRESHOLD;
	const passBottomJitterPx = options.passBottomJitterPx ?? DEFAULT_PASS_BOTTOM_JITTER;
	const passAnchorXJitterPx = options.passAnchorXJitterPx ?? DEFAULT_PASS_ANCHOR_X_JITTER;
	const fixableShiftPx = options.fixableShiftPx ?? DEFAULT_FIXABLE_SHIFT;
	const failBottomJitterPx = options.failBottomJitterPx ?? DEFAULT_FAIL_BOTTOM_JITTER;
	const failAnchorXJitterPx = options.failAnchorXJitterPx ?? DEFAULT_FAIL_ANCHOR_X_JITTER;
	const duplicateMotionScore = options.duplicateMotionScore ?? DEFAULT_DUPLICATE_MOTION_SCORE;
	const minNonStaticMotionScore = options.minNonStaticMotionScore ?? DEFAULT_MIN_NON_STATIC_MOTION_SCORE;
	const maxMotionImbalanceRatio = options.maxMotionImbalanceRatio ?? DEFAULT_MAX_MOTION_IMBALANCE_RATIO;
	const maxLoopSpikeRatio = options.maxLoopSpikeRatio ?? DEFAULT_MAX_LOOP_SPIKE_RATIO;
	const document = readImageSpriteDocument(spriteJsonPath);
	const action = selectAction(document, options.action);
	assert(action, `action not found: ${options.action ?? document.selectedAction ?? 0}`);
	assert(action.image || options.imagePath, `action ${action.id} does not reference an image`);
	const spriteDir = path.dirname(spriteJsonPath);
	const imagePath = options.imagePath ? path.resolve(options.imagePath) : path.resolve(spriteDir, action.image);
	const image = readPngRgba(imagePath);
	const issues = [];
	const warnings = [];
	if (Number.isFinite(action.imageWidth) && action.imageWidth !== image.width) {
		issues.push(`metadata imageWidth=${action.imageWidth} but PNG width=${image.width}`);
	}
	if (Number.isFinite(action.imageHeight) && action.imageHeight !== image.height) {
		issues.push(`metadata imageHeight=${action.imageHeight} but PNG height=${image.height}`);
	}
	if (!Array.isArray(action.frames) || action.frames.length === 0) {
		issues.push(`action ${action.id} has no frames`);
	}
	const frames = (action.frames ?? []).map((frame, index) => ({ ...frame, index }));
	const analyses = frames.map((frame) => analyzeFrame(image, frame, { alphaThreshold }));
	for (const analysis of analyses) {
		if (analysis.empty) issues.push(`frame ${analysis.index + 1} has no visible pixels`);
	}
	const visible = analyses.filter((analysis) => !analysis.empty);
	const bottoms = visible.map((analysis) => analysis.anchor.y);
	const anchorXs = visible.map((analysis) => analysis.anchor.x);
	const bboxCenterXs = visible.map((analysis) => analysis.bboxCenterX);
	const centroidXs = visible.map((analysis) => analysis.centroid.x);
	const temporal = analyzeTemporalContinuity(image, frames, { alphaThreshold, duplicateMotionScore });
	const metrics = {
		frameCount: frames.length,
		visibleFrameCount: visible.length,
		imageWidth: image.width,
		imageHeight: image.height,
		alphaThreshold,
		bottomJitterPx: range(bottoms),
		anchorXJitterPx: range(anchorXs),
		bboxCenterXJitterPx: range(bboxCenterXs),
		centroidXJitterPx: range(centroidXs),
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
		dx: Math.round(reference.anchorX - analysis.anchor.x),
		dy: Math.round(reference.anchorY - analysis.anchor.y),
	}));
	metrics.maxSuggestedShiftPx = shifts.reduce((max, shift) => Math.max(max, Math.abs(shift.dx), Math.abs(shift.dy)), 0);
	if (visible.length !== frames.length) {
		issues.push(`only ${visible.length}/${frames.length} frames contain visible pixels`);
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
	const transitionLabel = (pair) => `F${pair.fromFrameIndex + 1}->F${pair.toFrameIndex + 1}`;
	if (hasNonStaticMotion && temporal.duplicatePairs.length > 0) {
		issues.push(`near-duplicate transition(s) ${temporal.duplicatePairs.map(transitionLabel).join(', ')} while other transitions move; regenerate frames or add in-betweens`);
	}
	if (hasNonStaticMotion && metrics.temporalMotionImbalanceRatio > maxMotionImbalanceRatio) {
		issues.push(`temporal motion imbalance ${metrics.temporalMotionImbalanceRatio.toFixed(2)}x exceeds threshold ${maxMotionImbalanceRatio}x; frame pacing is visually uneven`);
	}
	if (hasNonStaticMotion && metrics.loopSpikeRatio > maxLoopSpikeRatio) {
		issues.push(`loop transition spike ${metrics.loopSpikeRatio.toFixed(2)}x exceeds threshold ${maxLoopSpikeRatio}x; first/last frames do not close the cycle smoothly`);
	}
	const needsFix = warnings.length > 0;
	const fixable = issues.length === 0 && needsFix && metrics.maxSuggestedShiftPx <= fixableShiftPx;
	let status = 'pass';
	if (issues.length > 0) status = 'fail';
	else if (needsFix) status = fixable ? 'fixable' : 'fail';
	if (needsFix && !fixable && status === 'fail' && metrics.maxSuggestedShiftPx > fixableShiftPx) {
		issues.push(`suggested registration shift ${metrics.maxSuggestedShiftPx}px exceeds fixable threshold ${fixableShiftPx}px; regenerate recommended`);
	}
	return {
		status,
		ok: status === 'pass',
		fixable,
		spriteJsonPath: path.resolve(spriteJsonPath),
		imagePath,
		action: {
			id: action.id,
			name: action.name,
			fps: action.fps,
			direction: action.direction,
			image: action.image,
		},
		metrics,
		reference,
		shifts,
		temporalPairs: temporal.pairs,
		frames: analyses.map((analysis) => analysis.empty ? {
			index: analysis.index,
			empty: true,
			rect: analysis.rect,
		} : {
			index: analysis.index,
			empty: false,
			rect: analysis.rect,
			bbox: analysis.bbox,
			anchor: analysis.anchor,
			bboxCenterX: analysis.bboxCenterX,
			centroid: analysis.centroid,
			opaquePixels: analysis.opaquePixels,
			fillRatio: analysis.fillRatio,
		}),
		warnings,
		issues,
		thresholds: {
			passBottomJitterPx,
			passAnchorXJitterPx,
			fixableShiftPx,
			failBottomJitterPx,
			failAnchorXJitterPx,
			duplicateMotionScore,
			minNonStaticMotionScore,
			maxMotionImbalanceRatio,
			maxLoopSpikeRatio,
		},
	};
};

export const writeAlignedImageSprite = (spriteJsonPath, outputImagePath, options = {}) => {
	const evaluation = evaluateImageSprite(spriteJsonPath, options);
	const source = readPngRgba(evaluation.imagePath);
	const target = {
		width: source.width,
		height: source.height,
		data: new Uint8Array(source.width * source.height * 4),
	};
	const shiftByFrame = new Map(evaluation.shifts.map((shift) => [shift.frameIndex, shift]));
	for (const frame of evaluation.frames) {
		if (frame.empty) continue;
		const shift = shiftByFrame.get(frame.index) ?? { dx: 0, dy: 0 };
		const rect = frame.rect;
		for (let localY = 0; localY < rect.height; localY += 1) {
			for (let localX = 0; localX < rect.width; localX += 1) {
				const sx = rect.x + localX;
				const sy = rect.y + localY;
				const tx = rect.x + localX + shift.dx;
				const ty = rect.y + localY + shift.dy;
				if (tx < rect.x || tx >= rect.x + rect.width || ty < rect.y || ty >= rect.y + rect.height) continue;
				copyPixel(source, sx, sy, target, tx, ty);
			}
		}
	}
	cleanImageSpriteEdges(target);
	writePngRgba(outputImagePath, target);
	return {
		...evaluation,
		outputImagePath: path.resolve(outputImagePath),
	};
};
