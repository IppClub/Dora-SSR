// Deployment gate: inspect the actual published files, without a browser/GPU.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';

const root = path.resolve(process.argv[2] || 'Docs/static/play');
function file(relative, base = root) {
	assert.equal(typeof relative, 'string', 'asset path must be a string');
	assert.ok(relative && !path.isAbsolute(relative) && !relative.includes('\\'), `invalid asset path: ${relative}`);
	const target = path.resolve(base, relative);
	assert.ok(target.startsWith(`${root}${path.sep}`), `asset escapes gallery: ${relative}`);
	assert.ok(fs.statSync(target, {throwIfNoEntry:false})?.isFile(), `missing gallery asset: ${target}`);
	const data = fs.readFileSync(target);
	assert.ok(data.length, `empty gallery asset: ${target}`);
	return data;
}
const catalog = JSON.parse(file('catalog.json'));
assert.equal(catalog.version, 1);
assert.match(catalog.player, /^player\/[0-9a-f]{16}\/$/);
assert.ok(Array.isArray(catalog.games) && catalog.games.length, 'gallery has no games');
const player = path.join(root, catalog.player);
assert.ok(file('index.html', player).toString().includes('gallery-player.js'));
for (const name of ['gallery-player.js', 'dora-player-runtime.js', 'dora-player-runtime.data']) file(name, player);
assert.ok(WebAssembly.validate(file('dora-player-runtime.wasm', player)), 'invalid player WASM');
const features = JSON.parse(file('dora-web-features.json', player));
assert.equal(features.activeProfile, 'dora-preset');
assert.equal(features.modules.crossOriginIsolationRequired, false);
for (const name of ['machineLearning', 'yueCompiler', 'playRho2D', 'entity', 'platformer', 'builtinLuaLibraries']) assert.equal(features.modules[name], true, `missing runtime feature: ${name}`);
const ids = new Set();
let count = 0;
for (const game of catalog.games) {
	assert.match(game.id, /^[a-z0-9-]+$/);
	assert.ok(!ids.has(game.id), `duplicate game: ${game.id}`);
	ids.add(game.id);
	const manifest = JSON.parse(file(game.manifest));
	assert.equal(manifest.format, 'dora-web-game');
	assert.equal(manifest.profile, 'dora-preset');
	assert.ok(manifest.files.some(item => item.path === 'init.lua' && item.startup), `missing startup script: ${game.id}`);
	const base = path.dirname(path.resolve(root, game.manifest));
	for (const asset of manifest.files) {
		const data = file(asset.url, base);
		assert.equal(data.length, asset.size, `${game.id}: incorrect size for ${asset.path}`);
		assert.equal(crypto.createHash('sha256').update(data).digest('hex'), asset.sha256, `${game.id}: incorrect hash for ${asset.path}`);
		count++;
	}
	if (game.cover) file(game.cover);
}
if (process.argv[3]) {
	const demo = path.resolve(process.argv[3]);
	const expected = fs.readdirSync(demo, {withFileTypes:true}).filter(item => item.isDirectory() && !item.name.startsWith('.')).map(item => item.name).sort();
	assert.deepEqual(catalog.games.map(game => game.title).sort(), expected, 'published gallery must contain every Dora-Demo game');
}
file('LICENSE-Dora-Demo');
console.log(`[INFO] Gallery deployment verified: one player, ${ids.size} games, ${count} verified assets (${root})`);
