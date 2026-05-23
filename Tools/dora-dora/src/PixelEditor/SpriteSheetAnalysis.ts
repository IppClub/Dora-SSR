/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

export interface RgbColor {
	r: number;
	g: number;
	b: number;
}

export interface PixelRect {
	x: number;
	y: number;
	width: number;
	height: number;
}

export interface SpriteSheetFrameRegion {
	index: number;
	row: number;
	column: number;
	bounds: PixelRect;
	slot: PixelRect;
	centerX: number;
	centerY: number;
	bottomY: number;
	area: number;
}

export interface SpriteSheetAnalysisResult {
	width: number;
	height: number;
	background: RgbColor;
	regions: SpriteSheetFrameRegion[];
	rowCount: number;
}

interface ComponentBounds {
	x: number;
	y: number;
	width: number;
	height: number;
	area: number;
	centerX: number;
	centerY: number;
	bottomY: number;
}

interface FrameRegionRow {
	centerY: number;
	regions: SpriteSheetFrameRegion[];
}

interface ColorBucket {
	count: number;
	r: number;
	g: number;
	b: number;
}

const foregroundDistanceThreshold = 28;
const componentDilationRadius = 1;
const maximumFrameRegions = 128;

const clampInteger = (value: number, min: number, max: number) => {
	if (!Number.isFinite(value)) return min;
	return Math.max(min, Math.min(max, Math.round(value)));
};

const getPixelOffset = (width: number, x: number, y: number) => (y * width + x) * 4;

const colorDistanceSquared = (red: number, green: number, blue: number, background: RgbColor) => {
	const dr = red - background.r;
	const dg = green - background.g;
	const db = blue - background.b;
	return dr * dr + dg * dg + db * db;
};

const normalizeRect = (rect: PixelRect, width: number, height: number): PixelRect => {
	const x = clampInteger(rect.x, 0, Math.max(0, width - 1));
	const y = clampInteger(rect.y, 0, Math.max(0, height - 1));
	const right = clampInteger(rect.x + rect.width, x + 1, width);
	const bottom = clampInteger(rect.y + rect.height, y + 1, height);
	return {
		x,
		y,
		width: Math.max(1, right - x),
		height: Math.max(1, bottom - y),
	};
};

const createImageElement = (source: string) => {
	return new Promise<HTMLImageElement>((resolve, reject) => {
		const image = new Image();
		image.onload = () => resolve(image);
		image.onerror = () => reject(new Error("failed to decode sprite sheet image"));
		image.src = source;
	});
};

export const loadImageDataFromSource = async (source: string) => {
	const image = await createImageElement(source);
	const canvas = window.document.createElement("canvas");
	canvas.width = image.naturalWidth;
	canvas.height = image.naturalHeight;
	const context = canvas.getContext("2d", { willReadFrequently: true });
	if (context === null) {
		throw new Error("failed to create sprite sheet analysis context");
	}
	context.imageSmoothingEnabled = false;
	context.drawImage(image, 0, 0);
	return context.getImageData(0, 0, canvas.width, canvas.height);
};

const addColorBucket = (buckets: Map<string, ColorBucket>, data: Uint8ClampedArray, offset: number) => {
	const alpha = data[offset + 3];
	if (alpha < 32) return;
	const red = data[offset];
	const green = data[offset + 1];
	const blue = data[offset + 2];
	const key = `${red >> 3},${green >> 3},${blue >> 3}`;
	const bucket = buckets.get(key);
	if (bucket === undefined) {
		buckets.set(key, {
			count: 1,
			r: red,
			g: green,
			b: blue,
		});
		return;
	}
	bucket.count += 1;
	bucket.r += red;
	bucket.g += green;
	bucket.b += blue;
};

export const detectDominantEdgeColor = (imageData: ImageData, rect?: PixelRect): RgbColor => {
	const bounds = rect === undefined ?
		{ x: 0, y: 0, width: imageData.width, height: imageData.height } :
		normalizeRect(rect, imageData.width, imageData.height);
	const { data, width } = imageData;
	const buckets = new Map<string, ColorBucket>();
	const right = bounds.x + bounds.width - 1;
	const bottom = bounds.y + bounds.height - 1;
	for (let x = bounds.x; x <= right; x++) {
		addColorBucket(buckets, data, getPixelOffset(width, x, bounds.y));
		addColorBucket(buckets, data, getPixelOffset(width, x, bottom));
	}
	for (let y = bounds.y + 1; y < bottom; y++) {
		addColorBucket(buckets, data, getPixelOffset(width, bounds.x, y));
		addColorBucket(buckets, data, getPixelOffset(width, right, y));
	}
	let bestBucket: ColorBucket | undefined;
	buckets.forEach((bucket) => {
		if (bestBucket === undefined || bucket.count > bestBucket.count) {
			bestBucket = bucket;
		}
	});
	if (bestBucket === undefined || bestBucket.count === 0) {
		return { r: 0, g: 0, b: 0 };
	}
	return {
		r: bestBucket.r / bestBucket.count,
		g: bestBucket.g / bestBucket.count,
		b: bestBucket.b / bestBucket.count,
	};
};

