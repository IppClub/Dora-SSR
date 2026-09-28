-- [ts]: EntryLease.ts
local ____exports = {} -- 1
local owner = "" -- 18
local runId -- 19
function ____exports.acquireEntryLease(id, entry) -- 27
	if owner ~= "" and owner ~= id then -- 20
		error("Dora entry runtime is busy with another Agent tool") -- 21
	end -- 21
	local status = entry.getCurrentEntryStatus() -- 22
	local interruptedUserRun = false
	if status.running and (owner ~= id or status.runId ~= runId) then -- 22
		if owner ~= "" then
			error("Dora entry runtime is busy with another Agent tool")
		end
		if not entry.stop() then
			error("Dora could not interrupt the running user game for Agent work")
		end
		interruptedUserRun = true
	end -- 23
	owner = id -- 24
	return interruptedUserRun
end -- 27
function ____exports.recordEntryLeaseRun(id, entry) -- 29
	if owner == id then -- 29
		runId = (entry.getCurrentEntryStatus().runId or 0) + 1 -- 30
	end -- 30
end -- 29
function ____exports.ownsEntryLease(id, entry) -- 32
	local status = entry.getCurrentEntryStatus() -- 33
	return owner == id and status.running and runId ~= nil and status.runId == runId -- 34
end -- 32
function ____exports.releaseEntryLease(id, entry) -- 36
	if owner ~= id then -- 36
		return nil -- 37
	end -- 37
	local cleanupError -- 38
	do -- 38
		local function ____catch(e) -- 38
			cleanupError = "failed to stop Agent preview: " .. tostring(e) -- 40
		end -- 40
		local ____try, ____hasReturned = pcall(function() -- 40
			if ____exports.ownsEntryLease(id, entry) and not entry.stop() then -- 40
				error("entry refused to stop") -- 39
			end -- 39
		end) -- 39
		if not ____try then -- 39
			____catch(____hasReturned) -- 39
		end -- 39
	end -- 39
	owner = "" -- 41
	runId = nil -- 41
	return cleanupError -- 42
end -- 36
return ____exports -- 36
