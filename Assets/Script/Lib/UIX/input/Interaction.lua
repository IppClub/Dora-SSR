-- [ts]: Interaction.ts
local ____exports = {} -- 1
local ____DoraX = require("DoraX") -- 1
local useSignal = ____DoraX.useSignal -- 1
function ____exports.useInteraction(options) -- 11
	local pressed = useSignal(false) -- 16
	local focused = useSignal(false) -- 17
	local disabled = (options and options.disabled) == true -- 18
	local loading = (options and options.loading) == true -- 19
	return { -- 20
		state = { -- 21
			hovered = false, -- 22
			pressed = pressed.value, -- 23
			focused = focused.value, -- 24
			selected = (options and options.selected) == true, -- 25
			disabled = disabled, -- 26
			loading = loading -- 27
		}, -- 27
		setPressed = function(value) -- 29
			if not disabled and not loading then -- 29
				pressed.value = value -- 31
			end -- 31
		end, -- 29
		setFocused = function(value) -- 34
			focused.value = value -- 35
		end, -- 34
		reset = function() -- 37
			pressed.value = false -- 38
			focused.value = false -- 39
		end -- 37
	} -- 37
end -- 11
return ____exports -- 11