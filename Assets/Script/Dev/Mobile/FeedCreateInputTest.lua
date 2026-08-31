-- Native input/view regression, with mock creation: no project or Agent writes.
local D = require("Dora")
local F = require("Dev.Mobile.Feed")
local function find(node, tag)
	if node.tag == tag then return node end
	local result
	node:eachChild(function(child) result = find(child, tag); return result ~= nil end)
	return result
end
local resultPath = "/tmp/dora-feed-create-input.result"
D.Content:save(resultPath, "running\n")
D.thread(function()
	local previousSize = D.App.winSize
	local hidden, host = {}, nil
	D.Director.systemUI:eachChild(function(node)
		if node.visible then hidden[#hidden + 1] = node; node.visible = false end
		return false
	end)
	local ok, err = xpcall(function()
		-- Web IDE disconnection is asynchronous and temporarily owns local input.
		for _=1,40 do if D.HttpServer.wsConnectionCount==0 then break end; D.sleep(0.05) end
		assert(D.HttpServer.wsConnectionCount==0, "Disconnect Web IDE before native input tests")
		D.App.winSize = D.Size(390, 820); D.sleep(0.2)
		local syncProgress, syncDone
		local submitted, remixCount = {}, 0
		local entries = {{id="input-fixture", title="输入框验证", kind="local", description="名称与焦点测试", workDir=D.Content.assetPath}}
		host = F.startMobileFeed({
			getLocalEntries=function() return entries end,
			getDiscoverEntries=function() return {} end,
			syncDiscover=function(progress, done) syncProgress=progress;syncDone=done end,
			onPlay=function() error("Unexpected Play") end,
			onRemix=function() remixCount=remixCount+1 end,
			prepare=function() error("Unexpected prepare") end,
			createProject=function(name)
				submitted[#submitted+1]=name
				if #submitted==1 then return {success=false,error="target-existed"} end
				return {success=true,entry=entries[1]}
			end,
		})
		local function get(tag) return assert(find(host, tag), tag) end
		local function outside()
			get("mobile-project-create-focus-observer"):emit("TapFilter", {enabled=true,worldLocation=D.Vec2(-10000,-10000)})
		end
		get("mobile-feed-create"):emit("Tapped")
		assert(not find(host,"mobile-project-create-close"), "Redundant close button remains")
		-- Auto-focus is asynchronous; an outside tap must cancel the pending attach.
		outside(); D.sleep(0.1)
		local input = get("mobile-project-create-input")
		local hint = get("remix-input-placeholder")
		local caret = get("remix-input-caret")
		local label = get("remix-input-text")
		local border = get("mobile-project-create-input-border")
		assert(not input.keyboardEnabled and hint.visible and not caret.visible, "Pending auto-focus not cancelled: keyboard="..tostring(input.keyboardEnabled).." hint="..tostring(hint.visible).." caret="..tostring(caret.visible))
		assert(border.color3:toRGB()==0x343b48, "Blur border is not gray")
		D.App:saveScreenshot("/tmp/dora-feed-create-blur"); D.sleep(0.15)
		input:emit("Tapped"); D.sleep(0.1)
		assert(input.keyboardEnabled and not hint.visible and border.color3:toRGB()==0xffcc33, "Focus view/border incorrect")
		input:emit("TextInput", "甲乙🙂"); input:emit("KeyDown", "Left"); input:emit("TextInput", "中")
		assert(label.text=="甲乙中🙂", "UTF-8 insert at cursor")
		input:emit("KeyDown", "BackSpace"); input:emit("KeyDown", "Delete")
		assert(label.text=="甲乙", "UTF-8 delete at cursor")
		input:emit("KeyDown", "Home"); input:emit("TextInput", "A\r\nB")
		assert(label.text=="AB甲乙", "Paste must strip line breaks")
		input:emit("TextEditing", "ni", 1)
		assert(label.text=="ABni甲乙", "Preedit at cursor")
		input:emit("KeyDown", "BackSpace"); input:emit("KeyDown", "Return")
		get("mobile-project-create-submit"):emit("Tapped")
		assert(label.text=="ABni甲乙" and #submitted==0, "Preedit modified/created project")
		syncProgress("test sync"); syncDone(true)
		assert(get("mobile-project-create-input")==input and input.keyboardEnabled and label.text=="ABni甲乙", "Catalog refresh replaced IME/preedit")
		input:emit("TextInput", "你"); assert(label.text=="AB你甲乙", "Preedit commit duplicated")
		input:emit("TextEditing", "cancel", 2); outside()
		get("mobile-project-create-submit"):emit("Tapped")
		assert(#submitted==0 and label.text=="AB你甲乙" and not input.keyboardEnabled, "Composition dismissal submitted")
		assert(border.color3:toRGB()==0x343b48 and not caret.visible and not hint.visible, "Nonempty blur view")
		input:emit("Tapped", {location=D.Vec2(12, input.height-9)}); D.sleep(0.1)
		input:emit("TextInput", "X"); assert(label.text=="XAB你甲乙", "Tap caret/refocus failed")
		input:emit("KeyDown", "End"); input:emit("TextInput", string.rep("长名称🙂", 24))
		local content, clip = get("remix-input-content"), get("remix-input-clip")
		assert(content.x<0 and content.y==0 and caret.x+content.x>=0 and caret.x+content.x+1<=clip.width, "Long input caret outside horizontal clip")
		assert(not label.text:find("\n",1,true) and label.height<=clip.height, "Project name wrapped instead of staying on one line")
		assert(get("remix-input-measure").parent==input and not get("remix-input-measure").visible, "Clip/probe ownership")
		D.App:saveScreenshot("/tmp/dora-feed-create-long"); D.sleep(0.15)
		local tail=content.x
		input:emit("TapBegan");input:emit("TapMoved",{delta=D.Vec2(30,0)})
		assert(content.x>tail, "Horizontal drag did not reveal earlier text")
		input:emit("Tapped",{location=D.Vec2(12,22)})
		input:emit("KeyDown", "Home"); assert(content.x==0, "Home did not reveal start of name")
		input:emit("KeyDown", "End")
		for _=1, 96 do input:emit("KeyDown", "BackSpace") end
		assert(label.text=="XAB你甲乙", "Long input deletion")
		D.App:saveScreenshot("/tmp/dora-feed-create-focus"); D.sleep(0.15)
		D.App.winSize=D.Size(430,820); D.sleep(0.2)
		input=get("mobile-project-create-input"); label=get("remix-input-text")
		assert(input.keyboardEnabled and label.text=="XAB你甲乙", "Resize lost focus/draft")
		input:emit("KeyDown", "Return")
		assert(submitted[1]=="XAB你甲乙" and get("remix-input-text").text==submitted[1], "Failure lost draft")
		assert(get("mobile-project-create-input-border").color3:toRGB()==0x343b48, "Failure retained focus border")
		get("mobile-project-create-submit"):emit("Tapped")
		assert(#submitted==2 and remixCount==1 and not find(host,"mobile-project-create-sheet"), "Retry did not create/remix")
		get("mobile-feed-create"):emit("Tapped"); D.sleep(0.1)
		input=get("mobile-project-create-input")
		assert(get("remix-input-text").text=="", "Reopen retained old draft")
		host:emit("SuspendLocalUI")
		assert(not input.keyboardEnabled and get("remix-input-placeholder").visible, "Suspension did not blur")
		get("mobile-project-create-cancel"):emit("Tapped"); D.sleep(0.05)
		assert(not find(D.Director.entry,"remix-input-measure"), "Probe leaked into game scene")
	end, debug.traceback)
	if host then host:removeFromParent(true) end
	D.App.winSize=previousSize
	for _, node in ipairs(hidden) do node.visible=true end
	D.Content:save(resultPath, ok and "passed noCloseButton=1 singleLine=1 horizontalScroll=1 focusBorder=1 pendingFocusCancel=1 utf8Cursor=1 preedit=1 catalogKeepInput=1 outsideBlur=1 reopen=1 clipping=1 resize=1 createRecovery=1 noProbeLeak=1 noProjectWrites=1\n" or "failed: "..tostring(err))
end)
