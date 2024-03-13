-- [yue]: Script/Example/Gesture.yue
local nvg = dora.nvg -- 1
local Sprite = dora.Sprite -- 1
local Vec2 = dora.Vec2 -- 1
local View = dora.View -- 1
local Node = dora.Node -- 1
local threadLoop = dora.threadLoop -- 1
local App = dora.App -- 1
local ImGui = dora.ImGui -- 1
local texture = nvg.GetDoraSSR() -- 3
local sprite = Sprite(texture) -- 4
local length = Vec2(View.size).length -- 5
local width, height = sprite.width, sprite.height -- 6
local size = Vec2(width, height).length -- 7
local scaledSize = size -- 8
do -- 10
	local _with_0 = Node() -- 10
	_with_0:addChild(sprite) -- 11
	_with_0.touchEnabled = true -- 12
	_with_0:slot("Gesture", function(center, _numTouches, delta, angle) -- 13
		sprite.position = center -- 17
		sprite.angle = sprite.angle + angle -- 18
		scaledSize = scaledSize + (delta * length) -- 19
		sprite.scaleX = scaledSize / size -- 20
		sprite.scaleY = scaledSize / size -- 21
	end) -- 13
end -- 10
local windowFlags = { -- 26
	"NoDecoration", -- 26
	"AlwaysAutoResize", -- 27
	"NoSavedSettings", -- 28
	"NoFocusOnAppearing", -- 29
	"NoNav", -- 30
	"NoMove" -- 31
} -- 25
return threadLoop(function() -- 32
	local width -- 33
	width = App.visualSize.width -- 33
	ImGui.SetNextWindowBgAlpha(0.35) -- 34
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), "Always", Vec2(1, 0)) -- 35
	ImGui.SetNextWindowSize(Vec2(240, 0), "FirstUseEver") -- 36
	return ImGui.Begin("Gesture", windowFlags, function() -- 37
		ImGui.Text("Gesture") -- 38
		ImGui.Separator() -- 39
		return ImGui.TextWrapped("Interact with multi-touches!") -- 40
	end) -- 40
end) -- 40
