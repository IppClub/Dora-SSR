-- Production validation, assets, response parsing, budget and request lifecycle.
-- Only filesystem, scheduler, base64 and HTTP I/O are deterministic adapters.
local J=require('dkjson')
local requests,loads,jobs,records,cancels,files={},{},{},{},{},{}
local app={runningTime=0}
local mode,response,cancelled,encodeFails,pumpHook,decodeImageFails
local png=string.char(137)..'PNG\r\n\26\n'..string.pack('>I4',13)..'IHDR'..string.pack('>I4I4',32,24)..string.char(8,6,0,0,0)..string.rep('\0',4)
local jpeg=string.char(255,216,255)..string.rep('J',20)
local function decode(text)
 local value,pos,err=J.decode(text)
 if not err and text:sub(pos):find('%S')then return nil,'trailing JSON' end
 return value,err
end
local Path=setmetatable({getExt=function(_,path)return path:match('%.([^./\\]+)$')or''end},{__call=function(_,...)return table.concat({...},'/')end})
local Content={isAbsolutePath=function(_,path)return path:sub(1,1)=='/'end,exist=function()return true end,isdir=function()return true end,
 load=function(_,path)loads[#loads+1]=path;return files[path]end}
package.preload['mime']=function()return {b64=function()if decodeImageFails then return nil end;return 'Zml4dHVyZQ=='end}end
package.preload['Dora']=function()return {
 App=app,Path=Path,Content=Content,json={null=J.null,encode=J.encode,decode=decode},DB={query=function()return records end},
 Director={systemScheduler={schedule=function(_,fn)jobs[#jobs+1]=fn end}},once=function(fn)return fn end,
 HttpClient={cancel=function(_,id)cancels[#cancels+1]=id end,post=function(_,url,headers,body,timeout,callback)
  requests[#requests+1]={body=assert(decode(body)),callback=callback,timeout=timeout}
  if mode=='reject'then return 0 end
  if mode=='network'then callback(nil)
  elseif mode=='huge'then callback(string.rep('x',512*1024+1))
  elseif mode~='deferred'then callback(type(response)=='string'and response or J.encode(response))end
  return #requests
 end},
}end
package.preload['Agent.Utils']=function()return {
 safeJsonDecode=decode,safeJsonEncode=function(value)if encodeFails then return nil end;return J.encode(value)end,
 sanitizeUTF8=function(text)return text end,createStudioModelRequestId=function()return'fixture'end,
}end
package.preload['Agent.Storage.Database']=function()return {TABLE_STEP='agent.AgentSessionStep'}end
local Validation=require('Agent.Tool.Validation')
local Vision=require('Agent.Tool.VisionAnalysis')
local Budget=require('Agent.Tool.VisionBudget')
local function reset()
 requests,loads,jobs,records,cancels={},{},{},{},{}
 files={['/project/a.png']=png,['/project/b.JPG']=jpeg,['/project/参考.png']=png}
 mode,cancelled,encodeFails,pumpHook,decodeImageFails='success',false,false,nil,false
 app.runningTime=0
 response={model='fixture-vision',choices={{message={content='Visible fixture.'},finish_reason='stop'}},usage={prompt_tokens=12,completion_tokens=8,total_tokens=20}}
end
local function begin(options)
 options=options or{}
 local req={workingDir='/project',taskId=1,binding={provider='deepseek',url='https://fixture.invalid',model='fixture-vision',apiKey='fixture-secret'},
  paths={'a.png'},question='Describe the visible scene.',isCancelled=function()return cancelled end}
 for key,value in pairs(options)do req[key]=value end
 if options.noBinding then req.binding=nil end
 local state={done=false}
 local promise=Vision.analyzeImage(req)
 promise['then'](promise,function(_,value)state.done,state.value=true,value end,function(_,err)state.done,state.error=true,err end)
 return state
end
local function pump(state)
 for round=1,30 do
  if state.done then break end
  if pumpHook then pumpHook(round)end
  local current=jobs;jobs={}
  for _,job in ipairs(current)do if not job()then jobs[#jobs+1]=job end end
 end
 assert(state.done,'request did not settle');assert(not state.error,tostring(state.error));return state.value
end
local function run(options)return pump(begin(options))end
local function persist(result)records[#records+1]={'analyze_image',J.encode(result)};return Budget.getVisionTaskUsage(1)end
local function noIO(result)assert(not result.success and #requests==0 and #loads==0,'invalid request performed I/O')end
local passed=0
local function test(name,fn)
 reset();local ok,err=xpcall(fn,debug.traceback);assert(ok,name..': '..tostring(err));passed=passed+1;print('PASS: '..name)
end
test('one PNG request includes dimensions and accounting',function()
 local r=run();assert(r.success and r.images[1].width==32 and r.images[1].height==24)
 assert(r.requestIssued and r.visionBudget.requestCount==1 and r.usage.total_tokens==20)
 local b=persist(r);assert(b.requestCount==1 and b.totalTokens==20 and b.reportedRequests==1)
end)
test('three mixed PNG JPEG Unicode images remain in input order',function()
 local r=run({paths={'a.png','b.JPG','参考.png'}});assert(r.success and #r.images==3)
 local imageBlocks={};for _,block in ipairs(requests[1].body.messages[2].content)do if block.type=='image_url'then imageBlocks[#imageBlocks+1]=block.image_url.url end end
 assert(#imageBlocks==3 and imageBlocks[1]:find('data:image/png;',1,true)==1 and imageBlocks[2]:find('data:image/jpeg;',1,true)==1)
 assert(r.images[2].path=='b.JPG'and r.images[2].width==nil and r.images[3].path=='参考.png')
end)
test('native paths are trimmed without mutating caller arrays',function()
 local paths={' 参考.png '};local r=run({paths=paths});assert(r.success and loads[1]=='/project/参考.png'and r.paths[1]=='参考.png'and paths[1]==' 参考.png ')
end)
test('4 MiB PNG payload boundary accepted',function()files['/project/a.png']=png..string.rep('x',4*1024*1024-#png);assert(run().success)end)
test('image over 4 MiB rejected before network',function()files['/project/a.png']=png..string.rep('x',4*1024*1024-#png+1);assert(not run().success and #requests==0)end)
test('mislabeled nonimage rejected before network',function()files['/project/a.png']='GIF89a'..string.rep('x',30);assert(not run().success and #requests==0)end)
test('PNG zero dimension rejected',function()files['/project/a.png']=png:sub(1,16)..string.pack('>I4',0)..png:sub(21);assert(not run().success and #requests==0)end)
test('truncated PNG header rejected',function()files['/project/a.png']=png:sub(1,20);assert(not run().success and #requests==0)end)
test('missing image rejected before network',function()files['/project/a.png']=nil;assert(not run().success and #requests==0)end)
test('bad second image aborts entire batch before network',function()files['/project/b.JPG']='invalid';assert(not run({paths={'a.png','b.JPG'}}).success and #requests==0)end)
test('base64 failure rejected before network',function()decodeImageFails=true;assert(not run().success and #requests==0)end)
test('JSON encoding failure rejected before network',function()encodeFails=true;assert(not run().success and #requests==0)end)
test('unbound model performs no filesystem or network I/O',function()noIO(run({noBinding=true}))end)
test('encoded array is rejected without compatibility or I/O',function()local r=run({paths='["a.png"]'});noIO(r);assert(r.message:find('must be a JSON array',1,true))end)
test('invalid native array boundaries and paths perform no I/O',function()
 for _,paths in ipairs({{}, {42}, {{'a.png'}}, {'../a.png'}, {'/tmp/a.png'}, {'C:\\a.png'}, {'..\\a.png'}, {'a.svg'}, {''}, {'a.png','a.png','a.png','a.png'}})do noIO(run({paths=paths}))end
end)
test('question Unicode 4000-character boundary accepted',function()assert(run({question=string.rep('中',4000)}).success)end)
test('question and optional text reject over-limit or wrong types',function()
 noIO(run({question=' '}));noIO(run({question=string.rep('中',4001)}));noIO(run({criteria=string.rep('界',4001)}));noIO(run({context=false}))
end)
test('three already-issued requests block before image reads',function()
 for _=1,3 do records[#records+1]={'analyze_image',J.encode({requestIssued=true})}end
 noIO(run())
end)
test('reported token cap blocks before image reads',function()
 records={{'analyze_image',J.encode({requestIssued=true,usage={prompt_tokens=59990,completion_tokens=10,total_tokens=60000}})}};noIO(run())
end)
test('last allowed request counts and clamps remaining budget',function()
 records={{'analyze_image',J.encode({requestIssued=true,usage={prompt_tokens=59990,completion_tokens=9,total_tokens=59999}})},{'analyze_image',J.encode({requestIssued=true})}}
 local r=run();assert(r.success and r.visionBudget.requestCount==3 and r.visionBudget.remaining.analysisRequests==0 and r.visionBudget.remaining.reportedTokens==0)
end)
test('network failure counts issued request without provider data',function()
 mode='network';local r=run();assert(not r.success and r.requestIssued and not r.report and not r.message:find('fixture%-secret'));assert(persist(r).requestCount==1)
end)
test('scheduler rejection does not count unissued request',function()mode='reject';local r=run();assert(not r.success and r.requestIssued==false and persist(r).requestCount==0)end)
test('oversized response rejected and issued request counted',function()mode='huge';local r=run();assert(not r.success and r.requestIssued and r.message:find('size budget',1,true) and persist(r).requestCount==1)end)
test('malformed response rejected without exposing raw payload',function()response='fixture-secret invalid JSON';local r=run();assert(not r.success and r.requestIssued and not r.report and not J.encode(r):find('fixture%-secret'))end)
test('wrong response model rejected but reported usage retained',function()response.model='unexpected';local r=run();assert(not r.success and not r.report and r.usage.total_tokens==20 and persist(r).totalTokens==20)end)
test('length-truncated provider report rejected but usage retained',function()response.choices[1].finish_reason='length';local r=run();assert(not r.success and r.finishReason=='length'and r.usage.total_tokens==20 and persist(r).requestCount==1)end)
test('empty report rejected but usage retained',function()response.choices[1].message.content=' ';local r=run();assert(not r.success and not r.report and persist(r).totalTokens==20)end)
test('valid response without usage still counts issued request',function()response.usage=nil;local r=run();assert(r.success and r.requestIssued and persist(r).reportedRequests==0 and Budget.getVisionTaskUsage(1).requestCount==1)end)
test('oversized text report is bounded and marked truncated',function()response.choices[1].message.content=string.rep('x',16001);local r=run();assert(r.success and #r.report==16000 and r.reportTruncated)end)
test('cancel before request performs no image or network I/O',function()cancelled=true;local r=run();noIO(r);assert(r.cancelled and persist(r).requestCount==0)end)
test('cancel before scheduled dispatch prevents HTTP request',function()pumpHook=function()cancelled=true end;local r=run();assert(not r.success and r.cancelled and #requests==0 and persist(r).requestCount==0)end)
test('cancel pending HTTP request once and ignore late callback',function()
 mode='deferred';pumpHook=function(round)if round==2 then cancelled=true end end
 local state=begin();local r=pump(state);assert(not r.success and r.cancelled and r.requestIssued and #cancels==1 and persist(r).requestCount==1)
 requests[1].callback(J.encode(response));assert(state.value==r and #cancels==1 and Budget.getVisionTaskUsage(1).requestCount==1)
end)
test('HTTP timeout cancels issued request and counts it',function()
 mode='deferred';pumpHook=function(round)if round==2 then app.runningTime=61 end end
 local r=run();assert(not r.success and not r.cancelled and r.requestIssued and #cancels==1 and r.message:find('timed out',1,true)and persist(r).requestCount==1)
end)
test('cancel after provider response preserves issued accounting without report',function()
 pumpHook=function(round)if round==2 then cancelled=true end end
 local r=run();assert(not r.success and r.cancelled and r.requestIssued,'issued request accounting lost in ready-response cancellation race')
 assert(not r.report and r.usage.total_tokens==20 and persist(r).totalTokens==20 and Budget.getVisionTaskUsage(1).requestCount==1)
end)
print('PASS: '..passed..' extended vision lifecycle scenarios.')
