-- Isolated DB fixture; no LLM calls and no edits to user sessions.
local D=require("Dora")
local S=require("Agent.Session")
local T=require("Agent.Storage.Database")
local H=require("Dev.Mobile.RemixHistory")
local R=require("Dev.Mobile.RemixTranscript")
local root=D.Path(D.Content.writablePath,"remix-history-test-"..tostring(D.App.runningTime))
local result="/tmp/dora-remix-history.result"
local function expect(ok,message) assert(ok,message) end
local function find(n,tag)
 if n.tag==tag then return n end
 local found;n:eachChild(function(c) found=find(c,tag);return found~=nil end);return found
end
D.thread(function()
 assert(D.Content:mkdir(root))
 local created=S.createSession(root,"History limit test")
 assert(created.success,created.message)
 local id=created.session.id
 local transcript
 local uiHost
 local hidden={}
 D.Director.systemUI:eachChild(function(n)
  if n.tag=="mobile-feed" then hidden[n]=n.visible;n.visible=false end
  return false
 end)
 local ok,err=xpcall(function()
  local messageIds={}
  local function addRound(round,replies)
   D.DB:exec("INSERT INTO "..T.TABLE_TASK.." (status,created_at,updated_at) VALUES ('DONE',1,1)")
   local task=D.DB:query("SELECT last_insert_rowid()")[1][1]
   D.DB:exec("UPDATE "..T.TABLE_SESSION.." SET current_task_id=?,status='DONE',current_task_status='DONE' WHERE id=?",{task,id})
   for m=0,replies do
    D.DB:exec("INSERT INTO "..T.TABLE_MESSAGE.." (session_id,task_id,role,content,created_at,updated_at) VALUES (?,?,?,?,1,1)",
     {id,task,m==0 and "user" or "assistant","第 "..round.." 轮 / "..m.."：完整消息"})
    if m==0 then messageIds[round]=D.DB:query("SELECT last_insert_rowid()")[1][1] end
   end
   D.DB:exec("INSERT INTO "..T.TABLE_STEP.." (session_id,task_id,step,tool,status,reason,created_at,updated_at) VALUES (?,?,1,'build','DONE',?,1,1)",
    {id,task,"第 "..round.." 轮工作"})
  end
  local view={recentRounds=10,currentTaskStepsOnly=true}
  local empty=S.getSession(id,view)
  expect(#empty.messages==0 and not empty.hasEarlierMessages,"empty session")
  for i=1,10 do addRound(i,2) end
  local ten=S.getSession(id,view)
  expect(#ten.messages==30 and not ten.hasEarlierMessages,"ten rounds must keep multiple replies")
  addRound(11,2)
  local eleven=S.getSession(id,view)
  expect(#eleven.messages==30 and eleven.messages[1].id==messageIds[2] and eleven.hasEarlierMessages,"eleven-round boundary")
  addRound(12,0)
  local limited=S.getSession(id,view)
  local full=S.getSession(id)
  expect(#limited.messages==28 and limited.messages[1].id==messageIds[3],"pending latest round cut incorrectly")
  expect(#limited.steps==1 and limited.steps[1].taskId==limited.session.currentTaskId,"historical work cards loaded")
  expect(#full.messages==34 and #full.steps==12 and not full.hasEarlierMessages,"full Web IDE history changed")
  local projected=H.remixHistory(full)
  expect(#projected.messages==28 and #projected.steps==1 and projected.hasEarlierMessages,"custom adapter not bounded")
  local revision=R.remixDisplayRevision(full)
  full.messages[1].content="hidden historical edit"
  full.steps[#full.steps].reason="hidden old work"
  expect(revision==R.remixDisplayRevision(full),"hidden history affects display revision")
  full.messages[#full.messages].content="当前轮次正文持续更新"
  expect(revision~=R.remixDisplayRevision(full),"latest content not refreshing")
  transcript=R.createRemixTranscript()
  transcript.node:addTo(D.Director.systemUI)
  transcript.node.scaleX=D.App.devicePixelRatio;transcript.node.scaleY=D.App.devicePixelRatio
  transcript:update(full,math.max(200,D.App.visualSize.width-32),math.max(200,D.App.visualSize.height-60),1,true)
  expect(find(transcript.node,"remix-history-limit"),"missing history notice")
  expect(not find(transcript.node,"message-"..messageIds[1]) and find(transcript.node,"message-"..messageIds[3]),"UI message boundary")
  expect(not find(transcript.node,"step-"..full.steps[#full.steps].id),"old work card rendered")
  transcript:update(full,400,500,1,false)
  expect(find(transcript.node,"remix-history-limit"),"English notice missing")
  addRound(13,2)
  local next=S.getSession(id,view)
  expect(next.messages[1].id==messageIds[4] and #next.messages==28,"new round did not advance window")
  expect(#S.getSession(id).messages==37,"history was deleted")
  expect(S.createSession(root,"reopen").session.id==id,"reopening did not reuse session")
  transcript.node:removeFromParent(true);transcript=nil
  uiHost=require("Dev.Mobile.Remix").startMobileRemix({entry={id="history-test",title="历史上限验收",workDir=root},onBack=function() end,onPlay=function() end})
  D.sleep(0.4)
  expect(find(uiHost,"remix-history-limit"),"default Remix adapter missing limit notice")
  expect(not find(uiHost,"message-"..messageIds[3]) and find(uiHost,"message-"..messageIds[4]),"default Remix adapter boundary")
  find(uiHost,"remix-scroll").offset=D.Vec2.zero
  D.sleep(0.1)
  D.App:saveScreenshot("/tmp/dora-remix-history-limit")
  D.sleep(0.2)
 end,debug.traceback)
 if transcript then transcript.node:removeFromParent(true) end
 if uiHost then uiHost:removeFromParent(true) end
 for n,visible in pairs(hidden) do if n.parent then n.visible=visible end end
 S.deleteSessionsByProjectRoot(root)
 D.Content:remove(root)
 D.Content:save(result,ok and "passed empty=1 ten=1 eleven=1 multipleReplies=1 pendingRound=1 currentStepsOnly=1 fullHistoryUnchanged=1 revision=1 notice=1 reopen=1 windowAdvance=1\n" or "failed "..tostring(err))
 if not ok then error(err) end
end)
