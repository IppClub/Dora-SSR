-- [tsx]: GoPanel.tsx
local ____lualib = require("lualib_bundle") -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local ____exports = {} -- 1
local ____DoraX = require("DoraX") -- 2
local React = ____DoraX.React -- 2
local toNode = ____DoraX.toNode -- 2
local ____Dora = require("Dora") -- 3
local App = ____Dora.App -- 3
local Node = ____Dora.Node -- 3
local Vec2 = ____Dora.Vec2 -- 3
local ScrollArea = require("UI/Control/Basic/ScrollArea") -- 4
local ____Gamepad = require("Dev.Mobile.Gamepad") -- 26
local attachGamepad = ____Gamepad.attachGamepad -- 26
local ____Manifest = require("Tools.SelfUpdater.Manifest") -- 27
local windowsUpdatePlatform = ____Manifest.windowsUpdatePlatform -- 27
local Updater = require("Tools.SelfUpdater.Service") -- 28
local function vertices(width, height, radius) -- 6
	if radius == nil then -- 6
		radius = 14 -- 6
	end -- 6
	local result = {} -- 7
	for ____, corner in ipairs({{x = width - radius, y = radius, start = -math.pi / 2}, {x = width - radius, y = height - radius, start = 0}, {x = radius, y = height - radius, start = math.pi / 2}, {x = radius, y = radius, start = math.pi}}) do -- 8
		do -- 8
			local i = 0 -- 9
			while i <= 6 do -- 9
				local angle = corner.start + i * math.pi / 12 -- 9
				result[#result + 1] = Vec2( -- 9
					corner.x + math.cos(angle) * radius, -- 9
					corner.y + math.sin(angle) * radius -- 9
				) -- 9
				i = i + 1 -- 9
			end -- 9
		end -- 9
	end -- 9
	return result -- 11
end -- 6
local function MobilePanelSurface(props) -- 13
	return React.createElement( -- 14
		"draw-node", -- 14
		{renderOrder = props.renderOrder}, -- 14
		React.createElement( -- 14
			"polygon-shape", -- 14
			{ -- 14
				verts = vertices(props.width, props.height, 24), -- 14
				fillColor = 4279968560, -- 14
				borderWidth = 1, -- 14
				borderColor = 4283061608 -- 14
			} -- 14
		) -- 14
	) -- 14
end -- 13
local function MobileButton(props) -- 16
	local height = props.height or 48 -- 17
	return React.createElement( -- 18
		"node", -- 18
		{ -- 18
			tag = props.tag, -- 18
			x = props.x, -- 18
			y = props.y, -- 18
			width = props.width, -- 18
			height = height, -- 18
			anchorX = 0, -- 18
			anchorY = 0, -- 18
			touchEnabled = true, -- 18
			swallowTouches = true, -- 18
			onTapped = props.onTapped -- 18
		}, -- 18
		React.createElement( -- 18
			"draw-node", -- 18
			{renderOrder = props.renderOrder}, -- 18
			React.createElement( -- 18
				"polygon-shape", -- 18
				{ -- 18
					verts = vertices(props.width, height), -- 18
					fillColor = props.primary and 4294954035 or 4280889664, -- 18
					borderWidth = 1, -- 18
					borderColor = props.primary and 4294958435 or 4283061608 -- 18
				} -- 18
			) -- 18
		), -- 18
		React.createElement("label", { -- 18
			x = props.width / 2, -- 18
			y = height / 2, -- 18
			renderOrder = 0, -- 18
			fontName = "sarasa-mono-sc-regular", -- 18
			fontSize = props.fontSize or 17, -- 18
			text = props.text, -- 18
			color3 = props.primary and 1512202 or 16052712 -- 18
		}) -- 18
	) -- 18
end -- 16
local function MobileChoiceButton(props) -- 23
	return React.createElement( -- 24
		"node", -- 24
		{opacity = props.disabled and 0.45 or 1}, -- 24
		React.createElement( -- 24
			MobileButton, -- 24
			__TS__ObjectAssign( -- 24
				{}, -- 24
				props, -- 24
				{ -- 24
					height = 40, -- 24
					fontSize = 14, -- 24
					primary = props.selected, -- 24
					onTapped = function() -- 24
						if not props.disabled then -- 24
							props:onTapped() -- 24
						end -- 24
					end -- 24
				} -- 24
			) -- 24
		) -- 24
	) -- 24
