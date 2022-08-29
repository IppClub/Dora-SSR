local Director <const> = require("Director")
local Node <const> = require("Node")
local Label <const> = require("Label")
local Sequence <const> = require("Sequence")
local Delay <const> = require("Delay")
local Scale <const> = require("Scale")
local Color <const> = require("Color")
local Vec2 <const> = require("Vec2")
local Opacity <const> = require("Opacity")

local node = Node()
node:addTo(Director.entry)

local label = Label("sarasa-mono-sc-regular", 40)
label.batched = false
label.text = "你好，Dorothy！"
label:addTo(node)
for i = 1, label.characterCount do
	local char = label:getCharacter(i)
	if not char is nil then
		char:runAction(
			Sequence(
				Delay(i / 5),
				Scale(0.2, 1, 2),
				Scale(0.2, 2, 1)
			)
		)
	end
end

label = Label("sarasa-mono-sc-regular", 30)
label.text = "-- from Jin."
label.color = Color(0x0000ffff)
label.position = Vec2(120, -70)
label:runAction(
	Sequence(
		Delay(2),
		Opacity(0.2, 0, 1)
	)
)
label:addTo(node)

-- example codes ends here, some test ui below --

local App <const> = require("App")
local ImGui <const> = require("ImGui")

local windowFlags = {
	"NoDecoration",
	"AlwaysAutoResize",
	"NoSavedSettings",
	"NoFocusOnAppearing",
	"NoNav",
	"NoMove"
}
local ui = Node()
ui:schedule(function(): boolean
	local width = App.visualSize.width
	ImGui.SetNextWindowBgAlpha(0.35)
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), "Always", Vec2(1, 0))
	ImGui.SetNextWindowSize(Vec2(240, 0), "FirstUseEver")
	ImGui.Begin("Label", windowFlags, function()
		ImGui.Text("Label")
		ImGui.Separator()
		ImGui.TextWrapped("Render labels with unbatched and batched methods!")
	end)
end)
ui:addTo(Director.entry)
