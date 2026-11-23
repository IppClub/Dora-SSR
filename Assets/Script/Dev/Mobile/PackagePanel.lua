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
		local actionY = apk and 128 or 78 -- 106
		local height = math.min(safe.height - 16, contentBottom + 20 + (hasActions and (apk and 176 or 126) or 66)) -- 107
		local actionWidth = (width - 52) / 2 -- 108
		local ____toNode_34 = toNode -- 109
		local ____React_createElement_33 = React.createElement -- 109
		local ____temp_31 = { -- 109
			x = -App.visualSize.width / 2, -- 109
			y = -App.visualSize.height / 2, -- 109
			anchorX = 0, -- 109
			anchorY = 0, -- 109
			width = App.visualSize.width, -- 109
			height = App.visualSize.height, -- 109
			touchEnabled = true, -- 109
			swallowTouches = true -- 109
		} -- 109
		local ____React_createElement_result_32 = React.createElement( -- 109
			"draw-node", -- 109
			nil, -- 109
			React.createElement("rect-shape", { -- 109
				centerX = App.visualSize.width / 2, -- 109
				centerY = App.visualSize.height / 2, -- 109
				width = App.visualSize.width, -- 109
				height = App.visualSize.height, -- 109
				fillColor = 2852126720 -- 109
			}) -- 109
		) -- 109
		local ____React_createElement_30 = React.createElement -- 109
		local ____array_29 = __TS__SparseArrayNew( -- 109
			"node", -- 109
			{ -- 109
				tag = "mobile-package-sheet", -- 109
				x = safe.left + (safe.width - width) / 2, -- 109
				y = safe.bottom + 8, -- 109
				width = width, -- 109
				height = height, -- 109
				anchorX = 0, -- 109
				anchorY = 0 -- 109
			}, -- 109
			React.createElement(NativePanelSurface, {width = width, height = height}), -- 109
			React.createElement("label", { -- 109
				x = 20, -- 109
				y = height - titleTop, -- 109
				anchorX = 0, -- 109
				anchorY = 1, -- 109
				fontName = "sarasa-mono-sc-regular", -- 109
				fontSize = 22, -- 109
				text = title, -- 109
				textWidth = width - 40, -- 109
				alignment = "Left" -- 109
			}) -- 109
		) -- 109
		local ____temp_16 -- 114
		if detail == "" then -- 114
			____temp_16 = nil -- 114
		else -- 114
			____temp_16 = React.createElement("label", { -- 114
				tag = "mobile-package-detail", -- 114
				ref = detailRef, -- 114
				x = 20, -- 114
				y = height - detailTop, -- 114
				anchorX = 0, -- 114
				anchorY = 1, -- 114
				fontName = "sarasa-mono-sc-regular", -- 114
				fontSize = 14, -- 114
				text = detail, -- 114
				color3 = 11055037, -- 114
				textWidth = width - 40, -- 114
				alignment = "Left" -- 114
			}) -- 114
		end -- 114
		__TS__SparseArrayPush( -- 114
			____array_29, -- 114
			____temp_16, -- 114
			React.createElement("label", { -- 114
				tag = "mobile-package-status", -- 114
				x = 20, -- 114
				y = height - messageTop, -- 114
				anchorX = 0, -- 114
				anchorY = 1, -- 114
				fontName = "sarasa-mono-sc-regular", -- 114
				fontSize = 14, -- 114
				text = message, -- 114
				color3 = failed and 16739179 or 11055037, -- 114
				textWidth = width - 40, -- 114
				alignment = "Left" -- 114
			}) -- 114
		) -- 114
		local ____temp_28 -- 116
		if not busy and preview then -- 116
			____temp_28 = React.createElement( -- 116
				"node", -- 116
				nil, -- 116
				React.createElement( -- 116
					PackageButton, -- 117
					{ -- 117
						tag = "mobile-package-import-play", -- 117
						x = 20, -- 117
						y = 78, -- 117
						width = actionWidth, -- 117
						text = zh and "导入并试玩" or "Import & play", -- 117
						fontSize = 15, -- 117
						primary = true, -- 117
						onTapped = function() return install(true) end -- 117
					} -- 117
				), -- 117
				React.createElement( -- 117
					PackageButton, -- 118
					{ -- 118
						tag = "mobile-package-import", -- 118
						x = 32 + actionWidth, -- 118
						y = 78, -- 118
						width = actionWidth, -- 118
						text = zh and "仅导入" or "Import", -- 118
						fontSize = 15, -- 118
						onTapped = function() return install(false) end -- 118
					} -- 118
				) -- 118
			) -- 118
		else -- 118
			local ____temp_27 -- 119
			if options.mode == "share" then -- 119
				local ____React_createElement_21 = React.createElement -- 119
				local ____React_createElement_result_19 = React.createElement( -- 119
					PackageButton, -- 120
					{ -- 120
						tag = "mobile-package-share", -- 120
						x = 20, -- 120
						y = actionY, -- 120
						width = actionWidth, -- 120
						text = zh and "分享作品" or "Share game", -- 120
						fontSize = 15, -- 120
						primary = true, -- 120
						onTapped = function() -- 120
							if enabled() and exported and not App:shareFile(exported.path) then -- 120
								failed = true -- 120
								message = zh and "无法打开分享面板" or "Could not open share sheet" -- 120
								render() -- 120
							end -- 120
						end -- 120
					} -- 120
				) -- 120
				local ____React_createElement_result_20 = React.createElement( -- 120
					PackageButton, -- 121
					{ -- 121
						tag = "mobile-package-save", -- 121
						x = 32 + actionWidth, -- 121
						y = actionY, -- 121
						width = actionWidth, -- 121
						text = zh and "保存作品包" or "Save package", -- 121
						fontSize = 15, -- 121
						onTapped = function() -- 121
							if enabled() and exported and not App:saveFileDialog(exported.path) then -- 121
								failed = true -- 121
								message = zh and "无法打开保存面板" or "Could not open save dialog" -- 121
								render() -- 121
							end -- 121
						end -- 121
					} -- 121
				) -- 121
				local ____apk_18 -- 122
				if apk then -- 122
					____apk_18 = React.createElement( -- 122
						PackageButton, -- 122
						{ -- 122
							tag = "mobile-package-apk", -- 122
							x = 20, -- 122
							y = 78, -- 122
							width = width - 40, -- 122
							text = zh and "导出 APK" or "Export APK", -- 122
							fontSize = 15, -- 122
							onTapped = function() -- 122
								local ____temp_17 = options.entry or ({}) -- 123
								local workDir = ____temp_17.workDir -- 123
								local fileName = ____temp_17.fileName -- 123
								local title = ____temp_17.title -- 123
								if not enabled() or not workDir or not fileName or not title then -- 123
									return -- 124
								end -- 124
								busy = true -- 125
								message = zh and "正在准备游戏文件…" or "Preparing game files…" -- 126
								render() -- 127
								thread(function() -- 128
									local ok, detail = pcall(function() -- 129
										local module = "Script.Dev.NativeGameExport" -- 130
										local exporter = require(module) -- 131
										exporter.exportAndroid(workDir, fileName, title) -- 132
									end) -- 129
									if not active then -- 129
										return -- 134
									end -- 134
									busy = false -- 135
									failed = not ok -- 136
									message = ok and (zh and "接收者导入后可以试玩，也可以继续改编。" or "Recipients can import, play, and Remix this game.") or tostring(detail) -- 137
									render() -- 138
								end) -- 128
							end -- 122
						} -- 122
					) -- 122
				else -- 122
					____apk_18 = nil -- 140
				end -- 140
				____temp_27 = ____React_createElement_21( -- 140
					"node", -- 140
					nil, -- 140
					____React_createElement_result_19, -- 140
					____React_createElement_result_20, -- 140
					____apk_18 -- 140
				) -- 140
			else -- 140
				local ____temp_26 -- 141
				if not busy then -- 141
					local ____React_createElement_25 = React.createElement -- 141
					local ____options_onNew_24 -- 142
					if options.onNew then -- 142
						____options_onNew_24 = React.createElement( -- 142
							PackageButton, -- 142
							{ -- 142
								tag = "mobile-package-new", -- 142
								x = 20, -- 142
								y = 78, -- 142
								width = actionWidth, -- 142
								text = zh and "新建作品" or "New game", -- 142
								fontSize = 15, -- 142
								onTapped = function() -- 142
									if enabled() then -- 142
										close() -- 142
										local ____opt_22 = options.onNew -- 142
										if ____opt_22 ~= nil then -- 142
											____opt_22() -- 142
										end -- 142
									end -- 142
								end -- 142
							} -- 142
						) -- 142
					else -- 142
						____options_onNew_24 = nil -- 142
					end -- 142
					____temp_26 = ____React_createElement_25( -- 142
						"node", -- 142
						nil, -- 142
						____options_onNew_24, -- 142
						React.createElement(PackageButton, { -- 142
							tag = "mobile-package-pick", -- 142
							x = options.onNew and 32 + actionWidth or 20, -- 142
							y = 78, -- 142
							width = options.onNew and actionWidth or width - 40, -- 142
							text = zh and "导入作品包" or "Import package", -- 142
							fontSize = 15, -- 142
							primary = true, -- 142
							onTapped = pick -- 142
						}) -- 142
					) -- 142
				else -- 142
					____temp_26 = nil -- 144
				end -- 144
				____temp_27 = ____temp_26 -- 141
			end -- 141
			____temp_28 = ____temp_27 -- 119
		end -- 119
		__TS__SparseArrayPush( -- 119
			____array_29, -- 119
			____temp_28, -- 119
			React.createElement(PackageButton, { -- 119
				tag = "mobile-package-close", -- 119
				x = 20, -- 119
				y = 18, -- 119
				width = width - 40, -- 119
				text = zh and "关闭" or "Close", -- 119
				onTapped = close -- 119
			}) -- 119
		) -- 119
		local node = ____toNode_34(____React_createElement_33( -- 109
			"node", -- 109
			____temp_31, -- 109
			____React_createElement_result_32, -- 109
			____React_createElement_30(__TS__SparseArraySpread(____array_29)) -- 109
		)) -- 109
		if node then -- 109
			host:addChild(node) -- 148
		end -- 148
	end -- 76
	attachGamepad(host, {initialTag = "mobile-package-close", isEnabled = enabled, onBack = close}) -- 150
	host:onAppChange(function(setting) -- 151
		if setting == "Size" then -- 151
			render() -- 151
		end -- 151
	end) -- 151
	host:onAppEvent(function(event) -- 152
		if event == "BackButton" and enabled() then -- 152
			close() -- 152
		end -- 152
	end) -- 152
	host:onCleanup(function() -- 153
		active = false -- 153
		if preview then -- 153
			discardPackage(preview) -- 153
		end -- 153
		preview = nil -- 153
	end) -- 153
	host:schedule(function() -- 154
		host.visible = HttpServer.wsConnectionCount == 0 -- 154
		return false -- 154
	end) -- 154
	render() -- 155
	if options.mode == "add" and options.pickOnOpen then -- 155
		pick() -- 156
	end -- 156
	if options.mode == "receive" and options.path then -- 156
		receive(options.path) -- 157
	end -- 157
	if options.mode == "share" and options.entry then -- 157
		thread(function() -- 159
			do -- 159
				local function ____catch(e) -- 159
					failed = true -- 168
					busy = false -- 168
					message = (string.match( -- 169
						tostring(e), -- 169
						":%d+: (.*)$" -- 169
					)) or tostring(e) -- 169
					render() -- 170
				end -- 170
				local ____try, ____hasReturned = pcall(function() -- 170
					exported = exportPackage(options.entry) -- 161
					busy = false -- 162
					if active and host.parent and detailRef.current then -- 162
						detailRef.current.text = (options.entry.title .. " · ") .. string.format("%.1f MB", exported.bytes / 1048576) -- 165
					end -- 165
				end) -- 165
				if not ____try then -- 165
					____catch(____hasReturned) -- 165
				end -- 165
			end -- 165
		end) -- 159
	end -- 159
	return host -- 174
end -- 9
return ____exports -- 9