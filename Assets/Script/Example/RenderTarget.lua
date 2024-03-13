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
		_with_1:runAction(Sequence(X(2, -150, 250), Event("Turn"), X(2, 250, -150), Event("Turn"))) -- 10
		_with_1:slot("ActionEnd", function(action) -- 16
			return _with_1:runAction(action) -- 16
		end) -- 16
		_with_1:slot("Turn", function() -- 17
			_with_1.fliped = not _with_1.fliped -- 17
		end) -- 17
		return _with_1 -- 5
	end)()) -- 5
	node = _with_0 -- 3
end -- 3
local renderTarget -- 19
do -- 19
	local _with_0 = RenderTarget(300, 400) -- 19
	_with_0:renderWithClear(Color(0xff8a8a8a)) -- 20
	renderTarget = _with_0 -- 19
end -- 19
local surface -- 22
do -- 22
	local _with_0 = Sprite(renderTarget.texture) -- 22
	_with_0.order = 1 -- 23
	_with_0.z = 300 -- 24
	_with_0.angleY = 25 -- 25
	_with_0:addChild(Line({ -- 27
		Vec2.zero, -- 27
		Vec2(300, 0), -- 28
		Vec2(300, 400), -- 29
		Vec2(0, 400), -- 30
		Vec2.zero -- 31
	}, App.themeColor)) -- 26
	_with_0:schedule(function() -- 33
		node.y = 200 -- 34
		renderTarget:renderWithClear(node, Color(0xff8a8a8a)) -- 35
		node.y = 0 -- 36
	end) -- 33
	surface = _with_0 -- 22
end -- 22
local windowFlags = { -- 41
	"NoDecoration", -- 41
	"AlwaysAutoResize", -- 42
	"NoSavedSettings", -- 43
	"NoFocusOnAppearing", -- 44
	"NoNav", -- 45
	"NoMove" -- 46
} -- 40
return threadLoop(function() -- 47
	local width -- 48
	width = App.visualSize.width -- 48
	ImGui.SetNextWindowBgAlpha(0.35) -- 49
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), "Always", Vec2(1, 0)) -- 50
	ImGui.SetNextWindowSize(Vec2(240, 0), "FirstUseEver") -- 51
	return ImGui.Begin("Render Target", windowFlags, function() -- 52
		ImGui.Text("Render Target") -- 53
		ImGui.Separator() -- 54
		return ImGui.TextWrapped("Use render target node as a mirror!") -- 55
	end) -- 55
end) -- 55
