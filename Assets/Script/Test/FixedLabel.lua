-- [yue]: Script/Test/FixedLabel.yue
local sleep = Dora.sleep -- 1
local Node = Dora.Node -- 1
local LineRect = require("UI.View.Shape.LineRect") -- 3
local FixedLabel = require("UI.Control.Basic.FixedLabel") -- 4
local utf8 = require("utf-8") -- 5
local createLabel -- 7
createLabel = function(textAlign) -- 7
	local _with_0 = FixedLabel({ -- 8
		text = "", -- 8
		width = 100, -- 8
		height = 30, -- 8
		textAlign = textAlign -- 8
	}) -- 8
	_with_0:addChild(LineRect({ -- 9
		width = 100, -- 9
		height = 30, -- 9
		color = 0xffff0080 -- 9
	})) -- 9
	local text = "1.23456壹贰叁肆伍陆柒玐玖" -- 10
	local textLen = utf8.len(text) -- 11
	_with_0:once(function() -- 12
		for i = 1, textLen do -- 13
			_with_0.text = utf8.sub(text, 1, i) -- 14
			sleep(0.3) -- 15
		end -- 15
	end) -- 12
	return _with_0 -- 8
end -- 7
local _with_0 = Node() -- 17
_with_0:addChild(createLabel("Center")) -- 18
_with_0:addChild((function() -- 19
	local _with_1 = createLabel("Left") -- 19
	_with_1.y = 40 -- 20
	return _with_1 -- 19
end)()) -- 19
_with_0:addChild((function() -- 21
	local _with_1 = createLabel("Right") -- 21
	_with_1.y = -40 -- 22
	return _with_1 -- 21
end)()) -- 21
return _with_0 -- 17
