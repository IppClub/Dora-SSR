import {readdir, readFile, writeFile, rm} from 'node:fs/promises';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {createHash} from 'node:crypto';
import {promisify} from 'node:util';
import {gzip, gunzip} from 'node:zlib';

const pack = promisify(gzip), unpack = promisify(gunzip);
const extensions = new Set(['.html', '.htm', '.js', '.mjs', '.css', '.json', '.txt', '.xml', '.svg', '.wasm', '.data']);
export const manifestName = 'precompressed-assets.json';
const minimumBytes = 1024;
const maximumBytes = 512 * 1024 * 1024; // Matches the server's on-demand decode bound.
const digest = bytes => createHash('sha256').update(bytes).digest('hex');
const eligible = file => file !== manifestName && extensions.has(path.extname(file).toLowerCase());
const safeName = name => typeof name === 'string' && name.length > 0 && !name.includes('\\')
	&& !/^[A-Za-z]:/.test(name) && !name.startsWith('/') && name.split('/').every(part => part !== '.' && part !== '..' && part !== '');

async function filesIn(root, prefix = '') {
	const result = [];
	for (const entry of await readdir(path.join(root, prefix), {withFileTypes: true})) {
		const file = prefix ? `${prefix}/${entry.name}` : entry.name;
		if (entry.isDirectory()) result.push(...await filesIn(root, file));
		else if (entry.isFile()) result.push(file); // Never follow output symlinks.
	}
	return result.sort();
}

// Bound compression concurrency and temporary raw/compressed buffers.
async function eachBounded(files, action) {
	let next = 0;
	const outcomes = await Promise.allSettled(Array.from({length: Math.min(4, files.length)}, async () => {
		while (next < files.length) await action(files[next++]);
	}));
	for (const outcome of outcomes) if (outcome.status === 'rejected') throw outcome.reason;
}

async function loadManifest(root) {
	let bytes;
	try { bytes = await readFile(path.join(root, manifestName), 'utf8'); }
	catch (error) { if (error.code === 'ENOENT') return {version: 1, files: {}}; throw error; }
	const manifest = JSON.parse(bytes);
	if (manifest.version !== 1 || !manifest.files || typeof manifest.files !== 'object' || Array.isArray(manifest.files)) throw new Error('Invalid gzip asset manifest');
	for (const [name, entry] of Object.entries(manifest.files)) {
		if (!safeName(name) || !eligible(name)) throw new Error(`Invalid gzip asset path: ${name}`);
		if (!entry || !Number.isSafeInteger(entry.size) || (entry.size < minimumBytes || entry.size > maximumBytes)
			|| !Number.isSafeInteger(entry.gzipSize) || entry.gzipSize < 18 || entry.gzipSize >= entry.size
			|| !/^[a-f0-9]{64}$/.test(entry.sha256) || !/^[a-f0-9]{64}$/.test(entry.gzipSha256))
			throw new Error(`Invalid gzip asset metadata: ${name}`);
	}
	return manifest;
}

export async function precompressAssets(root) {
	const old = await loadManifest(root), present = new Set(await filesIn(root));
	const names = [...new Set([...present].filter(eligible).concat(Object.keys(old.files)))].sort();
	const files = {}, result = {files: 0, originalBytes: 0, gzipBytes: 0};
	await eachBounded(names, async name => {
		if (!present.has(name) && !present.has(name + '.gz')) throw new Error(`Missing asset: ${name}`);
		const raw = present.has(name) ? await readFile(path.join(root, name))
			: await unpack(await readFile(path.join(root, name + '.gz')));
		if (!present.has(name) && (raw.length !== old.files[name].size || digest(raw) !== old.files[name].sha256))
			throw new Error(`Invalid existing gzip asset: ${name}`);
		const compressed = raw.length >= minimumBytes && raw.length <= maximumBytes ? await pack(raw, {level: 9}) : raw;
		if (compressed.length >= raw.length) {
			await writeFile(path.join(root, name), raw);
			await rm(path.join(root, name + '.gz'), {force: true});
			return;
		}
		await writeFile(path.join(root, name + '.gz'), compressed);
		await rm(path.join(root, name), {force: true});
		files[name] = {size: raw.length, sha256: digest(raw), gzipSize: compressed.length, gzipSha256: digest(compressed)};
		result.files++; result.originalBytes += raw.length; result.gzipBytes += compressed.length;
	});
	await writeFile(path.join(root, manifestName), JSON.stringify({version: 1,
		files: Object.fromEntries(Object.entries(files).sort(([a], [b]) => a.localeCompare(b)))}, null, 2) + '\n');
	return result;
}

export async function readAsset(root, name) {
	if (!safeName(name)) throw new Error(`Invalid asset path: ${name}`);
	try { return await readFile(path.join(root, name)); }
	catch (error) { if (error.code !== 'ENOENT') throw error; }
	return unpack(await readFile(path.join(root, name + '.gz')));
}

export async function verifyPrecompressedAssets(root) {
	const present = new Set(await filesIn(root));
	if (!present.has(manifestName)) throw new Error('Missing gzip asset manifest');
	const manifest = await loadManifest(root);
	for (const file of present) {
		if (file.endsWith('.gz') && eligible(file.slice(0, -3)) && !Object.hasOwn(manifest.files, file.slice(0, -3)))
			throw new Error(`Unlisted gzip asset: ${file}`);
	}
	await eachBounded(Object.keys(manifest.files), async name => {
		if (present.has(name)) throw new Error(`Duplicate uncompressed asset: ${name}`);
		if (!present.has(name + '.gz')) throw new Error(`Missing gzip asset: ${name}`);
		const compressed = await readFile(path.join(root, name + '.gz')), raw = await unpack(compressed);
		const expected = manifest.files[name];
		if (raw.length !== expected.size || digest(raw) !== expected.sha256
			|| compressed.length !== expected.gzipSize || digest(compressed) !== expected.gzipSha256)
			throw new Error(`Invalid gzip asset: ${name}`);
	});
	return Object.keys(manifest.files).length;
}

if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
	const root = path.resolve(process.argv[2] || '../../Assets/www');
	console.log('Precompressed Web IDE distribution:', await precompressAssets(root));
}
