-- [yue]: Script/Test/Ruler.yue
local print = _G.print -- 1
local Ruler = require("UI.Control.Basic.Ruler") -- 3
local CircleButton = require("UI.Control.Basic.CircleButton") -- 4
local ruler = Ruler({ -- 7
	width = 600, -- 7
	height = 150 -- 8
}) -- 6
local _with_0 = CircleButton({ -- 12
	text = "显示", -- 12
	y = -200, -- 13
	radius = 60, -- 14
	fontSize = 40 -- 15
}) -- 11
_with_0:slot("Tapped", function() -- 17
	if _with_0.text == "显示" then -- 18
		_with_0.text = "隐藏" -- 19
		return ruler:show(0, 0, 100, 10, function(value) -- 20
			return print(value) -- 21
		end) -- 21
	else -- 23
		_with_0.text = "显示" -- 23
		return ruler:hide() -- 24
	end -- 18
end) -- 17
return _with_0 -- 11
