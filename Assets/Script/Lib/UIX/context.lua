-- [ts]: context.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____theme = require("UIX.theme") -- 2
local doraPrismTheme = ____theme.doraPrismTheme -- 2
local mergeTheme = ____theme.mergeTheme -- 2
local ____FocusManager = require("UIX.input.FocusManager") -- 4
local FocusManager = ____FocusManager.FocusManager -- 4
local defaultFocusManager = __TS__New(FocusManager) -- 13
local currentContext = {theme = doraPrismTheme, inputMode = "pointer", focusManager = defaultFocusManager, scale = 1} -- 15
function ____exports.getUiContext() -- 22
	return currentContext -- 23
end -- 22
function ____exports.UiProvider(props) -- 33
	currentContext = { -- 34
		theme = mergeTheme(doraPrismTheme, props.theme), -- 35
		inputMode = props.inputMode or "pointer", -- 36
		focusManager = currentContext.focusManager, -- 37
		scale = props.scale or 1 -- 38
	} -- 38
	return props.children -- 40
end -- 33
function ____exports.ThemeScope(props) -- 48
	local previous = currentContext -- 49
	currentContext = { -- 50
		theme = mergeTheme(previous.theme, props.theme), -- 51
		inputMode = previous.inputMode, -- 52
		focusManager = previous.focusManager, -- 53
		scale = previous.scale -- 54
	} -- 54
	return props.children -- 56
end -- 48
return ____exports -- 48