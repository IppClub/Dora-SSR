-- [yue]: UI/Control/ButtonGlow.yue
local Class = Dora.Class -- 1
local _module_0 = Dora.Platformer -- 1
local Visual = _module_0.Visual -- 1
local Director = Dora.Director -- 1
local Audio = Dora.Audio -- 1
local loop = Dora.loop -- 1
local sleep = Dora.sleep -- 1
local _module_0 = nil -- 1
local ButtonGlow = require("UI.View.ButtonGlow") -- 10
_module_0 = Class(ButtonGlow, { -- 13
	__init = function(self) -- 13
		return self:slot("Tapped", function(touch) -- 14
			local _with_0 = Visual("Particle/select.par") -- 15
			if touch then -- 16
				_with_0.position = self:convertToWorldSpace(touch.location) -- 17
			else -- 19
				_with_0.position = self.parent:convertToWorldSpace(self.position) -- 19
			end -- 16
			_with_0:addTo(Director.ui) -- 20
			_with_0:autoRemove() -- 21
			_with_0:start() -- 22
			return _with_0 -- 15
		end) -- 22
	end, -- 13
	glow = function(self) -- 24
		if not self.scheduled then -- 25
			Audio:play("Audio/select.wav") -- 26
			return self:schedule(loop(function() -- 27
				self.up.visible = false -- 28
				self.down.visible = true -- 29
				sleep(0.5) -- 30
				self.up.visible = true -- 31
				self.down.visible = false -- 32
				return sleep(0.5) -- 33
			end)) -- 33
		end -- 25
	end, -- 24
	stopGlow = function(self) -- 35
		if self.scheduled then -- 36
			self:unschedule() -- 37
			self.up.visible = true -- 38
			self.down.visible = false -- 39
		end -- 36
	end -- 35
}) -- 12
return _module_0 -- 39
