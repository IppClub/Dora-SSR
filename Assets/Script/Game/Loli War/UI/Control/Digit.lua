-- [yue]: Script/Game/Loli War/UI/Control/Digit.yue
local Class = dora.Class -- 1
local property = dora.property -- 1
local math = _G.math -- 1
local Sprite = dora.Sprite -- 1
local tostring = _G.tostring -- 1
local Vec2 = dora.Vec2 -- 1
local _module_0 = nil -- 1
local Digit = require("UI.View.Digit") -- 2
_module_0 = Class(Digit, { -- 5
	__init = function(self) -- 5
		self._value = 99 -- 6
		self.maxValue = 99 -- 7
	end, -- 5
	value = property((function(self) -- 9
		return self._value -- 9
	end), function(self, value) -- 10
		self._value = math.max(math.min(self.maxValue, value), 0) -- 11
		self:removeAllChildren() -- 12
		local two = math.floor(self._value / 10) -- 13
		if two > 0 then -- 14
			do -- 15
				local _with_0 = Sprite("Model/misc.clip|" .. tostring(two)) -- 15
				_with_0.anchor = Vec2(0, 0.5) -- 16
				_with_0:addTo(self) -- 17
			end -- 15
		end -- 14
		local one = math.floor(self._value % 10) -- 18
		local _with_0 = Sprite("Model/misc.clip|" .. tostring(one)) -- 19
		_with_0.x = 6 -- 20
		_with_0.anchor = Vec2(0, 0.5) -- 21
		_with_0:addTo(self) -- 22
		return _with_0 -- 19
	end) -- 9
}) -- 4
return _module_0 -- 22
