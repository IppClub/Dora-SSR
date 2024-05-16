-- [yue]: Script/Test/FixedLabel.yue
local once = Dora.once -- 1
local sleep = Dora.sleep -- 1
local Node = Dora.Node -- 1
local LineRect = require("UI.View.Shape.LineRect") -- 2
local FixedLabel = require("UI.Control.Basic.FixedLabel") -- 3
local utf8 = require("utf-8") -- 4
local createLabel -- 6
createLabel = function(textAlign) -- 6
	local _with_0 = FixedLabel({ -- 7
		text = "", -- 7
		width = 100, -- 7
		height = 30, -- 7
		textAlign = textAlign -- 7
	}) -- 7
	_with_0:addChild(LineRect({ -- 8
		width = 100, -- 8
		height = 30, -- 8
		color = 0xffff0080 -- 8
	})) -- 8
	local text = "1.23456壹贰叁肆伍陆柒玐玖" -- 9
	local textLen = utf8.len(text) -- 10
	_with_0:schedule(once(function() -- 11
		for i = 1, textLen do -- 12
			_with_0.text = utf8.sub(text, 1, i) -- 13
			sleep(0.3) -- 14
		end -- 14
	end)) -- 11
	return _with_0 -- 7
end -- 6
local _with_0 = Node() -- 16
_with_0:addChild(createLabel("Center")) -- 17
_with_0:addChild((function() -- 18
	local _with_1 = createLabel("Left") -- 18
	_with_1.y = 40 -- 19
	return _with_1 -- 18
end)()) -- 18
_with_0:addChild((function() -- 20
	local _with_1 = createLabel("Right") -- 20
	_with_1.y = -40 -- 21
	return _with_1 -- 20
end)()) -- 20
return _with_0 -- 16
