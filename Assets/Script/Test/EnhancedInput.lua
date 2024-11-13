-- [yue]: Script/Test/EnhancedInput.yue
local Node = Dora.Node -- 1
local print = _G.print -- 1
local ImGui = Dora.ImGui -- 1
local loop = Dora.loop -- 1
local App = Dora.App -- 1
local Vec2 = Dora.Vec2 -- 1
local threadLoop = Dora.threadLoop -- 1
local InputManager = require("InputManager") -- 5
local Trigger = InputManager.Trigger -- 6
local QTEContext -- 22
QTEContext = function(keyName, buttonName, timeWindow) -- 22
	return { -- 23
		QTE = Trigger.Sequence({ -- 25
			Trigger.Selector({ -- 26
				Trigger.Selector({ -- 27
					Trigger.KeyPressed(keyName), -- 27
					Trigger.Block(Trigger.AnyKeyPressed()) -- 28
				}), -- 26
				Trigger.Selector({ -- 31
					Trigger.ButtonPressed(buttonName), -- 31
					Trigger.Block(Trigger.AnyButtonPressed()) -- 32
				}) -- 30
			}), -- 25
			Trigger.Selector({ -- 36
				Trigger.KeyTimed(keyName, timeWindow), -- 36
				Trigger.ButtonTimed(buttonName, timeWindow) -- 37
			}) -- 35
		}) -- 23
	} -- 39
end -- 22
local inputManager = InputManager.CreateManager({ -- 42
	Default = { -- 43
		Confirm = Trigger.Selector({ -- 44
			Trigger.ButtonHold("y", 1), -- 44
			Trigger.KeyHold("Return", 1) -- 45
		}), -- 43
		MoveDown = Trigger.Selector({ -- 48
			Trigger.ButtonPressed("dpdown"), -- 48
			Trigger.KeyPressed("S") -- 49
		}) -- 47
	}, -- 42
	Test = { -- 52
		Confirm = Trigger.Selector({ -- 53
			Trigger.ButtonHold("x", 0.3), -- 53
			Trigger.KeyHold("LCtrl", 0.3) -- 54
		}) -- 52
	}, -- 51
	["Phase1"] = QTEContext("J", "a", 3), -- 56
	["Phase2"] = QTEContext("K", "b", 2), -- 57
	["Phase3"] = QTEContext("L", "x", 1) -- 58
}) -- 41
inputManager:pushContext("Default") -- 60
InputManager.CreateGamePad({ -- 62
	inputManager = inputManager -- 62
}) -- 62
local phase = "None" -- 64
local text = "" -- 65
local holdTime = 0.0 -- 67
local node = Node() -- 68
node:gslot("Input.Confirm", function(state, progress) -- 69
	if "Completed" == state then -- 71
		holdTime = 1 -- 72
	elseif "Ongoing" == state then -- 73
		holdTime = progress -- 74
	end -- 74
end) -- 69
node:gslot("Input.MoveDown", function(state, progress, value) -- 76
	if state == "Completed" then -- 77
		return print(state, progress, value) -- 78
	end -- 77
end) -- 76
node:gslot("Input.QTE", function(state, progress) -- 80
	if "Phase1" == phase then -- 81
		if "Canceled" == state then -- 83
			phase = "None" -- 84
			inputManager:popContext() -- 85
			text = "Failed!" -- 86
			holdTime = progress -- 87
		elseif "Completed" == state then -- 88
			phase = "Phase2" -- 89
			inputManager:pushContext(phase) -- 90
			text = "Button B or Key K" -- 91
		elseif "Ongoing" == state then -- 92
			holdTime = progress -- 93
		end -- 93
	elseif "Phase2" == phase then -- 95
		if "Canceled" == state then -- 97
			phase = "None" -- 98
			inputManager:popContext(2) -- 99
			text = "Failed!" -- 100
			holdTime = progress -- 101
		elseif "Completed" == state then -- 102
			phase = "Phase3" -- 103
			inputManager:pushContext(phase) -- 104
			text = "Button X or Key L" -- 105
		elseif "Ongoing" == state then -- 106
			holdTime = progress -- 107
		end -- 107
	elseif "Phase3" == phase then -- 109
		if ("Canceled") == state or "Completed" == state then -- 111
			phase = "None" -- 112
			inputManager:popContext(3) -- 113
			text = state == "Completed" and "Success!" or "Failed!" -- 114
			holdTime = progress -- 115
		elseif "Ongoing" == state then -- 116
			holdTime = progress -- 117
		end -- 117
	end -- 117
end) -- 80
local QTEButton -- 119
QTEButton = function() -- 119
	if ImGui.Button("Start QTE") then -- 120
		phase = "Phase1" -- 121
		text = "Button A or Key J" -- 122
		return inputManager:pushContext(phase) -- 123
	end -- 120
end -- 119
local countDownFlags = { -- 125
	"NoResize", -- 125
	"NoSavedSettings", -- 125
	"NoTitleBar", -- 125
	"NoMove", -- 125
	"AlwaysAutoResize" -- 125
} -- 125
node:schedule(loop(function() -- 132
	local width, height -- 133
	do -- 133
		local _obj_0 = App.visualSize -- 133
		width, height = _obj_0.width, _obj_0.height -- 133
	end -- 133
	ImGui.SetNextWindowPos(Vec2(width / 2 - 160, height / 2 - 100)) -- 134
	ImGui.SetNextWindowSize(Vec2(300, 100), "Always") -- 135
	ImGui.Begin("CountDown", countDownFlags, function() -- 136
		if phase == "None" then -- 137
			QTEButton() -- 138
		else -- 140
			ImGui.BeginDisabled(QTEButton) -- 140
		end -- 137
		ImGui.SameLine() -- 141
		ImGui.Text(text) -- 142
		return ImGui.ProgressBar(holdTime, Vec2(-1, 30)) -- 143
	end) -- 136
	return false -- 143
end)) -- 132
local checked = false -- 145
local windowFlags = { -- 147
	"NoDecoration", -- 147
	"AlwaysAutoResize", -- 147
	"NoSavedSettings", -- 147
	"NoFocusOnAppearing", -- 147
	"NoNav", -- 147
	"NoMove" -- 147
} -- 147
return threadLoop(function() -- 155
	local width = App.visualSize.width -- 156
	ImGui.SetNextWindowBgAlpha(0.35) -- 157
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), ("Always"), Vec2(1, 0)) -- 158
	ImGui.SetNextWindowSize(Vec2(240, 0), "FirstUseEver") -- 159
	ImGui.Begin("EnhancedInput", windowFlags, function() -- 160
		ImGui.Text("Enhanced Input (YueScript)") -- 161
		ImGui.Separator() -- 162
		ImGui.TextWrapped("Change input context to alter input mapping") -- 163
		if phase == "None" then -- 164
			local changed -- 165
			changed, checked = ImGui.Checkbox("hold X to confirm (instead Y)", checked) -- 165
			if changed then -- 165
				if checked then -- 166
					return inputManager:pushContext("Test") -- 167
				else -- 169
					return inputManager:popContext() -- 169
				end -- 166
			end -- 165
		end -- 164
	end) -- 160
	return false -- 169
end) -- 169
