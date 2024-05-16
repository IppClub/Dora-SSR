-- [yue]: Script/Game/Loli War/UI/Control/ButtonGlow.yue
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
			_with_0.position = self:convertToWorldSpace(touch.location) -- 16
			_with_0:addTo(Director.ui) -- 17
			_with_0:autoRemove() -- 18
			_with_0:start() -- 19
			return _with_0 -- 15
		end) -- 19
	end, -- 13
	glow = function(self) -- 21
		if not self.scheduled then -- 22
			Audio:play("Audio/select.wav") -- 23
			return self:schedule(loop(function() -- 24
				self.up.visible = false -- 25
				self.down.visible = true -- 26
				sleep(0.5) -- 27
				self.up.visible = true -- 28
				self.down.visible = false -- 29
				return sleep(0.5) -- 30
			end)) -- 30
		end -- 22
	end, -- 21
	stopGlow = function(self) -- 32
		if self.scheduled then -- 33
			self:unschedule() -- 34
			self.up.visible = true -- 35
			self.down.visible = false -- 36
		end -- 33
	end -- 32
}) -- 12
return _module_0 -- 36
