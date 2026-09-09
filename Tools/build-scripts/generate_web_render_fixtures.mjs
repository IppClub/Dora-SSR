import fs from "node:fs";
import path from "node:path";
import {deflateSync} from "node:zlib";

const outputDir = path.resolve(process.argv[2] || "build/web-render-fixtures");

function crc32(bytes) {
	let value = 0xffffffff;
	for (const byte of bytes) {
		value ^= byte;
		for (let bit = 0; bit < 8; bit++) value = (value & 1) ? (0xedb88320 ^ (value >>> 1)) : (value >>> 1);
	}
	return (value ^ 0xffffffff) >>> 0;
}

function chunk(type, data) {
	const name = Buffer.from(type, "ascii");
	const result = Buffer.alloc(12 + data.length);
	result.writeUInt32BE(data.length, 0);
	name.copy(result, 4);
	data.copy(result, 8);
	result.writeUInt32BE(crc32(Buffer.concat([name, data])), 8 + data.length);
	return result;
}

function fixturePng(width, height, colors) {
	const rows = Buffer.alloc((width * 4 + 1) * height);
	for (let y = 0; y < height; y++) {
		const row = y * (width * 4 + 1);
		for (let x = 0; x < width; x++) {
			const color = colors[(x >= width / 2 ? 1 : 0) + (y >= height / 2 ? 2 : 0)];
			const offset = row + 1 + x * 4;
			rows[offset] = color[0];
			rows[offset + 1] = color[1];
			rows[offset + 2] = color[2];
			rows[offset + 3] = color[3];
		}
	}
	const header = Buffer.alloc(13);
	header.writeUInt32BE(width, 0);
	header.writeUInt32BE(height, 4);
	header[8] = 8;
	header[9] = 6;
	return Buffer.concat([
		Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]),
		chunk("IHDR", header),
		chunk("IDAT", deflateSync(rows, {level: 9})),
		chunk("IEND", Buffer.alloc(0)),
	]);
}

const fixtures = [
	["Spine/web-spine.png", [[69, 217, 232, 255], [91, 141, 239, 255], [72, 187, 120, 255], [50, 105, 190, 255]]],
	["DragonBones/web-dragon.png", [[255, 112, 151, 255], [255, 209, 102, 255], [239, 91, 91, 255], [245, 158, 66, 255]]],
];
for (const [relative, colors] of fixtures) {
	const destination = path.join(outputDir, relative);
	fs.mkdirSync(path.dirname(destination), {recursive: true});
	fs.writeFileSync(destination, fixturePng(128, 128, colors));
}
console.log(`[INFO] Generated ${fixtures.length} deterministic Web render fixture textures: ${outputDir}`);
