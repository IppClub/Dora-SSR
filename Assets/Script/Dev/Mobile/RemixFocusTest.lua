-- Native IME lifecycle + synthetic pointer events. No LLM or user-project writes.
local D = require("Dora")
local R = require("Dev.Mobile.Remix")
local function find(node, tag)
	if node.tag == tag then return node end
	local found
	node:eachChild(function(child) found=find(child,tag);return found~=nil end)
	return found
end
local session={id=91997,projectRoot=D.Content.assetPath,title="Focus test",kind="main",rootSessionId=91997,memoryScope="main",workMode="code",status="IDLE",createdAt=1,updatedAt=1}
local sent,back={},0
local pending
local config={url="https://example.invalid",model="test",apiKey="test",contextWindow=64000,temperature=0,maxTokens=1000,supportsFunctionCalling=true}
local services={
	createSession=function() return {success=true,session=session} end,
	getSession=function() return {success=true,session=session,relatedSessions={},messages={},steps={},checkpoints={},hasActivePlan=false,pendingQuestionnaire=pending} end,
	setWorkMode=function(_,mode) session.workMode=mode;return {success=true} end,
	sendPrompt=function(_,text) sent[#sent+1]=text;return {success=true,sessionId=session.id,taskId=92997} end,
	stopSessionTask=function() return {success=true} end,
	respondQuestionnaire=function() error("Unexpected questionnaire") end,
	getActiveLLMConfig=function() return {success=true,id=94997,config=config} end,
	getLLMConfig=function() return {success=true,id=94997,config=config} end,
	getLLMConfigSummaries=function() return {{id=94997,name="Test",model="test",active=true}} end,
}
D.thread(function()
	D.Content:save("/tmp/dora-remix-focus.result","running\n")
	local hidden={}
	D.Director.systemUI:eachChild(function(n) if n.visible then hidden[#hidden+1]=n;n.visible=false end;return false end)
	local host=R.startMobileRemix({entry={id="focus-test",title="输入失焦验证",workDir=D.Content.assetPath},services=services,onBack=function() back=back+1 end,onPlay=function() end})
	local ok,err=xpcall(function()
		D.sleep(0.1)
		local input=assert(find(host,"remix-input"))
		local hint=assert(find(input,"remix-input-placeholder"))
		local caret=assert(find(input,"remix-input-caret"))
		local label=assert(find(input,"remix-input-text"))
		local attached,detached=0,0
		input:slot("AttachIME",function() attached=attached+1 end)
		input:slot("DetachIME",function() detached=detached+1 end)
		local function observe(node,point)
			local observer=assert(find(host,"remix-focus-observer"))
			assert(observer.order>input.order and not observer.swallowTouches and not observer.swallowMouseWheel,"Observer intercepts controls")
			local world=node:convertToWorldSpace(point)
			local touch={enabled=true,worldLocation=world,location=observer:convertToNodeSpace(world),first=true}
			observer:emit("TapFilter",touch)
			assert(not touch.enabled,"Observer must not capture gesture")
		end
		local function outside() observe(find(host,"remix-scene"),D.Vec2(2,2)) end
		local function focus()
			input:emit("TapBegan")
			input:emit("Tapped",{location=D.Vec2(20,20)})
			D.sleep(0.08)
			assert(input.keyboardEnabled and not hint.visible,"Native IME did not attach")
		end
		assert(hint.visible and not caret.visible,"Initial state")
		focus();assert(attached==1,"Missing native AttachIME")
		observe(input,D.Vec2(20,20));assert(input.keyboardEnabled and detached==0,"Inside touch blurred input")
		outside();assert(not input.keyboardEnabled and hint.visible and not caret.visible and detached==1,"Outside did not detach IME")
		outside();assert(detached==1,"Repeated blur detached twice")
		focus();input:emit("TextInput","保留草稿")
		input:emit("TextEditing","ni",1)
		outside();assert(label.text=="保留草稿" and not hint.visible and not caret.visible,"Draft/preedit blur state")
		D.sleep(0.08);D.App:saveScreenshot("/tmp/dora-remix-focus-blurred");D.sleep(0.12)
		focus();input:emit("TextEditing","ni",1);input:emit("KeyDown","Escape")
		assert(not input.keyboardEnabled and label.text=="保留草稿","Escape during composition")
		focus()
		local mode=find(host,"remix-mode-plan")
		observe(mode,D.Vec2(10,10));mode:emit("Tapped")
		assert(session.workMode=="plan" and not input.keyboardEnabled and find(host,"remix-input")==input,"First outside button tap lost")
		D.sleep(0.3);assert(not input.keyboardEnabled,"Refresh restored unwanted focus")
		focus();input:emit("TextEditing","unfinished",1)
		local send=find(host,"remix-send")
		observe(send,D.Vec2(10,10));send:emit("Tapped")
		assert(#sent==0 and label.text=="保留草稿","Blur submitted draft while cancelling preedit")
		send=find(host,"remix-send");observe(send,D.Vec2(10,10));send:emit("Tapped")
		assert(sent[1]=="保留草稿" and hint.visible,"Next send tap/reset failed")
		input:emit("Tapped");outside();D.sleep(0.1)
		assert(not input.keyboardEnabled and hint.visible,"Pending focus reopened after outside blur")
		input:emit("Tapped");host:emit("SuspendLocalUI");D.sleep(0.1)
		assert(not input.keyboardEnabled,"Pending focus survived Web IDE takeover")
		focus();host:emit("SuspendLocalUI");assert(not input.keyboardEnabled and hint.visible,"Takeover did not blur")
		host:emit("ResumeLocalUI");D.sleep(0.1);assert(not input.keyboardEnabled,"Resume reopened input")
		focus();D.emit("AppEvent","WillEnterBackground");assert(not input.keyboardEnabled,"Background did not blur")
		focus();D.emit("AppEvent","BackButton");assert(not input.keyboardEnabled and back==0,"Back must dismiss focused input first")
		focus()
		local other=D.Node();local otherDetached=0
		other:onDetachIME(function() otherDetached=otherDetached+1 end)
		other:attachIME();outside();assert(otherDetached==0,"Inactive Remix detached another input's IME")
		other:detachIME();other:cleanup()
		input:emit("Tapped");host:removeFromParent(true);D.sleep(0.1)
		assert(not input.keyboardEnabled,"Cleanup allowed pending focus")
		pending={id=93997,sessionId=session.id,taskId=92997,step=1,status="PENDING",createdAt=1,
			schema={title="Question focus",questions={{id="answer",type="text",prompt="Type an answer",required=true}}}}
		host=R.startMobileRemix({entry={id="focus-question",title="问卷失焦验证",workDir=D.Content.assetPath},services=services,onBack=function() end,onPlay=function() end})
		D.sleep(0.1)
		local qlabel=assert(find(host,"remix-input-text"))
		local qinput=qlabel.parent.parent.parent
		qinput:emit("Tapped");D.sleep(0.1);qinput:emit("TextInput","回答保留")
		observe(qinput,D.Vec2(20,20));assert(qinput.keyboardEnabled,"Nested input hit-test blurred inside")
		outside();assert(not qinput.keyboardEnabled and qlabel.text=="回答保留","Nested question lost draft/focus")
		qinput:emit("Tapped");D.sleep(0.1);assert(qinput.keyboardEnabled,"Question could not refocus")
		host:removeFromParent(true);D.sleep(0.1);assert(not qinput.keyboardEnabled,"Focused cleanup did not detach")
	end,debug.traceback)
	if host.parent then host:removeFromParent(true) end
	for _,n in ipairs(hidden) do n.visible=true end
	D.Content:save("/tmp/dora-remix-focus.result",ok and "passed nativeAttachDetach=1 outside=1 inside=1 draft=1 preedit=1 escape=1 firstButtonTap=1 sendGuard=1 pendingFocus=1 takeover=1 background=1 back=1 cleanup=1 otherIME=1 questionnaire=1 noLLM=1\n" or "failed: "..tostring(err))
end)
