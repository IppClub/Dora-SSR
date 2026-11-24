-- [ts]: EntryLease.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local sleep = ____Dora.sleep -- 2
local owner = "" -- 20
local runId -- 21
--- Wait for the prior Agent test to clean up while the calling command is live.
function ____exports.acquireEntryLease(id, entry, isCancelled) -- 23
	while owner ~= "" and owner ~= id and not isCancelled() do -- 23
		sleep() -- 24
	end -- 24
	if isCancelled() then -- 24
		error("Agent entry request cancelled") -- 25
	end -- 25
	local status = entry.getCurrentEntryStatus() -- 26
	if status.running and (owner ~= id or status.runId ~= runId) then -- 26
		error("A user game is running. Stop the game before running an Agent preview or test.") -- 28
	end -- 28
	owner = id -- 30
end -- 23
function ____exports.recordEntryLeaseRun(id, entry) -- 35
	if owner == id then -- 35
		runId = (entry.getCurrentEntryStatus().runId or 0) + 1 -- 36
	end -- 36
end -- 35
function ____exports.ownsEntryLease(id, entry) -- 38
	local status = entry.getCurrentEntryStatus() -- 39
	return owner == id and status.running and runId ~= nil and status.runId == runId -- 40
end -- 38
function ____exports.canClearEntryAfterCommand(id, entry) -- 42
	return ____exports.ownsEntryLease(id, entry) or owner == "" and not entry.getCurrentEntryStatus().running -- 43
end -- 42
function ____exports.releaseEntryLease(id, entry) -- 45
	if owner ~= id then -- 45
		return nil -- 46
	end -- 46
	local cleanupError -- 47
	do -- 47
		local function ____catch(e) -- 47
			cleanupError = "failed to stop Agent preview: " .. tostring(e) -- 49
		end -- 49
		local ____try, ____hasReturned = pcall(function() -- 49
			if ____exports.ownsEntryLease(id, entry) and not entry.stop() then -- 49
				error("entry refused to stop") -- 48
			end -- 48
		end) -- 48
		if not ____try then -- 48
			____catch(____hasReturned) -- 48
		end -- 48
	end -- 48
	owner = "" -- 50
	runId = nil -- 50
	return cleanupError -- 51
end -- 45
return ____exports -- 45