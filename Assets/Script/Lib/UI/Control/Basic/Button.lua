-- [yue]: Script/Lib/UI/Control/Basic/Button.yue
local Class = dora.Class -- 1
local once = dora.once -- 1
local sleep = dora.sleep -- 1
local property = dora.property -- 1
local _module_0 = nil -- 1
local Button = require("UI.View.Control.Basic.Button") -- 2
_module_0 = Class(Button, { -- 9
	__init = function(self, args) -- 9
		if self.label then -- 10
			self._text = self.label.text -- 10
		end -- 10
		self:slot("TapFilter", function(touch) -- 11
			if not touch.first then -- 12
				touch.enabled = false -- 12
			end -- 12
		end) -- 11
		return self:slot("Tapped", function() -- 13
			local enabled = self.touchEnabled -- 14
			self.touchEnabled = false -- 15
			return self:schedule(once(function() -- 16
				sleep() -- 17
				self.touchEnabled = enabled -- 18
			end)) -- 18
		end) -- 18
	end, -- 9
	text = property((function(self) -- 20
		return self._text -- 20
	end), function(self, value) -- 21
		self._text = value -- 22
		if self.label then -- 23
			self.label.text = value -- 23
		end -- 23
	end) -- 20
}) -- 8
return _module_0 -- 23
