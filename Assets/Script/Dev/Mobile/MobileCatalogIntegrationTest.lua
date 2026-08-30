local Content = Dora.Content
local catalogSync = require("Script.Tools.ResourceDownloader.CatalogSync")
local mobileCatalog = require("Dev.Mobile.MobileCatalog")
local resultPath = "/tmp/dora-mobile-catalog-integration.result"
local progressEvents = 0
local lastProgress = ""
local forceSync
forceSync = function(options)
	options.force = true
	return catalogSync.syncCatalog(options)
end
return mobileCatalog.syncMobileCatalog((function(message)
	progressEvents = progressEvents + 1
	lastProgress = message
end), (function(success, message)
	if not success then
		Content:save(resultPath, "failed: " .. tostring(message or 'unknown Catalog sync error'))
		return
	end
	local cached = catalogSync.loadCachedCatalog()
	if not (cached.success and cached.snapshot and #cached.snapshot.catalog.resources > 0) then
		Content:save(resultPath, "failed: synchronized Catalog cache is empty")
		return
	end
	if not (progressEvents > 0) then
		Content:save(resultPath, "failed: forced Catalog sync emitted no progress")
		return
	end
	return Content:save(resultPath, "passed: source=" .. tostring(cached.snapshot.source) .. " resources=" .. tostring(#cached.snapshot.catalog.resources) .. " progressEvents=" .. tostring(progressEvents) .. " last=" .. tostring(lastProgress))
end), forceSync)
