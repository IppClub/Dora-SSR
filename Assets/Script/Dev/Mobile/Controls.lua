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
	local surfaceRenderOrder = (props.renderOrder or 0) + 1 -- 71
	return React.createElement( -- 72
		"node", -- 72
		{ -- 72
			tag = props.tag, -- 72
			x = props.x, -- 72
			y = props.y, -- 72
			anchorX = 0, -- 72
			anchorY = 0, -- 72
			width = props.width, -- 72
			height = 48, -- 72
			renderOrder = props.renderOrder, -- 72
			touchEnabled = true, -- 72
			swallowTouches = true, -- 72
			onTapped = props.onTapped -- 72
		}, -- 72
		React.createElement(RoundedSurface, { -- 72
			width = props.width, -- 72
			height = 48, -- 72
			radius = 14, -- 72
			renderOrder = surfaceRenderOrder, -- 72
			topColor = props.danger and 4294935941 or (props.primary and 4294958955 or 4280889664), -- 72
			bottomColor = props.danger and 4292824662 or (props.primary and 4294950190 or 4279967787), -- 72
			borderWidth = 1, -- 72
			borderColor = props.danger and 4294929259 or (props.primary and 4294958435 or 4281613128), -- 72
			shadow = props.primary or props.danger -- 72
		}), -- 72
		React.createElement("label", { -- 72
			x = props.width / 2, -- 72
			y = 24, -- 72
			fontName = fontName, -- 72
			fontSize = props.fontSize or 17, -- 72
			text = props.text, -- 72
			color3 = props.primary and 1512202 or 16052712 -- 72
		}) -- 72
	) -- 72
end -- 57
function ____exports.MobilePanelSurface(props) -- 85
	return React.createElement(RoundedSurface, { -- 86
		width = props.width, -- 86
		height = props.height, -- 86
		radius = 24, -- 86
		topColor = 4280560956, -- 86
		bottomColor = 4279309856, -- 86
		borderWidth = 1, -- 86
		borderColor = 4283061608, -- 86
		shadow = true, -- 86
		renderOrder = props.renderOrder -- 86
	}) -- 86
end -- 85
return ____exports -- 85