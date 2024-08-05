-- [yue]: Script/Example/RenderTarget.yue
local Node = Dora.Node -- 1
local Model = Dora.Model -- 1
local Sequence = Dora.Sequence -- 1
local X = Dora.X -- 1
local Event = Dora.Event -- 1
local RenderTarget = Dora.RenderTarget -- 1
local Color = Dora.Color -- 1
local Sprite = Dora.Sprite -- 1
local Line = Dora.Line -- 1
local Vec2 = Dora.Vec2 -- 1
local App = Dora.App -- 1
local threadLoop = Dora.threadLoop -- 1
local ImGui = Dora.ImGui -- 1
local node -- 3
do -- 3
	local _with_0 = Node() -- 3
	_with_0.order = 2 -- 4
	_with_0:addChild((function() -- 5
		local _with_1 = Model("Model/xiaoli.model") -- 5
		_with_1.y = -80 -- 6
		_with_1.fliped = true -- 7
		_with_1.look = "happy" -- 8
		_with_1:play("walk", true) -- 9
		_with_1:runAction(Sequence(X(2, -150, 250), Event("Turn"), X(2, 250, -150), Event("Turn")), true) -- 10
		_with_1:slot("Turn", function() -- 16
			_with_1.fliped = not _with_1.fliped -- 16
		end) -- 16
		return _with_1 -- 5
	end)()) -- 5
	node = _with_0 -- 3
end -- 3
local renderTarget -- 18
do -- 18
	local _with_0 = RenderTarget(300, 400) -- 18
	_with_0:renderWithClear(Color(0xff8a8a8a)) -- 19
	renderTarget = _with_0 -- 18
end -- 18
do -- 21
	local surface = Sprite(renderTarget.texture) -- 21
	surface.order = 1 -- 22
	surface.z = 300 -- 23
	surface.angleY = 25 -- 24
	surface:addChild(Line({ -- 26
		Vec2.zero, -- 26
		Vec2(300, 0), -- 27
		Vec2(300, 400), -- 28
		Vec2(0, 400), -- 29
		Vec2.zero -- 30
	}, App.themeColor)) -- 25
	surface:schedule(function() -- 32
		node.y = 200 -- 33
		renderTarget:renderWithClear(node, Color(0xff8a8a8a)) -- 34
		node.y = 0 -- 35
	end) -- 32
end -- 21
local windowFlags = { -- 40
	"NoDecoration", -- 40
	"AlwaysAutoResize", -- 40
	"NoSavedSettings", -- 40
	"NoFocusOnAppearing", -- 40
	"NoNav", -- 40
	"NoMove" -- 40
} -- 40
return threadLoop(function() -- 48
	local width -- 49
	width = App.visualSize.width -- 49
	ImGui.SetNextWindowBgAlpha(0.35) -- 50
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), "Always", Vec2(1, 0)) -- 51
	ImGui.SetNextWindowSize(Vec2(240, 0), "FirstUseEver") -- 52
	return ImGui.Begin("Render Target", windowFlags, function() -- 53
		ImGui.Text("Render Target (Yuescript)") -- 54
		ImGui.Separator() -- 55
		return ImGui.TextWrapped("Use render target node as a mirror!") -- 56
	end) -- 56
end) -- 56
