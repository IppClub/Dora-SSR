-- [ts]: SessionEvents.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__NumberIsFinite = ____lualib.__TS__NumberIsFinite -- 1
local __TS__Delete = ____lualib.__TS__Delete -- 1
local __TS__ObjectValues = ____lualib.__TS__ObjectValues -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local ____exports = {} -- 1
local listeners = {} -- 3
local sequences = {} -- 4
local nextId = 0 -- 5
--- Trusted host subscription; not an authorization boundary for project code.
function ____exports.subscribeSessionPatches(sessionId, listener) -- 8
	if type(sessionId) ~= "number" or not __TS__NumberIsFinite(sessionId) or math.floor(sessionId) ~= sessionId or sessionId <= 0 or sessionId > 9007199254740991 or type(listener) ~= "function" then -- 8
		error("Invalid session subscription") -- 9
	end -- 9
	nextId = nextId + 1 -- 10
	local id = nextId -- 10
	listeners[id] = {sessionId = sessionId, listener = listener} -- 11
	return function() -- 12
		__TS__Delete(listeners, id) -- 12
	end -- 12
end -- 8
--- Immutable serialized payload, snapshot iteration and isolated observer errors.
function ____exports.publishSessionPatch(sessionId, payload) -- 16
	local sequence = (sequences[sessionId] or 0) + 1 -- 17
	if sequence > 9007199254740991 then -- 17
		error("Session event sequence exhausted") -- 18
	end -- 18
	sequences[sessionId] = sequence -- 19
	local pending = __TS__ArrayFilter( -- 20
		__TS__ObjectValues(listeners), -- 20
		function(____, item) return item.sessionId == sessionId end -- 20
	) -- 20
	local failed = 0 -- 21
	for ____, item in ipairs(pending) do -- 22
		do -- 22
			local function ____catch() -- 22
				failed = failed + 1 -- 23
			end -- 23
			local ____try = pcall(function() -- 23
				item.listener(payload, sequence) -- 23
			end) -- 23
			if not ____try then -- 23
				____catch() -- 23
			end -- 23
		end -- 23
	end -- 23
	return failed -- 25
end -- 16
--- Read on the same trusted synchronous host. A yielding/mutating read is not a stable snapshot.
-- Sequence numbers are runtime-local; a runtime restart requires a new host generation.
function ____exports.captureSessionSnapshot(sessionId, read) -- 31
	if not __TS__NumberIsFinite(sessionId) or math.floor(sessionId) ~= sessionId or sessionId <= 0 or sessionId > 9007199254740991 then -- 31
		error("Invalid snapshot session") -- 32
	end -- 32
	local sequence = sequences[sessionId] or 0 -- 33
	local payload = read() -- 34
	if type(payload) ~= "string" or (sequences[sessionId] or 0) ~= sequence then -- 34
		error("Session changed during snapshot read") -- 35
	end -- 35
	return {payload = payload, sequence = sequence} -- 36
end -- 31
return ____exports -- 31