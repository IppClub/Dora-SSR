local _module_0 = { }
local catalogSync = require("Script.Tools.ResourceDownloader.CatalogSync")
local syncMobileCatalog
syncMobileCatalog = function(onProgress, onDone, operation)
	if operation == nil then
		operation = catalogSync.syncCatalog
	end
	local success, err = pcall(function()
		local promise = operation({
			onStatus = function(self, status)
				return onProgress(status.message)
			end
		})
		return promise:addCallbacks((function(_, result)
			return onDone(result.success, result.message)
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
