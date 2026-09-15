// Local real-browser audio regression. Intentionally NOT part of CI.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import http from 'node:http';
import os from 'node:os';
import path from 'node:path';
import {spawn} from 'node:child_process';

const root = path.resolve(process.argv[2] || 'build/web');
const galleryMode = process.argv.includes('--gallery');
const fallbackMode = process.argv.includes('--fallback');
const spatialMode = process.argv.includes('--spatial');
const loveMode = process.argv.includes('--love-probe');
const complexMode = process.argv.includes('--love-complex');
const isolatedMode = process.argv.includes('--isolated');
const gameId = process.argv.find(x => x.startsWith('--game='))?.slice(7) || 'dodge-the-creeps';
const profile = fs.mkdtempSync(path.join(os.tmpdir(), 'dora-audio-browser-'));
const chromePath = process.env.DORA_WEB_CHROME || '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';
const harness = `<!doctype html><button>Audio test</button><script>
window.Module = {preRun: [], doraAudioWorklet: ${!fallbackMode}};
window.audioEnds=[]; Module.ccall=(name,type,args,values)=>{if(name==='dora_worklet_ended')audioEnds.push(values[0]);};
let bootResolve; const boot = new Promise(r => bootResolve = r);
window.addRunDependency = () => {};
window.removeRunDependency = () => bootResolve();
const NativeNode = AudioWorkletNode;
window.AudioWorkletNode = class extends NativeNode { constructor(...args) { super(...args); if(args[1] === 'dora-audio') window.mixerNode=this; } };
</script><script src="/web-audio.js"></script><script>
Module.preRun.forEach(fn => fn());
window.testAudio = async () => {
 await boot;
 if (${fallbackMode}) return Module.doraAudio.state;
 if (!Module.doraAudio.ready) throw new Error(JSON.stringify(Module.doraAudio.state));
 const context = Module.doraAudio.context;
 await context.resume();
 const source = ${JSON.stringify(`class Observe extends AudioWorkletProcessor {
 constructor() { super(); this.reset(); this.port.onmessage=({data})=>{
  if(data==='reset') this.reset();
  this.port.postMessage({frames:this.frames,zeroBlocks:this.zeroBlocks,maxJump:this.maxJump,nonzero:this.nonzero});
 }; }
 reset(){ this.frames=0; this.zeroBlocks=0; this.maxJump=0; this.nonzero=0; this.last=null; }
 process(inputs) { const values=inputs[0]?.[0]; if(values) {
  let energy=0;
  for(const v of values) { energy+=v*v; if(Math.abs(v)>0.001) this.nonzero++;
   if(this.last!==null) this.maxJump=Math.max(this.maxJump,Math.abs(v-this.last)); this.last=v;
  }
  if(energy<1e-10) this.zeroBlocks++; this.frames+=values.length;
 } return true; }
} registerProcessor('observe',Observe);`)};
 const url=URL.createObjectURL(new Blob([source],{type:'text/javascript'}));
 await context.audioWorklet.addModule(url); URL.revokeObjectURL(url);
 const observer=new NativeNode(context,'observe'); mixerNode.connect(observer); observer.connect(context.destination);
 const query=command=>new Promise(resolve=>{observer.port.onmessage=e=>resolve(e.data); observer.port.postMessage(command);});
 const delay=ms=>new Promise(r=>setTimeout(r,ms));
 const rate=48000, frames=4800, bytes=new Uint8Array(44+frames*2), view=new DataView(bytes.buffer);
 const str=(p,s)=>{for(let i=0;i<s.length;i++) bytes[p+i]=s.charCodeAt(i);};
 str(0,'RIFF'); view.setUint32(4,bytes.length-8,true); str(8,'WAVEfmt ');
 view.setUint32(16,16,true); view.setUint16(20,1,true); view.setUint16(22,1,true);
 view.setUint32(24,rate,true);view.setUint32(28,rate*2,true);view.setUint16(32,2,true);view.setUint16(34,16,true);
 str(36,'data');view.setUint32(40,frames*2,true);
 for(let i=0;i<frames;i++)view.setInt16(44+i*2,Math.round(4000*Math.sin(2*Math.PI*440*i/rate)),true);
 Module.doraAudio.listener([0,0,0,0,0,1,0,1,0,0,0,0,343,1,2]);
 const config=${spatialMode} ? [2,-1,1,0,1,1,0,0,0,0,1,0,0,0,0,0,0,6.283185,6.283185,0,1,0,1,1000,1,1,1,0,0,0,1] : null;
 const id=Module.doraAudio.play('sine.wav',bytes,true,0,false,config);
 await delay(300); await query('reset');
 const start=performance.now(); while(performance.now()-start<600) {};
 await delay(150); const blocked=await query('report');
 Module.doraAudio.pause(true); await delay(100); await query('reset'); await delay(150);
 const paused=await query('report');
 Module.doraAudio.pause(false); await delay(100); await query('reset'); await delay(150);
 const resumed=await query('report');
 Module.doraAudio.stop(id,0.05); await delay(150); await query('reset'); await delay(150);
 const stopped=await query('report');
 const state=Module.doraAudio.state;
 Module.doraAudio.dispose(); await delay(50);
 return {crossOriginIsolated,blocked,paused,resumed,stopped,state,closed:context.state,audioEnds};
};</script>`;
const server = http.createServer((req, res) => {
	if(isolatedMode) {
		res.setHeader('Cross-Origin-Opener-Policy','same-origin');
		res.setHeader('Cross-Origin-Embedder-Policy','require-corp');
	}
	if (galleryMode || loveMode || complexMode) {
		let relative = decodeURIComponent(new URL(req.url, 'http://localhost').pathname);
		if (relative.endsWith('/')) relative += 'index.html';
		const target = path.resolve(root, `.${relative}`);
		if (!target.startsWith(root + path.sep) || !fs.statSync(target, {throwIfNoEntry:false})?.isFile())
			return res.writeHead(404).end();
		const types = {'.html':'text/html', '.js':'text/javascript', '.wasm':'application/wasm', '.json':'application/json'};
		res.writeHead(200, {'Content-Type':types[path.extname(target)] || 'application/octet-stream'});
		if (fallbackMode && path.basename(target) === 'gallery-player.js')
			return res.end('Module.doraAudioWorklet=false;\n' + fs.readFileSync(target, 'utf8'));
		if (fallbackMode && /^dora-love-(audio|complex)-probe\.js$/.test(path.basename(target)))
			return res.end('var Module={doraAudioWorklet:false};\n' + fs.readFileSync(target,'utf8'));
		return fs.createReadStream(target).pipe(res);
	}
	const files = {'/web-audio.js': 'Projects/Web/web-audio.js', '/audio-worklet.js': 'Projects/Web/audio-worklet.js',
		'/dora-audio-mixer.wasm': path.join(root, 'dora-audio-mixer.wasm')};
	if (req.url === '/') return res.writeHead(200, {'Content-Type': 'text/html'}).end(harness);
	const file = files[req.url];
	if (!file) return res.writeHead(404).end();
	res.writeHead(200, {'Content-Type': file.endsWith('.js') ? 'text/javascript' : 'application/wasm'});
	fs.createReadStream(file).pipe(res);
});
await new Promise(r => server.listen(0, '127.0.0.1', r));
const child = spawn(chromePath, ['--headless=new', '--remote-debugging-port=0', `--user-data-dir=${profile}`,
	'--autoplay-policy=no-user-gesture-required', '--no-first-run', '--no-default-browser-check', 'about:blank'], {stdio:'ignore'});
