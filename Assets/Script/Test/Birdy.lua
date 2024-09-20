-- [tsx]: Birdy.tsx
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ParseFloat = ____lualib.__TS__ParseFloat -- 1
local ____exports = {} -- 1
local ____DoraX = require("DoraX") -- 2
local React = ____DoraX.React -- 2
local toNode = ____DoraX.toNode -- 2
local useRef = ____DoraX.useRef -- 2
local ____Dora = require("Dora") -- 3
local Ease = ____Dora.Ease -- 3
local Line = ____Dora.Line -- 3
local Scale = ____Dora.Scale -- 3
local Vec2 = ____Dora.Vec2 -- 3
local tolua = ____Dora.tolua -- 3
toNode(React.createElement("sprite", {file = "Image/logo.png", scaleX = 0.2, scaleY = 0.2})) -- 5
local function Box(props) -- 14
	local numText = tostring(props.num) -- 15
	return React.createElement( -- 16
		"body", -- 16
		{ -- 16
			type = "Dynamic", -- 16
			scaleX = 0, -- 16
			scaleY = 0, -- 16
			x = props.x, -- 16
			y = props.y, -- 16
			tag = numText -- 16
		}, -- 16
		React.createElement("rect-fixture", {width = 100, height = 100}), -- 16
		React.createElement( -- 16
			"draw-node", -- 16
			nil, -- 16
			React.createElement("rect-shape", { -- 16
				width = 100, -- 16
				height = 100, -- 16
				fillColor = 2281766911, -- 16
				borderWidth = 1, -- 16
				borderColor = 4278255615 -- 16
			}) -- 16
		), -- 16
		React.createElement("label", {fontName = "sarasa-mono-sc-regular", fontSize = 40}, numText), -- 16
		props.children -- 23
	) -- 23
end -- 14
local bird = useRef() -- 28
local score = useRef() -- 29
local start = Vec2.zero -- 31
local delta = Vec2.zero -- 32
local line = Line() -- 34
local world = useRef() -- 35
toNode(React.createElement( -- 37
	"align-node", -- 37
	{ -- 37
		windowRoot = true, -- 37
		onLayout = function(w, h) -- 37
			if world.current then -- 37
				world.current.position = Vec2(w / 2, h / 2) -- 40
			end -- 40
		end -- 38
	}, -- 38
	React.createElement( -- 38
		"physics-world", -- 38
		{ -- 38
			ref = world, -- 38
			scaleX = 0.5, -- 38
			scaleY = 0.5, -- 38
			onTapBegan = function(touch) -- 38
				start = touch.location -- 45
				line:clear() -- 46
			end, -- 44
			onTapMoved = function(touch) -- 44
				delta = delta:add(touch.delta) -- 49
				line:set({ -- 50
					start, -- 50
					start:add(delta) -- 50
				}) -- 50
			end, -- 48
			onTapEnded = function() -- 48
				if not bird.current then -- 48
					return -- 53
				end -- 53
				bird.current.velocity = delta:mul(Vec2(10, 10)) -- 54
				start = Vec2.zero -- 55
				delta = Vec2.zero -- 56
				line:clear() -- 57
			end -- 52
		}, -- 52
		React.createElement( -- 52
			"body", -- 52
			{type = "Static"}, -- 52
			React.createElement("rect-fixture", {centerY = -200, width = 2000, height = 10}), -- 52
			React.createElement( -- 52
				"draw-node", -- 52
				nil, -- 52
				React.createElement("rect-shape", {centerY = -200, width = 2000, height = 10, fillColor = 4294689792}) -- 52
			) -- 52
		), -- 52
		__TS__ArrayMap( -- 68
			{ -- 68
				10, -- 68
				20, -- 68
				30, -- 68
				40, -- 68
				50 -- 68
			}, -- 68
			function(____, num, i) return React.createElement( -- 68
				Box, -- 69
				{num = num, x = 200, y = -150 + i * 100}, -- 69
				React.createElement( -- 69
					"sequence", -- 69
					nil, -- 69
					React.createElement("delay", {time = i * 0.2}), -- 69
					React.createElement("scale", {time = 0.3, start = 0, stop = 1}) -- 69
				) -- 69
			) end -- 69
		), -- 69
		React.createElement( -- 69
			"body", -- 69
			{ -- 69
				ref = bird, -- 69
				type = "Dynamic", -- 69
				x = -200, -- 69
				y = -150, -- 69
				onContactStart = function(other) -- 69
					if other.tag ~= "" and score.current then -- 69
						local sc = __TS__ParseFloat(score.current.text) + __TS__ParseFloat(other.tag) -- 80
						score.current.text = tostring(sc) -- 81
						local ____tolua_cast_2 = tolua.cast -- 82
						local ____opt_0 = other.children -- 82
						local label = ____tolua_cast_2(____opt_0 and ____opt_0.last, "Label") -- 82
						if label then -- 82
							label.text = "" -- 83
						end -- 83
						other.tag = "" -- 84
						other:perform(Scale(0.2, 0.7, 1)) -- 85
					end -- 85
				end -- 78
			}, -- 78
			React.createElement("disk-fixture", {radius = 50}), -- 78
			React.createElement( -- 78
				"draw-node", -- 78
				nil, -- 78
				React.createElement("dot-shape", {radius = 50, color = 4294901896}) -- 78
			), -- 78
			React.createElement("label", {ref = score, fontName = "sarasa-mono-sc-regular", fontSize = 40}, "0"), -- 78
			React.createElement("scale", {time = 0.4, start = 0.3, stop = 1, easing = Ease.OutBack}) -- 78
		) -- 78
	) -- 78
)) -- 78
return ____exports -- 78