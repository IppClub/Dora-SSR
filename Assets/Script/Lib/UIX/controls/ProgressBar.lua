-- [tsx]: ProgressBar.tsx
local ____exports = {} -- 1
local ____DoraX = require("DoraX") -- 1
local React = ____DoraX.React -- 1
local ____Dora = require("Dora") -- 2
local Color = ____Dora.Color -- 2
local nvg = require("nvg") -- 3
local ____PaintNode = require("UIX.paint.PaintNode") -- 5
local PaintNode = ____PaintNode.PaintNode -- 5
local ____primitives = require("UIX.paint.primitives") -- 6
local progressFill = ____primitives.progressFill -- 6
local progressTrack = ____primitives.progressTrack -- 6
local ____types = require("UIX.types") -- 8
local clamp = ____types.clamp -- 8
local ____helpers = require("UIX.layout.helpers") -- 9
local mergeStyle = ____helpers.mergeStyle -- 9
local progressFontId = 0 -- 20
function ____exports.ProgressBar(props) -- 22
	local min = props.min or 0 -- 23
	local max = props.max or 1 -- 24
	local progress = max == min and 0 or clamp((props.value - min) / (max - min), 0, 1) -- 25
	return React.createElement( -- 26
		"align-node", -- 26
		{ -- 26
			key = props.key, -- 26
			ref = props.ref, -- 26
			style = mergeStyle({ -- 26
				position = "relative", -- 31
				height = 18, -- 32
				minWidth = 80, -- 33
				alignItems = "center", -- 34
				justifyContent = "center" -- 35
			}, props.style), -- 35
			visible = props.visible, -- 35
			opacity = props.opacity -- 35
		}, -- 35
		React.createElement( -- 35
			PaintNode, -- 40
			{ -- 40
				order = -10, -- 40
				renderOrder = -10, -- 40
				state = {disabled = props.disabled == true}, -- 40
				painter = function(ctx) -- 40
					local r = {x = 0, y = 0, width = ctx.width, height = ctx.height} -- 45
					progressTrack(ctx, r) -- 46
					progressFill(ctx, r, progress, props.variant or "neutral") -- 47
					if props.showValue == true then -- 47
						if progressFontId == 0 then -- 47
							progressFontId = nvg.CreateFont(ctx.theme.font.name) -- 49
						end -- 49
						nvg.FontFaceId(progressFontId) -- 50
						nvg.FontSize(ctx.theme.font.size.xs) -- 51
						nvg.TextAlign("Center", "Middle") -- 52
						nvg.FillColor(Color(ctx.theme.colors.text.primary)) -- 53
						nvg.Save() -- 54
						nvg.Scale(1, -1) -- 55
						nvg.Text( -- 56
							ctx.width * 0.5, -- 56
							-ctx.height * 0.5, -- 56
							tostring(math.floor(progress * 100)) .. "%" -- 56
						) -- 56
						nvg.Restore() -- 57
					end -- 57
				end -- 44
			} -- 44
		) -- 44
	) -- 44
end -- 22
return ____exports -- 22