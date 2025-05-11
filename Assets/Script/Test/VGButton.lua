-- [tsx]: VGButton.tsx
local ____exports = {} -- 1
local ____DoraX = require("DoraX") -- 2
local React = ____DoraX.React -- 2
local toNode = ____DoraX.toNode -- 2
local ____Dora = require("Dora") -- 3
local Color = ____Dora.Color -- 3
local Node = ____Dora.Node -- 3
local Size = ____Dora.Size -- 3
local nvg = require("nvg") -- 4
local function Button(props) -- 12
	local fontId = nvg.CreateFont("sarasa-mono-sc-regular") -- 13
	local light = nvg.LinearGradient( -- 14
		0, -- 14
		80, -- 14
		0, -- 14
		0, -- 14
		Color(4294967295), -- 14
		Color(4278255615) -- 14
	) -- 14
	local dark = nvg.LinearGradient( -- 15
		0, -- 15
		80, -- 15
		0, -- 15
		0, -- 15
		Color(4294967295), -- 15
		Color(4294689792) -- 15
	) -- 15
	local paint = light -- 16
	local function onCreate() -- 17
		local node = Node() -- 18
		node.size = Size(100, 100) -- 19
		node:onRender(function() -- 20
			nvg.ApplyTransform(node) -- 21
			nvg.BeginPath() -- 22
			nvg.RoundedRect( -- 23
				0, -- 23
				0, -- 23
				100, -- 23
				100, -- 23
				10 -- 23
			) -- 23
			nvg.StrokeColor(Color(4294967295)) -- 24
			nvg.StrokeWidth(5) -- 25
			nvg.Stroke() -- 26
			nvg.FillPaint(paint) -- 27
			nvg.Fill() -- 28
			nvg.ClosePath() -- 29
			nvg.FontFaceId(fontId) -- 30
			nvg.FontSize(32) -- 31
			nvg.FillColor(Color(4278190080)) -- 32
			nvg.Scale(1, -1) -- 33
			nvg.Text(50, -30, props.text) -- 34
			return false -- 35
		end) -- 20
		return node -- 37
	end -- 17
	return React.createElement( -- 39
		"custom-node", -- 39
		{ -- 39
			onCreate = onCreate, -- 39
			onTapBegan = function() -- 39
				paint = dark -- 42
				return paint -- 42
			end, -- 42
			onTapEnded = function() -- 42
				paint = light -- 43
				return paint -- 43
			end, -- 43
			onTapped = props.onClick, -- 43
			children = props.children -- 43
		} -- 43
	) -- 43
end -- 12
toNode(React.createElement( -- 50
	Button, -- 51
	{ -- 51
		text = "OK", -- 51
		onClick = function() return print("Clicked") end -- 51
	}, -- 51
	React.createElement( -- 51
		"sequence", -- 51
		nil, -- 51
		React.createElement("move-x", {time = 1, start = 0, stop = 200}), -- 51
		React.createElement("angle", {time = 1, start = 0, stop = 360}), -- 51
		React.createElement("scale", {time = 1, start = 1, stop = 4}) -- 51
	) -- 51
)) -- 51
return ____exports -- 51