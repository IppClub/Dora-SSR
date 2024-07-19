
local threadLoop <const> = require("threadLoop")
local Vec2 <const> = require("Vec2")
local ImGui <const> = require("ImGui")
local App <const> = require("App")
local loop <const> = require("loop")
local InputManager <const> = require("InputManager")
local Node <const> = require("Node")
local Keyboard = require("Keyboard")
local KeyName = Keyboard.KeyName
local Controller = require("Controller")
local ButtonName = Controller.ButtonName
local Trigger <const> = InputManager.Trigger









local function QTEContext(contextName, keyName, buttonName, timeWindow)
	return {
		name = contextName,
		actions = { {
			name = "QTE",
			trigger = Trigger.Sequence({
				Trigger.Selector({
					Trigger.Selector({
						Trigger.KeyPressed(keyName),
						Trigger.Block(Trigger.AnyKeyPressed()),
					}),
					Trigger.Selector({
						Trigger.ButtonPressed(buttonName),
						Trigger.Block(Trigger.AnyButtonPressed()),
					}),
				}),
				Trigger.Selector({
					Trigger.KeyTimed(keyName, timeWindow),
					Trigger.ButtonTimed(buttonName, timeWindow),
				}),
			}),
		}, },
	}
end

local inputManager = InputManager.CreateManager({
	{ name = "Default", actions = {
		{ name = "Confirm", trigger = 
Trigger.Selector({
			Trigger.ButtonHold("y", 1),
			Trigger.KeyHold("Return", 1),
		}),
		},
		{ name = "MoveDown", trigger = 
Trigger.Selector({
			Trigger.ButtonPressed("dpdown"),
			Trigger.KeyPressed("S"),
		}),
		},
	}, },
	{ name = "Test", actions = {
		{ name = "Confirm", trigger = 
Trigger.Selector({
			Trigger.ButtonHold("x", 0.3),
			Trigger.KeyHold("LCtrl", 0.3),
		}),
		},
	}, },
	QTEContext("Phase1", "J", "a", 3),
	QTEContext("Phase2", "K", "b", 2),
	QTEContext("Phase3", "L", "x", 1),
})

inputManager:pushContext("Default")

InputManager.CreateGamePad({ inputManager = inputManager })

local phase = "None"
local text = ""

local holdTime = 0.0
local node = Node()
node:gslot("Input.Confirm", function(state, progress)
	if state == "Completed" then
		holdTime = 1
	elseif state == "Ongoing" then
		holdTime = progress
	end
end)

node:gslot("Input.MoveDown", function(state, progress, value)
	if state == "Completed" then
		print(state, progress, value)
	end
end)

node:gslot("Input.QTE", function(state, progress)
	if phase == "Phase1" then
		if state == "Canceled" then
			phase = "None"
			inputManager:popContext()
			text = "Failed!"
			holdTime = progress
		elseif state == "Completed" then
			phase = "Phase2"
			inputManager:pushContext("Phase2")
			text = "Button B or Key K"
		elseif state == "Ongoing" then
			holdTime = progress
		end
	elseif phase == "Phase2" then
		if state == "Canceled" then
			phase = "None"
			inputManager:popContext(2);
			text = "Failed!"
			holdTime = progress
		elseif state == "Completed" then
			phase = "Phase3"
			inputManager:pushContext("Phase3")
			text = "Button X or Key L"
		elseif state == "Ongoing" then
			holdTime = progress
		end
	elseif phase == "Phase3" then
		if state == "Canceled" or state == "Completed" then
			phase = "None"
			inputManager:popContext(3)
			text = state == "Completed" and "Success!" or "Failed!"
			holdTime = progress
		elseif state == "Ongoing" then
			holdTime = progress
		end
	end
end)

local function QTEButton()
	if ImGui.Button("Start QTE") then
		phase = "Phase1"
		text = "Button A or Key J"
		inputManager:pushContext("Phase1")
	end
end

local countDownFlags = {
	"NoResize",
	"NoSavedSettings",
	"NoTitleBar",
	"NoMove",
}
node:schedule(loop(function()
	local visualSize = App.visualSize
	local width = visualSize.width
	local height = visualSize.height
	ImGui.SetNextWindowPos(Vec2(width / 2 - 160, height / 2 - 100))
	ImGui.SetNextWindowSize(Vec2(300, 50), "FirstUseEver")
	ImGui.Begin("CountDown", countDownFlags, function()
		if phase == "None" then
			QTEButton()
		else
			ImGui.BeginDisabled(QTEButton)
		end
		ImGui.SameLine()
		ImGui.Text(text)
		ImGui.ProgressBar(holdTime, Vec2(-1, 30));
	end)
	return false
end))

local checked = false

local windowFlags = {
	"NoDecoration",
	"AlwaysAutoResize",
	"NoSavedSettings",
	"NoFocusOnAppearing",
	"NoNav",
	"NoMove",
}
threadLoop(function()
	local width = App.visualSize.width
	ImGui.SetNextWindowBgAlpha(0.35)
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), "Always", Vec2(1, 0))
	ImGui.SetNextWindowSize(Vec2(240, 0), "FirstUseEver")
	ImGui.Begin("EnhancedInput", windowFlags, function()
		ImGui.Text("Enhanced Input (Teal)")
		ImGui.Separator()
		ImGui.TextWrapped("Change input context to alter input mapping")
		if phase == "None" then
			local changed, result = false, false
			changed, result = ImGui.Checkbox("hold X to Confirm (instead Y)", checked)
			if changed then
				if checked then
					inputManager:popContext()
				else
					inputManager:pushContext("Test")
				end
				checked = result
			end
		end
	end)
	return false
end)