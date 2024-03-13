-- [yue]: Script/Test/UI.yue
local tostring = _G.tostring -- 1
local print = _G.print -- 1
local Size = dora.Size -- 1
local Director = dora.Director -- 1
local Vec2 = dora.Vec2 -- 1
local Button = require("UI.Control.Basic.Button") -- 2
local LineRect = require("UI.View.Shape.LineRect") -- 3
local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 4
local AlignNode = require("UI.Control.Basic.AlignNode") -- 5
local Panel -- 7
Panel = function(width, height, viewWidth, viewHeight) -- 7
	local _with_0 = ScrollArea({ -- 9
		width = width, -- 9
		height = height, -- 10
		paddingX = 50, -- 11
		paddingY = 50, -- 12
		viewWidth = viewWidth, -- 13
		viewHeight = viewHeight -- 14
	}) -- 8
	_with_0.border = LineRect({ -- 16
		width = width, -- 16
		height = height, -- 16
		color = 0xffffffff -- 16
	}) -- 16
	_with_0.area:addChild(_with_0.border) -- 17
	for i = 1, 50 do -- 18
		_with_0.view:addChild((function() -- 19
			local _with_1 = Button({ -- 20
				text = "点击\n按钮" .. tostring(i), -- 20
				width = 60, -- 21
				height = 60, -- 22
				fontName = "sarasa-mono-sc-regular", -- 23
				fontSize = 16 -- 24
			}) -- 19
			_with_1:slot("Tapped", function() -- 26
				return print("clicked " .. tostring(i)) -- 26
			end) -- 26
			return _with_1 -- 19
		end)()) -- 19
	end -- 26
	_with_0.view:alignItems(Size(viewWidth, height)) -- 27
	return _with_0 -- 8
end -- 7
return Director.ui:addChild((function() -- 29
	local _with_0 = AlignNode({ -- 29
		isRoot = true, -- 29
		inUI = true -- 29
	}) -- 29
	_with_0:addChild((function() -- 30
		local _with_1 = AlignNode() -- 30
		_with_1.hAlign = "Left" -- 31
		_with_1.vAlign = "Top" -- 32
		_with_1.alignWidth = "200" -- 33
		_with_1.alignHeight = "h-20" -- 34
		_with_1.alignOffset = Vec2(10, 10) -- 35
		_with_1:addChild((function() -- 36
			local _with_2 = Panel(200, 300, 430, 640) -- 36
			_with_2.position = Vec2(100, 150) -- 37
			_with_2:slot("AlignLayout", function(w, h) -- 38
				_with_2:adjustSizeWithAlign("Auto", 10, Size(w, h), Size(400, h)) -- 39
				_with_2.position = Vec2(w / 2, h / 2) -- 40
				_with_2.area:removeChild(_with_2.border) -- 41
				_with_2.border = LineRect({ -- 42
					width = w, -- 42
					height = h, -- 42
					color = 0xffffffff -- 42
				}) -- 42
				return _with_2.area:addChild(_with_2.border) -- 43
			end) -- 38
			return _with_2 -- 36
		end)()) -- 36
		return _with_1 -- 30
	end)()) -- 30
	_with_0:addChild((function() -- 44
		local _with_1 = AlignNode() -- 44
		_with_1.size = Size(300, 300) -- 45
		_with_1.hAlign = "Center" -- 46
		_with_1.vAlign = "Center" -- 47
		_with_1.alignOffset = Vec2.zero -- 48
		_with_1:addChild((function() -- 49
			local _with_2 = Panel(300, 300, 430, 640) -- 49
			_with_2.position = Vec2(150, 150) -- 50
			return _with_2 -- 49
		end)()) -- 49
		return _with_1 -- 44
	end)()) -- 44
	_with_0:addChild((function() -- 51
		local _with_1 = AlignNode() -- 51
		_with_1.size = Size(150, 200) -- 52
		_with_1.hAlign = "Right" -- 53
		_with_1.vAlign = "Bottom" -- 54
		_with_1.alignOffset = Vec2(10, 10) -- 55
		_with_1:addChild((function() -- 56
			local _with_2 = Panel(150, 200, 430, 640) -- 56
			_with_2.position = Vec2(75, 100) -- 57
			return _with_2 -- 56
		end)()) -- 56
		return _with_1 -- 51
	end)()) -- 51
	_with_0:alignLayout() -- 58
	return _with_0 -- 29
end)()) -- 58
