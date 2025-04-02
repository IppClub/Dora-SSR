-- [tsx]: Cube3D.tsx
local ____exports = {} -- 1
local ____DoraX = require("DoraX") -- 2
local React = ____DoraX.React -- 2
local toNode = ____DoraX.toNode -- 2
local ____Dora = require("Dora") -- 3
local App = ____Dora.App -- 3
local Color = ____Dora.Color -- 3
local themeColor = App.themeColor:toColor3() -- 5
local fillColor = Color(themeColor, 0.5 * 255):toARGB() -- 6
local bolderColor = Color(themeColor, 255):toARGB() -- 7
local size = 300 -- 8
local function Rect(____bindingPattern0) -- 9
	local angleY -- 9
	local angleX -- 9
	local z -- 9
	local y -- 9
	local x -- 9
	x = ____bindingPattern0.x -- 9
	y = ____bindingPattern0.y -- 9
	z = ____bindingPattern0.z -- 9
	angleX = ____bindingPattern0.angleX -- 9
	angleY = ____bindingPattern0.angleY -- 9
	return React.createElement( -- 10
		"draw-node", -- 10
		{ -- 10
			x = x, -- 10
			y = y, -- 10
			z = z, -- 10
			angleX = angleX, -- 10
			angleY = angleY -- 10
		}, -- 10
		React.createElement("rect-shape", { -- 10
			width = size, -- 10
			height = size, -- 10
			fillColor = fillColor, -- 10
			borderColor = bolderColor, -- 10
			borderWidth = 2 -- 10
		}) -- 10
	) -- 10
end -- 9
toNode(React.createElement( -- 16
	"node", -- 16
	nil, -- 16
	React.createElement("sprite", {file = "Image/logo.png", width = size, height = size}), -- 16
	React.createElement(Rect, {z = size / 2}), -- 16
	React.createElement(Rect, {z = -size / 2}), -- 16
	React.createElement(Rect, {x = size / 2, angleY = 90}), -- 16
	React.createElement(Rect, {x = -size / 2, angleY = 90}), -- 16
	React.createElement(Rect, {y = size / 2, angleX = 90}), -- 16
	React.createElement(Rect, {y = -size / 2, angleX = 90}), -- 16
	React.createElement( -- 16
		"loop", -- 16
		nil, -- 16
		React.createElement("angle-x", {time = 3, start = 0, stop = 360}), -- 16
		React.createElement("angle-y", {time = 3, start = 0, stop = 360}) -- 16
	) -- 16
)) -- 16
return ____exports -- 16