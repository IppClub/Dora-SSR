-- Run a known, safe local fixture through the real Entry shell (not mocked callbacks).
-- No prompts are sent and no project files are modified.
local D=require("Dora")
local E=require("Script.Dev.Entry")
local function find(root,tag)
	if root.tag==tag then return root end
	local found;root:eachChild(function(child) found=find(child,tag);return found~=nil end);return found
end
return function(projectId,directPlay)
	assert(not E.getCurrentEntryStatus().running,"Stop the current project before navigation validation")
	local target
	for _,entry in ipairs(E.getMobileFeedEntries(true)) do if entry.id==projectId then target=entry;break end end
	assert(target,"Missing safe test project: "..projectId)
	local originalMode=E.getUIMode()
	assert(E.setUIMode("mobile"))
	local probe=D.Node();probe.tag="entry-navigation-test";probe:addTo(D.Director.systemUI)
	local elapsed,total,step=0,0,0
	D.Content:save("/tmp/dora-entry-navigation.result","running\n")
	local function finish(message)
		D.Content:save("/tmp/dora-entry-navigation.result",message)
		probe:removeFromParent(true)
		if originalMode~="mobile" and not E.getCurrentEntryStatus().running then E.setUIMode(originalMode) end
	end
	probe:schedule(function(dt)
		elapsed=elapsed+dt;total=total+dt
		if elapsed<0.4 then return false end;elapsed=0
		local ok,err=xpcall(function()
			assert(total<30,"Navigation timed out at step "..step)
			local feed=find(D.Director.systemUI,"mobile-feed")
			if step==0 then
				assert(feed and feed.visible,"Feed not visible")
				feed:emit("RestoreFeedEntry",target)
				assert(find(feed,"mobile-feed-card-"..target.id),"Target not selected")
				if directPlay then step=3;find(feed,"mobile-feed-play"):emit("Tapped")
				else step=1;find(feed,"mobile-feed-remix"):emit("Tapped") end
			elseif step==1 then
				local remix=assert(find(D.Director.systemUI,"mobile-remix"))
				step=2;find(remix,"remix-back"):emit("Tapped")
			elseif step==2 then
				assert(feed.visible and find(feed,"mobile-feed-card-"..target.id),"Real Remix return lost target")
				step=3;find(feed,"mobile-feed-play"):emit("Tapped")
			elseif step==3 then
				local status=E.getCurrentEntryStatus()
				if not status.running then return end
				assert(status.fileName==target.fileName,"Wrong project is running")
				local leaked={}
				local function inspect(node)
					local label=D.tolua.cast(node,"Label")
					if node.tag=="remix-input-measure" or (label and label.text=="M\nM") then leaked[#leaked+1]=node end
					node:eachChild(function(child) inspect(child);return false end)
				end
				inspect(D.Director.entry)
				D.App:saveScreenshot(directPlay and "/tmp/dora-direct-measure-play" or "/tmp/dora-remix-measure-play")
				assert(#leaked==0,"Remix measurement text leaked into Play: "..#leaked.." labels containing M\\nM")
				-- Capture the Play frame before returning; screenshots complete asynchronously.
				step=31
			elseif step==31 then
				local overlay=assert(find(D.Director.systemUI,"mobile-play-overlay"))
				step=4;find(overlay,"mobile-play-exit"):emit("Tapped")
			elseif step==4 then
				assert(not E.getCurrentEntryStatus().running,"Play did not stop")
				assert(feed.visible and find(feed,"mobile-feed-card-"..target.id),"Real Play restart lost target")
				D.App:saveScreenshot("/tmp/dora-navigation-real-return")
				step=5
			elseif step==5 then
				assert(feed.visible and find(feed,"mobile-feed-card-"..target.id),"Async Catalog refresh moved return card")
				finish("passed "..(directPlay and "directFeedPlay=1 " or "realEntryRemixReturn=1 ").."realPlayLaunch=1 realPlayExit=1 recreatedFeedTarget=1 noMeasurementLeak=1 noPrompt=1 noProjectWrites=1\n")
			end
		end,debug.traceback)
		if not ok then finish("failed "..tostring(err)) end
		return false
	end)
end
