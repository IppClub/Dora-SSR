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
		local title = state.phase == "ready" and (zh and "更新已准备好" or "Update ready") or (state.available and (zh and "有可用更新" or "Update available") or (state.phase == "checking" and (zh and "正在检查更新…" or "Checking for updates…") or (state.comparison == 1 and (zh and "当前版本高于稳定版" or "Newer than stable") or (zh and "引擎更新" or "Engine update")))) -- 60
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
		if details then -- 68
			contentHeight = contentHeight + (120 + (state.windows and state.canDownload and 100 or 0) + ((state.prepared or state.canDownload) and 50 or 0)) -- 69
		end -- 69
		local function scrollNode() -- 70
			scroll = ScrollArea({ -- 71
				width = viewportWidth, -- 71
				height = viewHeight, -- 71
				viewWidth = viewportWidth, -- 71
				viewHeight = contentHeight, -- 71
				paddingX = 0, -- 71
				paddingY = 0, -- 71
				scrollBar = true -- 71
			}) -- 71
			scroll.renderOrder = 0 -- 72
			maxScroll = math.max(0, contentHeight - viewHeight) -- 73
			scroll.offset = Vec2( -- 74
				0, -- 74
				math.min(maxScroll, offset and offset.y or 0) -- 74
			) -- 74
			local top = 180 + messageHeight -- 75
			local notesTop = top -- 76
			if state.releaseUrl then -- 76
				top = top + 48 -- 76
			end -- 76
			local detailTop = top -- 77
			top = top + 46 -- 77
			local descriptionTop = top -- 78
			top = top + 120 -- 78
			local graphicsTop = top -- 79
			if state.windows and state.canDownload then -- 79
				top = top + 100 -- 80
			end -- 80
			local repairTop = top -- 81
			local ____toNode_15 = toNode -- 82
			local ____React_createElement_14 = React.createElement -- 82
			local ____array_13 = __TS__SparseArrayNew( -- 82
				"node", -- 82
				{ -- 82
					width = contentWidth, -- 82
					height = contentHeight, -- 82
					anchorX = 0, -- 82
					anchorY = 0, -- 82
					y = viewHeight - contentHeight -- 82
				}, -- 82
				text(title, 0, 15, 16763955), -- 83
				text(state.targetVersion or "—", 30, 24), -- 84
				text(((zh and "当前版本" or "Installed") .. " ") .. state.currentVersion, 70, 12, 11055037), -- 85
				text( -- 86
					state.platform .. (state.packageSize and (" · " .. string.format("%.1f", state.packageSize / 1048576)) .. " MiB" or ""), -- 86
					96, -- 86
					12, -- 86
					11055037 -- 86
				), -- 86
				React.createElement( -- 86
					MobileChoiceButton, -- 87
					{ -- 87
						renderOrder = 0, -- 87
						x = 0, -- 87
						y = contentHeight - 165, -- 87
						width = (contentWidth - 10) / 2, -- 87
						text = "AtomGit", -- 87
						selected = state.source == "AtomGit", -- 87
						disabled = busy or state.prepared, -- 87
						onTapped = click(function() -- 87
							Updater.checkForUpdates("AtomGit") -- 87
						end) -- 87
					} -- 87
				), -- 87
				React.createElement( -- 87
					MobileChoiceButton, -- 88
					{ -- 88
						renderOrder = 0, -- 88
						x = 10 + (contentWidth - 10) / 2, -- 88
						y = contentHeight - 165, -- 88
						width = (contentWidth - 10) / 2, -- 88
						text = "GitHub", -- 88
						selected = state.source == "GitHub", -- 88
						disabled = busy or state.prepared, -- 88
						onTapped = click(function() -- 88
							Updater.checkForUpdates("GitHub") -- 88
						end) -- 88
					} -- 88
				) -- 88
			) -- 88
			local ____temp_8 -- 89
			if messageHeight > 0 then -- 89
				____temp_8 = text(message, 180, 12, 11055037) -- 89
			else -- 89
				____temp_8 = nil -- 89
			end -- 89
			__TS__SparseArrayPush(____array_13, ____temp_8) -- 89
			local ____state_releaseUrl_9 -- 90
			if state.releaseUrl then -- 90
				____state_releaseUrl_9 = React.createElement( -- 90
					MobileButton, -- 90
					{ -- 90
						renderOrder = 0, -- 90
						tag = "engine-update-notes", -- 90
						x = 0, -- 90
						y = contentHeight - notesTop - 36, -- 90
						width = contentWidth, -- 90
						height = 36, -- 90
						fontSize = 13, -- 90
						text = zh and "查看发布说明" or "Release notes", -- 90
						onTapped = function() return App:openURL(state.releaseUrl) end -- 90
					} -- 90
				) -- 90
			else -- 90
				____state_releaseUrl_9 = nil -- 90
			end -- 90
			__TS__SparseArrayPush( -- 90
				____array_13, -- 90
				____state_releaseUrl_9, -- 90
				React.createElement( -- 90
					MobileButton, -- 91
					{ -- 91
						renderOrder = 0, -- 91
						tag = "engine-update-details", -- 91
						x = 0, -- 91
						y = contentHeight - detailTop - 34, -- 91
						width = contentWidth, -- 91
						height = 34, -- 91
						fontSize = 12, -- 91
						text = details and (zh and "收起安装信息" or "Hide installation info") or (zh and "安装选项与校验信息" or "Installation and verification"), -- 91
						onTapped = click(function() -- 91
							details = not details -- 91
						end) -- 91
					} -- 91
				) -- 91
			) -- 91
			local ____details_10 -- 92
			if details then -- 92
				____details_10 = text(state.platform == "Linux" and "sudo apt update\nsudo apt install --only-upgrade dora-ssr" or (zh and "项目和设置保留。安装前校验大小、SHA-256；AtomGit 另验证发布签名。\nmacOS 的 Homebrew 用户也可使用 brew upgrade。" or "Projects and settings are preserved. Package size, SHA-256 and AtomGit signatures are verified.\nHomebrew users can also use brew upgrade."), descriptionTop, 12, 11055037)
			else -- 92
				____details_10 = nil -- 92
			end -- 92
			__TS__SparseArrayPush(____array_13, ____details_10) -- 92
			local ____temp_11 -- 93
			if details and state.windows and state.canDownload and state.packagePlatform then -- 93
				____temp_11 = React.createElement( -- 93
					"node", -- 93
					nil, -- 93
					React.createElement( -- 93
						MobileButton, -- 94
						{ -- 94
							renderOrder = 0, -- 94
							tag = "engine-update-d3d12", -- 94
							x = 0, -- 94
							y = contentHeight - graphicsTop - 40, -- 94
							width = contentWidth, -- 94
							height = 40, -- 94
							fontSize = 13, -- 94
							text = zh and "下载 D3D12 图形版本" or "Download D3D12 backend", -- 94
							onTapped = click(function() -- 94
								Updater.downloadUpdate(windowsUpdatePlatform( -- 94
									"d3d12", -- 94
									__TS__StringEndsWith(state.packagePlatform, "-msi") -- 94
								)) -- 94
							end) -- 94
						} -- 94
					), -- 94
					React.createElement( -- 94
						MobileButton, -- 95
						{ -- 95
							renderOrder = 0, -- 95
							tag = "engine-update-opengl", -- 95
							x = 0, -- 95
							y = contentHeight - graphicsTop - 90, -- 95
							width = contentWidth, -- 95
							height = 40, -- 95
							fontSize = 13, -- 95
							text = zh and "下载 OpenGL 兼容版本" or "Download OpenGL backend", -- 95
							onTapped = click(function() -- 95
								Updater.downloadUpdate(windowsUpdatePlatform( -- 95
									"wgl", -- 95
									__TS__StringEndsWith(state.packagePlatform, "-msi") -- 95
								)) -- 95
							end) -- 95
						} -- 95
					) -- 95
				) -- 95
			else -- 95
				____temp_11 = nil -- 96
			end -- 96
			__TS__SparseArrayPush(____array_13, ____temp_11) -- 96
			local ____temp_12 -- 97
			if details and (state.canDownload and state.comparison == 0 or state.prepared) then -- 97
				____temp_12 = React.createElement( -- 97
					MobileButton, -- 97
					{ -- 97
						renderOrder = 0, -- 97
						tag = "engine-update-repair", -- 97
						x = 0, -- 97
						y = contentHeight - repairTop - 40, -- 97
						width = contentWidth, -- 97
						height = 40, -- 97
						fontSize = 13, -- 97
						text = state.prepared and (zh and "丢弃安装包" or "Discard package") or (zh and "重新下载安装包" or "Redownload package"), -- 97
						onTapped = click(function() -- 97
							if state.prepared then -- 97
								confirm = false -- 97
								Updater.discardPrepared() -- 97
							else -- 97
								Updater.downloadUpdate() -- 97
							end -- 97
						end) -- 97
					} -- 97
				) -- 97
			else -- 97
				____temp_12 = nil -- 97
			end -- 97
			__TS__SparseArrayPush(____array_13, ____temp_12) -- 97
			local body = ____toNode_15(____React_createElement_14(__TS__SparseArraySpread(____array_13))) -- 82
			if body ~= nil then -- 82
				body:addTo(scroll.view) -- 99
			end -- 99
			return scroll -- 100
		end -- 70
		local ____toNode_23 = toNode -- 102
		local ____React_createElement_22 = React.createElement -- 102
		local ____React_createElement_result_21 = React.createElement( -- 102
			"node", -- 102
			{ -- 102
				x = -App.visualSize.width / 2, -- 102
				y = -App.visualSize.height / 2, -- 102
				width = App.visualSize.width, -- 102
				height = App.visualSize.height, -- 102
				anchorX = 0, -- 102
				anchorY = 0, -- 102
				touchEnabled = true, -- 102
				swallowTouches = true -- 102
			}, -- 102
			React.createElement( -- 102
				"draw-node", -- 102
				{renderOrder = 0}, -- 102
				React.createElement("rect-shape", { -- 102
					width = App.visualSize.width, -- 102
					height = App.visualSize.height, -- 102
					centerX = App.visualSize.width / 2, -- 102
					centerY = App.visualSize.height / 2, -- 102
					fillColor = 2953119760 -- 102
				}) -- 102
			) -- 102
		) -- 102
		local ____React_createElement_20 = React.createElement -- 102
		local ____array_19 = __TS__SparseArrayNew( -- 102
			"node", -- 102
			{ -- 102
				x = x, -- 102
				y = y, -- 102
				width = width, -- 102
				height = height, -- 102
				anchorX = 0, -- 102
				anchorY = 0, -- 102
				touchEnabled = true, -- 102
				swallowTouches = true -- 102
			}, -- 102
			React.createElement(MobilePanelSurface, {width = width, height = height, renderOrder = 0}), -- 102
			React.createElement("label", { -- 102
				x = 22, -- 102
				y = height - 20, -- 102
				anchorX = 0, -- 102
				anchorY = 1, -- 102
				fontName = "sarasa-mono-sc-regular", -- 102
				fontSize = 20, -- 102
				renderOrder = 0, -- 102
				text = zh and "引擎更新" or "Engine update", -- 102
				color3 = 16052712 -- 102
			}), -- 102
			React.createElement(MobileButton, { -- 102
				renderOrder = 0, -- 102
				tag = "engine-update-close", -- 102
				x = width - 64, -- 102
				y = height - 62, -- 102
				width = 44, -- 102
				height = 40, -- 102
				text = "×", -- 102
				onTapped = close -- 102
			}), -- 102
			React.createElement("custom-node", {x = width / 2, y = 86 + viewHeight / 2, onCreate = scrollNode}), -- 102
			React.createElement( -- 102
				MobileButton, -- 111
				{ -- 111
					renderOrder = 0, -- 111
					tag = "engine-update-secondary", -- 111
					x = 22, -- 111
					y = 24, -- 111
					width = (width - 56) / 2, -- 111
					height = 48, -- 111
					fontSize = 14, -- 111
					text = confirm and (zh and "返回" or "Back") or (state.prepared and (zh and "稍后安装" or "Later") or (busy and (zh and "取消" or "Cancel") or (zh and "重新检查" or "Check again"))), -- 111
					onTapped = click(function() -- 111
						if confirm then -- 111
							confirm = false -- 111
						elseif state.prepared then -- 111
							close() -- 111
						elseif busy then -- 111
							Updater.cancelOperation() -- 111
						else -- 111
							Updater.checkForUpdates() -- 111
						end -- 111
					end) -- 111
				} -- 111
			) -- 111
		) -- 111
		local ____temp_18 -- 112
		if state.available and state.canDownload or state.phase == "ready" then -- 112
			____temp_18 = React.createElement( -- 112
				MobileButton, -- 112
				{ -- 112
					renderOrder = 0, -- 112
					tag = "engine-update-primary", -- 112
					x = 34 + (width - 56) / 2, -- 112
					y = 24, -- 112
					width = (width - 56) / 2, -- 112
					height = 48, -- 112
					primary = true, -- 112
					fontSize = 14, -- 112
					text = state.prepared and (confirm and (zh and "确认安装" or "Confirm install") or (state.platform == "Android" and (zh and "打开安装器" or "Open installer") or (zh and "安装并重启" or "Install & restart"))) or (zh and "下载更新" or "Download update"), -- 112
					onTapped = click(function() -- 112
						if state.prepared then -- 112
							if confirm then -- 112
								confirm = false -- 112
								Updater.installUpdate(true) -- 112
							else -- 112
								confirm = true -- 112
							end -- 112
						else -- 112
							Updater.downloadUpdate() -- 112
						end -- 112
					end) -- 112
				} -- 112
			) -- 112
		else -- 112
			____temp_18 = nil -- 112
		end -- 112
		__TS__SparseArrayPush(____array_19, ____temp_18) -- 112
		local scene = ____toNode_23(____React_createElement_22( -- 102
			"node", -- 102
			nil, -- 102
			____React_createElement_result_21, -- 102
			____React_createElement_20(__TS__SparseArraySpread(____array_19)) -- 102
		)) -- 102
		if scene ~= nil then -- 102
			scene:addTo(host) -- 115
		end -- 115
	end -- 43
	host:schedule(function() -- 117
		if serial ~= Updater.getState().serial then -- 117
			render() -- 117
		end -- 117
		return false -- 117
	end) -- 117
	attachGamepad( -- 118
		host, -- 118
		{ -- 118
			initialTag = "engine-update-primary", -- 118
			isEnabled = function() return host.parent ~= nil end, -- 118
			onBack = close, -- 118
			onScroll = function(amount) -- 118
				if scroll then -- 118
					scroll.offset = Vec2( -- 118
						0, -- 118
						math.max( -- 118
							0, -- 118
							math.min(maxScroll, scroll.offset.y + amount) -- 118
						) -- 118
					) -- 118
				end -- 118
			end -- 118
		} -- 118
	) -- 118
	host:onAppChange(function(setting) -- 119
		if setting == "Size" then -- 119
			render() -- 119
		end -- 119
	end) -- 119
	host:onAppEvent(function(event) -- 120
		if event == "BackButton" then -- 120
			close() -- 120
		end -- 120
	end) -- 120
	render() -- 121
	return host -- 121
end -- 31
return ____exports -- 31
