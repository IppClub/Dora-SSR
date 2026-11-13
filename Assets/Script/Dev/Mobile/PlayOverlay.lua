-- [tsx]: PlayOverlay.tsx
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
local ____Gamepad = require("Dev.Mobile.Gamepad") -- 3
local attachGamepad = ____Gamepad.attachGamepad -- 3
local ____Accessibility = require("Dev.Mobile.Accessibility") -- 4
local mobileFontScale = ____Accessibility.mobileFontScale -- 4
local ____Visual = require("Dev.Mobile.Visual") -- 5
local RoundedSurface = ____Visual.RoundedSurface -- 5
local fontName = "sarasa-mono-sc-regular" -- 12
local expandedWidth = 108 -- 13
local collapsedTouchWidth = 26 -- 14
local handleWidth = 6 -- 15
local controlHeight = 44 -- 16
local collapseDelay = 3 -- 17
local dragThreshold = 5 -- 18
function ____exports.resolvePlayHandleY(startControlY, startPointerY, pointerY, height) -- 20
	return math.max( -- 21
		0, -- 21
		math.min( -- 21
			math.max(0, height - controlHeight), -- 21
			startControlY + pointerY - startPointerY -- 21
		) -- 21
	) -- 21
end -- 20
local function loadHandleRatio(portrait) -- 24
	local name = portrait and "mobilePlayHandlePortrait" or "mobilePlayHandleLandscape" -- 25
	local rows = DB:query(("select value_num from Config where name = '" .. name) .. "' limit 1") -- 26
	local ____temp_0 -- 27
	if rows and #rows > 0 then -- 27
		____temp_0 = tonumber(rows[1][1]) -- 27
	else -- 27
		____temp_0 = nil -- 27
	end -- 27
	local ratio = ____temp_0 -- 27
	return ratio == nil and 0.62 or math.max( -- 28
		0.12, -- 28
		math.min(0.88, ratio) -- 28
	) -- 28
end -- 24
local function saveHandleRatio(portrait, ratio) -- 31
	local name = portrait and "mobilePlayHandlePortrait" or "mobilePlayHandleLandscape" -- 32
	DB:exec("insert or replace into Config(name, value_num, value_str, value_bool) values(?, ?, NULL, NULL)", {name, ratio}) -- 33
