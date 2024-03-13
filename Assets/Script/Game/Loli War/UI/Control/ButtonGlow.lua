-- [yue]: Script/Game/Loli War/UI/Control/ButtonGlow.yue
local Class = dora.Class -- 1
local _module_0 = dora.Platformer -- 1
local Visual = _module_0.Visual -- 1
local Director = dora.Director -- 1
local Audio = dora.Audio -- 1
local loop = dora.loop -- 1
local sleep = dora.sleep -- 1
local _module_0 = nil -- 1
local ButtonGlow = require("UI.View.ButtonGlow") -- 2
_module_0 = Class(ButtonGlow, { -- 5
	__init = function(self) -- 5
		return self:slot("Tapped", function(touch) -- 6
			local _with_0 = Visual("Particle/select.par") -- 7
			_with_0.position = self:convertToWorldSpace(touch.location) -- 8
			_with_0:addTo(Director.ui) -- 9
			_with_0:autoRemove() -- 10
			_with_0:start() -- 11
			return _with_0 -- 7
		end) -- 11
	end, -- 5
	glow = function(self) -- 13
		if not self.scheduled then -- 14
			Audio:play("Audio/select.wav") -- 15
			return self:schedule(loop(function() -- 16
				self.up.visible = false -- 17
				self.down.visible = true -- 18
				sleep(0.5) -- 19
				self.up.visible = true -- 20
				self.down.visible = false -- 21
				return sleep(0.5) -- 22
			end)) -- 22
		end -- 14
	end, -- 13
	stopGlow = function(self) -- 24
		if self.scheduled then -- 25
			self:unschedule() -- 26
			self.up.visible = true -- 27
			self.down.visible = false -- 28
		end -- 25
	end -- 24
}) -- 4
return _module_0 -- 28
