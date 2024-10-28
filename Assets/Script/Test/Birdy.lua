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
				line:set({start, touch.location}) -- 50
			end, -- 48
			onTapEnded = function() -- 48
				if not bird.current then -- 48
					return -- 53
				end -- 53
				bird.current.velocity = delta:mul(Vec2(10, 10)) -- 54
				start = Vec2.zero -- 55
				delta = Vec2.zero -- 56
				line:clear() -- 57
			end, -- 52
			onMount = function(world) -- 52
				world:addChild(line) -- 60
			end -- 59
		}, -- 59
		React.createElement( -- 59
			"body", -- 59
			{type = "Static"}, -- 59
			React.createElement("rect-fixture", {centerY = -200, width = 2000, height = 10}), -- 59
			React.createElement( -- 59
				"draw-node", -- 59
				nil, -- 59
				React.createElement("rect-shape", {centerY = -200, width = 2000, height = 10, fillColor = 4294689792}) -- 59
			) -- 59
		), -- 59
		__TS__ArrayMap( -- 71
			{ -- 71
				10, -- 71
				20, -- 71
				30, -- 71
				40, -- 71
				50 -- 71
			}, -- 71
			function(____, num, i) return React.createElement( -- 71
				Box, -- 72
				{num = num, x = 200, y = -150 + i * 100}, -- 72
				React.createElement( -- 72
					"sequence", -- 72
					nil, -- 72
					React.createElement("delay", {time = i * 0.2}), -- 72
					React.createElement("scale", {time = 0.3, start = 0, stop = 1}) -- 72
				) -- 72
			) end -- 72
		), -- 72
		React.createElement( -- 72
			"body", -- 72
			{ -- 72
				ref = bird, -- 72
				type = "Dynamic", -- 72
				x = -200, -- 72
				y = -150, -- 72
				onContactStart = function(other) -- 72
					if other.tag ~= "" and score.current then -- 72
						local sc = __TS__ParseFloat(score.current.text) + __TS__ParseFloat(other.tag) -- 83
						score.current.text = tostring(sc) -- 84
						local ____tolua_cast_2 = tolua.cast -- 85
						local ____opt_0 = other.children -- 85
						local label = ____tolua_cast_2(____opt_0 and ____opt_0.last, "Label") -- 85
						if label then -- 85
							label.text = "" -- 86
						end -- 86
						other.tag = "" -- 87
						other:perform(Scale(0.2, 0.7, 1)) -- 88
					end -- 88
				end -- 81
			}, -- 81
			React.createElement("disk-fixture", {radius = 50}), -- 81
			React.createElement( -- 81
				"draw-node", -- 81
				nil, -- 81
				React.createElement("dot-shape", {radius = 50, color = 4294901896}) -- 81
			), -- 81
			React.createElement("label", {ref = score, fontName = "sarasa-mono-sc-regular", fontSize = 40}, "0"), -- 81
			React.createElement("scale", {time = 0.4, start = 0.3, stop = 1, easing = Ease.OutBack}) -- 81
		) -- 81
	) -- 81
)) -- 81
return ____exports -- 81