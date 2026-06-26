-- [tsx]: Slider.tsx
local ____exports = {} -- 1
local ____DoraX = require("DoraX") -- 1
local React = ____DoraX.React -- 1
local ____Dora = require("Dora") -- 2
local Color = ____Dora.Color -- 2
local nvg = require("nvg") -- 4
local ____PaintNode = require("UIX.paint.PaintNode") -- 5
local PaintNode = ____PaintNode.PaintNode -- 5
local ____types = require("UIX.types") -- 6
local clamp = ____types.clamp -- 6
local ____helpers = require("UIX.layout.helpers") -- 7
local mergeStyle = ____helpers.mergeStyle -- 7
local ____color = require("UIX.paint.color") -- 8
local withAlpha = ____color.withAlpha -- 8
local sliderFontId = 0 -- 20
local function valueFromTouch(touch, width, min, max, step) -- 22
	if touch == nil then -- 22
		return nil -- 23
	end -- 23
	local raw = min + clamp( -- 24
		touch.location.x / math.max(1, width), -- 24
		0, -- 24
		1 -- 24
	) * (max - min) -- 24
	if step ~= nil and step > 0 then -- 24
		return min + math.floor((raw - min) / step + 0.5) * step -- 26
	end -- 26
	return raw -- 28
end -- 22
function ____exports.Slider(props) -- 31
	local min = props.min or 0 -- 32
	local max = props.max or 1 -- 33
	local value = clamp(props.value, min, max) -- 34
	local progress = max == min and 0 or (value - min) / (max - min) -- 35
	local disabled = props.disabled == true -- 36
	local valueWidth = props.showValue == true and (props.valueWidth or 42) or 0 -- 37
	local width = 160 -- 38
	local function emitFromTouch(touch) -- 39
		if disabled then -- 39
			return -- 40
		end -- 40
		local next = valueFromTouch( -- 41
			touch, -- 41
			math.max(1, width - valueWidth), -- 41
			min, -- 41
			max, -- 41
			props.step -- 41
		) -- 41
		if next ~= nil then -- 41
			local ____opt_0 = props.onValueChange -- 41
			if ____opt_0 ~= nil then -- 41
				____opt_0(clamp(next, min, max)) -- 42
			end -- 42
		end -- 42
	end -- 39
	return React.createElement( -- 44
		"align-node", -- 44
		{ -- 44
			key = props.key, -- 44
			ref = props.ref, -- 44
			style = mergeStyle({position = "relative", width = width, height = 32, minWidth = 96}, props.style), -- 44
			visible = props.visible, -- 44
			opacity = props.opacity, -- 44
			touchEnabled = not disabled, -- 44
			swallowTouches = true, -- 44
			onLayout = function(w) -- 44
				width = w -- 58
				return width -- 58
			end, -- 58
			onTapBegan = emitFromTouch, -- 58
			onTapMoved = emitFromTouch, -- 58
			onTapped = emitFromTouch -- 58
		}, -- 58
		React.createElement( -- 58
			PaintNode, -- 63
			{ -- 63
				state = {disabled = disabled}, -- 63
				painter = function(ctx) -- 63
					local theme = ctx.theme -- 66
					local trackH = 6 -- 67
					local y = ctx.height * 0.5 - trackH * 0.5 -- 68
					local radius = trackH * 0.5 -- 69
					local trackWidth = math.max(trackH, ctx.width - valueWidth) -- 70
					nvg.BeginPath() -- 71
					nvg.RoundedRect( -- 72
						0, -- 72
						y, -- 72
						trackWidth, -- 72
						trackH, -- 72
						radius -- 72
					) -- 72
					nvg.FillColor(Color(withAlpha(theme.colors.surface.sunken, ctx.opacity))) -- 73
					nvg.Fill() -- 74
					nvg.BeginPath() -- 75
					nvg.RoundedRect( -- 76
						0, -- 76
						y, -- 76
						math.max(trackH, trackWidth * progress), -- 76
						trackH, -- 76
						radius -- 76
					) -- 76
					nvg.FillColor(Color(withAlpha(disabled and theme.colors.text.disabled or theme.colors.accent.primary, ctx.opacity))) -- 77
					nvg.Fill() -- 78
					local knobX = clamp(trackWidth * progress, 8, trackWidth - 8) -- 79
					nvg.BeginPath() -- 80
					nvg.Circle(knobX, ctx.height * 0.5, 8) -- 81
					nvg.FillColor(Color(withAlpha(disabled and theme.colors.text.disabled or theme.colors.text.primary, ctx.opacity))) -- 82
					nvg.Fill() -- 83
					if props.showValue == true then -- 83
						if sliderFontId == 0 then -- 83
							sliderFontId = nvg.CreateFont(theme.font.name) -- 85
						end -- 85
						nvg.FontFaceId(sliderFontId) -- 86
						nvg.FontSize(theme.font.size.xs) -- 87
						nvg.TextAlign("Right", "Middle") -- 88
						nvg.FillColor(Color(theme.colors.text.secondary)) -- 89
						nvg.Save() -- 90
						nvg.Scale(1, -1) -- 91
						nvg.Text( -- 92
							ctx.width, -- 92
							-ctx.height * 0.5, -- 92
							tostring(math.floor(value * 100) / 100) -- 92
						) -- 92
						nvg.Restore() -- 93
					end -- 93
				end -- 65
			} -- 65
		) -- 65
	) -- 65
end -- 31
return ____exports -- 31