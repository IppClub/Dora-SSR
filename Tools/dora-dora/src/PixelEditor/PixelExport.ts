/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import Info from '../Info';
import * as Service from '../Service';
import type { PixelDocument } from './PixelDocument';

export interface PixelSpriteExportResult {
	texturePath: string;
	metadataPath: string;
}

const { path } = Info;

const removePixelJsonSuffix = (fileName: string) => {
	const suffix = ".pixel.json";
	return fileName.toLowerCase().endsWith(suffix) ? fileName.slice(0, -suffix.length) : path.basename(fileName, path.extname(fileName));
};

const putPixel = (imageData: ImageData, x: number, y: number, width: number, color: string) => {
	const match = /^#([0-9a-fA-F]{6})([0-9a-fA-F]{2})?$/.exec(color);
	if (match === null) return;
	const rgb = match[1];
	const alpha = match[2] ?? "ff";
	const offset = (y * width + x) * 4;
	imageData.data[offset] = Number.parseInt(rgb.slice(0, 2), 16);
	imageData.data[offset + 1] = Number.parseInt(rgb.slice(2, 4), 16);
	imageData.data[offset + 2] = Number.parseInt(rgb.slice(4, 6), 16);
	imageData.data[offset + 3] = Number.parseInt(alpha, 16);
};

const createSpriteSheetBlob = (document: PixelDocument) => new Promise<Blob>((resolve, reject) => {
	const canvas = window.document.createElement('canvas');
	canvas.width = document.width * document.frames.length;
	canvas.height = document.height;
	const context = canvas.getContext('2d');
	if (context === null) {
		reject(new Error('failed to create canvas context'));
		return;
	}
	context.imageSmoothingEnabled = false;
	const imageData = context.createImageData(canvas.width, canvas.height);
	document.frames.forEach((frame, frameIndex) => {
		for (let y = 0; y < document.height; y++) {
			for (let x = 0; x < document.width; x++) {
				const sourceIndex = y * document.width + x;
				const colorIndex = frame.pixels[sourceIndex] ?? 0;
				const color = document.palette[colorIndex] ?? document.palette[0] ?? '#00000000';
				putPixel(imageData, frameIndex * document.width + x, y, canvas.width, color);
			}
		}
	});
	context.putImageData(imageData, 0, 0);
	canvas.toBlob((blob) => {
		if (blob === null) {
			reject(new Error('failed to encode sprite sheet'));
			return;
		}
		resolve(blob);
	}, 'image/png');
});

const uploadBlob = async (directory: string, fileName: string, blob: Blob) => {
	const formData = new FormData();
	formData.append('file', blob, fileName);
	const response = await fetch(Service.addr(`/upload?path=${encodeURIComponent(directory)}`), {
		method: 'POST',
		body: formData,
	});
	if (!response.ok) {
		throw new Error(`upload failed: ${response.status}`);
	}
};

export const exportPixelSprite = async (filePath: string, document: PixelDocument): Promise<PixelSpriteExportResult> => {
	const directory = path.dirname(filePath);
	const baseName = removePixelJsonSuffix(path.basename(filePath));
	const textureName = `${baseName}.sheet.png`;
	const metadataName = `${baseName}.sheet.json`;
	const texturePath = path.join(directory, textureName);
	const metadataPath = path.join(directory, metadataName);
	const spriteSheetBlob = await createSpriteSheetBlob(document);
	await uploadBlob(directory, textureName, spriteSheetBlob);
	const metadata = {
		version: 1,
		texture: textureName,
		frameWidth: document.width,
		frameHeight: document.height,
		frames: document.frames.map((frame, index) => ({
			name: frame.name,
			x: index * document.width,
			y: 0,
			width: document.width,
			height: document.height,
			duration: 1 / document.fps,
		})),
		fps: document.fps,
	};
	const writeResult = await Service.write({ path: metadataPath, content: JSON.stringify(metadata, undefined, "\t") });
	if (!writeResult.success) {
		throw new Error(`failed to write ${metadataName}`);
	}
	Service.emitUpdateFile(texturePath, true);
	Service.emitUpdateFile(metadataPath, true, JSON.stringify(metadata));
	return { texturePath, metadataPath };
};
