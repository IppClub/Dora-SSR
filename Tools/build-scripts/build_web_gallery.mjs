// Build once, package every top-level Dora-Demo game, then publish the catalog last.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {execFileSync} from 'node:child_process';
import {fileURLToPath} from 'node:url';
const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../..');
const run = (exe, args, cwd = root) => execFileSync(exe, args, {cwd, stdio: 'inherit'});
const git = (dir, ...args) => execFileSync('git', ['-C', dir, ...args], {encoding: 'utf8'}).trim();
run(process.execPath, ['Tools/build-scripts/check_web_api_parity.mjs']);
const demo = path.resolve(process.env.DORA_DEMO_DIR || path.join(root, 'build/Dora-Demo'));
if (!process.env.DORA_DEMO_DIR) {
	if (!fs.existsSync(demo)) run('git', ['clone', 'https://github.com/ippclub/Dora-Demo.git', demo]);
	if (git(demo, 'status', '--porcelain')) throw new Error(`Managed demo checkout has local changes: ${demo}`);
	const head = git(demo, 'ls-remote', '--symref', 'origin', 'HEAD').match(/ref: refs\/heads\/([^\s]+)/)?.[1];
	if (!head) throw new Error('Cannot resolve Dora-Demo default branch');
	run('git', ['fetch', 'origin', head], demo);
	run('git', ['switch', '--detach', 'FETCH_HEAD'], demo);
}
const build = path.resolve(process.env.DORA_WEB_BUILD_DIR || path.join(root, 'build/web'));
if (!fs.existsSync(path.join(build, 'CMakeCache.txt'))) {
	execFileSync('bash', ['Tools/build-scripts/build_web.sh'], {cwd: root, stdio: 'inherit', env: {...process.env,
		DORA_WEB_BUILD_ENGINE: '1', DORA_WEB_LINK_PLAYER: '1', DORA_WEB_BUILD_LOVE_PROBE: '0', DORA_WEB_BUILD_LOVE_PTHREAD_PLAYER: '0', DORA_WEB_PTHREADS: '0', DORA_WEB_PROFILE: 'dora-preset'}});
}
// Reconfigure existing caches too: the gallery requires every demo capability.
run('cmake', ['-S', path.join(root, 'Projects/Web'), '-B', build, '-DDORA_WEB_BUILD_ENGINE=ON', '-DDORA_WEB_LINK_PLAYER=ON', '-DDORA_WEB_PTHREADS=OFF', '-DDORA_WEB_PROFILE=dora-preset',
	...['PHYSICS_2D', 'ENTITY', 'PLATFORMER', 'BUILTIN_LIBS', 'ML', 'YUE'].map(feature => `-DDORA_WEB_FEATURE_${feature}=ON`),
	`-DDORA_WEB_BUILTIN_FONT=${path.join(root, 'Assets/Font/sarasa-mono-sc-regular.ttf')}`]);
run('cmake', ['--build', build, '--target', 'dora-web-player', '-j', process.env.DORA_WEB_JOBS || '8']);
const features = JSON.parse(fs.readFileSync(path.join(build, 'dora-web-features.json')));
if (features.activeProfile !== 'dora-preset' || features.modules.crossOriginIsolationRequired || !features.modules.machineLearning || !features.modules.yueCompiler) throw new Error('Gallery requires a single-threaded dora-preset build with ML and Yue');
const output = path.resolve(process.env.DORA_WEB_GALLERY_DIR || path.join(root, 'Docs/static/play'));
const artifacts = ['dora-player-runtime.js', 'dora-player-runtime.wasm', 'dora-player-runtime.data', 'dora-web-features.json'];
const shell = fs.readFileSync(path.join(root, 'Projects/Web/player-shell.html'), 'utf8')
	.replace('<head>', `<head><script>const base = document.createElement('base'); base.href = location.pathname.endsWith('.html') ? new URL('.', location.href).href : location.origin + location.pathname.replace(/\\/$/, '') + '/'; document.head.appendChild(base);</script>`)
	.replace('{{{ SCRIPT }}}', '<script src="gallery-player.js"></script>');
const bridge = fs.readFileSync(path.join(root, 'Projects/Web/gallery-player.js'));
const hash = crypto.createHash('sha256').update(shell).update(bridge);
for (const file of artifacts) hash.update(fs.readFileSync(path.join(build, file)));
const player = `player/${hash.digest('hex').slice(0, 16)}`;
fs.mkdirSync(path.join(output, player), {recursive: true});
for (const file of artifacts) fs.copyFileSync(path.join(build, file), path.join(output, player, file));
fs.writeFileSync(path.join(output, player, 'index.html'), shell);
fs.writeFileSync(path.join(output, player, 'gallery-player.js'), bridge);
const games = [];
for (const item of fs.readdirSync(demo, {withFileTypes: true}).sort((a,b) => a.name.localeCompare(b.name))) {
	if (!item.isDirectory() || item.name.startsWith('.')) continue;
	const source = path.join(demo, item.name);
	if (!fs.existsSync(path.join(source, 'init.lua'))) throw new Error(`Missing generated init.lua: ${item.name}`);
	const id = item.name.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');
	if (!id || games.some(game => game.id === id)) throw new Error(`Invalid or duplicate ID: ${item.name}`);
	const stage = fs.mkdtempSync(path.join(root, 'build/gallery-game-'));
	execFileSync(process.execPath, ['Tools/build-scripts/package_web_game.mjs', source, stage], {cwd: root, stdio: 'inherit', env: {...process.env, DORA_WEB_GAME_PROFILE: 'dora-preset', DORA_WEB_EAGER_GAME_ASSETS: '1'}});
	const manifestData = fs.readFileSync(path.join(stage, 'dora-web-manifest.json'));
	const revision = crypto.createHash('sha256').update(manifestData).digest('hex').slice(0,16);
	const target = `games/${id}/${revision}`;
	fs.mkdirSync(path.join(output, target), {recursive: true});
	fs.cpSync(stage, path.join(output, target), {recursive: true});
	const manifest = JSON.parse(manifestData);
	const cover = manifest.files.find(file => /(?:banner|cover)\.(?:jpg|png)$/i.test(file.path));
	games.push({id, title: item.name, manifest: `${target}/dora-web-manifest.json`, cover: cover ? `${target}/${cover.url}` : null,
		source: `https://github.com/ippclub/Dora-Demo/tree/HEAD/${encodeURIComponent(item.name)}`});
}
if (!games.length) throw new Error('No games found');
fs.copyFileSync(path.join(demo, 'LICENSE'), path.join(output, 'LICENSE-Dora-Demo'));
const catalog = {version: 1, player: `${player}/`, engineCommit: git(root, 'rev-parse', 'HEAD'), demoCommit: git(demo, 'rev-parse', 'HEAD'), games};
fs.writeFileSync(path.join(output, 'catalog.json.tmp'), JSON.stringify(catalog, null, 2)+'\n');
fs.renameSync(path.join(output, 'catalog.json.tmp'), path.join(output, 'catalog.json'));
console.log(`Gallery ready: ${games.length} games, one player. ${output}`);
