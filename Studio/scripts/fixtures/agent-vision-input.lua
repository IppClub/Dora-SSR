-- Production Lua modules, deterministic engine/network adapters. No real keys.
local J=require('dkjson')
local requests,loads,jobs={},{},{}
local function decode(text)
 local value,pos,err=J.decode(text)
 if not err and text:sub(pos):find('%S') then return nil,'trailing JSON data' end
 return value,err
end
local Path=setmetatable({getExt=function(_,path)return path:match('%.([^./\\]+)$') or '' end},{__call=function(_,root,path)return root..'/'..path end})
local Content={isAbsolutePath=function(_,path)return path:sub(1,1)=='/' end,exist=function()return true end,isdir=function()return true end,
 load=function(_,path)loads[#loads+1]=path;return 'fixture image bytes' end}
package.preload['mime']=function()return {b64=function()return 'Zml4dHVyZQ==' end}end
package.preload['Dora']=function()return {
 Path=Path,Content=Content,App={runningTime=0},json={null=J.null,encode=J.encode,decode=decode},
 Director={systemScheduler={schedule=function(_,fn)jobs[#jobs+1]=fn end}},once=function(fn)return fn end,
 HttpClient={cancel=function()end,post=function(_,url,headers,body,timeout,callback)
  requests[#requests+1]=assert(decode(body))
  callback(J.encode({model='fixture-vision',choices={{message={content='The image contains a gold square.'},finish_reason='stop'}},usage={prompt_tokens=12,completion_tokens=8,total_tokens=20}}))
  return #requests
 end},
}end
package.preload['Agent.Utils']=function()return {safeJsonDecode=decode,safeJsonEncode=J.encode,sanitizeUTF8=function(text)return text end,createStudioModelRequestId=function()return 'fixture' end}end
package.preload['Agent.Tools']=function()return {}end
package.preload['Agent.Runtime.Policy']=function()return {}end
package.preload['Agent.Tool.Handlers']=function()return {AGENT_TOOL_HANDLERS={}}end
package.preload['Agent.Tool.VisionAssets']=function()return {inspectImage=function()return {format='png',width=64,height=64}end}end
package.preload['Agent.Tool.VisionBudget']=function()return {VISION_MAX_ANALYSIS_REQUESTS=3,VISION_MAX_REPORTED_TOKENS=60000,
 getVisionTaskUsage=function()return {requestCount=0,totalTokens=0,reportedRequests=0,inputTokens=0,outputTokens=0}end,
 getVisionBudgetState=function(value)return value end}end
local Parsing=require('Agent.Runtime.DecisionParsing')
local Registry=require('Agent.Tool.Registry')
local Validation=require('Agent.Tool.Validation')
local Binding=require('Agent.Tool.VisionBinding')
-- Capability routing must agree with the schema without broadening credential reuse.
local routes={
 {'https://api.deepseek.com/chat/completions','deepseek'},
 {' https://api.deepseek.com/v1/chat/completions/ ','deepseek'},
 {'https://open.bigmodel.cn/api/coding/paas/v4/chat/completions','glm-coding-cn'},
 {'https://open.bigmodel.cn/api/paas/v4/chat/completions'},
 {'https://relay.invalid/v1/chat/completions'},
 {'https://api.deepseek.com.relay.invalid/chat/completions'},
}
for _,route in ipairs(routes)do
 local binding=Binding.resolveVisionBinding({url=route[1],apiKey='test-only',model='text-model'})
 assert((binding and binding.provider)==route[2],'unexpected vision route: '..route[1])
 for _,role in ipairs({'main','sub'})do for _,mode in ipairs({'code','plan'})do
  local tools=Registry.getAllowedToolsForRole(role,{workMode=mode,disabledAgentTools=binding and {} or {'analyze_image'}})
  local found=false;for _,name in ipairs(tools)do if name=='analyze_image'then found=true end end
  assert(found==(binding~=nil),'vision schema disagrees with route capability')
 end end
end
assert(not Binding.resolveVisionBinding({url=routes[1][1],apiKey=' ',model='text-model'}),'empty credential enabled vision')
local gateway={url='https://studio.invalid/agent-host/chat',apiKey='studio-agent',model='text-model',studioGateway=true,
 studioVision={provider='deepseek',model='deepseek-flash',url='https://studio.invalid/agent-host/1/vision/deepseek'}}
assert(Binding.resolveVisionBinding(gateway).studioGateway,'valid Studio route rejected')
gateway.studioVision.model='unregistered-model'
assert(not Binding.resolveVisionBinding(gateway),'unregistered Studio model enabled vision')
gateway.studioVision=nil
assert(not Binding.resolveVisionBinding(gateway),'missing Studio route enabled vision')
print('PASS: vision route and role/mode capability matrix; unsupported endpoints and empty credentials stay disabled; Studio route validation.')
local question='Describe ["gold"] literally; do not reinterpret this text.'
local function validate(paths)
 local args=Parsing.parseToolCallArguments('analyze_image',J.encode({paths=paths,question=question}))
 assert(args.success~=false,'outer arguments failed to parse')
 return Parsing.validateDecision('analyze_image',args)
end
local good={'.agent/vision/a.png','assets/参考.JPG'}
assert(validate(good).success,'native array rejected')
local result=validate(J.encode(good))
assert(not result.success and result.message:find('must be a JSON array',1,true),'encoded array must fail with actionable type error')
local native=validate(good)
assert(native.params.question==question,'free text was coerced')
assert(validate({' .agent/vision/a.png '}).params.paths[1]==good[1],'native paths not trimmed')
local bad={'plain.png','["a.png"','{"path":"a.png"}','null','42','[]','[42]','[["a.png"]]',J.encode(J.encode(good)),
 '["../outside.png"]','["/tmp/outside.png"]',J.encode({'C:\\outside.png'}),J.encode({'..\\outside.png'}),'["a.svg"]','[""]','["a.png","b.png","c.png","d.png"]'}
for _,paths in ipairs(bad)do assert(not validate(paths).success,'invalid input accepted: '..paths)end
local invalidArrays={{},{42},{{'a.png'}},{'../outside.png'},{'/tmp/outside.png'},{'C:\\outside.png'},{'..\\outside.png'},{'a.svg'},{''},{'a.png','b.png','c.png','d.png'}}
for _,paths in ipairs(invalidArrays)do assert(not validate(paths).success,'invalid native array accepted: '..J.encode(paths))end
local schema
for _,tool in ipairs(Registry.buildDecisionToolSchema('main',20))do if tool['function'].name=='analyze_image' then schema=tool['function'].parameters end end
assert(schema.properties.paths.type=='array','model-facing schema weakened')
assert(not schema.properties.paths.description:find('XML',1,true),'obsolete XML example retained')
assert(schema.properties.paths.description:find('Do not JSON%-stringify'),'native array guidance missing')
local Vision=require('Agent.Tool.VisionAnalysis')
local function await(promise)
 local done,value,failure=false
 promise['then'](promise,function(_,answer)done,value=true,answer end,function(_,reason)done,failure=true,reason end)
 for _=1,20 do if done then break end;local current=jobs;jobs={};for _,job in ipairs(current)do if not job()then jobs[#jobs+1]=job end end end
 assert(done,'vision promise did not settle');assert(not failure,tostring(failure));return value
end
local function analyze(paths)
 return await(Vision.analyzeImage({workingDir='/project',taskId=1,binding={provider='deepseek',url='https://fixture.invalid',model='fixture-vision',apiKey='test-only'},paths=paths,question=question,isCancelled=function()return false end}))
end
local direct=analyze({' .agent/vision/a.png ','assets/b.jpg'})
assert(direct.success,direct.message)
assert(#loads==2 and loads[1]=='/project/.agent/vision/a.png' and loads[2]=='/project/assets/b.jpg','executor ignored normalized paths')
assert(#direct.paths==2 and direct.paths[1]==good[1],'result did not preserve normalized evidence paths')
local attached=0
for _,block in ipairs(requests[1].messages[2].content)do if block.type=='image_url' then attached=attached+1 end end
assert(attached==2,'incorrect number of image attachments')
for _,paths in ipairs(invalidArrays)do assert(not analyze(paths).success and #requests==1 and #loads==2,'invalid native array reached file or provider I/O')end
assert(not analyze(J.encode(good)).success and #requests==1,'encoded array reached provider')
assert(not analyze(J.encode(J.encode(good))).success and #requests==1,'double-encoded array reached provider')
print('PASS: reject real provider string-array replay with actionable error; native arrays; malformed/nested/escaping/unsupported/over-limit inputs; unchanged array schema; normalized executor paths and two image attachments; invalid inputs never reach provider.')
