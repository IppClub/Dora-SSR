-- Native Go Feed interaction/render regression. Catalog/Git callbacks are fixtures;
-- real repository operations are covered by test_catalog_project_sync.py.
return function(outputDir, showShare)
	local D = require('Dora')
	local sleep = D.sleep
	local previousDora, previousFeed = package.loaded.Dora, package.loaded['Dev/Mobile/Feed']
	local previousGamepad = package.loaded['Dev/Mobile/Gamepad']
	local previousGamepadDot = package.loaded['Dev.Mobile.Gamepad']
	-- Isolate the Feed's Web IDE input lock so native tests can run through the CLI
	-- while the Web IDE remains connected. No server connection is changed.
	local app = showShare and setmetatable({platform="Android"},{__index=function(_,key) return D.App[key] end}) or D.App
	package.loaded.Dora = setmetatable({HttpServer = {wsConnectionCount = 0},App=app}, {__index = D})
	package.loaded['Dev/Mobile/Feed'] = nil
	package.loaded['Dev/Mobile/Gamepad'] = nil
	package.loaded['Dev.Mobile.Gamepad'] = nil
	local okLoad, Feed = pcall(require, 'Dev/Mobile/Feed')
	local Gamepad = require('Dev.Mobile.Gamepad')
	package.loaded.Dora = previousDora
	package.loaded['Dev/Mobile/Feed'] = previousFeed
	package.loaded['Dev/Mobile/Gamepad'] = previousGamepad
	package.loaded['Dev.Mobile.Gamepad'] = previousGamepadDot
	assert(okLoad, Feed)
	local host
	local function find(node, tag)
		if node.tag == tag then return node end
		local found
		node:eachChild(function(child) found=find(child,tag);return found~=nil end)
		return found
	end
	local function tapped(tag)
		local button=assert(find(host,tag),'missing button: '..tag)
		button:emit('Tapped')
	end
	assert(D.Content:mkdir(outputDir) or D.Content:isdir(outputDir))
	assert(D.Director:beginGameCapture())
	local function capture(name)
		sleep(0.1)
		local done,saved=false,false
		assert(D.Director:captureGameAsync(D.Path(outputDir,name..'.png'),function(ok) saved=ok;done=true end))
		while not done do sleep(0.01) end
		assert(saved,'capture failed')
	end
	local ok,err=pcall(function()
		local resource={id='fixture'}
		local item={id='fixture',title='Catalog Sync Test',description='Native Go UI verification',kind='local',
			fileName='/tmp/catalog-fixture/init',workDir='/tmp/catalog-fixture',resource=resource}
		local discover={id='fixture',title=item.title,description=item.description,kind='discover',installed=true,resource=resource}
		local ordinaryCalls,forceCalls,refreshCalls=0,0,0
		local mode='conflict'
		host=Feed.startMobileFeed({
			takeReceivedFile=function() return '' end,
			getLocalEntries=function(dirty) if dirty then refreshCalls=refreshCalls+1 end;return {item} end,
			getDiscoverEntries=function() return {discover} end,
			onPlay=function() error('sync must not launch the game') end,
			onRemix=function() error('sync must not enter Remix') end,
			prepare=function() error('sync must not reinstall automatically') end,
			sync=function(entry,force,onProgress,onDone)
				assert(entry==item)
				if force then
					forceCalls=forceCalls+1
					onProgress(0.5,'Receiving project',1024)
					if mode=='force-failure' then onDone(false,nil,'Download failed',false)
					else onProgress(1,'Installed',1024);onDone(true,{workDir=item.workDir}) end
				else
					ordinaryCalls=ordinaryCalls+1
					onDone(false,nil,mode=='canceled' and 'Canceled' or 'Local changes would be overwritten by Git pull',mode~='canceled')
				end
			end,
		})
		assert(find(host,'mobile-feed-manage'))
		assert(not find(host,'mobile-feed-sync'),'Sync must not be a primary card action')
		local controller
		D.Director.systemUI:eachChild(function(child) if child.tag=='mobile-gamepad' then controller=child end;return false end)
		assert(controller)
		local function button(name) sleep(0.03);controller:emit('ButtonDown',0,name);controller:emit('ButtonUp',0,name) end
		capture('catalog-sync-card')
		assert(Gamepad.selectGamepadNode(host,'mobile-feed-manage'));button('a')
		assert(find(host,'mobile-feed-management-menu') and find(host,'mobile-feed-sync'))
		assert((find(host,'mobile-feed-share')~=nil)==(showShare==true))
		capture('catalog-management-menu')
		button('b')
		assert(not find(host,'mobile-feed-management-menu') and ordinaryCalls==0)
		local function syncTap() tapped('mobile-feed-manage');tapped('mobile-feed-sync') end
		tapped('mobile-feed-manage');tapped('mobile-feed-management-menu') -- Outside closes without an action.
		assert(not find(host,'mobile-feed-management-menu') and ordinaryCalls==0)
		tapped('mobile-feed-manage');sleep(0.05);assert(Gamepad.selectGamepadNode(host,'mobile-feed-sync'));button('a')
		assert(ordinaryCalls==1 and forceCalls==0)
		assert(find(host,'mobile-feed-sync-confirmation'))
		capture('catalog-sync-confirmation')
		button('a') -- Safe default focus in the modal keeps the local project.
		assert(not find(host,'mobile-feed-sync-confirmation') and forceCalls==0)
		syncTap()
		button('dpright');button('a')
		assert(forceCalls==1 and refreshCalls==1 and not find(host,'mobile-feed-sync-confirmation'))
		capture('catalog-sync-complete')
		tapped('mobile-feed-discover-tab')
		assert(not find(host,'mobile-feed-sync') and not find(host,'mobile-feed-manage'),'Discover must not have project management')
		tapped('mobile-feed-local-tab')
		mode='canceled';syncTap()
		assert(not find(host,'mobile-feed-sync-confirmation'),'Canceled pull must not offer force')
		mode='force-failure';syncTap();tapped('mobile-feed-sync-force')
		assert(forceCalls==2 and not find(host,'mobile-feed-sync-confirmation'),'Force failure must not loop into confirmation')
		item.resource=nil
		tapped('mobile-feed-discover-tab')
		tapped('mobile-feed-local-tab')
		assert(not find(host,'mobile-feed-sync'),'Unrelated local project must not have Sync')
		if showShare then tapped('mobile-feed-manage');assert(find(host,'mobile-feed-share') and not find(host,'mobile-feed-sync'))
		else assert(not find(host,'mobile-feed-manage'),'Do not offer an empty management menu') end
		print('Native Go UI: Management menu, primary actions, share availability, local-only Sync, failure confirmation, keep local, force, refresh, cancellation, controller focus and failure checks passed')
	end)
	if host then host:removeFromParent(true) end
	D.Director:endGameCapture()
	assert(ok,err)
end
