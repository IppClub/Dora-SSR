-- [yue]: UI/Control/StartPanel.yue
local Class = Dora.Class -- 1
local Audio = Dora.Audio -- 1
local emit = Dora.emit -- 1
local App = Dora.App -- 1
local nvg = Dora.nvg -- 1
local Vec2 = Dora.Vec2 -- 1
local ipairs = _G.ipairs -- 1
local Rect = Dora.Rect -- 1
local _module_0 = nil -- 1
local StartPanel = require("UI.View.StartPanel") -- 10
local _anon_func_0 = function(button, self) -- 23
	if self.fButton == button then -- 21
		return "Flandre" -- 21
	elseif self.vButton == button then -- 22
		return "Villy" -- 22
	elseif self.dButton == button then -- 23
		return "Dorothy" -- 23
	end -- 23
end -- 20
_module_0 = Class(StartPanel, { -- 13
	__init = function(self) -- 13
		local buttons = { -- 14
			self.fButton, -- 14
			self.vButton, -- 14
			self.dButton -- 14
		} -- 14
		for _index_0 = 1, #buttons do -- 15
			local button = buttons[_index_0] -- 15
			button:slot("Tapped", function() -- 16
				Audio:play("Audio/choose.wav") -- 17
				for _index_1 = 1, #buttons do -- 18
					local btn = buttons[_index_1] -- 18
					btn.touchEnabled = false -- 19
				end -- 19
				return emit("PlayerSelect", _anon_func_0(button, self)) -- 23
			end) -- 16
		end -- 23
		self:slot("Enter", function() -- 24
			return emit("InputManager.Select", true) -- 24
		end) -- 24
		self:slot("Exit", function() -- 25
			return emit("InputManager.Select", false) -- 25
		end) -- 25
		self.node:schedule(function() -- 26
			local bw, bh -- 27
			do -- 27
				local _obj_0 = App.bufferSize -- 27
				bw, bh = _obj_0.width, _obj_0.height -- 27
			end -- 27
			local vw = App.visualSize.width -- 28
			local pos = nvg.TouchPos() * (bw / vw) -- 29
			pos = Vec2(pos.x - bw / 2, bh / 2 - pos.y) -- 30
			for _, button in ipairs(buttons) do -- 31
				local localPos = button:convertToNodeSpace(pos) -- 32
				if Rect(Vec2.zero, button.size):containsPoint(localPos) then -- 33
					button:glow() -- 34
				else -- 36
					button:stopGlow() -- 36
				end -- 33
			end -- 36
		end) -- 26
		self.node:slot("PanelHide", function() -- 37
			return self:removeFromParent() -- 37
		end) -- 37
		self.node:gslot("Input.Flandre", function() -- 38
			if self.fButton.touchEnabled then -- 38
				return self.fButton:emit("Tapped") -- 38
			end -- 38
		end) -- 38
		self.node:gslot("Input.Dorothy", function() -- 39
			if self.dButton.touchEnabled then -- 39
				return self.dButton:emit("Tapped") -- 39
			end -- 39
		end) -- 39
		return self.node:gslot("Input.Villy", function() -- 40
			if self.vButton.touchEnabled then -- 40
				return self.vButton:emit("Tapped") -- 40
			end -- 40
		end) -- 40
	end -- 13
}) -- 12
return _module_0 -- 40
