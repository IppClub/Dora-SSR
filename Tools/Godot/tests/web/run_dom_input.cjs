// Trusted browser input only: no Godot input function or SDL event injection.
const {chromium}=require(process.env.DORA_PLAYWRIGHT_MODULE||'playwright');
const fs=require('node:fs'),path=require('node:path'),http=require('node:http'),crypto=require('node:crypto');
const directory=path.resolve(process.argv[2]),output=path.resolve(process.argv[3]);fs.mkdirSync(output,{recursive:true});
const report=path.join(output,'verification.json');fs.rmSync(report,{force:true});
const types={'.html':'text/html','.js':'text/javascript','.mjs':'text/javascript','.wasm':'application/wasm','.json':'application/json'};
(async()=>{
 const server=http.createServer((request,response)=>{const relative=decodeURIComponent(new URL(request.url,'http://localhost').pathname).replace(/^\//,'')||'index.html',file=path.resolve(directory,relative);if(relative==='favicon.ico'){response.writeHead(204).end();return;}if(!file.startsWith(directory+path.sep)){response.writeHead(403).end();return;}fs.readFile(file,(error,data)=>{response.writeHead(error?404:200,{'Content-Type':types[path.extname(file)]||'application/octet-stream','Cross-Origin-Opener-Policy':'same-origin','Cross-Origin-Embedder-Policy':'require-corp','Cache-Control':'no-store'});response.end(error?'Not found':data);});});
 await new Promise(resolve=>server.listen(0,'127.0.0.1',resolve));let browser,page,browserPid;const logs=[],errors=[],warnings=[];
 try{
  browser=await chromium.launch({channel:'chrome',headless:process.env.DORA_DOM_HEADED!=='1',args:['--use-angle=metal','--autoplay-policy=no-user-gesture-required']});
  const context=await browser.newContext({viewport:{width:1280,height:720},deviceScaleFactor:1,hasTouch:true});page=await context.newPage();
  // Playwright keeps every page artificially focused by default. Restore native focus.
  const focusSession=await context.newCDPSession(page);await focusSession.send('Emulation.setFocusEmulationEnabled',{enabled:false});
  page.on('pageerror',error=>errors.push(String(error)));page.on('console',message=>{const text=message.text();logs.push(text);console.log('BROWSER '+message.type()+': '+text);if(message.type()==='error'||text.includes('[error]'))errors.push(text);if(message.type()==='warning')warnings.push(text);});
  await page.addInitScript(()=>{window.domObserved=[];for(const type of ['pointerdown','pointerup','keydown','keyup','keypress','input','compositionstart','compositionupdate','compositionend','blur','focus'])window.addEventListener(type,event=>window.domObserved.push({type,trusted:event.isTrusted,key:event.key||'',data:event.data||'',pointerType:event.pointerType||''}),true);});
  const wait=async expression=>{const deadline=Date.now()+15000;while(Date.now()<deadline){const match=logs.join('\n').match(expression);if(match)return match;if(errors.some(value=>!value.startsWith('Blocking on the main thread')))throw new Error('Native input runtime error');await page.waitForTimeout(50);}throw new Error('Missing log '+expression);};
  await page.goto(`http://127.0.0.1:${server.address().port}`);
  await focusSession.send('Emulation.setFocusEmulationEnabled',{enabled:false});
  if(process.env.DORA_DOM_HEADED==='1'&&process.platform==='darwin') {
   const browserSession=await browser.newBrowserCDPSession();
   const processes=await browserSession.send('SystemInfo.getProcessInfo');
   const pid=processes.processInfo.find(value=>value.type==='browser').id;browserPid=pid;
   require('node:child_process').execFileSync('osascript',['-e',`tell application "System Events" to set frontmost of first application process whose unix id is ${pid} to true`]);
  }
  await page.bringToFront();
  console.log('Native page focus: '+await page.evaluate(()=>document.hasFocus()));
  await wait(/GODOT_DOM_IME_FOCUS active=1/);
  await page.waitForFunction(()=>{const input=document.querySelector('#dora-ime-input');return input&&!input.disabled;});
  const autoEnabled=await page.evaluate(()=>{const input=document.querySelector('#dora-ime-input');return {enabled:Boolean(input&&!input.disabled),left:input?.style.left||'',top:input?.style.top||''};});
  const first=await wait(/DORA_DOM_TARGET 1 x=([\d.-]+) y=([\d.-]+)/),x=Number(first[1]),y=Number(first[2]);
  await page.mouse.click(x,y);await page.waitForFunction(()=>document.activeElement?.id==='dora-ime-input');await page.keyboard.press('a');
  await page.keyboard.down('Shift');await page.keyboard.press('a');await page.mouse.click(x,y);await page.keyboard.up('Shift');
  await page.keyboard.press('Control+a');await page.keyboard.type('z');
  await page.keyboard.insertText('中文');
  await page.waitForTimeout(200);await page.evaluate(()=>Module.FS.writeFile('/user/dom-step-1','done'));
  const second=await wait(/DORA_DOM_TARGET 2 x=([\d.-]+) y=([\d.-]+)/),sx=Number(second[1]),sy=Number(second[2]);
  await page.touchscreen.tap(sx,sy);await page.mouse.click(sx,sy,{button:'right'});await page.keyboard.press('Escape');
  await page.keyboard.down('a');await page.mouse.move(sx,sy);await page.mouse.down();await page.keyboard.press('F8');await wait(/GODOT_DOM_ARMED/);
  console.log('Before focus switch: '+await page.evaluate(()=>document.hasFocus()));
  if(browserPid) {
   require('node:child_process').execFileSync('osascript',['-e','tell application "Finder" to activate']);
   await page.waitForTimeout(500);
   console.log('After focus switch: '+await page.evaluate(()=>document.hasFocus()));
   require('node:child_process').execFileSync('osascript',['-e',`tell application "System Events" to set frontmost of first application process whose unix id is ${browserPid} to true`]);
   await page.bringToFront();
  } else {
   const other=await context.newPage();const otherFocus=await context.newCDPSession(other);await otherFocus.send('Emulation.setFocusEmulationEnabled',{enabled:false});await other.goto('about:blank');await otherFocus.send('Emulation.setFocusEmulationEnabled',{enabled:false});await other.bringToFront();await other.mouse.click(10,10);await other.waitForTimeout(250);await page.bringToFront();await other.close();
  }
  await page.waitForTimeout(200);await page.keyboard.up('a');await page.mouse.up();
  await wait(/GODOT_DOM_FOCUS released=1/);await page.evaluate(()=>Module.FS.writeFile('/user/dom-step-2','done'));await wait(/DORA_DOM_DONE/);
  await page.waitForFunction(()=>document.querySelector('#dora-ime-input')?.disabled===true);
  const imeReleased=await page.evaluate(()=>document.querySelector('#dora-ime-input')?.disabled===true);
  const observed=await page.evaluate(()=>window.domObserved);await page.evaluate(()=>Module.ccall('dora_web_stop','number',[],[]));await page.waitForFunction(()=>document.documentElement.dataset.doraState==='stopped',null,{timeout:15000});
  const source=logs.join('\n'),pointers=[...source.matchAll(/GODOT_DOM_POINTER button=(\d+) pressed=(\d+) x=([\d.-]+) y=([\d.-]+) shift=(\d+)/g)].map(match=>({button:Number(match[1]),pressed:Number(match[2]),x:Number(match[3]),y:Number(match[4]),shift:Number(match[5])}));
  const keys=[...source.matchAll(/GODOT_DOM_KEY A pressed=(\d+) shift=(\d+) ctrl=(\d+) state=(\d+)/g)].map(match=>({pressed:Number(match[1]),shift:Number(match[2]),ctrl:Number(match[3]),state:Number(match[4])}));
  const assertions={automatic_ime:autoEnabled.enabled,ime_position:autoEnabled.left!=='0px'||autoEnabled.top!=='0px',ime_released:imeReleased,line_edit:/GODOT_DOM_LINE text=.*中文/.test(source),right_button:pointers.some(p=>p.button===2&&p.pressed===1),pointer:pointers.some(p=>p.button===1&&p.pressed===1&&Math.abs(p.x-120)<=2&&Math.abs(p.y-90)<=2),transformed_touch:pointers.some(p=>p.button===1&&p.pressed===1&&Math.abs(p.x-200)<=2&&Math.abs(p.y-120)<=2),key:keys.some(k=>k.pressed===1&&k.state===1),shift:keys.some(k=>k.pressed===1&&k.shift===1),ctrl:keys.some(k=>k.pressed===1&&k.ctrl===1),pointer_shift:pointers.some(p=>p.pressed===1&&p.shift===1),text:/GODOT_DOM_TEXT codepoint=122/.test(source),unicode:/GODOT_DOM_TEXT codepoint=20013/.test(source)&&/GODOT_DOM_TEXT codepoint=25991/.test(source),focus:/GODOT_DOM_FOCUS released=1/.test(source),trusted_mouse:observed.some(e=>e.type==='pointerdown'&&e.pointerType==='mouse'&&e.trusted),trusted_touch:observed.some(e=>e.type==='pointerdown'&&e.pointerType==='touch'&&e.trusted),trusted_text:observed.some(e=>e.type==='input'&&e.data==='中文'&&e.trusted),trusted_blur:observed.some(e=>e.type==='blur'&&e.trusted),trusted_keyboard:observed.some(e=>e.type==='keydown'&&e.trusted)};
  const artifacts=Object.fromEntries(['dora-player-runtime.js','dora-player-runtime.wasm','dora-web-manifest.json','godot/dora-godot.js','godot/dora-godot.wasm'].map(name=>[name,crypto.createHash('sha256').update(fs.readFileSync(path.join(directory,name))).digest('hex')]));
  const passed=Object.values(assertions).every(Boolean)&&!errors.some(value=>!value.startsWith('Blocking on the main thread'))&&!warnings.some(value=>/INVALID_OPERATION|INVALID_ENUM|INVALID_VALUE/.test(value));
  fs.writeFileSync(report,JSON.stringify({passed,scope:'Actual Godot LineEdit-driven Dora IME lifecycle plus browser mouse/touch/keyboard/committed Unicode text and page-focus input; OS composition UI remains separate',assertions,auto_ime:autoEnabled,artifacts,pointers,keys,observed,logs,browser_errors:errors,browser_warnings:warnings},null,2)+'\n');if(!passed)process.exitCode=1;
 }catch(error){fs.writeFileSync(report,JSON.stringify({passed:false,error:String(error),observed:page?await page.evaluate(()=>window.domObserved).catch(()=>[]):[],logs,browser_errors:errors,browser_warnings:warnings},null,2)+'\n');throw error;}
 finally{if(browser)await browser.close();await new Promise(resolve=>server.close(resolve));}
})().catch(error=>{console.error(error);process.exitCode=1;});
