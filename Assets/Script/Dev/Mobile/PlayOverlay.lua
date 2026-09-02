-- [tsx]: PlayOverlay.tsx
local Gamepad = require("Dev.Mobile.Gamepad")
local ____exports = {} -- 1
local ____DoraX = require("DoraX") -- 1
local React = ____DoraX.React -- 1
local reference = ____DoraX.reference -- 1
local toNode = ____DoraX.toNode -- 1
local ____Dora = require("Dora") -- 2
local App = ____Dora.App -- 2
local DB = ____Dora.DB -- 2
local Director = ____Dora.Director -- 2
local HttpServer = ____Dora.HttpServer -- 2
local Node = ____Dora.Node -- 2
local Vec2 = ____Dora.Vec2 -- 2
local ____Accessibility = require("Dev.Mobile.Accessibility") -- 3
local mobileFontScale = ____Accessibility.mobileFontScale -- 3
local ____Visual = require("Dev.Mobile.Visual") -- 4
local RoundedSurface = ____Visual.RoundedSurface -- 4
local fontName = "sarasa-mono-sc-regular" -- 11
local expandedWidth = 108 -- 12
local collapsedTouchWidth = 26 -- 13
local handleWidth = 6 -- 14
local controlHeight = 44 -- 15
local collapseDelay = 3 -- 16
local dragThreshold = 5 -- 17
function ____exports.resolvePlayHandleY(startControlY, startPointerY, pointerY, height) -- 19
	return math.max( -- 20
		0, -- 20
		math.min( -- 20
			math.max(0, height - controlHeight), -- 20
			startControlY + pointerY - startPointerY -- 20
		) -- 20
	) -- 20
end -- 19
local function loadHandleRatio(portrait) -- 23
	local name = portrait and "mobilePlayHandlePortrait" or "mobilePlayHandleLandscape" -- 24
	local rows = DB:query(("select value_num from Config where name = '" .. name) .. "' limit 1") -- 25
	local ____temp_0 -- 26
	if rows and #rows > 0 then -- 26
		____temp_0 = tonumber(rows[1][1]) -- 26
	else -- 26
		____temp_0 = nil -- 26
	end -- 26
	local ratio = ____temp_0 -- 26
	return ratio == nil and 0.62 or math.max( -- 27
		0.12, -- 27
		math.min(0.88, ratio) -- 27
	) -- 27
end -- 23
local function saveHandleRatio(portrait, ratio) -- 30
	local name = portrait and "mobilePlayHandlePortrait" or "mobilePlayHandleLandscape" -- 31
	DB:exec("insert or replace into Config(name, value_num, value_str, value_bool) values(?, ?, NULL, NULL)", {name, ratio}) -- 32
