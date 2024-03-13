-- [yue]: Script/Test/Ruler.yue
local print = _G.print -- 1
local Ruler = require("UI.Control.Basic.Ruler") -- 2
local CircleButton = require("UI.Control.Basic.CircleButton") -- 3
local ruler = Ruler({ -- 6
	x = 0, -- 6
	y = 0, -- 7
	width = 600, -- 8
	height = 150, -- 9
	fontName = "sarasa-mono-sc-regular", -- 10
	fontSize = 30 -- 11
}) -- 5
local _with_0 = CircleButton({ -- 15
	text = "显示", -- 15
	y = -200, -- 16
	radius = 60, -- 17
	fontSize = 40 -- 18
}) -- 14
_with_0:slot("Tapped", function() -- 20
	if _with_0.text == "显示" then -- 21
		_with_0.text = "隐藏" -- 22
		return ruler:show(0, 0, 100, 10, function(value) -- 23
			return print(value) -- 24
		end) -- 24
	else -- 26
		_with_0.text = "显示" -- 26
		return ruler:hide() -- 27
	end -- 21
end) -- 20
return _with_0 -- 14
