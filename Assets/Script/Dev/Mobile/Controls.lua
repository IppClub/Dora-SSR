-- [tsx]: Controls.tsx
local ____exports = {} -- 1
local ____DoraX = require("DoraX") -- 1
local React = ____DoraX.React -- 1
local ____Visual = require("Dev.Mobile.Visual") -- 2
local RoundedSurface = ____Visual.RoundedSurface -- 2
local fontName = "sarasa-mono-sc-regular" -- 4
function ____exports.MobileButton(props) -- 6
	local surfaceRenderOrder = (props.renderOrder or 0) + 1 -- 20
	return React.createElement( -- 21
		"node", -- 21
		{ -- 21
			tag = props.tag, -- 21
			x = props.x, -- 21
			y = props.y, -- 21
			anchorX = 0, -- 21
			anchorY = 0, -- 21
			width = props.width, -- 21
			height = 48, -- 21
			renderOrder = props.renderOrder, -- 21
			touchEnabled = true, -- 21
			swallowTouches = true, -- 21
			onTapped = props.onTapped -- 21
		}, -- 21
		React.createElement(RoundedSurface, { -- 21
			width = props.width, -- 21
			height = 48, -- 21
			radius = 14, -- 21
			renderOrder = surfaceRenderOrder, -- 21
			topColor = props.danger and 4294935941 or (props.primary and 4294958955 or 4280889664), -- 21
			bottomColor = props.danger and 4292824662 or (props.primary and 4294950190 or 4279967787), -- 21
			borderWidth = 1, -- 21
			borderColor = props.danger and 4294929259 or (props.primary and 4294958435 or 4281613128), -- 21
			shadow = props.primary or props.danger -- 21
		}), -- 21
		React.createElement("label", { -- 21
			x = props.width / 2, -- 21
			y = 24, -- 21
			fontName = fontName, -- 21
			fontSize = props.fontSize or 17, -- 21
			text = props.text, -- 21
			color3 = props.primary and 1512202 or 16052712 -- 21
		}) -- 21
	) -- 21
end -- 6
function ____exports.MobilePanelSurface(props) -- 34
	return React.createElement(RoundedSurface, { -- 35
		width = props.width, -- 35
		height = props.height, -- 35
		radius = 24, -- 35
		topColor = 4280560956, -- 35
		bottomColor = 4279309856, -- 35
		borderWidth = 1, -- 35
		borderColor = 4283061608, -- 35
		shadow = true, -- 35
		renderOrder = props.renderOrder -- 35
	}) -- 35
end -- 34
return ____exports -- 34
