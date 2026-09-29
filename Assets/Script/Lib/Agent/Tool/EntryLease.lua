-- [ts]: EntryLease.ts
local ____exports = {} -- 1
local owner = "" -- 18
local runId -- 19
--- Acquires the Agent-owned Entry runtime. A running game without an Agent
-- owner belongs to the user and is stopped so Agent work takes priority.
-- Agent-owned runs remain mutually exclusive and are never preempted.
-- Returns true when a user game was interrupted.
function ____exports.acquireEntryLease(id, entry) -- 26
	if owner ~= "" and owner ~= id then -- 26
		error("Dora entry runtime is busy with another Agent tool") -- 27
	end -- 27
	local status = entry.getCurrentEntryStatus() -- 28
	local interruptedUserRun = false -- 29
	if status.running and (owner ~= id or status.runId ~= runId) then -- 29
		if owner ~= "" then -- 29
			error("Dora entry runtime is busy with another Agent tool") -- 31
		end -- 31
		if not entry.stop() then -- 31
			error("Dora could not interrupt the running user game for Agent work") -- 32
		end -- 32
		interruptedUserRun = true -- 33
	end -- 33
	owner = id -- 35
	return interruptedUserRun -- 36
end -- 26
function ____exports.recordEntryLeaseRun(id, entry) -- 41
	if owner == id then -- 41
		runId = (entry.getCurrentEntryStatus().runId or 0) + 1 -- 42
	end -- 42
end -- 41
function ____exports.ownsEntryLease(id, entry) -- 44
	local status = entry.getCurrentEntryStatus() -- 45
	return owner == id and status.running and runId ~= nil and status.runId == runId -- 46
end -- 44
function ____exports.releaseEntryLease(id, entry) -- 48
	if owner ~= id then -- 48
		return nil -- 49
	end -- 49
	local cleanupError -- 50
	do -- 50
		local function ____catch(e) -- 50
			cleanupError = "failed to stop Agent preview: " .. tostring(e) -- 52
		end -- 52
		local ____try, ____hasReturned = pcall(function() -- 52
			if ____exports.ownsEntryLease(id, entry) and not entry.stop() then -- 52
				error("entry refused to stop") -- 51
			end -- 51
		end) -- 51
		if not ____try then -- 51
			____catch(____hasReturned) -- 51
		end -- 51
	end -- 51
	owner = "" -- 53
	runId = nil -- 53
	return cleanupError -- 54
end -- 48
return ____exports -- 48