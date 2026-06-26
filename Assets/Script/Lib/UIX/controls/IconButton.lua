-- [tsx]: IconButton.tsx
local ____lualib = require("lualib_bundle") -- 1
local __TS__ObjectRest = ____lualib.__TS__ObjectRest -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local ____exports = {} -- 1
local ____DoraX = require("DoraX") -- 1
local React = ____DoraX.React -- 1
local ____Button = require("UIX.controls.Button") -- 2
local Button = ____Button.Button -- 2
local ____context = require("UIX.context") -- 3
local getUiContext = ____context.getUiContext -- 3
local ____helpers = require("UIX.layout.helpers") -- 4
local mergeStyle = ____helpers.mergeStyle -- 4
function ____exports.IconButton(props) -- 12
	local theme = getUiContext().theme -- 13
	local size = props.size or "md" -- 14
	local controlSize = theme.size.control[size] -- 15
	local ____props_0 = props -- 16
	local children = ____props_0.children -- 16
	local style = ____props_0.style -- 16
	local buttonProps = __TS__ObjectRest(____props_0, {children = true, style = true}) -- 16
	local ____React_createElement_4 = React.createElement -- 16
	local ____Button_2 = Button -- 18
	local ____TS__ObjectAssign_result_3 = __TS__ObjectAssign( -- 18
		{}, -- 18
		buttonProps, -- 19
		{ -- 19
			icon = props.icon, -- 19
			style = mergeStyle({width = controlSize, height = controlSize, minWidth = controlSize}, style) -- 19
		} -- 19
	) -- 19
	local ____children_1 = children -- 27
	if ____children_1 == nil then -- 27
		____children_1 = "" -- 27
	end -- 27
	return ____React_createElement_4(____Button_2, ____TS__ObjectAssign_result_3, ____children_1) -- 17
end -- 12
return ____exports -- 12