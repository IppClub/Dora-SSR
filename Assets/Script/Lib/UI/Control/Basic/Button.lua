-- [yue]: Script/Lib/UI/Control/Basic/Button.yue
local _module_0 = nil -- 1
local _ENV = Dora -- 9
local Button = require("UI.View.Control.Basic.Button") -- 10
local Class <const> = Class -- 11
local once <const> = once -- 11
local sleep <const> = sleep -- 11
local property <const> = property -- 11
_module_0 = Class(Button, { -- 18
	__init = function(self) -- 18
		if self.label then -- 19
			self._text = self.label.text -- 19
		end -- 19
		self:slot("TapFilter", function(touch) -- 20
			if not touch.first then -- 21
				touch.enabled = false -- 21
			end -- 21
		end) -- 20
		return self:slot("Tapped", function() -- 22
			local enabled = self.touchEnabled -- 23
			self.touchEnabled = false -- 24
			return self:schedule(once(function() -- 25
				sleep() -- 26
				self.touchEnabled = enabled -- 27
			end)) -- 25
		end) -- 22
	end, -- 18
	text = property((function(self) -- 29
		return self._text -- 29
	end), function(self, value) -- 30
		self._text = value -- 31
		if self.label then -- 32
			self.label.text = value -- 32
		end -- 32
	end) -- 29
}) -- 17
return _module_0 -- 1
