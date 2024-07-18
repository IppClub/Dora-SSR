-- @preview-file on
local threadLoop <const> = require("threadLoop")
local Vec2 <const> = require("Vec2")
local ImGui <const> = require("ImGui")
local App <const> = require("App")
local loop <const> = require("loop")
local InputManager <const> = require("InputManager")
local Node <const> = require("Node")
local Trigger <const> = InputManager.Trigger
local type TriggerState = InputManager.TriggerState

local inputManager = InputManager.CreateInputManager({
	{name = "Default", actions = {
		{name = "Confirm", trigger =
			Trigger.Selector({
				Trigger.ButtonHold("a", 1),
				Trigger.KeyHold("Return", 1),
			})
		},
		{name = "MoveDown", trigger =
			Trigger.Selector({
				Trigger.ButtonPressed("dpdown"),
				Trigger.KeyPressed("S")
			})
		},
	}},
	{name = "Test", actions = {
		{name = "Confirm", trigger =
			Trigger.Selector({
				Trigger.ButtonHold("x", 0.3),
				Trigger.KeyHold("LCtrl", 0.3),
			})
		},
	}},
})

inputManager:pushContext("Default")

InputManager.CreateGamePad({inputManager = inputManager})

local holdTime = 0.0
local node = Node()
node:gslot("Input.Confirm", function(state: TriggerState, progress: number)
	if state == "Completed" then
		holdTime = 1
	elseif state == "Ongoing" then
		holdTime = progress
	end
end)

node:gslot("Input.MoveDown", function(state: TriggerState, progress: number, value: any)
	if state == "Completed" then
		print(state, progress, value)
	end
end)

local countDownFlags = {
	"NoResize",
	"NoSavedSettings",
	"NoTitleBar",
	"NoMove"
}
node:schedule(loop(function(): boolean
	local visualSize = App.visualSize
	local width = visualSize.width
	local height = visualSize.height
	ImGui.SetNextWindowPos(Vec2(width / 2 - 160, height / 2 - 50))
	ImGui.SetNextWindowSize(Vec2(300, 50), "FirstUseEver")
	ImGui.Begin("CountDown", countDownFlags, function()
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
	"NoMove"
}
threadLoop(function(): boolean
	local width = App.visualSize.width
	ImGui.SetNextWindowBgAlpha(0.35)
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), "Always", Vec2(1, 0))
	ImGui.SetNextWindowSize(Vec2(240, 0), "FirstUseEver")
	ImGui.Begin("EnhancedInput", windowFlags, function()
		ImGui.Text("Enhanced Input (Teal)")
		ImGui.Separator()
		ImGui.TextWrapped("Change input context to alter input mapping")
		local changed, result = false, false
		changed, result = ImGui.Checkbox("X to Confirm (not A)", checked)
		if changed then
			if checked then
				inputManager:popContext()
			else
				inputManager:pushContext("Test")
			end
			checked = result
		end
	end)
	return false
end)
