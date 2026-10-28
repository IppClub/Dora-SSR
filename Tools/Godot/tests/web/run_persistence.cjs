// Two real page lifetimes on one origin; no direct access to the Godot FS.
const {chromium}=require(process.env.DORA_PLAYWRIGHT_MODULE||'playwright');
const fs=require('node:fs'),path=require('node:path'),http=require('node:http'),crypto=require('node:crypto');
const directory=path.resolve(process.argv[2]),output=path.resolve(process.argv[3]);fs.mkdirSync(output,{recursive:true});
const report=path.join(output,'verification.json');fs.rmSync(report,{force:true});
const types={'.html':'text/html','.js':'text/javascript','.mjs':'text/javascript','.wasm':'application/wasm','.json':'application/json'};
(async()=>{
 const server=http.createServer((request,response)=>{const relative=decodeURIComponent(new URL(request.url,'http://localhost').pathname).replace(/^\//,'')||'index.html',file=path.resolve(directory,relative);if(relative==='favicon.ico'){response.writeHead(204).end();return;}if(!file.startsWith(directory+path.sep)){response.writeHead(403).end();return;}fs.readFile(file,(error,data)=>{response.writeHead(error?404:200,{'Content-Type':types[path.extname(file)]||'application/octet-stream','Cross-Origin-Opener-Policy':'same-origin','Cross-Origin-Embedder-Policy':'require-corp','Cache-Control':'no-store'});response.end(error?'Not found':data);});});
 await new Promise(resolve=>server.listen(0,'127.0.0.1',resolve));let browser;
 try {
  browser=await chromium.launch({channel:'chrome',headless:true,args:['--use-angle=metal','--autoplay-policy=no-user-gesture-required']});
  const context=await browser.newContext({viewport:{width:960,height:540}}),url=`http://127.0.0.1:${server.address().port}`,cycles=[];
  for(let cycle=1;cycle<=2;++cycle) {
   const page=await context.newPage(),logs=[],errors=[],warnings=[];
   page.on('pageerror',error=>errors.push(String(error)));page.on('console',message=>{const value=message.text();logs.push(value);if(message.type()==='error'||value.includes('[error]'))errors.push(value);if(message.type()==='warning')warnings.push(value);});
   await page.goto(url);await page.waitForFunction(expected=>document.body.innerText.includes('')&&performance.now()>0,cycle);
   const deadline=Date.now()+30000;while(Date.now()<deadline&&!logs.some(value=>value.includes('DORA_PERSIST_DONE'))){if(errors.some(value=>!value.startsWith('Blocking on the main thread')))throw new Error(`Cycle ${cycle} failed: ${errors.join('; ')}`);await page.waitForTimeout(50);}
   if(!logs.some(value=>value.includes('DORA_PERSIST_DONE')))throw new Error(`Cycle ${cycle} did not finish`);
   const match=logs.join('\n').match(/GODOT_PERSIST value=(\d+)/);if(!match)throw new Error(`Cycle ${cycle} did not report persistent value`);
   await page.evaluate(()=>Module.ccall('dora_web_stop','number',[],[]));await page.waitForFunction(()=>document.documentElement.dataset.doraState==='stopped',null,{timeout:15000});
   cycles.push({cycle,value:Number(match[1]),logs,browser_errors:errors,browser_warnings:warnings});await page.close();
  }
  const artifacts=Object.fromEntries(['dora-player-runtime.js','dora-player-runtime.wasm','dora-web-manifest.json','godot/dora-godot.js','godot/dora-godot.wasm'].map(name=>[name,crypto.createHash('sha256').update(fs.readFileSync(path.join(directory,name))).digest('hex')]));
  const passed=cycles.map(value=>value.value).join(',')==='1,2'&&cycles.every(value=>!value.browser_errors.some(error=>!error.startsWith('Blocking on the main thread'))&&!value.browser_warnings.some(warning=>/INVALID_OPERATION|INVALID_ENUM|INVALID_VALUE/.test(warning)));
  fs.writeFileSync(report,JSON.stringify({passed,scope:'Godot user:// IDBFS persistence across two complete Dora Web page/runtime lifetimes on one real browser origin',cycles,artifacts},null,2)+'\n');if(!passed)process.exitCode=1;
 } finally {if(browser)await browser.close();await new Promise(resolve=>server.close(resolve));}
})().catch(error=>{console.error(error);process.exitCode=1;});
