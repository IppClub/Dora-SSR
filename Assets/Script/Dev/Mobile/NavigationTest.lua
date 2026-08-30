-- Deterministic native UI regression; no LLM or user-project writes.
local D=require("Dora")
local F=require("Dev.Mobile.Feed")
local R=require("Dev.Mobile.Remix")
local A=require("Dev.Mobile.Accessibility")
local function find(node,tag)
	if node.tag==tag then return node end
	local result;node:eachChild(function(child) result=find(child,tag);return result~=nil end);return result
end
local function noAa(node)
	local label=D.tolua.cast(node,"Label")
	assert(not label or label.text~="Aa","Size toggle still present")
	node:eachChild(function(child) noAa(child);return false end)
end
local function item(id,kind) return {id=id,title=id,description="Navigation fixture",kind=kind or "local",workDir="/fixture/"..id,fileName="/fixture/"..id.."/init",installed=true} end
local a,b,c=item("A"),item("B"),item("C")
local x,y=item("X","discover"),item("Y","discover")
local localItems,discoverItems={a,b,c},{x,y}
local session={id=91996,projectRoot=D.Content.assetPath,title="Navigation",kind="main",rootSessionId=91996,memoryScope="main",workMode="code",status="IDLE",createdAt=1,updatedAt=1}
local cfg={url="https://example.invalid",model="test",apiKey="test",contextWindow=64000,temperature=0,maxTokens=1000,supportsFunctionCalling=true}
local services={
	createSession=function() return {success=true,session=session} end,
	getSession=function() return {success=true,session=session,relatedSessions={},messages={},steps={},checkpoints={},hasActivePlan=false} end,
	getLLMConfigSummaries=function() return {{id=94996,name="test",model="test",active=true}} end,
	getLLMConfig=function() return {success=true,id=94996,config=cfg} end,
	getActiveLLMConfig=function() return {success=true,id=94996,config=cfg} end,
	setWorkMode=function(_,mode) session.workMode=mode;return {success=true} end,
	sendPrompt=function() error("Unexpected send") end,
	respondQuestionnaire=function() error("Unexpected questionnaire") end,
	stopSessionTask=function() return {success=true} end,
}
D.thread(function()
	D.Content:save("/tmp/dora-navigation.result","running\n")
	local previousSize=D.App.winSize
	local hidden={}
	D.Director.systemUI:eachChild(function(n) if n.visible then hidden[#hidden+1]=n;n.visible=false end;return false end)
	D.App.winSize=D.Size(390,844);D.sleep(0.2)
	local feed,remix,synced,selected,played
	local function start(initial)
		return F.startMobileFeed({initialEntry=initial,getLocalEntries=function() return localItems end,getDiscoverEntries=function() return discoverItems end,
			syncDiscover=function(_,done) synced=done end,prepare=function() error("Unexpected install") end,
			onPlay=function(entry) played=entry end,
			onRemix=function(entry)
				selected=entry;feed.visible=false
				remix=R.startMobileRemix({entry=entry,services=services,onPlay=function() end,onBack=function()
					feed:emit("RestoreFeedEntry",entry);feed.visible=true
				end})
			end})
	end
	local function title(expected)
		assert(find(feed,"mobile-feed-current-title").text==expected,"Wrong Feed card, expected "..expected)
	end
	local function gesture(dx,dy,verticalFirst)
		local observer=assert(find(remix,"remix-focus-observer"))
		local start=D.Vec2(260,430)
		local touch={first=true,enabled=true,location=start,worldLocation=observer:convertToWorldSpace(start)}
		observer:emit("TapFilter",touch);assert(touch.enabled,"Body gesture not accepted")
		observer:emit("TapBegan",touch)
		if verticalFirst then touch.location=start+D.Vec2(0,40);observer:emit("TapMoved",touch) end
		local page=assert(find(remix,"remix-page"))
		local input=assert(find(remix,"remix-input"))
		local before=input:convertToWorldSpace(D.Vec2.zero)
		touch.location=start+D.Vec2(dx,dy);observer:emit("TapMoved",touch)
		local expected=not verticalFirst and dx<0 and dx*0.18 or 0
		assert(math.abs(page.x-expected)<0.01,"Page is not following the left drag")
		assert(observer.x==0,"Gesture observer moved with page")
		-- Descendant world transforms are refreshed on the next frame.
		D.sleep(0.03)
		local after=input:convertToWorldSpace(D.Vec2.zero)
		assert(input.parent==page,"Composer is outside moving page")
		assert(math.abs(after.x-before.x-expected*D.App.devicePixelRatio)<=1,"Composer did not move with whole page: "..tostring(after.x-before.x).." expected "..tostring(expected*D.App.devicePixelRatio))
		if dx==-20 then
			D.sleep(0.3);assert(page.parent and math.abs(page.x-expected)<0.01,"Polling reset active gesture")
		end
		if dx==-160 and session.status=="IDLE" then
			D.App:saveScreenshot("/tmp/dora-navigation-remix-drag");D.sleep(0.08)
		end
		local leaving=not verticalFirst and dx<=-150 and session.status=="IDLE"
		local removedX
		if leaving then page:onCleanup(function() removedX=page.x end) end
		observer:emit("TapEnded",touch)
		assert(observer.parent,"Destroyed touch target before native Tapped dispatch")
		if leaving then assert(math.abs(page.x-expected)<0.01,"Successful swipe rebounded before switching") end
		observer:emit("Tapped",touch)
		if leaving then assert(math.abs(page.x-expected)<0.01,"Tapped reset the outgoing page") end
		D.sleep(0.05)
		if leaving then
			assert(not remix.parent,"Successful swipe waited for an exit animation")
			assert(removedX and math.abs(removedX-expected)<0.01,"Outgoing page reset before cleanup")
		end
		D.sleep(0.23)
		if remix.parent then assert(find(remix,"remix-page").x==0,"Cancelled or blocked swipe did not spring back") end
	end
	local ok,err=xpcall(function()
		A.setMobileLargeText(false);assert(A.getMobileLargeText() and A.mobileFontScale==1.16,"Legacy setting restored small text")
		feed=start();title("A");noAa(feed)
		synced(true);title("A")
		feed:emit("RestoreFeedEntry",b);title("B")
		find(feed,"mobile-feed-remix"):emit("Tapped");assert(selected==b and not feed.visible)
		noAa(remix)
		local back=assert(find(remix,"remix-back"));assert(back.x>D.App.safeArea.width/2 and back.width>=44 and back.height>=44,"Back is not top-right/touch-sized")
		D.sleep(0.1);D.App:saveScreenshot("/tmp/dora-navigation-remix");D.sleep(0.1)
		gesture(150,0);assert(remix.parent and not feed.visible,"Right swipe went back")
		gesture(-20,0);assert(remix.parent,"Short swipe went back")
		gesture(-150,80,true);assert(remix.parent,"Vertical scroll turned into Back")
		local observer=find(remix,"remix-focus-observer")
		local input=find(remix,"remix-input")
		local world=input:convertToWorldSpace(D.Vec2(30,30))
		local touch={first=true,enabled=true,worldLocation=world,location=observer:convertToNodeSpace(world)}
		observer:emit("TapFilter",touch);assert(not touch.enabled,"Input drag became navigation")
		session.status="RUNNING";D.sleep(0.3);gesture(-160,0);assert(remix.parent and not feed.visible,"Busy swipe bypassed leave guard")
		session.status="IDLE";D.sleep(0.3)
		localItems={c,a,{id="B renamed",title="B renamed",description="",kind="local",workDir=b.workDir,fileName=b.fileName}}
		gesture(-160,0);assert(not remix.parent and feed.visible,"Left swipe did not return");title("B renamed")
		discoverItems={y,x};synced(true);title("B renamed")
		find(feed,"mobile-feed-play"):emit("Tapped");assert(played.fileName==b.fileName,"Play selected wrong project")
		feed:removeFromParent(true);feed=start(played);title("B renamed")
		find(feed,"mobile-feed-remix"):emit("Tapped");find(remix,"remix-back"):emit("Tapped");assert(feed.visible and not remix.parent);title("B renamed")
		feed:removeFromParent(true);feed=start(x);title("X")
		discoverItems={x,y};synced(true);title("X")
		feed:removeFromParent(true);localItems={};feed=start();title("X")
		feed:removeFromParent(true);discoverItems={};feed=start();assert(not find(feed,"mobile-feed-current-title"),"Empty Feed should not invent card")
		discoverItems={y};synced(true);title("Y")
	end,debug.traceback)
	if remix and remix.parent then remix:removeFromParent(true) end
	if feed and feed.parent then feed:removeFromParent(true) end
	D.App.winSize=previousSize
	for _,n in ipairs(hidden) do n.visible=true end
	D.Content:save("/tmp/dora-navigation.result",ok and "passed largeOnly=1 noAa=1 backTopRight=1 leftSwipe=1 wholePageDrag=1 stationaryObserver=1 springBack=1 pollingDuringDrag=1 verticalLock=1 inputGuard=1 busyGuard=1 localDefault=1 emptyFallback=1 restoreRenamedReordered=1 remixBack=1 playRecreate=1 catalogSyncPin=1 discoverOrigin=1 noLLM=1\n" or "failed "..tostring(err))
end)
