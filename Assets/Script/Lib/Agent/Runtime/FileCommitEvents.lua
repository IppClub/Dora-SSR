-- [ts]: FileCommitEvents.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Delete = ____lualib.__TS__Delete -- 1
local __TS__ObjectValues = ____lualib.__TS__ObjectValues -- 1
local __TS__ArraySome = ____lualib.__TS__ArraySome -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local ____exports = {} -- 1
local listeners = {} -- 3
local nextId = 0 -- 4
--- Trusted host notifications only; checkpoint storage remains authoritative.
function ____exports.subscribeFileCommits(workDir, listener) -- 7
	if type(workDir) ~= "string" or workDir == "" or type(listener) ~= "function" then -- 7
		error("Invalid file commit subscription") -- 8
	end -- 8
	nextId = nextId + 1 -- 9
	local id = nextId -- 9
	listeners[id] = {workDir = workDir, listener = listener} -- 10
	return function() -- 11
		__TS__Delete(listeners, id) -- 11
	end -- 11
end -- 7
function ____exports.hasFileCommitListeners(workDir) -- 14
	return __TS__ArraySome( -- 15
		__TS__ObjectValues(listeners), -- 15
		function(____, item) return item.workDir == workDir end -- 15
	) -- 15
end -- 14
--- Immutable serialized batch; observer errors cannot undo a completed tool commit.
-- This notification is not an acknowledgement of Studio workspace persistence.
function ____exports.publishFileCommit(workDir, payload) -- 21
	local pending = __TS__ArrayFilter( -- 22
		__TS__ObjectValues(listeners), -- 22
		function(____, item) return item.workDir == workDir end -- 22
	) -- 22
	local failed = 0 -- 23
	for ____, item in ipairs(pending) do -- 24
		do -- 24
			local function ____catch() -- 24
				failed = failed + 1 -- 25
			end -- 25
			local ____try = pcall(function() -- 25
				item.listener(payload) -- 25
			end) -- 25
			if not ____try then -- 25
				____catch() -- 25
			end -- 25
		end -- 25
	end -- 25
	return failed -- 27
end -- 21
return ____exports -- 21
