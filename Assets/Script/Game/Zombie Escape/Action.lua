-- [yue]: Script/Game/Zombie Escape/Action.yue
local _module_0 = dora.Platformer -- 1
local UnitAction = _module_0.UnitAction -- 1
local groundEntranceEnd -- 3
groundEntranceEnd = function(name, playable) -- 3
	if not (name == "groundEntrance") then -- 4
		return -- 4
	end -- 4
	return playable.parent:stop() -- 5
end -- 3
UnitAction:add("groundEntrance", { -- 8
	priority = 6, -- 8
	reaction = -1, -- 9
	recovery = 0, -- 10
	queued = true, -- 11
	create = function(self) -- 12
		self.data.lastGroup = self.group -- 13
		self.group = 0 -- 14
		do -- 15
			local _with_0 = self.playable -- 15
			_with_0.speed = 1 -- 16
			_with_0:slot("AnimationEnd", groundEntranceEnd) -- 17
			_with_0:play("groundEntrance") -- 18
		end -- 15
		return function() -- 19
			return false -- 19
		end -- 19
	end, -- 12
	stop = function(self) -- 20
		self.playable:slot("AnimationEnd"):remove(groundEntranceEnd) -- 21
		self.group = self.data.lastGroup -- 22
		self.data.lastGroup = nil -- 23
		self.data.entered = true -- 24
	end -- 20
}) -- 7
return UnitAction:add("fallOff", { -- 27
	priority = 1, -- 27
	reaction = 1, -- 28
	recovery = 0, -- 29
	available = function(self) -- 30
		return not self.onSurface -- 30
	end, -- 30
	create = function(self) -- 31
		if self.velocityY <= 0 then -- 32
			self.data.fallDown = true -- 33
			local _with_0 = self.playable -- 34
			_with_0.speed = 1 -- 35
			_with_0:play("fallOff") -- 36
		else -- 37
			self.data.fallDown = false -- 37
		end -- 32
		return function(self, action) -- 38
			if self.onSurface then -- 39
				return true -- 39
			end -- 39
			if not self.data.fallDown and self.playable.current ~= "fallOff" and self.velocityY <= 0 then -- 40
				self.data.fallDown = true -- 43
				local _with_0 = self.playable -- 44
				_with_0.speed = 1 -- 45
				_with_0:play("fallOff") -- 46
			end -- 40
			return false -- 47
		end -- 47
	end -- 31
}) -- 47
