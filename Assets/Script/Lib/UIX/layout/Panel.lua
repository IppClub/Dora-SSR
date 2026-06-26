-- [tsx]: Panel.tsx
local ____lualib = require("lualib_bundle") -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local ____exports = {} -- 1
local ____DoraX = require("DoraX") -- 1
local React = ____DoraX.React -- 1
local ____context = require("UIX.context") -- 2
local getUiContext = ____context.getUiContext -- 2
local ____PaintNode = require("UIX.paint.PaintNode") -- 3
local PaintNode = ____PaintNode.PaintNode -- 3
local ____primitives = require("UIX.paint.primitives") -- 4
local roundedPanel = ____primitives.roundedPanel -- 4
local ____Column = require("UIX.layout.Column") -- 5
local Column = ____Column.Column -- 5
local ____Box = require("UIX.layout.Box") -- 6
local Box = ____Box.Box -- 6
local ____ScrollView = require("UIX.layout.ScrollView") -- 7
local ScrollView = ____ScrollView.ScrollView -- 7
local ____Text = require("UIX.foundation.Text") -- 8
local Text = ____Text.Text -- 8
local ____helpers = require("UIX.layout.helpers") -- 10
local mergeStyle = ____helpers.mergeStyle -- 10
function ____exports.Panel(props) -- 25
	local theme = getUiContext().theme -- 26
	local headerHeight = props.headerHeight or (props.title ~= nil and 36 or 0) -- 27
	local padding = props.padding or theme.space.lg -- 28
	local ____opt_0 = props.style -- 28
	local panelWidth = ____opt_0 and ____opt_0.width -- 29
	local ____opt_2 = props.style -- 29
	local panelHeight = ____opt_2 and ____opt_2.height -- 30
	local contentWidth = panelWidth ~= nil and math.max(0, panelWidth - padding * 2) or nil -- 31
	local contentHeight = panelHeight ~= nil and math.max(0, panelHeight - padding * 2 - headerHeight - (props.title ~= nil and theme.space.sm or 0)) or nil -- 32
	local scrollContentHeight = props.scrollContentHeight or contentHeight or 0 -- 35
	local ____React_createElement_7 = React.createElement -- 35
	local ____array_6 = __TS__SparseArrayNew( -- 35
		Column, -- 37
		{ -- 37
			key = props.key, -- 37
			ref = props.ref, -- 37
			style = mergeStyle({position = "relative", padding = padding, gap = theme.space.sm}, props.style), -- 37
			visible = props.visible, -- 37
			opacity = props.opacity, -- 37
			onLayout = props.onLayout -- 37
		}, -- 37
		React.createElement( -- 37
			PaintNode, -- 49
			{painter = function(ctx) return roundedPanel(ctx, {x = 0, y = 0, width = ctx.width, height = ctx.height}, {variant = props.variant or "default", elevated = props.elevated}) end} -- 49
		) -- 49
	) -- 49
	local ____temp_4 -- 55
	if props.title ~= nil then -- 55
		____temp_4 = React.createElement( -- 55
			Box, -- 56
			{key = "header", style = {height = headerHeight, alignItems = "center", justifyContent = "center"}}, -- 56
			React.createElement(Text, {text = props.title, fontSize = theme.font.size.lg, color = theme.colors.text.primary}) -- 56
		) -- 56
	else -- 56
		____temp_4 = nil -- 58
	end -- 58
	__TS__SparseArrayPush(____array_6, ____temp_4) -- 58
	local ____temp_5 -- 60
	if props.scroll == true and contentWidth ~= nil and contentHeight ~= nil then -- 60
		____temp_5 = React.createElement( -- 60
			ScrollView, -- 61
			{ -- 61
				key = "content-scroll", -- 61
				width = contentWidth, -- 61
				height = contentHeight, -- 61
				contentHeight = math.max(contentHeight, scrollContentHeight), -- 61
				wheelSpeed = props.scrollWheelSpeed, -- 61
				onScroll = props.onScroll, -- 61
				style = {flex = 1} -- 61
			}, -- 61
			props.children -- 70
		) -- 70
	else -- 70
		____temp_5 = React.createElement(Box, {key = "content", style = {flex = 1}}, props.children) -- 70
	end -- 70
	__TS__SparseArrayPush(____array_6, ____temp_5) -- 70
	return ____React_createElement_7(__TS__SparseArraySpread(____array_6)) -- 36
end -- 25
return ____exports -- 25