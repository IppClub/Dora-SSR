-- Real Dora UI, deterministic services; no model calls or user-session writes.
local D = require("Dora")
local R = require("Dev.Mobile.Remix")
local function find(node, tag)
	if node.tag == tag then return node end
	local found
	node:eachChild(function(c) found = find(c, tag); return found ~= nil end)
	return found
end
local session = {id=91999, projectRoot=D.Content.assetPath, title="Button test", kind="main", rootSessionId=91999,
	memoryScope="main", workMode="code", status="IDLE", currentTaskStatus="IDLE", currentTaskId=92999, createdAt=1, updatedAt=1}
local sends, stops, rejectStop = 0, 0, true
local config = {url="https://example.invalid", model="test", apiKey="test", contextWindow=64000, temperature=0, maxTokens=1000, supportsFunctionCalling=true}
local services = {
	createSession=function() return {success=true, session=session} end,
	getSession=function() return {success=true, session=session, relatedSessions={}, messages={}, steps={}, checkpoints={}, hasActivePlan=false} end,
	setWorkMode=function(_, mode) session.workMode=mode; return {success=true} end,
	sendPrompt=function() sends=sends+1; session.status="RUNNING"; session.currentTaskStatus="RUNNING"; return {success=true,sessionId=session.id,taskId=session.currentTaskId} end,
	stopSessionTask=function() stops=stops+1; return rejectStop and {success=false,message="Test rejection"} or {success=true,stopping=true} end,
	respondQuestionnaire=function() error("Unexpected questionnaire") end,
	getActiveLLMConfig=function() return {success=true,id=94999,config=config} end,
	getLLMConfig=function() return {success=true,id=94999,config=config} end,
	getLLMConfigSummaries=function() return {{id=94999,name="Test",model="test",active=true}} end,
}
D.thread(function()
	local previousSize = D.App.winSize
	local hidden = {}
	D.Director.systemUI:eachChild(function(n) if n.visible then hidden[#hidden+1]=n; n.visible=false end; return false end)
	D.App.winSize=D.Size(390,844); D.sleep(0.3)
	local host=R.startMobileRemix({entry={id="primary-action-test", title="按钮切换验证", workDir=D.Content.assetPath}, services=services, onBack=function() end, onPlay=function() end})
	local ok, err = xpcall(function()
		local function checkSpacing(button)
			local input=assert(find(host,"remix-input"))
			local plan=assert(find(host,"remix-mode-plan"))
			local code=assert(find(host,"remix-mode-code"))
			local function equal(a,b,message) assert(math.abs(a-b)<0.01,message) end
			equal(button.y,input.y,"Input/action bottom alignment")
			equal(button.height,input.height,"Input/action height alignment")
			equal(button.x-input.x-input.width,12,"Input/action gap")
			equal(plan.y-input.y-input.height,12,"Composer row gap")
			equal(code.x-plan.x-plan.width,12,"Mode button gap")
			equal(plan.x,input.x,"Left edges")
			equal(code.x+code.width,button.x+button.width,"Right edges")
			assert(math.abs(plan.width-code.width)<=1,"Mode widths differ")
			equal(input.x,D.App.safeArea.x+16,"Safe-area left inset")
			equal(button.x+button.width,D.App.safeArea.x+D.App.safeArea.width-16,"Safe-area right inset")
			local transcript=assert(find(host,"remix-transcript"))
			local status=assert(find(host,"remix-status"))
			local errorLabel=find(host,"remix-error")
			local lower=errorLabel or plan
			equal(transcript.y-lower.y-lower.height,12,"Transcript bottom gap")
			if errorLabel then equal(errorLabel.y-plan.y-plan.height,12,"Error gap") end
			equal(status.y-transcript.y-transcript.height,12,"Transcript top gap")
			equal(find(host,"remix-back").y-status.y-status.height,12,"Header/status gap")
			local scroll=assert(find(host,"remix-scroll"))
			equal(scroll.y-scroll.area.height/2,0,"Transcript has hidden footer spacing")
			assert(input.width>0,"Non-positive input width")
		end
		local function action(mode)
			assert(not find(host, mode=="send" and "remix-stop" or "remix-send"), "Send and Stop visible together")
			local button=assert(find(host,"remix-"..mode),"Missing "..mode)
			checkSpacing(button)
			return button
		end
		local send=action("send")
		local x,y,w,h=send.x,send.y,send.width,send.height
		local input=assert(find(host,"remix-input"))
		input:emit("TextInput","调整游戏")
		input:emit("TextEditing","ni")
		send:emit("Tapped"); assert(sends==0,"Sent unfinished IME composition")
		input:emit("TextEditing","")
		D.sleep(0.2); D.App:saveScreenshot("/tmp/dora-remix-primary-send"); D.sleep(0.2)
		send:emit("Tapped"); assert(sends==1)
		local stop=action("stop")
		assert(stop.x==x and stop.y==y and stop.width==w and stop.height==h,"Action slot moved")
		assert(find(host,"remix-input")==input,"Send/Stop transition replaced IME node")
		D.sleep(0.2); D.App:saveScreenshot("/tmp/dora-remix-primary-stop"); D.sleep(0.2)
		input:emit("TextInput","下一轮草稿"); input:emit("TextEditing","ni")
		host.visible=false; stop:emit("Tapped"); assert(stops==0,"Hidden stop acted"); host.visible=true
		stop:emit("Tapped"); assert(stops==1 and action("stop").touchEnabled,"Rejected stop did not remain retryable")
		rejectStop=false; action("stop"):emit("Tapped")
		assert(stops==2 and not action("stop").touchEnabled,"Stop request not disabled")
		action("stop"):emit("Tapped"); assert(stops==2,"Duplicate stop request")
		assert(find(host,"remix-input")==input and find(host,"remix-input-text").text=="下一轮草稿ni","Stop lost draft/composition")
		session.currentTaskFinalizing=true; session.status="DONE"; session.currentTaskStatus="DONE"; D.sleep(0.35)
		local finishing=action("stop"); assert(not finishing.touchEnabled,"Finalizing stop enabled")
		finishing:emit("Tapped"); assert(stops==2)
		session.currentTaskFinalizing=false; D.sleep(0.35)
		assert(action("send").touchEnabled,"Send did not return after finalization")
		finishing:emit("Tapped"); assert(stops==2 and sends==1,"Stale Stop acted or sent draft")
		for _,state in ipairs({"FAILED","STOPPED","DONE"}) do
			session.status=state; session.currentTaskStatus=state; D.sleep(0.3); assert(action("send").touchEnabled)
		end
		session.status="IDLE"; session.currentTaskStatus="RUNNING"; D.sleep(0.3)
		assert(action("stop").touchEnabled,"Active task with stale session status lost Stop")
		session.status="WAITING_USER"; session.currentTaskStatus="WAITING_USER"; D.sleep(0.3)
		assert(action("stop").touchEnabled,"Waiting session lost Stop")
		for _,size in ipairs({D.Size(320,568),D.Size(391,844),D.Size(768,1024),D.Size(844,390)}) do
			D.App.winSize=size;D.sleep(0.35);checkSpacing(action("stop"))
			D.App:saveScreenshot("/tmp/dora-remix-spacing-"..size.width);D.sleep(0.1)
		end
	end, debug.traceback)
	host:removeFromParent(true); D.App.winSize=previousSize
	for _,n in ipairs(hidden) do n.visible=true end
	D.Content:save("/tmp/dora-remix-primary-action.result",ok and "passed exclusiveSlot=1 fixedGeometry=1 sendStopSend=1 stoppingFinalizing=1 retry=1 staleClick=1 hidden=1 draftIME=1 terminalStates=1 taskStatusFallback=1 uniformSpacing=1 alignedEdges=1 fourViewportSizes=1 noLLM=1\n" or "failed: "..tostring(err))
end)
