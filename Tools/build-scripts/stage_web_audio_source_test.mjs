// Local integration fixture using the real Lua bindings, AudioSource and player.
import fs from 'node:fs';
import path from 'node:path';
import {execFileSync} from 'node:child_process';
const build = path.resolve(process.argv[2] || 'build/web-demo-profile');
const output = fs.mkdtempSync(path.resolve('build/web-audio-source-test-'));
const source = path.join(output, 'source');
const game = 'games/audio-source-test/fixture';
const player = 'player/fixture/';
fs.mkdirSync(source, {recursive:true});
fs.copyFileSync('Projects/Web/audio-source-fixture/init.lua', path.join(source, 'init.lua'));
execFileSync(process.execPath, ['Tools/build-scripts/generate_web_audio_fixture.mjs', path.join(source, 'Audio/tone.wav'), path.join(source, 'Audio/tone.ogg')], {stdio:'inherit'});
execFileSync(process.execPath, ['Tools/build-scripts/package_web_game.mjs', source, path.join(output,game)], {stdio:'inherit',env:{...process.env,DORA_WEB_EAGER_GAME_ASSETS:'1'}});
fs.mkdirSync(path.join(output,player), {recursive:true});
for(const file of ['dora-player-runtime.js','dora-player-runtime.wasm','dora-player-runtime.data','dora-audio-mixer.wasm','audio-worklet.js'])
	fs.copyFileSync(path.join(build,file),path.join(output,player,file));
fs.copyFileSync('Projects/Web/gallery-player.js',path.join(output,player,'gallery-player.js'));
fs.writeFileSync(path.join(output,player,'index.html'),fs.readFileSync('Projects/Web/player-shell.html','utf8').replace('{{{ SCRIPT }}}','<script src="gallery-player.js"></script>'));
fs.writeFileSync(path.join(output,'catalog.json'),JSON.stringify({version:1,player,games:[{id:'audio-source-test',manifest:`${game}/dora-web-manifest.json`}]}));
console.log(output);
