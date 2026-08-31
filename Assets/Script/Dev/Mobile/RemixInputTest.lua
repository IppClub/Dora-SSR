-- Engine-rendered controls with deterministic services. No LLM/user-project writes.
local D = require("Dora")
local R = require("Dev.Mobile.Remix")
local I = require("Dev.Mobile.RemixInput")
local function find(node, tag)
	if node.tag == tag then return node end
	local found
	node:eachChild(function(child) found=find(child,tag); return found~=nil end)
	return found
end
local session={id=91998,projectRoot=D.Content.assetPath,title="Input test",kind="main",rootSessionId=91998,memoryScope="main",workMode="code",status="IDLE",createdAt=1,updatedAt=1}
local sent={}
local config={url="https://example.invalid",model="test",apiKey="test",contextWindow=64000,temperature=0,maxTokens=1000,supportsFunctionCalling=true}
local services={
	createSession=function() return {success=true,session=session} end,
	getSession=function() return {success=true,session=session,relatedSessions={},messages={},steps={},checkpoints={},hasActivePlan=false} end,
	setWorkMode=function(_,mode) session.workMode=mode;return {success=true} end,
	sendPrompt=function(_,text) sent[#sent+1]=text;return {success=true,sessionId=session.id,taskId=92998} end,
	stopSessionTask=function() return {success=true} end,
	respondQuestionnaire=function() error("Unexpected questionnaire") end,
	getActiveLLMConfig=function() return {success=true,id=94998,config=config} end,
	getLLMConfig=function() return {success=true,id=94998,config=config} end,
	getLLMConfigSummaries=function() return {{id=94998,name="Test",model="test",active=true}} end,
}
D.thread(function()
	local previousSize=D.App.winSize
	local hidden={}
	D.Director.systemUI:eachChild(function(n) if n.visible then hidden[#hidden+1]=n;n.visible=false end;return false end)
	D.App.winSize=D.Size(390,540);D.sleep(0.3)
	local host=R.startMobileRemix({entry={id="input-test",title="多行输入验证",workDir=D.Content.assetPath},services=services,onBack=function() end,onPlay=function() end})
	local ok,err=xpcall(function()
		assert(I.inputLength("甲🙂乙")==3 and I.inputSlice("甲🙂乙",1,2)=="🙂","UTF-8 slicing")
		local layout=I.layoutInput("ab\n\n中🙂 ",20,function() return 10 end)
		assert(layout.rows==4 and #layout.stops==8,"Explicit empty lines/wrapping")
		local input=assert(find(host,"remix-input"))
		local label=assert(find(input,"remix-input-text"))
		local hint=assert(find(input,"remix-input-placeholder"))
		local caret=assert(find(input,"remix-input-caret"))
		local border=assert(find(input,"remix-input-border"))
		local clip=assert(find(input,"remix-input-clip"))
		local content=assert(find(input,"remix-input-content"))
		local inputMeasure=assert(find(input,"remix-input-measure"))
		assert(inputMeasure.parent==input and not inputMeasure.visible,"Metrics probe is not hidden/owned by input")
		assert(D.tolua.cast(clip,"ClipNode") and label.parent==content and content.parent==clip and caret.parent==content,"Text/caret not clipped")
		assert(hint.visible and label.text=="" and not caret.visible,"Idle placeholder/caret")
		assert(border.color3:toRGB()==0x343b48,"Idle border not gray")
		D.sleep(0.1);D.App:saveScreenshot("/tmp/dora-remix-input-placeholder");D.sleep(0.15)
		assert(not find(D.Director.entry,"remix-input-measure"),"Metrics probe was auto-attached to game scene")
		input:emit("AttachIME")
		assert(not hint.visible and caret.visible,"Focus did not hide placeholder/show caret")
		assert(border.color3:toRGB()==0xffcc33,"Focused prompt border not gold")
		D.sleep(0.1);D.App:saveScreenshot("/tmp/dora-remix-input-focus");D.sleep(0.5)
		assert(D.App.reducedMotion or not caret.visible,"Caret did not blink")
		input:emit("DetachIME");assert(hint.visible and not caret.visible,"Blur did not restore placeholder")
		assert(border.color3:toRGB()==0x343b48,"Blur did not restore gray border")
		input:emit("AttachIME")
		input:emit("TextInput","中中文")
		local measure=assert(D.Label("sarasa-mono-sc-regular",18,true))
		measure.visible=false;input:addChild(measure)
		-- Match the current large-text setting by reading a fresh view at an explicit size.
		local probe=D.Node();probe.width=250;probe.height=60
		local view=I.createRemixInputView(probe,18)
		view.update("中中文","",true,3)
		measure.batched=false;measure.alignment="Left";measure.text="M"
		local start=measure:getCharacter(1).x
		measure.text="中中文M"
		assert(math.abs(view.caret.x-(measure:getCharacter(4).x-start))<0.01,"Caret differs from real glyph advance")
		local probeMeasure=assert(find(probe,"remix-input-measure"))
		local probeCleaned=false;probeMeasure:onCleanup(function() probeCleaned=true end)
		probe:cleanup()
		D.sleep(0.03)
		assert(probeCleaned and not probeMeasure.parent,"Metrics probe outlived its input")
		find(host,"remix-send"):emit("Tapped");sent={}
		input:emit("TextInput","甲乙🙂");input:emit("KeyDown","Left");input:emit("TextInput","中")
		assert(label.text=="甲乙中🙂","Insert at caret")
		input:emit("KeyDown","BackSpace");input:emit("KeyDown","Delete");assert(label.text=="甲乙","UTF-8 delete")
		input:emit("KeyDown","Return");input:emit("TextInput","下一行")
		assert(label.text=="甲乙\n下一行" and #sent==0,"Return did not insert newline")
		input:emit("TextEditing","ni",1);assert(label.text=="甲乙\n下一行ni","Composition display")
		find(host,"remix-send"):emit("Tapped");assert(#sent==0,"Sent composition")
		input:emit("TextInput","你");assert(label.text=="甲乙\n下一行你","Composition commit duplicated")
		find(host,"remix-send"):emit("Tapped");assert(sent[1]=="甲乙\n下一行你" and label.text=="" and not hint.visible,"Exact multiline send/reset")
		local long=string.rep("中文🙂 alphabet 0123456789\n",15).."最后一行"
		input:emit("TextInput",long)
		assert(content.y>0 and caret.y+content.y>=0 and caret.y+content.y+18<=clip.height,"Caret not followed into viewport")
		assert(label.height>clip.height and not hint.visible,"Long text not multiline")
		D.sleep(0.1);D.App:saveScreenshot("/tmp/dora-remix-input-long");D.sleep(0.15)
		local tail=content.y
		input:emit("MouseWheel",D.Vec2(0,3));assert(content.y<tail,"Wheel did not scroll within input")
		input:emit("KeyDown","Home");assert(content.y==0,"Home did not reveal caret")
		input:emit("KeyDown","Down");input:emit("TextInput","[插入]")
		find(host,"remix-mode-plan"):emit("Tapped")
		assert(find(host,"remix-input")==input and not hint.visible,"Mode change replaced input")
		assert(border.color3:toRGB()==0xffcc33,"Mode change lost focus highlight")
		input:emit("KeyDown","End");find(host,"remix-send"):emit("Tapped")
		assert(#sent==2 and sent[2]:find("[插入]",1,true),"Caret edit lost on send")
		input:emit("TextInput","AB")
		input:emit("Tapped",{location=D.Vec2(12,input.height-9)})
		input:emit("TextInput","X");assert(label.text=="XAB","Tap did not place caret")
		input:emit("TextEditing","cancel",2);input:emit("TextEditing","");assert(label.text=="XAB","Composition cancel")
		input:emit("DetachIME");assert(not hint.visible and not caret.visible,"Nonempty blur placeholder")
		assert(border.color3:toRGB()==0x343b48,"Nonempty blur lost border state")
		input:emit("Tapped"); D.sleep(0.1)
		assert(input.keyboardEnabled and border.color3:toRGB()==0xffcc33,"Real IME refocus did not highlight prompt")
		find(host,"remix-focus-observer"):emit("TapFilter",{enabled=true,worldLocation=D.Vec2(-10000,-10000),location=D.Vec2(-10000,-10000)})
		assert(not input.keyboardEnabled and border.color3:toRGB()==0x343b48,"Outside tap did not blur prompt")
	end,debug.traceback)
	host:removeFromParent(true);D.App.winSize=previousSize
	for _,n in ipairs(hidden) do n.visible=true end
	D.Content:save("/tmp/dora-remix-input.result",ok and "passed focusBorder=1 outsideBlur=1 imeRefocus=1 placeholderFocusBlur=1 caretBlink=1 clipHierarchy=1 multilineReturn=1 utf8CaretEdit=1 composition=1 exactSend=1 caretFollow=1 wheel=1 arrows=1 tap=1 keptInput=1 noLLM=1\n" or "failed: "..tostring(err))
end)
