-- [tsx]: Controls.tsx
local ____exports = {} -- 1
local ____DoraX = require("DoraX") -- 1
local React = ____DoraX.React -- 1
local ____Dora = require("Dora") -- 2
local Color = ____Dora.Color -- 2
local Color3 = ____Dora.Color3 -- 2
local DrawNode = ____Dora.DrawNode -- 2
local Label = ____Dora.Label -- 2
local Node = ____Dora.Node -- 2
local Size = ____Dora.Size -- 2
local Vec2 = ____Dora.Vec2 -- 2
local ____Visual = require("Dev.Mobile.Visual") -- 3
local RoundedSurface = ____Visual.RoundedSurface -- 3
local fontName = "sarasa-mono-sc-regular" -- 5
local function roundedVerts(width, height, radius) -- 7
	local verts = {} -- 8
	local r = math.max( -- 9
		0, -- 9
		math.min(radius, width / 2, height / 2) -- 9
	) -- 9
	local corners = {{x = width - r, y = r, start = -math.pi / 2}, {x = width - r, y = height - r, start = 0}, {x = r, y = height - r, start = math.pi / 2}, {x = r, y = r, start = math.pi}} -- 10
	for ____, corner in ipairs(corners) do -- 16
		do -- 16
			local step = 0 -- 17
			while step <= 6 do -- 17
				local angle = corner.start + step * math.pi / 12 -- 18
				verts[#verts + 1] = Vec2( -- 19
					corner.x + math.cos(angle) * r, -- 19
					corner.y + math.sin(angle) * r -- 19
				) -- 19
				step = step + 1 -- 17
			end -- 17
		end -- 17
	end -- 17
	return verts -- 22
end -- 7
local function createMobileNewButton(options) -- 25
	local renderOrder = options.renderOrder or 0 -- 31
	local root = Node() -- 32
	root.tag = options.tag -- 33
	root.anchor = Vec2.zero -- 33
	root.size = Size(70, 44) -- 33
	root.renderOrder = renderOrder -- 34
	root.touchEnabled = true -- 34
	root.swallowTouches = true -- 34
	root:onTapped(options.onTapped) -- 34
	local shape = DrawNode() -- 35
	shape.renderOrder = renderOrder -- 36
	shape:drawPolygon( -- 37
		roundedVerts(70, 44, 22), -- 37
		Color(857020705), -- 37
		0.5, -- 37
		Color(4294954035) -- 37
	) -- 37
	shape:addTo(root) -- 38
	local label = Label(fontName, 14, true) -- 39
	label.text = options.text -- 40
	label.color3 = Color3(4294954035) -- 40
	label.position = Vec2(35, 22) -- 40
	label.renderOrder = renderOrder + 1 -- 41
	label:addTo(root) -- 41
	return root -- 42
end -- 25
function ____exports.MobileNewButton(props) -- 45
	return React.createElement( -- 53
		"custom-node", -- 53
		{ -- 53
			tag = props.tag, -- 53
			x = props.x, -- 53
			y = props.y, -- 53
			width = 70, -- 53
			height = 44, -- 53
			onCreate = function() return createMobileNewButton(props) end -- 53
		} -- 53
	) -- 53
end -- 45
function ____exports.MobileButton(props) -- 57
	local height = props.height or 48 -- 72
	local surfaceRenderOrder = (props.renderOrder or 0) + 1 -- 73
	return React.createElement( -- 74
		"node", -- 74
		{ -- 74
			tag = props.tag, -- 74
			x = props.x, -- 74
			y = props.y, -- 74
			anchorX = 0, -- 74
			anchorY = 0, -- 74
			width = props.width, -- 74
			height = height, -- 74
			renderOrder = props.renderOrder, -- 74
			touchEnabled = true, -- 74
			swallowTouches = true, -- 74
			onTapped = props.onTapped -- 74
		}, -- 74
		React.createElement(RoundedSurface, { -- 74
			width = props.width, -- 74
			height = height, -- 74
			radius = 14, -- 74
			renderOrder = surfaceRenderOrder, -- 74
			topColor = props.danger and 4294935941 or (props.primary and 4294958955 or 4280889664), -- 74
			bottomColor = props.danger and 4292824662 or (props.primary and 4294950190 or 4279967787), -- 74
			borderWidth = 1, -- 74
			borderColor = props.danger and 4294929259 or (props.primary and 4294958435 or 4281613128), -- 74
			shadow = props.primary or props.danger -- 74
		}), -- 74
		React.createElement("label", { -- 74
			x = props.width / 2, -- 74
			y = height / 2, -- 74
			fontName = fontName, -- 74
			fontSize = props.fontSize or 17, -- 74
			text = props.text, -- 74
			color3 = props.primary and 1512202 or 16052712 -- 74
		}) -- 74
	) -- 74
end -- 57
function ____exports.MobilePanelSurface(props) -- 87
	return React.createElement(RoundedSurface, { -- 88
		width = props.width, -- 88
		height = props.height, -- 88
		radius = 24, -- 88
		topColor = 4280560956, -- 88
		bottomColor = 4279309856, -- 88
		borderWidth = 1, -- 88
		borderColor = 4283061608, -- 88
		shadow = true, -- 88
		renderOrder = props.renderOrder -- 88
	}) -- 88
end -- 87
return ____exports -- 87