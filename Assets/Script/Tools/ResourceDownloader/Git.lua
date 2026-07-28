-- [ts]: Git.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Promise = ____lualib.__TS__Promise -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local Director = ____Dora.Director -- 2
local Git = ____Dora.Git -- 2
____exports.quoteGitArgument = function(value) -- 28
	local escapedSlashes = string.gsub(value, "\\", "\\\\") -- 29
	local escapedQuotes = string.gsub(escapedSlashes, "\"", "\\\"") -- 30
	return ("\"" .. escapedQuotes) .. "\"" -- 31
end -- 28
____exports.runGit = function(repoPath, command, options) -- 34
	if options == nil then -- 34
		options = {} -- 37
	end -- 37
	return __TS__New( -- 39
		__TS__Promise, -- 39
		function(____, resolve) -- 39
			local timeout = options.timeout or 1200 -- 40
			local currentStatus -- 41
			local settled = false -- 42
			local jobId = 0 -- 43
			local function finish(result) -- 44
				if settled then -- 44
					return -- 45
				end -- 45
				settled = true -- 46
				resolve(nil, result) -- 47
			end -- 44
			local function consumeTerminalStatus() -- 49
				if not currentStatus then -- 49
					return false -- 50
				end -- 50
				if currentStatus.state == "done" then -- 50
					finish({success = true, status = currentStatus}) -- 52
					return true -- 53
				end -- 53
				if currentStatus.state == "error" or currentStatus.state == "canceled" then -- 53
					finish({success = false, status = currentStatus, message = currentStatus.error or currentStatus.message or "Git operation failed", canceled = currentStatus.state == "canceled"}) -- 56
					return true -- 62
				end -- 62
				return false -- 64
			end -- 49
			jobId = Git:run( -- 66
				repoPath, -- 66
				command, -- 66
				function(status) -- 66
					local nextStatus = status -- 67
					if type(nextStatus.progress) ~= "number" then -- 67
						nextStatus.progress = currentStatus and currentStatus.progress or 0 -- 69
					end -- 69
					currentStatus = nextStatus -- 71
					if options.onStatus then -- 71
						options:onStatus(currentStatus) -- 72
					end -- 72
					consumeTerminalStatus() -- 73
				end -- 66
			) -- 66
			if jobId <= 0 then -- 66
				finish({success = false, message = "Failed to start Git operation"}) -- 76
				return -- 77
			end -- 77
			local startedAt = os.time() -- 79
			Director.systemScheduler:schedule(function() -- 80
				if settled then -- 80
					return true -- 81
				end -- 81
				if options.isCanceled and options:isCanceled() then -- 81
					Git:cancel(jobId) -- 83
					finish({success = false, status = currentStatus, message = "Git operation canceled", canceled = true}) -- 84
					return true -- 85
				end -- 85
				if consumeTerminalStatus() then -- 85
					return true -- 87
				end -- 87
				if os.time() - startedAt >= timeout then -- 87
					Git:cancel(jobId) -- 89
					finish({success = false, status = currentStatus, message = "Git operation timed out"}) -- 90
					return true -- 91
				end -- 91
				return false -- 93
			end) -- 80
		end -- 39
	) -- 39
end -- 34
____exports.gitHeadFromStatus = function(status) -- 98
	local ____opt_2 = status and status.data -- 98
	local value = ____opt_2 and ____opt_2.head -- 99
	return type(value) == "string" and value or nil -- 100
end -- 98
return ____exports -- 98