let socket;
const sleep = ms => new Promise(r => setTimeout(r, ms));
try {
	const portFile = path.join(profile, 'DevToolsActivePort');
	for (let i = 0; !fs.existsSync(portFile) && i < 100; ++i) await sleep(100);
	const port = fs.readFileSync(portFile, 'utf8').split('\n')[0];
	const tabs = await (await fetch(`http://127.0.0.1:${port}/json/list`)).json();
	socket = new WebSocket(tabs.find(x => x.type === 'page').webSocketDebuggerUrl);
	await new Promise(r => socket.addEventListener('open', r, {once:true}));
	let sequence = 0;
	const pending = new Map();
	socket.addEventListener('message', ({data}) => {
		const message = JSON.parse(data);
		if (pending.has(message.id)) { pending.get(message.id)(message); pending.delete(message.id); }
	});
	const call = (method, params = {}) => new Promise(resolve => {
		const id = ++sequence; pending.set(id, resolve); socket.send(JSON.stringify({id, method, params}));
	});
	const origin = `http://127.0.0.1:${server.address().port}/`;
	if (loveMode || complexMode) {
		const errors = [];
		socket.addEventListener('message', ({data}) => {
			const event=JSON.parse(data);
			if(event.method==='Runtime.exceptionThrown' || (event.method==='Runtime.consoleAPICalled' && event.params.type==='error')) errors.push(event.params);
		});
		await call('Runtime.enable');
		await call('Page.enable');
		const injection=await call('Page.addScriptToEvaluateOnNewDocument', {source:`(()=>{const OriginalWorklet=globalThis.AudioWorkletNode;
			globalThis.AudioWorkletNode=class extends OriginalWorklet { constructor(...args){ super(...args); if(args[1]==='dora-audio')globalThis.testMixer=this; } };})();`});
		assert.ok(!injection.error,JSON.stringify(injection));
		const evaluate = async expression => {
			const result=await call('Runtime.evaluate',{expression,awaitPromise:true,returnByValue:true,timeout:15000});
			assert.ok(!result.result?.exceptionDetails,JSON.stringify(result));
			return result.result?.result?.value;
		};
		await call('Page.navigate',{url:origin+`dora-love-${complexMode?'complex':'audio'}-probe.html`});
		const snapshot=complexMode?'doraLoveComplexSnapshot':'doraLoveAudioSnapshot';
		let before;
		for(let i=0;i<120;i++) {
			await sleep(500);
			before=await evaluate(`typeof ${snapshot}==='function' && Module.calledRun ? {runtime:${snapshot}(),audio:Module.doraAudio.state} : null`);
			if(before?.runtime.error) throw new Error(JSON.stringify(before));
			assert.deepEqual(errors,[],JSON.stringify(before));
			if((fallbackMode ? before?.runtime.playing>0 : before?.audio.voices>0) && (complexMode || before?.runtime.readyCount>=2))break;
		}
		assert.ok(fallbackMode ? before?.runtime.playing>0 : before?.audio.voices>0,JSON.stringify({before,errors}));
		assert.equal(before.audio.backend,fallbackMode?'sdl-fallback':'audioworklet-soloud');
		const blocked=fallbackMode?null:await evaluate(`(async()=>{
			const context=Module.doraAudio.context; await context.resume();
			const url=URL.createObjectURL(new Blob([
				"class Capture extends AudioWorkletProcessor { constructor(){super();this.frames=0;this.nonzero=0;this.zero=0;this.port.onmessage=()=>this.port.postMessage({frames:this.frames,nonzero:this.nonzero,zero:this.zero});} process(inputs){const a=inputs[0]?.[0];if(a){let energy=0;for(const x of a){energy+=x*x;if(Math.abs(x)>0.00001)this.nonzero++;}if(energy<1e-12)this.zero++;this.frames+=a.length;}return true;} } registerProcessor('capture-love',Capture);"
			],{type:'text/javascript'})); await context.audioWorklet.addModule(url);URL.revokeObjectURL(url);
			const observer=new AudioWorkletNode(context,'capture-love');testMixer.connect(observer);observer.connect(context.destination);
			await new Promise(r=>setTimeout(r,200));
			const read=()=>new Promise(r=>{observer.port.onmessage=e=>r(e.data);observer.port.postMessage('read');});
			const a=await read();const t=performance.now();while(performance.now()-t<600){};
			const b=await read();testMixer.disconnect(observer);observer.disconnect();
			return {frames:b.frames-a.frames,nonzero:b.nonzero-a.nonzero,zero:b.zero-a.zero,
				legacySignal:Array.from(Module.SDL2?.audio?.currentOutputBuffer?.getChannelData(0)||[]).some(v=>Math.abs(v)>0.001)};
		})()`);
		if(blocked) {
			assert.ok(blocked.frames>before.audio.sampleRate*0.45,JSON.stringify(blocked));
			assert.ok(blocked.nonzero>1000,JSON.stringify(blocked));
			assert.equal(blocked.zero,0,'Love mix must continue while main thread is blocked');
			assert.equal(blocked.legacySignal,false,'ordinary Love sources must not produce SDL samples');
		}
		if(loveMode) {
			for(let i=0;i<3;i++) {
				assert.equal(await evaluate('doraRestartFirstLoveAudioProbe()'),true);
				await sleep(700);
			}
			assert.equal(await evaluate('doraReleaseFirstLoveAudioProbe()'),true);
			await sleep(1100);
			const peer=await evaluate('({runtime:doraLoveAudioSnapshot(),audio:Module.doraAudio.state})');
			assert.equal(peer.runtime.instances,1);
			if(!fallbackMode){assert.ok(peer.audio.voices>0);assert.equal(peer.audio.buses,5);}
		}
		assert.equal(await evaluate(complexMode?'doraReleaseLoveComplexProbe()':'doraReleaseLoveAudioProbe()'),true);
		await sleep(1200);
		const after=await evaluate(`({runtime:${snapshot}(),audio:Module.doraAudio.state})`);
		if(!fallbackMode){assert.equal(after.audio.voices,0);assert.equal(after.audio.buses,0);}
		else {assert.equal(after.runtime.sources,0);assert.equal(after.runtime.voices,0);}
		assert.deepEqual(errors,[]);
		await evaluate('Module.doraAudio.dispose()');
		console.log(JSON.stringify({before,blocked,after},null,2));
	} else if (galleryMode) {
		const catalog = JSON.parse(fs.readFileSync(path.join(root, 'catalog.json')));
		const browserErrors = [];
		const logs = [];
		socket.addEventListener('message', ({data}) => {
			const event = JSON.parse(data);
			if (event.method === 'Runtime.exceptionThrown') browserErrors.push(event.params);
			if (event.method === 'Runtime.consoleAPICalled' && event.params.type === 'error') browserErrors.push(event.params);
			if (event.method === 'Runtime.consoleAPICalled') logs.push(event.params.args.map(x=>x.value||'').join(' '));
		});
		await call('Runtime.enable');
		await call('Page.navigate', {url:origin + catalog.player + '?game=' + gameId});
		let state;
		let started = false;
		for (let i = 0; i < 60; ++i) {
			await sleep(500);
			const result = await call('Runtime.evaluate', {expression:'({engine:document.documentElement.dataset.doraState,audio:globalThis.Module?.doraAudio?.state,legacySignal:Array.from(globalThis.Module?.SDL2?.audio?.currentOutputBuffer?.getChannelData(0)||[]).some(v=>Math.abs(v)>0.001)})', returnByValue:true});
			state = result.result?.result?.value;
			if (state?.engine === 'running' && !started) {
				started = true;
				await call('Runtime.evaluate', {expression:'document.getElementById("canvas").focus()'});
				await call('Input.dispatchKeyEvent', {type:'keyDown', key:'Enter', code:'Enter', windowsVirtualKeyCode:13});
				await sleep(100);
				await call('Input.dispatchKeyEvent', {type:'keyUp', key:'Enter', code:'Enter', windowsVirtualKeyCode:13});
			}
			if (state?.engine === 'running' && (fallbackMode ? state.legacySignal : state.audio?.voices > 0)) break;
		}
		assert.equal(state?.engine, 'running', JSON.stringify({state,browserErrors}));
		assert.equal(state.audio.backend, fallbackMode ? 'sdl-fallback' : 'audioworklet-soloud');
		assert.ok(fallbackMode ? state.legacySignal : state.audio.voices > 0, JSON.stringify({state,browserErrors}));
		if (gameId === 'audio-source-test') {
			const marker = 'AUDIO_SOURCE_TEST_PASS';
			for(let i=0;i<60 && !logs.some(x=>x.includes(marker));i++) await sleep(250);
			assert.ok(logs.some(x=>x.includes(marker)), JSON.stringify({logs,browserErrors}));
			if (!fallbackMode) assert.ok(!state.legacySignal, 'migrated fixture must not mix through SDL');
		}
		if (!fallbackMode) {
			const paused = await call('Runtime.evaluate', {expression:'(async()=>{await DoraWebPlatform.unlockAudio();await DoraWebPlatform.setSuspended(true);Module.doraAudio.resume();return Module.doraAudio.state.context;})()', awaitPromise:true, returnByValue:true});
			assert.equal(paused.result.result.value, 'suspended');
			await call('Runtime.evaluate', {expression:'DoraWebPlatform.setSuspended(false)', awaitPromise:true});
		}
		await call('Runtime.evaluate', {expression:'{ const t=performance.now(); while(performance.now()-t<600){} }'});
		await sleep(1200);
		const after = await call('Runtime.evaluate', {expression:'Module.doraAudio.state', returnByValue:true});
		if (!fallbackMode) assert.ok(after.result.result.value.frames > state.audio.frames);
		await call('Runtime.evaluate', {expression:'doraStop()'});
		await sleep(500);
		const stopped = await call('Runtime.evaluate', {expression:'({engine:document.documentElement.dataset.doraState,audio:Module.doraAudio.state})', returnByValue:true});
		if (!fallbackMode) assert.equal(stopped.result.result.value.audio.context, 'closed');
		assert.equal(stopped.result.result.value.engine, 'stopped');
		assert.deepEqual(browserErrors, []);
		console.log(JSON.stringify({before:state,after:after.result.result.value,stopped:stopped.result.result.value}, null, 2));
	} else {
	await call('Page.navigate', {url:origin});
	await sleep(1000);
	const response = await call('Runtime.evaluate', {expression:'testAudio()', awaitPromise:true, returnByValue:true, timeout:30000});
	assert.ok(!response.error && !response.result.exceptionDetails, JSON.stringify(response));
	const report = response.result.result.value;
	if (fallbackMode) {
		assert.equal(report.backend, 'sdl-fallback');
		assert.equal(report.ready, false);
	} else {
	assert.equal(report.crossOriginIsolated, false, 'must work without COOP/COEP');
	assert.ok(report.blocked.frames > 24000, 'audio must advance during main-thread block');
	assert.equal(report.blocked.zeroBlocks, 0, 'no silent blocks during main-thread stall');
	assert.ok(report.blocked.maxJump < 0.05, 'no waveform discontinuity during main-thread stall');
	assert.equal(report.paused.nonzero, 0);
	assert.ok(report.resumed.nonzero > 1000);
	assert.equal(report.stopped.nonzero, 0);
	assert.equal(report.closed, 'closed');
	assert.deepEqual(report.audioEnds, spatialMode ? [4096] : []);
	}
	console.log(JSON.stringify(report, null, 2));
	}
} finally {
	socket?.close();
	child.kill('SIGTERM');
	await Promise.race([new Promise(r=>child.once('exit',r)), sleep(3000)]);
	server.closeAllConnections(); await new Promise(r => server.close(r));
	fs.rmSync(profile, {recursive:true, force:true, maxRetries:10, retryDelay:100});
}
