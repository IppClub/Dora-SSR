-- [yue]: Script/Game/Zombie Escape/Action.yue
local _module_0 = Dora.Platformer -- 1
local UnitAction = _module_0.UnitAction -- 1
local groundEntranceEnd -- 11
groundEntranceEnd = function(name, playable) -- 11
	if not (name == "groundEntrance") then -- 12
		return -- 12
	end -- 12
	return playable.parent:stop() -- 13
end -- 11
UnitAction:add("groundEntrance", { -- 16
	priority = 6, -- 16
	reaction = -1, -- 17
	recovery = 0, -- 18
	queued = true, -- 19
	create = function(self) -- 20
		self.data.lastGroup = self.group -- 21
		self.group = 0 -- 22
		do -- 23
			local _with_0 = self.playable -- 23
			_with_0.speed = 1 -- 24
			_with_0:slot("AnimationEnd", groundEntranceEnd) -- 25
			_with_0:play("groundEntrance") -- 26
		end -- 23
		return function() -- 27
			return false -- 27
		end -- 27
	end, -- 20
	stop = function(self) -- 28
		self.playable:slot("AnimationEnd"):remove(groundEntranceEnd) -- 29
		self.group = self.data.lastGroup -- 30
		self.data.lastGroup = nil -- 31
		self.data.entered = true -- 32
	end -- 28
}) -- 15
return UnitAction:add("fallOff", { -- 35
	priority = 1, -- 35
	reaction = 1, -- 36
	recovery = 0, -- 37
	available = function(self) -- 38
		return not self.onSurface -- 38
	end, -- 38
	create = function(self) -- 39
		if self.velocityY <= 0 then -- 40
			self.data.fallDown = true -- 41
			local _with_0 = self.playable -- 42
			_with_0.speed = 1 -- 43
			_with_0:play("fallOff") -- 44
		else -- 45
			self.data.fallDown = false -- 45
		end -- 40
		return function(self, action) -- 46
			if self.onSurface then -- 47
				return true -- 47
			end -- 47
			if not self.data.fallDown and self.playable.current ~= "fallOff" and self.velocityY <= 0 then -- 48
				self.data.fallDown = true -- 51
				local _with_0 = self.playable -- 52
				_with_0.speed = 1 -- 53
				_with_0:play("fallOff") -- 54
			end -- 48
			return false -- 55
		end -- 55
	end -- 39
}) -- 55
