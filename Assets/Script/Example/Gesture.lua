-- [yue]: Script/Example/Gesture.yue
local nvg = Dora.nvg -- 1
local Sprite = Dora.Sprite -- 1
local Vec2 = Dora.Vec2 -- 1
local View = Dora.View -- 1
local Node = Dora.Node -- 1
local threadLoop = Dora.threadLoop -- 1
local App = Dora.App -- 1
local ImGui = Dora.ImGui -- 1
local texture = nvg.GetDoraSSR() -- 3
local sprite = Sprite(texture) -- 4
local length = Vec2(View.size).length -- 5
local width, height = sprite.width, sprite.height -- 6
local size = Vec2(width, height).length -- 7
local scaledSize = size -- 8
do -- 10
	local _with_0 = Node() -- 10
	_with_0:addChild(sprite) -- 11
	_with_0:onGesture(function(center, _numTouches, delta, angle) -- 12
		sprite.position = center -- 16
		sprite.angle = sprite.angle + angle -- 17
		scaledSize = scaledSize + (delta * length) -- 18
		sprite.scaleX = scaledSize / size -- 19
		sprite.scaleY = scaledSize / size -- 20
	end) -- 12
end -- 10
local windowFlags = { -- 25
	"NoDecoration", -- 25
	"AlwaysAutoResize", -- 25
	"NoSavedSettings", -- 25
	"NoFocusOnAppearing", -- 25
	"NoNav", -- 25
	"NoMove" -- 25
} -- 25
return threadLoop(function() -- 33
	local width -- 34
	width = App.visualSize.width -- 34
	ImGui.SetNextWindowBgAlpha(0.35) -- 35
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), "Always", Vec2(1, 0)) -- 36
	ImGui.SetNextWindowSize(Vec2(240, 0), "FirstUseEver") -- 37
	return ImGui.Begin("Gesture", windowFlags, function() -- 38
		ImGui.Text("Gesture (Yuescript)") -- 39
		ImGui.Separator() -- 40
		return ImGui.TextWrapped("Interact with multi-touches!") -- 41
	end) -- 41
end) -- 41
