-- [tsx]: ResourceCounter.tsx
local ____exports = {} -- 1
local ____DoraX = require("DoraX") -- 1
local React = ____DoraX.React -- 1
local ____context = require("UIX.context") -- 2
local getUiContext = ____context.getUiContext -- 2
local ____Icon = require("UIX.foundation.Icon") -- 3
local Icon = ____Icon.Icon -- 3
local ____Text = require("UIX.foundation.Text") -- 4
local Text = ____Text.Text -- 4
local ____Row = require("UIX.layout.Row") -- 5
local Row = ____Row.Row -- 5
local ____helpers = require("UIX.layout.helpers") -- 7
local mergeStyle = ____helpers.mergeStyle -- 7
function ____exports.ResourceCounter(props) -- 17
	local theme = getUiContext().theme -- 18
	local color = theme.colors.text.primary -- 19
	if props.variant == "warm" then -- 19
		color = theme.colors.accent.warm -- 20
	end -- 20
	if props.variant == "success" then -- 20
		color = theme.colors.state.success -- 21
	end -- 21
	if props.variant == "danger" then -- 21
		color = theme.colors.state.danger -- 22
	end -- 22
	local text = ((props.prefix or "") .. tostring(props.value)) .. (props.suffix or "") -- 23
	local ____React_createElement_3 = React.createElement -- 23
	local ____Row_1 = Row -- 25
	local ____temp_2 = { -- 25
		key = props.key, -- 25
		ref = props.ref, -- 25
		gap = theme.space.sm, -- 25
		align = "center", -- 25
		style = mergeStyle({height = theme.size.control.sm, padding = {0, theme.space.sm}}, props.style), -- 25
		visible = props.visible, -- 25
		opacity = props.opacity -- 25
	} -- 25
	local ____temp_0 -- 37
	if props.icon ~= nil then -- 37
		____temp_0 = React.createElement(Icon, {icon = props.icon, size = theme.size.icon.sm, color = color}) -- 37
	else -- 37
		____temp_0 = nil -- 37
	end -- 37
	return ____React_createElement_3( -- 24
		____Row_1, -- 25
		____temp_2, -- 25
		____temp_0, -- 25
		React.createElement(Text, {text = text, color = color, fontSize = theme.font.size.md}) -- 25
	) -- 25
end -- 17
return ____exports -- 17