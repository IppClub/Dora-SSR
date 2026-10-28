// Actual Dora Player + GodotNode acceptance (no synthetic GL consumer).
const playwright=require(process.env.DORA_PLAYWRIGHT_MODULE || 'playwright');
const browserEngine=process.env.DORA_BROWSER_ENGINE || 'chromium';
const browserType=playwright[browserEngine];
if(!['chromium','firefox','webkit'].includes(browserEngine)||!browserType)throw new Error('DORA_BROWSER_ENGINE must be chromium, firefox or webkit');
const fs=require('node:fs'),path=require('node:path'),http=require('node:http'),crypto=require('node:crypto');
const directory=path.resolve(process.argv[2]),output=path.resolve(process.argv[3]);
const audioDurationIndex=process.argv.indexOf('--audio-output-seconds');
const audioOutputSeconds=audioDurationIndex<0?0.5:Number(process.argv[audioDurationIndex+1]);
if(!Number.isFinite(audioOutputSeconds)||audioOutputSeconds<0.5||audioOutputSeconds>3600)throw Error('Audio output duration must be 0.5..3600 seconds');
if(audioDurationIndex>=0&&!process.argv.includes('--audio-output'))throw Error('--audio-output-seconds requires --audio-output');
for(let i=4;i<process.argv.length;i++){
 if(process.argv[i]==='--audio-output-seconds'){i++;continue;}
 if(!['--ordinary','--audio-output','--suspend'].includes(process.argv[i]))throw Error('Unknown node acceptance option: '+process.argv[i]);
}
fs.mkdirSync(output,{recursive:true});
for(const name of ['execution.json','verification.json','audio-output.json'])fs.rmSync(path.join(output,name),{force:true});
// Shared build directories can be repackaged by other tests. Fail before opening
// a browser when the requested node fixture is absent or its content has drifted.
if(!process.argv.includes('--ordinary')){
 const manifest=JSON.parse(fs.readFileSync(path.join(directory,'dora-web-manifest.json'),'utf8'));
 const entry=manifest.files.find(file=>file.path===manifest.entry);
 if(!entry)throw new Error('GodotNode fixture entry is missing');
 const url=new URL(entry.url,'http://fixture/');
 const file=path.resolve(directory,'.'+url.pathname);
 if(!file.startsWith(directory+path.sep))throw new Error('Invalid fixture path');
 const content=fs.readFileSync(file);
 if(crypto.createHash('sha256').update(content).digest('hex')!==entry.sha256 || !content.includes(Buffer.from('DORA_WEB_NODE_DONE')))
  throw new Error('Package is not the expected GodotNode fixture; run prepare_node_game.py in an owned directory');
}
function digest(file){const hash=crypto.createHash('sha256'),fd=fs.openSync(file,'r'),buffer=Buffer.alloc(1024*1024);try{for(;;){const count=fs.readSync(fd,buffer,0,buffer.length,null);if(!count)break;hash.update(buffer.subarray(0,count));}}finally{fs.closeSync(fd);}return hash.digest('hex');}
const artifacts={};for(const name of ['dora-player-runtime.js','dora-player-runtime.wasm','dora-player-runtime.data','dora-web-manifest.json','dora-web-features.json','godot/dora-godot.js','godot/dora-godot.wasm','godot/shared_gl.mjs','godot/runtime_bridge.mjs']){const file=path.join(directory,name);if(fs.existsSync(file))artifacts[name]=digest(file);}
fs.mkdirSync(output,{recursive:true});const report=path.join(output,'execution.json');fs.rmSync(report,{force:true});fs.rmSync(path.join(output,'verification.json'),{force:true});
const types={'.html':'text/html','.js':'text/javascript','.mjs':'text/javascript','.wasm':'application/wasm','.json':'application/json'};
(async()=>{
 const server=http.createServer((request,response)=>{
  const relative=decodeURIComponent(new URL(request.url,'http://localhost').pathname).replace(/^\//,'')||'index.html',file=path.resolve(directory,relative);
  if(relative==='favicon.ico'){response.writeHead(204).end();return;}
  if(!file.startsWith(directory+path.sep)){response.writeHead(403).end();return;}
  fs.readFile(file,(error,data)=>{response.writeHead(error?404:200,{'Content-Type':types[path.extname(file)]||'application/octet-stream','Cache-Control':'no-store','Cross-Origin-Opener-Policy':'same-origin','Cross-Origin-Embedder-Policy':'require-corp'});response.end(error?'Not found':data);});
 });
 await new Promise(resolve=>server.listen(0,'127.0.0.1',resolve));let browser;
 const logs=[],errors=[],warnings=[],captures=[];let done=false,capabilities=null,browserVersion=null,lastState=null;
 try{
  const launch={headless:process.env.DORA_BROWSER_HEADLESS!=='0'};
  if(browserEngine==='chromium')Object.assign(launch,{channel:process.env.DORA_BROWSER_CHANNEL||'chrome',args:['--use-angle=metal','--autoplay-policy=no-user-gesture-required']});
  browser=await browserType.launch(launch);
  browserVersion=await browser.version();
  const page=await browser.newPage({viewport:{width:1280,height:720},deviceScaleFactor:1});
  page.on('pageerror',error=>errors.push(String(error)));
  page.on('console',message=>{
   const text=message.text();logs.push(text);console.log('BROWSER '+message.type()+': '+text);
   if(message.type()==='error'||text.includes('[error]'))errors.push(text);if(message.type()==='warning')warnings.push(text);
   const capture=/DORA_WEB_NODE_CAPTURE (\S+) frame=(\d+)/.exec(text);if(capture)captures.push({name:capture[1],frame:Number(capture[2])});
   if(text.includes('DORA_WEB_NODE_DONE'))done=true;
  });
  // Set the existing opt-in PCM oracle before the native AudioState is created.
  await page.addInitScript({path:path.join(__dirname,'acceptance_init.js')});
  await page.goto(`http://127.0.0.1:${server.address().port}`);
  capabilities=await page.evaluate(()=>({crossOriginIsolated,sharedArrayBuffer:typeof SharedArrayBuffer!=='undefined',webAssembly:typeof WebAssembly!=='undefined',audioContext:typeof AudioContext!=='undefined',state:document.documentElement.dataset.doraState||null}));
  console.log('BROWSER_CAPABILITIES '+JSON.stringify({browserEngine,browserVersion,...capabilities}));
  const ordinary=process.argv.includes('--ordinary');
  if(ordinary&&Object.keys(artifacts).some(name=>name.startsWith('godot/')))throw new Error('Ordinary Web package unexpectedly contains Godot runtime files');
  if(ordinary){await page.waitForFunction(()=>document.documentElement.dataset.doraState==='running',null,{timeout:60000});await page.waitForTimeout(250);done=true;}
  let suspension=null;
  if(process.argv.includes('--audio-output')){
   await page.waitForFunction(()=>Module.FS.analyzePath('/user/animated.png').exists,null,{timeout:60000});
   await page.mouse.click(5,5);
   const rendered=await page.evaluate(async(duration)=>{
    const source=window.__doraOutputSources?.at(-1);if(!source)throw Error('No host ScriptProcessor output');
    const {context,node}=source;await context.resume();
    const code=`class Probe extends AudioWorkletProcessor {
     constructor(){super();this.n=0;this.nz=0;this.silent=0;this.maxSilent=0;this.cross=[0,0];this.prev=[0,0];this.started=false;}
     process(inputs){const ch=inputs[0];if(ch.length<2)return true;
      for(let i=0;i<ch[0].length;i++){if(Math.abs(ch[0][i])+Math.abs(ch[1][i])>0.00001)this.started=true;if(!this.started)continue;
       this.n++;if(Math.abs(ch[0][i])+Math.abs(ch[1][i])>0.00001){this.nz++;this.silent=0;}else{this.silent++;this.maxSilent=Math.max(this.maxSilent,this.silent);}
       for(let c=0;c<2;c++){let v=ch[c][i];if(this.prev[c]<=0&&v>0)this.cross[c]++;this.prev[c]=v;}}
      if(this.n>=sampleRate*${duration}){this.port.postMessage({frames:this.n,nonzero:this.nz,maxSilent:this.maxSilent,cross:this.cross,sampleRate});return false;}return true;
     }}registerProcessor('dora-output-probe',Probe);`;
    const url=URL.createObjectURL(new Blob([code],{type:'text/javascript'}));
    try{await context.audioWorklet.addModule(url);}finally{URL.revokeObjectURL(url);}
    const probe=new AudioWorkletNode(context,'dora-output-probe',{numberOfInputs:1,numberOfOutputs:1,outputChannelCount:[2]});
    node.connect(probe);probe.connect(context.destination);
    try{return await new Promise((resolve,reject)=>{const timer=setTimeout(()=>reject(Error('No complete browser output tone window')),Math.max(15000,(duration+15)*1000));probe.port.onmessage=e=>{clearTimeout(timer);resolve({...e.data,contextState:context.state,baseLatency:context.baseLatency??null,outputLatency:context.outputLatency??null});};});}
    finally{node.disconnect(probe);probe.disconnect();probe.port.close();}
   },audioOutputSeconds);
   rendered.artifacts=artifacts;rendered.browser_engine=browserEngine;rendered.browser=browserVersion;
   rendered.requested_seconds=audioOutputSeconds;rendered.observed_seconds=rendered.frames/rendered.sampleRate;
   rendered.scope='Browser AudioWorklet tap of actual host ScriptProcessor output; requested '+audioOutputSeconds+' second tone window; no OS/device loopback or end-to-end latency measurement';
   rendered.frequencies=rendered.cross.map(n=>n*rendered.sampleRate/rendered.frames);
   rendered.passed=rendered.observed_seconds>=audioOutputSeconds&&rendered.contextState==='running'&&rendered.nonzero/rendered.frames>0.95&&rendered.maxSilent<rendered.sampleRate*0.01&&rendered.frequencies.every((f,i)=>Math.abs(f-[440,660][i])<15);
   fs.writeFileSync(path.join(output,'audio-output.json'),JSON.stringify(rendered,null,2)+'\n');
   if(!rendered.passed)throw Error('Browser rendered audio tone/continuity check failed');
  }
  if(process.argv.includes('--suspend')){
   const suspendDeadline=Date.now()+60000;
   while(!logs.some(value=>value.includes('DORA_WEB_NODE_CAPTURE animated'))&&Date.now()<suspendDeadline){
    if(errors.some(error=>!error.startsWith('Blocking on the main thread')))throw new Error('Native/browser error before suspension');
    await page.waitForTimeout(50);
   }
   if(!logs.some(value=>value.includes('DORA_WEB_NODE_CAPTURE animated')))throw new Error('Suspension test startup timeout');
   const entered=await page.evaluate(async()=>{const unlock=await Module.doraWebPlatform.unlockAudio();const transition=await Module.doraWebPlatform.setSuspended(true,'acceptance');return {unlock,transition,state:Module.doraWebPlatform.state};});
   await page.waitForTimeout(400);
   const held=await page.evaluate(async()=>{const transition=await Module.doraWebPlatform.setSuspended(true,'acceptance-repeat');return {transition,state:Module.doraWebPlatform.state};});
   const resumed=await page.evaluate(async()=>{const transition=await Module.doraWebPlatform.setSuspended(false,'acceptance');return {transition,state:Module.doraWebPlatform.state};});
   if(!entered.state.suspended||!held.state.suspended||resumed.state.suspended||entered.transition.engineFrame!==held.transition.engineFrame)throw new Error('Web suspension state/frame contract failed');
   suspension={entered,held,resumed};
  }
  const deadline=Date.now()+120000;
  while(!done&&Date.now()<deadline){await page.waitForTimeout(250);if(errors.some(error=>!error.startsWith('Blocking on the main thread is very dangerous')))throw new Error('Native/browser error during node test');lastState=await page.evaluate(()=>({state:document.documentElement.dataset.doraState,status:document.querySelector('#status-message')?.textContent,calledRun:Module.calledRun,runtimeReady:Boolean(Module.doraGodotRuntime),dependencies:Module.runDependencies}));if(lastState.state==='faulted')throw new Error('Dora runtime faulted');}
  if(!done)throw new Error('Dora GodotNode controller timeout');
  const renderer=await page.evaluate(()=>{const gl=Module.canvas.getContext('webgl2'),ext=gl.getExtension('WEBGL_debug_renderer_info');return ext?gl.getParameter(ext.UNMASKED_RENDERER_WEBGL):gl.getParameter(gl.RENDERER);});
  await page.waitForTimeout(250);await page.evaluate(()=>Module.ccall('dora_web_stop','number',[],[]));
  await page.waitForFunction(()=>document.documentElement.dataset.doraState==='stopped',{timeout:15000});
  const teardown=await page.evaluate(async()=>{
   const state=Module.doraWebPlatform.state;
   window.dispatchEvent(new Event('blur'));document.dispatchEvent(new Event('visibilitychange'));
   await new Promise(resolve=>setTimeout(resolve,50));
   return {state,dispose_again:Module.doraWebPlatform.dispose({notifyEngine:false}),ime_present:Boolean(document.querySelector('#dora-ime-input'))};
  });
  if(teardown.state.active||teardown.dispose_again||teardown.ime_present)throw new Error('Web platform services remained active after stop');
  for(const capture of captures){const bytes=await page.evaluate(name=>Array.from(Module.FS.readFile('/user/'+name+'.png')),capture.name);fs.writeFileSync(path.join(output,capture.name+'.png'),Buffer.from(bytes));}
  const audio_metrics=await page.evaluate(()=>Module.doraTestAudioMetrics);
  const result={artifacts,renderer,audio_metrics,suspension,teardown,godot_packaged:Object.keys(artifacts).some(name=>name.startsWith('godot/')),passed:audio_metrics.underruns.length===0&&!errors.some(error=>!error.startsWith('Blocking on the main thread is very dangerous'))&&!warnings.some(value=>/GL_INVALID|INVALID_OPERATION|INVALID_VALUE|INVALID_ENUM/.test(value)),scope:'Actual Dora GodotNode Web execution; pixel/image verification is a separate required step',controller_frames:ordinary?0:620,ordinary,captures,browser_engine:browserEngine,browser_headless:launch.headless,browser:await browser.version(),browser_errors:errors,browser_warnings:warnings,logs};
  fs.writeFileSync(report,JSON.stringify(result,null,2)+'\n');if(!result.passed)process.exitCode=1;
 }catch(error){fs.writeFileSync(report,JSON.stringify({passed:false,error:String(error),browser_engine:browserEngine,browser:browserVersion,capabilities,lastState,artifacts,captures,browser_errors:errors,browser_warnings:warnings,logs},null,2)+'\n');throw error;}
 finally{if(browser)await browser.close();await new Promise(resolve=>server.close(resolve));}
})().catch(error=>{console.error(error);process.exitCode=1;});
