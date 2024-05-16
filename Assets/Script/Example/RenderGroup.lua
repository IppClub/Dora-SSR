-- [yue]: Script/Example/RenderGroup.yue
local Class = Dora.Class -- 1
local Node = Dora.Node -- 1
local Vec2 = Dora.Vec2 -- 1
local Sprite = Dora.Sprite -- 1
local DrawNode = Dora.DrawNode -- 1
local App = Dora.App -- 1
local Color = Dora.Color -- 1
local Line = Dora.Line -- 1
local Angle = Dora.Angle -- 1
local Size = Dora.Size -- 1
local threadLoop = Dora.threadLoop -- 1
local ImGui = Dora.ImGui -- 1
local _anon_func_0 = function(Sprite) -- 12
	local _with_0 = Sprite("Image/logo.png") -- 9
	_with_0.scaleX = 0.1 -- 10
	_with_0.scaleY = 0.1 -- 11
	_with_0.renderOrder = 1 -- 12
	return _with_0 -- 9
end -- 9
local _anon_func_1 = function(App, Color, DrawNode, Vec2) -- 22
	local _with_0 = DrawNode() -- 14
	_with_0:drawPolygon({ -- 16
		Vec2(-60, -60), -- 16
		Vec2(60, -60), -- 17
		Vec2(60, 60), -- 18
		Vec2(-60, 60) -- 19
	}, Color(App.themeColor:toColor3(), 0x30)) -- 15
	_with_0.renderOrder = 2 -- 21
	_with_0.angle = 45 -- 22
	return _with_0 -- 14
end -- 14
local _anon_func_2 = function(Color, Line, Vec2) -- 32
	local _with_0 = Line({ -- 25
		Vec2(-60, -60), -- 25
		Vec2(60, -60), -- 26
		Vec2(60, 60), -- 27
		Vec2(-60, 60), -- 28
		Vec2(-60, -60) -- 29
	}, Color(0xffff0080)) -- 24
	_with_0.renderOrder = 3 -- 31
	_with_0.angle = 45 -- 32
	return _with_0 -- 24
end -- 24
local Item = Class(Node, { -- 4
	__init = function(self) -- 4
		self.width = 144 -- 5
		self.height = 144 -- 6
		self.anchor = Vec2.zero -- 7
		self:addChild(_anon_func_0(Sprite)) -- 9
		self:addChild(_anon_func_1(App, Color, DrawNode, Vec2)) -- 14
		self:addChild(_anon_func_2(Color, Line, Vec2)) -- 24
		return self:runAction(Angle(5, 0, 360), true) -- 34
	end -- 4
}) -- 3
local currentEntry -- 36
do -- 36
	local _with_0 = Node() -- 36
	_with_0.renderGroup = true -- 37
	_with_0.size = Size(750, 750) -- 38
	for i = 1, 16 do -- 39
		_with_0:addChild(Item()) -- 39
	end -- 39
	_with_0:alignItems() -- 40
	currentEntry = _with_0 -- 36
end -- 36
local renderGroup = currentEntry.renderGroup -- 44
local windowFlags = { -- 46
	"NoDecoration", -- 46
	"AlwaysAutoResize", -- 47
	"NoSavedSettings", -- 48
	"NoFocusOnAppearing", -- 49
	"NoNav", -- 50
	"NoMove" -- 51
} -- 45
return threadLoop(function() -- 52
	local width -- 53
	width = App.visualSize.width -- 53
	ImGui.SetNextWindowBgAlpha(0.35) -- 54
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), "Always", Vec2(1, 0)) -- 55
	ImGui.SetNextWindowSize(Vec2(240, 0), "FirstUseEver") -- 56
	return ImGui.Begin("Render Group", windowFlags, function() -- 57
		ImGui.Text("Render Group (Yuescript)") -- 58
		ImGui.Separator() -- 59
		ImGui.TextWrapped("When render group is enabled, the nodes in the sub render tree will be grouped by \"renderOrder\" property, and get rendered in ascending order!\nNotice the draw call changes in stats window.") -- 60
		local changed -- 61
		changed, renderGroup = ImGui.Checkbox("Grouped", renderGroup) -- 61
		if changed then -- 61
			currentEntry.renderGroup = renderGroup -- 62
		end -- 61
	end) -- 62
end) -- 62