export const isForegroundPixel = (imageData: ImageData, pixelIndex: number, background: RgbColor, threshold = foregroundDistanceThreshold) => {
	const offset = pixelIndex * 4;
	const alpha = imageData.data[offset + 3];
	if (alpha < 32) return false;
	const red = imageData.data[offset];
	const green = imageData.data[offset + 1];
	const blue = imageData.data[offset + 2];
	return colorDistanceSquared(red, green, blue, background) > threshold * threshold;
};

const buildForegroundMask = (imageData: ImageData, background: RgbColor) => {
	const pixelCount = imageData.width * imageData.height;
	const mask = new Uint8Array(pixelCount);
	for (let index = 0; index < pixelCount; index++) {
		if (isForegroundPixel(imageData, index, background)) {
			mask[index] = 1;
		}
	}
	return mask;
};

const dilateMask = (mask: Uint8Array, width: number, height: number, radius: number) => {
	if (radius <= 0) return mask;
	const output = new Uint8Array(mask.length);
	for (let y = 0; y < height; y++) {
		for (let x = 0; x < width; x++) {
			const index = y * width + x;
			if (mask[index] === 0) continue;
			for (let offsetY = -radius; offsetY <= radius; offsetY++) {
				for (let offsetX = -radius; offsetX <= radius; offsetX++) {
					const nextX = x + offsetX;
					const nextY = y + offsetY;
					if (nextX < 0 || nextY < 0 || nextX >= width || nextY >= height) continue;
					output[nextY * width + nextX] = 1;
				}
			}
		}
	}
	return output;
};

const createComponent = (
	x: number,
	y: number,
	width: number,
	height: number,
	area: number,
): ComponentBounds => ({
	x,
	y,
	width,
	height,
	area,
	centerX: x + width / 2,
	centerY: y + height / 2,
	bottomY: y + height,
});

const findConnectedComponents = (foregroundMask: Uint8Array, traversalMask: Uint8Array, width: number, height: number) => {
	const visited = new Uint8Array(traversalMask.length);
	const components: ComponentBounds[] = [];
	const stack: number[] = [];
	for (let startIndex = 0; startIndex < traversalMask.length; startIndex++) {
		if (traversalMask[startIndex] === 0 || visited[startIndex] !== 0) continue;
		let minX = width;
		let minY = height;
		let maxX = -1;
		let maxY = -1;
		let originalArea = 0;
		visited[startIndex] = 1;
		stack.push(startIndex);
		while (stack.length > 0) {
			const index = stack.pop();
			if (index === undefined) break;
			const x = index % width;
			const y = Math.floor(index / width);
			if (foregroundMask[index] !== 0) {
				originalArea += 1;
				minX = Math.min(minX, x);
				minY = Math.min(minY, y);
				maxX = Math.max(maxX, x);
				maxY = Math.max(maxY, y);
			}
			const neighbours = [
				x > 0 ? index - 1 : -1,
				x + 1 < width ? index + 1 : -1,
				y > 0 ? index - width : -1,
				y + 1 < height ? index + width : -1,
			];
			for (const neighbour of neighbours) {
				if (neighbour < 0 || traversalMask[neighbour] === 0 || visited[neighbour] !== 0) continue;
				visited[neighbour] = 1;
				stack.push(neighbour);
			}
		}
		if (originalArea === 0) continue;
		components.push(createComponent(minX, minY, maxX - minX + 1, maxY - minY + 1, originalArea));
	}
	return components;
};

const medianNumber = (values: number[], fallback: number) => {
	if (values.length === 0) return fallback;
	const sorted = [...values].sort((left, right) => left - right);
	const middle = Math.floor(sorted.length / 2);
	return sorted.length % 2 === 0 ? (sorted[middle - 1] + sorted[middle]) / 2 : sorted[middle];
};

const filterSpriteComponents = (components: ComponentBounds[], width: number, height: number) => {
	const imageArea = width * height;
	const minimumArea = Math.max(8, Math.round(imageArea * 0.00018));
	const maximumArea = Math.round(imageArea * 0.25);
	return components.filter((component) => {
		if (component.area < minimumArea || component.area > maximumArea) return false;
		if (component.width < 3 || component.height < 3) return false;
		return true;
	});
};

const groupFrameRows = (regions: SpriteSheetFrameRegion[]) => {
	const medianHeight = medianNumber(regions.map((region) => region.bounds.height), 12);
	const threshold = Math.max(4, medianHeight * 0.65);
	const rows: FrameRegionRow[] = [];
	const sorted = [...regions].sort((left, right) => left.centerY - right.centerY || left.centerX - right.centerX);
	for (const region of sorted) {
		const row = rows.find((item) => Math.abs(item.centerY - region.centerY) <= threshold);
		if (row === undefined) {
			rows.push({ centerY: region.centerY, regions: [region] });
			continue;
		}
		row.regions.push(region);
		row.centerY = row.regions.reduce((sum, item) => sum + item.centerY, 0) / row.regions.length;
	}
	rows.sort((left, right) => left.centerY - right.centerY);
	rows.forEach((row) => {
		row.regions.sort((left, right) => left.centerX - right.centerX);
	});
	return rows;
};

