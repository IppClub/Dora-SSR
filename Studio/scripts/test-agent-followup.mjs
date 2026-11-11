import assert from 'node:assert/strict';
import {createServer} from 'node:http';
import {readFile,writeFile,mkdir} from 'node:fs/promises';
import {resolve,extname,dirname} from 'node:path';
import {createHash} from 'node:crypto';
import {createRequire} from 'node:module';
import {build} from 'esbuild';
import {compileAgentCommand} from './compile-agent.mjs';
// Isolated browser database, real Agent Lua/WASM and a deterministic local model.
const {chromium}=createRequire(import.meta.url)(process.env.STUDIO_PLAYWRIGHT_MODULE||'playwright');
const runtime=resolve('../build/studio-agent-host'),requests=[];
const userTest=process.argv.includes('--user-test');
const userTestLua=userTest?await readFile('scripts/fixtures/agent-followup-user-test.lua','utf8'):'';
const lua=String.raw`
_studio_agent_emit('{"kind":"boot"}')
local outerOk,outerError=xpcall(function()
local D=require('Dora')
local sleep=D.sleep
if not D.DB:existDB('agent') then D.DB:exec('ATTACH DATABASE ? AS agent',{D.Path(D.Content.writablePath,'agent.db')}) end
if D.DB:query('PRAGMA agent.user_version')[1][1]==0 then
 local fixture=D.Content:load('/game/fixtures/agent-schema-v1.sql')
 for statement in fixture:gmatch('([^;]+);') do assert(D.DB:exec(statement)>=0,statement) end
 assert(D.DB:exec("INSERT INTO agent.AgentSessionMessage(session_id,task_id,role,content,display_content,created_at,updated_at) VALUES(9999,0,'user','migration sentinel','',1,1)")>=0)
end
local S=require('Agent.Session')
local U=require('Agent.Utils')
local I=require('Agent.Runtime.InputInbox')
local L=require('lualib_bundle')
local M=require('Agent.Runtime.Memory')
local root='/user/followup-test'
D.Content:mkdir(root)
D.Content:save(root..'/init.lua','local value=42\nprint(value)\nreturn value\n')
local created=S.createSession(root,'Follow-up regression')
assert(created.success,created.message)
local sid=created.session.id
assert(D.DB:query('PRAGMA agent.user_version')[1][1]==2,'v1 migration did not run')
assert(D.DB:query("SELECT COUNT(*) FROM agent.AgentSessionMessage WHERE content='migration sentinel'")[1][1]==1,'migration deleted existing messages')
local config={url='MODEL_URL',apiKey='test-only',model='fixture',contextWindow=64000,maxTokens=2048,temperature=0,customOptions={auxiliaryOptions={reasoning_effort="low"}}}
local function send(text,delivery,id,action,inputId)
 local r=S.sendPrompt(sid,text,{},'code',nil,config,20,{delivery=delivery,requestId=id,action=action,inputId=inputId})
 assert(r.success,r.message)
 return r
end
if D.Content:exist(root..'/restart-marker') then
 D.thread(function()
  local ok,err=pcall(function()
   local restored=S.getSession(sid)
   local pending=I.listInputs(sid)
   assert(#pending==1 and pending[1].content=='PRESERVED_QUEUE' and pending[1].held,'restart lost pending input')
   local before=D.DB:query('SELECT COUNT(*) FROM agent.AgentTask')[1][1]
   send('','queue','resume-restored','resume')
   local deadline=D.App.runningTime+15
   repeat sleep(.05) until (S.isRuntimeIdle() and #I.listInputs(sid)==0) or D.App.runningTime>deadline
   assert(#I.listInputs(sid)==0,'restored queue did not drain')
   assert(D.DB:query('SELECT COUNT(*) FROM agent.AgentTask')[1][1]==before+1,'restored input was delivered twice')
   local history=L.__TS__New(M.DualLayerStorage,root,'main'):readSessionState().messages
   local seen={}
   for _,message in ipairs(history) do if message.inputId then assert(not seen[message.inputId],'restart duplicated history');seen[message.inputId]=true end end
   _studio_agent_emit(U.safeJsonEncode({kind='restored',history=history}))
  end)
  if not ok then _studio_agent_emit(U.safeJsonEncode({kind='failure',message=tostring(err)})) end
 end)
 return
end
D.thread(function()
 local ok,err=pcall(function()
  local first=send('ORIGINAL_TASK','queue','original')
  send('AFTER_TASK_A','queue','queued-a')
  send('AFTER_TASK_B','queue','queued-b')
  send('STEER_TOUCH','steer','steer-a')
  assert(send('STEER_TOUCH','steer','steer-a').taskId==first.taskId)
  local pending=I.listInputs(sid)
  assert(#pending==3,U.safeJsonEncode(pending))
  local a=pending[1]
  send('','queue','edit-lock','hold',a.id)
  send('AFTER_TASK_A_EDITED','queue','edit-text','edit',a.id)
  send('','queue','edit-release','release',a.id)
  sleep(.55)
  send('STEER_FINAL_RESPONSE','steer','steer-final')
  local deadline=D.App.runningTime+30
  repeat
   sleep(.05)
   local detail=S.getSession(sid)
   if S.isRuntimeIdle() and #I.listInputs(sid)==0 then
    assert(detail.session.currentTaskStatus=='DONE',U.safeJsonEncode(detail))
    local history=L.__TS__New(M.DualLayerStorage,root,'main'):readSessionState().messages
    local seen={}
    for _,message in ipairs(history) do
     if message.inputId then assert(not seen[message.inputId],'duplicate history');seen[message.inputId]=true end
     if message.inputKind=='steer' then assert(message.taskId==first.taskId,'guide started a new task') end
    end
    assert(D.DB:query('SELECT COUNT(*) FROM agent.AgentTask')[1][1]==3,'expected exactly three tasks')
    send('STOP_TASK','queue','stop-task')
    send('PRESERVED_QUEUE','queue','preserved')
    assert(S.stopSessionTask(sid).success)
    repeat sleep(.05) until S.isRuntimeIdle() or D.App.runningTime>deadline
    assert(I.listInputs(sid)[1].held,'stop did not pause queue')
    local before=D.DB:query('SELECT COUNT(*) FROM agent.AgentTask')[1][1]
    sleep(.2)
    assert(D.DB:query('SELECT COUNT(*) FROM agent.AgentTask')[1][1]==before,'paused queue started')
    local P=require('Agent.Runtime.HistoryProjection')
    local projected=P.projectMessagesForLLMContext({{role='user',content='touch',inputKind='steer',inputId=10,taskId=1}})
    assert(projected[1].inputId==nil and projected[1].inputKind==nil,'metadata leaked to provider')
    assert(P.projectMessagesForCompression({{role='user',content='touch',inputKind='steer'}})[1].inputKind=='steer','compression lost input kind')
    D.Content:save(root..'/restart-marker','1')
    _studio_agent_emit(U.safeJsonEncode({kind='complete',history=history,detail=detail}))
    return
   end
  until D.App.runningTime>deadline
  error('execution timed out: '..U.safeJsonEncode(S.getSession(sid)))
 end)
 if not ok then _studio_agent_emit(U.safeJsonEncode({kind='failure',message=tostring(err)})) end
end)
end,debug.traceback)
if not outerOk then _studio_agent_emit(require('json').encode({kind='failure',message=tostring(outerError)})) end
`;
const sources=(await compileAgentCommand({fullAgent:true})).map(file=>({path:file.path,text:file.text}));
for(const path of ['AgentHostSession.lua','AgentSessionBridge.lua','StudioAgentEntry.lua','StudioAgentYueBuild.lua','StudioAgentXmlBuild.lua'])sources.push({path,text:await readFile('packages/runtime-web/'+path,'utf8')});
sources.push({path:'fixtures/agent-schema-v1.sql',text:await readFile('scripts/fixtures/agent-schema-v1.sql','utf8')});
sources.push({path:'Utils.lua',text:await readFile('../Assets/Script/Lib/Utils.lua','utf8')});
const uiRequire=createRequire(resolve('apps/web/package.json'));
const ui=await build({alias:{react:dirname(uiRequire.resolve('react/package.json')),'react-dom':dirname(uiRequire.resolve('react-dom/package.json'))},stdin:{contents:`import React from 'react';import {createRoot} from 'react-dom/client';import {SharedAgentComposer} from '../../../packages/agent-ui/src/AgentComposer';function Test(){const [prompt,setPrompt]=React.useState('');return <SharedAgentComposer prompt={prompt} loading={false} running onPromptChange={setPrompt} onSend={delivery=>{window.sent.push({prompt,delivery});setPrompt('')}} onStop={()=>window.stops++} pendingInputs={[{id:1,content:'等待当前任务完成后补充测试',delivery:'queue',held:false,status:'pending'},{id:2,content:'需要兼容触屏',delivery:'steer',held:false,status:'pending'}]} onInputAction={async(command,content)=>window.commands.push({command,content})}/>}window.sent=[];window.stops=0;window.commands=[];createRoot(document.getElementById('root')).render(<Test/>);`,loader:'tsx',resolveDir:resolve('apps/web/src')},bundle:true,write:false,format:'esm',platform:'browser',jsx:'automatic',loader:{'.css':'empty'}});
const userTestUi=userTest?await build({alias:{react:dirname(uiRequire.resolve('react/package.json')),'react-dom':dirname(uiRequire.resolve('react-dom/package.json'))},entryPoints:['scripts/fixtures/agent-followup-user-test.tsx'],bundle:true,write:false,format:'esm',platform:'browser',jsx:'automatic',loader:{'.css':'empty'}}):null;
const html=await readFile(resolve(runtime,'dora-player-runtime.html'),'utf8');
const server=createServer(async(req,res)=>{
 try{
  if(req.url==='/user-test'){res.setHeader('Content-Type','text/html');res.end('<!doctype html><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><body style="margin:0;background:#1d1d1d"><div id="root"></div><script type="module" src="/user-test.js"></script>');return;}
  if(req.url==='/user-test.js'&&userTestUi){res.setHeader('Content-Type','text/javascript');res.end(userTestUi.outputFiles[0].text);return;}
  if(req.url==='/ui'){res.setHeader('Content-Type','text/html');res.end('<!doctype html><meta charset="utf-8"><body style="margin:0;background:#1d1d1d"><div id="root" style="max-width:760px;margin:36px auto"></div><script type="module" src="/ui.js"></script>');return;}
  if(req.url==='/ui.js'){res.setHeader('Content-Type','text/javascript');res.end(ui.outputFiles[0].text);return;}
  if(req.url==='/model'){
   let raw='';for await(const part of req)raw+=part;requests.push(JSON.parse(raw));const index=requests.length;
   res.setHeader('Content-Type','text/event-stream');res.flushHeaders();
   const delta=index===1?{role:'assistant',content:'',tool_calls:[0,1].map(i=>({index:i,id:'read-'+i,type:'function',function:{name:'read_file',arguments:JSON.stringify({path:'init.lua',startLine:1,endLine:10})}}))}:{role:'assistant',content:'Fixture completed '+index+'.'};
   setTimeout(()=>{if(!res.destroyed)res.end('data: '+JSON.stringify({id:'fixture-'+index,choices:[{index:0,delta,finish_reason:index===1?'tool_calls':'stop'}]})+'\n\ndata: [DONE]\n\n');},userTest?(index===1?8000:2500):(index===1?350:index===2?700:index>=6?1500:30));return;
  }
  if(req.url==='/'||req.url==='/runtime-uat'){
   const files=[{path:'init.lua',text:(req.url==='/runtime-uat'?userTestLua:lua).replace('MODEL_URL',`http://127.0.0.1:${server.address().port}/model`)},...sources].map(file=>({path:file.path,bytes:[...Buffer.from(file.text)]}));
   const manifest={format:'dora-web-game',version:1,engineVersion:process.env.DORA_TEST_ENGINE_VERSION||'1.10.2',profile:'dora-preset',entry:'init.lua',files:files.map(file=>({path:file.path,url:file.path,size:file.bytes.length,sha256:createHash('sha256').update(Buffer.from(file.bytes)).digest('hex'),startup:true}))};
   const injection=`<script>window.events=[];Module.print=(...args)=>console.log(...args);Module.printErr=(...args)=>console.error(...args);Module.doraStudioAgentEvent=payload=>{const value=JSON.parse(payload);window.events.push(value);if(location.pathname==='/runtime-uat')parent.postMessage({agentUserTest:value},location.origin);};Module.doraStorageId=Promise.resolve('agent-${(userTest?'e':'f').repeat(64)}');Module.doraSnapshot=Promise.resolve({manifest:${JSON.stringify(manifest)},files:${JSON.stringify(files)}.map(file=>({path:file.path,bytes:new Uint8Array(file.bytes)}))});</script>`;
   res.setHeader('Content-Type','text/html');res.end(html.replace(/<script\s+async\s+src=["']?dora-player-runtime\.js["']?\s*>/,match=>injection+match));return;
  }
  const file=resolve(runtime,'.'+new URL(req.url,'http://local').pathname);if(!file.startsWith(runtime+'/'))throw new Error('invalid path');
  res.setHeader('Content-Type',({'.js':'text/javascript','.wasm':'application/wasm','.json':'application/json'})[extname(file)]||'application/octet-stream');res.end(await readFile(file));
 }catch(error){res.statusCode=500;res.end(String(error));}
});
await new Promise(done=>server.listen(0,'127.0.0.1',done));
const browser=await chromium.launch({headless:true,...(process.env.STUDIO_CHROMIUM_EXECUTABLE?{executablePath:process.env.STUDIO_CHROMIUM_EXECUTABLE}:{})});
const output=resolve('../build/agent-followup-qa');await mkdir(output,{recursive:true});
try{
 if(userTest){await (await import('./test-agent-followup-user.mjs')).runUserTest({browser,baseUrl:`http://127.0.0.1:${server.address().port}`,output,requests});}
 else{
 const page=await browser.newPage(),logs=[];page.on('console',message=>logs.push(message.text()));page.on('pageerror',error=>{logs.push(error.stack);console.error(error.message)});
 await page.goto(`http://127.0.0.1:${server.address().port}/`);
 try{await page.waitForFunction(()=>document.documentElement.dataset.doraState==='faulted'||window.events?.some(event=>event.kind==='complete'||event.kind==='failure'),null,{timeout:60000});}catch(error){console.log(await page.evaluate(()=>({state:document.documentElement.dataset,events:window.events,files:Module.FS?.readdir('/game')})));throw new Error(String(error)+'\n'+logs.slice(-35).join('\n'));}
 const events=await page.evaluate(()=>window.events);await writeFile(resolve(output,'runtime.json'),JSON.stringify({events,requests,logs},null,2));
 const result=events.find(event=>event.kind==='complete'||event.kind==='failure');assert.equal(result.kind,'complete',result.message+'\n'+logs.slice(-15).join('\n'));
 assert.ok(requests.length>=5);const second=requests[1].messages,index=second.findIndex(message=>message.role==='assistant'&&message.tool_calls?.length===2);
 assert.ok(index>=0);assert.equal(second[index+1].role,'tool');assert.equal(second[index+2].role,'tool');assert.ok(second.slice(index+3).some(message=>message.role==='user'&&message.content?.includes('STEER_TOUCH')));
 assert.ok(!second.some(message=>message.content?.includes('AFTER_TASK_A')),'future queue leaked into active task');
 assert.ok(requests[2].messages.some(message=>message.content?.includes('STEER_FINAL_RESPONSE')),'guide during final reply was lost');
 assert.deepEqual(requests.slice(3,5).map(request=>request.messages.filter(message=>message.role==='user').at(-1).content),['AFTER_TASK_A_EDITED','AFTER_TASK_B']);
 await page.evaluate(()=>Module.doraSyncUserStorage({afterCurrent:true}));
 await page.reload();await page.waitForFunction(()=>window.events?.some(event=>event.kind==='restored'||event.kind==='failure'),null,{timeout:30000});
 const restoredEvents=await page.evaluate(()=>window.events);const resumed=restoredEvents.find(event=>event.kind==='restored'||event.kind==='failure');assert.equal(resumed.kind,'restored',resumed.message);
 await writeFile(resolve(output,'restored.json'),JSON.stringify(restoredEvents,null,2));
 await page.goto(`http://127.0.0.1:${server.address().port}/ui`);const input=page.getByRole('textbox',{name:'Agent 描述'});
 await input.fill('queued');await input.press('Enter');assert.equal((await page.evaluate(()=>window.sent))[0].delivery,'queue');
 const modifier=await page.evaluate(()=>/Mac|iPhone|iPad/.test(navigator.platform))?'Meta':'Control';
 await input.fill('guided');await input.press(modifier+'+Enter');assert.equal((await page.evaluate(()=>window.sent))[1].delivery,'steer');
 await input.fill('one');await input.press('Shift+Enter');await input.type('two');assert.equal(await input.inputValue(),'one\ntwo');
 await input.press('Escape');assert.equal(await page.evaluate(()=>window.stops),1);
 await page.getByRole('button',{name:'后续消息设置'}).click();await page.getByRole('menuitem',{name:'引导 · 补充当前任务的要求'}).click();await page.keyboard.press('Escape');
 await input.fill('default guide');await input.press('Enter');assert.equal((await page.evaluate(()=>window.sent))[2].delivery,'steer');
 await input.fill('temporary queue');await input.press(modifier+'+Enter');assert.equal((await page.evaluate(()=>window.sent))[3].delivery,'queue');
 await page.getByRole('menu').waitFor({state:'hidden'});await page.waitForTimeout(200);await page.screenshot({path:resolve(output,'composer-desktop.png')});await page.setViewportSize({width:390,height:844});await page.screenshot({path:resolve(output,'composer-mobile.png')});
 await page.reload();const restored=page.getByRole('textbox',{name:'Agent 描述'});await restored.fill('persisted');await restored.press('Enter');assert.equal((await page.evaluate(()=>window.sent))[0].delivery,'steer');
 console.log('PASS: real Lua/WASM FIFO, mid-tool/final-reply steering, duplicate IDs, editing, stop preservation; desktop/mobile composer and shortcuts.');
}
}finally{await browser.close();await new Promise(done=>server.close(done));}
