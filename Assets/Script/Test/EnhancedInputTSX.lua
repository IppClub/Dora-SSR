-- [tsx]: EnhancedInputTSX.tsx
local ____exports = {} -- 1
local ____DoraX = require("DoraX") -- 2
local React = ____DoraX.React -- 2
local toNode = ____DoraX.toNode -- 2
local ____Dora = require("Dora") -- 3
local App = ____Dora.App -- 3
local Node = ____Dora.Node -- 3
local Vec2 = ____Dora.Vec2 -- 3
local loop = ____Dora.loop -- 3
local threadLoop = ____Dora.threadLoop -- 3
local ImGui = require("ImGui") -- 4
local ____InputManager = require("InputManager") -- 6
local GamePad = ____InputManager.GamePad -- 6
local CreateManager = ____InputManager.CreateManager -- 6
local Trigger = ____InputManager.Trigger -- 6
local function QTEContext(keyName, buttonName, timeWindow) -- 15
	return {QTE = Trigger.Sequence({ -- 16
		Trigger.Selector({ -- 18
			Trigger.Selector({ -- 19
				Trigger.KeyPressed(keyName), -- 20
				Trigger.Block(Trigger.AnyKeyPressed()) -- 21
			}), -- 21
			Trigger.Selector({ -- 23
				Trigger.ButtonPressed(buttonName), -- 24
				Trigger.Block(Trigger.AnyButtonPressed()) -- 25
			}) -- 25
		}), -- 25
		Trigger.Selector({ -- 28
			Trigger.KeyTimed(keyName, timeWindow), -- 29
			Trigger.ButtonTimed(buttonName, timeWindow) -- 30
		}) -- 30
	})} -- 30
end -- 15
local inputManager = CreateManager({ -- 36
	Default = { -- 37
		Confirm = Trigger.Selector({ -- 38
			Trigger.ButtonHold("y", 1), -- 39
			Trigger.KeyHold("Return", 1) -- 40
		}), -- 40
		MoveDown = Trigger.Selector({ -- 42
			Trigger.ButtonPressed("dpdown"), -- 43
			Trigger.KeyPressed("S") -- 44
		}) -- 44
	}, -- 44
	Test = {Confirm = Trigger.Selector({ -- 47
		Trigger.ButtonHold("x", 0.3), -- 49
		Trigger.KeyHold("LCtrl", 0.3) -- 50
	})}, -- 50
	Phase1 = QTEContext("J", "a", 3), -- 53
	Phase2 = QTEContext("K", "b", 2), -- 54
	Phase3 = QTEContext("L", "x", 1) -- 55
}) -- 55
inputManager:pushContext("Default") -- 58
toNode(React.createElement(GamePad, {inputManager = inputManager})) -- 60
local phase = "None" -- 64
local text = "" -- 65
local holdTime = 0 -- 67
local node = Node() -- 68
node:gslot( -- 69
	"Input.Confirm", -- 69
	function(state, progress) -- 69
		if state == "Completed" then -- 69
			holdTime = 1 -- 71
		elseif state == "Ongoing" then -- 71
			holdTime = progress -- 73
		end -- 73
	end -- 69
) -- 69
node:gslot( -- 77
	"Input.MoveDown", -- 77
	function(state, progress, value) -- 77
		if state == "Completed" then -- 77
			print(state, progress, value) -- 79
		end -- 79
	end -- 77
) -- 77
node:gslot( -- 83
	"Input.QTE", -- 83
	function(state, progress) -- 83
		repeat -- 83
			local ____switch9 = phase -- 83
			local ____cond9 = ____switch9 == "Phase1" -- 83
			if ____cond9 then -- 83
				repeat -- 83
					local ____switch10 = state -- 83
					local ____cond10 = ____switch10 == "Canceled" -- 83
					if ____cond10 then -- 83
						phase = "None" -- 88
						inputManager:popContext() -- 89
						text = "Failed!" -- 90
						holdTime = progress -- 91
						break -- 92
					end -- 92
					____cond10 = ____cond10 or ____switch10 == "Completed" -- 92
					if ____cond10 then -- 92
						phase = "Phase2" -- 94
						inputManager:pushContext("Phase2") -- 95
						text = "Button B or Key K" -- 96
						break -- 97
					end -- 97
					____cond10 = ____cond10 or ____switch10 == "Ongoing" -- 97
					if ____cond10 then -- 97
						holdTime = progress -- 99
						break -- 100
					end -- 100
				until true -- 100
				break -- 102
			end -- 102
			____cond9 = ____cond9 or ____switch9 == "Phase2" -- 102
			if ____cond9 then -- 102
				repeat -- 102
					local ____switch11 = state -- 102
					local ____cond11 = ____switch11 == "Canceled" -- 102
					if ____cond11 then -- 102
						phase = "None" -- 106
						inputManager:popContext(2) -- 107
						text = "Failed!" -- 108
						holdTime = progress -- 109
						break -- 110
					end -- 110
					____cond11 = ____cond11 or ____switch11 == "Completed" -- 110
					if ____cond11 then -- 110
						phase = "Phase3" -- 112
						inputManager:pushContext("Phase3") -- 113
						text = "Button X or Key L" -- 114
						break -- 115
					end -- 115
					____cond11 = ____cond11 or ____switch11 == "Ongoing" -- 115
					if ____cond11 then -- 115
						holdTime = progress -- 117
						break -- 118
					end -- 118
				until true -- 118
				break -- 120
			end -- 120
			____cond9 = ____cond9 or ____switch9 == "Phase3" -- 120
			if ____cond9 then -- 120
				repeat -- 120
					local ____switch12 = state -- 120
					local ____cond12 = ____switch12 == "Canceled" or ____switch12 == "Completed" -- 120
					if ____cond12 then -- 120
						phase = "None" -- 125
						inputManager:popContext(3) -- 126
						text = state == "Completed" and "Success!" or "Failed!" -- 127
						holdTime = progress -- 128
						break -- 129
					end -- 129
					____cond12 = ____cond12 or ____switch12 == "Ongoing" -- 129
					if ____cond12 then -- 129
						holdTime = progress -- 131
						break -- 132
					end -- 132
				until true -- 132
				break -- 134
			end -- 134
		until true -- 134
	end -- 83
) -- 83
local function QTEButton() -- 138
	if ImGui.Button("Start QTE") then -- 138
		phase = "Phase1" -- 140
		text = "Button A or Key J" -- 141
		inputManager:pushContext("Phase1") -- 142
	end -- 142
