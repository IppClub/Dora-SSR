// Run against a native Dora instance with Web IDE tabs closed.
// Verifies real compiler output, readiness fallback, concurrency and recycling.
import assert from 'node:assert/strict';
import { mkdtemp, writeFile, readFile, rm, access } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';

const base = process.env.DORA_COMPILER_URL ?? 'http://localhost:8866';
const post = async (path, body = {}) => {
	const response = await fetch(base + path, {
		method: 'POST', headers: { 'Content-Type': 'application/json' },
		body: JSON.stringify(body), signal: AbortSignal.timeout(45000),
	});
	assert.equal(response.status, 200, path);
	return response.json();
};
let status;
for (let attempt = 0; attempt < 50; attempt++) {
	try { status = await post('/status'); break; }
	catch (error) {
		if (error.cause?.code !== 'ECONNREFUSED' || attempt === 49) throw error;
		await new Promise(resolve => setTimeout(resolve, 200));
	}
}
assert.equal(status.wsConnectionCount, 0, 'Close Web IDE before running this test');
assert.equal(status.typescriptCompiler.embeddedSupported, true);
const root = await mkdtemp(join(tmpdir(), 'dora-compiler-'));
let socket;
try {
	await writeFile(join(root, 'math.ts'), 'export const value = 42;\n');
	await writeFile(join(root, 'init.ts'), 'import {value} from "math"; export const result = value;\n');
	await writeFile(join(root, 'bad.ts'), 'export const bad: number = "wrong";\n');
	await writeFile(join(root, 'view.tsx'), 'import {React} from "DoraX"; export const view = <node x={42}/>;\n');
	const build = (name = 'init.ts') => post('/ts/build', { path: join(root, name), projectRoot: root });
	const started = Date.now();
	assert.equal((await build()).success, true);
	assert.match(await readFile(join(root, 'init.lua'), 'utf8'), /require\(["']math["']\)/);
	assert.equal((await build('view.tsx')).success, true);
	await access(join(root, 'view.lua'));
	const diagnostic = await build('bad.ts');
	assert.equal(diagnostic.success, false);
	assert.match(diagnostic.messages[0].message, /TS2322/);
	await assert.rejects(access(join(root, 'bad.lua')));
	for (const result of await Promise.all([build(), build(), build()])) assert.equal(result.success, true);

	socket = new WebSocket(base.replace(/^http/, 'ws').replace(/:\d+$/, ':8868'));
	let probeMode = 'unavailable';
	let probes = 0;
	let builds = 0;
	socket.onmessage = async ({ data }) => {
		const message = JSON.parse(typeof data === 'string' ? data : await data.text());
		if (message.name === 'TranspileTSProbe') {
			probes++;
			socket.send(JSON.stringify({ name: message.name, id: message.id, success: probeMode === 'ready' }));
		} else if (message.name === 'TranspileTS') {
			builds++;
			// Deliberately malformed success must fall back to the real WebView.
			socket.send(JSON.stringify({ name: message.name, id: message.id, success: true, luaCode: '' }));
		}
	};
	await new Promise((resolve, reject) => { socket.onopen = resolve; socket.onerror = reject; });
	assert.equal((await build()).success, true, 'Unavailable IDE falls back');
	assert.ok(probes > 0);
	assert.equal((await post('/status')).typescriptCompiler.webIDEReady, false);
	probeMode = 'ready';
	assert.equal((await build()).success, true, 'Missing IDE Lua output falls back');
	assert.ok(builds > 0);
	socket.close();
	await new Promise(resolve => { socket.onclose = resolve; });
	socket = undefined;
	await new Promise(resolve => setTimeout(resolve, 9500));
	const idle = (await post('/status')).typescriptCompiler;
	assert.equal(idle.users, 0);
	assert.equal(idle.queuedJobs, 0);
	assert.equal(idle.embeddedRequested, false, 'Idle WebView is recycled');
	const pending = build();
	let startup;
	for (let attempt = 0; attempt < 100; attempt++) {
		startup = (await post('/status')).typescriptCompiler;
		if (startup.users > 0 && startup.embeddedRequested) break;
		await new Promise(resolve => setTimeout(resolve, 10));
	}
	assert.ok(startup.users > 0, 'Startup request is pending');
	assert.equal((await post('/compiler/failure', { message: 'QA compiler warmup failure' })).success, true);
	const failed = await pending;
	assert.equal(failed.success, false);
	assert.match(failed.messages[0].message, /QA compiler warmup failure/);
	for (let attempt = 0; attempt < 100; attempt++) {
		if (!(await post('/status')).typescriptCompiler.embeddedRequested) break;
		await new Promise(resolve => setTimeout(resolve, 10));
	}
	assert.equal((await build()).success, true, 'Compiler restarts after recycling');
	console.log(`Native compiler verification passed (${status.platform}, ${((Date.now() - started) / 1000).toFixed(1)}s).`);
} finally {
	socket?.close();
	await rm(root, { recursive: true, force: true });
}