end -- 23
____exports.createGoUpdaterPanel = function(onClosed) -- 31
	if Updater.getState().phase == "idle" then -- 31
		Updater.checkForUpdates() -- 32
	end -- 32
	local host = Node() -- 33
	host.order = 16000 -- 34
	host.renderOrder = 16000 -- 34
	host.renderGroup = false -- 34
	local serial = -1 -- 35
	local confirm = false -- 36
	local details = false -- 37
	local scroll -- 38
	local maxScroll = 0 -- 39
	local zh = (string.match(App.locale, "^zh")) ~= nil -- 40
	local function close() -- 41
		return host:removeFromParent(true) -- 41
	end -- 41
	host:onCleanup(onClosed) -- 42
	local render -- 43
	render = function() -- 43
		local contentHeight -- 43
		local state = Updater.getState() -- 44
		serial = state.serial -- 45
		local offset = scroll and scroll.offset -- 46
		host:removeAllChildren() -- 47
		host.scaleX = App.devicePixelRatio -- 48
		host.scaleY = App.devicePixelRatio -- 48
		local safe = App.safeArea -- 49
		local width = math.min(460, safe.width - 24) -- 50
		local height = math.min(560, safe.height - 24) -- 51
		local x = safe.left + (safe.width - width) / 2 - App.visualSize.width / 2 -- 52
		local y = safe.bottom + (safe.height - height) / 2 - App.visualSize.height / 2 -- 53
		local busy = state.phase == "checking" or state.phase == "downloading" or state.phase == "canceling" or state.phase == "installing" -- 54
		local viewHeight = math.max(40, height - 160) -- 55
		local viewportWidth = width - 44 -- 56
		local contentWidth = viewportWidth - 18 -- 59
		local title = state.phase == "ready" and (zh and "更新已准备好" or "Update ready") or (state.ignored and (zh and "已忽略此版本" or "This version is ignored") or (state.available and (zh and "有可用更新" or "Update available") or (state.phase == "checking" and (zh and "正在检查更新…" or "Checking for updates…") or (state.comparison == 1 and (zh and "当前版本高于稳定版" or "Newer than stable") or (zh and "引擎更新" or "Engine update"))))) -- 60
		local function text(value, top, size, color) -- 61
			if size == nil then -- 61
				size = 14 -- 61
			end -- 61
			if color == nil then -- 61
				color = 16052712 -- 61
			end -- 61
			return React.createElement("label", { -- 61
				x = 0, -- 61
				y = contentHeight - top, -- 61
				anchorX = 0, -- 61
				anchorY = 1, -- 61
				fontName = "sarasa-mono-sc-regular", -- 61
				fontSize = size, -- 61
				renderOrder = 0, -- 61
				text = value, -- 61
				textWidth = contentWidth, -- 61
				alignment = "Left", -- 61
				color3 = color -- 61
			}) -- 61
		end -- 61
		local function click(action) -- 62
			return function() -- 62
				action() -- 62
				if host.parent then -- 62
					render() -- 62
				end -- 62
			end -- 62
		end -- 62
		local ____confirm_5 -- 63
		if confirm then -- 63
			____confirm_5 = zh and "请先保存作品。确认后安装并重启；Android 将打开系统安装器。" or "Save your work first. Installation restarts the engine or opens the Android installer." -- 63
		else -- 63
			local ____state_usedCache_4 -- 63
			if state.usedCache then -- 63
				____state_usedCache_4 = zh and "当前为离线缓存结果，请联网重新检查。" or "Offline cached result. Check again online." -- 63
			else -- 63
				local ____opt_2 = state.progress -- 63
				____state_usedCache_4 = ____opt_2 and ____opt_2.message or state.message -- 63
			end -- 63
			____confirm_5 = ____state_usedCache_4 -- 63
		end -- 63
		local message = ____confirm_5 -- 63
		local messageHeight = message ~= "" and 100 or 0 -- 65
		contentHeight = 180 + messageHeight -- 66
		if state.releaseUrl then -- 66
			contentHeight = contentHeight + 48 -- 67
		end -- 67
		contentHeight = contentHeight + 46 -- 68
		if state.canIgnore then -- 68
			contentHeight = contentHeight + 46 -- 69
		end -- 69
		if details then -- 69
			contentHeight = contentHeight + (120 + (state.windows and state.canDownload and 100 or 0) + ((state.prepared or state.canDownload) and 50 or 0)) -- 70
		end -- 70
		local function scrollNode() -- 71
			scroll = ScrollArea({ -- 72
				width = viewportWidth, -- 72
				height = viewHeight, -- 72
				viewWidth = viewportWidth, -- 72
				viewHeight = contentHeight, -- 72
				paddingX = 0, -- 72
				paddingY = 0, -- 72
				scrollBar = true -- 72
			}) -- 72
			scroll.renderOrder = 0 -- 73
			maxScroll = math.max(0, contentHeight - viewHeight) -- 74
			scroll.offset = Vec2( -- 75
				0, -- 75
				math.min(maxScroll, offset and offset.y or 0) -- 75
			) -- 75
			local top = 180 + messageHeight -- 76
			local notesTop = top -- 77
			if state.releaseUrl then -- 77
				top = top + 48 -- 77
			end -- 77
			local detailTop = top -- 78
			top = top + 46 -- 78
			local ignoreTop = top -- 79
			if state.canIgnore then -- 79
				top = top + 46 -- 79
			end -- 79
			local descriptionTop = top -- 80
			top = top + 120 -- 80
			local graphicsTop = top -- 81
			if state.windows and state.canDownload then -- 81
				top = top + 100 -- 82
			end -- 82
			local repairTop = top -- 83
			local ____toNode_16 = toNode -- 84
			local ____React_createElement_15 = React.createElement -- 84
			local ____array_14 = __TS__SparseArrayNew( -- 84
				"node", -- 84
				{ -- 84
					width = contentWidth, -- 84
					height = contentHeight, -- 84
					anchorX = 0, -- 84
					anchorY = 0, -- 84
					y = viewHeight - contentHeight -- 84
				}, -- 84
				text(title, 0, 15, 16763955), -- 85
				text(state.targetVersion or "—", 30, 24), -- 86
				text(((zh and "当前版本" or "Installed") .. " ") .. state.currentVersion, 70, 12, 11055037), -- 87
				text( -- 88
					state.platform .. (state.packageSize and (" · " .. string.format("%.1f", state.packageSize / 1048576)) .. " MiB" or ""), -- 88
					96, -- 88
					12, -- 88
					11055037 -- 88
				), -- 88
				React.createElement( -- 88
					MobileChoiceButton, -- 89
					{ -- 89
						renderOrder = 0, -- 89
						x = 0, -- 89
						y = contentHeight - 165, -- 89
						width = (contentWidth - 10) / 2, -- 89
						text = "AtomGit", -- 89
						selected = state.source == "AtomGit", -- 89
						disabled = busy or state.prepared, -- 89
						onTapped = click(function() -- 89
							Updater.checkForUpdates("AtomGit") -- 89
						end) -- 89
					} -- 89
				), -- 89
				React.createElement( -- 89
					MobileChoiceButton, -- 90
					{ -- 90
						renderOrder = 0, -- 90
						x = 10 + (contentWidth - 10) / 2, -- 90
						y = contentHeight - 165, -- 90
						width = (contentWidth - 10) / 2, -- 90
						text = "GitHub", -- 90
						selected = state.source == "GitHub", -- 90
						disabled = busy or state.prepared, -- 90
						onTapped = click(function() -- 90
							Updater.checkForUpdates("GitHub") -- 90
						end) -- 90
					} -- 90
				) -- 90
			) -- 90
			local ____temp_8 -- 91
			if messageHeight > 0 then -- 91
				____temp_8 = text(message, 180, 12, 11055037) -- 91
			else -- 91
				____temp_8 = nil -- 91
			end -- 91
			__TS__SparseArrayPush(____array_14, ____temp_8) -- 91
			local ____state_releaseUrl_9 -- 92
			if state.releaseUrl then -- 92
				____state_releaseUrl_9 = React.createElement( -- 92
					MobileButton, -- 92
					{ -- 92
						renderOrder = 0, -- 92
						tag = "engine-update-notes", -- 92
						x = 0, -- 92
						y = contentHeight - notesTop - 36, -- 92
						width = contentWidth, -- 92
						height = 36, -- 92
						fontSize = 13, -- 92
						text = zh and "查看发布说明" or "Release notes", -- 92
						onTapped = function() return App:openURL(state.releaseUrl) end -- 92
					} -- 92
				) -- 92
			else -- 92
				____state_releaseUrl_9 = nil -- 92
			end -- 92
			__TS__SparseArrayPush( -- 92
				____array_14, -- 92
				____state_releaseUrl_9, -- 92
				React.createElement( -- 92
					MobileButton, -- 93
					{ -- 93
						renderOrder = 0, -- 93
						tag = "engine-update-details", -- 93
						x = 0, -- 93
						y = contentHeight - detailTop - 34, -- 93
						width = contentWidth, -- 93
						height = 34, -- 93
						fontSize = 12, -- 93
						text = details and (zh and "收起安装信息" or "Hide installation info") or (zh and "安装选项与校验信息" or "Installation and verification"), -- 93
						onTapped = click(function() -- 93
							details = not details -- 93
						end) -- 93
					} -- 93
				) -- 93
			) -- 93
			local ____state_canIgnore_10 -- 94
			if state.canIgnore then -- 94
				____state_canIgnore_10 = React.createElement( -- 94
					MobileButton, -- 94
					{ -- 94
						renderOrder = 0, -- 94
						tag = "engine-update-ignore", -- 94
						x = 0, -- 94
						y = contentHeight - ignoreTop - 34, -- 94
						width = contentWidth, -- 94
						height = 34, -- 94
						fontSize = 12, -- 94
						text = zh and "忽略此版本" or "Ignore this version", -- 94
						onTapped = function() -- 94
							if Updater.ignoreUpdate() then -- 94
								close() -- 94
							end -- 94
						end -- 94
					} -- 94
				) -- 94
			else -- 94
				____state_canIgnore_10 = nil -- 94
			end -- 94
			__TS__SparseArrayPush(____array_14, ____state_canIgnore_10) -- 94
			local ____details_11 -- 95
			if details then -- 95
				____details_11 = text(state.platform == "Linux" and "sudo apt update\nsudo apt install --only-upgrade dora-ssr" or (zh and "项目和设置保留。安装前校验大小、SHA-256；AtomGit 另验证发布签名。\nmacOS 的 Homebrew 用户也可使用 brew upgrade。" or "Projects and settings are preserved. Package size, SHA-256 and AtomGit signatures are verified.\nHomebrew users can also use brew upgrade."), descriptionTop, 12, 11055037)
			else -- 95
				____details_11 = nil -- 95
			end -- 95
			__TS__SparseArrayPush(____array_14, ____details_11) -- 95
			local ____temp_12 -- 96
			if details and state.windows and state.canDownload and state.packagePlatform then -- 96
				____temp_12 = React.createElement( -- 96
					"node", -- 96
					nil, -- 96
					React.createElement( -- 96
						MobileButton, -- 97
						{ -- 97
							renderOrder = 0, -- 97
							tag = "engine-update-d3d12", -- 97
							x = 0, -- 97
							y = contentHeight - graphicsTop - 40, -- 97
							width = contentWidth, -- 97
							height = 40, -- 97
							fontSize = 13, -- 97
							text = zh and "下载 D3D12 图形版本" or "Download D3D12 backend", -- 97
							onTapped = click(function() -- 97
								Updater.downloadUpdate(windowsUpdatePlatform( -- 97
									"d3d12", -- 97
									__TS__StringEndsWith(state.packagePlatform, "-msi") -- 97
								)) -- 97
							end) -- 97
						} -- 97
					), -- 97
					React.createElement( -- 97
						MobileButton, -- 98
						{ -- 98
							renderOrder = 0, -- 98
							tag = "engine-update-opengl", -- 98
							x = 0, -- 98
							y = contentHeight - graphicsTop - 90, -- 98
							width = contentWidth, -- 98
							height = 40, -- 98
							fontSize = 13, -- 98
							text = zh and "下载 OpenGL 兼容版本" or "Download OpenGL backend", -- 98
							onTapped = click(function() -- 98
								Updater.downloadUpdate(windowsUpdatePlatform( -- 98
									"wgl", -- 98
									__TS__StringEndsWith(state.packagePlatform, "-msi") -- 98
								)) -- 98
							end) -- 98
						} -- 98
					) -- 98
				) -- 98
			else -- 98
				____temp_12 = nil -- 99
			end -- 99
			__TS__SparseArrayPush(____array_14, ____temp_12) -- 99
			local ____temp_13 -- 100
			if details and (state.canDownload and state.comparison == 0 or state.prepared) then -- 100
				____temp_13 = React.createElement( -- 100
					MobileButton, -- 100
					{ -- 100
						renderOrder = 0, -- 100
						tag = "engine-update-repair", -- 100
						x = 0, -- 100
						y = contentHeight - repairTop - 40, -- 100
						width = contentWidth, -- 100
						height = 40, -- 100
						fontSize = 13, -- 100
						text = state.prepared and (zh and "丢弃安装包" or "Discard package") or (zh and "重新下载安装包" or "Redownload package"), -- 100
						onTapped = click(function() -- 100
							if state.prepared then -- 100
								confirm = false -- 100
								Updater.discardPrepared() -- 100
							else -- 100
								Updater.downloadUpdate() -- 100
							end -- 100
						end) -- 100
					} -- 100
				) -- 100
			else -- 100
				____temp_13 = nil -- 100
			end -- 100
			__TS__SparseArrayPush(____array_14, ____temp_13) -- 100
			local body = ____toNode_16(____React_createElement_15(__TS__SparseArraySpread(____array_14))) -- 84
			if body ~= nil then -- 84
				body:addTo(scroll.view) -- 102
			end -- 102
			return scroll -- 103
		end -- 71
		local ____toNode_24 = toNode -- 105
		local ____React_createElement_23 = React.createElement -- 105
		local ____React_createElement_result_22 = React.createElement( -- 105
			"node", -- 105
			{ -- 105
				x = -App.visualSize.width / 2, -- 105
				y = -App.visualSize.height / 2, -- 105
				width = App.visualSize.width, -- 105
				height = App.visualSize.height, -- 105
				anchorX = 0, -- 105
				anchorY = 0, -- 105
				touchEnabled = true, -- 105
				swallowTouches = true -- 105
			}, -- 105
			React.createElement( -- 105
				"draw-node", -- 105
				{renderOrder = 0}, -- 105
				React.createElement("rect-shape", { -- 105
					width = App.visualSize.width, -- 105
					height = App.visualSize.height, -- 105
					centerX = App.visualSize.width / 2, -- 105
					centerY = App.visualSize.height / 2, -- 105
					fillColor = 2953119760 -- 105
				}) -- 105
			) -- 105
		) -- 105
		local ____React_createElement_21 = React.createElement -- 105
		local ____array_20 = __TS__SparseArrayNew( -- 105
			"node", -- 105
			{ -- 105
				x = x, -- 105
				y = y, -- 105
				width = width, -- 105
				height = height, -- 105
				anchorX = 0, -- 105
				anchorY = 0, -- 105
				touchEnabled = true, -- 105
				swallowTouches = true -- 105
			}, -- 105
			React.createElement(MobilePanelSurface, {width = width, height = height, renderOrder = 0}), -- 105
			React.createElement("label", { -- 105
				x = 22, -- 105
				y = height - 20, -- 105
				anchorX = 0, -- 105
				anchorY = 1, -- 105
				fontName = "sarasa-mono-sc-regular", -- 105
				fontSize = 20, -- 105
				renderOrder = 0, -- 105
				text = zh and "引擎更新" or "Engine update", -- 105
				color3 = 16052712 -- 105
			}), -- 105
			React.createElement(MobileButton, { -- 105
				renderOrder = 0, -- 105
				tag = "engine-update-close", -- 105
				x = width - 64, -- 105
				y = height - 62, -- 105
				width = 44, -- 105
				height = 40, -- 105
				text = "×", -- 105
				onTapped = close -- 105
			}), -- 105
			React.createElement("custom-node", {x = width / 2, y = 86 + viewHeight / 2, onCreate = scrollNode}), -- 105
			React.createElement( -- 105
				MobileButton, -- 114
				{ -- 114
					renderOrder = 0, -- 114
					tag = "engine-update-secondary", -- 114
					x = 22, -- 114
					y = 24, -- 114
					width = (width - 56) / 2, -- 114
					height = 48, -- 114
					fontSize = 14, -- 114
					text = confirm and (zh and "返回" or "Back") or (state.prepared and (zh and "稍后安装" or "Later") or (busy and (zh and "取消" or "Cancel") or (zh and "重新检查" or "Check again"))), -- 114
					onTapped = click(function() -- 114
						if confirm then -- 114
							confirm = false -- 114
						elseif state.prepared then -- 114
							close() -- 114
						elseif busy then -- 114
							Updater.cancelOperation() -- 114
						else -- 114
							Updater.checkForUpdates() -- 114
						end -- 114
					end) -- 114
				} -- 114
			) -- 114
		) -- 114
		local ____temp_19 -- 115
		if state.comparison == -1 and state.canDownload or state.phase == "ready" then -- 115
			____temp_19 = React.createElement( -- 115
				MobileButton, -- 115
				{ -- 115
					renderOrder = 0, -- 115
					tag = "engine-update-primary", -- 115
					x = 34 + (width - 56) / 2, -- 115
					y = 24, -- 115
					width = (width - 56) / 2, -- 115
					height = 48, -- 115
					primary = true, -- 115
					fontSize = 14, -- 115
					text = state.prepared and (confirm and (zh and "确认安装" or "Confirm install") or (state.platform == "Android" and (zh and "打开安装器" or "Open installer") or (zh and "安装并重启" or "Install & restart"))) or (zh and "下载更新" or "Download update"), -- 115
					onTapped = click(function() -- 115
						if state.prepared then -- 115
							if confirm then -- 115
								confirm = false -- 115
								Updater.installUpdate(true) -- 115
							else -- 115
								confirm = true -- 115
							end -- 115
						else -- 115
							Updater.downloadUpdate() -- 115
						end -- 115
					end) -- 115
				} -- 115
			) -- 115
		else -- 115
			____temp_19 = nil -- 115
		end -- 115
		__TS__SparseArrayPush(____array_20, ____temp_19) -- 115
		local scene = ____toNode_24(____React_createElement_23( -- 105
			"node", -- 105
			nil, -- 105
			____React_createElement_result_22, -- 105
			____React_createElement_21(__TS__SparseArraySpread(____array_20)) -- 105
		)) -- 105
		if scene ~= nil then -- 105
			scene:addTo(host) -- 118
		end -- 118
	end -- 43
	host:schedule(function() -- 120
		if serial ~= Updater.getState().serial then -- 120
			render() -- 120
		end -- 120
		return false -- 120
	end) -- 120
	attachGamepad( -- 121
		host, -- 121
		{ -- 121
			initialTag = "engine-update-primary", -- 121
			isEnabled = function() return host.parent ~= nil end, -- 121
			onBack = close, -- 121
			onScroll = function(amount) -- 121
				if scroll then -- 121
					scroll.offset = Vec2( -- 121
						0, -- 121
						math.max( -- 121
							0, -- 121
							math.min(maxScroll, scroll.offset.y + amount) -- 121
						) -- 121
					) -- 121
				end -- 121
			end -- 121
		} -- 121
	) -- 121
	host:onAppChange(function(setting) -- 122
		if setting == "Size" then -- 122
			render() -- 122
		end -- 122
	end) -- 122
	host:onAppEvent(function(event) -- 123
		if event == "BackButton" then -- 123
			close() -- 123
		end -- 123
	end) -- 123
	render() -- 124
	return host -- 124
end -- 31
return ____exports -- 31
