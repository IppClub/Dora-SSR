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
local colors = { -- 37
	background = 4278914322, -- 38
	panel = 4279572770, -- 39
	panelRaised = 4280297010, -- 40
	text = 4294242792, -- 41
	muted = 4289245117, -- 42
	brand = 4294954035, -- 43
	border = 4281613128, -- 44
	danger = 4294929259 -- 45
} -- 45
local fontName = "sarasa-mono-sc-regular" -- 48
local createSheetHeight = 304 -- 49
local createInputHeight = 44 -- 50
local createInputTop = 140 -- 51
local function OverlayActionButton(props) -- 55
	return React.createElement( -- 56
		"node", -- 56
		{ -- 56
			key = props.key, -- 56
			tag = props.tag, -- 56
			x = props.x, -- 56
			y = props.y or 20, -- 56
			width = props.width, -- 56
			height = 48, -- 56
			anchorX = 0, -- 56
			anchorY = 0, -- 56
			touchEnabled = true, -- 56
			swallowTouches = true, -- 56
			onTapped = props.onTapped -- 56
		}, -- 56
		React.createElement( -- 56
			"draw-node", -- 56
			{renderOrder = 2}, -- 56
			React.createElement( -- 56
				"polygon-shape", -- 56
				{ -- 56
					verts = roundedRectVerts(props.width, 48, 14), -- 56
					fillColor = props.danger and 4292824662 or 4280889664, -- 56
					borderWidth = 1, -- 56
					borderColor = props.danger and 4294935941 or colors.border -- 56
				} -- 56
			) -- 56
		), -- 56
		React.createElement("label", { -- 56
			x = props.width / 2, -- 56
			y = 24, -- 56
			fontName = fontName, -- 56
			fontSize = props.fontSize or 17, -- 56
			text = props.text, -- 56
			color3 = 16052712, -- 56
			renderOrder = 3 -- 56
		}) -- 56
	) -- 56
end -- 55
local function conciseDescription(text, limit) -- 64
	local length = (utf8.len(text)) or 0 -- 65
	if length <= limit then -- 65
		return text -- 66
	end -- 66
	local stop = utf8.offset(text, limit + 1) or #text + 1 -- 67
	return string.sub(text, 1, stop - 1) .. "…" -- 68
end -- 64
local function formatTransferBytes(bytes) -- 71
	if bytes < 1024 then -- 71
		return tostring(math.floor(bytes)) .. " B" -- 72
	end -- 72
	local value = bytes -- 73
	local units = {"KiB", "MiB", "GiB", "TiB"} -- 74
	for ____, unit in ipairs(units) do -- 75
		value = value / 1024 -- 76
		if value < 1024 or unit == "TiB" then -- 76
			return (string.format("%.1f", value) .. " ") .. unit -- 77
		end -- 77
	end -- 77
	return tostring(math.floor(bytes)) .. " B" -- 79
end -- 71
local function Cover(props) -- 82
	local file = props.entry.bannerFile -- 83
	local function scaleSprite(sprite, mode) -- 84
		local scales = getCoverScales(sprite.width, sprite.height, props.width, props.height) -- 85
		sprite.scaleX = scales[mode] -- 86
		sprite.scaleY = scales[mode] -- 87
	end -- 84
	local ____React_createElement_5 = React.createElement -- 84
	local ____temp_3 = { -- 84
		x = props.x, -- 84
		y = props.y, -- 84
		width = props.width, -- 84
		height = props.height, -- 84
		anchorX = 0, -- 84
		anchorY = 0 -- 84
	} -- 84
	local ____React_createElement_result_4 = React.createElement( -- 84
		RoundedSurface, -- 90
		{ -- 90
			width = props.width, -- 90
			height = props.height, -- 90
			radius = 22, -- 90
			topColor = stableCoverColor(props.entry.id), -- 90
			bottomColor = 4279310115, -- 90
			shadow = true -- 90
		} -- 90
	) -- 90
	local ____file_0 -- 92
	if file then -- 92
		____file_0 = React.createElement( -- 92
			"clip-node", -- 92
			{ -- 92
				width = props.width, -- 92
				height = props.height, -- 92
				anchorX = 0, -- 92
				anchorY = 0, -- 92
				stencil = React.createElement(RoundedStencil, {width = props.width, height = props.height, radius = 22}) -- 92
			}, -- 92
			React.createElement( -- 92
				"sprite", -- 92
				{ -- 92
					file = file, -- 92
					x = props.width / 2 - 5, -- 92
					y = props.height / 2, -- 92
					opacity = 0.08, -- 92
					onMount = function(sprite) return scaleSprite(sprite, "cover") end -- 92
				} -- 92
			), -- 92
			React.createElement( -- 92
				"sprite", -- 92
				{ -- 92
					file = file, -- 92
					x = props.width / 2 + 5, -- 92
					y = props.height / 2, -- 92
					opacity = 0.08, -- 92
					onMount = function(sprite) return scaleSprite(sprite, "cover") end -- 92
				} -- 92
			), -- 92
			React.createElement( -- 92
				"sprite", -- 92
				{ -- 92
					file = file, -- 92
					x = props.width / 2, -- 92
					y = props.height / 2 - 5, -- 92
					opacity = 0.08, -- 92
					onMount = function(sprite) return scaleSprite(sprite, "cover") end -- 92
				} -- 92
			), -- 92
			React.createElement( -- 92
				"draw-node", -- 92
				{x = props.width / 2, y = props.height / 2}, -- 92
				React.createElement("rect-shape", {width = props.width, height = props.height, fillColor = 2953514258}) -- 92
			), -- 92
			React.createElement( -- 92
				"sprite", -- 92
				{ -- 92
					file = file, -- 92
					x = props.width / 2, -- 92
					y = props.height / 2, -- 92
					onMount = function(sprite) return scaleSprite(sprite, "contain") end -- 92
				} -- 92
			) -- 92
		) -- 92
	else -- 92
		____file_0 = React.createElement( -- 92
			"label", -- 92
			{ -- 92
				x = props.width / 2, -- 92
				y = props.height / 2 + 10, -- 92
				fontName = fontName, -- 92
				fontSize = math.floor(math.max( -- 92
					22, -- 104
					math.min(34, props.width / 12) -- 104
				)), -- 104
				text = props.entry.title, -- 104
				textWidth = props.width - 40, -- 104
				color3 = 16052712 -- 104
			} -- 104
		) -- 104
	end -- 104
	local ____file_1 -- 109
	if file then -- 109
		____file_1 = nil -- 109
	else -- 109
		____file_1 = React.createElement("label", { -- 109
			x = props.width / 2, -- 109
			y = 30, -- 109
			fontName = fontName, -- 109
			fontSize = 14, -- 109
			text = "DORA SSR · REMIXABLE", -- 109
			color3 = 16763955 -- 109
		}) -- 109
	end -- 109
	local ____file_2 -- 117
	if file then -- 117
		____file_2 = nil -- 117
	else -- 117
		____file_2 = React.createElement(DoraMascot, {state = "idle", x = props.width - 46, y = 64, size = 42}) -- 117
	end -- 117
	return ____React_createElement_5( -- 89
		"node", -- 89
		____temp_3, -- 89
		____React_createElement_result_4, -- 89
		____file_0, -- 89
		____file_1, -- 89
		____file_2, -- 89
		React.createElement(RoundedSurface, { -- 89
			width = props.width, -- 89
			height = props.height, -- 89
			radius = 22, -- 89
			fillColor = 0, -- 89
			borderWidth = 1, -- 89
			borderColor = 4282074454 -- 89
		}) -- 89
	) -- 89
