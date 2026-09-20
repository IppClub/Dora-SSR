import {createHash} from 'node:crypto';
import {readFile, stat} from 'node:fs/promises';
import path from 'node:path';
import {fileURLToPath} from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../../..');
const webRoot = path.resolve(process.argv[2] || path.join(root, 'Assets/www'));
const playerRoot = path.join(webRoot, 'web-player');
const digest = bytes => createHash('sha256').update(bytes).digest('hex');
const loadJson = async file => JSON.parse(await readFile(file, 'utf8'));

for (const name of ['index.html', 'heavy-assets.json']) {
	const info = await stat(path.join(webRoot, name));
	if (!info.isFile() || info.size === 0) throw new Error(`Missing Web IDE asset: ${name}`);
}

const metadata = await loadJson(path.join(playerRoot, 'runtime.json'));
if (metadata.version !== 1 || !/^\d+\.\d+\.\d+$/.test(metadata.engineVersion) || !metadata.files) {
	throw new Error('Invalid Web export runtime metadata');
}

const required = [
	'dora-player-runtime.js',
	'dora-player-runtime.wasm',
	'dora-player-runtime.data',
	'dora-web-features.json',
	'audio-worklet.js',
	'dora-audio-mixer.wasm',
	'dora-logo.png',
];
for (const name of required) {
	const expected = metadata.files[name];
	if (!expected || !Number.isSafeInteger(expected.size) || !/^[0-9a-f]{64}$/.test(expected.sha256)) {
		throw new Error(`Missing Web export runtime metadata: ${name}`);
	}
	const bytes = await readFile(path.join(playerRoot, name));
	if (bytes.length !== expected.size || digest(bytes) !== expected.sha256) {
		throw new Error(`Web export runtime checksum mismatch: ${name}`);
	}
}

const features = await loadJson(path.join(playerRoot, 'dora-web-features.json'));
for (const name of ['model3D', 'jolt3D', 'rustBridge']) {
	if (features.modules?.[name] !== true) throw new Error(`Required Web export feature is disabled: ${name}`);
}

const source = await readFile(path.join(root, 'Source/Basic/Application.cpp'), 'utf8');
const sourceVersion = source.match(/^#define DORA_VERSION "(\d+\.\d+\.\d+)"_slice$/m)?.[1];
if (metadata.engineVersion !== sourceVersion) {
	throw new Error(`Web runtime engine version ${metadata.engineVersion} does not match source ${sourceVersion}`);
}

console.log(`Verified Web release assets for Dora SSR ${metadata.engineVersion}: ${required.length} runtime files`);
