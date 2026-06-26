-- [tsx]: Stack.tsx
local ____lualib = require("lualib_bundle") -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local ____exports = {} -- 1
local ____DoraX = require("DoraX") -- 1
local React = ____DoraX.React -- 1
local ____Box = require("UIX.layout.Box") -- 2
local Box = ____Box.Box -- 2
local ____helpers = require("UIX.layout.helpers") -- 3
local mergeStyle = ____helpers.mergeStyle -- 3
function ____exports.Stack(props) -- 10
	return React.createElement( -- 11
		Box, -- 12
		__TS__ObjectAssign( -- 12
			{}, -- 12
			props, -- 13
			{style = mergeStyle({position = "relative", overflow = props.clip == true and "hidden" or nil}, props.style)} -- 13
		) -- 13
	) -- 13
end -- 10
return ____exports -- 10