end -- 30
function ____exports.startMobilePlayOverlay(options) -- 35
	local onExit = options.onExit -- 36
	local zh = (string.match(App.locale, "^zh")) ~= nil -- 37
	local host = Node() -- 38
	host.tag = "mobile-play-overlay" -- 39
	host.order = 10000 -- 40
	host.renderGroup = true -- 41
	host.scaleX = App.devicePixelRatio -- 42
	host.scaleY = App.devicePixelRatio -- 43
	host:addTo(Director.systemUI) -- 44
	local exiting = false -- 45
	local expanded = false -- 46
	local gamepadExit = false
	local expandedTime = 0 -- 47
	local dragDistance = 0 -- 48
	local pointerDown = false -- 49
	local dragStartPointer = Vec2.zero -- 50
	local dragStartControlY = 0 -- 51
	local portrait = App.visualSize.height >= App.visualSize.width -- 52
	local handleRatio = loadHandleRatio(portrait) -- 53
	local controlRef = reference() -- 54
	local sceneRef = reference() -- 55
	local function exit() -- 57
		if exiting or not host.visible or HttpServer.wsConnectionCount > 0 then -- 57
			return -- 58
		end -- 58
		exiting = true -- 59
		host:removeFromParent(true) -- 60
		onExit() -- 61
	end -- 57
	local function fail(message) -- 63
		if exiting or not host.visible or HttpServer.wsConnectionCount > 0 then -- 63
			return -- 64
		end -- 64
		exiting = true -- 65
		host:removeFromParent(true) -- 66
		if options.onRuntimeError then -- 66
			options.onRuntimeError(message) -- 67
		else -- 67
			onExit() -- 68
		end -- 68
	end -- 63
	local function controlPosition(controlWidth, width, height) -- 70
		local y = math.max(0, height - controlHeight) * handleRatio -- 71
		return Vec2(width - controlWidth, y) -- 72
	end -- 70
	local function persistPosition() -- 74
		return saveHandleRatio(portrait, handleRatio) -- 74
	end -- 74
	local render -- 75
	render = function() -- 75
		host:removeAllChildren() -- 76
		host.scaleX = App.devicePixelRatio -- 77
		host.scaleY = App.devicePixelRatio -- 78
		local ____App_visualSize_1 = App.visualSize -- 79
		local width = ____App_visualSize_1.width -- 79
		local height = ____App_visualSize_1.height -- 79
		local nextPortrait = height >= width -- 80
		if nextPortrait ~= portrait then -- 80
			portrait = nextPortrait -- 82
			handleRatio = loadHandleRatio(portrait) -- 83
		end -- 83
		local controlWidth = expanded and expandedWidth or collapsedTouchWidth -- 85
		local position = controlPosition(controlWidth, width, height) -- 86
		controlRef = reference() -- 87
		sceneRef = reference() -- 88
		local ____toNode_13 = toNode -- 89
		local ____React_createElement_12 = React.createElement -- 89
		local ____temp_11 = { -- 89
			ref = sceneRef, -- 89
			x = -width / 2, -- 89
			y = -height / 2, -- 89
			width = width, -- 89
			height = height, -- 89
			anchorX = 0, -- 89
			anchorY = 0 -- 89
		} -- 89
		local ____React_createElement_10 = React.createElement -- 89
		local ____temp_9 = { -- 89
			tag = expanded and "mobile-play-exit" or "mobile-play-handle", -- 89
			ref = controlRef, -- 89
			x = position.x, -- 89
			y = position.y, -- 89
			width = controlWidth, -- 89
			height = controlHeight, -- 89
			anchorX = 0, -- 89
			anchorY = 0, -- 89
			touchEnabled = true, -- 89
			swallowTouches = true, -- 89
			onTapBegan = function(touch) -- 89
				local ____opt_2 = sceneRef.current -- 89
				local point = ____opt_2 and ____opt_2:convertToNodeSpace(touch.worldLocation) or touch.location -- 94
				dragStartPointer = point -- 95
				local ____opt_4 = controlRef.current -- 95
				dragStartControlY = ____opt_4 and ____opt_4.y or position.y -- 96
				dragDistance = 0 -- 97
				pointerDown = true -- 98
				expandedTime = 0 -- 99
			end, -- 93
			onTapMoved = function(touch) -- 93
				local ____opt_6 = sceneRef.current -- 93
				local point = ____opt_6 and ____opt_6:convertToNodeSpace(touch.worldLocation) or touch.location -- 102
				dragDistance = math.max( -- 103
					dragDistance, -- 103
					point:distance(dragStartPointer) -- 103
				) -- 103
				local control = controlRef.current -- 104
				local y = ____exports.resolvePlayHandleY(dragStartControlY, dragStartPointer.y, point.y, height) -- 105
				handleRatio = y / math.max(1, height - controlHeight) -- 106
				if control then -- 106
					control.y = y -- 107
				end -- 107
			end, -- 101
			onTapEnded = function() -- 101
				pointerDown = false -- 110
				if dragDistance > dragThreshold then -- 110
					persistPosition() -- 111
				end -- 111
			end, -- 109
			onTapped = function() -- 109
				if dragDistance > dragThreshold then -- 109
					return -- 114
				end -- 114
				if expanded then -- 114
					exit() -- 115
				else -- 115
					expanded = true -- 116
					gamepadExit = false
					expandedTime = 0 -- 116
					render() -- 116
				end -- 116
			end -- 113
		} -- 113
		local ____expanded_8 -- 118
		if expanded then -- 118
			____expanded_8 = React.createElement( -- 118
				"node", -- 118
				nil, -- 118
				React.createElement(RoundedSurface, { -- 118
					width = controlWidth, -- 118
					height = controlHeight, -- 118
					radius = 12, -- 118
					topColor = 3895145538, -- 118
					bottomColor = 3893433629, -- 118
					borderWidth = 1, -- 118
					borderColor = 2298478591, -- 118
					shadow = true -- 118
				}), -- 118
				React.createElement( -- 118
					"label", -- 118
					{ -- 118
						x = controlWidth / 2, -- 118
						y = gamepadExit and 29 or controlHeight / 2, -- 118
						fontName = fontName, -- 118
						fontSize = math.floor(14 * mobileFontScale), -- 118
						text = zh and "退出试玩" or "Exit", -- 118
						color3 = 16052712 -- 118
					} -- 118
				), -- 118
				gamepadExit and React.createElement("label", {
					x = controlWidth / 2, y = 11, fontName = fontName,
					fontSize = 10, text = "Back + Start", color3 = 0xffcc33
				}) or nil
			) -- 118
		else -- 118
			____expanded_8 = React.createElement(RoundedSurface, { -- 118
				x = collapsedTouchWidth - handleWidth, -- 118
				y = 5, -- 118
				width = handleWidth, -- 118
				height = controlHeight - 10, -- 118
				radius = 3, -- 118
				fillColor = 2583691263 -- 118
			}) -- 118
		end -- 118
		local scene = ____toNode_13(____React_createElement_12( -- 89
			"node", -- 89
			____temp_11, -- 89
			____React_createElement_10("node", ____temp_9, ____expanded_8) -- 89
		)) -- 89
		if scene then -- 89
			host:addChild(scene) -- 128
		end -- 128
	end -- 75
	Gamepad.attachGamepad(host, {
		onBack = function() end,
		onButton = function(button, id)
			if (button == "start" and ____Dora.Controller:isButtonPressed(id, "back")) or
				(button == "back" and ____Dora.Controller:isButtonPressed(id, "start")) then
				if expanded then exit() else expanded = true; gamepadExit = true; expandedTime = 0; render() end
			elseif button == "b" and expanded then expanded = false; render() end
			return true
		end,
	})
	host:schedule(function(dt) -- 131
		if not expanded or exiting or pointerDown then -- 131
			return false -- 132
		end -- 132
		expandedTime = expandedTime + dt -- 133
		if expandedTime >= collapseDelay then -- 133
			expanded = false -- 135
			expandedTime = 0 -- 136
			render() -- 137
		end -- 137
		return false -- 139
	end) -- 131
	host:onAppChange(function(setting) -- 141
		if setting == "Locale" then -- 142
			zh = (string.match(App.locale, "^zh")) ~= nil -- 142
		end -- 142
		if setting == "Size" or setting == "Locale" then -- 141
			render() -- 141
		end -- 141
	end) -- 141
	host:onAppEvent(function(event) -- 142
		if event == "BackButton" then -- 142
			exit() -- 142
		end -- 142
	end) -- 142
	host:gslot("ScriptError", fail) -- 143
	render() -- 144
	return host -- 145
end -- 35
return ____exports -- 35
