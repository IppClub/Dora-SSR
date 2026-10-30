// A browser GPU transport test. Requires Playwright and an installed Chrome.
const {chromium}=require(process.env.DORA_PLAYWRIGHT_MODULE || 'playwright');
const fs=require('node:fs'),http=require('node:http'),path=require('node:path');
const directory=path.resolve(process.argv[2]);
const report=path.join(directory,'verification.json');
const types={'.html':'text/html','.js':'text/javascript','.mjs':'text/javascript','.wasm':'application/wasm'};
(async()=>{
 fs.rmSync(report,{force:true});
 const server=http.createServer((request,response)=>{
  const relative=decodeURIComponent(new URL(request.url,'http://localhost').pathname).replace(/^\//,'') || 'index.html';
  const file=path.resolve(directory,relative);
  if(!file.startsWith(directory+path.sep)){response.writeHead(403).end();return;}
  fs.readFile(file,(error,data)=>{response.writeHead(error?404:200,{'Content-Type':types[path.extname(file)] || 'application/octet-stream','Cache-Control':'no-store','Cross-Origin-Opener-Policy':'same-origin','Cross-Origin-Embedder-Policy':'require-corp'});response.end(error?'Not found':data);});
 });
 await new Promise(resolve=>server.listen(0,'127.0.0.1',resolve));
 let browser;
 try {
  browser=await chromium.launch({channel:process.env.DORA_BROWSER_CHANNEL || 'chrome',headless:true,args:process.platform==='darwin'?['--use-angle=metal']:[]});
  const page=await browser.newPage(),errors=[],warnings=[];
  page.on('pageerror',error=>errors.push(String(error)));
  page.on('console',message=>{if(process.env.DORA_BROWSER_LOG==='1')console.log('BROWSER '+message.type()+': '+message.text());if(message.type()==='error')errors.push(message.text());if(message.type()==='warning')warnings.push(message.text());});
  await page.goto(`http://127.0.0.1:${server.address().port}${process.env.DORA_BROWSER_QUERY || ''}`);
  await page.waitForFunction(()=>window.result,{timeout:90000});
  const result=await page.evaluate(()=>window.result);
  result.browser=await browser.version();result.browser_errors=errors;result.browser_warnings=warnings;
  // Emscripten's warnOnce writes this SDK diagnostic to console.error. Preserve
  // it verbatim; a graphics-only oracle does not certify main-thread latency.
  const blocking='Blocking on the main thread is very dangerous, see https://emscripten.org/docs/porting/pthreads.html#blocking-on-the-main-browser-thread';
  result.browser_diagnostics=errors.filter(value=>value===blocking);
  // Treat GL validation warnings as failures even if a pixel check passed.
  result.passed=Boolean(result.passed && errors.every(value=>value===blocking) && !warnings.some(value=>/GL_INVALID|INVALID_OPERATION|INVALID_VALUE|INVALID_ENUM/.test(value)));
  fs.writeFileSync(report,JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result,null,2));
  if(!result.passed)process.exitCode=1;
 }finally{if(browser)await browser.close();await new Promise(resolve=>server.close(resolve));}
})().catch(error=>{console.error(error);process.exitCode=1;});
