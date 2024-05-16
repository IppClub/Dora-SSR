-- [yue]: Script/Lib/UI/Control/Basic/Button.yue
local Class = Dora.Class -- 1
local once = Dora.once -- 1
local sleep = Dora.sleep -- 1
local property = Dora.property -- 1
local _module_0 = nil -- 1
local Button = require("UI.View.Control.Basic.Button") -- 10
_module_0 = Class(Button, { -- 17
	__init = function(self, args) -- 17
		if self.label then -- 18
			self._text = self.label.text -- 18
		end -- 18
		self:slot("TapFilter", function(touch) -- 19
			if not touch.first then -- 20
				touch.enabled = false -- 20
			end -- 20
		end) -- 19
		return self:slot("Tapped", function() -- 21
			local enabled = self.touchEnabled -- 22
			self.touchEnabled = false -- 23
			return self:schedule(once(function() -- 24
				sleep() -- 25
				self.touchEnabled = enabled -- 26
			end)) -- 26
		end) -- 26
	end, -- 17
	text = property((function(self) -- 28
		return self._text -- 28
	end), function(self, value) -- 29
		self._text = value -- 30
		if self.label then -- 31
			self.label.text = value -- 31
		end -- 31
	end) -- 28
}) -- 16
return _module_0 -- 31
