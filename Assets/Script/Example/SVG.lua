-- [yue]: Script/Example/SVG.yue
local SVG = dora.SVG -- 1
local threadLoop = dora.threadLoop -- 1
local nvg = dora.nvg -- 1
local svg = SVG("Image/dora.svg") -- 3
return threadLoop(function() -- 5
	nvg.Scale(0.5, 0.5) -- 6
	return svg:render() -- 7
end) -- 7
