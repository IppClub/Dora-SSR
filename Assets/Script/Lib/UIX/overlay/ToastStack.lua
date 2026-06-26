-- [tsx]: ToastStack.tsx
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local ____exports = {} -- 1
local ____DoraX = require("DoraX") -- 1
local React = ____DoraX.React -- 1
local ____context = require("UIX.context") -- 2
local getUiContext = ____context.getUiContext -- 2
local ____Text = require("UIX.foundation.Text") -- 3
local Text = ____Text.Text -- 3
local ____Column = require("UIX.layout.Column") -- 4
local Column = ____Column.Column -- 4
local ____Panel = require("UIX.layout.Panel") -- 5
local Panel = ____Panel.Panel -- 5
local ____helpers = require("UIX.layout.helpers") -- 7
local mergeStyle = ____helpers.mergeStyle -- 7
function ____exports.ToastStack(props) -- 22
	local theme = getUiContext().theme -- 23
	local width = props.width or 280 -- 24
	local maxVisible = props.maxVisible or 4 -- 25
	local items = {} -- 26
	for i = 1, math.min(#props.items, maxVisible) do -- 26
		items[#items + 1] = props.items[i] -- 28
	end -- 28
	return React.createElement( -- 30
		Column, -- 31
		{ -- 31
			key = props.key, -- 31
			ref = props.ref, -- 31
			gap = theme.space.sm, -- 31
			style = mergeStyle({position = "absolute", right = theme.space.lg, top = theme.space.lg, width = width}, props.style), -- 31
			visible = props.visible, -- 31
			opacity = props.opacity -- 31
		}, -- 31
		__TS__ArrayMap( -- 44
			items, -- 44
			function(____, item) -- 44
				local ____React_createElement_6 = React.createElement -- 44
				local ____Panel_4 = Panel -- 45
				local ____temp_5 = { -- 45
					key = item.id, -- 45
					variant = item.variant == "glass" and "glass" or "solid", -- 45
					padding = theme.space.sm, -- 45
					headerHeight = 0, -- 45
					style = {width = width, minHeight = item.title ~= nil and 72 or 52} -- 45
				} -- 45
				local ____React_createElement_3 = React.createElement -- 45
				local ____Column_1 = Column -- 52
				local ____temp_2 = {style = {width = "100%", gap = theme.space.xs}} -- 52
				local ____temp_0 -- 53
				if item.title ~= nil then -- 53
					____temp_0 = React.createElement(Text, {text = item.title, fontSize = theme.font.size.sm, color = theme.colors.text.primary, style = {width = "100%", height = 20}}) -- 53
				else -- 53
					____temp_0 = nil -- 54
				end -- 54
				return ____React_createElement_6( -- 44
					____Panel_4, -- 45
					____temp_5, -- 45
					____React_createElement_3( -- 45
						____Column_1, -- 52
						____temp_2, -- 52
						____temp_0, -- 52
						React.createElement(Text, {text = item.message, fontSize = theme.font.size.sm, color = theme.colors.text.secondary, style = {width = "100%", height = 24}}) -- 52
					) -- 52
				) -- 52
			end -- 44
		) -- 44
	) -- 44
end -- 22
return ____exports -- 22