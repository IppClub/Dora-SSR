-- [tsx]: Spacer.tsx
local ____exports = {} -- 1
local ____DoraX = require("DoraX") -- 1
local React = ____DoraX.React -- 1
function ____exports.Spacer(props) -- 9
	return React.createElement("align-node", {style = {flex = props.flex or 1, width = props.width, height = props.height}}) -- 10
end -- 9
return ____exports -- 9