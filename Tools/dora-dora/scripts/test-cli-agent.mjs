import assert from 'node:assert/strict';
import {spawn} from 'node:child_process';
import {createServer} from 'node:http';
import {fileURLToPath} from 'node:url';
import path from 'node:path';

const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(scriptDir, '../../..');
const binary = process.env.DORA_TEST_BIN ?? path.join(root, 'Projects/macOS/build/Debug/Dora.app/Contents/MacOS/Dora');
const asset = path.join(root, 'Assets');

let lastPreviewBody;
const server = createServer((req, res) => {
	const chunks = [];
	req.on('data', chunk => chunks.push(chunk));
	req.on('end', () => {
		const body = chunks.length ? JSON.parse(Buffer.concat(chunks).toString('utf8')) : {};
		res.setHeader('content-type', 'application/json');
		if (req.url === '/status') res.end(JSON.stringify({success: true, version: 'test', platform: 'Test'}));
		else if (req.url === '/log') res.end(JSON.stringify({success: true, log: `last ${body.count} lines`}));
		else if (req.url === '/agent/preview') {
			lastPreviewBody = body;
			res.end(JSON.stringify({success: true, requestId: 'preview-1', files: ['.agent/vision/1-1.png'], frames: []}));
		} else {
			res.statusCode = 404;
			res.end(JSON.stringify({success: false, message: 'not found'}));
		}
	});
});
await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
const {port} = server.address();

function run(args) {
	return new Promise((resolve, reject) => {
		const child = spawn(binary, ['--asset', asset, 'cli', ...args], {cwd: root});
		let stdout = '';
		let stderr = '';
		child.stdout.on('data', chunk => { stdout += chunk; });
		child.stderr.on('data', chunk => { stderr += chunk; });
		child.on('error', reject);
		child.on('close', code => resolve({code, stdout, stderr}));
	});
}

try {
	const status = await run(['agent', 'status', '--port', String(port)]);
	assert.equal(status.code, 0, status.stderr);
	assert.deepEqual(JSON.parse(status.stdout), {success: true, version: 'test', platform: 'Test'});

	const preview = await run(['agent', 'preview', '-p', root, '--entry', 'init.ts', '--capture-at', '0.5,2', '--queue-timeout', '17', '--port', String(port)]);
	assert.equal(preview.code, 0, preview.stderr);
	assert.equal(JSON.parse(preview.stdout).requestId, 'preview-1');
	assert.equal(lastPreviewBody.projectRoot, root);
	assert.equal(lastPreviewBody.entry, 'init.ts');
	assert.deepEqual(lastPreviewBody.captureAtSeconds, [0.5, 2]);
	assert.equal(lastPreviewBody.queueTimeoutSeconds, 17);

	const log = await run(['agent', 'log', '-n', '7', '--port', String(port)]);
	assert.equal(log.code, 0, log.stderr);
	assert.equal(JSON.parse(log.stdout).log, 'last 7 lines');

	const unknown = await run(['agent', 'unknown', '--port', String(port)]);
	assert.equal(unknown.code, 1);
	assert.equal(JSON.parse(unknown.stdout).code, 'UNKNOWN_AGENT_COMMAND');
} finally {
	await new Promise(resolve => server.close(resolve));
}

console.log('Dora CLI agent protocol tests passed');
