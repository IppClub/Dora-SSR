-- [tsx]: Controls.tsx
local ____exports = {} -- 1
local ____DoraX = require("DoraX") -- 1
local React = ____DoraX.React -- 1
local ____Dora = require("Dora") -- 2
local Vec2 = ____Dora.Vec2 -- 2
local function vertices(width, height, radius) -- 4
	if radius == nil then -- 4
		radius = 14 -- 4
	end -- 4
	local result = {} -- 5
	for ____, corner in ipairs({{x = width - radius, y = radius, start = -math.pi / 2}, {x = width - radius, y = height - radius, start = 0}, {x = radius, y = height - radius, start = math.pi / 2}, {x = radius, y = radius, start = math.pi}}) do -- 6
		do -- 6
			local i = 0 -- 7
			while i <= 6 do -- 7
				local angle = corner.start + i * math.pi / 12 -- 7
				result[#result + 1] = Vec2( -- 7
					corner.x + math.cos(angle) * radius, -- 7
					corner.y + math.sin(angle) * radius -- 7
				) -- 7
				i = i + 1 -- 7
			end -- 7
		end -- 7
	end -- 7
	return result -- 9
end -- 4
function ____exports.MobilePanelSurface(props) -- 11
	return React.createElement( -- 12
		"draw-node", -- 12
		{renderOrder = props.renderOrder}, -- 12
		React.createElement( -- 12
			"polygon-shape", -- 12
			{ -- 12
				verts = vertices(props.width, props.height, 24), -- 12
				fillColor = 4279968560, -- 12
				borderWidth = 1, -- 12
				borderColor = 4283061608 -- 12
			} -- 12
		) -- 12
	) -- 12
end -- 11
function ____exports.MobileButton(props) -- 14
	local height = props.height or 48 -- 15
	return React.createElement( -- 16
		"node", -- 16
		{ -- 16
			tag = props.tag, -- 16
			x = props.x, -- 16
			y = props.y, -- 16
			width = props.width, -- 16
			height = height, -- 16
			anchorX = 0, -- 16
			anchorY = 0, -- 16
			touchEnabled = true, -- 16
			swallowTouches = true, -- 16
			onTapped = props.onTapped -- 16
		}, -- 16
		React.createElement( -- 16
			"draw-node", -- 16
			{renderOrder = props.renderOrder}, -- 16
			React.createElement( -- 16
				"polygon-shape", -- 16
				{ -- 16
					verts = vertices(props.width, height), -- 16
					fillColor = props.primary and 4294954035 or 4280889664, -- 16
					borderWidth = 1, -- 16
					borderColor = props.primary and 4294958435 or 4283061608 -- 16
				} -- 16
			) -- 16
		), -- 16
		React.createElement("label", { -- 16
			x = props.width / 2, -- 16
			y = height / 2, -- 16
			renderOrder = 0, -- 16
			fontName = "sarasa-mono-sc-regular", -- 16
			fontSize = props.fontSize or 17, -- 16
			text = props.text, -- 16
			color3 = props.primary and 1512202 or 16052712 -- 16
		}) -- 16
	) -- 16
end -- 14
function ____exports.RoundedSurface(props) -- 22
	return React.createElement( -- 23
		"draw-node", -- 23
		nil, -- 23
		React.createElement( -- 23
			"polygon-shape", -- 23
			{ -- 23
				verts = vertices(props.width, props.height, props.radius), -- 23
				fillColor = props.topColor -- 23
			} -- 23
		) -- 23
	) -- 23
end -- 22
return ____exports -- 22