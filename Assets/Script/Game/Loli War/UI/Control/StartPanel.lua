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
local StartPanel = require("UI.View.StartPanel") -- 2
local _anon_func_0 = function(button, self) -- 15
	if self.fButton == button then -- 13
		return "Flandre" -- 13
	elseif self.vButton == button then -- 14
		return "Villy" -- 14
	elseif self.dButton == button then -- 15
		return "Dorothy" -- 15
	end -- 15
end -- 12
_module_0 = Class(StartPanel, { -- 5
	__init = function(self) -- 5
		local buttons = { -- 6
			self.fButton, -- 6
			self.vButton, -- 6
			self.dButton -- 6
		} -- 6
		for _index_0 = 1, #buttons do -- 7
			local button = buttons[_index_0] -- 7
			button:slot("Tapped", function() -- 8
				Audio:play("Audio/choose.wav") -- 9
				for _index_1 = 1, #buttons do -- 10
					local btn = buttons[_index_1] -- 10
					btn.touchEnabled = false -- 11
				end -- 11
				return emit("PlayerSelect", _anon_func_0(button, self)) -- 15
			end) -- 8
		end -- 15
		self.node:schedule(function() -- 16
			local bw, bh -- 17
			do -- 17
				local _obj_0 = App.bufferSize -- 17
				bw, bh = _obj_0.width, _obj_0.height -- 17
			end -- 17
			local vw, vh -- 18
			do -- 18
				local _obj_0 = App.visualSize -- 18
				vw, vh = _obj_0.width, _obj_0.height -- 18
			end -- 18
			local pos = nvg.TouchPos() * (bw / vw) -- 19
			pos = Vec2(pos.x - bw / 2, bh / 2 - pos.y) -- 20
			for _, button in ipairs(buttons) do -- 21
				local localPos = button:convertToNodeSpace(pos) -- 22
				if Rect(Vec2.zero, button.size):containsPoint(localPos) then -- 23
					button:glow() -- 24
				else -- 26
					button:stopGlow() -- 26
				end -- 23
			end -- 26
		end) -- 16
		return self.node:slot("PanelHide", function() -- 27
			return self:removeFromParent() -- 27
		end) -- 27
	end -- 5
}) -- 4
return _module_0 -- 27
