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
local Color = ____Dora.Color -- 2
local Director = ____Dora.Director -- 2
local DrawNode = ____Dora.DrawNode -- 2
local HttpServer = ____Dora.HttpServer -- 2
local Label = ____Dora.Label -- 2
local Node = ____Dora.Node -- 2
local Vec2 = ____Dora.Vec2 -- 2
local thread = ____Dora.thread -- 2
local ____Gamepad = require("Dev.Mobile.Gamepad") -- 3
local attachGamepad = ____Gamepad.attachGamepad -- 3
local ____Package = require("Dev.Mobile.Package") -- 4
local discardPackage = ____Package.discardPackage -- 4
local exportPackage = ____Package.exportPackage -- 4
local inspectPackage = ____Package.inspectPackage -- 4
local installPackage = ____Package.installPackage -- 4
local function PackageSurface(props) -- 9
	return React.createElement( -- 10
		"custom-node", -- 10
		{onCreate = function() -- 10
			local draw = DrawNode() -- 11
			local vertices = {} -- 12
			local r = props.radius -- 13
			for ____, corner in ipairs({{x = props.width - r, y = r, angle = -math.pi / 2}, {x = props.width - r, y = props.height - r, angle = 0}, {x = r, y = props.height - r, angle = math.pi / 2}, {x = r, y = r, angle = math.pi}}) do -- 14
				do -- 14
					local i = 0 -- 20
					while i <= 8 do -- 20
						local angle = corner.angle + i * math.pi / 16 -- 21
						vertices[#vertices + 1] = Vec2( -- 22
							corner.x + math.cos(angle) * r, -- 22
							corner.y + math.sin(angle) * r -- 22
						) -- 22
						i = i + 1 -- 20
					end -- 20
				end -- 20
			end -- 20
			draw:drawPolygon( -- 25
				vertices, -- 25
				Color(props.color), -- 25
				1, -- 25
				Color(4281613128) -- 25
			) -- 25
			return draw -- 26
		end} -- 10
	) -- 10
end -- 9
local function PackageButton(props) -- 30
	return React.createElement( -- 31
		"node", -- 31
		{ -- 31
			tag = props.tag, -- 31
			x = props.x, -- 31
			y = props.y, -- 31
			width = props.width, -- 31
			height = 48, -- 31
			anchorX = 0, -- 31
			anchorY = 0, -- 31
			touchEnabled = true, -- 31
			swallowTouches = true, -- 31
			onTapped = props.onTapped -- 31
		}, -- 31
		React.createElement(PackageSurface, {width = props.width, height = 48, radius = 14, color = props.primary and 4294955851 or 4280560698}), -- 31
		React.createElement("label", { -- 31
			x = props.width / 2, -- 31
			y = 24, -- 31
			fontName = "sarasa-mono-sc-regular", -- 31
			fontSize = props.fontSize or 17, -- 31
			text = props.text, -- 31
			color3 = props.primary and 1512202 or 16052712 -- 31
		}) -- 31
	) -- 31
