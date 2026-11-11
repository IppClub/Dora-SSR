-- Isolated browser user-test host. Uses the production Session and inbox.
local D = require('Dora')
local S = require('Agent.Session')
local U = require('Agent.Utils')
local L = require('lualib_bundle')
local M = require('Agent.Runtime.Memory')
local root = '/user/followup-user-test'
D.Content:mkdir(root)
D.Content:save(root .. '/init.lua', 'print("User test project")\n')
local created = S.createSession(root, '后续消息用户测试')
assert(created.success, created.message)
local sid = created.session.id
local config = {url='MODEL_URL',apiKey='test-only',model='fixture',contextWindow=64000,maxTokens=2048,temperature=0,customOptions={auxiliaryOptions={reasoning_effort='low'}}}
local function emit(value) _studio_agent_emit(U.safeJsonEncode(value)) end
local function snapshot()
 local detail = S.getSession(sid)
 emit({kind='state',detail=detail,history=L.__TS__New(M.DualLayerStorage,root,'main'):readSessionState().messages,idle=S.isRuntimeIdle()})
end
_studio_agent_request = function(encoded)
 local request = U.safeJsonDecode(encoded)
 local ok,result = pcall(function()
  if request.operation == 'stop' then return S.stopSessionTask(sid) end
  if request.operation == 'continue' then return S.continuePrompt(sid,{},nil,config) end
  if request.operation == 'prompt' then
   local submission = request.submission or {}
   submission.requestId = request.requestId
   return S.sendPrompt(sid,request.prompt,{},'code',nil,config,20,submission)
  end
  error('unsupported user-test operation')
 end)
 emit({kind='ack',requestId=request.requestId,result=ok and result or {success=false,message=tostring(result)}})
 snapshot()
end
D.threadLoop(function() snapshot();D.sleep(.1);return false end)
