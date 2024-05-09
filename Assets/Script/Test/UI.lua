-- [yue]: Script/Test/UI.yue
local App = dora.App -- 1
local tostring = _G.tostring -- 1
local math = _G.math -- 1
local print = _G.print -- 1
local Size = dora.Size -- 1
local Vec2 = dora.Vec2 -- 1
local Director = dora.Director -- 1
local AlignNode = dora.AlignNode -- 1
local Button = require("UI.Control.Basic.Button") -- 2
local LineRect = require("UI.View.Shape.LineRect") -- 3
local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 4
local Panel -- 6
Panel = function(width, height, viewWidth, viewHeight) -- 6
	local scale = App.devicePixelRatio -- 7
	local _with_0 = ScrollArea({ -- 9
		width = width, -- 9
		height = height, -- 10
		paddingX = 50 * scale, -- 11
		paddingY = 50 * scale, -- 12
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
				width = 60 * scale, -- 21
				height = 60 * scale, -- 22
				fontName = "sarasa-mono-sc-regular", -- 23
				fontSize = math.floor(16 * scale) -- 24
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
		self:adjustSizeWithAlign("Auto", 10 * scale, Size(w, h), Size(width * scale, h)) -- 30
		self.area:removeChild(self.border) -- 31
		self.border = LineRect({ -- 32
			width = w, -- 32
			height = h, -- 32
			color = 0xffffffff -- 32
		}) -- 32
		return self.area:addChild(self.border) -- 33
	end -- 28
	return _with_0 -- 8
end -- 6
return Director.ui:addChild((function() -- 35
	local _with_0 = AlignNode() -- 35
	local width, height -- 36
	do -- 36
		local _obj_0 = App.bufferSize -- 36
		width, height = _obj_0.width, _obj_0.height -- 36
	end -- 36
	_with_0:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 37
	_with_0:gslot("AppSizeChanged", function() -- 38
		do -- 39
			local _obj_0 = App.bufferSize -- 39
			width, height = _obj_0.width, _obj_0.height -- 39
		end -- 39
		return _with_0:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 40
	end) -- 38
	_with_0:css("justify-content: space-between; flex-direction: row") -- 41
	_with_0:addChild((function() -- 42
		local _with_1 = AlignNode() -- 42
		_with_1:css("width: 30%; height: 100%; padding: 10") -- 43
		_with_1:addChild((function() -- 44
			local _with_2 = AlignNode() -- 44
			_with_2:css("width: 100%; height: 100%") -- 45
			local panel = Panel(500, 1000, 1000, 1000) -- 46
			_with_2:addChild(panel) -- 47
			_with_2:slot("AlignLayout", function(w, h) -- 48
				return panel:updateSize(w, h) -- 48
			end) -- 48
			return _with_2 -- 44
		end)()) -- 44
		return _with_1 -- 42
	end)()) -- 42
	_with_0:addChild((function() -- 49
		local _with_1 = AlignNode() -- 49
		_with_1:css("width: 40%; height: 100%; padding: 10; justify-content: center") -- 50
		_with_1:addChild((function() -- 51
			local _with_2 = AlignNode() -- 51
			_with_2:css("width: 100%; height: 50%") -- 52
			local panel = Panel(600, 1000, 1000, 1000) -- 53
			_with_2:addChild(panel) -- 54
			_with_2:slot("AlignLayout", function(w, h) -- 55
				return panel:updateSize(w, h) -- 55
			end) -- 55
			return _with_2 -- 51
		end)()) -- 51
		return _with_1 -- 49
	end)()) -- 49
	_with_0:addChild((function() -- 56
		local _with_1 = AlignNode() -- 56
		_with_1:css("width: 30%; height: 100%; padding: 10; flex-direction: column-reverse") -- 57
		_with_1:addChild((function() -- 58
			local _with_2 = AlignNode() -- 58
			_with_2:css("width: 100%; height: 40%") -- 59
			local panel = Panel(600, 1000, 1000, 1000) -- 60
			_with_2:addChild(panel) -- 61
			_with_2:slot("AlignLayout", function(w, h) -- 62
				return panel:updateSize(w, h) -- 62
			end) -- 62
			return _with_2 -- 58
		end)()) -- 58
		return _with_1 -- 56
	end)()) -- 56
	return _with_0 -- 35
end)()) -- 62
