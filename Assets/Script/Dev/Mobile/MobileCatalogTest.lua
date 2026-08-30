local Content = Dora.Content
local resultPath = "/tmp/dora-mobile-catalog-sync.result"
local expect
expect = function(condition, message)
	if not condition then
		return error(message)
	end
end
local run
run = function()
	Content:save(resultPath, "stage: success")
	local progressMessage = ""
	local successDone = false
	local successOperation
	successOperation = function(options)
		options:onStatus({
			progress = 0.5,
			message = "Validating Catalog"
		})
		return {
			addCallbacks = function(self, onSuccess, onFailure)
				return onSuccess(nil, {
					success = true
				})
			end
		}
	end
	local mobileCatalog = require("Dev.Mobile.MobileCatalog")
	mobileCatalog.syncMobileCatalog((function(message)
		progressMessage = message
	end), (function(success, message)
		expect(success and message == nil, "successful Catalog sync result mismatch")
		successDone = true
	end), successOperation)
	expect(successDone, "successful Catalog sync callback did not complete")
	expect(progressMessage == "Validating Catalog", "Catalog progress forwarding mismatch")
	Content:save(resultPath, "stage: failure")
	local failureDone = false
	local failureOperation
	failureOperation = function(options)
		return {
			addCallbacks = function(self, onSuccess, onFailure)
				return onSuccess(nil, {
					success = false,
					message = "offline"
				})
			end
		}
	end
	mobileCatalog.syncMobileCatalog((function() end), (function(success, message)
		expect(not success and message == "offline", "failed Catalog sync result mismatch")
		failureDone = true
	end), failureOperation)
	expect(failureDone, "failed Catalog sync callback did not complete")
	Content:save(resultPath, "stage: rejection")
	local rejectedDone = false
	local rejectedOperation
	rejectedOperation = function(options)
		return {
			addCallbacks = function(self, onSuccess, onFailure)
				return onFailure(nil, "network exception")
			end
		}
	end
	mobileCatalog.syncMobileCatalog((function() end), (function(success, message)
		expect(not success and (message:match("network exception") ~= nil), "rejected Catalog sync result mismatch")
		rejectedDone = true
	end), rejectedOperation)
	return expect(rejectedDone, "rejected Catalog sync callback did not complete")
end
local success, err = pcall(run)
return Content:save(resultPath, (function()
	if success then
		return "passed"
	else
		return "failed: " .. tostring(err)
	end
end)())