end -- 30
function ____exports.startPackagePanel(options) -- 37
	local render -- 37
	local host = Node() -- 45
	host.tag = "mobile-package-panel" -- 46
	host.order = 20000 -- 47
	host:addTo(Director.systemUI) -- 48
	local active = true -- 49
	local busy = options.mode == "share" and options.entry ~= nil -- 50
	local preview -- 51
	local exported -- 52
	local detailRef = reference() -- 53
	local message = options.mode == "share" and (__TS__StringStartsWith( -- 54
		string.lower(App.locale), -- 54
		"zh" -- 54
	) and "接收者导入后可以试玩，也可以继续改编。" or "Recipients can import, play, and Remix this game.") or "" -- 54
	local failed = false -- 55
	local zh = __TS__StringStartsWith( -- 56
		string.lower(App.locale), -- 56
		"zh" -- 56
	) -- 56
	local function enabled() -- 57
		return active and host.parent ~= nil and host.visible and HttpServer.wsConnectionCount == 0 and not busy -- 57
	end -- 57
	local function close() -- 58
		if busy or not active then -- 58
			return -- 59
		end -- 59
		active = false -- 60
		if preview then -- 60
			discardPackage(preview) -- 61
		end -- 61
		preview = nil -- 62
		host:removeFromParent(true) -- 63
		options.onClosed() -- 64
	end -- 58
	local function receive(path) -- 66
		if not active then -- 66
			return -- 67
		end -- 67
		busy = true -- 68
		failed = false -- 68
		message = zh and "正在检查作品包…" or "Checking game package…" -- 69
		render() -- 70
		thread(function() -- 71
			do -- 71
				local function ____catch(e) -- 71
					failed = true -- 77
					message = (string.match( -- 77
						tostring(e), -- 77
						":%d+: (.*)$" -- 77
					)) or tostring(e) -- 77
				end -- 77
				local ____try, ____hasReturned, ____returnValue = pcall(function() -- 77
					local result = inspectPackage(path) -- 73
					if not active or not host.parent then -- 73
						discardPackage(result) -- 74
						return true -- 74
					end -- 74
					preview = result -- 75
					message = zh and "包含代码与素材，导入后可试玩和 Remix。" or "Includes code and assets. Import to play or Remix." -- 76
				end) -- 76
				if not ____try then -- 76
					____hasReturned, ____returnValue = ____catch(____hasReturned) -- 76
				end -- 76
				do -- 76
					busy = false -- 79
					render() -- 79
				end -- 79
				if ____hasReturned then -- 79
					return ____returnValue -- 72
				end -- 72
			end -- 72
		end) -- 71
	end -- 66
	local function pick() -- 83
		if not enabled() then -- 83
			return -- 84
		end -- 84
		busy = true -- 85
		message = zh and "请选择 ZIP 作品包" or "Choose a ZIP game package" -- 85
		render() -- 85
		App:openFileDialog( -- 86
			false, -- 86
			function(path) -- 86
				busy = false -- 87
				if not active or not host.parent then -- 87
					return -- 88
				end -- 88
				if path ~= "" then -- 88
					receive(path) -- 89
				else -- 89
					message = "" -- 90
					render() -- 90
				end -- 90
			end -- 86
		) -- 86
	end -- 83
	local function install(play) -- 93
		if not enabled() or not preview then -- 93
			return -- 94
		end -- 94
		do -- 94
			local function ____catch(e) -- 94
				failed = true -- 100
				message = (string.match( -- 100
					tostring(e), -- 100
					":%d+: (.*)$" -- 100
				)) or tostring(e) -- 100
				render() -- 100
			end -- 100
			local ____try, ____hasReturned = pcall(function() -- 100
				local entry = installPackage(preview) -- 96
				preview = nil -- 97
				close() -- 98
				local ____opt_0 = options.onImported -- 98
				if ____opt_0 ~= nil then -- 98
					____opt_0(entry, play) -- 99
				end -- 99
			end) -- 99
			if not ____try then -- 99
				____catch(____hasReturned) -- 99
			end -- 99
		end -- 99
	end -- 93
	render = function() -- 102
		if not active or not host.parent then -- 102
			return -- 103
		end -- 103
		host:removeAllChildren() -- 104
		host.scaleX = App.devicePixelRatio -- 105
		host.scaleY = App.devicePixelRatio -- 105
		local safe = App.safeArea -- 106
		local width = math.min(safe.width, 540) -- 107
		local title = preview and preview.title or (options.mode == "share" and (zh and "分享作品" or "Share game") or (zh and "添加作品" or "Add game")) -- 108
		local ____preview_5 -- 109
		if preview then -- 109
			____preview_5 = (preview.author and preview.author .. " · " or "") .. string.format("%.1f MB", preview.bytes / 1048576) -- 109
		else -- 109
			local ____temp_4 -- 110
			if options.mode == "share" then -- 110
				local ____opt_2 = options.entry -- 110
				____temp_4 = ((____opt_2 and ____opt_2.title or "") .. " · ") .. (exported and string.format("%.1f MB", exported.bytes / 1048576) or (zh and "打包中…" or "Packaging…")) -- 110
			else -- 110
				____temp_4 = "" -- 110
			end -- 110
			____preview_5 = ____temp_4 -- 110
		end -- 110
		local detail = ____preview_5 -- 109
		local function textHeight(text, fontSize) -- 111
			if text == "" then -- 111
				return 0 -- 112
			end -- 112
			local label = Label("sarasa-mono-sc-regular", fontSize) -- 113
			label.textWidth = width - 40 -- 114
			label.text = text -- 115
			local height = math.max( -- 116
				fontSize, -- 116
				math.ceil(label.height) -- 116
			) -- 116
			label:cleanup() -- 118
			return height -- 119
		end -- 111
		local titleTop = 20 -- 121
		local detailTop = titleTop + textHeight(title, 22) + 12 -- 122
		local ____temp_12 -- 124
		if options.mode == "share" then -- 124
			local ____math_max_11 = math.max -- 125
			local ____opt_6 = options.entry -- 125
			local ____textHeight_result_10 = textHeight(((____opt_6 and ____opt_6.title or "") .. " · ") .. (zh and "打包中…" or "Packaging…"), 14) -- 125
			local ____opt_8 = options.entry -- 125
			____temp_12 = ____math_max_11( -- 125
				____textHeight_result_10, -- 125
				textHeight((____opt_8 and ____opt_8.title or "") .. " · 256.0 MB", 14) -- 125
			) -- 125
		else -- 125
			____temp_12 = textHeight(detail, 14) -- 126
		end -- 126
		local detailHeight = ____temp_12 -- 124
		local messageTop = detail ~= "" and detailTop + detailHeight + 10 or detailTop -- 127
		local contentBottom = message ~= "" and messageTop + textHeight(message, 14) or (detail ~= "" and detailTop + detailHeight or detailTop - 12) -- 128
		local hasActions = options.mode == "share" or not busy -- 130
		local height = math.min(safe.height - 16, contentBottom + 20 + (hasActions and 126 or 66)) -- 131
		local actionWidth = (width - 52) / 2 -- 132
		local ____toNode_26 = toNode -- 133
		local ____React_createElement_25 = React.createElement -- 133
		local ____temp_23 = { -- 133
			x = -App.visualSize.width / 2, -- 133
			y = -App.visualSize.height / 2, -- 133
			anchorX = 0, -- 133
			anchorY = 0, -- 133
			width = App.visualSize.width, -- 133
			height = App.visualSize.height, -- 133
			touchEnabled = true, -- 133
			swallowTouches = true -- 133
		} -- 133
		local ____React_createElement_result_24 = React.createElement( -- 133
			"draw-node", -- 133
			nil, -- 133
			React.createElement("rect-shape", { -- 133
				centerX = App.visualSize.width / 2, -- 133
				centerY = App.visualSize.height / 2, -- 133
				width = App.visualSize.width, -- 133
				height = App.visualSize.height, -- 133
				fillColor = 2852126720 -- 133
			}) -- 133
		) -- 133
		local ____React_createElement_22 = React.createElement -- 133
		local ____array_21 = __TS__SparseArrayNew( -- 133
			"node", -- 133
			{ -- 133
				tag = "mobile-package-sheet", -- 133
				x = safe.left + (safe.width - width) / 2, -- 133
				y = safe.bottom + 8, -- 133
				width = width, -- 133
				height = height, -- 133
				anchorX = 0, -- 133
				anchorY = 0 -- 133
			}, -- 133
			React.createElement(PackageSurface, {width = width, height = height, radius = 24, color = 4279573803}), -- 133
			React.createElement("label", { -- 133
				x = 20, -- 133
				y = height - titleTop, -- 133
				anchorX = 0, -- 133
				anchorY = 1, -- 133
				fontName = "sarasa-mono-sc-regular", -- 133
				fontSize = 22, -- 133
				text = title, -- 133
				textWidth = width - 40, -- 133
				alignment = "Left" -- 133
			}) -- 133
		) -- 133
		local ____temp_13 -- 138
		if detail == "" then -- 138
			____temp_13 = nil -- 138
		else -- 138
			____temp_13 = React.createElement("label", { -- 138
				tag = "mobile-package-detail", -- 138
				ref = detailRef, -- 138
				x = 20, -- 138
				y = height - detailTop, -- 138
				anchorX = 0, -- 138
				anchorY = 1, -- 138
				fontName = "sarasa-mono-sc-regular", -- 138
				fontSize = 14, -- 138
				text = detail, -- 138
				color3 = 11055037, -- 138
				textWidth = width - 40, -- 138
				alignment = "Left" -- 138
			}) -- 138
		end -- 138
		__TS__SparseArrayPush( -- 138
			____array_21, -- 138
			____temp_13, -- 138
			React.createElement("label", { -- 138
				tag = "mobile-package-status", -- 138
				x = 20, -- 138
				y = height - messageTop, -- 138
				anchorX = 0, -- 138
				anchorY = 1, -- 138
				fontName = "sarasa-mono-sc-regular", -- 138
				fontSize = 14, -- 138
				text = message, -- 138
				color3 = failed and 16739179 or 11055037, -- 138
				textWidth = width - 40, -- 138
				alignment = "Left" -- 138
			}) -- 138
		) -- 138
		local ____temp_20 -- 140
		if not busy and preview then -- 140
			____temp_20 = React.createElement( -- 140
				"node", -- 140
				nil, -- 140
				React.createElement( -- 140
					PackageButton, -- 141
					{ -- 141
						tag = "mobile-package-import-play", -- 141
						x = 20, -- 141
						y = 78, -- 141
						width = actionWidth, -- 141
						text = zh and "导入并试玩" or "Import & play", -- 141
						fontSize = 15, -- 141
						primary = true, -- 141
						onTapped = function() return install(true) end -- 141
					} -- 141
				), -- 141
				React.createElement( -- 141
					PackageButton, -- 142
					{ -- 142
						tag = "mobile-package-import", -- 142
						x = 32 + actionWidth, -- 142
						y = 78, -- 142
						width = actionWidth, -- 142
						text = zh and "仅导入" or "Import", -- 142
						fontSize = 15, -- 142
						onTapped = function() return install(false) end -- 142
					} -- 142
				) -- 142
			) -- 142
		else -- 142
			local ____temp_19 -- 143
			if options.mode == "share" then -- 143
				____temp_19 = React.createElement( -- 143
					"node", -- 143
					nil, -- 143
					React.createElement( -- 143
						PackageButton, -- 144
						{ -- 144
							tag = "mobile-package-share", -- 144
							x = 20, -- 144
							y = 78, -- 144
							width = actionWidth, -- 144
							text = zh and "分享作品" or "Share game", -- 144
							fontSize = 15, -- 144
							primary = true, -- 144
							onTapped = function() -- 144
								if enabled() and exported and not App:shareFile(exported.path) then -- 144
									failed = true -- 144
									message = zh and "无法打开分享面板" or "Could not open share sheet" -- 144
									render() -- 144
								end -- 144
							end -- 144
						} -- 144
					), -- 144
					React.createElement( -- 144
						PackageButton, -- 145
						{ -- 145
							tag = "mobile-package-save", -- 145
							x = 32 + actionWidth, -- 145
							y = 78, -- 145
							width = actionWidth, -- 145
							text = zh and "保存作品包" or "Save package", -- 145
							fontSize = 15, -- 145
							onTapped = function() -- 145
								if enabled() and exported and not App:saveFileDialog(exported.path) then -- 145
									failed = true -- 145
									message = zh and "无法打开保存面板" or "Could not open save dialog" -- 145
									render() -- 145
								end -- 145
							end -- 145
						} -- 145
					) -- 145
				) -- 145
			else -- 145
				local ____temp_18 -- 146
				if not busy then -- 146
					local ____React_createElement_17 = React.createElement -- 146
					local ____options_onNew_16 -- 147
					if options.onNew then -- 147
						____options_onNew_16 = React.createElement( -- 147
							PackageButton, -- 147
							{ -- 147
								tag = "mobile-package-new", -- 147
								x = 20, -- 147
								y = 78, -- 147
								width = actionWidth, -- 147
								text = zh and "新建作品" or "New game", -- 147
								fontSize = 15, -- 147
								onTapped = function() -- 147
									if enabled() then -- 147
										close() -- 147
										local ____opt_14 = options.onNew -- 147
										if ____opt_14 ~= nil then -- 147
											____opt_14() -- 147
										end -- 147
									end -- 147
								end -- 147
							} -- 147
						) -- 147
					else -- 147
						____options_onNew_16 = nil -- 147
					end -- 147
					____temp_18 = ____React_createElement_17( -- 147
						"node", -- 147
						nil, -- 147
						____options_onNew_16, -- 147
						React.createElement(PackageButton, { -- 147
							tag = "mobile-package-pick", -- 147
							x = options.onNew and 32 + actionWidth or 20, -- 147
							y = 78, -- 147
							width = options.onNew and actionWidth or width - 40, -- 147
							text = zh and "导入作品包" or "Import package", -- 147
							fontSize = 15, -- 147
							primary = true, -- 147
							onTapped = pick -- 147
						}) -- 147
					) -- 147
				else -- 147
					____temp_18 = nil -- 149
				end -- 149
				____temp_19 = ____temp_18 -- 146
			end -- 146
			____temp_20 = ____temp_19 -- 143
		end -- 143
		__TS__SparseArrayPush( -- 143
			____array_21, -- 143
			____temp_20, -- 143
			React.createElement(PackageButton, { -- 143
				tag = "mobile-package-close", -- 143
				x = 20, -- 143
				y = 18, -- 143
				width = width - 40, -- 143
				text = zh and "关闭" or "Close", -- 143
				onTapped = close -- 143
			}) -- 143
		) -- 143
		local node = ____toNode_26(____React_createElement_25( -- 133
			"node", -- 133
			____temp_23, -- 133
			____React_createElement_result_24, -- 133
			____React_createElement_22(__TS__SparseArraySpread(____array_21)) -- 133
		)) -- 133
		if node then -- 133
			host:addChild(node) -- 153
		end -- 153
	end -- 102
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
	if options.mode == "receive" and options.path then -- 160
		receive(options.path) -- 161
	end -- 161
	if options.mode == "share" and options.entry then -- 161
		thread(function() -- 163
			do -- 163
				local function ____catch(e) -- 163
					failed = true -- 172
					busy = false -- 172
					message = (string.match( -- 173
						tostring(e), -- 173
						":%d+: (.*)$" -- 173
					)) or tostring(e) -- 173
					render() -- 174
				end -- 174
				local ____try, ____hasReturned = pcall(function() -- 174
					exported = exportPackage(options.entry) -- 165
					busy = false -- 166
					if active and host.parent and detailRef.current then -- 166
						detailRef.current.text = (options.entry.title .. " · ") .. string.format("%.1f MB", exported.bytes / 1048576) -- 169
					end -- 169
				end) -- 169
				if not ____try then -- 169
					____catch(____hasReturned) -- 169
				end -- 169
			end -- 169
		end) -- 163
	end -- 163
	return host -- 178
end -- 37
return ____exports -- 37