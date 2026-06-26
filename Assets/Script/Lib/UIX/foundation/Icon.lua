-- [tsx]: Icon.tsx
local ____exports = {} -- 1
local ____DoraX = require("DoraX") -- 1
local React = ____DoraX.React -- 1
local ____context = require("UIX.context") -- 2
local getUiContext = ____context.getUiContext -- 2
local ____PaintNode = require("UIX.paint.PaintNode") -- 3
local PaintNode = ____PaintNode.PaintNode -- 3
local ____icons = require("UIX.paint.icons") -- 4
local drawIcon = ____icons.drawIcon -- 4
function ____exports.Icon(props) -- 14
	local theme = getUiContext().theme -- 15
	local size = props.size or theme.size.icon.md -- 16
	local color = props.disabled == true and (props.disabledColor or theme.colors.text.disabled) or (props.color or theme.colors.text.primary) -- 17
	if type(props.icon) == "table" and props.icon.kind == "sprite" then -- 17
		local icon = props.icon -- 19
		return React.createElement("sprite", { -- 20
			file = icon.file, -- 20
			width = size, -- 20
			height = size, -- 20
			color3 = color, -- 20
			opacity = props.opacity -- 20
		}) -- 20
	end -- 20
	local name = type(props.icon) == "string" and props.icon or props.icon.name -- 22
	return React.createElement( -- 23
		"align-node", -- 23
		{key = props.key, style = {width = size, height = size}}, -- 23
		React.createElement( -- 23
			PaintNode, -- 25
			{ -- 25
				key = "icon-paint", -- 25
				painter = function(ctx) return drawIcon(name, ctx, {x = 0, y = 0, width = ctx.width, height = ctx.height}, color) end, -- 25
				state = {disabled = props.disabled == true}, -- 25
				opacity = props.opacity -- 25
			} -- 25
		) -- 25
	) -- 25
end -- 14
return ____exports -- 14