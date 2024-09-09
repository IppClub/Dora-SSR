-- [yue]: Script/Test/UI.yue
local App = Dora.App -- 1
local tostring = _G.tostring -- 1
local math = _G.math -- 1
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
	local scale = App.devicePixelRatio -- 8
	local _with_0 = ScrollArea({ -- 10
		width = width, -- 10
		height = height, -- 11
		paddingX = 50 * scale, -- 12
		paddingY = 50 * scale, -- 13
		viewWidth = viewWidth, -- 14
		viewHeight = viewHeight -- 15
	}) -- 9
	_with_0.border = LineRect({ -- 17
		x = 1, -- 17
		y = 1, -- 17
		width = width - 2, -- 17
		height = height - 2, -- 17
		color = 0xffffffff -- 17
	}) -- 17
	_with_0.area:addChild(_with_0.border) -- 18
	for i = 1, 50 do -- 19
		_with_0.view:addChild((function() -- 20
			local _with_1 = Button({ -- 21
				text = "点击\n按钮" .. tostring(i), -- 21
				width = 60 * scale, -- 22
				height = 60 * scale, -- 23
				fontName = "sarasa-mono-sc-regular", -- 24
				fontSize = math.floor(16 * scale) -- 25
			}) -- 20
			_with_1:onTapped(function() -- 27
				return print("clicked " .. tostring(i)) -- 27
			end) -- 27
			return _with_1 -- 20
		end)()) -- 20
	end -- 27
	_with_0.view:alignItems(Size(viewWidth, height)) -- 28
	_with_0.updateSize = function(self, w, h) -- 29
		self.position = Vec2(w / 2, h / 2) -- 30
		self:adjustSizeWithAlign("Auto", 10 * scale, Size(w, h), Size(width * scale, h)) -- 31
		self.area:removeChild(self.border) -- 32
		self.border = LineRect({ -- 33
			x = 1, -- 33
			y = 1, -- 33
			width = w - 2, -- 33
			height = h - 2, -- 33
			color = 0xffffffff -- 33
		}) -- 33
		return self.area:addChild(self.border) -- 34
	end -- 29
	return _with_0 -- 9
end -- 7
return Director.ui:addChild((function() -- 36
	local _with_0 = AlignNode() -- 36
	local width, height -- 37
	do -- 37
		local _obj_0 = App.bufferSize -- 37
		width, height = _obj_0.width, _obj_0.height -- 37
	end -- 37
	_with_0:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 38
	_with_0:gslot("AppChange", function(settingName) -- 39
		if settingName == "Size" then -- 39
			do -- 40
				local _obj_0 = App.bufferSize -- 40
				width, height = _obj_0.width, _obj_0.height -- 40
			end -- 40
			return _with_0:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 41
		end -- 39
	end) -- 39
	_with_0:css("justify-content: space-between; flex-direction: row") -- 42
	_with_0:addChild((function() -- 43
		local _with_1 = AlignNode() -- 43
		_with_1:css("width: 30%; height: 100%; padding: 10") -- 44
		_with_1:addChild((function() -- 45
			local _with_2 = AlignNode() -- 45
			_with_2:css("width: 100%; height: 100%") -- 46
			local panel = Panel(500, 1000, 1000, 1000) -- 47
			_with_2:addChild(panel) -- 48
			_with_2:onAlignLayout(function(w, h) -- 49
				return panel:updateSize(w, h) -- 49
			end) -- 49
			return _with_2 -- 45
		end)()) -- 45
		return _with_1 -- 43
	end)()) -- 43
	_with_0:addChild((function() -- 50
		local _with_1 = AlignNode() -- 50
		_with_1:css("width: 40%; height: 100%; padding: 10; justify-content: center") -- 51
		_with_1:addChild((function() -- 52
			local _with_2 = AlignNode() -- 52
			_with_2:css("width: 100%; height: 50%") -- 53
			local panel = Panel(600, 1000, 1000, 1000) -- 54
			_with_2:addChild(panel) -- 55
			_with_2:onAlignLayout(function(w, h) -- 56
				return panel:updateSize(w, h) -- 56
			end) -- 56
			return _with_2 -- 52
		end)()) -- 52
		return _with_1 -- 50
	end)()) -- 50
	_with_0:addChild((function() -- 57
		local _with_1 = AlignNode() -- 57
		_with_1:css("width: 30%; height: 100%; padding: 10; flex-direction: column-reverse") -- 58
		_with_1:addChild((function() -- 59
			local _with_2 = AlignNode() -- 59
			_with_2:css("width: 100%; height: 40%") -- 60
			local panel = Panel(600, 1000, 1000, 1000) -- 61
			_with_2:addChild(panel) -- 62
			_with_2:onAlignLayout(function(w, h) -- 63
				return panel:updateSize(w, h) -- 63
			end) -- 63
			return _with_2 -- 59
		end)()) -- 59
		return _with_1 -- 57
	end)()) -- 57
	return _with_0 -- 36
end)()) -- 63
