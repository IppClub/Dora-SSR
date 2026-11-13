-- [tsx]: Feed.tsx
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayFind = ____lualib.__TS__ArrayFind -- 1
local __TS__ArrayFindIndex = ____lualib.__TS__ArrayFindIndex -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
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
local Ease = ____Dora.Ease -- 2
local HttpServer = ____Dora.HttpServer -- 2
local Move = ____Dora.Move -- 2
local Node = ____Dora.Node -- 2
local sleep = ____Dora.sleep -- 2
local thread = ____Dora.thread -- 2
local Vec2 = ____Dora.Vec2 -- 2
local ____Mascot = require("Dev.Mobile.Mascot") -- 3
local DoraMascot = ____Mascot.DoraMascot -- 3
local ____Gamepad = require("Dev.Mobile.Gamepad") -- 4
local attachGamepad = ____Gamepad.attachGamepad -- 4
local findGamepadNode = ____Gamepad.findGamepadNode -- 4
local ____Accessibility = require("Dev.Mobile.Accessibility") -- 5
local mobileFontScale = ____Accessibility.mobileFontScale -- 5
local ____FeedModel = require("Dev.Mobile.FeedModel") -- 6
local getCoverScales = ____FeedModel.getCoverScales -- 6
local getReusableCardIndices = ____FeedModel.getReusableCardIndices -- 6
local normalizeFeedIndex = ____FeedModel.normalizeFeedIndex -- 6
local resolveDiscoverRefreshTab = ____FeedModel.resolveDiscoverRefreshTab -- 6
local resolveFeedGesture = ____FeedModel.resolveFeedGesture -- 6
local resolveFeedLocation = ____FeedModel.resolveFeedLocation -- 6
local stableCoverColor = ____FeedModel.stableCoverColor -- 6
local ____TextInput = require("Dev.Mobile.TextInput") -- 7
local createTextInput = ____TextInput.createTextInput -- 7
local ____Controls = require("Dev.Mobile.Controls") -- 8
local MobileButton = ____Controls.MobileButton -- 8
local MobileChoiceButton = ____Controls.MobileChoiceButton -- 8
local MobileNewButton = ____Controls.MobileNewButton -- 8
local MobilePanelSurface = ____Controls.MobilePanelSurface -- 8
local ____Visual = require("Dev.Mobile.Visual") -- 9
local roundedRectVerts = ____Visual.roundedRectVerts -- 9
local RoundedStencil = ____Visual.RoundedStencil -- 9
local RoundedSurface = ____Visual.RoundedSurface -- 9
local VerticalGradient = ____Visual.VerticalGradient -- 9
local ____PackagePanel = require("Dev.Mobile.PackagePanel") -- 10
local startPackagePanel = ____PackagePanel.startPackagePanel -- 10
local ____ProjectIndex = require("Dev.Mobile.ProjectIndex") -- 11
local ProjectIndex = ____ProjectIndex.ProjectIndex -- 11
local Updater = require("Tools.SelfUpdater.Service") -- 14
local ____GoPanel = require("Tools.SelfUpdater.GoPanel") -- 15
local createGoUpdaterPanel = ____GoPanel.createGoUpdaterPanel -- 15
local colors = { -- 39
	background = 4278914322, -- 40
	panel = 4279572770, -- 41
	panelRaised = 4280297010, -- 42
	text = 4294242792, -- 43
	muted = 4289245117, -- 44
	brand = 4294954035, -- 45
	border = 4281613128, -- 46
	danger = 4294929259 -- 47
} -- 47
local fontName = "sarasa-mono-sc-regular" -- 50
local createSheetHeight = 304 -- 51
local createInputHeight = 44 -- 52
local createInputTop = 140 -- 53
local function OverlayActionButton(props) -- 57
	return React.createElement( -- 58
		"node", -- 58
		{ -- 58
			key = props.key, -- 58
			tag = props.tag, -- 58
			x = props.x, -- 58
			y = props.y or 20, -- 58
			width = props.width, -- 58
			height = 48, -- 58
			anchorX = 0, -- 58
			anchorY = 0, -- 58
			touchEnabled = true, -- 58
			swallowTouches = true, -- 58
			onTapped = props.onTapped -- 58
		}, -- 58
		React.createElement( -- 58
			"draw-node", -- 58
			{renderOrder = 2}, -- 58
			React.createElement( -- 58
				"polygon-shape", -- 58
				{ -- 58
					verts = roundedRectVerts(props.width, 48, 14), -- 58
					fillColor = props.danger and 4292824662 or 4280889664, -- 58
					borderWidth = 1, -- 58
					borderColor = props.danger and 4294935941 or colors.border -- 58
				} -- 58
			) -- 58
		), -- 58
		React.createElement("label", { -- 58
			x = props.width / 2, -- 58
			y = 24, -- 58
			fontName = fontName, -- 58
			fontSize = props.fontSize or 17, -- 58
			text = props.text, -- 58
			color3 = 16052712, -- 58
			renderOrder = 3 -- 58
		}) -- 58
	) -- 58
end -- 57
local function conciseDescription(text, limit) -- 66
	local length = (utf8.len(text)) or 0 -- 67
	if length <= limit then -- 67
		return text -- 68
	end -- 68
	local stop = utf8.offset(text, limit + 1) or #text + 1 -- 69
	return string.sub(text, 1, stop - 1) .. "…" -- 70
end -- 66
local function formatTransferBytes(bytes) -- 73
	if bytes < 1024 then -- 73
		return tostring(math.floor(bytes)) .. " B" -- 74
	end -- 74
	local value = bytes -- 75
	local units = {"KiB", "MiB", "GiB", "TiB"} -- 76
	for ____, unit in ipairs(units) do -- 77
		value = value / 1024 -- 78
		if value < 1024 or unit == "TiB" then -- 78
			return (string.format("%.1f", value) .. " ") .. unit -- 79
		end -- 79
	end -- 79
	return tostring(math.floor(bytes)) .. " B" -- 81
end -- 73
local function Cover(props) -- 84
	local file = props.entry.bannerFile -- 85
	local function scaleSprite(sprite, mode) -- 86
		local scales = getCoverScales(sprite.width, sprite.height, props.width, props.height) -- 87
		sprite.scaleX = scales[mode] -- 88
		sprite.scaleY = scales[mode] -- 89
	end -- 86
	local ____React_createElement_5 = React.createElement -- 86
	local ____temp_3 = { -- 86
		x = props.x, -- 86
		y = props.y, -- 86
		width = props.width, -- 86
		height = props.height, -- 86
		anchorX = 0, -- 86
		anchorY = 0 -- 86
	} -- 86
	local ____React_createElement_result_4 = React.createElement( -- 86
		RoundedSurface, -- 92
		{ -- 92
			width = props.width, -- 92
			height = props.height, -- 92
			radius = 22, -- 92
			topColor = stableCoverColor(props.entry.id), -- 92
			bottomColor = 4279310115, -- 92
			shadow = true -- 92
		} -- 92
	) -- 92
	local ____file_0 -- 94
	if file then -- 94
		____file_0 = React.createElement( -- 94
			"clip-node", -- 94
			{ -- 94
				width = props.width, -- 94
				height = props.height, -- 94
				anchorX = 0, -- 94
				anchorY = 0, -- 94
				stencil = React.createElement(RoundedStencil, {width = props.width, height = props.height, radius = 22}) -- 94
			}, -- 94
			React.createElement( -- 94
				"sprite", -- 94
				{ -- 94
					file = file, -- 94
					x = props.width / 2 - 5, -- 94
					y = props.height / 2, -- 94
					opacity = 0.08, -- 94
					onMount = function(sprite) return scaleSprite(sprite, "cover") end -- 94
				} -- 94
			), -- 94
			React.createElement( -- 94
				"sprite", -- 94
				{ -- 94
					file = file, -- 94
					x = props.width / 2 + 5, -- 94
					y = props.height / 2, -- 94
					opacity = 0.08, -- 94
					onMount = function(sprite) return scaleSprite(sprite, "cover") end -- 94
				} -- 94
			), -- 94
			React.createElement( -- 94
				"sprite", -- 94
				{ -- 94
					file = file, -- 94
					x = props.width / 2, -- 94
					y = props.height / 2 - 5, -- 94
					opacity = 0.08, -- 94
					onMount = function(sprite) return scaleSprite(sprite, "cover") end -- 94
				} -- 94
			), -- 94
			React.createElement( -- 94
				"draw-node", -- 94
				{x = props.width / 2, y = props.height / 2}, -- 94
				React.createElement("rect-shape", {width = props.width, height = props.height, fillColor = 2953514258}) -- 94
			), -- 94
			React.createElement( -- 94
				"sprite", -- 94
				{ -- 94
					file = file, -- 94
					x = props.width / 2, -- 94
					y = props.height / 2, -- 94
					onMount = function(sprite) return scaleSprite(sprite, "contain") end -- 94
				} -- 94
			) -- 94
		) -- 94
	else -- 94
		____file_0 = React.createElement( -- 94
			"label", -- 94
			{ -- 94
				x = props.width / 2, -- 94
				y = props.height / 2 + 10, -- 94
				fontName = fontName, -- 94
				fontSize = math.floor(math.max( -- 94
					22, -- 106
					math.min(34, props.width / 12) -- 106
				)), -- 106
				text = props.entry.title, -- 106
				textWidth = props.width - 40, -- 106
				color3 = 16052712 -- 106
			} -- 106
		) -- 106
	end -- 106
	local ____file_1 -- 111
	if file then -- 111
		____file_1 = nil -- 111
	else -- 111
		____file_1 = React.createElement("label", { -- 111
			x = props.width / 2, -- 111
			y = 30, -- 111
			fontName = fontName, -- 111
			fontSize = 14, -- 111
			text = "DORA SSR · REMIXABLE", -- 111
			color3 = 16763955 -- 111
		}) -- 111
	end -- 111
	local ____file_2 -- 119
	if file then -- 119
		____file_2 = nil -- 119
	else -- 119
		____file_2 = React.createElement(DoraMascot, {state = "idle", x = props.width - 46, y = 64, size = 42}) -- 119
	end -- 119
	return ____React_createElement_5( -- 91
		"node", -- 91
		____temp_3, -- 91
		____React_createElement_result_4, -- 91
		____file_0, -- 91
		____file_1, -- 91
		____file_2, -- 91
		React.createElement(RoundedSurface, { -- 91
			width = props.width, -- 91
			height = props.height, -- 91
			radius = 22, -- 91
			fillColor = 0, -- 91
			borderWidth = 1, -- 91
			borderColor = 4282074454 -- 91
		}) -- 91
	) -- 91
