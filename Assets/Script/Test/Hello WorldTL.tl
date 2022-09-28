local Director <const> = require("Director")
local Node <const> = require("Node")
local once <const> = require("once")
local sleep <const> = require("sleep")

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
node:addTo(Director.entry)

-- example codes ends here, some test ui below --

local ImGui = require("ImGui")
local Vec2 = require("Vec2")
local App = require("App")

local ui = Node()
local windowFlags = {
	"NoDecoration",
	"AlwaysAutoResize",
	"NoSavedSettings",
	"NoFocusOnAppearing",
	"NoNav",
	"NoMove"
}
ui:schedule(function(): boolean
	local size = App.visualSize
	ImGui.SetNextWindowBgAlpha(0.35)
	ImGui.SetNextWindowPos(Vec2(size.width - 10, 10), "Always", Vec2(1, 0))
	ImGui.SetNextWindowSize(Vec2(240, 0), "FirstUseEver")
	ImGui.Begin("Hello World", windowFlags, function()
		ImGui.Text("Hello World")
		ImGui.Separator()
		ImGui.TextWrapped("Basic Dorothy schedule and signal function usage. Written in Teal. View outputs in log window!")
	end)
end)
Director.entry:addChild(ui)
