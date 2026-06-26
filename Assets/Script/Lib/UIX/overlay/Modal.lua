-- [tsx]: Modal.tsx
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local App = ____Dora.App -- 1
local Color = ____Dora.Color -- 1
local ____DoraX = require("DoraX") -- 3
local React = ____DoraX.React -- 3
local useRef = ____DoraX.useRef -- 3
local nvg = require("nvg") -- 4
local ____Button = require("UIX.controls.Button") -- 5
local Button = ____Button.Button -- 5
local ____context = require("UIX.context") -- 6
local getUiContext = ____context.getUiContext -- 6
local ____Text = require("UIX.foundation.Text") -- 7
local Text = ____Text.Text -- 7
local ____Column = require("UIX.layout.Column") -- 8
local Column = ____Column.Column -- 8
local ____Row = require("UIX.layout.Row") -- 9
local Row = ____Row.Row -- 9
local ____Panel = require("UIX.layout.Panel") -- 10
local Panel = ____Panel.Panel -- 10
local ____color = require("UIX.paint.color") -- 11
local withAlpha = ____color.withAlpha -- 11
local ____PaintNode = require("UIX.paint.PaintNode") -- 12
local PaintNode = ____PaintNode.PaintNode -- 12
function ____exports.Modal(props) -- 36
	local internalRef = useRef() -- 37
	if not props.open then -- 37
		return {} -- 38
	end -- 38
	local theme = getUiContext().theme -- 39
	local rootRef = props.ref or internalRef -- 40
	local width = props.width or 320 -- 41
	local height = props.height or 188 -- 42
	local screen = App.visualSize -- 43
	local backdropColor = props.backdropColor or 4278190080 -- 44
	local backdropOpacity = props.backdropOpacity or 0.58 -- 45
	local actions = props.actions or ({}) -- 46
	local messageHeight = props.message ~= nil and 34 or 0 -- 47
	local bodyHeight = props.children ~= nil and theme.size.control.sm or 0 -- 48
	local actionsHeight = #actions > 0 and theme.size.control.md or 0 -- 49
	local ____React_createElement_17 = React.createElement -- 49
	local ____temp_15 = { -- 49
		key = props.key, -- 49
		ref = rootRef, -- 49
		windowRoot = true, -- 49
		order = props.order or 10000, -- 49
		renderOrder = props.renderOrder, -- 49
		style = {width = screen.width, height = screen.height, alignItems = "center", justifyContent = "center"}, -- 49
		visible = props.visible, -- 49
		opacity = props.opacity, -- 49
		touchEnabled = true, -- 49
		swallowTouches = true, -- 49
		onTapped = function() -- 49
			if props.closeOnBackdrop ~= false then -- 49
				local ____opt_0 = props.onClose -- 49
				if ____opt_0 ~= nil then -- 49
					____opt_0() -- 68
				end -- 68
			end -- 68
		end -- 67
	} -- 67
	local ____React_createElement_result_16 = React.createElement( -- 67
		"align-node", -- 67
		{ -- 67
			key = "__uix_modal_backdrop", -- 67
			order = 0, -- 67
			renderOrder = 0, -- 67
			style = { -- 67
				position = "absolute", -- 76
				left = 0, -- 77
				top = 0, -- 78
				width = screen.width, -- 79
				height = screen.height -- 80
			}, -- 80
			touchEnabled = false -- 80
		}, -- 80
		React.createElement( -- 80
			PaintNode, -- 84
			{ -- 84
				key = "__uix_modal_backdrop_paint", -- 84
				painter = function(ctx) -- 84
					nvg.BeginPath() -- 87
					nvg.Rect(0, 0, ctx.width, ctx.height) -- 88
					nvg.FillColor(Color(withAlpha(backdropColor, backdropOpacity * (props.opacity or 1)))) -- 89
					nvg.Fill() -- 90
				end -- 86
			} -- 86
		) -- 86
	) -- 86
	local ____React_createElement_14 = React.createElement -- 86
	local ____temp_13 = { -- 86
		key = "__uix_modal_panel", -- 86
		order = 10, -- 86
		renderOrder = 10, -- 86
		style = {width = width, height = height}, -- 86
		touchEnabled = true, -- 86
		swallowTouches = true -- 86
	} -- 86
	local ____React_createElement_12 = React.createElement -- 86
	local ____Panel_10 = Panel -- 102
	local ____temp_11 = { -- 102
		title = props.title, -- 102
		variant = "solid", -- 102
		padding = theme.space.lg, -- 102
		headerHeight = props.title ~= nil and 34 or 0, -- 102
		style = {width = width, height = height} -- 102
	} -- 102
	local ____React_createElement_9 = React.createElement -- 102
	local ____Column_7 = Column -- 109
	local ____temp_8 = {style = {width = "100%", height = "100%", gap = theme.space.sm}} -- 109
	local ____temp_2 -- 110
	if props.message ~= nil then -- 110
		____temp_2 = React.createElement(Text, {text = props.message, fontSize = theme.font.size.sm, color = theme.colors.text.secondary, style = {width = "100%", height = messageHeight}}) -- 110
	else -- 110
		____temp_2 = nil -- 111
	end -- 111
	local ____temp_3 -- 112
	if bodyHeight > 0 then -- 112
		____temp_3 = React.createElement("align-node", {style = {width = "100%", height = bodyHeight, alignItems = "center", justifyContent = "center"}}, props.children) -- 112
	else -- 112
		____temp_3 = nil -- 115
	end -- 115
	local ____temp_6 -- 116
	if #actions > 0 then -- 116
		____temp_6 = React.createElement( -- 116
			Row, -- 117
			{gap = theme.space.sm, style = {width = "100%", height = actionsHeight, justifyContent = "center", alignItems = "center"}}, -- 117
			__TS__ArrayMap( -- 118
				actions, -- 118
				function(____, action) return React.createElement( -- 118
					Button, -- 119
					{ -- 119
						key = action.id, -- 119
						variant = action.variant or "secondary", -- 119
						disabled = action.disabled, -- 119
						style = {width = 96}, -- 119
						onClick = function() -- 119
							local ____opt_4 = props.onAction -- 119
							return ____opt_4 and ____opt_4(action.id) -- 124
						end -- 124
					}, -- 124
					action.label -- 126
				) end -- 126
			) -- 126
		) -- 126
	else -- 126
		____temp_6 = nil -- 129
	end -- 129
	return ____React_createElement_17( -- 50
		"align-node", -- 50
		____temp_15, -- 50
		____React_createElement_result_16, -- 50
		____React_createElement_14( -- 50
			"align-node", -- 50
			____temp_13, -- 50
			____React_createElement_12( -- 50
				____Panel_10, -- 102
				____temp_11, -- 102
				____React_createElement_9( -- 102
					____Column_7, -- 109
					____temp_8, -- 109
					____temp_2, -- 109
					____temp_3, -- 109
					____temp_6 -- 109
				) -- 109
			) -- 109
		) -- 109
	) -- 109
end -- 36
return ____exports -- 36