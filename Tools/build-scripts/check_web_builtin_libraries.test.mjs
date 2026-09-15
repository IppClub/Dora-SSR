import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import test from 'node:test';
import {checkBuiltinLibraries, requiredLibraries} from './check_web_builtin_libraries.mjs';

test('validates Emscripten preload paths and bytes, including minified glue', t => {
	const root = fs.mkdtempSync(path.join(os.tmpdir(), 'dora-web-libs-'));
	t.after(() => fs.rmSync(root, {recursive: true, force: true}));
	const chunks = [], files = [];
	let start = 0;
	for (const name of requiredLibraries) {
		const bytes = Buffer.from(`return ${JSON.stringify(name)}\n`);
		const file = path.join(root, name);
		fs.mkdirSync(path.dirname(file), {recursive: true});
		fs.writeFileSync(file, bytes);
		files.push({filename: `/builtin/Script/Lib/${name}`, start, end: start + bytes.length});
		chunks.push(bytes);
		start += bytes.length;
	}
	const data = Buffer.concat(chunks);
	const glue = `loadPackage(${JSON.stringify({files})});`;
	checkBuiltinLibraries(glue, data, root);
	checkBuiltinLibraries(glue.replace(/"(filename|start|end|files)":/g, '$1:'), data, root);
	assert.throws(() => checkBuiltinLibraries(JSON.stringify({files: files.slice(1)}), data, root), /missing/);
	assert.throws(() => checkBuiltinLibraries(glue.replace('/builtin/', '/game/'), data, root), /missing/);
	const damaged = Buffer.from(data); damaged[0] ^= 1;
	assert.throws(() => checkBuiltinLibraries(glue, damaged, root), /differs from source/);
	assert.throws(() => checkBuiltinLibraries(glue, data.subarray(0, 1), root), /Invalid preload range/);
});
