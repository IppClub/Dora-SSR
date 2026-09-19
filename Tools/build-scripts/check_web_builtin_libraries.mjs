import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath, pathToFileURL} from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../..');
export const requiredLibraries = [
	'Config.lua', 'utf-8.lua', 'Utils.lua', 'lualib_bundle.lua',
	'UI/Control/Basic/ScrollArea.lua', 'UI/View/Control/Basic/ScrollArea.lua',
	'UI/View/Shape/SolidRect.lua',
];

// Emscripten emits JSON; optimized glue may leave the property names unquoted.
export function checkBuiltinLibraries(glue, data, sourceRoot = path.join(root, 'Assets/Script/Lib')) {
	const entries = new Map();
	const pattern = /\{\s*"?filename"?\s*:\s*"([^"\\]+)"\s*,\s*"?start"?\s*:\s*(\d+)\s*,\s*"?end"?\s*:\s*(\d+)/g;
	for (const match of glue.matchAll(pattern)) {
		assert.ok(!entries.has(match[1]), `Duplicate preload path: ${match[1]}`);
		entries.set(match[1], {start: Number(match[2]), end: Number(match[3])});
	}
	for (const name of requiredLibraries) {
		const filename = `/builtin/Script/Lib/${name}`;
		const entry = entries.get(filename);
		assert.ok(entry, `Web Player builtin Lua library is missing: ${filename}`);
		assert.ok(entry.start >= 0 && entry.end > entry.start && entry.end <= data.length,
			`Invalid preload range: ${filename}`);
		assert.ok(data.subarray(entry.start, entry.end).equals(fs.readFileSync(path.join(sourceRoot, name))),
			`Web Player builtin Lua library differs from source: ${filename}`);
	}
}

if (process.argv[1] && import.meta.url === pathToFileURL(path.resolve(process.argv[1])).href) {
	const output = path.resolve(process.argv[2] || 'result/dora-web-player');
	checkBuiltinLibraries(fs.readFileSync(path.join(output, 'dora-player-runtime.js'), 'utf8'),
		fs.readFileSync(path.join(output, 'dora-player-runtime.data')));
	console.log('[INFO] Web Player builtin Lua libraries verified');
}
