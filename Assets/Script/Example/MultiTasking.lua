-- [yue]: Script/Example/MultiTasking.yue
local thread = dora.thread -- 1
local print = _G.print -- 1
local Content = dora.Content -- 1
local sleep = dora.sleep -- 1
local string = _G.string -- 1
local tostring = _G.tostring -- 1
local App = dora.App -- 1
local threadLoop = dora.threadLoop -- 1
local math = _G.math -- 1
local Node = dora.Node -- 1
local once = dora.once -- 1
local loop = dora.loop -- 1
local ImGui = dora.ImGui -- 1
local Vec2 = dora.Vec2 -- 1
thread(function() -- 3
	print("thread 1") -- 4
	local yueCodes = Content:loadAsync("Script/Example/MultiTasking.yue") -- 5
	sleep(2) -- 6
	local yue = require("yue") -- 7
	local luaCodes = yue.to_lua(yueCodes) -- 8
	print(luaCodes) -- 9
	print("thread 1 done") -- 10
	return thread(function() -- 12
		print("thread 2 stared") -- 13
		repeat -- 14
			print("thread 2 Time passed: " .. tostring(string.format("%.2fs", App.totalTime))) -- 15
			sleep(1) -- 16
		until false -- 17
	end) -- 17
end) -- 3
threadLoop(function() -- 19
	print("thread 3") -- 20
	sleep(math.random(3)) -- 21
	print("do nothing") -- 22
	return sleep(0.2) -- 23
end) -- 19
do -- 25
	local _with_0 = Node() -- 25
	_with_0:schedule(once(function() -- 26
		sleep(5) -- 27
		print("5 seconds later") -- 28
		return _with_0:schedule(loop(function() -- 29
			sleep(3) -- 30
			return print("another 3 seconds") -- 31
		end)) -- 31
	end)) -- 26
end -- 25
local windowFlags = { -- 36
	"NoDecoration", -- 36
	"AlwaysAutoResize", -- 37
	"NoSavedSettings", -- 38
	"NoFocusOnAppearing", -- 39
	"NoNav", -- 40
	"NoMove" -- 41
} -- 35
return threadLoop(function() -- 42
	local width -- 43
	width = App.visualSize.width -- 43
	ImGui.SetNextWindowBgAlpha(0.35) -- 44
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), "Always", Vec2(1, 0)) -- 45
	ImGui.SetNextWindowSize(Vec2(240, 0), "FirstUseEver") -- 46
	return ImGui.Begin("Multi-tasking", windowFlags, function() -- 47
		ImGui.Text("Multi-tasking") -- 48
		ImGui.Separator() -- 49
		return ImGui.TextWrapped("Basic Dora multi-tasking usage. Powered by View outputs in log window!") -- 50
	end) -- 50
end) -- 50
