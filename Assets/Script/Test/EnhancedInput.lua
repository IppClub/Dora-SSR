-- [yue]: Script/Test/EnhancedInput.yue
local Node = Dora.Node -- 1
local print = _G.print -- 1
local ImGui = Dora.ImGui -- 1
local loop = Dora.loop -- 1
local App = Dora.App -- 1
local Vec2 = Dora.Vec2 -- 1
local threadLoop = Dora.threadLoop -- 1
local InputManager = require("InputManager") -- 4
local Trigger = InputManager.Trigger -- 5
local QTEContext -- 21
QTEContext = function(contextName, keyName, buttonName, timeWindow) -- 21
	return { -- 22
		name = contextName, -- 22
		actions = { -- 24
			{ -- 24
				name = "QTE", -- 24
				trigger = Trigger.Sequence({ -- 26
					Trigger.Selector({ -- 27
						Trigger.Selector({ -- 28
							Trigger.KeyPressed(keyName), -- 28
							Trigger.Block(Trigger.AnyKeyPressed()) -- 29
						}), -- 27
						Trigger.Selector({ -- 32
							Trigger.ButtonPressed(buttonName), -- 32
							Trigger.Block(Trigger.AnyButtonPressed()) -- 33
						}) -- 31
					}), -- 26
					Trigger.Selector({ -- 37
						Trigger.KeyTimed(keyName, timeWindow), -- 37
						Trigger.ButtonTimed(buttonName, timeWindow) -- 38
					}) -- 36
				}) -- 25
			} -- 24
		} -- 23
	} -- 40
end -- 21
local inputManager = InputManager.CreateManager({ -- 43
	{ -- 43
		name = "Default", -- 43
		actions = { -- 45
			{ -- 45
				name = "Confirm", -- 45
				trigger = Trigger.Selector({ -- 47
					Trigger.ButtonHold("y", 1), -- 47
					Trigger.KeyHold("Return", 1) -- 48
				}) -- 46
			}, -- 45
			{ -- 50
				name = "MoveDown", -- 50
				trigger = Trigger.Selector({ -- 52
					Trigger.ButtonPressed("dpdown"), -- 52
					Trigger.KeyPressed("S") -- 53
				}) -- 51
			} -- 50
		} -- 44
	}, -- 43
	{ -- 55
		name = "Test", -- 55
		actions = { -- 57
			{ -- 57
				name = "Confirm", -- 57
				trigger = Trigger.Selector({ -- 59
					Trigger.ButtonHold("x", 0.3), -- 59
					Trigger.KeyHold("LCtrl", 0.3) -- 60
				}) -- 58
			} -- 57
		} -- 56
	}, -- 55
	QTEContext(("Phase1"), "J", "a", 3), -- 62
	QTEContext(("Phase2"), "K", "b", 2), -- 63
	QTEContext(("Phase3"), "L", "x", 1) -- 64
}) -- 42
inputManager:pushContext("Default") -- 66
InputManager.CreateGamePad({ -- 68
	inputManager = inputManager -- 68
}) -- 68
local phase = "None" -- 70
local text = "" -- 71
local holdTime = 0.0 -- 73
local node = Node() -- 74
node:gslot("Input.Confirm", function(state, progress) -- 75
	if "Completed" == state then -- 77
		holdTime = 1 -- 78
	elseif "Ongoing" == state then -- 79
		holdTime = progress -- 80
	end -- 80
end) -- 75
node:gslot("Input.MoveDown", function(state, progress, value) -- 82
	if state == "Completed" then -- 83
		return print(state, progress, value) -- 84
	end -- 83
end) -- 82
node:gslot("Input.QTE", function(state, progress) -- 86
	if "Phase1" == phase then -- 87
		if "Canceled" == state then -- 89
			phase = "None" -- 90
			inputManager:popContext() -- 91
			text = "Failed!" -- 92
			holdTime = progress -- 93
		elseif "Completed" == state then -- 94
			phase = "Phase2" -- 95
			inputManager:pushContext(phase) -- 96
			text = "Button B or Key K" -- 97
		elseif "Ongoing" == state then -- 98
			holdTime = progress -- 99
		end -- 99
	elseif "Phase2" == phase then -- 101
		if "Canceled" == state then -- 103
			phase = "None" -- 104
			inputManager:popContext(2) -- 105
			text = "Failed!" -- 106
			holdTime = progress -- 107
		elseif "Completed" == state then -- 108
			phase = "Phase3" -- 109
			inputManager:pushContext(phase) -- 110
			text = "Button X or Key L" -- 111
		elseif "Ongoing" == state then -- 112
			holdTime = progress -- 113
		end -- 113
	elseif "Phase3" == phase then -- 115
		if ("Canceled") == state or "Completed" == state then -- 117
			phase = "None" -- 118
			inputManager:popContext(3) -- 119
			text = state == "Completed" and "Success!" or "Failed!" -- 120
			holdTime = progress -- 121
		elseif "Ongoing" == state then -- 122
			holdTime = progress -- 123
		end -- 123
	end -- 123
end) -- 86
local QTEButton -- 125
QTEButton = function() -- 125
	if ImGui.Button("Start QTE") then -- 126
		phase = "Phase1" -- 127
		text = "Button A or Key J" -- 128
		return inputManager:pushContext(phase) -- 129
	end -- 126
