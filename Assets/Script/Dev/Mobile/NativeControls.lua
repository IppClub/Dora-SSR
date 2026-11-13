-- [tsx]: NativeControls.tsx
local ____lualib = require("lualib_bundle") -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local ____exports = {} -- 1
local ____DoraX = require("DoraX") -- 1
local React = ____DoraX.React -- 1
local ____Dora = require("Dora") -- 2
local DrawNode = ____Dora.DrawNode -- 2
local ____Surface = require("Dev.Mobile.Surface") -- 3
local paintSurface = ____Surface.paintSurface -- 3
function ____exports.NativeRoundedSurface(props) -- 5
	return React.createElement( -- 6
		"custom-node", -- 6
		{ -- 6
			renderOrder = props.renderOrder, -- 6
			onCreate = function() -- 6
				local draw = DrawNode() -- 7
				paintSurface( -- 8
					draw, -- 8
					props.width, -- 8
					props.height, -- 8
					props.radius, -- 8
					props -- 8
				) -- 8
				return draw -- 9
			end -- 6
		} -- 6
	) -- 6
end -- 5
function ____exports.NativePanelSurface(props) -- 13
	return React.createElement( -- 14
		____exports.NativeRoundedSurface, -- 14
		__TS__ObjectAssign({}, props, { -- 14
			radius = 24, -- 14
			topColor = 4280953904, -- 14
			bottomColor = 4279571992, -- 14
			borderColor = 4283585624, -- 14
			shadow = true -- 14
		}) -- 14
	) -- 14
end -- 13
function ____exports.NativeButton(props) -- 17
	local height = props.height or 48 -- 18
	return React.createElement( -- 19
		"node", -- 19
		{ -- 19
			tag = props.tag, -- 19
			x = props.x, -- 19
			y = props.y, -- 19
			width = props.width, -- 19
			height = height, -- 19
			anchorX = 0, -- 19
			anchorY = 0, -- 19
			touchEnabled = true, -- 19
			swallowTouches = true, -- 19
			onTapped = props.onTapped -- 19
		}, -- 19
		React.createElement(____exports.NativeRoundedSurface, { -- 19
			width = props.width, -- 19
			height = height, -- 19
			radius = 14, -- 19
			renderOrder = props.renderOrder, -- 19
			topColor = props.primary and 4294958955 or 4281282868, -- 19
			bottomColor = props.primary and 4294950190 or 4280229922, -- 19
			borderColor = props.primary and 4294958435 or 4281940797, -- 19
			shadow = props.primary -- 19
		}), -- 19
		React.createElement("label", { -- 19
			x = props.width / 2, -- 19
			y = height / 2, -- 19
			renderOrder = 0, -- 19
			fontName = "sarasa-mono-sc-regular", -- 19
			fontSize = props.fontSize or 17, -- 19
			text = props.text, -- 19
			color3 = props.primary and 1512202 or 16052712 -- 19
		}) -- 19
	) -- 19
end -- 17
return ____exports -- 17