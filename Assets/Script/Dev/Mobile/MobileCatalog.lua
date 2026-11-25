-- [yue]: Dev/Mobile/MobileCatalog.yue
local _module_0 = { } -- 1
local catalogSync = require("Script.Tools.ResourceDownloader.CatalogSync") -- 1
local syncMobileCatalog -- 3
syncMobileCatalog = function(onProgress, onDone, operation, force) -- 3
	if operation == nil then -- 3
		operation = catalogSync.syncCatalog -- 3
	end -- 3
	if force == nil then -- 3
		force = false -- 3
	end -- 3
	local success, err = pcall(function() -- 4
		local promise = operation({ -- 5
			force = force, -- 5
			onStatus = function(self, status) -- 5
				return onProgress(status.message) -- 5
			end -- 5
		}) -- 5
		return promise:addCallbacks((function(_, result) -- 6
			return onDone(result.success and not (force and result.usedCache), result.message) -- 6
		end), (function(_, err) -- 6
			return onDone(false, tostring(err)) -- 6
		end)) -- 6
	end) -- 4
	if not success then -- 7
		return onDone(false, tostring(err)) -- 7
	end -- 7
end -- 3
_module_0["syncMobileCatalog"] = syncMobileCatalog -- 3
return _module_0 -- 1