end -- 31
function ____exports.startMobilePlayOverlay(options) -- 36
	local onExit = options.onExit -- 37
	local zh = (string.match(App.locale, "^zh")) ~= nil -- 38
	local host = Node() -- 39
	host.tag = "mobile-play-overlay" -- 40
	host.order = 10000 -- 41
	host.renderGroup = true -- 42
	host.scaleX = App.devicePixelRatio -- 43
	host.scaleY = App.devicePixelRatio -- 44
	host:addTo(Director.systemUI) -- 45
	local exiting = false -- 46
	local expanded = false -- 47
	local gamepadExit = false -- 48
	local expandedTime = 0 -- 49
	local dragDistance = 0 -- 50
	local pointerDown = false -- 51
	local dragStartPointer = Vec2.zero -- 52
	local dragStartControlY = 0 -- 53
	local portrait = App.visualSize.height >= App.visualSize.width -- 54
	local handleRatio = loadHandleRatio(portrait) -- 55
	local controlRef = reference() -- 56
	local sceneRef = reference() -- 57
	local function exit() -- 59
		if exiting or not host.visible or HttpServer.wsConnectionCount > 0 then -- 59
			return -- 60
		end -- 60
		exiting = true -- 61
		host:removeFromParent(true) -- 62
		onExit() -- 63
	end -- 59
	local function fail(message) -- 65
		if exiting or not host.visible or HttpServer.wsConnectionCount > 0 then -- 65
			return -- 66
		end -- 66
		exiting = true -- 67
		host:removeFromParent(true) -- 68
		if options.onRuntimeError then -- 68
			options.onRuntimeError(message) -- 69
		else -- 69
			onExit() -- 70
		end -- 70
	end -- 65
	local function controlPosition(controlWidth, width, height) -- 72
		local y = math.max(0, height - controlHeight) * handleRatio -- 73
		return Vec2(width - controlWidth, y) -- 74
	end -- 72
	local function persistPosition() -- 76
		return saveHandleRatio(portrait, handleRatio) -- 76
	end -- 76
	local render -- 77
	render = function() -- 77
		host:removeAllChildren() -- 78
		host.scaleX = App.devicePixelRatio -- 79
		host.scaleY = App.devicePixelRatio -- 80
		local ____App_visualSize_1 = App.visualSize -- 81
		local width = ____App_visualSize_1.width -- 81
		local height = ____App_visualSize_1.height -- 81
		local nextPortrait = height >= width -- 82
		if nextPortrait ~= portrait then -- 82
			portrait = nextPortrait -- 84
			handleRatio = loadHandleRatio(portrait) -- 85
		end -- 85
		local controlWidth = expanded and expandedWidth or collapsedTouchWidth -- 87
		local position = controlPosition(controlWidth, width, height) -- 88
		controlRef = reference() -- 89
		sceneRef = reference() -- 90
		local ____toNode_17 = toNode -- 91
		local ____React_createElement_16 = React.createElement -- 91
		local ____temp_15 = { -- 91
			ref = sceneRef, -- 91
			x = -width / 2, -- 91
			y = -height / 2, -- 91
			width = width, -- 91
			height = height, -- 91
			anchorX = 0, -- 91
			anchorY = 0 -- 91
		} -- 91
		local ____React_createElement_14 = React.createElement -- 91
		local ____temp_13 = { -- 91
			tag = expanded and "mobile-play-exit" or "mobile-play-handle", -- 91
			ref = controlRef, -- 91
			x = position.x, -- 91
			y = position.y, -- 91
			width = controlWidth, -- 91
			height = controlHeight, -- 91
			anchorX = 0, -- 91
			anchorY = 0, -- 91
			touchEnabled = true, -- 91
			swallowTouches = true, -- 91
			onTapBegan = function(touch) -- 91
				local ____opt_2 = sceneRef.current -- 91
				local point = ____opt_2 and ____opt_2:convertToNodeSpace(touch.worldLocation) or touch.location -- 96
				dragStartPointer = point -- 97
				local ____opt_4 = controlRef.current -- 97
				dragStartControlY = ____opt_4 and ____opt_4.y or position.y -- 98
				dragDistance = 0 -- 99
				pointerDown = true -- 100
				expandedTime = 0 -- 101
			end, -- 95
			onTapMoved = function(touch) -- 95
				local ____opt_6 = sceneRef.current -- 95
				local point = ____opt_6 and ____opt_6:convertToNodeSpace(touch.worldLocation) or touch.location -- 104
				dragDistance = math.max( -- 105
					dragDistance, -- 105
					point:distance(dragStartPointer) -- 105
				) -- 105
				local control = controlRef.current -- 106
				local y = ____exports.resolvePlayHandleY(dragStartControlY, dragStartPointer.y, point.y, height) -- 107
				handleRatio = y / math.max(1, height - controlHeight) -- 108
				if control then -- 108
					control.y = y -- 109
				end -- 109
			end, -- 103
			onTapEnded = function() -- 103
				pointerDown = false -- 112
				if dragDistance > dragThreshold then -- 112
					persistPosition() -- 113
				end -- 113
			end, -- 111
			onTapped = function() -- 111
				if dragDistance > dragThreshold then -- 111
					return -- 116
				end -- 116
				if expanded then -- 116
					exit() -- 117
				else -- 117
					expanded = true -- 118
					gamepadExit = false -- 118
					expandedTime = 0 -- 118
					render() -- 118
				end -- 118
			end -- 115
		} -- 115
		local ____expanded_12 -- 120
		if expanded then -- 120
			local ____React_createElement_11 = React.createElement -- 120
			local ____React_createElement_result_9 = React.createElement(RoundedSurface, { -- 120
				width = controlWidth, -- 120
				height = controlHeight, -- 120
				radius = 12, -- 120
				topColor = 3895145538, -- 120
				bottomColor = 3893433629, -- 120
				borderWidth = 1, -- 120
				borderColor = 2298478591, -- 120
				shadow = true -- 120
			}) -- 120
			local ____React_createElement_result_10 = React.createElement( -- 120
				"label", -- 120
				{ -- 120
					x = controlWidth / 2, -- 120
					y = gamepadExit and 29 or controlHeight / 2, -- 120
					fontName = fontName, -- 120
					fontSize = math.floor(14 * mobileFontScale), -- 120
					text = zh and "退出试玩" or "Exit", -- 120
					color3 = 16052712 -- 120
				} -- 120
			) -- 120
			local ____gamepadExit_8 -- 126
			if gamepadExit then -- 126
				____gamepadExit_8 = React.createElement("label", { -- 126
					x = controlWidth / 2, -- 126
					y = 11, -- 126
					fontName = fontName, -- 126
					fontSize = 10, -- 126
					text = "Back + Start", -- 126
					color3 = 16763955 -- 126
				}) -- 126
			else -- 126
				____gamepadExit_8 = nil -- 126
			end -- 126
			____expanded_12 = ____React_createElement_11( -- 126
				"node", -- 126
				nil, -- 126
				____React_createElement_result_9, -- 126
				____React_createElement_result_10, -- 126
				____gamepadExit_8 -- 126
			) -- 126
		else -- 126
			____expanded_12 = React.createElement(RoundedSurface, { -- 126
				x = collapsedTouchWidth - handleWidth, -- 126
				y = 5, -- 126
				width = handleWidth, -- 126
				height = controlHeight - 10, -- 126
				radius = 3, -- 126
				fillColor = 2583691263 -- 126
			}) -- 126
		end -- 126
		local scene = ____toNode_17(____React_createElement_16( -- 91
			"node", -- 91
			____temp_15, -- 91
			____React_createElement_14("node", ____temp_13, ____expanded_12) -- 91
		)) -- 91
		if scene then -- 91
			host:addChild(scene) -- 131
		end -- 131
	end -- 77
	attachGamepad( -- 134
		host, -- 134
		{ -- 134
			onBack = function() return nil end, -- 135
			onButton = function(button) -- 136
				if button == "b" and expanded then -- 136
					expanded = false -- 138
					render() -- 138
				end -- 138
				return true -- 139
			end -- 136
		} -- 136
	) -- 136
	host:gslot( -- 142
		"ControllerShortcut", -- 142
		function(_id, shortcut) -- 142
			if shortcut ~= "back+start" or exiting or not host.visible or HttpServer.wsConnectionCount > 0 then -- 142
				return -- 143
			end -- 143
			if expanded then -- 143
				exit() -- 144
			else -- 144
				expanded = true -- 145
				gamepadExit = true -- 145
				expandedTime = 0 -- 145
				render() -- 145
			end -- 145
		end -- 142
	) -- 142
	host:schedule(function(dt) -- 147
		if not expanded or exiting or pointerDown then -- 147
			return false -- 148
		end -- 148
		expandedTime = expandedTime + dt -- 149
		if expandedTime >= collapseDelay then -- 149
			expanded = false -- 151
			expandedTime = 0 -- 152
			render() -- 153
		end -- 153
		return false -- 155
	end) -- 147
	host:onAppChange(function(setting) -- 157
		if setting == "Locale" then -- 157
			zh = (string.match(App.locale, "^zh")) ~= nil -- 158
		end -- 158
		if setting == "Size" or setting == "Locale" then -- 158
			render() -- 159
		end -- 159
	end) -- 157
	host:onAppEvent(function(event) -- 161
		if event == "BackButton" then -- 161
			exit() -- 161
		end -- 161
	end) -- 161
	host:gslot("ScriptError", fail) -- 162
	render() -- 163
	return host -- 164
end -- 36
return ____exports -- 36