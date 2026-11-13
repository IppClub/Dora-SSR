-- [tsx]: View.tsx
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__StringSubstring = ____lualib.__TS__StringSubstring -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local ____exports = {} -- 1
local ____DoraX = require("DoraX") -- 2
local React = ____DoraX.React -- 2
local toNode = ____DoraX.toNode -- 2
local ____Dora = require("Dora") -- 3
local App = ____Dora.App -- 3
local Color3 = ____Dora.Color3 -- 3
local Director = ____Dora.Director -- 3
local Label = ____Dora.Label -- 3
local Node = ____Dora.Node -- 3
local Path = ____Dora.Path -- 3
local Size = ____Dora.Size -- 3
local Vec2 = ____Dora.Vec2 -- 3
local emit = ____Dora.emit -- 3
local ____Controls = require("Tools.RepositoryImporter.Controls") -- 4
local MobileButton = ____Controls.MobileButton -- 4
local MobilePanelSurface = ____Controls.MobilePanelSurface -- 4
local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 5
local ____Controls = require("Tools.RepositoryImporter.Controls") -- 6
local RoundedSurface = ____Controls.RoundedSurface -- 6
local ____TextInput = require("Dev.Mobile.TextInput") -- 7
local createTextInput = ____TextInput.createTextInput -- 7
local ____Gamepad = require("Dev.Mobile.Gamepad") -- 8
local attachGamepad = ____Gamepad.attachGamepad -- 8
local ____ImportIDE = require("Dev.ImportIDE") -- 9
local getTargets = ____ImportIDE.getTargets -- 9
local openProject = ____ImportIDE.openProject -- 9
local ____Import = require("Tools.RepositoryImporter.Import") -- 10
local importRepository = ____Import.importRepository -- 10
local normalizeRepository = ____Import.normalizeRepository -- 10
function ____exports.start(repository) -- 12
	local begin, render -- 12
	local host = Node() -- 13
	host.tag = "repository-importer" -- 13
	host.renderGroup = false -- 13
	host.order = 16000 -- 13
	host.renderOrder = 16000 -- 13
	host:addTo(Director.entry) -- 13
	local zh = (string.match(App.locale, "^zh")) ~= nil -- 14
	local url = repository or "" -- 15
	local phase = "input" -- 16
	local message = "" -- 17
	local project -- 17
	local operation -- 18
	local disposed = false -- 19
	local details = false -- 19
	local targetKey = "" -- 19
	local progressBucket = -1 -- 20
	local lastRefresh = 0 -- 21
	local shownPhase = "" -- 21
	local scroll -- 23
	local function finish() -- 24
		return emit("RepositoryImportDone") -- 24
	end -- 24
	local input = createTextInput({ -- 25
		fontSize = 14, -- 25
		singleLine = true, -- 25
		nativeSurface = true, -- 25
		getText = function() return url end, -- 25
		setText = function(value) -- 25
			url = value -- 25
		end, -- 25
		getPlaceholder = function() return "https://github.com/owner/project" end, -- 26
		isEnabled = function() return not disposed and phase == "input" end, -- 26
		onReturn = function() -- 27
			begin() -- 27
			return true -- 27
		end -- 27
	}) -- 27
	begin = function() -- 28
		local normalized = normalizeRepository(url) -- 29
		if not normalized then -- 29
			message = zh and "请输入 GitHub、AtomGit、Gitee 或 GitCode 的公开 HTTPS 仓库地址。" or "Enter a public HTTPS repository on GitHub, AtomGit, Gitee or GitCode." -- 30
			render() -- 30
			return -- 30
		end -- 30
		input.blur() -- 31
		url = normalized -- 31
		phase = "busy" -- 31
		message = "" -- 31
		project = nil -- 31
		local current = {canceled = false, phase = "clone"} -- 32
		operation = current -- 32
		render() -- 33
		local ____self_0 = importRepository(url, current) -- 33
		____self_0["then"]( -- 34
			____self_0, -- 34
			function(____, result) -- 34
				if disposed or current.canceled then -- 34
					return -- 35
				end -- 35
				project = result -- 36
				phase = "ready" -- 36
				emit("RepositoryImported", result.entry) -- 36
				render() -- 36
			end -- 34
		):catch(function(____, ____error) -- 34
			if disposed or current.canceled then -- 34
				return -- 38
			end -- 38
			phase = "error" -- 39
			message = tostring(____error) -- 39
			render() -- 39
		end) -- 37
	end -- 28
	local function open(target) -- 42
		if not project or phase ~= "ready" then -- 42
			return -- 43
		end -- 43
		phase = "opening" -- 44
		message = "" -- 44
		render() -- 44
		local ____self_1 = openProject(target, project.root) -- 44
		____self_1["then"]( -- 44
			____self_1, -- 44
			function(____, success) -- 45
				if disposed then -- 45
					return -- 46
				end -- 46
				phase = "ready" -- 47
				if not success then -- 47
					message = zh and "IDE 未响应，请重试或重新连接 IDE。" or "The IDE did not respond. Retry or reconnect it." -- 48
					render() -- 48
					return -- 48
				end -- 48
				if target.embedded then -- 48
					finish() -- 49
					emit("AppWebView", "/ide/show", true) -- 49
				else -- 49
					message = zh and "已在浏览器 IDE 中打开，请切换到浏览器。" or "Opened in the browser IDE. Switch to your browser." -- 50
					render() -- 50
				end -- 50
			end -- 45
		) -- 45
	end -- 42
	render = function() -- 53
		if disposed then -- 53
			return -- 54
		end -- 54
		local offset = scroll and scroll.offset.y or 0 -- 55
		input.unmount() -- 56
		host:removeAllChildren() -- 56
		host.scaleX = App.devicePixelRatio -- 57
		host.scaleY = App.devicePixelRatio -- 57
		local safe = App.safeArea -- 58
		local width = math.max( -- 58
			160, -- 58
			math.min(540, safe.width - 24) -- 58
		) -- 58
		local availableHeight = math.max(180, safe.height - 64) -- 59
		local height = math.max( -- 60
			180, -- 60
			math.min(480, availableHeight - 24) -- 60
		) -- 60
		local left = safe.left + (safe.width - width) / 2 - App.visualSize.width / 2 -- 61
		local bottom = safe.bottom + 64 + (availableHeight - height) / 2 - App.visualSize.height / 2 -- 62
		local targets = getTargets() -- 63
		targetKey = table.concat( -- 64
			__TS__ArrayMap( -- 64
				targets, -- 64
				function(____, target) return target.id end -- 64
			), -- 64
			"," -- 64
		) -- 64
		shownPhase = operation and operation.phase or "" -- 64
		local title = phase == "ready" and (project and project.existing and (zh and "项目已在本地" or "Already imported") or (zh and "项目已导入" or "Project imported")) or (phase == "error" and (zh and "导入未完成" or "Import failed") or (phase == "opening" and (zh and "正在打开项目…" or "Opening project…") or (phase == "busy" and ((operation and operation.phase) == "verify" and (zh and "正在校验项目…" or "Verifying project…") or (zh and "正在下载项目…" or "Cloning project…")) or (zh and "从仓库导入" or "Import repository")))) -- 65
		local buttonWidth = (width - 60) / 2 -- 68
		local contentWidth = width - 66 -- 68
		local hasFooterPrimary = phase == "input" or phase == "error" or phase == "ready" and #targets == 0 -- 69
		local name = url ~= "" and Path:getFilename(url) or (zh and "公开开源仓库" or "Public repository") -- 70
		local ____math_max_15 = math.max -- 71
		local ____math_min_14 = math.min -- 71
		local ____opt_10 = operation and operation.status -- 71
		local p = ____math_max_15( -- 71
			0, -- 71
			____math_min_14(1, ____opt_10 and ____opt_10.progress or 0) -- 71
		) -- 71
		progressBucket = math.floor(p * 100) -- 71
		local items = {} -- 72
		local top = 0 -- 73
		local function add(node, height) -- 74
			if node then -- 74
				items[#items + 1] = {node = node, top = top, label = false} -- 74
				top = top + (height + 12) -- 74
			end -- 74
		end -- 74
		local function text(value, size, color) -- 75
			if size == nil then -- 75
				size = 14 -- 75
			end -- 75
			if color == nil then -- 75
				color = 11055037 -- 75
			end -- 75
			local node = Label("sarasa-mono-sc-regular", size, true) -- 76
			node.textWidth = contentWidth -- 77
			node.alignment = "Left" -- 77
			node.anchor = Vec2(0, 1) -- 77
			node.text = value -- 78
			node.color3 = Color3(color) -- 78
			items[#items + 1] = {node = node, top = top, label = true} -- 79
			top = top + (node.height + 14) -- 79
		end -- 75
		text(name, 20, 4294954035) -- 81
		if phase == "input" then -- 81
			local field = Node() -- 83
			field.tag = "repository-input" -- 83
			field.anchor = Vec2.zero -- 83
			field.size = Size(contentWidth, 44) -- 83
			input.mount(field) -- 83
			add(field, 44) -- 83
			add( -- 84
				toNode(React.createElement( -- 84
					MobileButton, -- 84
					{ -- 84
						tag = "import-paste", -- 84
						x = 0, -- 84
						y = 0, -- 84
						width = contentWidth, -- 84
						height = 36, -- 84
						text = zh and "粘贴仓库地址" or "Paste repository URL", -- 84
						fontSize = 13, -- 84
						onTapped = function() -- 84
							input.pasteFromClipboard(true) -- 84
						end -- 84
					} -- 84
				)), -- 84
				36 -- 84
			) -- 84
			text(zh and "支持 GitHub、AtomGit、Gitee 和 GitCode 的公开 HTTPS 仓库。" or "Public HTTPS repositories on GitHub, AtomGit, Gitee and GitCode.", 12) -- 85
		else -- 85
			text(url, 12) -- 86
		end -- 86
		if phase == "busy" then -- 86
			text(zh and "下载 → 校验 → 导入" or "Clone → Verify → Import", 13) -- 88
			local ____toNode_20 = toNode -- 89
			local ____React_createElement_19 = React.createElement -- 89
			local ____temp_17 = {width = contentWidth, height = 10, anchorX = 0, anchorY = 0} -- 89
			local ____React_createElement_result_18 = React.createElement(RoundedSurface, { -- 89
				width = contentWidth, -- 89
				height = 10, -- 89
				radius = 5, -- 89
				topColor = 4279571992, -- 89
				bottomColor = 4279571992 -- 89
			}) -- 89
			local ____temp_16 -- 91
			if p > 0 then -- 91
				____temp_16 = React.createElement( -- 91
					RoundedSurface, -- 91
					{ -- 91
						width = math.max(10, contentWidth * p), -- 91
						height = 10, -- 91
						radius = 5, -- 91
						topColor = 4294958955, -- 91
						bottomColor = 4294950190 -- 91
					} -- 91
				) -- 91
			else -- 91
				____temp_16 = nil -- 91
			end -- 91
			add( -- 89
				____toNode_20(____React_createElement_19("node", ____temp_17, ____React_createElement_result_18, ____temp_16)), -- 89
				10 -- 92
			) -- 92
			local ____math_floor_result_25 = math.floor(p * 100) -- 93
			local ____opt_21 = operation and operation.status -- 93
			text( -- 93
				(tostring(____math_floor_result_25) .. "%") .. (____opt_21 and ____opt_21.transferredBytes and ("  " .. string.format("%.1f", operation.status.transferredBytes / 1048576)) .. " MiB" or ""), -- 93
				13 -- 93
			) -- 93
		end -- 93
		if phase == "ready" then -- 93
			text(zh and "源码已就绪，选择下一步。" or "Source is ready. Choose what to do next.", 13) -- 96
			if #targets > 1 then -- 96
				text(zh and "选择打开位置" or "Choose an IDE", 12) -- 97
			end -- 97
			do -- 97
				local i = 0 -- 98
				while i < #targets do -- 98
					local target = targets[i + 1] -- 99
					local caption = target.embedded and (zh and "在内置 IDE 中打开" or "Open in embedded IDE") or (zh and "在浏览器 IDE 中打开" or "Open in browser IDE") .. (#__TS__ArrayFilter( -- 100
						targets, -- 100
						function(____, t) return not t.embedded end -- 100
					) > 1 and (" (" .. string.sub(target.id, -4)) .. ")" or "") -- 100
					add( -- 101
						toNode(React.createElement( -- 101
							MobileButton, -- 101
							{ -- 101
								tag = "import-ide-" .. tostring(i), -- 101
								x = 0, -- 101
								y = 0, -- 101
								width = contentWidth, -- 101
								height = 42, -- 101
								fontSize = 14, -- 101
								primary = i == 0, -- 101
								text = caption, -- 101
								onTapped = function() return open(target) end -- 101
							} -- 101
						)), -- 101
						42 -- 101
					) -- 101
					i = i + 1 -- 98
				end -- 98
			end -- 98
		end -- 98
		if message ~= "" then -- 98
			text( -- 104
				details and message or __TS__StringSubstring(message, 0, 130), -- 104
				12, -- 104
				phase == "error" and 16745861 or 11055037 -- 104
			) -- 104
		end -- 104
		if phase == "error" then -- 104
			add( -- 105
				toNode(React.createElement( -- 105
					MobileButton, -- 105
					{ -- 105
						tag = "import-details", -- 105
						x = 0, -- 105
						y = 0, -- 105
						width = contentWidth, -- 105
						height = 32, -- 105
						fontSize = 12, -- 105
						text = details and (zh and "收起详情" or "Hide details") or (zh and "查看详情" or "Show details"), -- 105
						onTapped = function() -- 105
							details = not details -- 105
							render() -- 105
						end -- 105
					} -- 105
				)), -- 105
				32 -- 105
			) -- 105
		end -- 105
		local viewHeight = height - 154 -- 106
		local contentHeight = math.max(viewHeight, top) -- 106
		scroll = ScrollArea({ -- 107
			width = width - 48, -- 107
			height = viewHeight, -- 107
			viewWidth = width - 48, -- 107
			viewHeight = contentHeight, -- 107
			paddingX = 0, -- 107
			paddingY = 0, -- 107
			scrollBar = true -- 107
		}) -- 107
		scroll.offset = Vec2( -- 108
			0, -- 108
			math.min( -- 108
				offset, -- 108
				math.max(0, contentHeight - viewHeight) -- 108
			) -- 108
		) -- 108
		local body = Node() -- 109
		body.anchor = Vec2.zero -- 109
		body.size = Size(contentWidth, contentHeight) -- 109
		body.y = viewHeight - contentHeight -- 109
		for ____, item in ipairs(items) do -- 110
			item.node.y = contentHeight - item.top - (item.label and 0 or item.node.height) -- 110
			body:addChild(item.node) -- 110
		end -- 110
		body:addTo(scroll.view) -- 111
		local ____toNode_32 = toNode -- 112
		local ____React_createElement_31 = React.createElement -- 112
		local ____React_createElement_result_30 = React.createElement( -- 112
			"draw-node", -- 112
			nil, -- 112
			React.createElement("rect-shape", {width = App.visualSize.width, height = App.visualSize.height, fillColor = 4279506198}) -- 112
		) -- 112
		local ____React_createElement_29 = React.createElement -- 112
		local ____array_28 = __TS__SparseArrayNew( -- 112
			"node", -- 112
			{ -- 112
				x = left, -- 112
				y = bottom, -- 112
				width = width, -- 112
				height = height, -- 112
				anchorX = 0, -- 112
				anchorY = 0 -- 112
			}, -- 112
			React.createElement(MobilePanelSurface, {width = width, height = height}), -- 112
			React.createElement("label", { -- 112
				x = 24, -- 112
				y = height - 24, -- 112
				anchorX = 0, -- 112
				anchorY = 1, -- 112
				fontName = "sarasa-mono-sc-regular", -- 112
				fontSize = 22, -- 112
				text = title, -- 112
				color3 = 16052712 -- 112
			}), -- 112
			React.createElement( -- 112
				"custom-node", -- 112
				{ -- 112
					x = width / 2, -- 112
					y = 86 + viewHeight / 2, -- 112
					onCreate = function() return scroll end -- 112
				} -- 112
			), -- 112
			React.createElement(MobileButton, { -- 112
				tag = "import-close", -- 112
				x = 24, -- 112
				y = 24, -- 112
				width = hasFooterPrimary and buttonWidth or width - 48, -- 112
				text = (phase == "busy" or phase == "opening") and (zh and "取消" or "Cancel") or (zh and "完成" or "Done"), -- 112
				fontSize = 14, -- 112
				onTapped = finish -- 112
			}) -- 112
		) -- 112
		local ____temp_26 -- 119
		if phase == "input" or phase == "error" then -- 119
			____temp_26 = React.createElement(MobileButton, { -- 119
				tag = "import-primary", -- 119
				x = 36 + buttonWidth, -- 119
				y = 24, -- 119
				width = buttonWidth, -- 119
				primary = true, -- 119
				text = phase == "error" and (zh and "重试" or "Retry") or (zh and "导入项目" or "Import"), -- 119
				fontSize = 14, -- 119
				onTapped = begin -- 119
			}) -- 119
		else -- 119
			____temp_26 = nil -- 119
		end -- 119
		__TS__SparseArrayPush(____array_28, ____temp_26) -- 119
		local ____temp_27 -- 120
		if phase == "ready" and #targets == 0 then -- 120
			____temp_27 = React.createElement( -- 120
				MobileButton, -- 120
				{ -- 120
					tag = "import-primary", -- 120
					x = 36 + buttonWidth, -- 120
					y = 24, -- 120
					width = buttonWidth, -- 120
					primary = true, -- 120
					text = zh and "查看项目" or "View project", -- 120
					fontSize = 14, -- 120
					onTapped = function() -- 120
						emit("RepositoryImportReveal", project.entry) -- 120
					end -- 120
				} -- 120
			) -- 120
		else -- 120
			____temp_27 = nil -- 120
		end -- 120
		__TS__SparseArrayPush(____array_28, ____temp_27) -- 120
		local scene = ____toNode_32(____React_createElement_31( -- 112
			"node", -- 112
			nil, -- 112
			____React_createElement_result_30, -- 112
			____React_createElement_29(__TS__SparseArraySpread(____array_28)) -- 112
		)) -- 112
		if scene ~= nil then -- 112
			scene:addTo(host) -- 123
		end -- 123
	end -- 53
	host:onCleanup(function() -- 125
		disposed = true -- 125
		if operation then -- 125
			operation.canceled = true -- 125
		end -- 125
		input.unmount() -- 125
	end) -- 125
	host:onAppChange(function(setting) -- 126
		if setting == "Size" then -- 126
			render() -- 126
		end -- 126
	end) -- 126
	host:onAppEvent(function(event) -- 127
		if event == "BackButton" then -- 127
			finish() -- 127
		end -- 127
	end) -- 127
	host:schedule(function() -- 128
		if App.runningTime - lastRefresh < 0.15 then -- 128
			return false -- 129
		end -- 129
		lastRefresh = App.runningTime -- 130
		local ____temp_44 = phase == "busy" -- 131
		if ____temp_44 then -- 131
			local ____temp_43 = shownPhase ~= (operation and operation.phase) -- 131
			if not ____temp_43 then -- 131
				local ____progressBucket_42 = progressBucket -- 131
				local ____math_floor_41 = math.floor -- 131
				local ____opt_37 = operation and operation.status -- 131
				____temp_43 = ____progressBucket_42 ~= ____math_floor_41((____opt_37 and ____opt_37.progress or 0) * 100) -- 131
			end -- 131
			____temp_44 = ____temp_43 -- 131
		end -- 131
		if ____temp_44 or phase == "ready" and targetKey ~= table.concat( -- 131
			__TS__ArrayMap( -- 131
				getTargets(), -- 131
				function(____, t) return t.id end -- 131
			), -- 131
			"," -- 131
		) then -- 131
			render() -- 131
		end -- 131
		return false -- 132
	end) -- 128
	attachGamepad( -- 134
		host, -- 134
		{ -- 134
			initialTag = "import-primary", -- 134
			onBack = finish, -- 134
			onScroll = function(amount) -- 134
				if scroll then -- 134
					scroll.offset = Vec2( -- 134
						0, -- 134
						math.max( -- 134
							0, -- 134
							math.min(scroll.view.height - scroll.height, scroll.offset.y + amount) -- 134
						) -- 134
					) -- 134
				end -- 134
			end -- 134
		} -- 134
	) -- 134
	render() -- 135
	if repository then -- 135
		begin() -- 135
	end -- 135
end -- 12
return ____exports -- 12