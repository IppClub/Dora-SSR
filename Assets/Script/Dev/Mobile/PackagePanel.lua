-- [tsx]: PackagePanel.tsx
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local ____exports = {} -- 1
local ____DoraX = require("DoraX") -- 1
local React = ____DoraX.React -- 1
local reference = ____DoraX.reference -- 1
local toNode = ____DoraX.toNode -- 1
local ____Dora = require("Dora") -- 2
local App = ____Dora.App -- 2
local Director = ____Dora.Director -- 2
local HttpServer = ____Dora.HttpServer -- 2
local Label = ____Dora.Label -- 2
local Node = ____Dora.Node -- 2
local thread = ____Dora.thread -- 2
local ____Gamepad = require("Dev.Mobile.Gamepad") -- 3
local attachGamepad = ____Gamepad.attachGamepad -- 3
local ____Package = require("Dev.Mobile.Package") -- 4
local discardPackage = ____Package.discardPackage -- 4
local exportPackage = ____Package.exportPackage -- 4
local inspectPackage = ____Package.inspectPackage -- 4
local installPackage = ____Package.installPackage -- 4
local ____NativeControls = require("Dev.Mobile.NativeControls") -- 7
local PackageButton = ____NativeControls.NativeButton -- 7
local NativePanelSurface = ____NativeControls.NativePanelSurface -- 7
function ____exports.startPackagePanel(options) -- 9
	local render -- 9
	local host = Node() -- 18
	host.tag = "mobile-package-panel" -- 19
	host.order = 20000 -- 20
	host.renderGroup = true -- 21
	host:addTo(Director.systemUI) -- 22
	local active = true -- 23
	local busy = options.mode == "share" and options.entry ~= nil -- 24
	local preview -- 25
	local exported -- 26
	local detailRef = reference() -- 27
	local message = options.mode == "share" and (__TS__StringStartsWith( -- 28
		string.lower(App.locale), -- 28
		"zh" -- 28
	) and "接收者导入后可以试玩，也可以继续改编。" or "Recipients can import, play, and Remix this game.") or "" -- 28
	local failed = false -- 29
	local zh = __TS__StringStartsWith( -- 30
		string.lower(App.locale), -- 30
		"zh" -- 30
	) -- 30
	local function enabled() -- 31
		return active and host.parent ~= nil and host.visible and HttpServer.wsConnectionCount == 0 and not busy -- 31
	end -- 31
	local function close() -- 32
		if busy or not active then -- 32
			return -- 33
		end -- 33
		active = false -- 34
		if preview then -- 34
			discardPackage(preview) -- 35
		end -- 35
		preview = nil -- 36
		host:removeFromParent(true) -- 37
		options.onClosed() -- 38
	end -- 32
	local function receive(path) -- 40
		if not active then -- 40
			return -- 41
		end -- 41
		busy = true -- 42
		failed = false -- 42
		message = zh and "正在检查作品包…" or "Checking game package…" -- 43
		render() -- 44
		thread(function() -- 45
			do -- 45
				local function ____catch(e) -- 45
					failed = true -- 51
					message = (string.match( -- 51
						tostring(e), -- 51
						":%d+: (.*)$" -- 51
					)) or tostring(e) -- 51
				end -- 51
				local ____try, ____hasReturned, ____returnValue = pcall(function() -- 51
					local result = inspectPackage(path) -- 47
					if not active or not host.parent then -- 47
						discardPackage(result) -- 48
						return true -- 48
					end -- 48
					preview = result -- 49
					message = zh and "包含代码与素材，导入后可试玩和 Remix。" or "Includes code and assets. Import to play or Remix." -- 50
				end) -- 50
				if not ____try then -- 50
					____hasReturned, ____returnValue = ____catch(____hasReturned) -- 50
				end -- 50
				do -- 50
					busy = false -- 53
					render() -- 53
				end -- 53
				if ____hasReturned then -- 53
					return ____returnValue -- 46
				end -- 46
			end -- 46
		end) -- 45
	end -- 40
	local function pick() -- 57
		if not enabled() then -- 57
			return -- 58
		end -- 58
		busy = true -- 59
		message = zh and "请选择 ZIP 作品包" or "Choose a ZIP game package" -- 59
		render() -- 59
		App:openFileDialog( -- 60
			false, -- 60
			function(path) -- 60
				busy = false -- 61
				if not active or not host.parent then -- 61
					return -- 62
				end -- 62
				if path ~= "" then -- 62
					receive(path) -- 63
				else -- 63
					message = "" -- 64
					render() -- 64
				end -- 64
			end, -- 60
			"zip" -- 65
		) -- 65
	end -- 57
	local function install(play) -- 67
		if not enabled() or not preview then -- 67
			return -- 68
		end -- 68
		do -- 68
			local function ____catch(e) -- 68
				failed = true -- 74
				message = (string.match( -- 74
					tostring(e), -- 74
					":%d+: (.*)$" -- 74
				)) or tostring(e) -- 74
				render() -- 74
			end -- 74
			local ____try, ____hasReturned = pcall(function() -- 74
				local entry = installPackage(preview) -- 70
				preview = nil -- 71
				close() -- 72
				local ____opt_0 = options.onImported -- 72
				if ____opt_0 ~= nil then -- 72
					____opt_0(entry, play) -- 73
				end -- 73
			end) -- 73
			if not ____try then -- 73
				____catch(____hasReturned) -- 73
			end -- 73
		end -- 73
	end -- 67
	render = function() -- 76
		if not active or not host.parent then -- 76
			return -- 77
		end -- 77
		host:removeAllChildren() -- 78
		host.scaleX = App.devicePixelRatio -- 79
		host.scaleY = App.devicePixelRatio -- 79
		local safe = App.safeArea -- 80
		local width = math.min(safe.width, 540) -- 81
		local title = preview and preview.title or (options.mode == "share" and (zh and "分享作品" or "Share game") or (zh and "添加作品" or "Add game")) -- 82
		local ____preview_5 -- 83
		if preview then -- 83
			____preview_5 = (preview.author and preview.author .. " · " or "") .. string.format("%.1f MB", preview.bytes / 1048576) -- 83
		else -- 83
			local ____temp_4 -- 84
			if options.mode == "share" then -- 84
				local ____opt_2 = options.entry -- 84
				____temp_4 = ((____opt_2 and ____opt_2.title or "") .. " · ") .. (exported and string.format("%.1f MB", exported.bytes / 1048576) or (zh and "打包中…" or "Packaging…")) -- 84
			else -- 84
				____temp_4 = "" -- 84
			end -- 84
			____preview_5 = ____temp_4 -- 84
		end -- 84
		local detail = ____preview_5 -- 83
		local function textHeight(text, fontSize) -- 85
			if text == "" then -- 85
				return 0 -- 86
			end -- 86
			local label = Label("sarasa-mono-sc-regular", fontSize) -- 87
			label.textWidth = width - 40 -- 88
			label.text = text -- 89
			local height = math.max( -- 90
				fontSize, -- 90
				math.ceil(label.height) -- 90
			) -- 90
			label:cleanup() -- 92
			return height -- 93
		end -- 85
		local titleTop = 20 -- 95
		local detailTop = titleTop + textHeight(title, 22) + 12 -- 96
		local ____temp_12 -- 98
		if options.mode == "share" then -- 98
			local ____math_max_11 = math.max -- 99
			local ____opt_6 = options.entry -- 99
			local ____textHeight_result_10 = textHeight(((____opt_6 and ____opt_6.title or "") .. " · ") .. (zh and "打包中…" or "Packaging…"), 14) -- 99
			local ____opt_8 = options.entry -- 99
			____temp_12 = ____math_max_11( -- 99
				____textHeight_result_10, -- 99
				textHeight((____opt_8 and ____opt_8.title or "") .. " · 256.0 MB", 14) -- 99
			) -- 99
		else -- 99
			____temp_12 = textHeight(detail, 14) -- 100
		end -- 100
		local detailHeight = ____temp_12 -- 98
		local messageTop = detail ~= "" and detailTop + detailHeight + 10 or detailTop -- 101
		local contentBottom = message ~= "" and messageTop + textHeight(message, 14) or (detail ~= "" and detailTop + detailHeight or detailTop - 12) -- 102
		local hasActions = options.mode == "share" or not busy -- 104
		local height = math.min(safe.height - 16, contentBottom + 20 + (hasActions and 126 or 66)) -- 105
		local actionWidth = (width - 52) / 2 -- 106
		local ____toNode_26 = toNode -- 107
		local ____React_createElement_25 = React.createElement -- 107
		local ____temp_23 = { -- 107
			x = -App.visualSize.width / 2, -- 107
			y = -App.visualSize.height / 2, -- 107
			anchorX = 0, -- 107
			anchorY = 0, -- 107
			width = App.visualSize.width, -- 107
			height = App.visualSize.height, -- 107
			touchEnabled = true, -- 107
			swallowTouches = true -- 107
		} -- 107
		local ____React_createElement_result_24 = React.createElement( -- 107
			"draw-node", -- 107
			nil, -- 107
			React.createElement("rect-shape", { -- 107
				centerX = App.visualSize.width / 2, -- 107
				centerY = App.visualSize.height / 2, -- 107
				width = App.visualSize.width, -- 107
				height = App.visualSize.height, -- 107
				fillColor = 2852126720 -- 107
			}) -- 107
		) -- 107
		local ____React_createElement_22 = React.createElement -- 107
		local ____array_21 = __TS__SparseArrayNew( -- 107
			"node", -- 107
			{ -- 107
				tag = "mobile-package-sheet", -- 107
				x = safe.left + (safe.width - width) / 2, -- 107
				y = safe.bottom + 8, -- 107
				width = width, -- 107
				height = height, -- 107
				anchorX = 0, -- 107
				anchorY = 0 -- 107
			}, -- 107
			React.createElement(NativePanelSurface, {width = width, height = height}), -- 107
			React.createElement("label", { -- 107
				x = 20, -- 107
				y = height - titleTop, -- 107
				anchorX = 0, -- 107
				anchorY = 1, -- 107
				fontName = "sarasa-mono-sc-regular", -- 107
				fontSize = 22, -- 107
				text = title, -- 107
				textWidth = width - 40, -- 107
				alignment = "Left" -- 107
			}) -- 107
		) -- 107
		local ____temp_13 -- 112
		if detail == "" then -- 112
			____temp_13 = nil -- 112
		else -- 112
			____temp_13 = React.createElement("label", { -- 112
				tag = "mobile-package-detail", -- 112
				ref = detailRef, -- 112
				x = 20, -- 112
				y = height - detailTop, -- 112
				anchorX = 0, -- 112
				anchorY = 1, -- 112
				fontName = "sarasa-mono-sc-regular", -- 112
				fontSize = 14, -- 112
				text = detail, -- 112
				color3 = 11055037, -- 112
				textWidth = width - 40, -- 112
				alignment = "Left" -- 112
			}) -- 112
		end -- 112
		__TS__SparseArrayPush( -- 112
			____array_21, -- 112
			____temp_13, -- 112
			React.createElement("label", { -- 112
				tag = "mobile-package-status", -- 112
				x = 20, -- 112
				y = height - messageTop, -- 112
				anchorX = 0, -- 112
				anchorY = 1, -- 112
				fontName = "sarasa-mono-sc-regular", -- 112
				fontSize = 14, -- 112
				text = message, -- 112
				color3 = failed and 16739179 or 11055037, -- 112
				textWidth = width - 40, -- 112
				alignment = "Left" -- 112
			}) -- 112
		) -- 112
		local ____temp_20 -- 114
		if not busy and preview then -- 114
			____temp_20 = React.createElement( -- 114
				"node", -- 114
				nil, -- 114
				React.createElement( -- 114
					PackageButton, -- 115
					{ -- 115
						tag = "mobile-package-import-play", -- 115
						x = 20, -- 115
						y = 78, -- 115
						width = actionWidth, -- 115
						text = zh and "导入并试玩" or "Import & play", -- 115
						fontSize = 15, -- 115
						primary = true, -- 115
						onTapped = function() return install(true) end -- 115
					} -- 115
				), -- 115
				React.createElement( -- 115
					PackageButton, -- 116
					{ -- 116
						tag = "mobile-package-import", -- 116
						x = 32 + actionWidth, -- 116
						y = 78, -- 116
						width = actionWidth, -- 116
						text = zh and "仅导入" or "Import", -- 116
						fontSize = 15, -- 116
						onTapped = function() return install(false) end -- 116
					} -- 116
				) -- 116
			) -- 116
		else -- 116
			local ____temp_19 -- 117
			if options.mode == "share" then -- 117
				____temp_19 = React.createElement( -- 117
					"node", -- 117
					nil, -- 117
					React.createElement( -- 117
						PackageButton, -- 118
						{ -- 118
							tag = "mobile-package-share", -- 118
							x = 20, -- 118
							y = 78, -- 118
							width = actionWidth, -- 118
							text = zh and "分享作品" or "Share game", -- 118
							fontSize = 15, -- 118
							primary = true, -- 118
							onTapped = function() -- 118
								if enabled() and exported and not App:shareFile(exported.path) then -- 118
									failed = true -- 118
									message = zh and "无法打开分享面板" or "Could not open share sheet" -- 118
									render() -- 118
								end -- 118
							end -- 118
						} -- 118
					), -- 118
					React.createElement( -- 118
						PackageButton, -- 119
						{ -- 119
							tag = "mobile-package-save", -- 119
							x = 32 + actionWidth, -- 119
							y = 78, -- 119
							width = actionWidth, -- 119
							text = zh and "保存作品包" or "Save package", -- 119
							fontSize = 15, -- 119
							onTapped = function() -- 119
								if enabled() and exported and not App:saveFileDialog(exported.path) then -- 119
									failed = true -- 119
									message = zh and "无法打开保存面板" or "Could not open save dialog" -- 119
									render() -- 119
								end -- 119
							end -- 119
						} -- 119
					) -- 119
				) -- 119
			else -- 119
				local ____temp_18 -- 120
				if not busy then -- 120
					local ____React_createElement_17 = React.createElement -- 120
					local ____options_onNew_16 -- 121
					if options.onNew then -- 121
						____options_onNew_16 = React.createElement( -- 121
							PackageButton, -- 121
							{ -- 121
								tag = "mobile-package-new", -- 121
								x = 20, -- 121
								y = 78, -- 121
								width = actionWidth, -- 121
								text = zh and "新建作品" or "New game", -- 121
								fontSize = 15, -- 121
								onTapped = function() -- 121
									if enabled() then -- 121
										close() -- 121
										local ____opt_14 = options.onNew -- 121
										if ____opt_14 ~= nil then -- 121
											____opt_14() -- 121
										end -- 121
									end -- 121
								end -- 121
							} -- 121
						) -- 121
					else -- 121
						____options_onNew_16 = nil -- 121
					end -- 121
					____temp_18 = ____React_createElement_17( -- 121
						"node", -- 121
						nil, -- 121
						____options_onNew_16, -- 121
						React.createElement(PackageButton, { -- 121
							tag = "mobile-package-pick", -- 121
							x = options.onNew and 32 + actionWidth or 20, -- 121
							y = 78, -- 121
							width = options.onNew and actionWidth or width - 40, -- 121
							text = zh and "导入作品包" or "Import package", -- 121
							fontSize = 15, -- 121
							primary = true, -- 121
							onTapped = pick -- 121
						}) -- 121
					) -- 121
				else -- 121
					____temp_18 = nil -- 123
				end -- 123
				____temp_19 = ____temp_18 -- 120
			end -- 120
			____temp_20 = ____temp_19 -- 117
		end -- 117
		__TS__SparseArrayPush( -- 117
			____array_21, -- 117
			____temp_20, -- 117
			React.createElement(PackageButton, { -- 117
				tag = "mobile-package-close", -- 117
				x = 20, -- 117
				y = 18, -- 117
				width = width - 40, -- 117
				text = zh and "关闭" or "Close", -- 117
				onTapped = close -- 117
			}) -- 117
		) -- 117
		local node = ____toNode_26(____React_createElement_25( -- 107
			"node", -- 107
			____temp_23, -- 107
			____React_createElement_result_24, -- 107
			____React_createElement_22(__TS__SparseArraySpread(____array_21)) -- 107
		)) -- 107
		if node then -- 107
			host:addChild(node) -- 127
		end -- 127
	end -- 76
	attachGamepad(host, {initialTag = "mobile-package-close", isEnabled = enabled, onBack = close}) -- 129
	host:onAppChange(function(setting) -- 130
		if setting == "Size" then -- 130
			render() -- 130
		end -- 130
	end) -- 130
	host:onAppEvent(function(event) -- 131
		if event == "BackButton" and enabled() then -- 131
			close() -- 131
		end -- 131
	end) -- 131
	host:onCleanup(function() -- 132
		active = false -- 132
		if preview then -- 132
			discardPackage(preview) -- 132
		end -- 132
		preview = nil -- 132
	end) -- 132
	host:schedule(function() -- 133
		host.visible = HttpServer.wsConnectionCount == 0 -- 133
		return false -- 133
	end) -- 133
	render() -- 134
	if options.mode == "add" and options.pickOnOpen then -- 134
		pick() -- 135
	end -- 135
	if options.mode == "receive" and options.path then -- 135
		receive(options.path) -- 136
	end -- 136
	if options.mode == "share" and options.entry then -- 136
		thread(function() -- 138
			do -- 138
				local function ____catch(e) -- 138
					failed = true -- 147
					busy = false -- 147
					message = (string.match( -- 148
						tostring(e), -- 148
						":%d+: (.*)$" -- 148
					)) or tostring(e) -- 148
					render() -- 149
				end -- 149
				local ____try, ____hasReturned = pcall(function() -- 149
					exported = exportPackage(options.entry) -- 140
					busy = false -- 141
					if active and host.parent and detailRef.current then -- 141
						detailRef.current.text = (options.entry.title .. " · ") .. string.format("%.1f MB", exported.bytes / 1048576) -- 144
					end -- 144
				end) -- 144
				if not ____try then -- 144
					____catch(____hasReturned) -- 144
				end -- 144
			end -- 144
		end) -- 138
	end -- 138
	return host -- 153
end -- 9
return ____exports -- 9