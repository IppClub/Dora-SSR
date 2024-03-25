-- [yue]: Script/Game/Loli War/UI/Control/StartPanel.yue
local Class = dora.Class -- 1
local Audio = dora.Audio -- 1
local emit = dora.emit -- 1
local App = dora.App -- 1
local nvg = dora.nvg -- 1
local Vec2 = dora.Vec2 -- 1
local ipairs = _G.ipairs -- 1
local Rect = dora.Rect -- 1
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
		self.node:schedule(function() -- 24
			local bw, bh -- 25
			do -- 25
				local _obj_0 = App.bufferSize -- 25
				bw, bh = _obj_0.width, _obj_0.height -- 25
			end -- 25
			local vw, vh -- 26
			do -- 26
				local _obj_0 = App.visualSize -- 26
				vw, vh = _obj_0.width, _obj_0.height -- 26
			end -- 26
			local pos = nvg.TouchPos() * (bw / vw) -- 27
			pos = Vec2(pos.x - bw / 2, bh / 2 - pos.y) -- 28
			for _, button in ipairs(buttons) do -- 29
				local localPos = button:convertToNodeSpace(pos) -- 30
				if Rect(Vec2.zero, button.size):containsPoint(localPos) then -- 31
					button:glow() -- 32
				else -- 34
					button:stopGlow() -- 34
				end -- 31
			end -- 34
		end) -- 24
		return self.node:slot("PanelHide", function() -- 35
			return self:removeFromParent() -- 35
		end) -- 35
	end -- 13
}) -- 12
return _module_0 -- 35
