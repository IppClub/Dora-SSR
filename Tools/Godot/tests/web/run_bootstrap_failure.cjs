const fs=require('node:fs'),path=require('node:path'),http=require('node:http'),crypto=require('node:crypto');
const playwright=require(process.env.DORA_PLAYWRIGHT_MODULE),engine=process.env.DORA_BROWSER_ENGINE||'chromium';
if(!['chromium','firefox','webkit'].includes(engine))throw Error('Unsupported browser');
if(process.argv.length!==4&&!(process.argv.length===6&&process.argv[4]==='--expected-message'))throw Error('Usage: run_bootstrap_failure.cjs <package> <output> [--expected-message text]');
const expectedMessage=process.argv[5]||'DORA_EXPECTED_BOOTSTRAP_FAILURE';
const directory=path.resolve(process.argv[2]),out=path.resolve(process.argv[3]);if(fs.existsSync(out))throw Error('Use fresh output');fs.mkdirSync(out,{recursive:true});
const errors=[],consoleErrors=[],warnings=[],logs=[];const sha=file=>crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex');
(async()=>{
 const server=http.createServer((request,response)=>{const relative=decodeURIComponent(new URL(request.url,'http://localhost').pathname).replace(/^\//,'')||'index.html';if(relative==='favicon.ico'){response.writeHead(204).end();return;}const file=path.resolve(directory,relative);if(!file.startsWith(directory+path.sep)){response.writeHead(403).end();return;}fs.readFile(file,(error,data)=>{response.writeHead(error?404:200,{'Content-Type':file.endsWith('.wasm')?'application/wasm':(file.endsWith('.js')||file.endsWith('.mjs'))?'text/javascript':file.endsWith('.json')?'application/json':file.endsWith('.html')?'text/html':'application/octet-stream','Cross-Origin-Opener-Policy':'same-origin','Cross-Origin-Embedder-Policy':'require-corp'});response.end(error?'Not found':data);});});
 await new Promise(resolve=>server.listen(0,'127.0.0.1',resolve));let browser;
 try{
  const chromium={headless:true,args:['--autoplay-policy=no-user-gesture-required']};
  if(process.platform==='darwin'){chromium.channel='chrome';chromium.args.push('--use-angle=metal');}
  else chromium.args.push('--use-angle=swiftshader','--enable-unsafe-swiftshader');
  browser=await playwright[engine].launch(engine==='chromium'?chromium:{headless:true});
  const page=await browser.newPage();page.on('pageerror',error=>errors.push(error.stack||String(error)));page.on('console',message=>{logs.push(message.text());if(message.type()==='error')consoleErrors.push(message.text());if(message.type()==='warning')warnings.push(message.text());});
  await page.goto('http://127.0.0.1:'+server.address().port);
  await page.waitForFunction(()=>document.documentElement.dataset.doraState==='faulted',null,{timeout:60000});await page.waitForTimeout(1000);
  const state=await page.evaluate(()=>({runtime:document.documentElement.dataset.doraState,platform:Module.doraWebPlatform?.state,ime:Boolean(document.querySelector('#dora-ime-input'))}));
  const expected=logs.filter(error=>error.includes('[error]')&&error.includes(expectedMessage));if(expected.length!==1)throw Error('Expected fixture failure not observed');
  const report={passed:errors.length===0&&consoleErrors.every(error=>error==='[DoraWeb] Runtime failed: Failed to initialize the Web runtime'||(error.includes('[error]')&&error.includes(expectedMessage)))&&!warnings.some(value=>/GL_INVALID|INVALID_OPERATION|INVALID_VALUE|INVALID_ENUM/.test(value))&&state.runtime==='faulted'&&Boolean(state.platform)&&!state.platform.active&&state.platform.pressedKeys===0&&state.platform.activePointers===0&&!state.ime,scope:'Intentional Lua bootstrap assertion and ordinary Web failure cleanup only; no Godot GPU acceptance',browser_engine:engine,browser:await browser.version(),wasm_sha256:sha(path.join(directory,'dora-player-runtime.wasm')),manifest_sha256:sha(path.join(directory,'dora-web-manifest.json')),state,page_errors:errors,console_errors:consoleErrors,warnings,logs};
  fs.writeFileSync(path.join(out,'verification.json'),JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify(report,null,2));if(!report.passed)process.exitCode=1;
 }finally{if(browser)await browser.close();await new Promise(resolve=>server.close(resolve));}
})().catch(error=>{fs.writeFileSync(path.join(out,'failure.json'),JSON.stringify({passed:false,error:String(error),page_errors:errors,console_errors:consoleErrors,warnings,logs},null,2)+'\n');console.error(error);process.exitCode=1;});