const applySlotBounds = (rows: FrameRegionRow[], width: number, height: number) => {
	rows.forEach((row, rowIndex) => {
		const previousRow = rows[rowIndex - 1];
		const nextRow = rows[rowIndex + 1];
		const top = previousRow === undefined ? 0 : clampInteger((previousRow.centerY + row.centerY) / 2, 0, height - 1);
		const bottom = nextRow === undefined ? height : clampInteger((row.centerY + nextRow.centerY) / 2, top + 1, height);
		row.regions.forEach((region, columnIndex) => {
			const previousRegion = row.regions[columnIndex - 1];
			const nextRegion = row.regions[columnIndex + 1];
			const left = previousRegion === undefined ? 0 : clampInteger((previousRegion.centerX + region.centerX) / 2, 0, width - 1);
			const right = nextRegion === undefined ? width : clampInteger((region.centerX + nextRegion.centerX) / 2, left + 1, width);
			region.row = rowIndex;
			region.column = columnIndex;
			region.slot = {
				x: left,
				y: top,
				width: right - left,
				height: bottom - top,
			};
		});
	});
};

export const findForegroundBoundsInRect = (
	imageData: ImageData,
	rect: PixelRect,
	background: RgbColor,
	threshold = foregroundDistanceThreshold,
) => {
	const bounds = normalizeRect(rect, imageData.width, imageData.height);
	let minX = imageData.width;
	let minY = imageData.height;
	let maxX = -1;
	let maxY = -1;
	let area = 0;
	const right = bounds.x + bounds.width;
	const bottom = bounds.y + bounds.height;
	for (let y = bounds.y; y < bottom; y++) {
		for (let x = bounds.x; x < right; x++) {
			const pixelIndex = y * imageData.width + x;
			if (!isForegroundPixel(imageData, pixelIndex, background, threshold)) continue;
			area += 1;
			minX = Math.min(minX, x);
			minY = Math.min(minY, y);
			maxX = Math.max(maxX, x);
			maxY = Math.max(maxY, y);
		}
	}
	if (area === 0) return undefined;
	return createComponent(minX, minY, maxX - minX + 1, maxY - minY + 1, area);
};

export const analyzeReferenceSpriteSheet = async (source: string): Promise<SpriteSheetAnalysisResult> => {
	const imageData = await loadImageDataFromSource(source);
	const background = detectDominantEdgeColor(imageData);
	const foregroundMask = buildForegroundMask(imageData, background);
	const traversalMask = dilateMask(foregroundMask, imageData.width, imageData.height, componentDilationRadius);
	const components = filterSpriteComponents(
		findConnectedComponents(foregroundMask, traversalMask, imageData.width, imageData.height),
		imageData.width,
		imageData.height,
	);
	if (components.length === 0) {
		throw new Error("motion reference sheet did not contain detectable sprite poses");
	}
	const regions = components
		.sort((left, right) => left.centerY - right.centerY || left.centerX - right.centerX)
		.slice(0, maximumFrameRegions)
		.map<SpriteSheetFrameRegion>((component, index) => ({
			index,
			row: 0,
			column: 0,
			bounds: {
				x: component.x,
				y: component.y,
				width: component.width,
				height: component.height,
			},
			slot: {
				x: component.x,
				y: component.y,
				width: component.width,
				height: component.height,
			},
			centerX: component.centerX,
			centerY: component.centerY,
			bottomY: component.bottomY,
			area: component.area,
		}));
	const rows = groupFrameRows(regions);
	applySlotBounds(rows, imageData.width, imageData.height);
	const orderedRegions = rows
		.flatMap((row) => row.regions)
		.map((region, index) => ({ ...region, index }));
	return {
		width: imageData.width,
		height: imageData.height,
		background,
		regions: orderedRegions,
		rowCount: rows.length,
	};
};

export const selectLargestSpriteSheetRegions = (
	analysis: SpriteSheetAnalysisResult,
	expectedFrameCount: number,
): SpriteSheetAnalysisResult => {
	const frameCount = clampInteger(expectedFrameCount, 1, maximumFrameRegions);
	const selectedRegions = [...analysis.regions]
		.sort((left, right) => right.area - left.area)
		.slice(0, frameCount)
		.map<SpriteSheetFrameRegion>((region, index) => ({
			...region,
			index,
			row: 0,
			column: 0,
			slot: {
				x: region.bounds.x,
				y: region.bounds.y,
				width: region.bounds.width,
				height: region.bounds.height,
			},
		}));
	const rows = groupFrameRows(selectedRegions);
	applySlotBounds(rows, analysis.width, analysis.height);
	const orderedRegions = rows
		.flatMap((row) => row.regions)
		.map((region, index) => ({ ...region, index }));
	return {
		...analysis,
		regions: orderedRegions,
		rowCount: rows.length,
	};
};
