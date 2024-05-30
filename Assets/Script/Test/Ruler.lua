-- [yue]: Script/Test/Ruler.yue
local print = _G.print -- 1
local Ruler = require("UI.Control.Basic.Ruler") -- 3
local CircleButton = require("UI.Control.Basic.CircleButton") -- 4
local ruler = Ruler({ -- 7
	x = 0, -- 7
	y = 0, -- 8
	width = 600, -- 9
	height = 150, -- 10
	fontName = "sarasa-mono-sc-regular", -- 11
	fontSize = 30 -- 12
}) -- 6
local _with_0 = CircleButton({ -- 16
	text = "显示", -- 16
	y = -200, -- 17
	radius = 60, -- 18
	fontSize = 40 -- 19
}) -- 15
_with_0:slot("Tapped", function() -- 21
	if _with_0.text == "显示" then -- 22
		_with_0.text = "隐藏" -- 23
		return ruler:show(0, 0, 100, 10, function(value) -- 24
			return print(value) -- 25
		end) -- 25
	else -- 27
		_with_0.text = "显示" -- 27
		return ruler:hide() -- 28
	end -- 22
end) -- 21
return _with_0 -- 15
