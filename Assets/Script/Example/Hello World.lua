-- [yue]: Script/Example/Hello World.yue
local Node = Dora.Node -- 1
local print = _G.print -- 1
local once = Dora.once -- 1
local sleep = Dora.sleep -- 1
local threadLoop = Dora.threadLoop -- 1
local App = Dora.App -- 1
local ImGui = Dora.ImGui -- 1
local Vec2 = Dora.Vec2 -- 1
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
	"AlwaysAutoResize", -- 16
	"NoSavedSettings", -- 16
	"NoFocusOnAppearing", -- 16
	"NoNav", -- 16
	"NoMove" -- 16
} -- 16
return threadLoop(function() -- 24
	local width -- 25
	width = App.visualSize.width -- 25
	ImGui.SetNextWindowBgAlpha(0.35) -- 26
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), "Always", Vec2(1, 0)) -- 27
	ImGui.SetNextWindowSize(Vec2(240, 0), "FirstUseEver") -- 28
	return ImGui.Begin("Hello World", windowFlags, function() -- 29
		ImGui.Text("Hello World (Yuescript)") -- 30
		ImGui.Separator() -- 31
		return ImGui.TextWrapped("Basic Dora schedule and signal function usage. Written in Yuescript. View outputs in log window!") -- 32
	end) -- 32
end) -- 32
