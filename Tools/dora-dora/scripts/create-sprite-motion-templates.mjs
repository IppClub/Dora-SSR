/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import fs from 'node:fs';
import path from 'node:path';
import zlib from 'node:zlib';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const outputDir = path.resolve(__dirname, '../public/pixel-templates');
const width = 256;
const height = 256;
const cellSize = 64;

const colors = {
	background: [0, 255, 0, 255],
	outline: [35, 38, 42, 255],
	body: [176, 182, 191, 255],
	bodyDark: [121, 127, 136, 255],
	head: [196, 202, 210, 255],
	face: [45, 48, 52, 255],
	accent: [236, 240, 245, 255],
};

const makeCrcTable = () => {
	const table = new Uint32Array(256);
	for (let index = 0; index < 256; index++) {
		let value = index;
		for (let bit = 0; bit < 8; bit++) {
			value = (value & 1) !== 0 ? 0xedb88320 ^ (value >>> 1) : value >>> 1;
		}
		table[index] = value >>> 0;
	}
	return table;
};

const crcTable = makeCrcTable();

const crc32 = (buffer) => {
	let crc = 0xffffffff;
	for (const byte of buffer) {
		crc = crcTable[(crc ^ byte) & 0xff] ^ (crc >>> 8);
	}
	return (crc ^ 0xffffffff) >>> 0;
};

const chunk = (type, data) => {
	const typeBuffer = Buffer.from(type, 'ascii');
	const length = Buffer.alloc(4);
	length.writeUInt32BE(data.length, 0);
	const checksum = Buffer.alloc(4);
	checksum.writeUInt32BE(crc32(Buffer.concat([typeBuffer, data])), 0);
	return Buffer.concat([length, typeBuffer, data, checksum]);
};

const encodePng = (pixels) => {
	const signature = Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]);
	const ihdr = Buffer.alloc(13);
	ihdr.writeUInt32BE(width, 0);
	ihdr.writeUInt32BE(height, 4);
	ihdr[8] = 8;
	ihdr[9] = 6;
	ihdr[10] = 0;
	ihdr[11] = 0;
	ihdr[12] = 0;
	const stride = width * 4;
	const raw = Buffer.alloc((stride + 1) * height);
	for (let y = 0; y < height; y++) {
		raw[y * (stride + 1)] = 0;
		pixels.copy(raw, y * (stride + 1) + 1, y * stride, (y + 1) * stride);
	}
	return Buffer.concat([
		signature,
		chunk('IHDR', ihdr),
		chunk('IDAT', zlib.deflateSync(raw, { level: 9 })),
		chunk('IEND', Buffer.alloc(0)),
	]);
};

const createBuffer = () => {
	const pixels = Buffer.alloc(width * height * 4);
	for (let offset = 0; offset < pixels.length; offset += 4) {
		pixels[offset] = colors.background[0];
		pixels[offset + 1] = colors.background[1];
		pixels[offset + 2] = colors.background[2];
		pixels[offset + 3] = colors.background[3];
	}
	return pixels;
};

const putPixel = (pixels, x, y, color) => {
	if (x < 0 || x >= width || y < 0 || y >= height) return;
	const offset = (Math.round(y) * width + Math.round(x)) * 4;
	pixels[offset] = color[0];
	pixels[offset + 1] = color[1];
	pixels[offset + 2] = color[2];
	pixels[offset + 3] = color[3];
};

const fillRect = (pixels, x, y, rectWidth, rectHeight, color) => {
	const startX = Math.max(0, Math.floor(x));
	const startY = Math.max(0, Math.floor(y));
	const endX = Math.min(width, Math.ceil(x + rectWidth));
	const endY = Math.min(height, Math.ceil(y + rectHeight));
	for (let yy = startY; yy < endY; yy++) {
		for (let xx = startX; xx < endX; xx++) putPixel(pixels, xx, yy, color);
	}
};

const fillCircle = (pixels, centerX, centerY, radius, color) => {
	const radiusSquared = radius * radius;
	for (let y = Math.floor(centerY - radius); y <= Math.ceil(centerY + radius); y++) {
		for (let x = Math.floor(centerX - radius); x <= Math.ceil(centerX + radius); x++) {
			const dx = x - centerX;
			const dy = y - centerY;
			if (dx * dx + dy * dy <= radiusSquared) putPixel(pixels, x, y, color);
		}
	}
};

