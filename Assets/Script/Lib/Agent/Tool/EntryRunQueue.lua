-- [ts]: EntryRunQueue.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__ArraySplice = ____lualib.__TS__ArraySplice -- 1
local ____exports = {} -- 1
--- FIFO admission in front of EntryLease. The queue decides which request may
-- attempt to acquire the renderer; EntryLease remains the authority for
-- ownership of the actual Entry run and its cleanup.
function ____exports.createEntryRunQueue(maxPending) -- 25
	if maxPending == nil then -- 25
		maxPending = 32 -- 25
	end -- 25
	local active = "" -- 26
	local waiting = {} -- 27
	local function validId(id) -- 28
		return type(id) == "string" and __TS__StringTrim(id) ~= "" -- 28
	end -- 28
	local function waitingIndex(id) -- 29
		return __TS__ArrayIndexOf(waiting, id) -- 29
	end -- 29
	return { -- 30
		enqueue = function(self, id) -- 31
			if not validId(id) then -- 31
				return {success = false, message = "entry run id is required"} -- 32
			end -- 32
			if active == id or waitingIndex(id) >= 0 then -- 32
				return {success = false, message = "entry run is already queued"} -- 33
			end -- 33
			if #waiting >= maxPending then -- 33
				return {success = false, message = "entry run queue is full"} -- 34
			end -- 34
			waiting[#waiting + 1] = id -- 35
			return {success = true, position = #waiting} -- 36
		end, -- 31
		tryAcquire = function(self, id) -- 38
			if active == id then -- 38
				return true -- 39
			end -- 39
			if active ~= "" or waiting[1] ~= id then -- 39
				return false -- 40
			end -- 40
			table.remove(waiting, 1) -- 41
			active = id -- 42
			return true -- 43
		end, -- 38
		get = function(self, id) -- 45
			if active == id then -- 45
				return {id = id, state = "running"} -- 46
			end -- 46
			local index = waitingIndex(id) -- 47
			return index >= 0 and ({id = id, state = "queued", position = index + 1}) or ({id = id, state = "missing"}) -- 48
		end, -- 45
		release = function(self, id) -- 50
			if active ~= id then -- 50
				return false -- 51
			end -- 51
			active = "" -- 52
			return true -- 53
		end, -- 50
		cancel = function(self, id) -- 55
			local index = waitingIndex(id) -- 56
			if index < 0 then -- 56
				return false -- 57
			end -- 57
			__TS__ArraySplice(waiting, index, 1) -- 58
			return true -- 59
		end, -- 55
		size = function(self) -- 61
			return #waiting + (active == "" and 0 or 1) -- 62
		end -- 61
	} -- 61
end -- 25
____exports.sharedEntryRunQueue = ____exports.createEntryRunQueue() -- 67
return ____exports -- 67