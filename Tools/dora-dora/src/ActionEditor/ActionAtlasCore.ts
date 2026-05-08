import type {ActionClipDocument, ActionClipRect} from "./ActionClip";

export type ActionPackInput = {
	name: string;
	path: string;
	width: number;
	height: number;
};

export type ActionPackedRect = ActionClipRect & {
	sourcePath: string;
};

export type ActionPackResult = {
	width: number;
	height: number;
	rects: ActionPackedRect[];
};

const padding = 2;

const nextPowerOfTwo = (value: number) => {
	let result = 1;
	while (result < value) result *= 2;
	return result;
};

export const packActionImages = (inputs: ActionPackInput[]): ActionPackResult => {
	const sorted = [...inputs].sort((a, b) => Math.max(b.width, b.height) - Math.max(a.width, a.height));
	let x = padding;
	let y = padding;
	let rowHeight = 0;
	const area = sorted.reduce((sum, item) => sum + item.width * item.height, 0);
	const maxWidth = nextPowerOfTwo(Math.max(64, Math.ceil(Math.sqrt(area))));
	const rects: ActionPackedRect[] = [];
	for (const item of sorted) {
		const width = Math.ceil(item.width);
		const height = Math.ceil(item.height);
		if (x + width + padding > maxWidth) {
			x = padding;
			y += rowHeight + padding;
			rowHeight = 0;
		}
		rects.push({
			name: item.name,
			sourcePath: item.path,
			x,
			y,
			width,
			height,
		});
		x += width + padding;
		rowHeight = Math.max(rowHeight, height);
	}
	const height = nextPowerOfTwo(Math.max(64, y + rowHeight + padding));
	return {width: maxWidth, height, rects};
};

export const writePackedActionClip = (textureFile: string, result: ActionPackResult): ActionClipDocument => ({
	textureFile,
	texturePath: textureFile,
	rects: Object.fromEntries(result.rects.map((rect) => [rect.name, {
		name: rect.name,
		x: rect.x,
		y: rect.y,
		width: rect.width,
		height: rect.height,
	}])),
});
