-- [yue]: Script/Game/Loli War/UI/Control/Digit.yue
local Class = Dora.Class -- 1
local property = Dora.property -- 1
local math = _G.math -- 1
local Sprite = Dora.Sprite -- 1
local tostring = _G.tostring -- 1
local Vec2 = Dora.Vec2 -- 1
local _module_0 = nil -- 1
local Digit = require("UI.View.Digit") -- 10
_module_0 = Class(Digit, { -- 13
	__init = function(self) -- 13
		self._value = 99 -- 14
		self.maxValue = 99 -- 15
	end, -- 13
	value = property((function(self) -- 17
		return self._value -- 17
	end), function(self, value) -- 18
		self._value = math.max(math.min(self.maxValue, value), 0) -- 19
		self:removeAllChildren() -- 20
		local two = math.floor(self._value / 10) -- 21
		if two > 0 then -- 22
			local _with_0 = Sprite("Model/misc.clip|" .. tostring(two)) -- 23
			_with_0.anchor = Vec2(0, 0.5) -- 24
			_with_0:addTo(self) -- 25
		end -- 22
		local one = math.floor(self._value % 10) -- 26
		local _with_0 = Sprite("Model/misc.clip|" .. tostring(one)) -- 27
		_with_0.x = 6 -- 28
		_with_0.anchor = Vec2(0, 0.5) -- 29
		_with_0:addTo(self) -- 30
		return _with_0 -- 27
	end) -- 17
}) -- 12
return _module_0 -- 30
