local _module_0 = { }
local catalogSync = require("Script.Tools.ResourceDownloader.CatalogSync")
local syncMobileCatalog
syncMobileCatalog = function(onProgress, onDone, operation, force)
	if operation == nil then
		operation = catalogSync.syncCatalog
	end
	if force == nil then
		force = false
	end
	local success, err = pcall(function()
		local promise = operation({
			force = force,
			onStatus = function(self, status)
				return onProgress(status.message)
			end
		})
		return promise:addCallbacks((function(_, result)
			return onDone(result.success and not (force and result.usedCache), result.message)
		end), (function(_, err)
			return onDone(false, tostring(err))
		end))
	end)
	if not success then
		return onDone(false, tostring(err))
	end
end
_module_0["syncMobileCatalog"] = syncMobileCatalog
return _module_0
