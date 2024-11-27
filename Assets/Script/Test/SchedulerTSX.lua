-- [tsx]: SchedulerTSX.tsx
local ____exports = {} -- 1
local ____DoraX = require("DoraX") -- 2
local React = ____DoraX.React -- 2
local toNode = ____DoraX.toNode -- 2
local ____Dora = require("Dora") -- 3
local App = ____Dora.App -- 3
local Node = ____Dora.Node -- 3
local Scheduler = ____Dora.Scheduler -- 3
local Vec2 = ____Dora.Vec2 -- 3
local threadLoop = ____Dora.threadLoop -- 3
local ImGui = require("ImGui") -- 5
local function Item(props) -- 7
	return React.createElement( -- 8
		"sprite", -- 8
		{ -- 8
			file = "Image/logo.png", -- 8
			x = props.x, -- 8
			y = props.y, -- 8
			width = 100, -- 8
			height = 100, -- 8
			scheduler = props.scheduler -- 8
		}, -- 8
		React.createElement( -- 8
			"loop", -- 8
			nil, -- 8
			React.createElement("angle", {time = 3, start = 0, stop = 360}) -- 8
		) -- 8
	) -- 8
end -- 7
local function Scene(props) -- 17
	return React.createElement( -- 18
		"node", -- 18
		{scaleX = props.flip and -1 or 1}, -- 18
		React.createElement(Item, {x = -100, y = 100, scheduler = props.scheduler}), -- 18
		React.createElement(Item, {x = -100, y = 0, scheduler = props.scheduler}), -- 18
		React.createElement(Item, {x = -100, y = -100, scheduler = props.scheduler}), -- 18
		React.createElement( -- 18
			"physics-world", -- 18
			{showDebug = true, x = -280, y = -100, scheduler = props.scheduler}, -- 18
			React.createElement( -- 18
				"body", -- 18
				{type = "Static"}, -- 18
				React.createElement("rect-fixture", {width = 200, height = 10}) -- 18
			), -- 18
			React.createElement( -- 18
				"body", -- 18
				{type = "Dynamic", y = 100}, -- 18
				React.createElement("disk-fixture", {radius = 50, restitution = 1}) -- 18
			) -- 18
		) -- 18
	) -- 18
end -- 17
local scheduler = Scheduler() -- 35
scheduler.timeScale = 0.1 -- 36
local node = Node() -- 38
node:schedule(function(deltaTime) return scheduler:update(deltaTime) end) -- 39
toNode(React.createElement( -- 41
	React.Fragment, -- 41
	nil, -- 41
	React.createElement(Scene, nil), -- 41
	React.createElement(Scene, {flip = true, scheduler = scheduler}) -- 41
)) -- 41
local timeScale = scheduler.timeScale -- 41
local windowFlags = { -- 50
	"NoDecoration", -- 51
	"NoSavedSettings", -- 52
	"NoFocusOnAppearing", -- 53
	"NoNav", -- 54
	"NoMove" -- 55
} -- 55
threadLoop(function() -- 57
	local ____App_visualSize_0 = App.visualSize -- 58
	local width = ____App_visualSize_0.width -- 58
	ImGui.SetNextWindowPos( -- 59
		Vec2(width - 10, 10), -- 59
		"Always", -- 59
		Vec2(1, 0) -- 59
	) -- 59
	ImGui.SetNextWindowSize( -- 60
		Vec2(200, 0), -- 60
		"Always" -- 60
	) -- 60
	ImGui.Begin( -- 61
		"Scheduler", -- 61
		windowFlags, -- 61
		function() -- 61
			ImGui.Text("Scheduler (TSX)") -- 62
			ImGui.Separator() -- 63
			ImGui.TextWrapped("Using a custom scheduler to control update speed.") -- 64
			local changed = false -- 65
			changed, timeScale = ImGui.DragFloat( -- 66
				"Speed", -- 66
				timeScale, -- 66
				0.01, -- 66
				0.1, -- 66
				3, -- 66
				"%.2f" -- 66
			) -- 66
			if changed then -- 66
				scheduler.timeScale = timeScale -- 68
			end -- 68
		end -- 61
	) -- 61
	return false -- 71
end) -- 57
return ____exports -- 57