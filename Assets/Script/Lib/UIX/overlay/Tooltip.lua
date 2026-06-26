-- [tsx]: Tooltip.tsx
local ____exports = {} -- 1
local ____DoraX = require("DoraX") -- 2
local React = ____DoraX.React -- 2
local ____context = require("UIX.context") -- 3
local getUiContext = ____context.getUiContext -- 3
local ____Text = require("UIX.foundation.Text") -- 4
local Text = ____Text.Text -- 4
local wrapTextLines = ____Text.wrapTextLines -- 4
local ____Column = require("UIX.layout.Column") -- 5
local Column = ____Column.Column -- 5
local ____PaintNode = require("UIX.paint.PaintNode") -- 6
local PaintNode = ____PaintNode.PaintNode -- 6
local ____primitives = require("UIX.paint.primitives") -- 7
local roundedPanel = ____primitives.roundedPanel -- 7
local ____helpers = require("UIX.layout.helpers") -- 8
local mergeStyle = ____helpers.mergeStyle -- 8
function ____exports.Tooltip(props) -- 17
	local theme = getUiContext().theme -- 18
	local width = props.width or 220 -- 19
	local hasTitle = props.title ~= nil and props.title ~= "" -- 20
	local textFontSize = theme.font.size.sm -- 21
	local textLineHeight = textFontSize * 1.25 -- 22
	local textWidth = width - theme.space.md * 2 -- 23
	local textLines = props.text ~= nil and wrapTextLines(props.text, textWidth, textFontSize) or ({}) -- 24
	local textHeight = props.text ~= nil and math.max(textLineHeight, #textLines * textLineHeight) or 0 -- 25
	local ____React_createElement_7 = React.createElement -- 25
	local ____temp_5 = { -- 25
		key = props.key, -- 25
		ref = props.ref, -- 25
		style = mergeStyle({ -- 25
			position = "absolute", -- 31
			width = width, -- 32
			height = (hasTitle and 30 or 0) + textHeight + theme.space.md * 2, -- 33
			padding = theme.space.md, -- 34
			gap = theme.space.xs -- 35
		}, props.style), -- 35
		visible = props.visible, -- 35
		opacity = props.opacity, -- 35
		touchEnabled = false -- 35
	} -- 35
	local ____React_createElement_result_6 = React.createElement( -- 35
		PaintNode, -- 41
		{painter = function(ctx) return roundedPanel(ctx, {x = 0, y = 0, width = ctx.width, height = ctx.height}, {variant = "solid", radius = theme.radius.sm}) end} -- 41
	) -- 41
	local ____React_createElement_4 = React.createElement -- 41
	local ____Column_2 = Column -- 45
	local ____temp_3 = {style = {width = "100%", height = "100%", gap = theme.space.xs}} -- 45
	local ____hasTitle_0 -- 46
	if hasTitle then -- 46
		____hasTitle_0 = React.createElement(Text, {text = props.title, fontSize = theme.font.size.md, color = theme.colors.text.primary, style = {width = "100%", height = 26}}) -- 46
	else -- 46
		____hasTitle_0 = nil -- 47
	end -- 47
	local ____temp_1 -- 48
	if props.text ~= nil then -- 48
		____temp_1 = React.createElement( -- 48
			Text, -- 49
			{ -- 49
				text = props.text, -- 49
				fontSize = textFontSize, -- 49
				lineHeight = textLineHeight, -- 49
				wrap = true, -- 49
				alignment = "Left", -- 49
				color = theme.colors.text.secondary, -- 49
				style = { -- 49
					width = "100%", -- 56
					height = math.max(textLineHeight, textHeight) -- 56
				} -- 56
			} -- 56
		) -- 56
	else -- 56
		____temp_1 = nil -- 57
	end -- 57
	return ____React_createElement_7( -- 26
		"align-node", -- 26
		____temp_5, -- 26
		____React_createElement_result_6, -- 26
		____React_createElement_4( -- 26
			____Column_2, -- 45
			____temp_3, -- 45
			____hasTitle_0, -- 45
			____temp_1, -- 45
			props.children -- 58
		) -- 58
	) -- 58
end -- 17
return ____exports -- 17