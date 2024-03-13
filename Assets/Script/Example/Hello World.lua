-- [yue]: Script/Example/Hello World.yue
local Node = dora.Node -- 1
local print = _G.print -- 1
local once = dora.once -- 1
local sleep = dora.sleep -- 1
local threadLoop = dora.threadLoop -- 1
local App = dora.App -- 1
local ImGui = dora.ImGui -- 1
local Vec2 = dora.Vec2 -- 1
do -- 3
	local _with_0 = Node() -- 3
	_with_0:slot("Enter", function() -- 4
		return print("on enter event") -- 4
	end) -- 4
	_with_0:slot("Exit", function() -- 5
		return print("on exit event") -- 5
	end) -- 5
	_with_0:slot("Cleanup", function() -- 6
		return print("on node destoyed event") -- 6
	end) -- 6
	_with_0:schedule(once(function() -- 7
		for i = 5, 1, -1 do -- 8
			print(i) -- 9
			sleep(1) -- 10
		end -- 10
		return print("Hello World!") -- 11
	end)) -- 7
end -- 3
local windowFlags = { -- 16
	"NoDecoration", -- 16
	"AlwaysAutoResize", -- 17
	"NoSavedSettings", -- 18
	"NoFocusOnAppearing", -- 19
	"NoNav", -- 20
	"NoMove" -- 21
} -- 15
return threadLoop(function() -- 22
	local width -- 23
	width = App.visualSize.width -- 23
	ImGui.SetNextWindowBgAlpha(0.35) -- 24
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), "Always", Vec2(1, 0)) -- 25
	ImGui.SetNextWindowSize(Vec2(240, 0), "FirstUseEver") -- 26
	return ImGui.Begin("Hello World", windowFlags, function() -- 27
		ImGui.Text("Hello World") -- 28
		ImGui.Separator() -- 29
		return ImGui.TextWrapped("Basic Dora schedule and signal function usage. Written in Yuescript. View outputs in log window!") -- 30
	end) -- 30
end) -- 30
