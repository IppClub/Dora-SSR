local Director = require("Director")
local Node = require("Node")
local once = require("once")
local sleep = require("sleep")
local node = Node()
node:slot("Enter", function()
	print("on enter event")
end)
node:slot("Exit", function()
	print("on exit event")
end)
node:slot("Cleanup", function()
	print("on node destoyed event")
end)
node:schedule(once(function(): boolean
	for i = 5, 1, -1 do
		print(i)
		sleep(1)
	end
	print("Hello World!")
end))
Director.entry:addChild(node)

-- example codes ends here, some test ui below --
local ImGui = require("ImGui")
local Vec2 = require("Vec2")
local App = require("App")
local ui = Node()
ui:schedule(function(): boolean
	local size = App.visualSize
	ImGui.SetNextWindowPos(Vec2(size.width - 250, 10), "FirstUseEver")
	ImGui.SetNextWindowSize(Vec2(240, 120), "FirstUseEver")
	ImGui.Begin("Hello World", {"NoResize","NoSavedSettings"}, function()
		ImGui.TextWrapped("Basic Dorothy schedule and signal function usage. View outputs in log window!")
	end)
end)
Director.entry:addChild(ui)
