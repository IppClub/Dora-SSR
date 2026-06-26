-- [tsx]: Toggle.tsx
local ____exports = {} -- 1
local ____DoraX = require("DoraX") -- 1
local React = ____DoraX.React -- 1
local ____Dora = require("Dora") -- 2
local Color = ____Dora.Color -- 2
local nvg = require("nvg") -- 3
local ____context = require("UIX.context") -- 4
local getUiContext = ____context.getUiContext -- 4
local ____Text = require("UIX.foundation.Text") -- 5
local Text = ____Text.Text -- 5
local ____FocusRing = require("UIX.foundation.FocusRing") -- 6
local FocusRing = ____FocusRing.FocusRing -- 6
local ____Row = require("UIX.layout.Row") -- 7
local Row = ____Row.Row -- 7
local ____PaintNode = require("UIX.paint.PaintNode") -- 8
local PaintNode = ____PaintNode.PaintNode -- 8
local ____Interaction = require("UIX.input.Interaction") -- 9
local useInteraction = ____Interaction.useInteraction -- 9
local ____color = require("UIX.paint.color") -- 11
local withAlpha = ____color.withAlpha -- 11
local ____helpers = require("UIX.layout.helpers") -- 12
local mergeStyle = ____helpers.mergeStyle -- 12
local function togglePainter(checked) -- 21
	return function(ctx) -- 22
		local theme = ctx.theme -- 23
		local disabled = ctx.state.disabled -- 24
		local w = ctx.width -- 25
		local h = ctx.height -- 26
		local radius = h * 0.5 -- 27
		local fill = disabled and withAlpha(theme.colors.surface.sunken, theme.painter.disabledAlpha) or (checked and withAlpha(theme.colors.accent.primary, 0.88) or theme.colors.surface.sunken) -- 28
		local stroke = checked and theme.colors.accent.primary or theme.colors.line.normal -- 31
		nvg.BeginPath() -- 32
		nvg.RoundedRect( -- 33
			0, -- 33
			0, -- 33
			w, -- 33
			h, -- 33
			radius -- 33
		) -- 33
		nvg.FillColor(Color(withAlpha(fill, ctx.opacity))) -- 34
		nvg.Fill() -- 35
		nvg.StrokeWidth(theme.stroke.hairline) -- 36
		nvg.StrokeColor(Color(withAlpha(stroke, disabled and 0.45 or ctx.opacity))) -- 37
		nvg.Stroke() -- 38
		local knobSize = h - 8 -- 39
		local knobX = checked and w - knobSize - 4 or 4 -- 40
		nvg.BeginPath() -- 41
		nvg.Circle(knobX + knobSize * 0.5, h * 0.5, knobSize * 0.5) -- 42
		nvg.FillColor(Color(withAlpha(disabled and theme.colors.text.disabled or theme.colors.text.primary, ctx.opacity))) -- 43
		nvg.Fill() -- 44
	end -- 22
end -- 21
function ____exports.Toggle(props) -- 48
	local theme = getUiContext().theme -- 49
	local interaction = useInteraction({disabled = props.disabled}) -- 50
	if props.focused == true and not interaction.state.focused then -- 50
		interaction.setFocused(true) -- 52
	end -- 52
	local disabled = props.disabled == true -- 54
	local control = React.createElement( -- 55
		"align-node", -- 55
		{ -- 55
			ref = props.ref, -- 55
			style = {position = "relative", width = 54, height = 30}, -- 55
			touchEnabled = not disabled, -- 55
			swallowTouches = true, -- 55
			onTapBegan = function() return interaction.setPressed(true) end, -- 55
			onTapEnded = function() return interaction.setPressed(false) end, -- 55
			onTapped = function() -- 55
				if not disabled then -- 55
					local ____opt_0 = props.onChange -- 55
					if ____opt_0 ~= nil then -- 55
						____opt_0(not props.checked) -- 64
					end -- 64
				end -- 64
			end, -- 63
			onUnmount = function() return interaction.reset() end -- 63
		}, -- 63
		React.createElement( -- 63
			PaintNode, -- 68
			{ -- 68
				state = interaction.state, -- 68
				painter = togglePainter(props.checked) -- 68
			} -- 68
		), -- 68
		React.createElement(FocusRing, {active = interaction.state.focused, disabled = disabled}) -- 68
	) -- 68
	local ____React_createElement_5 = React.createElement -- 68
	local ____Row_3 = Row -- 73
	local ____temp_4 = { -- 73
		key = props.key, -- 73
		style = mergeStyle({height = theme.size.control.sm, alignItems = "center", gap = theme.space.sm}, props.style), -- 73
		visible = props.visible, -- 73
		opacity = props.opacity -- 73
	} -- 73
	local ____temp_2 -- 80
	if props.label ~= nil then -- 80
		____temp_2 = React.createElement(Text, {text = props.label, fontSize = theme.font.size.sm, color = disabled and theme.colors.text.disabled or theme.colors.text.primary}) -- 80
	else -- 80
		____temp_2 = nil -- 81
	end -- 81
	return ____React_createElement_5(____Row_3, ____temp_4, control, ____temp_2) -- 72
end -- 48
return ____exports -- 48