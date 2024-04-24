-- [yue]: Script/Example/RenderTarget.yue
local Node = dora.Node -- 1
local Model = dora.Model -- 1
local Sequence = dora.Sequence -- 1
local X = dora.X -- 1
local Event = dora.Event -- 1
local RenderTarget = dora.RenderTarget -- 1
local Color = dora.Color -- 1
local Sprite = dora.Sprite -- 1
local Line = dora.Line -- 1
local Vec2 = dora.Vec2 -- 1
local App = dora.App -- 1
local threadLoop = dora.threadLoop -- 1
local ImGui = dora.ImGui -- 1
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
local surface -- 21
do -- 21
	local _with_0 = Sprite(renderTarget.texture) -- 21
	_with_0.order = 1 -- 22
	_with_0.z = 300 -- 23
	_with_0.angleY = 25 -- 24
	_with_0:addChild(Line({ -- 26
		Vec2.zero, -- 26
		Vec2(300, 0), -- 27
		Vec2(300, 400), -- 28
		Vec2(0, 400), -- 29
		Vec2.zero -- 30
	}, App.themeColor)) -- 25
	_with_0:schedule(function() -- 32
		node.y = 200 -- 33
		renderTarget:renderWithClear(node, Color(0xff8a8a8a)) -- 34
		node.y = 0 -- 35
	end) -- 32
	surface = _with_0 -- 21
end -- 21
local windowFlags = { -- 40
	"NoDecoration", -- 40
	"AlwaysAutoResize", -- 41
	"NoSavedSettings", -- 42
	"NoFocusOnAppearing", -- 43
	"NoNav", -- 44
	"NoMove" -- 45
} -- 39
return threadLoop(function() -- 46
	local width -- 47
	width = App.visualSize.width -- 47
	ImGui.SetNextWindowBgAlpha(0.35) -- 48
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), "Always", Vec2(1, 0)) -- 49
	ImGui.SetNextWindowSize(Vec2(240, 0), "FirstUseEver") -- 50
	return ImGui.Begin("Render Target", windowFlags, function() -- 51
		ImGui.Text("Render Target (Yuescript)") -- 52
		ImGui.Separator() -- 53
		return ImGui.TextWrapped("Use render target node as a mirror!") -- 54
	end) -- 54
end) -- 54
