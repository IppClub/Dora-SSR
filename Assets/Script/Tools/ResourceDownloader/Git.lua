-- [ts]: Git.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Promise = ____lualib.__TS__Promise -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local Director = ____Dora.Director -- 2
local Git = ____Dora.Git -- 2
____exports.quoteGitArgument = function(value) -- 29
	local escapedSlashes = string.gsub(value, "\\", "\\\\") -- 30
	local escapedQuotes = string.gsub(escapedSlashes, "\"", "\\\"") -- 31
	return ("\"" .. escapedQuotes) .. "\"" -- 32
end -- 29
____exports.runGit = function(repoPath, command, options) -- 35
	if options == nil then -- 35
		options = {} -- 38
	end -- 38
	return __TS__New( -- 40
		__TS__Promise, -- 40
		function(____, resolve) -- 40
			local timeout = options.timeout or 1200 -- 41
			local currentStatus -- 42
			local settled = false -- 43
			local cancelRequested = false -- 44
			local timedOut = false -- 45
			local jobId = 0 -- 46
			local function finish(result) -- 47
				if settled then -- 47
					return -- 48
				end -- 48
				settled = true -- 49
				resolve(nil, result) -- 50
			end -- 47
			local function consumeTerminalStatus() -- 52
				if not currentStatus then -- 52
					return false -- 53
				end -- 53
				if currentStatus.state == "done" then -- 53
					finish({success = true, status = currentStatus}) -- 55
					return true -- 56
				end -- 56
				if currentStatus.state == "error" or currentStatus.state == "canceled" then -- 56
					finish({success = false, status = currentStatus, message = timedOut and "Git operation timed out" or (currentStatus.error or currentStatus.message or "Git operation failed"), canceled = not timedOut and currentStatus.state == "canceled"}) -- 59
					return true -- 65
				end -- 65
				return false -- 67
			end -- 52
			jobId = Git:run( -- 69
				repoPath, -- 69
				command, -- 69
				function(status) -- 69
					local nextStatus = status -- 70
					if type(nextStatus.progress) ~= "number" then -- 70
						nextStatus.progress = currentStatus and currentStatus.progress or 0 -- 72
					end -- 72
					currentStatus = nextStatus -- 74
					if options.onStatus then -- 74
						options:onStatus(currentStatus) -- 75
					end -- 75
					consumeTerminalStatus() -- 76
				end -- 69
			) -- 69
			if jobId <= 0 then -- 69
				finish({success = false, message = "Failed to start Git operation"}) -- 79
				return -- 80
			end -- 80
			local startedAt = os.time() -- 82
			Director.systemScheduler:schedule(function() -- 83
				if settled then -- 83
					return true -- 84
				end -- 84
				if not cancelRequested and options.isCanceled and options:isCanceled() then -- 84
					cancelRequested = true -- 86
					Git:cancel(jobId) -- 87
				end -- 87
				if consumeTerminalStatus() then -- 87
					return true -- 89
				end -- 89
				if not cancelRequested and os.time() - startedAt >= timeout then -- 89
					cancelRequested = true -- 91
					timedOut = true -- 92
					Git:cancel(jobId) -- 93
				end -- 93
				return false -- 95
			end) -- 83
		end -- 40
	) -- 40
end -- 35
____exports.gitHeadFromStatus = function(status) -- 100
	local ____opt_2 = status and status.data -- 100
	local value = ____opt_2 and ____opt_2.head -- 101
	return type(value) == "string" and value or nil -- 102
end -- 100
return ____exports -- 100