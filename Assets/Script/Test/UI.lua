-- [yue]: Script/Test/UI.yue
local tostring = _G.tostring -- 1
local print = _G.print -- 1
local Size = Dora.Size -- 1
local Vec2 = Dora.Vec2 -- 1
local Director = Dora.Director -- 1
local AlignNode = Dora.AlignNode -- 1
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
	for i = 1, 50 do -- 16
		_with_0.view:addChild((function() -- 17
			local _with_1 = Button({ -- 18
				text = "点击\n按钮" .. tostring(i), -- 18
				width = 60, -- 19
				height = 60, -- 20
				fontName = "sarasa-mono-sc-regular", -- 21
				fontSize = 16 -- 22
			}) -- 17
			_with_1:onTapped(function() -- 24
				return print("clicked " .. tostring(i)) -- 24
			end) -- 24
			return _with_1 -- 17
		end)()) -- 17
	end -- 24
	_with_0.view:alignItems(Size(viewWidth, height)) -- 25
	_with_0.updateSize = function(self, w, h) -- 26
		self.position = Vec2(w / 2, h / 2) -- 27
		self:adjustSizeWithAlign("Auto", 10, Size(w, h), Size(width, h)) -- 28
		if self.border then -- 29
			self.border:removeFromParent() -- 29
		end -- 29
		self.border = LineRect({ -- 30
			x = -w / 2, -- 30
			y = -h / 2, -- 30
			width = w, -- 30
			height = h, -- 30
			color = 0xffffffff -- 30
		}) -- 30
		return _with_0:addChild(self.border) -- 31
	end -- 26
	return _with_0 -- 8
end -- 7
return Director.ui:addChild((function() -- 33
	local _with_0 = AlignNode(true) -- 33
	_with_0:css("justify-content: space-between; flex-direction: row") -- 34
	_with_0:addChild((function() -- 35
		local _with_1 = AlignNode() -- 35
		_with_1:css("width: 30%; height: 100%; padding: 10") -- 36
		_with_1:addChild((function() -- 37
			local _with_2 = AlignNode() -- 37
			_with_2:css("width: 100%; height: 100%") -- 38
			local panel = Panel(500, 1000, 1000, 1000) -- 39
			_with_2:addChild(panel) -- 40
			_with_2:onAlignLayout(function(w, h) -- 41
				return panel:updateSize(w, h) -- 41
			end) -- 41
			return _with_2 -- 37
		end)()) -- 37
		return _with_1 -- 35
	end)()) -- 35
	_with_0:addChild((function() -- 42
		local _with_1 = AlignNode() -- 42
		_with_1:css("width: 40%; height: 100%; padding: 10; justify-content: center") -- 43
		_with_1:addChild((function() -- 44
			local _with_2 = AlignNode() -- 44
			_with_2:css("width: 100%; height: 50%") -- 45
			local panel = Panel(600, 1000, 1000, 1000) -- 46
			_with_2:addChild(panel) -- 47
			_with_2:onAlignLayout(function(w, h) -- 48
				return panel:updateSize(w, h) -- 48
			end) -- 48
			return _with_2 -- 44
		end)()) -- 44
		return _with_1 -- 42
	end)()) -- 42
	_with_0:addChild((function() -- 49
		local _with_1 = AlignNode() -- 49
		_with_1:css("width: 30%; height: 100%; padding: 10; flex-direction: column-reverse") -- 50
		_with_1:addChild((function() -- 51
			local _with_2 = AlignNode() -- 51
			_with_2:css("width: 100%; height: 40%") -- 52
			local panel = Panel(600, 1000, 1000, 1000) -- 53
			_with_2:addChild(panel) -- 54
			_with_2:onAlignLayout(function(w, h) -- 55
				return panel:updateSize(w, h) -- 55
			end) -- 55
			return _with_2 -- 51
		end)()) -- 51
		return _with_1 -- 49
	end)()) -- 49
	return _with_0 -- 33
end)()) -- 55
