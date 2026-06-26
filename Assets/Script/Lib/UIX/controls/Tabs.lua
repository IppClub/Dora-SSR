-- [tsx]: Tabs.tsx
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local ____exports = {} -- 1
local ____DoraX = require("DoraX") -- 1
local React = ____DoraX.React -- 1
local ____Button = require("UIX.controls.Button") -- 2
local Button = ____Button.Button -- 2
local ____Row = require("UIX.layout.Row") -- 3
local Row = ____Row.Row -- 3
local ____context = require("UIX.context") -- 4
local getUiContext = ____context.getUiContext -- 4
local ____helpers = require("UIX.layout.helpers") -- 5
local mergeStyle = ____helpers.mergeStyle -- 5
function ____exports.Tabs(props) -- 20
	local theme = getUiContext().theme -- 21
	return React.createElement( -- 22
		Row, -- 23
		{ -- 23
			key = props.key, -- 23
			ref = props.ref, -- 23
			gap = theme.space.xs, -- 23
			style = mergeStyle({height = theme.size.control.md, alignItems = "center"}, props.style), -- 23
			visible = props.visible, -- 23
			opacity = props.opacity -- 23
		}, -- 23
		__TS__ArrayMap( -- 34
			props.items, -- 34
			function(____, item) return React.createElement( -- 34
				Button, -- 35
				{ -- 35
					key = item.id, -- 35
					size = "sm", -- 35
					variant = item.id == props.value and "primary" or "ghost", -- 35
					selected = item.id == props.value, -- 35
					disabled = props.disabled == true or item.disabled == true, -- 35
					style = {minWidth = 72}, -- 35
					onClick = function() -- 35
						if item.id ~= props.value then -- 35
							local ____opt_0 = props.onValueChange -- 35
							if ____opt_0 ~= nil then -- 35
								____opt_0(item.id) -- 43
							end -- 43
						end -- 43
					end -- 42
				}, -- 42
				item.label -- 46
			) end -- 46
		) -- 46
	) -- 46
end -- 20
return ____exports -- 20