const drawLine = (pixels, x1, y1, x2, y2, color, thickness = 2) => {
	const steps = Math.max(Math.abs(x2 - x1), Math.abs(y2 - y1), 1);
	for (let step = 0; step <= steps; step++) {
		const t = step / steps;
		const x = x1 + (x2 - x1) * t;
		const y = y1 + (y2 - y1) * t;
		fillCircle(pixels, x, y, thickness, color);
	}
};

const drawMannequin = (pixels, facing, frameIndex) => {
	const cellX = frameIndex * cellSize;
	const centerX = cellX + 32;
	const bob = [0, -1, 0, 1][frameIndex] ?? 0;
	const sway = [-1, 0, 1, 0][frameIndex] ?? 0;
	const topY = 77 + bob;
	const headY = topY + 9;
	const torsoY = topY + 23;
	const footY = topY + 57;

	if (facing === 'front' || facing === 'back') {
		fillCircle(pixels, centerX, headY, 10, colors.outline);
		fillCircle(pixels, centerX, headY, 8, colors.head);
		fillRect(pixels, centerX - 9, torsoY - 1, 18, 22, colors.outline);
		fillRect(pixels, centerX - 7, torsoY + 1, 14, 18, colors.body);
		drawLine(pixels, centerX - 9, torsoY + 4, centerX - 17 - sway, torsoY + 25, colors.outline, 2);
		drawLine(pixels, centerX + 9, torsoY + 4, centerX + 17 - sway, torsoY + 25, colors.outline, 2);
		drawLine(pixels, centerX - 4, torsoY + 20, centerX - 11 - sway, footY, colors.outline, 3);
		drawLine(pixels, centerX + 4, torsoY + 20, centerX + 11 - sway, footY, colors.outline, 3);
		if (facing === 'front') {
			fillRect(pixels, centerX - 4, headY - 1, 2, 2, colors.face);
			fillRect(pixels, centerX + 3, headY - 1, 2, 2, colors.face);
			fillRect(pixels, centerX - 5, torsoY + 5, 10, 3, colors.accent);
		} else {
			fillRect(pixels, centerX - 8, headY - 7, 16, 6, colors.bodyDark);
			fillRect(pixels, centerX - 4, torsoY + 3, 8, 16, colors.bodyDark);
		}
		return;
	}

	const direction = facing === 'left' ? -1 : 1;
	fillCircle(pixels, centerX, headY, 10, colors.outline);
	fillCircle(pixels, centerX, headY, 8, colors.head);
	fillRect(pixels, centerX + direction * 7 - (direction < 0 ? 4 : 0), headY - 1, 4, 3, colors.outline);
	fillRect(pixels, centerX + direction * 4, headY - 2, 2, 2, colors.face);
	fillRect(pixels, centerX - 6, torsoY - 1, 12, 22, colors.outline);
	fillRect(pixels, centerX - 4, torsoY + 1, 8, 18, colors.body);
	drawLine(pixels, centerX - direction * 3, torsoY + 5, centerX - direction * 10 - sway, torsoY + 26, colors.outline, 2);
	drawLine(pixels, centerX + direction * 2, torsoY + 20, centerX + direction * 11, footY, colors.outline, 3);
	drawLine(pixels, centerX - direction * 2, torsoY + 20, centerX - direction * 8, footY - 1, colors.outline, 3);
	fillRect(pixels, centerX + direction * 2 - (direction < 0 ? 8 : 0), torsoY + 6, 8, 3, colors.accent);
};

const writeTemplate = (name, facing) => {
	const pixels = createBuffer();
	for (let index = 0; index < 4; index++) drawMannequin(pixels, facing, index);
	fs.writeFileSync(path.join(outputDir, name), encodePng(pixels));
};

fs.mkdirSync(outputDir, { recursive: true });
writeTemplate('idle_front_4_mannequin.png', 'front');
writeTemplate('idle_back_4_mannequin.png', 'back');
writeTemplate('idle_left_4_mannequin.png', 'left');
writeTemplate('idle_right_4_mannequin.png', 'right');
console.log(`Generated sprite motion templates in ${outputDir}`);
