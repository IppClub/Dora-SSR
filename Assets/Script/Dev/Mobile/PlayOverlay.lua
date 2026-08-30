-- [tsx]: PlayOverlay.tsx
local ____exports = {} -- 1
local ____DoraX = require("DoraX") -- 1
local React = ____DoraX.React -- 1
local toNode = ____DoraX.toNode -- 1
local ____Dora = require("Dora") -- 2
local App = ____Dora.App -- 2
local Director = ____Dora.Director -- 2
local HttpServer = ____Dora.HttpServer -- 2
local Node = ____Dora.Node -- 2
local ____Accessibility = require("Dev.Mobile.Accessibility") -- 3
local mobileFontScale = ____Accessibility.mobileFontScale -- 3
local fontName = "sarasa-mono-sc-regular" -- 10
function ____exports.startMobilePlayOverlay(options) -- 12
	local onExit = options.onExit -- 13
	local zh = (string.match(App.locale, "^zh")) ~= nil -- 14
	local host = Node() -- 15
	host.tag = "mobile-play-overlay" -- 16
	host.scaleX = App.devicePixelRatio -- 17
	host.scaleY = App.devicePixelRatio -- 18
	host:addTo(Director.systemUI) -- 19
	local exiting = false -- 20
	local function exit() -- 22
		if exiting or not host.visible or HttpServer.wsConnectionCount > 0 then -- 22
			return -- 23
		end -- 23
		exiting = true -- 24
		host:removeFromParent(true) -- 25
		onExit() -- 26
	end -- 22
	local function fail(message) -- 28
		if exiting or not host.visible or HttpServer.wsConnectionCount > 0 then -- 28
			return -- 29
		end -- 29
		exiting = true -- 30
		host:removeFromParent(true) -- 31
		if options.onRuntimeError then -- 31
			options.onRuntimeError(message) -- 32
		else -- 32
			onExit() -- 33
		end -- 33
	end -- 28
	local function render() -- 35
		host:removeAllChildren() -- 36
		host.scaleX = App.devicePixelRatio -- 37
		host.scaleY = App.devicePixelRatio -- 38
		local ____App_visualSize_0 = App.visualSize -- 39
		local width = ____App_visualSize_0.width -- 39
		local height = ____App_visualSize_0.height -- 39
		local safe = App.safeArea -- 40
		local buttonWidth = 92 -- 41
		local scene = toNode(React.createElement( -- 42
			"node", -- 42
			{ -- 42
				x = -width / 2, -- 42
				y = -height / 2, -- 42
				width = width, -- 42
				height = height, -- 42
				anchorX = 0, -- 42
				anchorY = 0 -- 42
			}, -- 42
			React.createElement( -- 42
				"node", -- 42
				{ -- 42
					tag = "mobile-play-exit", -- 42
					x = safe.x + safe.width - buttonWidth - 12, -- 42
					y = safe.y + safe.height - 50, -- 42
					width = buttonWidth, -- 42
					height = 38, -- 42
					anchorX = 0, -- 42
					anchorY = 0, -- 42
					touchEnabled = true, -- 42
					swallowTouches = true, -- 42
					onTapped = exit -- 42
				}, -- 42
				React.createElement( -- 42
					"draw-node", -- 42
					{x = buttonWidth / 2, y = 19}, -- 42
					React.createElement("rect-shape", { -- 42
						width = buttonWidth, -- 42
						height = 38, -- 42
						fillColor = 3423671581, -- 42
						borderWidth = 1, -- 42
						borderColor = 1728053247 -- 42
					}) -- 42
				), -- 42
				React.createElement( -- 42
					"label", -- 42
					{ -- 42
						x = buttonWidth / 2, -- 42
						y = 19, -- 42
						fontName = fontName, -- 42
						fontSize = math.floor(14 * mobileFontScale), -- 42
						text = zh and "退出试玩" or "Exit", -- 42
						color3 = 16052712 -- 42
					} -- 42
				) -- 42
			) -- 42
		)) -- 42
		if scene then -- 42
			host:addChild(scene) -- 51
		end -- 51
	end -- 35
	host:onAppChange(function(setting) -- 54
		if setting == "Size" or setting == "Locale" then -- 54
			render() -- 54
		end -- 54
	end) -- 54
	host:onAppEvent(function(event) -- 55
		if event == "BackButton" then -- 55
			exit() -- 55
		end -- 55
	end) -- 55
	host:gslot("ScriptError", fail) -- 56
	render() -- 57
	return host -- 58
end -- 12
return ____exports -- 12