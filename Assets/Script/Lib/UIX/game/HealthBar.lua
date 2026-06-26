-- [tsx]: HealthBar.tsx
local ____lualib = require("lualib_bundle") -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local ____exports = {} -- 1
local ____DoraX = require("DoraX") -- 1
local React = ____DoraX.React -- 1
local ____ProgressBar = require("UIX.controls.ProgressBar") -- 2
local ProgressBar = ____ProgressBar.ProgressBar -- 2
function ____exports.HealthBar(props) -- 9
	local min = props.min or 0 -- 10
	local max = props.max or 1 -- 11
	local threshold = props.dangerThreshold or 0.3 -- 12
	local progress = max == min and 0 or (props.value - min) / (max - min) -- 13
	return React.createElement( -- 14
		ProgressBar, -- 15
		__TS__ObjectAssign({}, props, {variant = progress <= threshold and "health" or "warm"}) -- 15
	) -- 15
end -- 9
return ____exports -- 9