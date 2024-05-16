-- [yue]: Script/Example/SVG.yue
local SVG = Dora.SVG -- 1
local threadLoop = Dora.threadLoop -- 1
local nvg = Dora.nvg -- 1
local svg = SVG("Image/Dora.svg") -- 3
return threadLoop(function() -- 5
	nvg.Scale(0.5, 0.5) -- 6
	return svg:render() -- 7
end) -- 7