end -- 84
function ____exports.startMobileFeed(options) -- 124
	local submitCreate, render, refreshDiscover -- 124
	local getLocalEntries = options.getLocalEntries -- 125
	local getDiscoverEntries = options.getDiscoverEntries -- 126
	local onPlay = options.onPlay -- 127
	local onRemix = options.onRemix -- 128
	local prepare = options.prepare -- 129
	local syncDiscover = options.syncDiscover -- 130
	local canShare = App.platform == "Android" or App.platform == "iOS" -- 131
	local zh = (string.match(App.locale, "^zh")) ~= nil -- 132
	local tab = "local" -- 133
	local index = 0 -- 134
	local drag = Vec2.zero -- 135
	local dragAxis = "none" -- 136
	local discoverError = "" -- 137
	local preparing = false -- 138
	local transitioning = false -- 139
	local prepareStatus = "" -- 140
	local prepareProgress = 0 -- 141
	local prepareTransferredBytes = 0 -- 142
	local prepareCanceled = false -- 143
	local synchronizing = false -- 144
	local syncConfirmation -- 145
	local syncFailure = "" -- 146
	local managementOpen = false -- 147
	local catalogSyncing = false -- 148
	local catalogStatus = "" -- 149
	local catalogStatusView -- 150
	local repairResourceId = "" -- 151
	local userSelectedTab = false -- 152
	local active = true -- 153
	local leaving = false -- 154
	local packagePanel -- 155
	local createOpen = false -- 156
	local projectIndexOpen = false -- 157
	local creating = false -- 158
	local createName = "" -- 159
	local createLanguage = "typescript" -- 160
	local dismissedCreateComposition = false -- 161
	local createError = "" -- 162
	local gamepadUsed = false -- 163
	local returnEntry = options.initialEntry -- 164
	local ____opt_6 = options.initialEntries -- 164
	local ____temp_10 = ____opt_6 and ____opt_6["local"] -- 166
	local ____opt_8 = options.initialEntries -- 166
	local rememberedEntries = {["local"] = ____temp_10, discover = ____opt_8 and ____opt_8.discover} -- 165
	local cardRef = reference() -- 169
	local indexRef = reference() -- 170
	local createInputRef = reference() -- 171
	local discover = getDiscoverEntries() -- 172
	local ____local = getLocalEntries() -- 173
	if #discover == 0 then -- 173
		discoverError = zh and "资源目录暂不可用" or "Catalog is unavailable" -- 176
	end -- 176
	local initialLocation = resolveFeedLocation(____local, discover, returnEntry) -- 178
	tab = initialLocation.tab -- 179
	index = initialLocation.index -- 180
	local host = Node() -- 182
	host.tag = "mobile-feed" -- 183
	host.scaleX = App.devicePixelRatio -- 184
	host.scaleY = App.devicePixelRatio -- 185
	host:addTo(Director.systemUI) -- 186
	local function isActive() -- 188
		return active and not leaving and host.parent ~= nil -- 188
	end -- 188
	local function entries() -- 190
		return tab == "discover" and discover or ____local -- 190
	end -- 190
	local function current() -- 191
		return entries()[normalizeFeedIndex( -- 191
			index, -- 191
			#entries() -- 191
		) + 1] -- 191
	end -- 191
	local rememberedEntryKey = "" -- 192
	local function rememberCurrent() -- 193
		local item = current() -- 194
		if not item or not options.onCurrentEntryChanged then -- 194
			return -- 195
		end -- 195
		local key = (((((item.kind .. "\n") .. item.id) .. "\n") .. (item.workDir or "")) .. "\n") .. (item.fileName or "") -- 196
		if key == rememberedEntryKey then -- 196
			return -- 197
		end -- 197
		rememberedEntryKey = key -- 198
		rememberedEntries[item.kind] = item -- 199
		options.onCurrentEntryChanged(item) -- 200
	end -- 193
	local function canEditCreate() -- 202
		return createOpen and not creating and isActive() and host.visible and HttpServer.wsConnectionCount == 0 -- 202
	end -- 202
	local createInput = createTextInput({ -- 203
		fontSize = math.floor(16 * mobileFontScale), -- 204
		singleLine = true, -- 205
		background = colors.background, -- 206
		getText = function() return createName end, -- 207
		setText = function(text) -- 208
			createName = text -- 208
		end, -- 208
		getPlaceholder = function() return zh and "例如：星际花园" or "For example: Star Garden" end, -- 209
		isEnabled = canEditCreate, -- 210
		onReturn = function() -- 211
			submitCreate() -- 211
			return true -- 211
		end -- 211
	}) -- 211
	local blurCreateInput = createInput.blur -- 213
	local function closeCreate() -- 214
		if creating then -- 214
			return -- 215
		end -- 215
		blurCreateInput() -- 216
		createOpen = false -- 217
		createName = "" -- 218
		createError = "" -- 219
		render() -- 220
	end -- 214
	local function openCreate() -- 222
		if not options.createProject or preparing or transitioning or creating or createOpen or syncConfirmation or managementOpen or HttpServer.wsConnectionCount > 0 then -- 222
			return -- 223
		end -- 223
		projectIndexOpen = false -- 224
		createOpen = true -- 225
		createLanguage = "typescript" -- 226
		createName = "" -- 227
		dismissedCreateComposition = false -- 228
		createError = "" -- 229
		render() -- 230
		createInput.deferFocus() -- 231
	end -- 222
	local function openProjectIndex() -- 233
		if preparing or transitioning or creating or createOpen or syncConfirmation or managementOpen or HttpServer.wsConnectionCount > 0 then -- 233
			return -- 234
		end -- 234
		if tab == "local" then -- 234
			____local = getLocalEntries() -- 235
		end -- 235
		projectIndexOpen = true -- 236
		render() -- 237
	end -- 233
	local function createErrorText(____error) -- 239
		repeat -- 239
			local ____switch37 = ____error -- 239
			local ____cond37 = ____switch37 == "invalid-name" -- 239
			if ____cond37 then -- 239
				return zh and "请输入不含路径分隔符的项目名称" or "Enter a project name without path separators" -- 241
			end -- 241
			____cond37 = ____cond37 or ____switch37 == "target-existed" -- 241
			if ____cond37 then -- 241
				return zh and "已有同名项目，请换一个名称" or "A project with that name already exists" -- 242
			end -- 242
			____cond37 = ____cond37 or ____switch37 == "create-folder-failed" -- 242
			if ____cond37 then -- 242
				return zh and "无法创建项目目录，请检查工作目录后重试" or "Could not create the project folder; check the workspace and retry" -- 243
			end -- 243
			____cond37 = ____cond37 or ____switch37 == "create-entry-failed" -- 243
			if ____cond37 then -- 243
				return zh and "无法写入项目入口，未完成项目已回滚" or "Could not write the project entry; the incomplete project was rolled back" -- 244
			end -- 244
			____cond37 = ____cond37 or ____switch37 == "created-project-not-found" -- 244
			if ____cond37 then -- 244
				return zh and "项目已创建，但本地列表未能找到它，请返回后重试" or "The project was created but could not be found in Local; return and retry" -- 245
			end -- 245
			do -- 245
				return zh and "创建失败，请重试" or "Project creation failed; try again" -- 246
			end -- 246
		until true -- 246
	end -- 239
	submitCreate = function() -- 249
		if not options.createProject or creating or not createOpen or not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 then -- 249
			return -- 250
		end -- 250
		if createInput.isComposing() then -- 250
			return -- 251
		end -- 251
		creating = true -- 252
		createError = "" -- 253
		blurCreateInput() -- 254
		render() -- 255
		local result = options.createProject(createName, createLanguage) -- 256
		if not isActive() then -- 256
			return -- 257
		end -- 257
		creating = false -- 258
		if not result.success then -- 258
			createError = createErrorText(result.error) -- 260
			render() -- 261
			return -- 262
		end -- 262
		createOpen = false -- 264
		createName = "" -- 265
		____local = getLocalEntries() -- 266
		returnEntry = result.entry -- 267
		local location = resolveFeedLocation(____local, discover, result.entry) -- 268
		tab = location.tab -- 269
		index = location.index -- 270
		render() -- 271
		onRemix(result.entry) -- 272
	end -- 249
	local function openPackage(mode, path, pickOnOpen) -- 275
		if pickOnOpen == nil then -- 275
			pickOnOpen = false -- 275
		end -- 275
		if not isActive() or not host.visible or packagePanel or preparing or transitioning or creating or createOpen or HttpServer.wsConnectionCount > 0 then -- 275
			return -- 276
		end -- 276
		projectIndexOpen = false -- 277
		packagePanel = startPackagePanel({ -- 278
			mode = mode, -- 279
			path = path, -- 279
			pickOnOpen = pickOnOpen, -- 279
			entry = current(), -- 279
			onNew = openCreate, -- 280
			onClosed = function() -- 281
				packagePanel = nil -- 281
			end, -- 281
			onImported = function(entry, play) -- 282
				if not isActive() then -- 282
					return -- 283
				end -- 283
				____local = getLocalEntries(entry.workDir) -- 284
				local imported = __TS__ArrayFind( -- 285
					____local, -- 285
					function(____, item) return item.workDir == entry.workDir end -- 285
				) or entry -- 285
				returnEntry = imported -- 286
				local location = resolveFeedLocation(____local, discover, imported) -- 287
				tab = "local" -- 288
				index = location.index -- 288
				render() -- 289
				if play then -- 289
					onPlay(imported) -- 290
				end -- 290
			end -- 282
		}) -- 282
	end -- 275
	local updatePanel -- 294
	local updateAvailable = Updater.getState().available -- 295
	local function openUpdate() -- 296
		if updatePanel or preparing or creating or createOpen or packagePanel or transitioning or syncConfirmation or managementOpen then -- 296
			return -- 297
		end -- 297
		updatePanel = createGoUpdaterPanel(function() -- 298
			updatePanel = nil -- 298
		end) -- 298
		updatePanel:addTo(Director.systemUI) -- 299
	end -- 296
	local receiveElapsed = 0 -- 301
	host:schedule(function(dt) -- 302
		receiveElapsed = receiveElapsed + dt -- 303
		if receiveElapsed < 0.5 then -- 303
			return false -- 304
		end -- 304
		receiveElapsed = 0 -- 305
		local available = Updater.getState().available -- 306
		if available ~= updateAvailable and not createOpen and not preparing and not transitioning then -- 306
			updateAvailable = available -- 307
			render() -- 307
		end -- 307
		if updatePanel then -- 307
			return false -- 308
		end -- 308
		if isActive() and host.visible and not packagePanel and not createOpen and not projectIndexOpen and not managementOpen and not syncConfirmation and not preparing and not transitioning and HttpServer.wsConnectionCount == 0 then -- 308
			local path = options.takeReceivedFile and options.takeReceivedFile() or App:takeReceivedFile() -- 310
			if path ~= "" then -- 310
				openPackage("receive", path) -- 311
			end -- 311
		end -- 311
		return false -- 313
	end) -- 302
	local function setTab(next) -- 316
		if not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 or preparing or creating or syncConfirmation or managementOpen then -- 316
			return -- 317
		end -- 317
		userSelectedTab = true -- 318
		returnEntry = nil -- 319
		if tab == next then -- 319
			return -- 320
		end -- 320
		if createOpen then -- 320
			blurCreateInput() -- 322
			createOpen = false -- 323
			createName = "" -- 324
			createError = "" -- 325
		end -- 325
		tab = next -- 327
		local target = rememberedEntries[next] -- 328
		local ____temp_11 -- 329
		if target == nil then -- 329
			____temp_11 = nil -- 329
		else -- 329
			____temp_11 = resolveFeedLocation(____local, discover, target) -- 329
		end -- 329
		local location = ____temp_11 -- 329
		index = (location and location.tab) == next and location.index or 0 -- 330
		render() -- 331
	end -- 316
	local function activate(action) -- 333
		local item = current() -- 334
		if not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 or not item or preparing or syncConfirmation or managementOpen then -- 334
			return -- 335
		end -- 335
		if item.webPlayUrl then -- 335
			local url = action == "play" and item.webPlayUrl or item.sourceUrl -- 337
			if url then -- 337
				App:openURL(url) -- 338
			end -- 338
			return -- 339
		end -- 339
		item.launchError = nil -- 341
		local function done() -- 342
			returnEntry = item -- 342
			local ____temp_14 -- 342
			if action == "play" then -- 342
				____temp_14 = onPlay(item) -- 342
			else -- 342
				____temp_14 = onRemix(item) -- 342
			end -- 342
			return ____temp_14 -- 342
		end -- 342
		if item.kind == "local" or item.installed then -- 342
			done() -- 343
			return -- 343
		end -- 343
		preparing = true -- 344
		prepareProgress = 0 -- 345
		prepareTransferredBytes = 0 -- 346
		prepareCanceled = false -- 347
		prepareStatus = zh and "准备安装…" or "Preparing install…" -- 348
		render() -- 349
		local repairIncomplete = repairResourceId == item.id -- 350
		repairResourceId = "" -- 351
		prepare( -- 352
			item, -- 352
			repairIncomplete, -- 352
			function(progress, message, transferredBytes) -- 352
				if not isActive() then -- 352
					return -- 353
				end -- 353
				prepareProgress = math.max( -- 354
					0, -- 354
					math.min(1, progress) -- 354
				) -- 354
				if transferredBytes ~= nil then -- 354
					prepareTransferredBytes = math.max(prepareTransferredBytes, transferredBytes) -- 355
				end -- 355
				prepareStatus = message -- 356
				render() -- 357
			end, -- 352
			function(success, ready, message, repairable) -- 358
				if not isActive() then -- 358
					return -- 359
				end -- 359
				preparing = false -- 360
				if not success or not ready then -- 360
					repairResourceId = repairable and item.id or "" -- 362
					prepareStatus = message or (zh and "安装失败，点击按钮重试" or "Install failed; tap to retry") -- 363
					render() -- 364
					return -- 365
				end -- 365
				item.fileName = ready.fileName -- 367
				item.workDir = ready.workDir -- 368
				item.installed = true -- 369
				prepareStatus = "" -- 370
				if HttpServer.wsConnectionCount == 0 and host.visible then -- 370
					done() -- 371
				else -- 371
					render() -- 372
				end -- 372
			end, -- 358
			function() return prepareCanceled end -- 373
		) -- 373
	end -- 333
	local function cancelPrepare() -- 375
		if not preparing or prepareCanceled then -- 375
			return -- 376
		end -- 376
		prepareCanceled = true -- 377
		prepareStatus = zh and "正在中断下载…" or "Canceling download…" -- 378
		render() -- 379
	end -- 375
	local function closeManagement() -- 381
		managementOpen = false -- 381
		render() -- 381
	end -- 381
	local function openManagement() -- 382
		local item = current() -- 383
		if not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 or not item or item.kind ~= "local" or preparing or transitioning or creating or createOpen or packagePanel or syncConfirmation then -- 383
			return -- 385
		end -- 385
		managementOpen = not managementOpen -- 386
		render() -- 387
	end -- 382
	local function dismissSyncConfirmation() -- 389
		syncConfirmation = nil -- 389
		render() -- 389
	end -- 389
	local function synchronize(item, force) -- 390
		if not options.sync or not item.resource or item.kind ~= "local" or preparing or not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 then -- 390
			return -- 392
		end -- 392
		syncConfirmation = nil -- 393
		managementOpen = false -- 394
		preparing = true -- 395
		synchronizing = true -- 396
		prepareProgress = 0 -- 397
		prepareTransferredBytes = 0 -- 398
		prepareCanceled = false -- 399
		prepareStatus = zh and "正在同步…" or "Synchronizing…" -- 400
		render() -- 401
		options.sync( -- 402
			item, -- 402
			force, -- 402
			function(progress, message, transferredBytes) -- 402
				if not isActive() then -- 402
					return -- 403
				end -- 403
				prepareProgress = math.max( -- 404
					0, -- 404
					math.min(1, progress) -- 404
				) -- 404
				prepareTransferredBytes = transferredBytes or prepareTransferredBytes -- 405
				prepareStatus = message -- 406
				render() -- 407
			end, -- 402
			function(success, ready, message, forceable) -- 408
				if not isActive() then -- 408
					return -- 409
				end -- 409
				preparing = false -- 410
				synchronizing = false -- 411
				if success and ready then -- 411
					____local = getLocalEntries(ready.workDir) -- 413
					discover = getDiscoverEntries() -- 414
					local sameEntry = __TS__ArrayFindIndex( -- 415
						____local, -- 415
						function(____, entry) return entry.fileName == item.fileName end -- 415
					) -- 415
					local sameResource = __TS__ArrayFindIndex( -- 416
						____local, -- 416
						function(____, entry) -- 416
							local ____opt_15 = entry.resource -- 416
							local ____temp_19 = ____opt_15 and ____opt_15.id -- 416
							local ____opt_17 = item.resource -- 416
							return ____temp_19 == (____opt_17 and ____opt_17.id) -- 416
						end -- 416
					) -- 416
					index = normalizeFeedIndex(sameEntry >= 0 and sameEntry or (sameResource >= 0 and sameResource or index), #____local) -- 417
					prepareStatus = message or (zh and "同步完成" or "Synchronized") -- 418
				else -- 418
					prepareStatus = message or (zh and "同步失败" or "Synchronization failed") -- 420
					if not force and forceable and not prepareCanceled then -- 420
						syncFailure = prepareStatus -- 422
						syncConfirmation = item -- 423
					end -- 423
				end -- 423
				render() -- 426
			end, -- 408
			function() return prepareCanceled or not isActive() end -- 427
		) -- 427
	end -- 390
	local function commit(action) -- 430
		if not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 or preparing or transitioning or syncConfirmation or managementOpen then -- 430
			return -- 431
		end -- 431
		if action == "play" or action == "remix" then -- 431
			local card = cardRef.current -- 433
			if card then -- 433
				card.position = Vec2.zero -- 434
			end -- 434
		end -- 434
		repeat -- 434
			local ____switch100 = action -- 434
			local ____cond100 = ____switch100 == "previous" or ____switch100 == "next" -- 434
			if ____cond100 then -- 434
				do -- 434
					returnEntry = nil -- 439
					local target = normalizeFeedIndex( -- 440
						index + (action == "next" and 1 or -1), -- 440
						#entries() -- 440
					) -- 440
					if target == index then -- 440
						local card = cardRef.current -- 442
						if card then -- 442
							card:perform(Move(App.reducedMotion and 0 or 0.16, card.position, Vec2.zero, Ease.OutQuad)) -- 443
						end -- 443
						return -- 444
					end -- 444
					local duration = App.reducedMotion and 0 or 0.18 -- 446
					local function finish() -- 447
						if not isActive() then -- 447
							return -- 448
						end -- 448
						index = target -- 449
						transitioning = false -- 450
						App:vibrate(0.012) -- 451
						render() -- 452
					end -- 447
					local card = cardRef.current -- 454
					if duration > 0 and card then -- 454
						transitioning = true -- 456
						card:perform(Move( -- 457
							duration, -- 457
							card.position, -- 457
							Vec2(0, (action == "next" and 1 or -1) * App.safeArea.height), -- 457
							Ease.OutQuad -- 457
						)) -- 457
						thread(function() -- 458
							sleep(duration) -- 458
							finish() -- 458
						end) -- 458
					else -- 458
						finish() -- 459
					end -- 459
					return -- 460
				end -- 460
			end -- 460
			____cond100 = ____cond100 or ____switch100 == "play" -- 460
			if ____cond100 then -- 460
				activate("play") -- 462
				return -- 462
			end -- 462
			____cond100 = ____cond100 or ____switch100 == "remix" -- 462
			if ____cond100 then -- 462
				activate("remix") -- 463
				return -- 463
			end -- 463
			do -- 463
				return -- 464
			end -- 464
		until true -- 464
	end -- 430
	local function switchMode() -- 468
		if not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 or preparing or creating or createOpen or packagePanel or transitioning or syncConfirmation or managementOpen or updatePanel or not options.onSwitchMode then -- 468
			return -- 469
		end -- 469
		leaving = true -- 470
		options.onSwitchMode() -- 471
	end -- 468
	host:slot("SwitchUIMode", switchMode) -- 473
	render = function() -- 474
		if not isActive() then -- 474
			return -- 475
		end -- 475
		catalogStatusView = nil -- 476
		local safeContentWidth = App.safeArea.width - 40 -- 478
		local shortLandscapeInputWidth = safeContentWidth - 12 - math.min( -- 479
			300, -- 479
			math.floor(safeContentWidth * 0.42) -- 479
		) -- 479
		local expectedInputWidth = App.safeArea.width >= 760 and App.safeArea.height < 500 and shortLandscapeInputWidth or safeContentWidth -- 480
		local ____createOpen_22 = createOpen -- 481
		if ____createOpen_22 then -- 481
			local ____opt_20 = createInputRef.current -- 481
			____createOpen_22 = (____opt_20 and ____opt_20.width) == expectedInputWidth -- 481
		end -- 481
		local keptInput = ____createOpen_22 and createInputRef.current or nil -- 481
		local restoreFocus = createInput.isFocused() -- 482
		if keptInput ~= nil then -- 482
			keptInput:removeFromParent(false) -- 483
		end -- 483
		if not keptInput then -- 483
			createInput.unmount() -- 485
			createInputRef = reference() -- 486
		end -- 486
		local createPanelRef = reference() -- 488
		host:removeAllChildren() -- 489
		host.scaleX = App.devicePixelRatio -- 490
		host.scaleY = App.devicePixelRatio -- 491
		local ____App_visualSize_25 = App.visualSize -- 492
		local width = ____App_visualSize_25.width -- 492
		local height = ____App_visualSize_25.height -- 492
		local safe = App.safeArea -- 493
		local left = safe.left -- 494
		local bottom = safe.bottom -- 495
		local usableWidth = safe.width -- 496
		local usableHeight = safe.height -- 497
		local wide = usableWidth >= 760 -- 498
		local updateHeaderExtra = Updater.getState().available and usableWidth < 400 and 44 or 0 -- 499
		local shortLandscape = wide and usableHeight < 500 -- 500
		local compact = not wide and usableHeight < 700 -- 501
		local compactLandscape = compact and usableWidth > usableHeight and usableHeight < 520 -- 502
		local landscapeTopLift = shortLandscape and 28 or 0 -- 503
		local data = entries() -- 504
		index = normalizeFeedIndex(index, #data) -- 505
		local item = current() -- 506
		rememberCurrent() -- 507
		local coverWidth = wide and math.min(usableWidth * 0.54, 680) or usableWidth - 32 -- 508
		local baseCoverHeight = wide and math.min(usableHeight - 118, coverWidth * 0.72) or (compact and math.min(usableHeight * (compactLandscape and 0.43 or 0.49), coverWidth * 0.72) or math.min(usableHeight * 0.54, coverWidth * 1.12)) -- 509
		local coverHeight = math.max(100, baseCoverHeight - updateHeaderExtra) -- 514
		local coverX = left + 16 -- 515
		local coverY = wide and bottom + (usableHeight - coverHeight) / 2 - 12 + landscapeTopLift or bottom + usableHeight - coverHeight - 82 - updateHeaderExtra -- 516
		local infoX = wide and coverX + coverWidth + 28 or left + 20 -- 517
		local infoWidth = wide and usableWidth - coverWidth - 72 or usableWidth - 40 -- 518
		local infoTop = wide and bottom + usableHeight - 122 + landscapeTopLift or coverY - (compactLandscape and 28 or 30) -- 519
		local descriptionY = infoTop - (compactLandscape and 38 or 58) -- 520
		local metadataY = infoTop - (wide and 136 or 118) -- 521
		local actionsY = bottom + (compactLandscape and 18 or 24) -- 522
		local gestureHintY = bottom + (compactLandscape and 88 or 92) -- 523
		local canSync = (item and item.kind) == "local" and item.resource ~= nil and options.sync ~= nil -- 524
		local canManage = (item and item.kind) == "local" and (canShare or canSync) -- 525
		local buttonWidth = wide and math.min(190, (infoWidth - 12) / 2) or (infoWidth - 12) / 2 -- 526
		local fontScale = mobileFontScale -- 527
		local cardIndices = getReusableCardIndices(index, #data) -- 528
		local headerRenderOrder = 1000 -- 529
		local ____toNode_72 = toNode -- 531
		local ____React_createElement_71 = React.createElement -- 531
		local ____array_70 = __TS__SparseArrayNew( -- 531
			"node", -- 531
			{ -- 531
				tag = "mobile-feed-scene", -- 531
				x = -width / 2, -- 531
				y = -height / 2, -- 531
				width = width, -- 531
				height = height, -- 531
				anchorX = 0, -- 531
				anchorY = 0, -- 531
				touchEnabled = true, -- 531
				onTapBegan = function() -- 531
					drag = Vec2.zero -- 541
					dragAxis = "none" -- 542
					local ____opt_30 = cardRef.current -- 542
					if ____opt_30 ~= nil then -- 542
						____opt_30:stopAllActions() -- 543
					end -- 543
					if indexRef.current then -- 543
						indexRef.current.opacity = 1 -- 544
					end -- 544
				end, -- 540
				onTapMoved = function(touch) -- 540
					drag = drag:add(touch.delta) -- 547
					if dragAxis == "none" and math.max( -- 547
						math.abs(drag.x), -- 548
						math.abs(drag.y) -- 548
					) >= 12 then -- 548
						dragAxis = math.abs(drag.x) > math.abs(drag.y) * 1.2 and "horizontal" or "vertical" -- 549
					end -- 549
					if cardRef.current then -- 549
						local offset = dragAxis == "horizontal" and Vec2(drag.x * 0.18, 0) or (dragAxis == "vertical" and Vec2(0, drag.y * 0.12) or Vec2.zero) -- 552
						cardRef.current.position = offset -- 553
						if indexRef.current then -- 553
							local headerBottom = bottom + usableHeight - 72 -- 555
							local indexTop = coverY + coverHeight - 14 + offset.y -- 556
							indexRef.current.opacity = dragAxis == "vertical" and math.max( -- 557
								0, -- 558
								math.min(1, (headerBottom - indexTop) / 16) -- 558
							) or 1 -- 558
						end -- 558
					end -- 558
				end, -- 546
				onTapEnded = function() -- 546
					local action = resolveFeedGesture(drag.x, drag.y, usableWidth, usableHeight) -- 564
					drag = Vec2.zero -- 565
					dragAxis = "none" -- 566
					if indexRef.current then -- 566
						indexRef.current.opacity = 1 -- 567
					end -- 567
					if action == "none" and cardRef.current then -- 567
						local card = cardRef.current -- 569
						card:perform(Move(App.reducedMotion and 0 or 0.16, card.position, Vec2.zero, Ease.OutQuad)) -- 570
					end -- 570
					commit(action) -- 572
				end, -- 563
				onMouseWheel = function(delta) return commit(delta.y > 0 and "previous" or "next") end -- 563
			}, -- 563
			React.createElement(VerticalGradient, {width = width, height = height, topColor = 4279310117, bottomColor = 4278716943}) -- 563
		) -- 563
		local ____React_createElement_68 = React.createElement -- 563
		local ____temp_66 = {visible = not projectIndexOpen} -- 563
		local ____createOpen_47 -- 578
		if createOpen then -- 578
			____createOpen_47 = nil -- 578
		else -- 578
			local ____temp_46 -- 578
			if item ~= nil then -- 578
				local ____React_createElement_45 = React.createElement -- 578
				local ____array_44 = __TS__SparseArrayNew( -- 578
					"node", -- 578
					{tag = "mobile-feed-card-" .. item.id, ref = cardRef, key = (tab .. "-") .. item.id}, -- 578
					__TS__ArrayMap( -- 579
						cardIndices, -- 579
						function(____, cardIndex) return React.createElement(Cover, { -- 579
							key = (tab .. "-") .. data[cardIndex + 1].id, -- 579
							entry = data[cardIndex + 1], -- 579
							x = coverX, -- 579
							y = coverY + (index - cardIndex) * usableHeight, -- 579
							width = coverWidth, -- 579
							height = coverHeight -- 579
						}) end -- 579
					), -- 579
					React.createElement( -- 579
						"node", -- 579
						{ -- 579
							tag = "mobile-feed-index", -- 579
							ref = indexRef, -- 579
							order = 10, -- 579
							renderGroup = true, -- 579
							x = coverX + coverWidth - 62, -- 579
							y = coverY + coverHeight - 40, -- 579
							width = 48, -- 579
							height = 26, -- 579
							anchorX = 0, -- 579
							anchorY = 0, -- 579
							touchEnabled = true, -- 579
							swallowTouches = true, -- 579
							onTapped = openProjectIndex -- 579
						}, -- 579
						React.createElement( -- 579
							"clip-node", -- 579
							{ -- 579
								width = 48, -- 579
								height = 26, -- 579
								anchorX = 0, -- 579
								anchorY = 0, -- 579
								stencil = React.createElement(RoundedStencil, {width = 48, height = 26, radius = 13}) -- 579
							}, -- 579
							React.createElement( -- 579
								"draw-node", -- 579
								nil, -- 579
								React.createElement( -- 579
									"verts-shape", -- 579
									{verts = { -- 579
										{ -- 592
											Vec2(0, 0), -- 592
											3759281694 -- 592
										}, -- 592
										{ -- 592
											Vec2(48, 0), -- 592
											3759281694 -- 592
										}, -- 592
										{ -- 592
											Vec2(48, 26), -- 592
											3760730173 -- 592
										}, -- 592
										{ -- 593
											Vec2(0, 0), -- 593
											3759281694 -- 593
										}, -- 593
										{ -- 593
											Vec2(48, 26), -- 593
											3760730173 -- 593
										}, -- 593
										{ -- 593
											Vec2(0, 26), -- 593
											3760730173 -- 593
										} -- 593
									}} -- 593
								) -- 593
							) -- 593
						), -- 593
						React.createElement( -- 593
							"draw-node", -- 593
							{x = 0.5, y = 0.5}, -- 593
							React.createElement( -- 593
								"polygon-shape", -- 593
								{ -- 593
									verts = roundedRectVerts(47, 25, 12.5), -- 593
									fillColor = 0, -- 593
									borderWidth = 0.5, -- 593
									borderColor = 2286967404 -- 593
								} -- 593
							) -- 593
						), -- 593
						React.createElement( -- 593
							"draw-node", -- 593
							{x = 18, y = 2}, -- 593
							React.createElement( -- 593
								"polygon-shape", -- 593
								{ -- 593
									verts = roundedRectVerts(12, 2, 1), -- 593
									fillColor = colors.brand -- 593
								} -- 593
							) -- 593
						), -- 593
						React.createElement( -- 593
							"label", -- 593
							{ -- 593
								x = 24, -- 593
								y = 13, -- 593
								fontName = fontName, -- 593
								fontSize = 11, -- 593
								text = (tostring(index + 1) .. " / ") .. tostring(#data), -- 593
								color3 = 14146531 -- 593
							} -- 593
						) -- 593
					), -- 593
					React.createElement( -- 593
						"label", -- 593
						{ -- 593
							tag = "mobile-feed-current-title", -- 593
							x = infoX, -- 593
							y = infoTop, -- 593
							anchorX = 0, -- 593
							anchorY = 0.5, -- 593
							fontName = fontName, -- 593
							fontSize = math.floor((wide and 30 or 25) * fontScale), -- 593
							text = item.title, -- 593
							textWidth = infoWidth - (canManage and 92 or 0), -- 593
							alignment = "Left", -- 593
							color3 = 16052712 -- 593
						} -- 593
					) -- 593
				) -- 593
				local ____canManage_32 -- 602
				if canManage then -- 602
					____canManage_32 = React.createElement(MobileButton, { -- 602
						tag = "mobile-feed-manage", -- 602
						x = infoX + infoWidth - 84, -- 602
						y = infoTop - 18, -- 602
						width = 84, -- 602
						height = 36, -- 602
						text = zh and "管理" or "Manage", -- 602
						fontSize = 13, -- 602
						onTapped = openManagement -- 602
					}) -- 602
				else -- 602
					____canManage_32 = nil -- 602
				end -- 602
				__TS__SparseArrayPush( -- 602
					____array_44, -- 602
					____canManage_32, -- 602
					React.createElement( -- 602
						"label", -- 602
						{ -- 602
							tag = "mobile-feed-description", -- 602
							x = infoX, -- 602
							y = descriptionY, -- 602
							anchorX = 0, -- 602
							anchorY = 0.5, -- 602
							fontName = fontName, -- 602
							fontSize = math.floor(15 * fontScale), -- 602
							text = conciseDescription(item.description, wide and 80 or (compact and 28 or 42)), -- 602
							textWidth = infoWidth, -- 602
							alignment = "Left", -- 602
							color3 = 11055037 -- 602
						} -- 602
					) -- 602
				) -- 602
				local ____temp_33 -- 605
				if compact or shortLandscape then -- 605
					____temp_33 = nil -- 605
				else -- 605
					____temp_33 = React.createElement( -- 605
						"node", -- 605
						{ -- 605
							x = infoX, -- 605
							y = metadataY, -- 605
							width = wide and 176 or 164, -- 605
							height = 28, -- 605
							anchorX = 0, -- 605
							anchorY = 0 -- 605
						}, -- 605
						React.createElement(RoundedSurface, { -- 605
							width = wide and 176 or 164, -- 605
							height = 28, -- 605
							radius = 14, -- 605
							topColor = 1714436683, -- 605
							bottomColor = 1712857131, -- 605
							borderWidth = 1, -- 605
							borderColor = 2288020349 -- 605
						}), -- 605
						React.createElement("label", { -- 605
							x = 12, -- 605
							y = 14, -- 605
							anchorX = 0, -- 605
							fontName = fontName, -- 605
							fontSize = 12, -- 605
							text = item.webPlayUrl and (zh and "发现  ·  在线试玩" or "Discover  ·  Web game") or (item.kind == "local" and (zh and "本地作品  ·  可 Remix" or "Local  ·  Remixable") or (item.installed and (zh and "发现  ·  已安装" or "Discover  ·  Installed") or (zh and "发现  ·  可安装" or "Discover  ·  Installable"))), -- 605
							textWidth = (wide and 176 or 164) - 24, -- 605
							alignment = "Left", -- 605
							color3 = 14475754 -- 605
						}) -- 605
					) -- 605
				end -- 605
				__TS__SparseArrayPush(____array_44, ____temp_33) -- 605
				local ____preparing_42 -- 611
				if preparing then -- 611
					local ____React_createElement_41 = React.createElement -- 611
					local ____array_40 = __TS__SparseArrayNew( -- 611
						"node", -- 611
						{ -- 611
							tag = "mobile-feed-download", -- 611
							x = infoX, -- 611
							y = actionsY, -- 611
							width = infoWidth, -- 611
							height = 48, -- 611
							anchorX = 0, -- 611
							anchorY = 0 -- 611
						}, -- 611
						React.createElement("label", { -- 611
							x = 0, -- 611
							y = 38, -- 611
							anchorX = 0, -- 611
							fontName = fontName, -- 611
							fontSize = 14, -- 611
							text = synchronizing and (zh and "正在同步" or "Synchronizing") or (zh and "正在下载" or "Downloading"), -- 611
							color3 = 16763955 -- 611
						}), -- 611
						React.createElement( -- 611
							"label", -- 611
							{ -- 611
								tag = "mobile-feed-download-percent", -- 611
								x = infoWidth - 92, -- 611
								y = 38, -- 611
								anchorX = 1, -- 611
								fontName = fontName, -- 611
								fontSize = 14, -- 611
								text = (tostring(math.floor(prepareProgress * 100)) .. "%") .. (prepareTransferredBytes > 0 and " · " .. formatTransferBytes(prepareTransferredBytes) or ""), -- 611
								color3 = 16763955 -- 611
							} -- 611
						) -- 611
					) -- 611
					local ____React_createElement_39 = React.createElement -- 611
					local ____temp_37 = { -- 611
						tag = "mobile-feed-download-track", -- 611
						width = infoWidth - 92, -- 611
						height = 8, -- 611
						y = 8, -- 611
						anchorX = 0, -- 611
						anchorY = 0 -- 611
					} -- 611
					local ____React_createElement_result_38 = React.createElement(RoundedSurface, {width = infoWidth - 92, height = 8, radius = 4, fillColor = 4280889664}) -- 611
					local ____React_createElement_36 = React.createElement -- 611
					local ____temp_35 = { -- 611
						tag = "mobile-feed-download-fill", -- 611
						width = (infoWidth - 92) * prepareProgress, -- 611
						height = 8, -- 611
						anchorX = 0, -- 611
						anchorY = 0 -- 611
					} -- 611
					local ____temp_34 -- 618
					if prepareProgress > 0 then -- 618
						____temp_34 = React.createElement(RoundedSurface, { -- 618
							width = (infoWidth - 92) * prepareProgress, -- 618
							height = 8, -- 618
							radius = 4, -- 618
							topColor = 4294958955, -- 618
							bottomColor = 4294950190 -- 618
						}) -- 618
					else -- 618
						____temp_34 = nil -- 618
					end -- 618
					__TS__SparseArrayPush( -- 618
						____array_40, -- 618
						____React_createElement_39( -- 618
							"node", -- 618
							____temp_37, -- 618
							____React_createElement_result_38, -- 618
							____React_createElement_36("node", ____temp_35, ____temp_34) -- 618
						), -- 618
						React.createElement(MobileButton, { -- 618
							tag = "mobile-feed-download-cancel", -- 618
							x = infoWidth - 80, -- 618
							y = 0, -- 618
							width = 80, -- 618
							height = 48, -- 618
							text = prepareCanceled and (zh and "中断中…" or "Canceling…") or (zh and "中断" or "Cancel"), -- 618
							fontSize = 13, -- 618
							danger = true, -- 618
							onTapped = cancelPrepare -- 618
						}) -- 618
					) -- 618
					____preparing_42 = ____React_createElement_41(__TS__SparseArraySpread(____array_40)) -- 618
				else -- 618
					____preparing_42 = React.createElement( -- 618
						"node", -- 618
						nil, -- 618
						React.createElement( -- 618
							MobileButton, -- 624
							{ -- 624
								tag = "mobile-feed-remix", -- 624
								x = infoX, -- 624
								y = actionsY, -- 624
								width = buttonWidth, -- 624
								text = item.webPlayUrl and (zh and "查看源码" or "View source") or (zh and "Remix 作品" or "Remix game"), -- 624
								fontSize = math.floor(16 * fontScale), -- 624
								primary = true, -- 624
								onTapped = function() return activate("remix") end -- 624
							} -- 624
						), -- 624
						React.createElement( -- 624
							MobileButton, -- 626
							{ -- 626
								tag = "mobile-feed-play", -- 626
								x = infoX + buttonWidth + 12, -- 626
								y = actionsY, -- 626
								width = buttonWidth, -- 626
								text = item.webPlayUrl and (zh and "在线试玩" or "Play online") or (zh and "试玩" or "Play"), -- 626
								fontSize = math.floor(17 * fontScale), -- 626
								onTapped = function() return activate("play") end -- 626
							} -- 626
						) -- 626
					) -- 626
				end -- 626
				__TS__SparseArrayPush(____array_44, ____preparing_42) -- 626
				local ____preparing_43 -- 629
				if preparing then -- 629
					____preparing_43 = React.createElement( -- 629
						"clip-node", -- 629
						{ -- 629
							tag = "mobile-feed-download-message-clip", -- 629
							x = infoX, -- 629
							y = gestureHintY - 10, -- 629
							width = infoWidth, -- 629
							height = 20, -- 629
							anchorX = 0, -- 629
							anchorY = 0, -- 629
							stencil = React.createElement(RoundedStencil, {width = infoWidth, height = 20, radius = 0}) -- 629
						}, -- 629
						React.createElement("label", { -- 629
							tag = "mobile-feed-download-message", -- 629
							x = 0, -- 629
							y = 10, -- 629
							anchorX = 0, -- 629
							fontName = fontName, -- 629
							fontSize = 12, -- 629
							text = (string.gsub(prepareStatus, "[\r\n]+", " ")), -- 629
							textWidth = -1, -- 629
							color3 = 11055037 -- 629
						}) -- 629
					) -- 629
				else -- 629
					____preparing_43 = React.createElement("label", { -- 629
						tag = "mobile-feed-gesture-hint", -- 629
						x = infoX, -- 629
						y = gestureHintY, -- 629
						anchorX = 0, -- 629
						anchorY = 0.5, -- 629
						fontName = fontName, -- 629
						fontSize = gamepadUsed and 11 or 14, -- 629
						text = prepareStatus ~= "" and prepareStatus or (item.launchError ~= nil and item.launchError or (item.webPlayUrl and (gamepadUsed and (zh and "↑↓ 浏览 · A 在线试玩 · X 查看源码 · Start 列表" or "↑↓ Browse · A Play online · X Source · Start List") or (zh and "上滑浏览  ·  右滑源码  ·  左滑在线试玩" or "Swipe up  ·  right Source  ·  left Web play")) or (gamepadUsed and (zh and "↑↓ 浏览 · A 确认 · X Remix · Start 列表 · Y 新建" or "↑↓ Browse · A Select · X Remix · Start List · Y New") or (zh and "上滑浏览  ·  右滑 Remix  ·  左滑试玩" or "Swipe up  ·  right Remix  ·  left Play")))), -- 629
						textWidth = infoWidth, -- 629
						alignment = "Left", -- 629
						color3 = item.launchError ~= nil and 16739179 or 11055037 -- 629
					}) -- 629
				end -- 629
				__TS__SparseArrayPush(____array_44, ____preparing_43) -- 629
				____temp_46 = ____React_createElement_45(__TS__SparseArraySpread(____array_44)) -- 629
			else -- 629
				____temp_46 = React.createElement( -- 629
					"node", -- 629
					nil, -- 629
					React.createElement("label", { -- 629
						x = left + usableWidth / 2, -- 629
						y = bottom + usableHeight / 2 + 20, -- 629
						fontName = fontName, -- 629
						fontSize = 22, -- 629
						text = tab == "discover" and (zh and "暂无移动作品" or "No mobile games yet") or (zh and "没有可运行的本地作品" or "No runnable local games"), -- 629
						color3 = 16052712 -- 629
					}), -- 629
					React.createElement("label", { -- 629
						x = left + usableWidth / 2, -- 629
						y = bottom + usableHeight / 2 - 28, -- 629
						fontName = fontName, -- 629
						fontSize = 14, -- 629
						text = tab == "discover" and discoverError ~= "" and discoverError or (zh and "切换标签或稍后重试" or "Switch tabs or retry later"), -- 629
						textWidth = usableWidth - 48, -- 629
						color3 = tab == "discover" and discoverError ~= "" and 16739179 or 11055037 -- 629
					}) -- 629
				) -- 629
			end -- 629
			____createOpen_47 = ____temp_46 -- 578
		end -- 578
		local ____temp_48 -- 645
		if not createOpen and not item and tab == "local" then -- 645
			____temp_48 = React.createElement( -- 645
				"node", -- 645
				nil, -- 645
				React.createElement(MobileButton, { -- 645
					tag = "mobile-empty-new", -- 645
					x = left + 20, -- 645
					y = bottom + 24, -- 645
					width = (usableWidth - 52) / 2, -- 645
					text = zh and "新建作品" or "New game", -- 645
					onTapped = openCreate -- 645
				}), -- 645
				React.createElement( -- 645
					MobileButton, -- 647
					{ -- 647
						tag = "mobile-empty-import", -- 647
						x = left + 32 + (usableWidth - 52) / 2, -- 647
						y = bottom + 24, -- 647
						width = (usableWidth - 52) / 2, -- 647
						text = zh and "导入作品包" or "Import package", -- 647
						fontSize = 15, -- 647
						primary = true, -- 647
						onTapped = function() return openPackage("add", nil, true) end -- 647
					} -- 647
				) -- 647
			) -- 647
		else -- 647
			____temp_48 = nil -- 648
		end -- 648
		local ____temp_49 -- 649
		if not item and tab == "discover" and syncDiscover then -- 649
			____temp_49 = React.createElement(MobileButton, { -- 649
				tag = "mobile-feed-empty-index", -- 649
				x = left + (usableWidth - 160) / 2, -- 649
				y = bottom + 24, -- 649
				width = 160, -- 649
				text = zh and "作品目录" or "Game index", -- 649
				onTapped = openProjectIndex -- 649
			}) -- 649
		else -- 649
			____temp_49 = nil -- 650
		end -- 650
		local ____React_createElement_54 = React.createElement -- 650
		local ____array_53 = __TS__SparseArrayNew("node", {tag = "mobile-feed-header", order = headerRenderOrder, visible = not syncConfirmation}) -- 650
		local ____Updater_getState_result_available_50 -- 652
		if Updater.getState().available then -- 652
			____Updater_getState_result_available_50 = React.createElement(MobileButton, { -- 652
				tag = "mobile-engine-update", -- 652
				x = left + usableWidth - (updateHeaderExtra > 0 and 56 or 136), -- 652
				y = bottom + usableHeight - 56 + landscapeTopLift, -- 652
				width = 44, -- 652
				height = 44, -- 652
				text = "↑", -- 652
				fontSize = 23, -- 652
				onTapped = openUpdate -- 652
			}) -- 652
		else -- 652
			____Updater_getState_result_available_50 = nil -- 652
		end -- 652
		__TS__SparseArrayPush(____array_53, ____Updater_getState_result_available_50) -- 652
		local ____options_onSwitchMode_51 -- 653
		if options.onSwitchMode then -- 653
			____options_onSwitchMode_51 = React.createElement( -- 653
				"node", -- 653
				{ -- 653
					tag = "mobile-ui-mode-switch", -- 653
					x = left + 12, -- 653
					y = bottom + usableHeight - 58 + landscapeTopLift, -- 653
					width = 72, -- 653
					height = 48, -- 653
					anchorX = 0, -- 653
					anchorY = 0, -- 653
					touchEnabled = true, -- 653
					swallowTouches = true, -- 653
					onTapped = switchMode -- 653
				}, -- 653
				React.createElement("label", { -- 653
					x = 0, -- 653
					y = 30, -- 653
					anchorX = 0, -- 653
					fontName = fontName, -- 653
					fontSize = 16, -- 653
					text = "DORA", -- 653
					color3 = preparing and 7831180 or 16763955 -- 653
				}), -- 653
				React.createElement("label", { -- 653
					x = 0, -- 653
					y = 10, -- 653
					anchorX = 0, -- 653
					fontName = fontName, -- 653
					fontSize = 10, -- 653
					text = zh and "切换传统界面" or "Classic UI", -- 653
					color3 = 7831180 -- 653
				}) -- 653
			) -- 653
		else -- 653
			____options_onSwitchMode_51 = nil -- 657
		end -- 657
		__TS__SparseArrayPush( -- 657
			____array_53, -- 657
			____options_onSwitchMode_51, -- 657
			React.createElement( -- 657
				"label", -- 657
				{ -- 657
					tag = "mobile-feed-discover-tab", -- 657
					x = left + usableWidth / 2 - 44, -- 657
					y = bottom + usableHeight - 34 + landscapeTopLift - updateHeaderExtra, -- 657
					fontName = fontName, -- 657
					fontSize = math.floor(17 * fontScale), -- 657
					text = zh and "发现" or "Discover", -- 657
					color3 = tab == "discover" and 16763955 or 11055037, -- 657
					touchEnabled = true, -- 657
					swallowTouches = true, -- 657
					onTapped = function() return setTab("discover") end -- 657
				} -- 657
			), -- 657
			React.createElement( -- 657
				"label", -- 657
				{ -- 657
					tag = "mobile-feed-local-tab", -- 657
					x = left + usableWidth / 2 + 44, -- 657
					y = bottom + usableHeight - 34 + landscapeTopLift - updateHeaderExtra, -- 657
					fontName = fontName, -- 657
					fontSize = math.floor(17 * fontScale), -- 657
					text = zh and "本地" or "Local", -- 657
					color3 = tab == "local" and 16763955 or 11055037, -- 657
					touchEnabled = true, -- 657
					swallowTouches = true, -- 657
					onTapped = function() -- 657
						____local = getLocalEntries() -- 663
						setTab("local") -- 663
					end -- 663
				} -- 663
			), -- 663
			React.createElement(RoundedSurface, { -- 663
				x = left + usableWidth / 2 + (tab == "discover" and -58 or 30), -- 663
				y = bottom + usableHeight - 56 + landscapeTopLift - updateHeaderExtra, -- 663
				width = 28, -- 663
				height = 3, -- 663
				radius = 1.5, -- 663
				fillColor = colors.brand, -- 663
				renderOrder = headerRenderOrder + 1 -- 663
			}) -- 663
		) -- 663
		local ____temp_52 -- 665
		if tab == "local" and options.createProject then -- 665
			____temp_52 = React.createElement( -- 665
				MobileNewButton, -- 665
				{ -- 665
					tag = "mobile-feed-create", -- 665
					x = left + usableWidth - (updateHeaderExtra > 0 and 138 or 82), -- 665
					y = bottom + usableHeight - 56 + landscapeTopLift, -- 665
					text = zh and "+ 新建" or "+ New", -- 665
					renderOrder = headerRenderOrder + 1, -- 665
					onTapped = function() return openPackage("add") end -- 665
				} -- 665
			) -- 665
		else -- 665
			____temp_52 = nil -- 667
		end -- 667
		__TS__SparseArrayPush(____array_53, ____temp_52) -- 667
		local ____React_createElement_54_result_67 = ____React_createElement_54(__TS__SparseArraySpread(____array_53)) -- 667
		local ____temp_56 -- 669
		if managementOpen and canManage and item then -- 669
			____temp_56 = (function() -- 669
				local menuWidth = math.min(208, infoWidth) -- 670
				local ____array_55 = __TS__SparseArrayNew(table.unpack(canShare and ({{ -- 670
					tag = "mobile-feed-share", -- 672
					text = zh and "分享作品" or "Share game", -- 672
					action = function() -- 672
						closeManagement() -- 672
						openPackage("share") -- 672
					end -- 672
				}}) or ({}))) -- 672
				__TS__SparseArrayPush( -- 672
					____array_55, -- 672
					table.unpack(canSync and ({{ -- 673
						tag = "mobile-feed-sync", -- 673
						text = zh and "同步上游" or "Sync upstream", -- 673
						action = function() -- 673
							managementOpen = false -- 673
							synchronize(item, false) -- 673
						end -- 673
					}}) or ({})) -- 673
				) -- 673
				local actions = {__TS__SparseArraySpread(____array_55)} -- 671
				local menuPadding = 12 -- 675
				local actionGap = 8 -- 676
				local menuHeight = menuPadding * 2 + #actions * 48 + (#actions - 1) * actionGap -- 677
				return React.createElement( -- 678
					"node", -- 678
					{ -- 678
						tag = "mobile-feed-management-menu", -- 678
						order = 1500, -- 678
						renderOrder = 1500, -- 678
						renderGroup = true, -- 678
						width = width, -- 678
						height = height, -- 678
						anchorX = 0, -- 678
						anchorY = 0, -- 678
						touchEnabled = true, -- 678
						swallowTouches = true, -- 678
						onTapped = closeManagement -- 678
					}, -- 678
					React.createElement( -- 678
						"draw-node", -- 678
						{x = width / 2, y = height / 2}, -- 678
						React.createElement("rect-shape", {width = width, height = height, fillColor = 855638016}) -- 678
					), -- 678
					React.createElement( -- 678
						"node", -- 678
						{ -- 678
							x = infoX + infoWidth - menuWidth, -- 678
							y = math.max(bottom + 16, infoTop - 26 - menuHeight), -- 678
							width = menuWidth, -- 678
							height = menuHeight, -- 678
							anchorX = 0, -- 678
							anchorY = 0, -- 678
							touchEnabled = true, -- 678
							swallowTouches = true -- 678
						}, -- 678
						React.createElement( -- 678
							"draw-node", -- 678
							{renderOrder = 1}, -- 678
							React.createElement( -- 678
								"polygon-shape", -- 678
								{ -- 678
									verts = roundedRectVerts(menuWidth, menuHeight, 16), -- 678
									fillColor = colors.panelRaised, -- 678
									borderWidth = 1, -- 678
									borderColor = colors.border -- 678
								} -- 678
							) -- 678
						), -- 678
						__TS__ArrayMap( -- 684
							actions, -- 684
							function(____, action, i) return React.createElement(OverlayActionButton, { -- 684
								key = action.tag, -- 684
								tag = action.tag, -- 684
								x = menuPadding, -- 684
								y = menuHeight - menuPadding - 48 - i * (48 + actionGap), -- 684
								width = menuWidth - menuPadding * 2, -- 684
								text = action.text, -- 684
								fontSize = 15, -- 684
								onTapped = action.action -- 684
							}) end -- 684
						) -- 684
					) -- 684
				) -- 684
			end)() -- 669
		else -- 669
			____temp_56 = nil -- 689
		end -- 689
		local ____syncConfirmation_57 -- 690
		if syncConfirmation then -- 690
			____syncConfirmation_57 = React.createElement( -- 690
				"node", -- 690
				{ -- 690
					tag = "mobile-feed-sync-confirmation", -- 690
					order = 2000, -- 690
					renderOrder = 2000, -- 690
					renderGroup = true, -- 690
					width = width, -- 690
					height = height, -- 690
					anchorX = 0, -- 690
					anchorY = 0, -- 690
					touchEnabled = true, -- 690
					swallowTouches = true, -- 690
					onTapped = function() -- 690
					end -- 691
				}, -- 691
				React.createElement( -- 691
					"draw-node", -- 691
					nil, -- 691
					React.createElement("rect-shape", { -- 691
						centerX = width / 2, -- 691
						centerY = height / 2, -- 691
						width = width, -- 691
						height = height, -- 691
						fillColor = 3490187791 -- 691
					}) -- 691
				), -- 691
				React.createElement( -- 691
					"node", -- 691
					{ -- 691
						x = left + (usableWidth - math.min(440, usableWidth - 24)) / 2, -- 691
						y = bottom + (usableHeight - math.min(310, usableHeight - 24)) / 2, -- 691
						width = math.min(440, usableWidth - 24), -- 691
						height = math.min(310, usableHeight - 24), -- 691
						anchorX = 0, -- 691
						anchorY = 0 -- 691
					}, -- 691
					React.createElement( -- 691
						"draw-node", -- 691
						{renderOrder = 1}, -- 691
						React.createElement( -- 691
							"polygon-shape", -- 691
							{ -- 691
								verts = roundedRectVerts( -- 691
									math.min(440, usableWidth - 24), -- 695
									math.min(310, usableHeight - 24), -- 695
									24 -- 695
								), -- 695
								fillColor = 4279572770, -- 695
								borderWidth = 1, -- 695
								borderColor = 4283061608 -- 695
							} -- 695
						) -- 695
					), -- 695
					React.createElement( -- 695
						"label", -- 695
						{ -- 695
							x = 20, -- 695
							y = math.min(310, usableHeight - 24) - 32, -- 695
							anchorX = 0, -- 695
							fontName = fontName, -- 695
							fontSize = 20, -- 695
							text = zh and "同步失败，是否强制同步？" or "Sync failed. Force sync?", -- 695
							textWidth = math.min(440, usableWidth - 24) - 40, -- 695
							alignment = "Left", -- 695
							renderOrder = 2 -- 695
						} -- 695
					), -- 695
					React.createElement( -- 695
						"label", -- 695
						{ -- 695
							x = 20, -- 695
							y = math.min(310, usableHeight - 24) - 82, -- 695
							anchorX = 0, -- 695
							fontName = fontName, -- 695
							fontSize = 13, -- 695
							color3 = 11055037, -- 695
							text = conciseDescription(syncFailure, 90), -- 695
							textWidth = math.min(440, usableWidth - 24) - 40, -- 695
							alignment = "Left", -- 695
							renderOrder = 2 -- 695
						} -- 695
					), -- 695
					React.createElement( -- 695
						"label", -- 695
						{ -- 695
							x = 20, -- 695
							y = math.min(310, usableHeight - 24) - 158, -- 695
							anchorX = 0, -- 695
							fontName = fontName, -- 695
							fontSize = 14, -- 695
							color3 = 16757683, -- 695
							text = zh and "将放弃本地所有修改、提交和新增文件，用当前 Catalog 的工程替换。此操作无法撤销。" or "Discard all local edits, commits and added files, replacing this project from the current Catalog. This cannot be undone.", -- 695
							textWidth = math.min(440, usableWidth - 24) - 40, -- 695
							alignment = "Left", -- 695
							renderOrder = 2 -- 695
						} -- 695
					), -- 695
					React.createElement( -- 695
						OverlayActionButton, -- 704
						{ -- 704
							tag = "mobile-feed-sync-cancel", -- 704
							x = 20, -- 704
							width = (math.min(440, usableWidth - 24) - 52) / 2, -- 704
							text = zh and "保留本地" or "Keep local", -- 704
							onTapped = dismissSyncConfirmation -- 704
						} -- 704
					), -- 704
					React.createElement( -- 704
						OverlayActionButton, -- 706
						{ -- 706
							tag = "mobile-feed-sync-force", -- 706
							x = 32 + (math.min(440, usableWidth - 24) - 52) / 2, -- 706
							width = (math.min(440, usableWidth - 24) - 52) / 2, -- 706
							text = zh and "强制同步" or "Force sync", -- 706
							danger = true, -- 706
							onTapped = function() -- 706
								if syncConfirmation then -- 706
									synchronize(syncConfirmation, true) -- 707
								end -- 707
							end -- 707
						} -- 707
					) -- 707
				) -- 707
			) -- 707
		else -- 707
			____syncConfirmation_57 = nil -- 709
		end -- 709
		local ____createOpen_65 -- 710
		if createOpen then -- 710
			____createOpen_65 = (function() -- 710
				local sheetHeight = math.min(createSheetHeight, usableHeight - 64) -- 711
				local sheetWidth = usableWidth -- 712
				local contentWidth = sheetWidth - 40 -- 713
				local actionGap = 12 -- 714
				local actionsWidth = shortLandscape and math.min( -- 715
					300, -- 715
					math.floor(contentWidth * 0.42) -- 715
				) or contentWidth -- 715
				local inputWidth = shortLandscape and contentWidth - actionGap - actionsWidth or contentWidth -- 716
				local actionX = shortLandscape and 20 + inputWidth + actionGap or 20 -- 717
				local actionY = shortLandscape and sheetHeight - createInputTop - createInputHeight or 20 -- 718
				local cancelWidth = math.floor((actionsWidth - actionGap) * (shortLandscape and 0.34 or 0.38)) -- 719
				local ____React_createElement_64 = React.createElement -- 719
				local ____array_63 = __TS__SparseArrayNew( -- 719
					"node", -- 719
					{ -- 719
						tag = "mobile-project-create-sheet", -- 719
						order = 10000, -- 719
						width = width, -- 719
						height = height, -- 719
						anchorX = 0, -- 719
						anchorY = 0, -- 719
						touchEnabled = true, -- 719
						swallowTouches = true -- 719
					}, -- 719
					React.createElement( -- 719
						"node", -- 719
						{ -- 719
							tag = "mobile-project-create-focus-observer", -- 719
							order = 1000, -- 719
							width = width, -- 719
							height = height, -- 719
							anchorX = 0, -- 719
							anchorY = 0, -- 719
							touchEnabled = true, -- 719
							swallowTouches = false, -- 719
							swallowMouseWheel = false, -- 719
							onTapFilter = function(touch) -- 719
								touch.enabled = false -- 723
								if not canEditCreate() then -- 723
									return -- 724
								end -- 724
								local input = createInputRef.current -- 725
								local point = input and input:convertToNodeSpace(touch.worldLocation) -- 726
								local inside = input and point and point.x >= 0 and point.y >= 0 and point.x <= input.width and point.y <= input.height -- 727
								dismissedCreateComposition = not inside and createInput.isComposing() -- 728
								if not inside then -- 728
									blurCreateInput() -- 729
								end -- 729
							end -- 722
						} -- 722
					), -- 722
					React.createElement( -- 722
						"draw-node", -- 722
						{ -- 722
							tag = "mobile-project-create-backdrop", -- 722
							order = 0, -- 722
							renderOrder = 0, -- 722
							x = width / 2, -- 722
							y = bottom + sheetHeight + (height - bottom - sheetHeight) / 2 -- 722
						}, -- 722
						React.createElement("rect-shape", {width = width, height = height - bottom - sheetHeight, fillColor = 2348810240}) -- 722
					) -- 722
				) -- 722
				local ____React_createElement_62 = React.createElement -- 722
				local ____array_61 = __TS__SparseArrayNew( -- 722
					"node", -- 722
					{ -- 722
						ref = createPanelRef, -- 722
						order = 10, -- 722
						renderOrder = 10, -- 722
						x = left, -- 722
						y = bottom, -- 722
						width = sheetWidth, -- 722
						height = sheetHeight, -- 722
						anchorX = 0, -- 722
						anchorY = 0, -- 722
						touchEnabled = true, -- 722
						swallowTouches = true -- 722
					}, -- 722
					React.createElement(MobilePanelSurface, {width = sheetWidth, height = sheetHeight, renderOrder = 10}), -- 722
					React.createElement("label", { -- 722
						x = 20, -- 722
						y = sheetHeight - 24, -- 722
						anchorX = 0, -- 722
						anchorY = 1, -- 722
						fontName = fontName, -- 722
						fontSize = 22, -- 722
						text = zh and "新建项目" or "New project", -- 722
						color3 = 16052712 -- 722
					}), -- 722
					__TS__ArrayMap( -- 737
						{"typescript", "lua"}, -- 737
						function(____, language, i) return React.createElement( -- 737
							MobileChoiceButton, -- 737
							{ -- 737
								tag = "mobile-project-create-language-" .. language, -- 737
								x = 20 + i * 144, -- 737
								y = sheetHeight - 98, -- 737
								width = language == "lua" and 84 or 132, -- 737
								text = language == "lua" and "Lua" or "TypeScript", -- 737
								selected = createLanguage == language, -- 737
								renderOrder = 10, -- 737
								onTapped = function() -- 737
									if not canEditCreate() then -- 737
										return -- 741
									end -- 741
									blurCreateInput() -- 742
									createLanguage = language -- 742
									render() -- 742
								end -- 740
							} -- 740
						) end -- 740
					), -- 740
					React.createElement("label", { -- 740
						x = 20, -- 740
						y = sheetHeight - 110, -- 740
						anchorX = 0, -- 740
						anchorY = 1, -- 740
						fontName = fontName, -- 740
						fontSize = 14, -- 740
						text = zh and "项目名称" or "Project name", -- 740
						color3 = 11055037 -- 740
					}) -- 740
				) -- 740
				local ____keptInput_60 -- 745
				if keptInput then -- 745
					____keptInput_60 = nil -- 745
				else -- 745
					____keptInput_60 = React.createElement("node", { -- 745
						tag = "mobile-project-create-input", -- 745
						ref = createInputRef, -- 745
						renderOrder = 10, -- 745
						x = 20, -- 745
						y = sheetHeight - createInputTop - createInputHeight, -- 745
						width = inputWidth, -- 745
						height = createInputHeight, -- 745
						anchorX = 0, -- 745
						anchorY = 0, -- 745
						onMount = createInput.mount -- 745
					}) -- 745
				end -- 745
				__TS__SparseArrayPush( -- 745
					____array_61, -- 745
					____keptInput_60, -- 745
					React.createElement("label", { -- 745
						tag = "mobile-project-create-error", -- 745
						x = 20, -- 745
						y = shortLandscape and sheetHeight - createInputTop + 12 or sheetHeight - createInputTop - createInputHeight - 12, -- 745
						anchorX = 0, -- 745
						anchorY = 1, -- 745
						fontName = fontName, -- 745
						fontSize = 12, -- 745
						text = createError ~= "" and createError or (zh and ("将创建可运行的 " .. (createLanguage == "lua" and "Lua" or "TypeScript")) .. " 起始项目" or ("Creates a runnable " .. (createLanguage == "lua" and "Lua" or "TypeScript")) .. " starter project"), -- 745
						textWidth = inputWidth, -- 745
						alignment = "Left", -- 745
						color3 = createError ~= "" and 16739179 or 11055037 -- 745
					}), -- 745
					React.createElement(MobileButton, { -- 745
						tag = "mobile-project-create-cancel", -- 745
						x = actionX, -- 745
						y = actionY, -- 745
						width = cancelWidth, -- 745
						text = zh and "取消" or "Cancel", -- 745
						renderOrder = 10, -- 745
						onTapped = closeCreate -- 745
					}), -- 745
					React.createElement( -- 745
						MobileButton, -- 751
						{ -- 751
							tag = "mobile-project-create-submit", -- 751
							x = actionX + cancelWidth + actionGap, -- 751
							y = actionY, -- 751
							width = actionsWidth - cancelWidth - actionGap, -- 751
							text = creating and (zh and "创建中…" or "Creating…") or (zh and "创建并进入 Remix" or "Create and Remix"), -- 751
							primary = true, -- 751
							renderOrder = 10, -- 751
							onTapped = function() -- 751
								if not dismissedCreateComposition then -- 751
									submitCreate() -- 752
								end -- 752
								dismissedCreateComposition = false -- 752
							end -- 752
						} -- 752
					) -- 752
				) -- 752
				__TS__SparseArrayPush( -- 752
					____array_63, -- 752
					____React_createElement_62(__TS__SparseArraySpread(____array_61)) -- 752
				) -- 752
				return ____React_createElement_64(__TS__SparseArraySpread(____array_63)) -- 720
			end)() -- 710
		else -- 710
			____createOpen_65 = nil -- 755
		end -- 755
		__TS__SparseArrayPush( -- 755
			____array_70, -- 755
			____React_createElement_68( -- 755
				"node", -- 755
				____temp_66, -- 755
				____createOpen_47, -- 755
				____temp_48, -- 755
				____temp_49, -- 755
				____React_createElement_54_result_67, -- 755
				____temp_56, -- 755
				____syncConfirmation_57, -- 755
				____createOpen_65 -- 755
			) -- 755
		) -- 755
		local ____projectIndexOpen_69 -- 757
		if projectIndexOpen then -- 757
			____projectIndexOpen_69 = React.createElement( -- 757
				ProjectIndex, -- 757
				{ -- 757
					entries = entries(), -- 757
					kind = tab, -- 757
					current = current(), -- 757
					x = left, -- 757
					y = bottom, -- 757
					width = usableWidth, -- 757
					height = usableHeight, -- 757
					zh = zh, -- 757
					refreshing = catalogSyncing, -- 757
					refreshStatus = catalogStatus, -- 757
					onRefresh = syncDiscover and (function() return refreshDiscover(true) end) or nil, -- 757
					onStatusReady = function(____, update) -- 757
						catalogStatusView = update -- 760
					end, -- 760
					onClose = function() -- 760
						projectIndexOpen = false -- 761
						render() -- 761
					end, -- 761
					onSelect = function(____, entry) -- 761
						projectIndexOpen = false -- 763
						local location = resolveFeedLocation(____local, discover, entry) -- 764
						tab = location.tab -- 765
						index = location.index -- 765
						render() -- 766
					end -- 762
				} -- 762
			) -- 762
		else -- 762
			____projectIndexOpen_69 = nil -- 767
		end -- 767
		__TS__SparseArrayPush(____array_70, ____projectIndexOpen_69) -- 767
		local scene = ____toNode_72(____React_createElement_71(__TS__SparseArraySpread(____array_70))) -- 531
		if scene ~= nil then -- 531
			host:addChild(scene) -- 769
		end -- 769
		if keptInput and createPanelRef.current then -- 769
			keptInput.position = Vec2( -- 771
				20, -- 771
				math.min(createSheetHeight, usableHeight - 64) - createInputTop - createInputHeight -- 771
			) -- 771
			createPanelRef.current:addChild(keptInput) -- 772
		end -- 772
		createInput.refresh() -- 774
		if restoreFocus and not keptInput and createOpen then -- 774
			createInput.focus(false) -- 775
		end -- 775
	end -- 474
	attachGamepad( -- 778
		host, -- 778
		{ -- 778
			initialTag = "mobile-feed-play", -- 779
			isEnabled = function() return isActive() and not updatePanel and not packagePanel and not preparing and not transitioning and not creating end, -- 780
			onActive = function() -- 781
				gamepadUsed = true -- 781
				render() -- 781
			end, -- 781
			onBack = function() -- 782
				if managementOpen then -- 782
					closeManagement() -- 782
				elseif syncConfirmation then -- 782
					dismissSyncConfirmation() -- 782
				elseif createInput.isFocused() then -- 782
					blurCreateInput() -- 782
				elseif createOpen then -- 782
					closeCreate() -- 782
				else -- 782
					switchMode() -- 782
				end -- 782
			end, -- 782
			onActivate = function(target) -- 783
				if target.tag == "mobile-project-create-input" then -- 783
					target:emit("GamepadActivate") -- 784
				else -- 784
					if createInput.isComposing() then -- 784
						blurCreateInput() -- 786
						return -- 786
					end -- 786
					blurCreateInput() -- 787
					dismissedCreateComposition = false -- 788
					target:emit("Tapped") -- 789
				end -- 789
			end, -- 783
			onButton = function(button) -- 792
				if createOpen or syncConfirmation or managementOpen then -- 792
					return false -- 793
				end -- 793
				repeat -- 793
					local ____switch168 = button -- 793
					local ____cond168 = ____switch168 == "dpup" -- 793
					if ____cond168 then -- 793
						commit("previous") -- 795
						return true -- 795
					end -- 795
					____cond168 = ____cond168 or ____switch168 == "dpdown" -- 795
					if ____cond168 then -- 795
						commit("next") -- 796
						return true -- 796
					end -- 796
					____cond168 = ____cond168 or ____switch168 == "leftshoulder" -- 796
					if ____cond168 then -- 796
						setTab("discover") -- 797
						return true -- 797
					end -- 797
					____cond168 = ____cond168 or ____switch168 == "rightshoulder" -- 797
					if ____cond168 then -- 797
						setTab("local") -- 798
						return true -- 798
					end -- 798
					____cond168 = ____cond168 or ____switch168 == "x" -- 798
					if ____cond168 then -- 798
						commit("remix") -- 799
						return true -- 799
					end -- 799
					____cond168 = ____cond168 or ____switch168 == "y" -- 799
					if ____cond168 then -- 799
						local ____opt_73 = findGamepadNode(host, "mobile-feed-create") -- 799
						if ____opt_73 ~= nil then -- 799
							____opt_73:emit("Tapped") -- 800
						end -- 800
						return true -- 800
					end -- 800
					____cond168 = ____cond168 or ____switch168 == "start" -- 800
					if ____cond168 then -- 800
						openProjectIndex() -- 801
						return true -- 801
					end -- 801
					do -- 801
						return false -- 802
					end -- 802
				until true -- 802
			end -- 792
		} -- 792
	) -- 792
	host:onAppChange(function(setting) -- 806
		if setting == "Locale" then -- 806
			local activeEntry = current() -- 808
			managementOpen = false -- 809
			zh = (string.match(App.locale, "^zh")) ~= nil -- 810
			____local = getLocalEntries() -- 811
			discover = getDiscoverEntries() -- 812
			local location = resolveFeedLocation(____local, discover, activeEntry) -- 813
			tab = location.tab -- 814
			index = location.index -- 815
			render() -- 816
		elseif setting == "Size" then -- 816
			render() -- 817
		end -- 817
	end) -- 806
	host:onAppEvent(function(event) -- 819
		if event == "BackButton" then -- 819
			if managementOpen then -- 819
				closeManagement() -- 821
			elseif syncConfirmation then -- 821
				dismissSyncConfirmation() -- 822
			elseif projectIndexOpen then -- 822
				projectIndexOpen = false -- 823
				render() -- 823
			elseif createOpen and not creating then -- 823
				closeCreate() -- 824
			end -- 824
		elseif event == "WillEnterBackground" or event == "DidEnterBackground" then -- 824
			blurCreateInput() -- 825
		end -- 825
	end) -- 819
	host:onCleanup(function() -- 827
		if updatePanel ~= nil then -- 827
			updatePanel:removeFromParent(true) -- 827
		end -- 827
		blurCreateInput() -- 827
		active = false -- 827
		if packagePanel ~= nil then -- 827
			packagePanel:removeFromParent(true) -- 827
		end -- 827
		packagePanel = nil -- 827
	end) -- 827
	host:slot( -- 828
		"RestoreFeedEntry", -- 828
		function(entry) -- 828
			if not isActive() or HttpServer.wsConnectionCount > 0 then -- 828
				return -- 829
			end -- 829
			managementOpen = false -- 830
			returnEntry = entry -- 831
			____local = getLocalEntries() -- 832
			discover = getDiscoverEntries() -- 833
			local location = resolveFeedLocation(____local, discover, entry) -- 834
			tab = location.tab -- 835
			index = location.index -- 836
			render() -- 837
		end -- 828
	) -- 828
	host:slot("SuspendLocalUI", blurCreateInput) -- 839
	host:slot( -- 840
		"ResumeLocalUI", -- 840
		function() -- 840
			leaving = false -- 840
			render() -- 840
		end -- 840
	) -- 840
	refreshDiscover = function(force) -- 841
		if not syncDiscover or catalogSyncing or not isActive() then -- 841
			return -- 842
		end -- 842
		catalogSyncing = true -- 843
		catalogStatus = zh and "正在同步资源目录…" or "Syncing Catalog…" -- 844
		if #discover == 0 then -- 844
			discoverError = catalogStatus -- 846
		end -- 846
		render() -- 848
		syncDiscover( -- 849
			function(message) -- 849
				if not isActive() then -- 849
					return -- 850
				end -- 850
				catalogStatus = message -- 851
				if catalogStatusView ~= nil then -- 851
					catalogStatusView(message) -- 852
				end -- 852
				if projectIndexOpen or #discover > 0 then -- 852
					return -- 853
				end -- 853
				discoverError = message -- 854
				render() -- 855
			end, -- 849
			function(success, message) -- 856
				if not isActive() then -- 856
					return -- 857
				end -- 857
				catalogSyncing = false -- 858
				catalogStatus = success and (zh and "目录已更新" or "Catalog updated") or (zh and "刷新失败：" or "Refresh failed: ") .. (message or (zh and "请重试" or "Try again")) -- 859
				local ____force_81 -- 860
				if force then -- 860
					____force_81 = current() -- 860
				else -- 860
					____force_81 = returnEntry or rememberedEntries[tab] or current() -- 860
				end -- 860
				local selected = ____force_81 -- 860
				local previousCount = #discover -- 861
				discover = getDiscoverEntries() -- 862
				discoverError = success and (#discover == 0 and (zh and "目录中暂无可运行作品" or "No runnable Catalog games") or "") or (message or (zh and "资源目录同步失败" or "Catalog sync failed")) -- 863
				if not force and not projectIndexOpen then -- 863
					tab = resolveDiscoverRefreshTab( -- 868
						tab, -- 868
						userSelectedTab, -- 868
						previousCount, -- 868
						#discover, -- 868
						#____local -- 868
					) -- 868
				end -- 868
				if selected ~= nil then -- 868
					local location = resolveFeedLocation(____local, discover, selected) -- 870
					if location.tab == tab then -- 870
						index = location.index -- 871
					end -- 871
				end -- 871
				index = normalizeFeedIndex( -- 873
					index, -- 873
					#entries() -- 873
				) -- 873
				render() -- 874
			end, -- 856
			force -- 875
		) -- 875
	end -- 841
	render() -- 877
	refreshDiscover(false) -- 878
	return host -- 879
end -- 124
return ____exports -- 124