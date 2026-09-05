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
	local host = Node() -- 46
	host.tag = "mobile-package-panel" -- 47
	host.order = 20000 -- 48
	host.renderGroup = true -- 49
	host:addTo(Director.systemUI) -- 50
	local active = true -- 51
	local busy = options.mode == "share" and options.entry ~= nil -- 52
	local preview -- 53
	local exported -- 54
	local detailRef = reference() -- 55
	local message = options.mode == "share" and (__TS__StringStartsWith( -- 56
		string.lower(App.locale), -- 56
		"zh" -- 56
	) and "接收者导入后可以试玩，也可以继续改编。" or "Recipients can import, play, and Remix this game.") or "" -- 56
	local failed = false -- 57
	local zh = __TS__StringStartsWith( -- 58
		string.lower(App.locale), -- 58
		"zh" -- 58
	) -- 58
	local function enabled() -- 59
		return active and host.parent ~= nil and host.visible and HttpServer.wsConnectionCount == 0 and not busy -- 59
	end -- 59
	local function close() -- 60
		if busy or not active then -- 60
			return -- 61
		end -- 61
		active = false -- 62
		if preview then -- 62
			discardPackage(preview) -- 63
		end -- 63
		preview = nil -- 64
		host:removeFromParent(true) -- 65
		options.onClosed() -- 66
	end -- 60
	local function receive(path) -- 68
		if not active then -- 68
			return -- 69
		end -- 69
		busy = true -- 70
		failed = false -- 70
		message = zh and "正在检查作品包…" or "Checking game package…" -- 71
		render() -- 72
		thread(function() -- 73
			do -- 73
				local function ____catch(e) -- 73
					failed = true -- 79
					message = (string.match( -- 79
						tostring(e), -- 79
						":%d+: (.*)$" -- 79
					)) or tostring(e) -- 79
				end -- 79
				local ____try, ____hasReturned, ____returnValue = pcall(function() -- 79
					local result = inspectPackage(path) -- 75
					if not active or not host.parent then -- 75
						discardPackage(result) -- 76
						return true -- 76
					end -- 76
					preview = result -- 77
					message = zh and "包含代码与素材，导入后可试玩和 Remix。" or "Includes code and assets. Import to play or Remix." -- 78
				end) -- 78
				if not ____try then -- 78
					____hasReturned, ____returnValue = ____catch(____hasReturned) -- 78
				end -- 78
				do -- 78
					busy = false -- 81
					render() -- 81
				end -- 81
				if ____hasReturned then -- 81
					return ____returnValue -- 74
				end -- 74
			end -- 74
		end) -- 73
	end -- 68
	local function pick() -- 85
		if not enabled() then -- 85
			return -- 86
		end -- 86
		busy = true -- 87
		message = zh and "请选择 ZIP 作品包" or "Choose a ZIP game package" -- 87
		render() -- 87
		App:openFileDialog( -- 88
			false, -- 88
			function(path) -- 88
				busy = false -- 89
				if not active or not host.parent then -- 89
					return -- 90
				end -- 90
				if path ~= "" then -- 90
					receive(path) -- 91
				else -- 91
					message = "" -- 92
					render() -- 92
				end -- 92
			end -- 88
		) -- 88
	end -- 85
	local function install(play) -- 95
		if not enabled() or not preview then -- 95
			return -- 96
		end -- 96
		do -- 96
			local function ____catch(e) -- 96
				failed = true -- 102
				message = (string.match( -- 102
					tostring(e), -- 102
					":%d+: (.*)$" -- 102
				)) or tostring(e) -- 102
				render() -- 102
			end -- 102
			local ____try, ____hasReturned = pcall(function() -- 102
				local entry = installPackage(preview) -- 98
				preview = nil -- 99
				close() -- 100
				local ____opt_0 = options.onImported -- 100
				if ____opt_0 ~= nil then -- 100
					____opt_0(entry, play) -- 101
				end -- 101
			end) -- 101
			if not ____try then -- 101
				____catch(____hasReturned) -- 101
			end -- 101
		end -- 101
	end -- 95
	render = function() -- 104
		if not active or not host.parent then -- 104
			return -- 105
		end -- 105
		host:removeAllChildren() -- 106
		host.scaleX = App.devicePixelRatio -- 107
		host.scaleY = App.devicePixelRatio -- 107
		local safe = App.safeArea -- 108
		local width = math.min(safe.width, 540) -- 109
		local title = preview and preview.title or (options.mode == "share" and (zh and "分享作品" or "Share game") or (zh and "添加作品" or "Add game")) -- 110
		local ____preview_5 -- 111
		if preview then -- 111
			____preview_5 = (preview.author and preview.author .. " · " or "") .. string.format("%.1f MB", preview.bytes / 1048576) -- 111
		else -- 111
			local ____temp_4 -- 112
			if options.mode == "share" then -- 112
				local ____opt_2 = options.entry -- 112
				____temp_4 = ((____opt_2 and ____opt_2.title or "") .. " · ") .. (exported and string.format("%.1f MB", exported.bytes / 1048576) or (zh and "打包中…" or "Packaging…")) -- 112
			else -- 112
				____temp_4 = "" -- 112
			end -- 112
			____preview_5 = ____temp_4 -- 112
		end -- 112
		local detail = ____preview_5 -- 111
		local function textHeight(text, fontSize) -- 113
			if text == "" then -- 113
				return 0 -- 114
			end -- 114
			local label = Label("sarasa-mono-sc-regular", fontSize) -- 115
			label.textWidth = width - 40 -- 116
			label.text = text -- 117
			local height = math.max( -- 118
				fontSize, -- 118
				math.ceil(label.height) -- 118
			) -- 118
			label:cleanup() -- 120
			return height -- 121
		end -- 113
		local titleTop = 20 -- 123
		local detailTop = titleTop + textHeight(title, 22) + 12 -- 124
		local ____temp_12 -- 126
		if options.mode == "share" then -- 126
			local ____math_max_11 = math.max -- 127
			local ____opt_6 = options.entry -- 127
			local ____textHeight_result_10 = textHeight(((____opt_6 and ____opt_6.title or "") .. " · ") .. (zh and "打包中…" or "Packaging…"), 14) -- 127
			local ____opt_8 = options.entry -- 127
			____temp_12 = ____math_max_11( -- 127
				____textHeight_result_10, -- 127
				textHeight((____opt_8 and ____opt_8.title or "") .. " · 256.0 MB", 14) -- 127
			) -- 127
		else -- 127
			____temp_12 = textHeight(detail, 14) -- 128
		end -- 128
		local detailHeight = ____temp_12 -- 126
		local messageTop = detail ~= "" and detailTop + detailHeight + 10 or detailTop -- 129
		local contentBottom = message ~= "" and messageTop + textHeight(message, 14) or (detail ~= "" and detailTop + detailHeight or detailTop - 12) -- 130
		local hasActions = options.mode == "share" or not busy -- 132
		local height = math.min(safe.height - 16, contentBottom + 20 + (hasActions and 126 or 66)) -- 133
		local actionWidth = (width - 52) / 2 -- 134
		local ____toNode_26 = toNode -- 135
		local ____React_createElement_25 = React.createElement -- 135
		local ____temp_23 = { -- 135
			x = -App.visualSize.width / 2, -- 135
			y = -App.visualSize.height / 2, -- 135
			anchorX = 0, -- 135
			anchorY = 0, -- 135
			width = App.visualSize.width, -- 135
			height = App.visualSize.height, -- 135
			touchEnabled = true, -- 135
			swallowTouches = true -- 135
		} -- 135
		local ____React_createElement_result_24 = React.createElement( -- 135
			"draw-node", -- 135
			nil, -- 135
			React.createElement("rect-shape", { -- 135
				centerX = App.visualSize.width / 2, -- 135
				centerY = App.visualSize.height / 2, -- 135
				width = App.visualSize.width, -- 135
				height = App.visualSize.height, -- 135
				fillColor = 2852126720 -- 135
			}) -- 135
		) -- 135
		local ____React_createElement_22 = React.createElement -- 135
		local ____array_21 = __TS__SparseArrayNew( -- 135
			"node", -- 135
			{ -- 135
				tag = "mobile-package-sheet", -- 135
				x = safe.left + (safe.width - width) / 2, -- 135
				y = safe.bottom + 8, -- 135
				width = width, -- 135
				height = height, -- 135
				anchorX = 0, -- 135
				anchorY = 0 -- 135
			}, -- 135
			React.createElement(PackageSurface, {width = width, height = height, radius = 24, color = 4279573803}), -- 135
			React.createElement("label", { -- 135
				x = 20, -- 135
				y = height - titleTop, -- 135
				anchorX = 0, -- 135
				anchorY = 1, -- 135
				fontName = "sarasa-mono-sc-regular", -- 135
				fontSize = 22, -- 135
				text = title, -- 135
				textWidth = width - 40, -- 135
				alignment = "Left" -- 135
			}) -- 135
		) -- 135
		local ____temp_13 -- 140
		if detail == "" then -- 140
			____temp_13 = nil -- 140
		else -- 140
			____temp_13 = React.createElement("label", { -- 140
				tag = "mobile-package-detail", -- 140
				ref = detailRef, -- 140
				x = 20, -- 140
				y = height - detailTop, -- 140
				anchorX = 0, -- 140
				anchorY = 1, -- 140
				fontName = "sarasa-mono-sc-regular", -- 140
				fontSize = 14, -- 140
				text = detail, -- 140
				color3 = 11055037, -- 140
				textWidth = width - 40, -- 140
				alignment = "Left" -- 140
			}) -- 140
		end -- 140
		__TS__SparseArrayPush( -- 140
			____array_21, -- 140
			____temp_13, -- 140
			React.createElement("label", { -- 140
				tag = "mobile-package-status", -- 140
				x = 20, -- 140
				y = height - messageTop, -- 140
				anchorX = 0, -- 140
				anchorY = 1, -- 140
				fontName = "sarasa-mono-sc-regular", -- 140
				fontSize = 14, -- 140
				text = message, -- 140
				color3 = failed and 16739179 or 11055037, -- 140
				textWidth = width - 40, -- 140
				alignment = "Left" -- 140
			}) -- 140
		) -- 140
		local ____temp_20 -- 142
		if not busy and preview then -- 142
			____temp_20 = React.createElement( -- 142
				"node", -- 142
				nil, -- 142
				React.createElement( -- 142
					PackageButton, -- 143
					{ -- 143
						tag = "mobile-package-import-play", -- 143
						x = 20, -- 143
						y = 78, -- 143
						width = actionWidth, -- 143
						text = zh and "导入并试玩" or "Import & play", -- 143
						fontSize = 15, -- 143
						primary = true, -- 143
						onTapped = function() return install(true) end -- 143
					} -- 143
				), -- 143
				React.createElement( -- 143
					PackageButton, -- 144
					{ -- 144
						tag = "mobile-package-import", -- 144
						x = 32 + actionWidth, -- 144
						y = 78, -- 144
						width = actionWidth, -- 144
						text = zh and "仅导入" or "Import", -- 144
						fontSize = 15, -- 144
						onTapped = function() return install(false) end -- 144
					} -- 144
				) -- 144
			) -- 144
		else -- 144
			local ____temp_19 -- 145
			if options.mode == "share" then -- 145
				____temp_19 = React.createElement( -- 145
					"node", -- 145
					nil, -- 145
					React.createElement( -- 145
						PackageButton, -- 146
						{ -- 146
							tag = "mobile-package-share", -- 146
							x = 20, -- 146
							y = 78, -- 146
							width = actionWidth, -- 146
							text = zh and "分享作品" or "Share game", -- 146
							fontSize = 15, -- 146
							primary = true, -- 146
							onTapped = function() -- 146
								if enabled() and exported and not App:shareFile(exported.path) then -- 146
									failed = true -- 146
									message = zh and "无法打开分享面板" or "Could not open share sheet" -- 146
									render() -- 146
								end -- 146
							end -- 146
						} -- 146
					), -- 146
					React.createElement( -- 146
						PackageButton, -- 147
						{ -- 147
							tag = "mobile-package-save", -- 147
							x = 32 + actionWidth, -- 147
							y = 78, -- 147
							width = actionWidth, -- 147
							text = zh and "保存作品包" or "Save package", -- 147
							fontSize = 15, -- 147
							onTapped = function() -- 147
								if enabled() and exported and not App:saveFileDialog(exported.path) then -- 147
									failed = true -- 147
									message = zh and "无法打开保存面板" or "Could not open save dialog" -- 147
									render() -- 147
								end -- 147
							end -- 147
						} -- 147
					) -- 147
				) -- 147
			else -- 147
				local ____temp_18 -- 148
				if not busy then -- 148
					local ____React_createElement_17 = React.createElement -- 148
					local ____options_onNew_16 -- 149
					if options.onNew then -- 149
						____options_onNew_16 = React.createElement( -- 149
							PackageButton, -- 149
							{ -- 149
								tag = "mobile-package-new", -- 149
								x = 20, -- 149
								y = 78, -- 149
								width = actionWidth, -- 149
								text = zh and "新建作品" or "New game", -- 149
								fontSize = 15, -- 149
								onTapped = function() -- 149
									if enabled() then -- 149
										close() -- 149
										local ____opt_14 = options.onNew -- 149
										if ____opt_14 ~= nil then -- 149
											____opt_14() -- 149
										end -- 149
									end -- 149
								end -- 149
							} -- 149
						) -- 149
					else -- 149
						____options_onNew_16 = nil -- 149
					end -- 149
					____temp_18 = ____React_createElement_17( -- 149
						"node", -- 149
						nil, -- 149
						____options_onNew_16, -- 149
						React.createElement(PackageButton, { -- 149
							tag = "mobile-package-pick", -- 149
							x = options.onNew and 32 + actionWidth or 20, -- 149
							y = 78, -- 149
							width = options.onNew and actionWidth or width - 40, -- 149
							text = zh and "导入作品包" or "Import package", -- 149
							fontSize = 15, -- 149
							primary = true, -- 149
							onTapped = pick -- 149
						}) -- 149
					) -- 149
				else -- 149
					____temp_18 = nil -- 151
				end -- 151
				____temp_19 = ____temp_18 -- 148
			end -- 148
			____temp_20 = ____temp_19 -- 145
		end -- 145
		__TS__SparseArrayPush( -- 145
			____array_21, -- 145
			____temp_20, -- 145
			React.createElement(PackageButton, { -- 145
				tag = "mobile-package-close", -- 145
				x = 20, -- 145
				y = 18, -- 145
				width = width - 40, -- 145
				text = zh and "关闭" or "Close", -- 145
				onTapped = close -- 145
			}) -- 145
		) -- 145
		local node = ____toNode_26(____React_createElement_25( -- 135
			"node", -- 135
			____temp_23, -- 135
			____React_createElement_result_24, -- 135
			____React_createElement_22(__TS__SparseArraySpread(____array_21)) -- 135
		)) -- 135
		if node then -- 135
			host:addChild(node) -- 155
		end -- 155
	end -- 104
	attachGamepad(host, {initialTag = "mobile-package-close", isEnabled = enabled, onBack = close}) -- 157
	host:onAppChange(function(setting) -- 158
		if setting == "Size" then -- 158
			render() -- 158
		end -- 158
	end) -- 158
	host:onAppEvent(function(event) -- 159
		if event == "BackButton" and enabled() then -- 159
			close() -- 159
		end -- 159
	end) -- 159
	host:onCleanup(function() -- 160
		active = false -- 160
		if preview then -- 160
			discardPackage(preview) -- 160
		end -- 160
		preview = nil -- 160
	end) -- 160
	host:schedule(function() -- 161
		host.visible = HttpServer.wsConnectionCount == 0 -- 161
		return false -- 161
	end) -- 161
	render() -- 162
	if options.mode == "add" and options.pickOnOpen then -- 162
		pick() -- 163
	end -- 163
	if options.mode == "receive" and options.path then -- 163
		receive(options.path) -- 164
	end -- 164
	if options.mode == "share" and options.entry then -- 164
		thread(function() -- 166
			do -- 166
				local function ____catch(e) -- 166
					failed = true -- 175
					busy = false -- 175
					message = (string.match( -- 176
						tostring(e), -- 176
						":%d+: (.*)$" -- 176
					)) or tostring(e) -- 176
					render() -- 177
				end -- 177
				local ____try, ____hasReturned = pcall(function() -- 177
					exported = exportPackage(options.entry) -- 168
					busy = false -- 169
					if active and host.parent and detailRef.current then -- 169
						detailRef.current.text = (options.entry.title .. " · ") .. string.format("%.1f MB", exported.bytes / 1048576) -- 172
					end -- 172
				end) -- 172
				if not ____try then -- 172
					____catch(____hasReturned) -- 172
				end -- 172
			end -- 172
		end) -- 166
	end -- 166
	return host -- 181
end -- 37
return ____exports -- 37