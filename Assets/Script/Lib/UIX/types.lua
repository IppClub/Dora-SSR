-- [ts]: types.ts
local ____exports = {} -- 1
function ____exports.defaultInteractionState() -- 44
	return { -- 45
		hovered = false, -- 46
		pressed = false, -- 47
		focused = false, -- 48
		selected = false, -- 49
		disabled = false, -- 50
		loading = false -- 51
	} -- 51
end -- 44
function ____exports.mergeInteractionState(state) -- 55
	local base = ____exports.defaultInteractionState() -- 56
	if state == nil then -- 56
		return base -- 57
	end -- 57
	base.hovered = state.hovered == true -- 58
	base.pressed = state.pressed == true -- 59
	base.focused = state.focused == true -- 60
	base.selected = state.selected == true -- 61
	base.disabled = state.disabled == true -- 62
	base.loading = state.loading == true -- 63
	return base -- 64
end -- 55
function ____exports.clamp(value, min, max) -- 67
	return math.max( -- 68
		min, -- 68
		math.min(max, value) -- 68
	) -- 68
end -- 67
return ____exports -- 67