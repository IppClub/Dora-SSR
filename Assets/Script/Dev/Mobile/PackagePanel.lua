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
		local ____temp_15 = options.mode == "share" and App.platform == "Android" -- 105
		if ____temp_15 then -- 105
			local ____opt_13 = options.entry -- 105
			____temp_15 = (____opt_13 and ____opt_13.workDir) ~= nil -- 105
		end -- 105
		local apk = ____temp_15 and options.entry.fileName ~= nil -- 105
		local buttonHeight = 48 -- 106
		local rowGap = 12 -- 107
		local closeY = 18 -- 108
		local actionY = closeY + buttonHeight + rowGap -- 109
		local shareY = apk and actionY + buttonHeight + rowGap or actionY -- 110
		local footerTop = (hasActions and shareY or closeY) + buttonHeight -- 111
		local height = math.min(safe.height - 16, contentBottom + 20 + footerTop) -- 112
		local actionWidth = (width - 52) / 2 -- 113
		local ____toNode_34 = toNode -- 114
		local ____React_createElement_33 = React.createElement -- 114
		local ____temp_31 = { -- 114
			x = -App.visualSize.width / 2, -- 114
			y = -App.visualSize.height / 2, -- 114
			anchorX = 0, -- 114
			anchorY = 0, -- 114
			width = App.visualSize.width, -- 114
			height = App.visualSize.height, -- 114
			touchEnabled = true, -- 114
			swallowTouches = true -- 114
		} -- 114
		local ____React_createElement_result_32 = React.createElement( -- 114
			"draw-node", -- 114
			nil, -- 114
			React.createElement("rect-shape", { -- 114
				centerX = App.visualSize.width / 2, -- 114
				centerY = App.visualSize.height / 2, -- 114
				width = App.visualSize.width, -- 114
				height = App.visualSize.height, -- 114
				fillColor = 2852126720 -- 114
			}) -- 114
		) -- 114
		local ____React_createElement_30 = React.createElement -- 114
		local ____array_29 = __TS__SparseArrayNew( -- 114
			"node", -- 114
			{ -- 114
				tag = "mobile-package-sheet", -- 114
				x = safe.left + (safe.width - width) / 2, -- 114
				y = safe.bottom + 8, -- 114
				width = width, -- 114
				height = height, -- 114
				anchorX = 0, -- 114
				anchorY = 0 -- 114
			}, -- 114
			React.createElement(NativePanelSurface, {width = width, height = height}), -- 114
			React.createElement("label", { -- 114
				x = 20, -- 114
				y = height - titleTop, -- 114
				anchorX = 0, -- 114
				anchorY = 1, -- 114
				fontName = "sarasa-mono-sc-regular", -- 114
				fontSize = 22, -- 114
				text = title, -- 114
				textWidth = width - 40, -- 114
				alignment = "Left" -- 114
			}) -- 114
		) -- 114
		local ____temp_16 -- 119
		if detail == "" then -- 119
			____temp_16 = nil -- 119
		else -- 119
			____temp_16 = React.createElement("label", { -- 119
				tag = "mobile-package-detail", -- 119
				ref = detailRef, -- 119
				x = 20, -- 119
				y = height - detailTop, -- 119
				anchorX = 0, -- 119
				anchorY = 1, -- 119
				fontName = "sarasa-mono-sc-regular", -- 119
				fontSize = 14, -- 119
				text = detail, -- 119
				color3 = 11055037, -- 119
				textWidth = width - 40, -- 119
				alignment = "Left" -- 119
			}) -- 119
		end -- 119
		__TS__SparseArrayPush( -- 119
			____array_29, -- 119
			____temp_16, -- 119
			React.createElement("label", { -- 119
				tag = "mobile-package-status", -- 119
				x = 20, -- 119
				y = height - messageTop, -- 119
				anchorX = 0, -- 119
				anchorY = 1, -- 119
				fontName = "sarasa-mono-sc-regular", -- 119
				fontSize = 14, -- 119
				text = message, -- 119
				color3 = failed and 16739179 or 11055037, -- 119
				textWidth = width - 40, -- 119
				alignment = "Left" -- 119
			}) -- 119
		) -- 119
		local ____temp_28 -- 121
		if not busy and preview then -- 121
			____temp_28 = React.createElement( -- 121
				"node", -- 121
				nil, -- 121
				React.createElement( -- 121
					PackageButton, -- 122
					{ -- 122
						tag = "mobile-package-import-play", -- 122
						x = 20, -- 122
						y = actionY, -- 122
						width = actionWidth, -- 122
						height = buttonHeight, -- 122
						text = zh and "导入并试玩" or "Import & play", -- 122
						fontSize = 15, -- 122
						primary = true, -- 122
						onTapped = function() return install(true) end -- 122
					} -- 122
				), -- 122
				React.createElement( -- 122
					PackageButton, -- 123
					{ -- 123
						tag = "mobile-package-import", -- 123
						x = 32 + actionWidth, -- 123
						y = actionY, -- 123
						width = actionWidth, -- 123
						height = buttonHeight, -- 123
						text = zh and "仅导入" or "Import", -- 123
						fontSize = 15, -- 123
						onTapped = function() return install(false) end -- 123
					} -- 123
				) -- 123
			) -- 123
		else -- 123
			local ____temp_27 -- 124
			if options.mode == "share" then -- 124
				local ____React_createElement_21 = React.createElement -- 124
				local ____React_createElement_result_19 = React.createElement( -- 124
					PackageButton, -- 125
					{ -- 125
						tag = "mobile-package-share", -- 125
						x = 20, -- 125
						y = shareY, -- 125
						width = actionWidth, -- 125
						height = buttonHeight, -- 125
						text = zh and "分享作品" or "Share game", -- 125
						fontSize = 15, -- 125
						primary = true, -- 125
						onTapped = function() -- 125
							if enabled() and exported and not App:shareFile(exported.path) then -- 125
								failed = true -- 125
								message = zh and "无法打开分享面板" or "Could not open share sheet" -- 125
								render() -- 125
							end -- 125
						end -- 125
					} -- 125
				) -- 125
				local ____React_createElement_result_20 = React.createElement( -- 125
					PackageButton, -- 126
					{ -- 126
						tag = "mobile-package-save", -- 126
						x = 32 + actionWidth, -- 126
						y = shareY, -- 126
						width = actionWidth, -- 126
						height = buttonHeight, -- 126
						text = zh and "保存作品包" or "Save package", -- 126
						fontSize = 15, -- 126
						onTapped = function() -- 126
							if enabled() and exported and not App:saveFileDialog(exported.path) then -- 126
								failed = true -- 126
								message = zh and "无法打开保存面板" or "Could not open save dialog" -- 126
								render() -- 126
							end -- 126
						end -- 126
					} -- 126
				) -- 126
				local ____apk_18 -- 127
				if apk then -- 127
					____apk_18 = React.createElement( -- 127
						PackageButton, -- 127
						{ -- 127
							tag = "mobile-package-apk", -- 127
							x = 20, -- 127
							y = actionY, -- 127
							width = width - 40, -- 127
							height = buttonHeight, -- 127
							text = zh and "导出 APK" or "Export APK", -- 127
							fontSize = 15, -- 127
							onTapped = function() -- 127
								local ____temp_17 = options.entry or ({}) -- 128
								local workDir = ____temp_17.workDir -- 128
								local fileName = ____temp_17.fileName -- 128
								local title = ____temp_17.title -- 128
								if not enabled() or not workDir or not fileName or not title then -- 128
									return -- 129
								end -- 129
								busy = true -- 130
								message = zh and "正在准备游戏文件…" or "Preparing game files…" -- 131
								render() -- 132
								thread(function() -- 133
									local ok, detail = pcall(function() -- 134
										local module = "Script.Dev.NativeGameExport" -- 135
										local exporter = require(module) -- 136
										exporter.exportAndroid(workDir, fileName, title) -- 137
									end) -- 134
									if not active then -- 134
										return -- 139
									end -- 139
									busy = false -- 140
									failed = not ok -- 141
									message = ok and (zh and "接收者导入后可以试玩，也可以继续改编。" or "Recipients can import, play, and Remix this game.") or tostring(detail) -- 142
									render() -- 143
								end) -- 133
							end -- 127
						} -- 127
					) -- 127
				else -- 127
					____apk_18 = nil -- 145
				end -- 145
				____temp_27 = ____React_createElement_21( -- 145
					"node", -- 145
					nil, -- 145
					____React_createElement_result_19, -- 145
					____React_createElement_result_20, -- 145
					____apk_18 -- 145
				) -- 145
			else -- 145
				local ____temp_26 -- 146
				if not busy then -- 146
					local ____React_createElement_25 = React.createElement -- 146
					local ____options_onNew_24 -- 147
					if options.onNew then -- 147
						____options_onNew_24 = React.createElement( -- 147
							PackageButton, -- 147
							{ -- 147
								tag = "mobile-package-new", -- 147
								x = 20, -- 147
								y = actionY, -- 147
								width = actionWidth, -- 147
								height = buttonHeight, -- 147
								text = zh and "新建作品" or "New game", -- 147
								fontSize = 15, -- 147
								onTapped = function() -- 147
									if enabled() then -- 147
										close() -- 147
										local ____opt_22 = options.onNew -- 147
										if ____opt_22 ~= nil then -- 147
											____opt_22() -- 147
										end -- 147
									end -- 147
								end -- 147
							} -- 147
						) -- 147
					else -- 147
						____options_onNew_24 = nil -- 147
					end -- 147
					____temp_26 = ____React_createElement_25( -- 147
						"node", -- 147
						nil, -- 147
						____options_onNew_24, -- 147
						React.createElement(PackageButton, { -- 147
							tag = "mobile-package-pick", -- 147
							x = options.onNew and 32 + actionWidth or 20, -- 147
							y = actionY, -- 147
							width = options.onNew and actionWidth or width - 40, -- 147
							height = buttonHeight, -- 147
							text = zh and "导入作品包" or "Import package", -- 147
							fontSize = 15, -- 147
							primary = true, -- 147
							onTapped = pick -- 147
						}) -- 147
					) -- 147
				else -- 147
					____temp_26 = nil -- 149
				end -- 149
				____temp_27 = ____temp_26 -- 146
			end -- 146
			____temp_28 = ____temp_27 -- 124
		end -- 124
		__TS__SparseArrayPush( -- 124
			____array_29, -- 124
			____temp_28, -- 124
			React.createElement(PackageButton, { -- 124
				tag = "mobile-package-close", -- 124
				x = 20, -- 124
				y = closeY, -- 124
				width = width - 40, -- 124
				height = buttonHeight, -- 124
				text = zh and "关闭" or "Close", -- 124
				onTapped = close -- 124
			}) -- 124
		) -- 124
		local node = ____toNode_34(____React_createElement_33( -- 114
			"node", -- 114
			____temp_31, -- 114
			____React_createElement_result_32, -- 114
			____React_createElement_30(__TS__SparseArraySpread(____array_29)) -- 114
		)) -- 114
		if node then -- 114
			host:addChild(node) -- 153
		end -- 153
	end -- 76
	attachGamepad(host, {initialTag = "mobile-package-close", isEnabled = enabled, onBack = close}) -- 155
	host:onAppChange(function(setting) -- 156
		if setting == "Size" then -- 156
			render() -- 156
		end -- 156
	end) -- 156
	host:onAppEvent(function(event) -- 157
		if event == "BackButton" and enabled() then -- 157
			close() -- 157
		end -- 157
	end) -- 157
	host:onCleanup(function() -- 158
		active = false -- 158
		if preview then -- 158
			discardPackage(preview) -- 158
		end -- 158
		preview = nil -- 158
	end) -- 158
	host:schedule(function() -- 159
		host.visible = HttpServer.wsConnectionCount == 0 -- 159
		return false -- 159
	end) -- 159
	render() -- 160
	if options.mode == "add" and options.pickOnOpen then -- 160
		pick() -- 161
	end -- 161
	if options.mode == "receive" and options.path then -- 161
		receive(options.path) -- 162
	end -- 162
	if options.mode == "share" and options.entry then -- 162
		thread(function() -- 164
			do -- 164
				local function ____catch(e) -- 164
					failed = true -- 173
					busy = false -- 173
					message = (string.match( -- 174
						tostring(e), -- 174
						":%d+: (.*)$" -- 174
					)) or tostring(e) -- 174
					render() -- 175
				end -- 175
				local ____try, ____hasReturned = pcall(function() -- 175
					exported = exportPackage(options.entry) -- 166
					busy = false -- 167
					if active and host.parent and detailRef.current then -- 167
						detailRef.current.text = (options.entry.title .. " · ") .. string.format("%.1f MB", exported.bytes / 1048576) -- 170
					end -- 170
				end) -- 170
				if not ____try then -- 170
					____catch(____hasReturned) -- 170
				end -- 170
			end -- 170
		end) -- 164
	end -- 164
	return host -- 179
end -- 9
return ____exports -- 9