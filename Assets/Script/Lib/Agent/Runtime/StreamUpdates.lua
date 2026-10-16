-- [ts]: StreamUpdates.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ObjectKeys = ____lualib.__TS__ObjectKeys -- 1
local __TS__ArraySome = ____lualib.__TS__ArraySome -- 1
local __TS__Delete = ____lualib.__TS__Delete -- 1
local ____exports = {} -- 1
--- Keep the first snapshot immediate, bound subsequent latency, and release
-- full text snapshots at every terminal/session lifecycle boundary.
____exports.StreamUpdates = __TS__Class() -- 19
local StreamUpdates = ____exports.StreamUpdates -- 19
StreamUpdates.name = "StreamUpdates" -- 19
function StreamUpdates.prototype.____constructor(self, publish) -- 21
	self.publish = publish -- 21
	self.entries = {} -- 20
end -- 21
function StreamUpdates.prototype.key(self, sessionId, taskId, step) -- 22
	return (((tostring(sessionId) .. ":") .. tostring(taskId)) .. ":") .. tostring(step) -- 23
end -- 22
function StreamUpdates.prototype.length(self, value) -- 25
	local ____opt_0 = value.content -- 25
	local ____temp_4 = ____opt_0 and ____opt_0.length or 0 -- 26
	local ____opt_2 = value.reasoningContent -- 26
	return ____temp_4 + (____opt_2 and ____opt_2.length or 0) -- 26
end -- 25
function StreamUpdates.prototype.flush(self, entry, now) -- 28
	entry.dirty = false -- 29
	entry.deltas = 0 -- 30
	entry.length = self:length(entry.value) -- 31
	entry.flushedAt = now -- 32
	self.publish(entry.sessionId, entry.taskId, entry.step, entry.value) -- 33
end -- 28
function StreamUpdates.prototype.update(self, sessionId, taskId, step, value, now) -- 35
	local key = self:key(sessionId, taskId, step) -- 36
	local entry = self.entries[key] -- 37
	if entry == nil then -- 37
		entry = { -- 39
			sessionId = sessionId, -- 39
			taskId = taskId, -- 39
			step = step, -- 39
			value = {content = value.content, reasoningContent = value.reasoningContent}, -- 39
			deltas = 0, -- 39
			length = 0, -- 39
			flushedAt = now, -- 39
			dirty = true -- 39
		} -- 39
		self.entries[key] = entry -- 40
		self:flush(entry, now) -- 41
		return -- 42
	end -- 42
	entry.value = {content = value.content ~= nil and value.content ~= "" and value.content or entry.value.content, reasoningContent = value.reasoningContent ~= nil and value.reasoningContent ~= "" and value.reasoningContent or entry.value.reasoningContent} -- 46
	entry.dirty = true -- 50
	entry.deltas = entry.deltas + 1 -- 51
	if entry.deltas >= 32 or self:length(entry.value) - entry.length >= 4096 or now - entry.flushedAt >= 0.1 then -- 51
		self:flush(entry, now) -- 53
	end -- 53
end -- 35
function StreamUpdates.prototype.flushDue(self, now) -- 55
	for ____, key in ipairs(__TS__ObjectKeys(self.entries)) do -- 56
		local entry = self.entries[key] -- 57
		if entry ~= nil and entry.dirty and now - entry.flushedAt >= 0.1 then -- 57
			self:flush(entry, now) -- 58
		end -- 58
	end -- 58
end -- 55
function StreamUpdates.prototype.hasPending(self) -- 61
	return __TS__ArraySome( -- 62
		__TS__ObjectKeys(self.entries), -- 62
		function(____, key) return self.entries[key].dirty end -- 62
	) -- 62
end -- 61
function StreamUpdates.prototype.finish(self, sessionId, taskId, step) -- 64
	__TS__Delete( -- 65
		self.entries, -- 65
		self:key(sessionId, taskId, step) -- 65
	) -- 65
end -- 64
function StreamUpdates.prototype.clear(self, sessionId, taskId, flushAt) -- 67
	for ____, key in ipairs(__TS__ObjectKeys(self.entries)) do -- 68
		do -- 68
			local entry = self.entries[key] -- 69
			if entry == nil or entry.sessionId ~= sessionId or taskId ~= nil and entry.taskId ~= taskId then -- 69
				goto __continue17 -- 70
			end -- 70
			__TS__Delete(self.entries, key) -- 72
			if entry.dirty and flushAt ~= nil then -- 72
				self:flush(entry, flushAt) -- 73
			end -- 73
		end -- 73
		::__continue17:: -- 73
	end -- 73
end -- 67
return ____exports -- 67