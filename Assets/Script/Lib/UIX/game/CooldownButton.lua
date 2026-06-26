-- [tsx]: CooldownButton.tsx
local ____lualib = require("lualib_bundle") -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local ____exports = {} -- 1
local ____DoraX = require("DoraX") -- 1
local React = ____DoraX.React -- 1
local ____IconButton = require("UIX.controls.IconButton") -- 2
local IconButton = ____IconButton.IconButton -- 2
local ____PaintNode = require("UIX.paint.PaintNode") -- 3
local PaintNode = ____PaintNode.PaintNode -- 3
local ____primitives = require("UIX.paint.primitives") -- 4
local cooldownMask = ____primitives.cooldownMask -- 4
local ____Text = require("UIX.foundation.Text") -- 5
local Text = ____Text.Text -- 5
local ____types = require("UIX.types") -- 6
local clamp = ____types.clamp -- 6
function ____exports.CooldownButton(props) -- 16
	local progress = props.maxCooldown <= 0 and 0 or clamp(props.cooldown / props.maxCooldown, 0, 1) -- 17
	local cooling = progress > 0 -- 18
	local ____React_createElement_6 = React.createElement -- 18
	local ____array_5 = __TS__SparseArrayNew( -- 18
		IconButton, -- 20
		__TS__ObjectAssign( -- 20
			{}, -- 20
			props, -- 21
			{ -- 21
				disabled = props.disabled == true or cooling, -- 21
				onClick = function() -- 21
					if not cooling then -- 21
						local ____opt_0 = props.onCast -- 21
						if ____opt_0 ~= nil then -- 21
							____opt_0() -- 25
						end -- 25
						local ____opt_2 = props.onClick -- 25
						if ____opt_2 ~= nil then -- 25
							____opt_2() -- 26
						end -- 26
					end -- 26
				end -- 23
			} -- 23
		), -- 23
		React.createElement( -- 23
			PaintNode, -- 30
			{ -- 30
				key = "cooldown-mask", -- 30
				order = -10, -- 30
				renderOrder = -10, -- 30
				state = {disabled = cooling}, -- 30
				painter = function(ctx) return cooldownMask(ctx, {x = 0, y = 0, width = ctx.width, height = ctx.height}, progress) end -- 30
			} -- 30
		) -- 30
	) -- 30
	local ____cooling_4 -- 37
	if cooling then -- 37
		____cooling_4 = React.createElement( -- 37
			Text, -- 38
			{ -- 38
				key = "cooldown-count", -- 38
				text = tostring(math.ceil(props.cooldown)), -- 38
				fontSize = 16, -- 38
				color = 4294244607 -- 38
			} -- 38
		) -- 38
	else -- 38
		____cooling_4 = nil -- 38
	end -- 38
	__TS__SparseArrayPush(____array_5, ____cooling_4) -- 38
	return ____React_createElement_6(__TS__SparseArraySpread(____array_5)) -- 19
end -- 16
return ____exports -- 16