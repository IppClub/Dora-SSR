-- [tsx]: ItemSlot.tsx
local ____exports = {} -- 1
local ____DoraX = require("DoraX") -- 2
local React = ____DoraX.React -- 2
local useRef = ____DoraX.useRef -- 2
local ____context = require("UIX.context") -- 3
local getUiContext = ____context.getUiContext -- 3
local ____Icon = require("UIX.foundation.Icon") -- 4
local Icon = ____Icon.Icon -- 4
local ____Text = require("UIX.foundation.Text") -- 5
local Text = ____Text.Text -- 5
local ____PaintNode = require("UIX.paint.PaintNode") -- 6
local PaintNode = ____PaintNode.PaintNode -- 6
local ____Interaction = require("UIX.input.Interaction") -- 7
local useInteraction = ____Interaction.useInteraction -- 7
local ____types = require("UIX.types") -- 8
local clamp = ____types.clamp -- 8
local ____helpers = require("UIX.layout.helpers") -- 9
local mergeStyle = ____helpers.mergeStyle -- 9
local primitivePainters = require("UIX.paint.primitives") -- 25
function ____exports.ItemSlot(props) -- 39
	local theme = getUiContext().theme -- 40
	local interaction = useInteraction({disabled = props.disabled, selected = props.selected}) -- 41
	local tapMoveDistance = useRef(0) -- 45
	local tapCancelled = useRef(false) -- 46
	local ____opt_0 = props.style -- 46
	local size = ____opt_0 and ____opt_0.width or theme.size.control.lg -- 47
	local disabled = props.disabled == true -- 48
	local quality = props.icon == nil and "empty" or (props.quality or "common") -- 49
	local cooldownProgress = props.cooldown ~= nil and props.maxCooldown ~= nil and props.maxCooldown > 0 and clamp(props.cooldown / props.maxCooldown, 0, 1) or 0 -- 50
	local ____React_createElement_16 = React.createElement -- 50
	local ____props_key_5 = props.key -- 55
	local ____props_ref_6 = props.ref -- 56
	local ____mergeStyle_result_7 = mergeStyle({ -- 57
		position = "relative", -- 58
		width = size, -- 59
		height = size, -- 60
		alignItems = "center", -- 61
		justifyContent = "center" -- 62
	}, props.style) -- 62
	local ____props_visible_8 = props.visible -- 64
	local ____props_opacity_9 = props.opacity -- 65
	local ____temp_10 = not disabled and props.icon ~= nil -- 66
	local ____props_swallowTouches_2 = props.swallowTouches -- 67
	if ____props_swallowTouches_2 == nil then -- 67
		____props_swallowTouches_2 = true -- 67
	end -- 67
	local ____temp_14 = { -- 67
		key = ____props_key_5, -- 67
		ref = ____props_ref_6, -- 67
		style = ____mergeStyle_result_7, -- 67
		visible = ____props_visible_8, -- 67
		opacity = ____props_opacity_9, -- 67
		touchEnabled = ____temp_10, -- 67
		swallowTouches = ____props_swallowTouches_2, -- 67
		onTapBegan = function() -- 67
			tapMoveDistance.current = 0 -- 69
			tapCancelled.current = false -- 70
			interaction.setPressed(true) -- 71
		end, -- 68
		onTapMoved = function(touch) -- 68
			local nextDistance = (tapMoveDistance.current or 0) + touch.delta.length -- 74
			tapMoveDistance.current = nextDistance -- 75
			if nextDistance > 10 then -- 75
				tapCancelled.current = true -- 77
				interaction.setPressed(false) -- 78
			end -- 78
		end, -- 73
		onTapEnded = function() return interaction.setPressed(false) end, -- 73
		onTapped = function() -- 73
			if not disabled and props.icon ~= nil and not tapCancelled.current then -- 73
				local ____opt_3 = props.onClick -- 73
				if ____opt_3 ~= nil then -- 73
					____opt_3(props.id) -- 83
				end -- 83
			end -- 83
			tapCancelled.current = false -- 84
		end, -- 82
		onUnmount = function() return interaction.reset() end -- 82
	} -- 82
	local ____React_createElement_result_15 = React.createElement( -- 82
		PaintNode, -- 88
		{ -- 88
			key = "item-slot-surface", -- 88
			state = interaction.state, -- 88
			painter = function(ctx) return primitivePainters.itemSlotSurface(ctx, {x = 0, y = 0, width = ctx.width, height = ctx.height}, quality, props.selected) end -- 88
		} -- 88
	) -- 88
	local ____temp_11 -- 93
	if props.icon ~= nil then -- 93
		____temp_11 = React.createElement(Icon, {icon = props.icon, size = size * 0.44, disabled = disabled}) -- 93
	else -- 93
		____temp_11 = nil -- 94
	end -- 94
	local ____temp_12 -- 95
	if props.count ~= nil and props.count > 1 then -- 95
		____temp_12 = React.createElement(Text, {text = props.count, fontSize = theme.font.size.xs, color = disabled and theme.colors.text.disabled or theme.colors.text.primary, style = { -- 95
			position = "absolute", -- 100
			right = 4, -- 100
			bottom = 3, -- 100
			width = size * 0.5, -- 100
			height = 16 -- 100
		}}) -- 100
	else -- 100
		____temp_12 = nil -- 101
	end -- 101
	local ____temp_13 -- 102
	if cooldownProgress > 0 then -- 102
		____temp_13 = React.createElement( -- 102
			PaintNode, -- 103
			{ -- 103
				key = "item-slot-cooldown-mask", -- 103
				order = 10, -- 103
				renderOrder = 10, -- 103
				painter = function(ctx) return primitivePainters.cooldownMask(ctx, {x = 0, y = 0, width = ctx.width, height = ctx.height}, cooldownProgress) end -- 103
			} -- 103
		) -- 103
	else -- 103
		____temp_13 = nil -- 108
	end -- 108
	return ____React_createElement_16( -- 53
		"align-node", -- 53
		____temp_14, -- 53
		____React_createElement_result_15, -- 53
		____temp_11, -- 53
		____temp_12, -- 53
		____temp_13 -- 53
	) -- 53
end -- 39
return ____exports -- 39