end -- 138
local countDownFlags = { -- 145
	"NoResize", -- 146
	"NoSavedSettings", -- 147
	"NoTitleBar", -- 148
	"NoMove", -- 149
	"AlwaysAutoResize" -- 150
} -- 150
node:schedule(loop(function() -- 152
	local ____App_visualSize_0 = App.visualSize -- 153
	local width = ____App_visualSize_0.width -- 153
	local height = ____App_visualSize_0.height -- 153
	ImGui.SetNextWindowPos(Vec2(width / 2 - 160, height / 2 - 100)) -- 154
	ImGui.SetNextWindowSize( -- 155
		Vec2(300, 100), -- 155
		"Always" -- 155
	) -- 155
	ImGui.Begin( -- 156
		"CountDown", -- 156
		countDownFlags, -- 156
		function() -- 156
			if phase == "None" then -- 156
				QTEButton() -- 158
			else -- 158
				ImGui.BeginDisabled(QTEButton) -- 160
			end -- 160
			ImGui.SameLine() -- 162
			ImGui.Text(text) -- 163
			ImGui.ProgressBar( -- 164
				holdTime, -- 164
				Vec2(-1, 30) -- 164
			) -- 164
		end -- 156
	) -- 156
	return false -- 166
end)) -- 152
local checked = false -- 169
local windowFlags = { -- 171
	"NoDecoration", -- 172
	"AlwaysAutoResize", -- 173
	"NoSavedSettings", -- 174
	"NoFocusOnAppearing", -- 175
	"NoNav", -- 176
	"NoMove" -- 177
} -- 177
threadLoop(function() -- 179
	local ____App_visualSize_1 = App.visualSize -- 180
	local width = ____App_visualSize_1.width -- 180
	ImGui.SetNextWindowBgAlpha(0.35) -- 181
	ImGui.SetNextWindowPos( -- 182
		Vec2(width - 10, 10), -- 182
		"Always", -- 182
		Vec2(1, 0) -- 182
	) -- 182
	ImGui.SetNextWindowSize( -- 183
		Vec2(240, 0), -- 183
		"FirstUseEver" -- 183
	) -- 183
	ImGui.Begin( -- 184
		"EnhancedInput", -- 184
		windowFlags, -- 184
		function() -- 184
			ImGui.Text("Enhanced Input (TSX)") -- 185
			ImGui.Separator() -- 186
			ImGui.TextWrapped("Change input context to alter input mapping") -- 187
			if phase == "None" then -- 187
				local changed, result = ImGui.Checkbox("hold X to Confirm (instead Y)", checked) -- 189
				if changed then -- 189
					if checked then -- 189
						inputManager:popContext() -- 192
					else -- 192
						inputManager:pushContext("Test") -- 194
					end -- 194
					checked = result -- 196
				end -- 196
			end -- 196
		end -- 184
	) -- 184
	return false -- 200
end) -- 179
return ____exports -- 179