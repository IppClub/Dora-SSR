-- [yue]: Script/Test/UI.yue
local tostring = _G.tostring -- 1
local print = _G.print -- 1
local Size = dora.Size -- 1
local Vec2 = dora.Vec2 -- 1
local Director = dora.Director -- 1
local AlignNode = dora.AlignNode -- 1
local Button = require("UI.Control.Basic.Button") -- 3
local LineRect = require("UI.View.Shape.LineRect") -- 4
local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 5
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
	_with_0.updateSize = function(self, w, h) -- 28
		self.position = Vec2(w / 2, h / 2) -- 29
		self:adjustSizeWithAlign("Auto", 10, Size(w, h), Size(width, h)) -- 30
		self.area:removeChild(self.border) -- 31
		self.border = LineRect({ -- 32
			width = w, -- 32
			height = h, -- 32
			color = 0xffffffff -- 32
		}) -- 32
		return self.area:addChild(self.border) -- 33
	end -- 28
	return _with_0 -- 8
end -- 7
return Director.ui:addChild((function() -- 35
	local _with_0 = AlignNode(true) -- 35
	_with_0:css("justify-content: space-between; flex-direction: row") -- 36
	_with_0:addChild((function() -- 37
		local _with_1 = AlignNode() -- 37
		_with_1:css("width: 30%; height: 100%; padding: 10") -- 38
		_with_1:addChild((function() -- 39
			local _with_2 = AlignNode() -- 39
			_with_2:css("width: 100%; height: 100%") -- 40
			local panel = Panel(500, 1000, 1000, 1000) -- 41
			_with_2:addChild(panel) -- 42
			_with_2:slot("AlignLayout", function(w, h) -- 43
				return panel:updateSize(w, h) -- 43
			end) -- 43
			return _with_2 -- 39
		end)()) -- 39
		return _with_1 -- 37
	end)()) -- 37
	_with_0:addChild((function() -- 44
		local _with_1 = AlignNode() -- 44
		_with_1:css("width: 40%; height: 100%; padding: 10; justify-content: center") -- 45
		_with_1:addChild((function() -- 46
			local _with_2 = AlignNode() -- 46
			_with_2:css("width: 100%; height: 50%") -- 47
			local panel = Panel(600, 1000, 1000, 1000) -- 48
			_with_2:addChild(panel) -- 49
			_with_2:slot("AlignLayout", function(w, h) -- 50
				return panel:updateSize(w, h) -- 50
			end) -- 50
			return _with_2 -- 46
		end)()) -- 46
		return _with_1 -- 44
	end)()) -- 44
	_with_0:addChild((function() -- 51
		local _with_1 = AlignNode() -- 51
		_with_1:css("width: 30%; height: 100%; padding: 10; flex-direction: column-reverse") -- 52
		_with_1:addChild((function() -- 53
			local _with_2 = AlignNode() -- 53
			_with_2:css("width: 100%; height: 40%") -- 54
			local panel = Panel(600, 1000, 1000, 1000) -- 55
			_with_2:addChild(panel) -- 56
			_with_2:slot("AlignLayout", function(w, h) -- 57
				return panel:updateSize(w, h) -- 57
			end) -- 57
			return _with_2 -- 53
		end)()) -- 53
		return _with_1 -- 51
	end)()) -- 51
	return _with_0 -- 35
end)()) -- 57
