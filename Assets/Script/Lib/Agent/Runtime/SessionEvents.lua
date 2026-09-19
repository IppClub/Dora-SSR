-- [ts]: SessionEvents.ts
local exports = {}
local listeners, nextId = {}, 0
local sequences = {}
function exports.subscribeSessionPatches(sessionId, listener)
	if type(sessionId) ~= "number" or sessionId <= 0 or sessionId > 9007199254740991 or sessionId % 1 ~= 0 or type(listener) ~= "function" then error("Invalid session subscription") end
	nextId = nextId + 1
	local id = nextId
	listeners[id] = {sessionId = sessionId, listener = listener}
	return function() listeners[id] = nil end
end
function exports.publishSessionPatch(sessionId, payload)
	local sequence = (sequences[sessionId] or 0) + 1
	if sequence > 9007199254740991 then error("Session event sequence exhausted") end
	sequences[sessionId] = sequence
	local pending = {}
	for _, item in pairs(listeners) do if item.sessionId == sessionId then pending[#pending + 1] = item end end
	local failed = 0
	for _, item in ipairs(pending) do
		if not pcall(item.listener, payload, sequence) then failed = failed + 1 end
	end
	return failed
end
function exports.captureSessionSnapshot(sessionId, read)
	if type(sessionId) ~= "number" or sessionId <= 0 or sessionId > 9007199254740991 or sessionId % 1 ~= 0 then error("Invalid snapshot session") end
	local sequence = sequences[sessionId] or 0
	local payload = read()
	if type(payload) ~= "string" or (sequences[sessionId] or 0) ~= sequence then error("Session changed during snapshot read") end
	return {payload = payload, sequence = sequence}
end
return exports
