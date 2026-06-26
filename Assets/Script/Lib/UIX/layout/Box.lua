-- [tsx]: Box.tsx
local ____exports = {} -- 1
local ____DoraX = require("DoraX") -- 1
local React = ____DoraX.React -- 1
function ____exports.Box(props) -- 9
	return React.createElement("align-node", { -- 10
		key = props.key, -- 10
		ref = props.ref, -- 10
		style = props.style, -- 10
		visible = props.visible, -- 10
		opacity = props.opacity, -- 10
		onLayout = props.onLayout, -- 10
		showDebug = props.showDebug -- 10
	}, props.children) -- 10
end -- 9
return ____exports -- 9