end -- 82
function ____exports.startMobileFeed(options) -- 122
	local submitCreate, render, refreshDiscover -- 122
	local getLocalEntries = options.getLocalEntries -- 123
	local getDiscoverEntries = options.getDiscoverEntries -- 124
	local onPlay = options.onPlay -- 125
	local onRemix = options.onRemix -- 126
	local prepare = options.prepare -- 127
	local syncDiscover = options.syncDiscover -- 128
	local canShare = App.platform == "Android" or App.platform == "iOS" -- 129
	local zh = (string.match(App.locale, "^zh")) ~= nil -- 130
	local tab = "local" -- 131
	local index = 0 -- 132
	local drag = Vec2.zero -- 133
	local dragAxis = "none" -- 134
	local discoverError = "" -- 135
	local preparing = false -- 136
	local transitioning = false -- 137
	local prepareStatus = "" -- 138
	local prepareProgress = 0 -- 139
	local prepareTransferredBytes = 0 -- 140
	local prepareCanceled = false -- 141
	local synchronizing = false -- 142
	local syncConfirmation -- 143
	local syncFailure = "" -- 144
	local managementOpen = false -- 145
	local catalogSyncing = false -- 146
	local catalogStatus = "" -- 147
	local catalogStatusView -- 148
	local repairResourceId = "" -- 149
	local userSelectedTab = false -- 150
	local active = true -- 151
	local leaving = false -- 152
	local packagePanel -- 153
	local createOpen = false -- 154
	local projectIndexOpen = false -- 155
	local creating = false -- 156
	local createName = "" -- 157
	local createLanguage = "typescript" -- 158
	local dismissedCreateComposition = false -- 159
	local createError = "" -- 160
	local gamepadUsed = false -- 161
	local returnEntry = options.initialEntry -- 162
	local ____opt_6 = options.initialEntries -- 162
	local ____temp_10 = ____opt_6 and ____opt_6["local"] -- 164
	local ____opt_8 = options.initialEntries -- 164
	local rememberedEntries = {["local"] = ____temp_10, discover = ____opt_8 and ____opt_8.discover} -- 163
	local cardRef = reference() -- 167
	local indexRef = reference() -- 168
	local createInputRef = reference() -- 169
	local discover = getDiscoverEntries() -- 170
	local ____local = getLocalEntries() -- 171
	if #discover == 0 then -- 171
		discoverError = zh and "资源目录暂不可用" or "Catalog is unavailable" -- 174
	end -- 174
	local initialLocation = resolveFeedLocation(____local, discover, returnEntry) -- 176
	tab = initialLocation.tab -- 177
	index = initialLocation.index -- 178
	local host = Node() -- 180
	host.tag = "mobile-feed" -- 181
	host.scaleX = App.devicePixelRatio -- 182
	host.scaleY = App.devicePixelRatio -- 183
	host:addTo(Director.systemUI) -- 184
	local function isActive() -- 186
		return active and not leaving and host.parent ~= nil -- 186
	end -- 186
	local function entries() -- 188
		return tab == "discover" and discover or ____local -- 188
	end -- 188
	local function current() -- 189
		return entries()[normalizeFeedIndex( -- 189
			index, -- 189
			#entries() -- 189
		) + 1] -- 189
	end -- 189
	local rememberedEntryKey = "" -- 190
	local function rememberCurrent() -- 191
		local item = current() -- 192
		if not item or not options.onCurrentEntryChanged then -- 192
			return -- 193
		end -- 193
		local key = (((((item.kind .. "\n") .. item.id) .. "\n") .. (item.workDir or "")) .. "\n") .. (item.fileName or "") -- 194
		if key == rememberedEntryKey then -- 194
			return -- 195
		end -- 195
		rememberedEntryKey = key -- 196
		rememberedEntries[item.kind] = item -- 197
		options.onCurrentEntryChanged(item) -- 198
	end -- 191
	local function canEditCreate() -- 200
		return createOpen and not creating and isActive() and host.visible and HttpServer.wsConnectionCount == 0 -- 200
	end -- 200
	local createInput = createTextInput({ -- 201
		fontSize = math.floor(16 * mobileFontScale), -- 202
		singleLine = true, -- 203
		background = colors.background, -- 204
		getText = function() return createName end, -- 205
		setText = function(text) -- 206
			createName = text -- 206
		end, -- 206
		getPlaceholder = function() return zh and "例如：星际花园" or "For example: Star Garden" end, -- 207
		isEnabled = canEditCreate, -- 208
		onReturn = function() -- 209
			submitCreate() -- 209
			return true -- 209
		end -- 209
	}) -- 209
	local blurCreateInput = createInput.blur -- 211
	local function closeCreate() -- 212
		if creating then -- 212
			return -- 213
		end -- 213
		blurCreateInput() -- 214
		createOpen = false -- 215
		createName = "" -- 216
		createError = "" -- 217
		render() -- 218
	end -- 212
	local function openCreate() -- 220
		if not options.createProject or preparing or transitioning or creating or createOpen or syncConfirmation or managementOpen or HttpServer.wsConnectionCount > 0 then -- 220
			return -- 221
		end -- 221
		projectIndexOpen = false -- 222
		createOpen = true -- 223
		createLanguage = "typescript" -- 224
		createName = "" -- 225
		dismissedCreateComposition = false -- 226
		createError = "" -- 227
		render() -- 228
		createInput.deferFocus() -- 229
	end -- 220
	local function openProjectIndex() -- 231
		if preparing or transitioning or creating or createOpen or syncConfirmation or managementOpen or HttpServer.wsConnectionCount > 0 then -- 231
			return -- 232
		end -- 232
		if tab == "local" then -- 232
			____local = getLocalEntries() -- 233
		end -- 233
		projectIndexOpen = true -- 234
		render() -- 235
	end -- 231
	local function createErrorText(____error) -- 237
		repeat -- 237
			local ____switch37 = ____error -- 237
			local ____cond37 = ____switch37 == "invalid-name" -- 237
			if ____cond37 then -- 237
				return zh and "请输入不含路径分隔符的项目名称" or "Enter a project name without path separators" -- 239
			end -- 239
			____cond37 = ____cond37 or ____switch37 == "target-existed" -- 239
			if ____cond37 then -- 239
				return zh and "已有同名项目，请换一个名称" or "A project with that name already exists" -- 240
			end -- 240
			____cond37 = ____cond37 or ____switch37 == "create-folder-failed" -- 240
			if ____cond37 then -- 240
				return zh and "无法创建项目目录，请检查工作目录后重试" or "Could not create the project folder; check the workspace and retry" -- 241
			end -- 241
			____cond37 = ____cond37 or ____switch37 == "create-entry-failed" -- 241
			if ____cond37 then -- 241
				return zh and "无法写入项目入口，未完成项目已回滚" or "Could not write the project entry; the incomplete project was rolled back" -- 242
			end -- 242
			____cond37 = ____cond37 or ____switch37 == "created-project-not-found" -- 242
			if ____cond37 then -- 242
				return zh and "项目已创建，但本地列表未能找到它，请返回后重试" or "The project was created but could not be found in Local; return and retry" -- 243
			end -- 243
			do -- 243
				return zh and "创建失败，请重试" or "Project creation failed; try again" -- 244
			end -- 244
		until true -- 244
	end -- 237
	submitCreate = function() -- 247
		if not options.createProject or creating or not createOpen or not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 then -- 247
			return -- 248
		end -- 248
		if createInput.isComposing() then -- 248
			return -- 249
		end -- 249
		creating = true -- 250
		createError = "" -- 251
		blurCreateInput() -- 252
		render() -- 253
		local result = options.createProject(createName, createLanguage) -- 254
		if not isActive() then -- 254
			return -- 255
		end -- 255
		creating = false -- 256
		if not result.success then -- 256
			createError = createErrorText(result.error) -- 258
			render() -- 259
			return -- 260
		end -- 260
		createOpen = false -- 262
		createName = "" -- 263
		____local = getLocalEntries() -- 264
		returnEntry = result.entry -- 265
		local location = resolveFeedLocation(____local, discover, result.entry) -- 266
		tab = location.tab -- 267
		index = location.index -- 268
		render() -- 269
		onRemix(result.entry) -- 270
	end -- 247
	local function openPackage(mode, path, pickOnOpen) -- 273
		if pickOnOpen == nil then -- 273
			pickOnOpen = false -- 273
		end -- 273
		if not isActive() or not host.visible or packagePanel or preparing or transitioning or creating or createOpen or HttpServer.wsConnectionCount > 0 then -- 273
			return -- 274
		end -- 274
		projectIndexOpen = false -- 275
		packagePanel = startPackagePanel({ -- 276
			mode = mode, -- 277
			path = path, -- 277
			pickOnOpen = pickOnOpen, -- 277
			entry = current(), -- 277
			onNew = openCreate, -- 278
			onClosed = function() -- 279
				packagePanel = nil -- 279
			end, -- 279
			onImported = function(entry, play) -- 280
				if not isActive() then -- 280
					return -- 281
				end -- 281
				____local = getLocalEntries(entry.workDir) -- 282
				local imported = __TS__ArrayFind( -- 283
					____local, -- 283
					function(____, item) return item.workDir == entry.workDir end -- 283
				) or entry -- 283
				returnEntry = imported -- 284
				local location = resolveFeedLocation(____local, discover, imported) -- 285
				tab = "local" -- 286
				index = location.index -- 286
				render() -- 287
				if play then -- 287
					onPlay(imported) -- 288
				end -- 288
			end -- 280
		}) -- 280
	end -- 273
	local receiveElapsed = 0 -- 292
	host:schedule(function(dt) -- 293
		receiveElapsed = receiveElapsed + dt -- 294
		if receiveElapsed < 0.5 then -- 294
			return false -- 295
		end -- 295
		receiveElapsed = 0 -- 296
		if isActive() and host.visible and not packagePanel and not createOpen and not projectIndexOpen and not managementOpen and not syncConfirmation and not preparing and not transitioning and HttpServer.wsConnectionCount == 0 then -- 296
			local path = options.takeReceivedFile and options.takeReceivedFile() or App:takeReceivedFile() -- 298
			if path ~= "" then -- 298
				openPackage("receive", path) -- 299
			end -- 299
		end -- 299
		return false -- 301
	end) -- 293
	local function setTab(next) -- 304
		if not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 or preparing or creating or syncConfirmation or managementOpen then -- 304
			return -- 305
		end -- 305
		userSelectedTab = true -- 306
		returnEntry = nil -- 307
		if tab == next then -- 307
			return -- 308
		end -- 308
		if createOpen then -- 308
			blurCreateInput() -- 310
			createOpen = false -- 311
			createName = "" -- 312
			createError = "" -- 313
		end -- 313
		tab = next -- 315
		local target = rememberedEntries[next] -- 316
		local ____temp_11 -- 317
		if target == nil then -- 317
			____temp_11 = nil -- 317
		else -- 317
			____temp_11 = resolveFeedLocation(____local, discover, target) -- 317
		end -- 317
		local location = ____temp_11 -- 317
		index = (location and location.tab) == next and location.index or 0 -- 318
		render() -- 319
	end -- 304
	local function activate(action) -- 321
		local item = current() -- 322
		if not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 or not item or preparing or syncConfirmation or managementOpen then -- 322
			return -- 323
		end -- 323
		if item.webPlayUrl then -- 323
			local url = action == "play" and item.webPlayUrl or item.sourceUrl -- 325
			if url then -- 325
				App:openURL(url) -- 326
			end -- 326
			return -- 327
		end -- 327
		item.launchError = nil -- 329
		local function done() -- 330
			returnEntry = item -- 330
			local ____temp_14 -- 330
			if action == "play" then -- 330
				____temp_14 = onPlay(item) -- 330
			else -- 330
				____temp_14 = onRemix(item) -- 330
			end -- 330
			return ____temp_14 -- 330
		end -- 330
		if item.kind == "local" or item.installed then -- 330
			done() -- 331
			return -- 331
		end -- 331
		preparing = true -- 332
		prepareProgress = 0 -- 333
		prepareTransferredBytes = 0 -- 334
		prepareCanceled = false -- 335
		prepareStatus = zh and "准备安装…" or "Preparing install…" -- 336
		render() -- 337
		local repairIncomplete = repairResourceId == item.id -- 338
		repairResourceId = "" -- 339
		prepare( -- 340
			item, -- 340
			repairIncomplete, -- 340
			function(progress, message, transferredBytes) -- 340
				if not isActive() then -- 340
					return -- 341
				end -- 341
				prepareProgress = math.max( -- 342
					0, -- 342
					math.min(1, progress) -- 342
				) -- 342
				if transferredBytes ~= nil then -- 342
					prepareTransferredBytes = math.max(prepareTransferredBytes, transferredBytes) -- 343
				end -- 343
				prepareStatus = message -- 344
				render() -- 345
			end, -- 340
			function(success, ready, message, repairable) -- 346
				if not isActive() then -- 346
					return -- 347
				end -- 347
				preparing = false -- 348
				if not success or not ready then -- 348
					repairResourceId = repairable and item.id or "" -- 350
					prepareStatus = message or (zh and "安装失败，点击按钮重试" or "Install failed; tap to retry") -- 351
					render() -- 352
					return -- 353
				end -- 353
				item.fileName = ready.fileName -- 355
				item.workDir = ready.workDir -- 356
				item.installed = true -- 357
				prepareStatus = "" -- 358
				if HttpServer.wsConnectionCount == 0 and host.visible then -- 358
					done() -- 359
				else -- 359
					render() -- 360
				end -- 360
			end, -- 346
			function() return prepareCanceled end -- 361
		) -- 361
	end -- 321
	local function cancelPrepare() -- 363
		if not preparing or prepareCanceled then -- 363
			return -- 364
		end -- 364
		prepareCanceled = true -- 365
		prepareStatus = zh and "正在中断下载…" or "Canceling download…" -- 366
		render() -- 367
	end -- 363
	local function closeManagement() -- 369
		managementOpen = false -- 369
		render() -- 369
	end -- 369
	local function openManagement() -- 370
		local item = current() -- 371
		if not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 or not item or item.kind ~= "local" or preparing or transitioning or creating or createOpen or packagePanel or syncConfirmation then -- 371
			return -- 373
		end -- 373
		managementOpen = not managementOpen -- 374
		render() -- 375
	end -- 370
	local function dismissSyncConfirmation() -- 377
		syncConfirmation = nil -- 377
		render() -- 377
	end -- 377
	local function synchronize(item, force) -- 378
		if not options.sync or not item.resource or item.kind ~= "local" or preparing or not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 then -- 378
			return -- 380
		end -- 380
		syncConfirmation = nil -- 381
		managementOpen = false -- 382
		preparing = true -- 383
		synchronizing = true -- 384
		prepareProgress = 0 -- 385
		prepareTransferredBytes = 0 -- 386
		prepareCanceled = false -- 387
		prepareStatus = zh and "正在同步…" or "Synchronizing…" -- 388
		render() -- 389
		options.sync( -- 390
			item, -- 390
			force, -- 390
			function(progress, message, transferredBytes) -- 390
				if not isActive() then -- 390
					return -- 391
				end -- 391
				prepareProgress = math.max( -- 392
					0, -- 392
					math.min(1, progress) -- 392
				) -- 392
				prepareTransferredBytes = transferredBytes or prepareTransferredBytes -- 393
				prepareStatus = message -- 394
				render() -- 395
			end, -- 390
			function(success, ready, message, forceable) -- 396
				if not isActive() then -- 396
					return -- 397
				end -- 397
				preparing = false -- 398
				synchronizing = false -- 399
				if success and ready then -- 399
					____local = getLocalEntries(ready.workDir) -- 401
					discover = getDiscoverEntries() -- 402
					local sameEntry = __TS__ArrayFindIndex( -- 403
						____local, -- 403
						function(____, entry) return entry.fileName == item.fileName end -- 403
					) -- 403
					local sameResource = __TS__ArrayFindIndex( -- 404
						____local, -- 404
						function(____, entry) -- 404
							local ____opt_15 = entry.resource -- 404
							local ____temp_19 = ____opt_15 and ____opt_15.id -- 404
							local ____opt_17 = item.resource -- 404
							return ____temp_19 == (____opt_17 and ____opt_17.id) -- 404
						end -- 404
					) -- 404
					index = normalizeFeedIndex(sameEntry >= 0 and sameEntry or (sameResource >= 0 and sameResource or index), #____local) -- 405
					prepareStatus = message or (zh and "同步完成" or "Synchronized") -- 406
				else -- 406
					prepareStatus = message or (zh and "同步失败" or "Synchronization failed") -- 408
					if not force and forceable and not prepareCanceled then -- 408
						syncFailure = prepareStatus -- 410
						syncConfirmation = item -- 411
					end -- 411
				end -- 411
				render() -- 414
			end, -- 396
			function() return prepareCanceled or not isActive() end -- 415
		) -- 415
	end -- 378
	local function commit(action) -- 418
		if not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 or preparing or transitioning or syncConfirmation or managementOpen then -- 418
			return -- 419
		end -- 419
		if action == "play" or action == "remix" then -- 419
			local card = cardRef.current -- 421
			if card then -- 421
				card.position = Vec2.zero -- 422
			end -- 422
		end -- 422
		repeat -- 422
			local ____switch95 = action -- 422
			local ____cond95 = ____switch95 == "previous" or ____switch95 == "next" -- 422
			if ____cond95 then -- 422
				do -- 422
					returnEntry = nil -- 427
					local target = normalizeFeedIndex( -- 428
						index + (action == "next" and 1 or -1), -- 428
						#entries() -- 428
					) -- 428
					if target == index then -- 428
						local card = cardRef.current -- 430
						if card then -- 430
							card:perform(Move(App.reducedMotion and 0 or 0.16, card.position, Vec2.zero, Ease.OutQuad)) -- 431
						end -- 431
						return -- 432
					end -- 432
					local duration = App.reducedMotion and 0 or 0.18 -- 434
					local function finish() -- 435
						if not isActive() then -- 435
							return -- 436
						end -- 436
						index = target -- 437
						transitioning = false -- 438
						App:vibrate(0.012) -- 439
						render() -- 440
					end -- 435
					local card = cardRef.current -- 442
					if duration > 0 and card then -- 442
						transitioning = true -- 444
						card:perform(Move( -- 445
							duration, -- 445
							card.position, -- 445
							Vec2(0, (action == "next" and 1 or -1) * App.safeArea.height), -- 445
							Ease.OutQuad -- 445
						)) -- 445
						thread(function() -- 446
							sleep(duration) -- 446
							finish() -- 446
						end) -- 446
					else -- 446
						finish() -- 447
					end -- 447
					return -- 448
				end -- 448
			end -- 448
			____cond95 = ____cond95 or ____switch95 == "play" -- 448
			if ____cond95 then -- 448
				activate("play") -- 450
				return -- 450
			end -- 450
			____cond95 = ____cond95 or ____switch95 == "remix" -- 450
			if ____cond95 then -- 450
				activate("remix") -- 451
				return -- 451
			end -- 451
			do -- 451
				return -- 452
			end -- 452
		until true -- 452
	end -- 418
	local function switchMode() -- 456
		if not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 or preparing or creating or createOpen or packagePanel or transitioning or syncConfirmation or managementOpen or not options.onSwitchMode then -- 456
			return -- 457
		end -- 457
		leaving = true -- 458
		options.onSwitchMode() -- 459
	end -- 456
	host:slot("SwitchUIMode", switchMode) -- 461
	render = function() -- 462
		if not isActive() then -- 462
			return -- 463
		end -- 463
		catalogStatusView = nil -- 464
		local safeContentWidth = App.safeArea.width - 40 -- 466
		local shortLandscapeInputWidth = safeContentWidth - 12 - math.min( -- 467
			300, -- 467
			math.floor(safeContentWidth * 0.42) -- 467
		) -- 467
		local expectedInputWidth = App.safeArea.width >= 760 and App.safeArea.height < 500 and shortLandscapeInputWidth or safeContentWidth -- 468
		local ____createOpen_22 = createOpen -- 469
		if ____createOpen_22 then -- 469
			local ____opt_20 = createInputRef.current -- 469
			____createOpen_22 = (____opt_20 and ____opt_20.width) == expectedInputWidth -- 469
		end -- 469
		local keptInput = ____createOpen_22 and createInputRef.current or nil -- 469
		local restoreFocus = createInput.isFocused() -- 470
		if keptInput ~= nil then -- 470
			keptInput:removeFromParent(false) -- 471
		end -- 471
		if not keptInput then -- 471
			createInput.unmount() -- 473
			createInputRef = reference() -- 474
		end -- 474
		local createPanelRef = reference() -- 476
		host:removeAllChildren() -- 477
		host.scaleX = App.devicePixelRatio -- 478
		host.scaleY = App.devicePixelRatio -- 479
		local ____App_visualSize_25 = App.visualSize -- 480
		local width = ____App_visualSize_25.width -- 480
		local height = ____App_visualSize_25.height -- 480
		local safe = App.safeArea -- 481
		local left = safe.left -- 482
		local bottom = safe.bottom -- 483
		local usableWidth = safe.width -- 484
		local usableHeight = safe.height -- 485
		local wide = usableWidth >= 760 -- 486
		local shortLandscape = wide and usableHeight < 500 -- 487
		local compact = not wide and usableHeight < 700 -- 488
		local compactLandscape = compact and usableWidth > usableHeight and usableHeight < 520 -- 489
		local landscapeTopLift = shortLandscape and 28 or 0 -- 490
		local data = entries() -- 491
		index = normalizeFeedIndex(index, #data) -- 492
		local item = current() -- 493
		rememberCurrent() -- 494
		local coverWidth = wide and math.min(usableWidth * 0.54, 680) or usableWidth - 32 -- 495
		local coverHeight = wide and math.min(usableHeight - 118, coverWidth * 0.72) or (compact and math.min(usableHeight * (compactLandscape and 0.43 or 0.49), coverWidth * 0.72) or math.min(usableHeight * 0.54, coverWidth * 1.12)) -- 496
		local coverX = left + 16 -- 501
		local coverY = wide and bottom + (usableHeight - coverHeight) / 2 - 12 + landscapeTopLift or bottom + usableHeight - coverHeight - 82 -- 502
		local infoX = wide and coverX + coverWidth + 28 or left + 20 -- 503
		local infoWidth = wide and usableWidth - coverWidth - 72 or usableWidth - 40 -- 504
		local infoTop = wide and bottom + usableHeight - 122 + landscapeTopLift or coverY - (compactLandscape and 28 or 30) -- 505
		local descriptionY = infoTop - (compactLandscape and 38 or 58) -- 506
		local metadataY = infoTop - (wide and 136 or 118) -- 507
		local actionsY = bottom + (compactLandscape and 18 or 24) -- 508
		local gestureHintY = bottom + (compactLandscape and 88 or 92) -- 509
		local canSync = (item and item.kind) == "local" and item.resource ~= nil and options.sync ~= nil -- 510
		local canManage = (item and item.kind) == "local" and (canShare or canSync) -- 511
		local buttonWidth = wide and math.min(190, (infoWidth - 12) / 2) or (infoWidth - 12) / 2 -- 512
		local fontScale = mobileFontScale -- 513
		local cardIndices = getReusableCardIndices(index, #data) -- 514
		local headerRenderOrder = 1000 -- 515
		local ____toNode_71 = toNode -- 517
		local ____React_createElement_70 = React.createElement -- 517
		local ____array_69 = __TS__SparseArrayNew( -- 517
			"node", -- 517
			{ -- 517
				tag = "mobile-feed-scene", -- 517
				x = -width / 2, -- 517
				y = -height / 2, -- 517
				width = width, -- 517
				height = height, -- 517
				anchorX = 0, -- 517
				anchorY = 0, -- 517
				touchEnabled = true, -- 517
				onTapBegan = function() -- 517
					drag = Vec2.zero -- 527
					dragAxis = "none" -- 528
					local ____opt_30 = cardRef.current -- 528
					if ____opt_30 ~= nil then -- 528
						____opt_30:stopAllActions() -- 529
					end -- 529
					if indexRef.current then -- 529
						indexRef.current.opacity = 1 -- 530
					end -- 530
				end, -- 526
				onTapMoved = function(touch) -- 526
					drag = drag:add(touch.delta) -- 533
					if dragAxis == "none" and math.max( -- 533
						math.abs(drag.x), -- 534
						math.abs(drag.y) -- 534
					) >= 12 then -- 534
						dragAxis = math.abs(drag.x) > math.abs(drag.y) * 1.2 and "horizontal" or "vertical" -- 535
					end -- 535
					if cardRef.current then -- 535
						local offset = dragAxis == "horizontal" and Vec2(drag.x * 0.18, 0) or (dragAxis == "vertical" and Vec2(0, drag.y * 0.12) or Vec2.zero) -- 538
						cardRef.current.position = offset -- 539
						if indexRef.current then -- 539
							local headerBottom = bottom + usableHeight - 72 -- 541
							local indexTop = coverY + coverHeight - 14 + offset.y -- 542
							indexRef.current.opacity = dragAxis == "vertical" and math.max( -- 543
								0, -- 544
								math.min(1, (headerBottom - indexTop) / 16) -- 544
							) or 1 -- 544
						end -- 544
					end -- 544
				end, -- 532
				onTapEnded = function() -- 532
					local action = resolveFeedGesture(drag.x, drag.y, usableWidth, usableHeight) -- 550
					drag = Vec2.zero -- 551
					dragAxis = "none" -- 552
					if indexRef.current then -- 552
						indexRef.current.opacity = 1 -- 553
					end -- 553
					if action == "none" and cardRef.current then -- 553
						local card = cardRef.current -- 555
						card:perform(Move(App.reducedMotion and 0 or 0.16, card.position, Vec2.zero, Ease.OutQuad)) -- 556
					end -- 556
					commit(action) -- 558
				end, -- 549
				onMouseWheel = function(delta) return commit(delta.y > 0 and "previous" or "next") end -- 549
			}, -- 549
			React.createElement(VerticalGradient, {width = width, height = height, topColor = 4279310117, bottomColor = 4278716943}) -- 549
		) -- 549
		local ____React_createElement_67 = React.createElement -- 549
		local ____temp_65 = {visible = not projectIndexOpen} -- 549
		local ____createOpen_47 -- 564
		if createOpen then -- 564
			____createOpen_47 = nil -- 564
		else -- 564
			local ____temp_46 -- 564
			if item ~= nil then -- 564
				local ____React_createElement_45 = React.createElement -- 564
				local ____array_44 = __TS__SparseArrayNew( -- 564
					"node", -- 564
					{tag = "mobile-feed-card-" .. item.id, ref = cardRef, key = (tab .. "-") .. item.id}, -- 564
					__TS__ArrayMap( -- 565
						cardIndices, -- 565
						function(____, cardIndex) return React.createElement(Cover, { -- 565
							key = (tab .. "-") .. data[cardIndex + 1].id, -- 565
							entry = data[cardIndex + 1], -- 565
							x = coverX, -- 565
							y = coverY + (index - cardIndex) * usableHeight, -- 565
							width = coverWidth, -- 565
							height = coverHeight -- 565
						}) end -- 565
					), -- 565
					React.createElement( -- 565
						"node", -- 565
						{ -- 565
							tag = "mobile-feed-index", -- 565
							ref = indexRef, -- 565
							order = 10, -- 565
							renderGroup = true, -- 565
							x = coverX + coverWidth - 62, -- 565
							y = coverY + coverHeight - 40, -- 565
							width = 48, -- 565
							height = 26, -- 565
							anchorX = 0, -- 565
							anchorY = 0, -- 565
							touchEnabled = true, -- 565
							swallowTouches = true, -- 565
							onTapped = openProjectIndex -- 565
						}, -- 565
						React.createElement( -- 565
							"clip-node", -- 565
							{ -- 565
								width = 48, -- 565
								height = 26, -- 565
								anchorX = 0, -- 565
								anchorY = 0, -- 565
								stencil = React.createElement(RoundedStencil, {width = 48, height = 26, radius = 13}) -- 565
							}, -- 565
							React.createElement( -- 565
								"draw-node", -- 565
								nil, -- 565
								React.createElement( -- 565
									"verts-shape", -- 565
									{verts = { -- 565
										{ -- 578
											Vec2(0, 0), -- 578
											3759281694 -- 578
										}, -- 578
										{ -- 578
											Vec2(48, 0), -- 578
											3759281694 -- 578
										}, -- 578
										{ -- 578
											Vec2(48, 26), -- 578
											3760730173 -- 578
										}, -- 578
										{ -- 579
											Vec2(0, 0), -- 579
											3759281694 -- 579
										}, -- 579
										{ -- 579
											Vec2(48, 26), -- 579
											3760730173 -- 579
										}, -- 579
										{ -- 579
											Vec2(0, 26), -- 579
											3760730173 -- 579
										} -- 579
									}} -- 579
								) -- 579
							) -- 579
						), -- 579
						React.createElement( -- 579
							"draw-node", -- 579
							{x = 0.5, y = 0.5}, -- 579
							React.createElement( -- 579
								"polygon-shape", -- 579
								{ -- 579
									verts = roundedRectVerts(47, 25, 12.5), -- 579
									fillColor = 0, -- 579
									borderWidth = 0.5, -- 579
									borderColor = 2286967404 -- 579
								} -- 579
							) -- 579
						), -- 579
						React.createElement( -- 579
							"draw-node", -- 579
							{x = 18, y = 2}, -- 579
							React.createElement( -- 579
								"polygon-shape", -- 579
								{ -- 579
									verts = roundedRectVerts(12, 2, 1), -- 579
									fillColor = colors.brand -- 579
								} -- 579
							) -- 579
						), -- 579
						React.createElement( -- 579
							"label", -- 579
							{ -- 579
								x = 24, -- 579
								y = 13, -- 579
								fontName = fontName, -- 579
								fontSize = 11, -- 579
								text = (tostring(index + 1) .. " / ") .. tostring(#data), -- 579
								color3 = 14146531 -- 579
							} -- 579
						) -- 579
					), -- 579
					React.createElement( -- 579
						"label", -- 579
						{ -- 579
							tag = "mobile-feed-current-title", -- 579
							x = infoX, -- 579
							y = infoTop, -- 579
							anchorX = 0, -- 579
							anchorY = 0.5, -- 579
							fontName = fontName, -- 579
							fontSize = math.floor((wide and 30 or 25) * fontScale), -- 579
							text = item.title, -- 579
							textWidth = infoWidth - (canManage and 92 or 0), -- 579
							alignment = "Left", -- 579
							color3 = 16052712 -- 579
						} -- 579
					) -- 579
				) -- 579
				local ____canManage_32 -- 588
				if canManage then -- 588
					____canManage_32 = React.createElement(MobileButton, { -- 588
						tag = "mobile-feed-manage", -- 588
						x = infoX + infoWidth - 84, -- 588
						y = infoTop - 18, -- 588
						width = 84, -- 588
						height = 36, -- 588
						text = zh and "管理" or "Manage", -- 588
						fontSize = 13, -- 588
						onTapped = openManagement -- 588
					}) -- 588
				else -- 588
					____canManage_32 = nil -- 588
				end -- 588
				__TS__SparseArrayPush( -- 588
					____array_44, -- 588
					____canManage_32, -- 588
					React.createElement( -- 588
						"label", -- 588
						{ -- 588
							tag = "mobile-feed-description", -- 588
							x = infoX, -- 588
							y = descriptionY, -- 588
							anchorX = 0, -- 588
							anchorY = 0.5, -- 588
							fontName = fontName, -- 588
							fontSize = math.floor(15 * fontScale), -- 588
							text = conciseDescription(item.description, wide and 80 or (compact and 28 or 42)), -- 588
							textWidth = infoWidth, -- 588
							alignment = "Left", -- 588
							color3 = 11055037 -- 588
						} -- 588
					) -- 588
				) -- 588
				local ____temp_33 -- 591
				if compact or shortLandscape then -- 591
					____temp_33 = nil -- 591
				else -- 591
					____temp_33 = React.createElement( -- 591
						"node", -- 591
						{ -- 591
							x = infoX, -- 591
							y = metadataY, -- 591
							width = wide and 176 or 164, -- 591
							height = 28, -- 591
							anchorX = 0, -- 591
							anchorY = 0 -- 591
						}, -- 591
						React.createElement(RoundedSurface, { -- 591
							width = wide and 176 or 164, -- 591
							height = 28, -- 591
							radius = 14, -- 591
							topColor = 1714436683, -- 591
							bottomColor = 1712857131, -- 591
							borderWidth = 1, -- 591
							borderColor = 2288020349 -- 591
						}), -- 591
						React.createElement("label", { -- 591
							x = 12, -- 591
							y = 14, -- 591
							anchorX = 0, -- 591
							fontName = fontName, -- 591
							fontSize = 12, -- 591
							text = item.webPlayUrl and (zh and "发现  ·  在线试玩" or "Discover  ·  Web game") or (item.kind == "local" and (zh and "本地作品  ·  可 Remix" or "Local  ·  Remixable") or (item.installed and (zh and "发现  ·  已安装" or "Discover  ·  Installed") or (zh and "发现  ·  可安装" or "Discover  ·  Installable"))), -- 591
							textWidth = (wide and 176 or 164) - 24, -- 591
							alignment = "Left", -- 591
							color3 = 14475754 -- 591
						}) -- 591
					) -- 591
				end -- 591
				__TS__SparseArrayPush(____array_44, ____temp_33) -- 591
				local ____preparing_42 -- 597
				if preparing then -- 597
					local ____React_createElement_41 = React.createElement -- 597
					local ____array_40 = __TS__SparseArrayNew( -- 597
						"node", -- 597
						{ -- 597
							tag = "mobile-feed-download", -- 597
							x = infoX, -- 597
							y = actionsY, -- 597
							width = infoWidth, -- 597
							height = 48, -- 597
							anchorX = 0, -- 597
							anchorY = 0 -- 597
						}, -- 597
						React.createElement("label", { -- 597
							x = 0, -- 597
							y = 38, -- 597
							anchorX = 0, -- 597
							fontName = fontName, -- 597
							fontSize = 14, -- 597
							text = synchronizing and (zh and "正在同步" or "Synchronizing") or (zh and "正在下载" or "Downloading"), -- 597
							color3 = 16763955 -- 597
						}), -- 597
						React.createElement( -- 597
							"label", -- 597
							{ -- 597
								tag = "mobile-feed-download-percent", -- 597
								x = infoWidth - 92, -- 597
								y = 38, -- 597
								anchorX = 1, -- 597
								fontName = fontName, -- 597
								fontSize = 14, -- 597
								text = (tostring(math.floor(prepareProgress * 100)) .. "%") .. (prepareTransferredBytes > 0 and " · " .. formatTransferBytes(prepareTransferredBytes) or ""), -- 597
								color3 = 16763955 -- 597
							} -- 597
						) -- 597
					) -- 597
					local ____React_createElement_39 = React.createElement -- 597
					local ____temp_37 = { -- 597
						tag = "mobile-feed-download-track", -- 597
						width = infoWidth - 92, -- 597
						height = 8, -- 597
						y = 8, -- 597
						anchorX = 0, -- 597
						anchorY = 0 -- 597
					} -- 597
					local ____React_createElement_result_38 = React.createElement(RoundedSurface, {width = infoWidth - 92, height = 8, radius = 4, fillColor = 4280889664}) -- 597
					local ____React_createElement_36 = React.createElement -- 597
					local ____temp_35 = { -- 597
						tag = "mobile-feed-download-fill", -- 597
						width = (infoWidth - 92) * prepareProgress, -- 597
						height = 8, -- 597
						anchorX = 0, -- 597
						anchorY = 0 -- 597
					} -- 597
					local ____temp_34 -- 604
					if prepareProgress > 0 then -- 604
						____temp_34 = React.createElement(RoundedSurface, { -- 604
							width = (infoWidth - 92) * prepareProgress, -- 604
							height = 8, -- 604
							radius = 4, -- 604
							topColor = 4294958955, -- 604
							bottomColor = 4294950190 -- 604
						}) -- 604
					else -- 604
						____temp_34 = nil -- 604
					end -- 604
					__TS__SparseArrayPush( -- 604
						____array_40, -- 604
						____React_createElement_39( -- 604
							"node", -- 604
							____temp_37, -- 604
							____React_createElement_result_38, -- 604
							____React_createElement_36("node", ____temp_35, ____temp_34) -- 604
						), -- 604
						React.createElement(MobileButton, { -- 604
							tag = "mobile-feed-download-cancel", -- 604
							x = infoWidth - 80, -- 604
							y = 0, -- 604
							width = 80, -- 604
							height = 48, -- 604
							text = prepareCanceled and (zh and "中断中…" or "Canceling…") or (zh and "中断" or "Cancel"), -- 604
							fontSize = 13, -- 604
							danger = true, -- 604
							onTapped = cancelPrepare -- 604
						}) -- 604
					) -- 604
					____preparing_42 = ____React_createElement_41(__TS__SparseArraySpread(____array_40)) -- 604
				else -- 604
					____preparing_42 = React.createElement( -- 604
						"node", -- 604
						nil, -- 604
						React.createElement( -- 604
							MobileButton, -- 610
							{ -- 610
								tag = "mobile-feed-remix", -- 610
								x = infoX, -- 610
								y = actionsY, -- 610
								width = buttonWidth, -- 610
								text = item.webPlayUrl and (zh and "查看源码" or "View source") or (zh and "Remix 作品" or "Remix game"), -- 610
								fontSize = math.floor(16 * fontScale), -- 610
								primary = true, -- 610
								onTapped = function() return activate("remix") end -- 610
							} -- 610
						), -- 610
						React.createElement( -- 610
							MobileButton, -- 612
							{ -- 612
								tag = "mobile-feed-play", -- 612
								x = infoX + buttonWidth + 12, -- 612
								y = actionsY, -- 612
								width = buttonWidth, -- 612
								text = item.webPlayUrl and (zh and "在线试玩" or "Play online") or (zh and "试玩" or "Play"), -- 612
								fontSize = math.floor(17 * fontScale), -- 612
								onTapped = function() return activate("play") end -- 612
							} -- 612
						) -- 612
					) -- 612
				end -- 612
				__TS__SparseArrayPush(____array_44, ____preparing_42) -- 612
				local ____preparing_43 -- 615
				if preparing then -- 615
					____preparing_43 = React.createElement( -- 615
						"clip-node", -- 615
						{ -- 615
							tag = "mobile-feed-download-message-clip", -- 615
							x = infoX, -- 615
							y = gestureHintY - 10, -- 615
							width = infoWidth, -- 615
							height = 20, -- 615
							anchorX = 0, -- 615
							anchorY = 0, -- 615
							stencil = React.createElement(RoundedStencil, {width = infoWidth, height = 20, radius = 0}) -- 615
						}, -- 615
						React.createElement("label", { -- 615
							tag = "mobile-feed-download-message", -- 615
							x = 0, -- 615
							y = 10, -- 615
							anchorX = 0, -- 615
							fontName = fontName, -- 615
							fontSize = 12, -- 615
							text = (string.gsub(prepareStatus, "[\r\n]+", " ")), -- 615
							textWidth = -1, -- 615
							color3 = 11055037 -- 615
						}) -- 615
					) -- 615
				else -- 615
					____preparing_43 = React.createElement("label", { -- 615
						tag = "mobile-feed-gesture-hint", -- 615
						x = infoX, -- 615
						y = gestureHintY, -- 615
						anchorX = 0, -- 615
						anchorY = 0.5, -- 615
						fontName = fontName, -- 615
						fontSize = gamepadUsed and 11 or 14, -- 615
						text = prepareStatus ~= "" and prepareStatus or (item.launchError ~= nil and item.launchError or (item.webPlayUrl and (gamepadUsed and (zh and "↑↓ 浏览 · A 在线试玩 · X 查看源码 · Start 列表" or "↑↓ Browse · A Play online · X Source · Start List") or (zh and "上滑浏览  ·  右滑源码  ·  左滑在线试玩" or "Swipe up  ·  right Source  ·  left Web play")) or (gamepadUsed and (zh and "↑↓ 浏览 · A 确认 · X Remix · Start 列表 · Y 新建" or "↑↓ Browse · A Select · X Remix · Start List · Y New") or (zh and "上滑浏览  ·  右滑 Remix  ·  左滑试玩" or "Swipe up  ·  right Remix  ·  left Play")))), -- 615
						textWidth = infoWidth, -- 615
						alignment = "Left", -- 615
						color3 = item.launchError ~= nil and 16739179 or 11055037 -- 615
					}) -- 615
				end -- 615
				__TS__SparseArrayPush(____array_44, ____preparing_43) -- 615
				____temp_46 = ____React_createElement_45(__TS__SparseArraySpread(____array_44)) -- 615
			else -- 615
				____temp_46 = React.createElement( -- 615
					"node", -- 615
					nil, -- 615
					React.createElement("label", { -- 615
						x = left + usableWidth / 2, -- 615
						y = bottom + usableHeight / 2 + 20, -- 615
						fontName = fontName, -- 615
						fontSize = 22, -- 615
						text = tab == "discover" and (zh and "暂无移动作品" or "No mobile games yet") or (zh and "没有可运行的本地作品" or "No runnable local games"), -- 615
						color3 = 16052712 -- 615
					}), -- 615
					React.createElement("label", { -- 615
						x = left + usableWidth / 2, -- 615
						y = bottom + usableHeight / 2 - 28, -- 615
						fontName = fontName, -- 615
						fontSize = 14, -- 615
						text = tab == "discover" and discoverError ~= "" and discoverError or (zh and "切换标签或稍后重试" or "Switch tabs or retry later"), -- 615
						textWidth = usableWidth - 48, -- 615
						color3 = tab == "discover" and discoverError ~= "" and 16739179 or 11055037 -- 615
					}) -- 615
				) -- 615
			end -- 615
			____createOpen_47 = ____temp_46 -- 564
		end -- 564
		local ____temp_48 -- 631
		if not createOpen and not item and tab == "local" then -- 631
			____temp_48 = React.createElement( -- 631
				"node", -- 631
				nil, -- 631
				React.createElement(MobileButton, { -- 631
					tag = "mobile-empty-new", -- 631
					x = left + 20, -- 631
					y = bottom + 24, -- 631
					width = (usableWidth - 52) / 2, -- 631
					text = zh and "新建作品" or "New game", -- 631
					onTapped = openCreate -- 631
				}), -- 631
				React.createElement( -- 631
					MobileButton, -- 633
					{ -- 633
						tag = "mobile-empty-import", -- 633
						x = left + 32 + (usableWidth - 52) / 2, -- 633
						y = bottom + 24, -- 633
						width = (usableWidth - 52) / 2, -- 633
						text = zh and "导入作品包" or "Import package", -- 633
						fontSize = 15, -- 633
						primary = true, -- 633
						onTapped = function() return openPackage("add", nil, true) end -- 633
					} -- 633
				) -- 633
			) -- 633
		else -- 633
			____temp_48 = nil -- 634
		end -- 634
		local ____temp_49 -- 635
		if not item and tab == "discover" and syncDiscover then -- 635
			____temp_49 = React.createElement(MobileButton, { -- 635
				tag = "mobile-feed-empty-index", -- 635
				x = left + (usableWidth - 160) / 2, -- 635
				y = bottom + 24, -- 635
				width = 160, -- 635
				text = zh and "作品目录" or "Game index", -- 635
				onTapped = openProjectIndex -- 635
			}) -- 635
		else -- 635
			____temp_49 = nil -- 636
		end -- 636
		local ____React_createElement_53 = React.createElement -- 636
		local ____array_52 = __TS__SparseArrayNew("node", {tag = "mobile-feed-header", order = headerRenderOrder, visible = not syncConfirmation}) -- 636
		local ____options_onSwitchMode_50 -- 638
		if options.onSwitchMode then -- 638
			____options_onSwitchMode_50 = React.createElement( -- 638
				"node", -- 638
				{ -- 638
					tag = "mobile-ui-mode-switch", -- 638
					x = left + 12, -- 638
					y = bottom + usableHeight - 58 + landscapeTopLift, -- 638
					width = 72, -- 638
					height = 48, -- 638
					anchorX = 0, -- 638
					anchorY = 0, -- 638
					touchEnabled = true, -- 638
					swallowTouches = true, -- 638
					onTapped = switchMode -- 638
				}, -- 638
				React.createElement("label", { -- 638
					x = 0, -- 638
					y = 30, -- 638
					anchorX = 0, -- 638
					fontName = fontName, -- 638
					fontSize = 16, -- 638
					text = "DORA", -- 638
					color3 = preparing and 7831180 or 16763955 -- 638
				}), -- 638
				React.createElement("label", { -- 638
					x = 0, -- 638
					y = 10, -- 638
					anchorX = 0, -- 638
					fontName = fontName, -- 638
					fontSize = 10, -- 638
					text = zh and "切换传统界面" or "Classic UI", -- 638
					color3 = 7831180 -- 638
				}) -- 638
			) -- 638
		else -- 638
			____options_onSwitchMode_50 = nil -- 642
		end -- 642
		__TS__SparseArrayPush( -- 642
			____array_52, -- 642
			____options_onSwitchMode_50, -- 642
			React.createElement( -- 642
				"label", -- 642
				{ -- 642
					tag = "mobile-feed-discover-tab", -- 642
					x = left + usableWidth / 2 - 44, -- 642
					y = bottom + usableHeight - 34 + landscapeTopLift, -- 642
					fontName = fontName, -- 642
					fontSize = math.floor(17 * fontScale), -- 642
					text = zh and "发现" or "Discover", -- 642
					color3 = tab == "discover" and 16763955 or 11055037, -- 642
					touchEnabled = true, -- 642
					swallowTouches = true, -- 642
					onTapped = function() return setTab("discover") end -- 642
				} -- 642
			), -- 642
			React.createElement( -- 642
				"label", -- 642
				{ -- 642
					tag = "mobile-feed-local-tab", -- 642
					x = left + usableWidth / 2 + 44, -- 642
					y = bottom + usableHeight - 34 + landscapeTopLift, -- 642
					fontName = fontName, -- 642
					fontSize = math.floor(17 * fontScale), -- 642
					text = zh and "本地" or "Local", -- 642
					color3 = tab == "local" and 16763955 or 11055037, -- 642
					touchEnabled = true, -- 642
					swallowTouches = true, -- 642
					onTapped = function() -- 642
						____local = getLocalEntries() -- 648
						setTab("local") -- 648
					end -- 648
				} -- 648
			), -- 648
			React.createElement(RoundedSurface, { -- 648
				x = left + usableWidth / 2 + (tab == "discover" and -58 or 30), -- 648
				y = bottom + usableHeight - 56 + landscapeTopLift, -- 648
				width = 28, -- 648
				height = 3, -- 648
				radius = 1.5, -- 648
				fillColor = colors.brand, -- 648
				renderOrder = headerRenderOrder + 1 -- 648
			}) -- 648
		) -- 648
		local ____temp_51 -- 650
		if tab == "local" and options.createProject then -- 650
			____temp_51 = React.createElement( -- 650
				MobileNewButton, -- 650
				{ -- 650
					tag = "mobile-feed-create", -- 650
					x = left + usableWidth - 82, -- 650
					y = bottom + usableHeight - 56 + landscapeTopLift, -- 650
					text = zh and "+ 新建" or "+ New", -- 650
					renderOrder = headerRenderOrder + 1, -- 650
					onTapped = function() return openPackage("add") end -- 650
				} -- 650
			) -- 650
		else -- 650
			____temp_51 = nil -- 652
		end -- 652
		__TS__SparseArrayPush(____array_52, ____temp_51) -- 652
		local ____React_createElement_53_result_66 = ____React_createElement_53(__TS__SparseArraySpread(____array_52)) -- 652
		local ____temp_55 -- 654
		if managementOpen and canManage and item then -- 654
			____temp_55 = (function() -- 654
				local menuWidth = math.min(208, infoWidth) -- 655
				local ____array_54 = __TS__SparseArrayNew(table.unpack(canShare and ({{ -- 655
					tag = "mobile-feed-share", -- 657
					text = zh and "分享作品" or "Share game", -- 657
					action = function() -- 657
						closeManagement() -- 657
						openPackage("share") -- 657
					end -- 657
				}}) or ({}))) -- 657
				__TS__SparseArrayPush( -- 657
					____array_54, -- 657
					table.unpack(canSync and ({{ -- 658
						tag = "mobile-feed-sync", -- 658
						text = zh and "同步上游" or "Sync upstream", -- 658
						action = function() -- 658
							managementOpen = false -- 658
							synchronize(item, false) -- 658
						end -- 658
					}}) or ({})) -- 658
				) -- 658
				local actions = {__TS__SparseArraySpread(____array_54)} -- 656
				local menuPadding = 12 -- 660
				local actionGap = 8 -- 661
				local menuHeight = menuPadding * 2 + #actions * 48 + (#actions - 1) * actionGap -- 662
				return React.createElement( -- 663
					"node", -- 663
					{ -- 663
						tag = "mobile-feed-management-menu", -- 663
						order = 1500, -- 663
						renderOrder = 1500, -- 663
						renderGroup = true, -- 663
						width = width, -- 663
						height = height, -- 663
						anchorX = 0, -- 663
						anchorY = 0, -- 663
						touchEnabled = true, -- 663
						swallowTouches = true, -- 663
						onTapped = closeManagement -- 663
					}, -- 663
					React.createElement( -- 663
						"draw-node", -- 663
						{x = width / 2, y = height / 2}, -- 663
						React.createElement("rect-shape", {width = width, height = height, fillColor = 855638016}) -- 663
					), -- 663
					React.createElement( -- 663
						"node", -- 663
						{ -- 663
							x = infoX + infoWidth - menuWidth, -- 663
							y = math.max(bottom + 16, infoTop - 26 - menuHeight), -- 663
							width = menuWidth, -- 663
							height = menuHeight, -- 663
							anchorX = 0, -- 663
							anchorY = 0, -- 663
							touchEnabled = true, -- 663
							swallowTouches = true -- 663
						}, -- 663
						React.createElement( -- 663
							"draw-node", -- 663
							{renderOrder = 1}, -- 663
							React.createElement( -- 663
								"polygon-shape", -- 663
								{ -- 663
									verts = roundedRectVerts(menuWidth, menuHeight, 16), -- 663
									fillColor = colors.panelRaised, -- 663
									borderWidth = 1, -- 663
									borderColor = colors.border -- 663
								} -- 663
							) -- 663
						), -- 663
						__TS__ArrayMap( -- 669
							actions, -- 669
							function(____, action, i) return React.createElement(OverlayActionButton, { -- 669
								key = action.tag, -- 669
								tag = action.tag, -- 669
								x = menuPadding, -- 669
								y = menuHeight - menuPadding - 48 - i * (48 + actionGap), -- 669
								width = menuWidth - menuPadding * 2, -- 669
								text = action.text, -- 669
								fontSize = 15, -- 669
								onTapped = action.action -- 669
							}) end -- 669
						) -- 669
					) -- 669
				) -- 669
			end)() -- 654
		else -- 654
			____temp_55 = nil -- 674
		end -- 674
		local ____syncConfirmation_56 -- 675
		if syncConfirmation then -- 675
			____syncConfirmation_56 = React.createElement( -- 675
				"node", -- 675
				{ -- 675
					tag = "mobile-feed-sync-confirmation", -- 675
					order = 2000, -- 675
					renderOrder = 2000, -- 675
					renderGroup = true, -- 675
					width = width, -- 675
					height = height, -- 675
					anchorX = 0, -- 675
					anchorY = 0, -- 675
					touchEnabled = true, -- 675
					swallowTouches = true, -- 675
					onTapped = function() -- 675
					end -- 676
				}, -- 676
				React.createElement( -- 676
					"draw-node", -- 676
					nil, -- 676
					React.createElement("rect-shape", { -- 676
						centerX = width / 2, -- 676
						centerY = height / 2, -- 676
						width = width, -- 676
						height = height, -- 676
						fillColor = 3490187791 -- 676
					}) -- 676
				), -- 676
				React.createElement( -- 676
					"node", -- 676
					{ -- 676
						x = left + (usableWidth - math.min(440, usableWidth - 24)) / 2, -- 676
						y = bottom + (usableHeight - math.min(310, usableHeight - 24)) / 2, -- 676
						width = math.min(440, usableWidth - 24), -- 676
						height = math.min(310, usableHeight - 24), -- 676
						anchorX = 0, -- 676
						anchorY = 0 -- 676
					}, -- 676
					React.createElement( -- 676
						"draw-node", -- 676
						{renderOrder = 1}, -- 676
						React.createElement( -- 676
							"polygon-shape", -- 676
							{ -- 676
								verts = roundedRectVerts( -- 676
									math.min(440, usableWidth - 24), -- 680
									math.min(310, usableHeight - 24), -- 680
									24 -- 680
								), -- 680
								fillColor = 4279572770, -- 680
								borderWidth = 1, -- 680
								borderColor = 4283061608 -- 680
							} -- 680
						) -- 680
					), -- 680
					React.createElement( -- 680
						"label", -- 680
						{ -- 680
							x = 20, -- 680
							y = math.min(310, usableHeight - 24) - 32, -- 680
							anchorX = 0, -- 680
							fontName = fontName, -- 680
							fontSize = 20, -- 680
							text = zh and "同步失败，是否强制同步？" or "Sync failed. Force sync?", -- 680
							textWidth = math.min(440, usableWidth - 24) - 40, -- 680
							alignment = "Left", -- 680
							renderOrder = 2 -- 680
						} -- 680
					), -- 680
					React.createElement( -- 680
						"label", -- 680
						{ -- 680
							x = 20, -- 680
							y = math.min(310, usableHeight - 24) - 82, -- 680
							anchorX = 0, -- 680
							fontName = fontName, -- 680
							fontSize = 13, -- 680
							color3 = 11055037, -- 680
							text = conciseDescription(syncFailure, 90), -- 680
							textWidth = math.min(440, usableWidth - 24) - 40, -- 680
							alignment = "Left", -- 680
							renderOrder = 2 -- 680
						} -- 680
					), -- 680
					React.createElement( -- 680
						"label", -- 680
						{ -- 680
							x = 20, -- 680
							y = math.min(310, usableHeight - 24) - 158, -- 680
							anchorX = 0, -- 680
							fontName = fontName, -- 680
							fontSize = 14, -- 680
							color3 = 16757683, -- 680
							text = zh and "将放弃本地所有修改、提交和新增文件，用当前 Catalog 的工程替换。此操作无法撤销。" or "Discard all local edits, commits and added files, replacing this project from the current Catalog. This cannot be undone.", -- 680
							textWidth = math.min(440, usableWidth - 24) - 40, -- 680
							alignment = "Left", -- 680
							renderOrder = 2 -- 680
						} -- 680
					), -- 680
					React.createElement( -- 680
						OverlayActionButton, -- 689
						{ -- 689
							tag = "mobile-feed-sync-cancel", -- 689
							x = 20, -- 689
							width = (math.min(440, usableWidth - 24) - 52) / 2, -- 689
							text = zh and "保留本地" or "Keep local", -- 689
							onTapped = dismissSyncConfirmation -- 689
						} -- 689
					), -- 689
					React.createElement( -- 689
						OverlayActionButton, -- 691
						{ -- 691
							tag = "mobile-feed-sync-force", -- 691
							x = 32 + (math.min(440, usableWidth - 24) - 52) / 2, -- 691
							width = (math.min(440, usableWidth - 24) - 52) / 2, -- 691
							text = zh and "强制同步" or "Force sync", -- 691
							danger = true, -- 691
							onTapped = function() -- 691
								if syncConfirmation then -- 691
									synchronize(syncConfirmation, true) -- 692
								end -- 692
							end -- 692
						} -- 692
					) -- 692
				) -- 692
			) -- 692
		else -- 692
			____syncConfirmation_56 = nil -- 694
		end -- 694
		local ____createOpen_64 -- 695
		if createOpen then -- 695
			____createOpen_64 = (function() -- 695
				local sheetHeight = math.min(createSheetHeight, usableHeight - 64) -- 696
				local sheetWidth = usableWidth -- 697
				local contentWidth = sheetWidth - 40 -- 698
				local actionGap = 12 -- 699
				local actionsWidth = shortLandscape and math.min( -- 700
					300, -- 700
					math.floor(contentWidth * 0.42) -- 700
				) or contentWidth -- 700
				local inputWidth = shortLandscape and contentWidth - actionGap - actionsWidth or contentWidth -- 701
				local actionX = shortLandscape and 20 + inputWidth + actionGap or 20 -- 702
				local actionY = shortLandscape and sheetHeight - createInputTop - createInputHeight or 20 -- 703
				local cancelWidth = math.floor((actionsWidth - actionGap) * (shortLandscape and 0.34 or 0.38)) -- 704
				local ____React_createElement_63 = React.createElement -- 704
				local ____array_62 = __TS__SparseArrayNew( -- 704
					"node", -- 704
					{ -- 704
						tag = "mobile-project-create-sheet", -- 704
						order = 10000, -- 704
						width = width, -- 704
						height = height, -- 704
						anchorX = 0, -- 704
						anchorY = 0, -- 704
						touchEnabled = true, -- 704
						swallowTouches = true -- 704
					}, -- 704
					React.createElement( -- 704
						"node", -- 704
						{ -- 704
							tag = "mobile-project-create-focus-observer", -- 704
							order = 1000, -- 704
							width = width, -- 704
							height = height, -- 704
							anchorX = 0, -- 704
							anchorY = 0, -- 704
							touchEnabled = true, -- 704
							swallowTouches = false, -- 704
							swallowMouseWheel = false, -- 704
							onTapFilter = function(touch) -- 704
								touch.enabled = false -- 708
								if not canEditCreate() then -- 708
									return -- 709
								end -- 709
								local input = createInputRef.current -- 710
								local point = input and input:convertToNodeSpace(touch.worldLocation) -- 711
								local inside = input and point and point.x >= 0 and point.y >= 0 and point.x <= input.width and point.y <= input.height -- 712
								dismissedCreateComposition = not inside and createInput.isComposing() -- 713
								if not inside then -- 713
									blurCreateInput() -- 714
								end -- 714
							end -- 707
						} -- 707
					), -- 707
					React.createElement( -- 707
						"draw-node", -- 707
						{ -- 707
							tag = "mobile-project-create-backdrop", -- 707
							order = 0, -- 707
							renderOrder = 0, -- 707
							x = width / 2, -- 707
							y = bottom + sheetHeight + (height - bottom - sheetHeight) / 2 -- 707
						}, -- 707
						React.createElement("rect-shape", {width = width, height = height - bottom - sheetHeight, fillColor = 2348810240}) -- 707
					) -- 707
				) -- 707
				local ____React_createElement_61 = React.createElement -- 707
				local ____array_60 = __TS__SparseArrayNew( -- 707
					"node", -- 707
					{ -- 707
						ref = createPanelRef, -- 707
						order = 10, -- 707
						renderOrder = 10, -- 707
						x = left, -- 707
						y = bottom, -- 707
						width = sheetWidth, -- 707
						height = sheetHeight, -- 707
						anchorX = 0, -- 707
						anchorY = 0, -- 707
						touchEnabled = true, -- 707
						swallowTouches = true -- 707
					}, -- 707
					React.createElement(MobilePanelSurface, {width = sheetWidth, height = sheetHeight, renderOrder = 10}), -- 707
					React.createElement("label", { -- 707
						x = 20, -- 707
						y = sheetHeight - 24, -- 707
						anchorX = 0, -- 707
						anchorY = 1, -- 707
						fontName = fontName, -- 707
						fontSize = 22, -- 707
						text = zh and "新建项目" or "New project", -- 707
						color3 = 16052712 -- 707
					}), -- 707
					__TS__ArrayMap( -- 722
						{"typescript", "lua"}, -- 722
						function(____, language, i) return React.createElement( -- 722
							MobileChoiceButton, -- 722
							{ -- 722
								tag = "mobile-project-create-language-" .. language, -- 722
								x = 20 + i * 144, -- 722
								y = sheetHeight - 98, -- 722
								width = language == "lua" and 84 or 132, -- 722
								text = language == "lua" and "Lua" or "TypeScript", -- 722
								selected = createLanguage == language, -- 722
								renderOrder = 10, -- 722
								onTapped = function() -- 722
									if not canEditCreate() then -- 722
										return -- 726
									end -- 726
									blurCreateInput() -- 727
									createLanguage = language -- 727
									render() -- 727
								end -- 725
							} -- 725
						) end -- 725
					), -- 725
					React.createElement("label", { -- 725
						x = 20, -- 725
						y = sheetHeight - 110, -- 725
						anchorX = 0, -- 725
						anchorY = 1, -- 725
						fontName = fontName, -- 725
						fontSize = 14, -- 725
						text = zh and "项目名称" or "Project name", -- 725
						color3 = 11055037 -- 725
					}) -- 725
				) -- 725
				local ____keptInput_59 -- 730
				if keptInput then -- 730
					____keptInput_59 = nil -- 730
				else -- 730
					____keptInput_59 = React.createElement("node", { -- 730
						tag = "mobile-project-create-input", -- 730
						ref = createInputRef, -- 730
						renderOrder = 10, -- 730
						x = 20, -- 730
						y = sheetHeight - createInputTop - createInputHeight, -- 730
						width = inputWidth, -- 730
						height = createInputHeight, -- 730
						anchorX = 0, -- 730
						anchorY = 0, -- 730
						onMount = createInput.mount -- 730
					}) -- 730
				end -- 730
				__TS__SparseArrayPush( -- 730
					____array_60, -- 730
					____keptInput_59, -- 730
					React.createElement("label", { -- 730
						tag = "mobile-project-create-error", -- 730
						x = 20, -- 730
						y = shortLandscape and sheetHeight - createInputTop + 12 or sheetHeight - createInputTop - createInputHeight - 12, -- 730
						anchorX = 0, -- 730
						anchorY = 1, -- 730
						fontName = fontName, -- 730
						fontSize = 12, -- 730
						text = createError ~= "" and createError or (zh and ("将创建可运行的 " .. (createLanguage == "lua" and "Lua" or "TypeScript")) .. " 起始项目" or ("Creates a runnable " .. (createLanguage == "lua" and "Lua" or "TypeScript")) .. " starter project"), -- 730
						textWidth = inputWidth, -- 730
						alignment = "Left", -- 730
						color3 = createError ~= "" and 16739179 or 11055037 -- 730
					}), -- 730
					React.createElement(MobileButton, { -- 730
						tag = "mobile-project-create-cancel", -- 730
						x = actionX, -- 730
						y = actionY, -- 730
						width = cancelWidth, -- 730
						text = zh and "取消" or "Cancel", -- 730
						renderOrder = 10, -- 730
						onTapped = closeCreate -- 730
					}), -- 730
					React.createElement( -- 730
						MobileButton, -- 736
						{ -- 736
							tag = "mobile-project-create-submit", -- 736
							x = actionX + cancelWidth + actionGap, -- 736
							y = actionY, -- 736
							width = actionsWidth - cancelWidth - actionGap, -- 736
							text = creating and (zh and "创建中…" or "Creating…") or (zh and "创建并进入 Remix" or "Create and Remix"), -- 736
							primary = true, -- 736
							renderOrder = 10, -- 736
							onTapped = function() -- 736
								if not dismissedCreateComposition then -- 736
									submitCreate() -- 737
								end -- 737
								dismissedCreateComposition = false -- 737
							end -- 737
						} -- 737
					) -- 737
				) -- 737
				__TS__SparseArrayPush( -- 737
					____array_62, -- 737
					____React_createElement_61(__TS__SparseArraySpread(____array_60)) -- 737
				) -- 737
				return ____React_createElement_63(__TS__SparseArraySpread(____array_62)) -- 705
			end)() -- 695
		else -- 695
			____createOpen_64 = nil -- 740
		end -- 740
		__TS__SparseArrayPush( -- 740
			____array_69, -- 740
			____React_createElement_67( -- 740
				"node", -- 740
				____temp_65, -- 740
				____createOpen_47, -- 740
				____temp_48, -- 740
				____temp_49, -- 740
				____React_createElement_53_result_66, -- 740
				____temp_55, -- 740
				____syncConfirmation_56, -- 740
				____createOpen_64 -- 740
			) -- 740
		) -- 740
		local ____projectIndexOpen_68 -- 742
		if projectIndexOpen then -- 742
			____projectIndexOpen_68 = React.createElement( -- 742
				ProjectIndex, -- 742
				{ -- 742
					entries = entries(), -- 742
					kind = tab, -- 742
					current = current(), -- 742
					x = left, -- 742
					y = bottom, -- 742
					width = usableWidth, -- 742
					height = usableHeight, -- 742
					zh = zh, -- 742
					refreshing = catalogSyncing, -- 742
					refreshStatus = catalogStatus, -- 742
					onRefresh = syncDiscover and (function() return refreshDiscover(true) end) or nil, -- 742
					onStatusReady = function(____, update) -- 742
						catalogStatusView = update -- 745
					end, -- 745
					onClose = function() -- 745
						projectIndexOpen = false -- 746
						render() -- 746
					end, -- 746
					onSelect = function(____, entry) -- 746
						projectIndexOpen = false -- 748
						local location = resolveFeedLocation(____local, discover, entry) -- 749
						tab = location.tab -- 750
						index = location.index -- 750
						render() -- 751
					end -- 747
				} -- 747
			) -- 747
		else -- 747
			____projectIndexOpen_68 = nil -- 752
		end -- 752
		__TS__SparseArrayPush(____array_69, ____projectIndexOpen_68) -- 752
		local scene = ____toNode_71(____React_createElement_70(__TS__SparseArraySpread(____array_69))) -- 517
		if scene ~= nil then -- 517
			host:addChild(scene) -- 754
		end -- 754
		if keptInput and createPanelRef.current then -- 754
			keptInput.position = Vec2( -- 756
				20, -- 756
				math.min(createSheetHeight, usableHeight - 64) - createInputTop - createInputHeight -- 756
			) -- 756
			createPanelRef.current:addChild(keptInput) -- 757
		end -- 757
		createInput.refresh() -- 759
		if restoreFocus and not keptInput and createOpen then -- 759
			createInput.focus(false) -- 760
		end -- 760
	end -- 462
	attachGamepad( -- 763
		host, -- 763
		{ -- 763
			initialTag = "mobile-feed-play", -- 764
			isEnabled = function() return isActive() and not packagePanel and not preparing and not transitioning and not creating end, -- 765
			onActive = function() -- 766
				gamepadUsed = true -- 766
				render() -- 766
			end, -- 766
			onBack = function() -- 767
				if managementOpen then -- 767
					closeManagement() -- 767
				elseif syncConfirmation then -- 767
					dismissSyncConfirmation() -- 767
				elseif createInput.isFocused() then -- 767
					blurCreateInput() -- 767
				elseif createOpen then -- 767
					closeCreate() -- 767
				else -- 767
					switchMode() -- 767
				end -- 767
			end, -- 767
			onActivate = function(target) -- 768
				if target.tag == "mobile-project-create-input" then -- 768
					target:emit("GamepadActivate") -- 769
				else -- 769
					if createInput.isComposing() then -- 769
						blurCreateInput() -- 771
						return -- 771
					end -- 771
					blurCreateInput() -- 772
					dismissedCreateComposition = false -- 773
					target:emit("Tapped") -- 774
				end -- 774
			end, -- 768
			onButton = function(button) -- 777
				if createOpen or syncConfirmation or managementOpen then -- 777
					return false -- 778
				end -- 778
				repeat -- 778
					local ____switch163 = button -- 778
					local ____cond163 = ____switch163 == "dpup" -- 778
					if ____cond163 then -- 778
						commit("previous") -- 780
						return true -- 780
					end -- 780
					____cond163 = ____cond163 or ____switch163 == "dpdown" -- 780
					if ____cond163 then -- 780
						commit("next") -- 781
						return true -- 781
					end -- 781
					____cond163 = ____cond163 or ____switch163 == "leftshoulder" -- 781
					if ____cond163 then -- 781
						setTab("discover") -- 782
						return true -- 782
					end -- 782
					____cond163 = ____cond163 or ____switch163 == "rightshoulder" -- 782
					if ____cond163 then -- 782
						setTab("local") -- 783
						return true -- 783
					end -- 783
					____cond163 = ____cond163 or ____switch163 == "x" -- 783
					if ____cond163 then -- 783
						commit("remix") -- 784
						return true -- 784
					end -- 784
					____cond163 = ____cond163 or ____switch163 == "y" -- 784
					if ____cond163 then -- 784
						local ____opt_72 = findGamepadNode(host, "mobile-feed-create") -- 784
						if ____opt_72 ~= nil then -- 784
							____opt_72:emit("Tapped") -- 785
						end -- 785
						return true -- 785
					end -- 785
					____cond163 = ____cond163 or ____switch163 == "start" -- 785
					if ____cond163 then -- 785
						openProjectIndex() -- 786
						return true -- 786
					end -- 786
					do -- 786
						return false -- 787
					end -- 787
				until true -- 787
			end -- 777
		} -- 777
	) -- 777
	host:onAppChange(function(setting) -- 791
		if setting == "Locale" then -- 791
			local activeEntry = current() -- 793
			managementOpen = false -- 794
			zh = (string.match(App.locale, "^zh")) ~= nil -- 795
			____local = getLocalEntries() -- 796
			discover = getDiscoverEntries() -- 797
			local location = resolveFeedLocation(____local, discover, activeEntry) -- 798
			tab = location.tab -- 799
			index = location.index -- 800
			render() -- 801
		elseif setting == "Size" then -- 801
			render() -- 802
		end -- 802
	end) -- 791
	host:onAppEvent(function(event) -- 804
		if event == "BackButton" then -- 804
			if managementOpen then -- 804
				closeManagement() -- 806
			elseif syncConfirmation then -- 806
				dismissSyncConfirmation() -- 807
			elseif projectIndexOpen then -- 807
				projectIndexOpen = false -- 808
				render() -- 808
			elseif createOpen and not creating then -- 808
				closeCreate() -- 809
			end -- 809
		elseif event == "WillEnterBackground" or event == "DidEnterBackground" then -- 809
			blurCreateInput() -- 810
		end -- 810
	end) -- 804
	host:onCleanup(function() -- 812
		blurCreateInput() -- 812
		active = false -- 812
		if packagePanel ~= nil then -- 812
			packagePanel:removeFromParent(true) -- 812
		end -- 812
		packagePanel = nil -- 812
	end) -- 812
	host:slot( -- 813
		"RestoreFeedEntry", -- 813
		function(entry) -- 813
			if not isActive() or HttpServer.wsConnectionCount > 0 then -- 813
				return -- 814
			end -- 814
			managementOpen = false -- 815
			returnEntry = entry -- 816
			____local = getLocalEntries() -- 817
			discover = getDiscoverEntries() -- 818
			local location = resolveFeedLocation(____local, discover, entry) -- 819
			tab = location.tab -- 820
			index = location.index -- 821
			render() -- 822
		end -- 813
	) -- 813
	host:slot("SuspendLocalUI", blurCreateInput) -- 824
	host:slot( -- 825
		"ResumeLocalUI", -- 825
		function() -- 825
			leaving = false -- 825
			render() -- 825
		end -- 825
	) -- 825
	refreshDiscover = function(force) -- 826
		if not syncDiscover or catalogSyncing or not isActive() then -- 826
			return -- 827
		end -- 827
		catalogSyncing = true -- 828
		catalogStatus = zh and "正在同步资源目录…" or "Syncing Catalog…" -- 829
		if #discover == 0 then -- 829
			discoverError = catalogStatus -- 831
		end -- 831
		render() -- 833
		syncDiscover( -- 834
			function(message) -- 834
				if not isActive() then -- 834
					return -- 835
				end -- 835
				catalogStatus = message -- 836
				if catalogStatusView ~= nil then -- 836
					catalogStatusView(message) -- 837
				end -- 837
				if projectIndexOpen or #discover > 0 then -- 837
					return -- 838
				end -- 838
				discoverError = message -- 839
				render() -- 840
			end, -- 834
			function(success, message) -- 841
				if not isActive() then -- 841
					return -- 842
				end -- 842
				catalogSyncing = false -- 843
				catalogStatus = success and (zh and "目录已更新" or "Catalog updated") or (zh and "刷新失败：" or "Refresh failed: ") .. (message or (zh and "请重试" or "Try again")) -- 844
				local ____force_78 -- 845
				if force then -- 845
					____force_78 = current() -- 845
				else -- 845
					____force_78 = returnEntry or rememberedEntries[tab] or current() -- 845
				end -- 845
				local selected = ____force_78 -- 845
				local previousCount = #discover -- 846
				discover = getDiscoverEntries() -- 847
				discoverError = success and (#discover == 0 and (zh and "目录中暂无可运行作品" or "No runnable Catalog games") or "") or (message or (zh and "资源目录同步失败" or "Catalog sync failed")) -- 848
				if not force and not projectIndexOpen then -- 848
					tab = resolveDiscoverRefreshTab( -- 853
						tab, -- 853
						userSelectedTab, -- 853
						previousCount, -- 853
						#discover, -- 853
						#____local -- 853
					) -- 853
				end -- 853
				if selected ~= nil then -- 853
					local location = resolveFeedLocation(____local, discover, selected) -- 855
					if location.tab == tab then -- 855
						index = location.index -- 856
					end -- 856
				end -- 856
				index = normalizeFeedIndex( -- 858
					index, -- 858
					#entries() -- 858
				) -- 858
				render() -- 859
			end, -- 841
			force -- 860
		) -- 860
	end -- 826
	render() -- 862
	refreshDiscover(false) -- 863
	return host -- 864
end -- 122
return ____exports -- 122