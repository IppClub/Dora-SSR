-- [ts]: FocusManager.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
____exports.FocusManager = __TS__Class() -- 12
local FocusManager = ____exports.FocusManager -- 12
FocusManager.name = "FocusManager" -- 12
function FocusManager.prototype.____constructor(self) -- 12
	self.handles = {} -- 13
end -- 12
function FocusManager.prototype.register(self, handle) -- 16
	self:unregister(handle.id) -- 17
	local ____self_handles_0 = self.handles -- 17
	____self_handles_0[#____self_handles_0 + 1] = handle -- 18
end -- 16
function FocusManager.prototype.unregister(self, id) -- 21
	for i = 1, #self.handles do -- 21
		if self.handles[i].id == id then -- 21
			local handle = self.handles[i] -- 24
			if self.current == handle then -- 24
				handle.blur() -- 26
				self.current = nil -- 27
			end -- 27
			table.remove(self.handles, i) -- 29
			return -- 30
		end -- 30
	end -- 30
end -- 21
function FocusManager.prototype.focus(self, id) -- 35
	for i = 1, #self.handles do -- 35
		local handle = self.handles[i] -- 37
		if handle.id == id and not handle.disabled() then -- 37
			if self.current ~= nil and self.current ~= handle then -- 37
				self.current.blur() -- 40
			end -- 40
			self.current = handle -- 42
			handle.focus() -- 43
			return -- 44
		end -- 44
	end -- 44
end -- 35
function FocusManager.prototype.focusNext(self) -- 49
	if #self.handles == 0 then -- 49
		return -- 50
	end -- 50
	local start = 1 -- 51
	if self.current ~= nil then -- 51
		for i = 1, #self.handles do -- 51
			if self.handles[i] == self.current then -- 51
				start = i + 1 -- 55
				break -- 56
			end -- 56
		end -- 56
	end -- 56
	for offset = 0, #self.handles - 1 do -- 56
		local index = (start + offset - 1) % #self.handles + 1 -- 61
		local handle = self.handles[index] -- 62
		if not handle.disabled() then -- 62
			self:focus(handle.id) -- 64
			return -- 65
		end -- 65
	end -- 65
end -- 49
function FocusManager.prototype.activate(self) -- 70
	if self.current ~= nil and not self.current.disabled() then -- 70
		self.current.activate() -- 72
	end -- 72
end -- 70
function FocusManager.prototype.clear(self) -- 76
	if self.current ~= nil then -- 76
		self.current.blur() -- 78
	end -- 78
	self.current = nil -- 80
	self.handles = {} -- 81
end -- 76
return ____exports -- 76