local App = Dora.App
local Content = Dora.Content
local Size = Dora.Size
local sleep = Dora.sleep
local thread = Dora.thread
local catalog = require("Script.Tools.ResourceDownloader.Catalog")
local catalogSync = require("Script.Tools.ResourceDownloader.CatalogSync")
local feed = require("Dev.Mobile.Feed")
local resultPath = "/tmp/dora-mobile-real-catalog-feed.result"
local cached = catalogSync.loadCachedCatalog()
if not (cached.success and cached.snapshot) then
	Content:save(resultPath, "failed: " .. tostring(cached.message or 'Catalog cache unavailable'))
	return
end
local resources = catalog.getMobileFeedResources(cached.snapshot.catalog.resources)
if not (#resources > 0) then
	Content:save(resultPath, "failed: Catalog contains no mobile Feed resources")
	return
end
local resource = resources[1]
App.winSize = Size(390, 844)
return thread(function()
	sleep(0.4)
	local host = feed.startMobileFeed({
		getDiscoverEntries = function()
			return {
				{
					id = resource.id,
					title = resource.title["zh-Hans"],
					description = resource.description["zh-Hans"],
					kind = "discover",
					bannerFile = resource.bannerPath
				}
			}
		end,
		getLocalEntries = function()
			return { }
		end,
		onPlay = function() end,
		onRemix = function() end,
		prepare = function(entry, repairIncomplete, onProgress, onDone)
			return onDone(false, nil, "preview only")
		end
	})
	sleep(0.8)
	local screenshot = App:saveScreenshot("/tmp/dora-mobile-real-catalog-feed")
	sleep(0.3)
	return Content:save(resultPath, "passed: source=" .. tostring(cached.snapshot.source) .. " resource=" .. tostring(resource.id) .. " banner=" .. tostring(resource.bannerPath) .. " screenshot=" .. tostring(screenshot) .. " hostScale=" .. tostring(host.scaleX) .. "," .. tostring(host.scaleY))
end)
