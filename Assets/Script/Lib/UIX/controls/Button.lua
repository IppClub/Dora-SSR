-- [tsx]: Button.tsx
local ____exports = {} -- 1
local ____DoraX = require("DoraX") -- 2
local React = ____DoraX.React -- 2
local useRef = ____DoraX.useRef -- 2
local ____context = require("UIX.context") -- 3
local getUiContext = ____context.getUiContext -- 3
local ____Icon = require("UIX.foundation.Icon") -- 4
local Icon = ____Icon.Icon -- 4
local ____FocusRing = require("UIX.foundation.FocusRing") -- 5
local FocusRing = ____FocusRing.FocusRing -- 5
local ____Text = require("UIX.foundation.Text") -- 6
local Text = ____Text.Text -- 6
local ____Row = require("UIX.layout.Row") -- 7
local Row = ____Row.Row -- 7
local ____helpers = require("UIX.layout.helpers") -- 8
local mergeStyle = ____helpers.mergeStyle -- 8
local textFromChildren = ____helpers.textFromChildren -- 8
local ____PaintNode = require("UIX.paint.PaintNode") -- 9
local PaintNode = ____PaintNode.PaintNode -- 9
local ____primitives = require("UIX.paint.primitives") -- 10
local buttonSurface = ____primitives.buttonSurface -- 10
local ____Interaction = require("UIX.input.Interaction") -- 11
local useInteraction = ____Interaction.useInteraction -- 11
function ____exports.Button(props) -- 27
	local ui = getUiContext() -- 28
	local theme = ui.theme -- 29
	local size = props.size or "md" -- 30
	local height = theme.size.control[size] -- 31
	local interaction = useInteraction({disabled = props.disabled, loading = props.loading, selected = props.selected}) -- 32
	local tapMoveDistance = useRef(0) -- 37
	local tapCancelled = useRef(false) -- 38
	if props.focused == true and not interaction.state.focused then -- 38
		interaction.setFocused(true) -- 40
	end -- 40
	local disabled = props.disabled == true or props.loading == true -- 42
	local text = textFromChildren(props.children) -- 43
	local ____temp_0 -- 44
	if text == "" then -- 44
		____temp_0 = props.children -- 44
	else -- 44
		____temp_0 = nil -- 44
	end -- 44
	local overlayChildren = ____temp_0 -- 44
	local iconSize = theme.size.icon[size] -- 45
	local ____React_createElement_6 = React.createElement -- 45
	local ____Row_4 = Row -- 47
	local ____temp_5 = {style = { -- 47
		width = "100%", -- 49
		height = "100%", -- 50
		padding = {0, theme.space.md}, -- 51
		alignItems = "center", -- 52
		justifyContent = "center", -- 53
		gap = theme.space.sm -- 54
	}} -- 54
	local ____temp_1 -- 57
	if props.icon ~= nil and props.iconPosition ~= "right" then -- 57
		____temp_1 = React.createElement(Icon, {icon = props.icon, size = iconSize, disabled = disabled, color = disabled and theme.colors.text.disabled or theme.colors.text.primary}) -- 57
	else -- 57
		____temp_1 = nil -- 58
	end -- 58
	local ____temp_2 -- 59
	if text ~= "" then -- 59
		____temp_2 = React.createElement(Text, {text = props.loading == true and "..." or text, fontSize = theme.font.size.md, color = disabled and theme.colors.text.disabled or theme.colors.text.primary}) -- 59
	else -- 59
		____temp_2 = nil -- 60
	end -- 60
	local ____temp_3 -- 61
	if props.icon ~= nil and props.iconPosition == "right" then -- 61
		____temp_3 = React.createElement(Icon, {icon = props.icon, size = iconSize, disabled = disabled, color = disabled and theme.colors.text.disabled or theme.colors.text.primary}) -- 61
	else -- 61
		____temp_3 = nil -- 62
	end -- 62
	local content = ____React_createElement_6( -- 46
		____Row_4, -- 47
		____temp_5, -- 47
		____temp_1, -- 47
		____temp_2, -- 47
		____temp_3 -- 47
	) -- 47
	local ____React_createElement_19 = React.createElement -- 47
	local ____props_key_10 = props.key -- 67
	local ____props_ref_11 = props.ref -- 68
	local ____mergeStyle_result_12 = mergeStyle({ -- 69
		position = "relative", -- 70
		height = height, -- 71
		minWidth = height, -- 72
		alignItems = "center", -- 73
		justifyContent = "center" -- 74
	}, props.style) -- 74
	local ____props_visible_13 = props.visible -- 76
	local ____props_opacity_14 = props.opacity -- 77
	local ____temp_15 = not disabled -- 78
	local ____props_swallowTouches_7 = props.swallowTouches -- 79
	if ____props_swallowTouches_7 == nil then -- 79
		____props_swallowTouches_7 = true -- 79
	end -- 79
	local ____temp_17 = { -- 79
		key = ____props_key_10, -- 79
		ref = ____props_ref_11, -- 79
		style = ____mergeStyle_result_12, -- 79
		visible = ____props_visible_13, -- 79
		opacity = ____props_opacity_14, -- 79
		touchEnabled = ____temp_15, -- 79
		swallowTouches = ____props_swallowTouches_7, -- 79
		onTapBegan = function() -- 79
			tapMoveDistance.current = 0 -- 81
			tapCancelled.current = false -- 82
			interaction.setPressed(true) -- 83
		end, -- 80
		onTapMoved = function(touch) -- 80
			local nextDistance = (tapMoveDistance.current or 0) + touch.delta.length -- 86
			tapMoveDistance.current = nextDistance -- 87
			if nextDistance > 10 then -- 87
				tapCancelled.current = true -- 89
				interaction.setPressed(false) -- 90
			end -- 90
		end, -- 85
		onTapEnded = function() return interaction.setPressed(false) end, -- 85
		onTapped = function() -- 85
			if not disabled and not tapCancelled.current then -- 85
				local ____opt_8 = props.onClick -- 85
				if ____opt_8 ~= nil then -- 85
					____opt_8() -- 95
				end -- 95
			end -- 95
			tapCancelled.current = false -- 96
		end, -- 94
		onUnmount = function() return interaction.reset() end -- 94
	} -- 94
	local ____React_createElement_result_18 = React.createElement( -- 94
		PaintNode, -- 100
		{ -- 100
			key = "button-surface", -- 100
			state = interaction.state, -- 100
			painter = function(ctx) return buttonSurface(ctx, {x = 0, y = 0, width = ctx.width, height = ctx.height}, {variant = props.variant or "primary"}) end -- 100
		} -- 100
	) -- 100
	local ____temp_16 -- 108
	if overlayChildren ~= nil then -- 108
		____temp_16 = React.createElement("align-node", {style = { -- 108
			position = "absolute", -- 111
			left = 0, -- 112
			right = 0, -- 113
			top = 0, -- 114
			bottom = 0, -- 115
			alignItems = "center", -- 116
			justifyContent = "center" -- 117
		}}, overlayChildren) -- 117
	else -- 117
		____temp_16 = nil -- 121
	end -- 121
	return ____React_createElement_19( -- 65
		"align-node", -- 65
		____temp_17, -- 65
		____React_createElement_result_18, -- 65
		content, -- 107
		____temp_16, -- 107
		React.createElement(FocusRing, {key = "button-focus-ring", active = interaction.state.focused, disabled = disabled}) -- 107
	) -- 107
end -- 27
return ____exports -- 27