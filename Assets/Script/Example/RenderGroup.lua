-- [yue]: Script/Example/RenderGroup.yue
local Class = dora.Class -- 1
local Node = dora.Node -- 1
local Vec2 = dora.Vec2 -- 1
local Sprite = dora.Sprite -- 1
local App = dora.App -- 1
local Color = dora.Color -- 1
local DrawNode = dora.DrawNode -- 1
local Line = dora.Line -- 1
local Angle = dora.Angle -- 1
local Size = dora.Size -- 1
local threadLoop = dora.threadLoop -- 1
local ImGui = dora.ImGui -- 1
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
		self:runAction(Angle(5, 0, 360)) -- 34
		return self:slot("ActionEnd", function(action) -- 35
			return self:runAction(action) -- 35
		end) -- 35
	end -- 4
}) -- 3
local currentEntry -- 37
do -- 37
	local _with_0 = Node() -- 37
	_with_0.renderGroup = true -- 38
	_with_0.size = Size(750, 750) -- 39
	for i = 1, 16 do -- 40
		_with_0:addChild(Item()) -- 40
	end -- 40
	_with_0:alignItems() -- 41
	currentEntry = _with_0 -- 37
end -- 37
local renderGroup = currentEntry.renderGroup -- 45
local windowFlags = { -- 47
	"NoDecoration", -- 47
	"AlwaysAutoResize", -- 48
	"NoSavedSettings", -- 49
	"NoFocusOnAppearing", -- 50
	"NoNav", -- 51
	"NoMove" -- 52
} -- 46
return threadLoop(function() -- 53
	local width -- 54
	width = App.visualSize.width -- 54
	ImGui.SetNextWindowBgAlpha(0.35) -- 55
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), "Always", Vec2(1, 0)) -- 56
	ImGui.SetNextWindowSize(Vec2(240, 0), "FirstUseEver") -- 57
	return ImGui.Begin("Render Group", windowFlags, function() -- 58
		ImGui.Text("Render Group") -- 59
		ImGui.Separator() -- 60
		ImGui.TextWrapped("When render group is enabled, the nodes in the sub render tree will be grouped by \"renderOrder\" property, and get rendered in ascending order!\nNotice the draw call changes in stats window.") -- 61
		local changed -- 62
		changed, renderGroup = ImGui.Checkbox("Grouped", renderGroup) -- 62
		if changed then -- 62
			currentEntry.renderGroup = renderGroup -- 63
		end -- 62
	end) -- 63
end) -- 63
