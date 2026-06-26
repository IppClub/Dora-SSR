-- [tsx]: FocusRing.tsx
local ____exports = {} -- 1
local ____DoraX = require("DoraX") -- 1
local React = ____DoraX.React -- 1
local ____PaintNode = require("UIX.paint.PaintNode") -- 2
local PaintNode = ____PaintNode.PaintNode -- 2
local ____primitives = require("UIX.paint.primitives") -- 3
local focusRing = ____primitives.focusRing -- 3
function ____exports.FocusRing(props) -- 13
	return React.createElement( -- 14
		PaintNode, -- 15
		{ -- 15
			key = props.key or "focus-ring-paint", -- 15
			style = props.style, -- 15
			visible = props.visible, -- 15
			opacity = props.opacity, -- 15
			state = {focused = props.active, disabled = props.disabled == true}, -- 15
			painter = function(ctx) return focusRing(ctx, {x = 0, y = 0, width = ctx.width, height = ctx.height}, {radius = props.radius, inset = props.inset, color = props.color}) end -- 15
		} -- 15
	) -- 15
end -- 13
return ____exports -- 13