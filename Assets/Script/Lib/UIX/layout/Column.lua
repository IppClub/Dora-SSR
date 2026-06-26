-- [tsx]: Column.tsx
local ____lualib = require("lualib_bundle") -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local ____exports = {} -- 1
local ____DoraX = require("DoraX") -- 1
local React = ____DoraX.React -- 1
local ____Box = require("UIX.layout.Box") -- 2
local Box = ____Box.Box -- 2
local ____helpers = require("UIX.layout.helpers") -- 3
local mergeStyle = ____helpers.mergeStyle -- 3
function ____exports.Column(props) -- 12
	return React.createElement( -- 13
		Box, -- 14
		__TS__ObjectAssign( -- 14
			{}, -- 14
			props, -- 15
			{style = mergeStyle({flexDirection = "column", gap = props.gap, alignItems = props.align, justifyContent = props.justify}, props.style)} -- 15
		) -- 15
	) -- 15
end -- 12
return ____exports -- 12