end -- 125
local countDownFlags = { -- 131
	"NoResize", -- 131
	"NoSavedSettings", -- 131
	"NoTitleBar", -- 131
	"NoMove", -- 131
	"AlwaysAutoResize" -- 131
} -- 131
node:schedule(loop(function() -- 138
	local width, height -- 139
	do -- 139
		local _obj_0 = App.visualSize -- 139
		width, height = _obj_0.width, _obj_0.height -- 139
	end -- 139
	ImGui.SetNextWindowPos(Vec2(width / 2 - 160, height / 2 - 100)) -- 140
	ImGui.SetNextWindowSize(Vec2(300, 100), "Always") -- 141
	ImGui.Begin("CountDown", countDownFlags, function() -- 142
		if phase == "None" then -- 143
			QTEButton() -- 144
		else -- 146
			ImGui.BeginDisabled(QTEButton) -- 146
		end -- 143
		ImGui.SameLine() -- 147
		ImGui.Text(text) -- 148
		return ImGui.ProgressBar(holdTime, Vec2(-1, 30)) -- 149
	end) -- 142
	return false -- 149
end)) -- 138
local checked = false -- 151
local windowFlags = { -- 153
	"NoDecoration", -- 153
	"AlwaysAutoResize", -- 153
	"NoSavedSettings", -- 153
	"NoFocusOnAppearing", -- 153
	"NoNav", -- 153
	"NoMove" -- 153
} -- 153
return threadLoop(function() -- 161
	local width = App.visualSize.width -- 162
	ImGui.SetNextWindowBgAlpha(0.35) -- 163
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), ("Always"), Vec2(1, 0)) -- 164
	ImGui.SetNextWindowSize(Vec2(240, 0), "FirstUseEver") -- 165
	ImGui.Begin("EnhancedInput", windowFlags, function() -- 166
		ImGui.Text("Enhanced Input (YueScript)") -- 167
		ImGui.Separator() -- 168
		ImGui.TextWrapped("Change input context to alter input mapping") -- 169
		if phase == "None" then -- 170
			local changed, result = ImGui.Checkbox("hold X to confirm (instead Y)", checked) -- 171
			if changed then -- 171
				checked = result -- 172
				return inputManager:popContext() -- 173
			else -- 175
				return inputManager:pushContext("Test") -- 175
			end -- 171
		end -- 170
	end) -- 166
	return false -- 175
end) -- 175
