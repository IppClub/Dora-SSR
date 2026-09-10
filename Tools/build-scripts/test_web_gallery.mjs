import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import crypto from 'node:crypto';
import {spawnSync} from 'node:child_process';
import {fileURLToPath} from 'node:url';

const temp = fs.mkdtempSync(path.join(os.tmpdir(), 'dora-gallery-gate-'));
const checker = fileURLToPath(new URL('./check_web_gallery.mjs', import.meta.url));
const write = (name, data) => {
	const target = path.join(temp, name);
	fs.mkdirSync(path.dirname(target), {recursive:true});
	fs.writeFileSync(target, data);
};
const run = () => spawnSync(process.execPath, [checker, temp], {encoding:'utf8'});
try {
	assert.notEqual(run().status, 0, 'missing gallery must fail');
	const player = 'player/0000000000000000/';
	write('catalog.json', JSON.stringify({version:1, player, games:[{id:'demo', title:'Demo', manifest:'games/demo/manifest.json'}]}));
	write(`${player}index.html`, '<script src="gallery-player.js"></script>');
	for (const name of ['gallery-player.js', 'dora-player-runtime.js', 'dora-player-runtime.data']) write(player+name, 'fixture');
	write(`${player}dora-player-runtime.wasm`, Buffer.from([0,97,115,109,1,0,0,0]));
	write(`${player}dora-web-features.json`, JSON.stringify({activeProfile:'dora-preset', modules:{crossOriginIsolationRequired:false,
		machineLearning:true, yueCompiler:true, playRho2D:true, entity:true, platformer:true, builtinLuaLibraries:true}}));
	const data = 'print("demo")';
	write('games/demo/init.lua', data);
	write('games/demo/manifest.json', JSON.stringify({format:'dora-web-game', profile:'dora-preset', files:[{path:'init.lua', url:'init.lua', startup:true,
		size:Buffer.byteLength(data), sha256:crypto.createHash('sha256').update(data).digest('hex')}]}));
	write('LICENSE-Dora-Demo', 'test license');
	const valid = run();
	assert.equal(valid.status, 0, valid.stderr);
	write('games/demo/init.lua', data.replace('demo', 'oops'));
	const corrupt = run();
	assert.notEqual(corrupt.status, 0);
	assert.match(corrupt.stderr, /incorrect hash/);
	fs.unlinkSync(path.join(temp, 'games/demo/init.lua'));
	assert.match(run().stderr, /missing gallery asset/);
	console.log('[INFO] Gallery gate positive, missing-output, missing-asset and corruption tests passed');
} finally {
	fs.rmSync(temp, {recursive:true, force:true});
}
