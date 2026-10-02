-- [tsx]: Feed.tsx
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayFind = ____lualib.__TS__ArrayFind -- 1
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
local colors = { -- 35
	background = 4278914322, -- 36
	panel = 4279572770, -- 37
	panelRaised = 4280297010, -- 38
	text = 4294242792, -- 39
	muted = 4289245117, -- 40
	brand = 4294954035, -- 41
	border = 4281613128, -- 42
	danger = 4294929259 -- 43
} -- 43
local fontName = "sarasa-mono-sc-regular" -- 46
local createSheetHeight = 304 -- 47
local createInputHeight = 44 -- 48
local createInputTop = 140 -- 49
local function conciseDescription(text, limit) -- 51
	local length = (utf8.len(text)) or 0 -- 52
	if length <= limit then -- 52
		return text -- 53
	end -- 53
	local stop = utf8.offset(text, limit + 1) or #text + 1 -- 54
	return string.sub(text, 1, stop - 1) .. "…" -- 55
end -- 51
local function formatTransferBytes(bytes) -- 58
	if bytes < 1024 then -- 58
		return tostring(math.floor(bytes)) .. " B" -- 59
	end -- 59
	local value = bytes -- 60
	local units = {"KiB", "MiB", "GiB", "TiB"} -- 61
	for ____, unit in ipairs(units) do -- 62
		value = value / 1024 -- 63
		if value < 1024 or unit == "TiB" then -- 63
			return (string.format("%.1f", value) .. " ") .. unit -- 64
		end -- 64
	end -- 64
	return tostring(math.floor(bytes)) .. " B" -- 66
end -- 58
local function Cover(props) -- 69
	local file = props.entry.bannerFile -- 70
	local function scaleSprite(sprite, mode) -- 71
		local scales = getCoverScales(sprite.width, sprite.height, props.width, props.height) -- 72
		sprite.scaleX = scales[mode] -- 73
		sprite.scaleY = scales[mode] -- 74
	end -- 71
	local ____React_createElement_5 = React.createElement -- 71
	local ____temp_3 = { -- 71
		x = props.x, -- 71
		y = props.y, -- 71
		width = props.width, -- 71
		height = props.height, -- 71
		anchorX = 0, -- 71
		anchorY = 0 -- 71
	} -- 71
	local ____React_createElement_result_4 = React.createElement( -- 71
		RoundedSurface, -- 77
		{ -- 77
			width = props.width, -- 77
			height = props.height, -- 77
			radius = 22, -- 77
			topColor = stableCoverColor(props.entry.id), -- 77
			bottomColor = 4279310115, -- 77
			shadow = true -- 77
		} -- 77
	) -- 77
	local ____file_0 -- 79
	if file then -- 79
		____file_0 = React.createElement( -- 79
			"clip-node", -- 79
			{ -- 79
				width = props.width, -- 79
				height = props.height, -- 79
				anchorX = 0, -- 79
				anchorY = 0, -- 79
				stencil = React.createElement(RoundedStencil, {width = props.width, height = props.height, radius = 22}) -- 79
			}, -- 79
			React.createElement( -- 79
				"sprite", -- 79
				{ -- 79
					file = file, -- 79
					x = props.width / 2 - 5, -- 79
					y = props.height / 2, -- 79
					opacity = 0.08, -- 79
					onMount = function(sprite) return scaleSprite(sprite, "cover") end -- 79
				} -- 79
			), -- 79
			React.createElement( -- 79
				"sprite", -- 79
				{ -- 79
					file = file, -- 79
					x = props.width / 2 + 5, -- 79
					y = props.height / 2, -- 79
					opacity = 0.08, -- 79
					onMount = function(sprite) return scaleSprite(sprite, "cover") end -- 79
				} -- 79
			), -- 79
			React.createElement( -- 79
				"sprite", -- 79
				{ -- 79
					file = file, -- 79
					x = props.width / 2, -- 79
					y = props.height / 2 - 5, -- 79
					opacity = 0.08, -- 79
					onMount = function(sprite) return scaleSprite(sprite, "cover") end -- 79
				} -- 79
			), -- 79
			React.createElement( -- 79
				"draw-node", -- 79
				{x = props.width / 2, y = props.height / 2}, -- 79
				React.createElement("rect-shape", {width = props.width, height = props.height, fillColor = 2953514258}) -- 79
			), -- 79
			React.createElement( -- 79
				"sprite", -- 79
				{ -- 79
					file = file, -- 79
					x = props.width / 2, -- 79
					y = props.height / 2, -- 79
					onMount = function(sprite) return scaleSprite(sprite, "contain") end -- 79
				} -- 79
			) -- 79
		) -- 79
	else -- 79
		____file_0 = React.createElement( -- 79
			"label", -- 79
			{ -- 79
				x = props.width / 2, -- 79
				y = props.height / 2 + 10, -- 79
				fontName = fontName, -- 79
				fontSize = math.floor(math.max( -- 79
					22, -- 91
					math.min(34, props.width / 12) -- 91
				)), -- 91
				text = props.entry.title, -- 91
				textWidth = props.width - 40, -- 91
				color3 = 16052712 -- 91
			} -- 91
		) -- 91
	end -- 91
	local ____file_1 -- 96
	if file then -- 96
		____file_1 = nil -- 96
	else -- 96
		____file_1 = React.createElement("label", { -- 96
			x = props.width / 2, -- 96
			y = 30, -- 96
			fontName = fontName, -- 96
			fontSize = 14, -- 96
			text = "DORA SSR · REMIXABLE", -- 96
			color3 = 16763955 -- 96
		}) -- 96
	end -- 96
	local ____file_2 -- 104
	if file then -- 104
		____file_2 = nil -- 104
	else -- 104
		____file_2 = React.createElement(DoraMascot, {state = "idle", x = props.width - 46, y = 64, size = 42}) -- 104
	end -- 104
	return ____React_createElement_5( -- 76
		"node", -- 76
		____temp_3, -- 76
		____React_createElement_result_4, -- 76
		____file_0, -- 76
		____file_1, -- 76
		____file_2, -- 76
		React.createElement(RoundedSurface, { -- 76
			width = props.width, -- 76
			height = props.height, -- 76
			radius = 22, -- 76
			fillColor = 0, -- 76
			borderWidth = 1, -- 76
			borderColor = 4282074454 -- 76
		}) -- 76
	) -- 76
end -- 69
function ____exports.startMobileFeed(options) -- 109
	local submitCreate, render, refreshDiscover -- 109
	local getLocalEntries = options.getLocalEntries -- 110
	local getDiscoverEntries = options.getDiscoverEntries -- 111
	local onPlay = options.onPlay -- 112
	local onRemix = options.onRemix -- 113
	local prepare = options.prepare -- 114
	local syncDiscover = options.syncDiscover -- 115
	local canShare = App.platform == "Android" or App.platform == "iOS" -- 116
	local zh = (string.match(App.locale, "^zh")) ~= nil -- 117
	local tab = "local" -- 118
	local index = 0 -- 119
	local drag = Vec2.zero -- 120
	local dragAxis = "none" -- 121
	local discoverError = "" -- 122
	local preparing = false -- 123
	local transitioning = false -- 124
	local prepareStatus = "" -- 125
	local prepareProgress = 0 -- 126
	local prepareTransferredBytes = 0 -- 127
	local prepareCanceled = false -- 128
	local catalogSyncing = false -- 129
	local catalogStatus = "" -- 130
	local catalogStatusView -- 131
	local repairResourceId = "" -- 132
	local userSelectedTab = false -- 133
	local active = true -- 134
	local leaving = false -- 135
	local packagePanel -- 136
	local createOpen = false -- 137
	local projectIndexOpen = false -- 138
	local creating = false -- 139
	local createName = "" -- 140
	local createLanguage = "typescript" -- 141
	local dismissedCreateComposition = false -- 142
	local createError = "" -- 143
	local gamepadUsed = false -- 144
	local returnEntry = options.initialEntry -- 145
	local ____opt_6 = options.initialEntries -- 145
	local ____temp_10 = ____opt_6 and ____opt_6["local"] -- 147
	local ____opt_8 = options.initialEntries -- 147
	local rememberedEntries = {["local"] = ____temp_10, discover = ____opt_8 and ____opt_8.discover} -- 146
	local cardRef = reference() -- 150
	local indexRef = reference() -- 151
	local createInputRef = reference() -- 152
	local discover = getDiscoverEntries() -- 153
	local ____local = getLocalEntries() -- 154
	if #discover == 0 then -- 154
		discoverError = zh and "资源目录暂不可用" or "Catalog is unavailable" -- 157
	end -- 157
	local initialLocation = resolveFeedLocation(____local, discover, returnEntry) -- 159
	tab = initialLocation.tab -- 160
	index = initialLocation.index -- 161
	local host = Node() -- 163
	host.tag = "mobile-feed" -- 164
	host.scaleX = App.devicePixelRatio -- 165
	host.scaleY = App.devicePixelRatio -- 166
	host:addTo(Director.systemUI) -- 167
	local function isActive() -- 169
		return active and not leaving and host.parent ~= nil -- 169
	end -- 169
	local function entries() -- 171
		return tab == "discover" and discover or ____local -- 171
	end -- 171
	local function current() -- 172
		return entries()[normalizeFeedIndex( -- 172
			index, -- 172
			#entries() -- 172
		) + 1] -- 172
	end -- 172
	local rememberedEntryKey = "" -- 173
	local function rememberCurrent() -- 174
		local item = current() -- 175
		if not item or not options.onCurrentEntryChanged then -- 175
			return -- 176
		end -- 176
		local key = (((((item.kind .. "\n") .. item.id) .. "\n") .. (item.workDir or "")) .. "\n") .. (item.fileName or "") -- 177
		if key == rememberedEntryKey then -- 177
			return -- 178
		end -- 178
		rememberedEntryKey = key -- 179
		rememberedEntries[item.kind] = item -- 180
		options.onCurrentEntryChanged(item) -- 181
	end -- 174
	local function canEditCreate() -- 183
		return createOpen and not creating and isActive() and host.visible and HttpServer.wsConnectionCount == 0 -- 183
	end -- 183
	local createInput = createTextInput({ -- 184
		fontSize = math.floor(16 * mobileFontScale), -- 185
		singleLine = true, -- 186
		background = colors.background, -- 187
		getText = function() return createName end, -- 188
		setText = function(text) -- 189
			createName = text -- 189
		end, -- 189
		getPlaceholder = function() return zh and "例如：星际花园" or "For example: Star Garden" end, -- 190
		isEnabled = canEditCreate, -- 191
		onReturn = function() -- 192
			submitCreate() -- 192
			return true -- 192
		end -- 192
	}) -- 192
	local blurCreateInput = createInput.blur -- 194
	local function closeCreate() -- 195
		if creating then -- 195
			return -- 196
		end -- 196
		blurCreateInput() -- 197
		createOpen = false -- 198
		createName = "" -- 199
		createError = "" -- 200
		render() -- 201
	end -- 195
	local function openCreate() -- 203
		if not options.createProject or preparing or transitioning or creating or createOpen or HttpServer.wsConnectionCount > 0 then -- 203
			return -- 204
		end -- 204
		projectIndexOpen = false -- 205
		createOpen = true -- 206
		createLanguage = "typescript" -- 207
		createName = "" -- 208
		dismissedCreateComposition = false -- 209
		createError = "" -- 210
		render() -- 211
		createInput.deferFocus() -- 212
	end -- 203
	local function openProjectIndex() -- 214
		if preparing or transitioning or creating or createOpen or HttpServer.wsConnectionCount > 0 then -- 214
			return -- 215
		end -- 215
		if tab == "local" then -- 215
			____local = getLocalEntries() -- 216
		end -- 216
		projectIndexOpen = true -- 217
		render() -- 218
	end -- 214
	local function createErrorText(____error) -- 220
		repeat -- 220
			local ____switch36 = ____error -- 220
			local ____cond36 = ____switch36 == "invalid-name" -- 220
			if ____cond36 then -- 220
				return zh and "请输入不含路径分隔符的项目名称" or "Enter a project name without path separators" -- 222
			end -- 222
			____cond36 = ____cond36 or ____switch36 == "target-existed" -- 222
			if ____cond36 then -- 222
				return zh and "已有同名项目，请换一个名称" or "A project with that name already exists" -- 223
			end -- 223
			____cond36 = ____cond36 or ____switch36 == "create-folder-failed" -- 223
			if ____cond36 then -- 223
				return zh and "无法创建项目目录，请检查工作目录后重试" or "Could not create the project folder; check the workspace and retry" -- 224
			end -- 224
			____cond36 = ____cond36 or ____switch36 == "create-entry-failed" -- 224
			if ____cond36 then -- 224
				return zh and "无法写入项目入口，未完成项目已回滚" or "Could not write the project entry; the incomplete project was rolled back" -- 225
			end -- 225
			____cond36 = ____cond36 or ____switch36 == "created-project-not-found" -- 225
			if ____cond36 then -- 225
				return zh and "项目已创建，但本地列表未能找到它，请返回后重试" or "The project was created but could not be found in Local; return and retry" -- 226
			end -- 226
			do -- 226
				return zh and "创建失败，请重试" or "Project creation failed; try again" -- 227
			end -- 227
		until true -- 227
	end -- 220
	submitCreate = function() -- 230
		if not options.createProject or creating or not createOpen or not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 then -- 230
			return -- 231
		end -- 231
		if createInput.isComposing() then -- 231
			return -- 232
		end -- 232
		creating = true -- 233
		createError = "" -- 234
		blurCreateInput() -- 235
		render() -- 236
		local result = options.createProject(createName, createLanguage) -- 237
		if not isActive() then -- 237
			return -- 238
		end -- 238
		creating = false -- 239
		if not result.success then -- 239
			createError = createErrorText(result.error) -- 241
			render() -- 242
			return -- 243
		end -- 243
		createOpen = false -- 245
		createName = "" -- 246
		____local = getLocalEntries() -- 247
		returnEntry = result.entry -- 248
		local location = resolveFeedLocation(____local, discover, result.entry) -- 249
		tab = location.tab -- 250
		index = location.index -- 251
		render() -- 252
		onRemix(result.entry) -- 253
	end -- 230
	local function openPackage(mode, path, pickOnOpen) -- 256
		if pickOnOpen == nil then -- 256
			pickOnOpen = false -- 256
		end -- 256
		if not isActive() or not host.visible or packagePanel or preparing or transitioning or creating or createOpen or HttpServer.wsConnectionCount > 0 then -- 256
			return -- 257
		end -- 257
		projectIndexOpen = false -- 258
		packagePanel = startPackagePanel({ -- 259
			mode = mode, -- 260
			path = path, -- 260
			pickOnOpen = pickOnOpen, -- 260
			entry = current(), -- 260
			onNew = openCreate, -- 261
			onClosed = function() -- 262
				packagePanel = nil -- 262
			end, -- 262
			onImported = function(entry, play) -- 263
				if not isActive() then -- 263
					return -- 264
				end -- 264
				____local = getLocalEntries(entry.workDir) -- 265
				local imported = __TS__ArrayFind( -- 266
					____local, -- 266
					function(____, item) return item.workDir == entry.workDir end -- 266
				) or entry -- 266
				returnEntry = imported -- 267
				local location = resolveFeedLocation(____local, discover, imported) -- 268
				tab = "local" -- 269
				index = location.index -- 269
				render() -- 270
				if play then -- 270
					onPlay(imported) -- 271
				end -- 271
			end -- 263
		}) -- 263
	end -- 256
	local receiveElapsed = 0 -- 275
	host:schedule(function(dt) -- 276
		receiveElapsed = receiveElapsed + dt -- 277
		if receiveElapsed < 0.5 then -- 277
			return false -- 278
		end -- 278
		receiveElapsed = 0 -- 279
		if isActive() and host.visible and not packagePanel and not createOpen and not projectIndexOpen and not preparing and not transitioning and HttpServer.wsConnectionCount == 0 then -- 279
			local path = options.takeReceivedFile and options.takeReceivedFile() or App:takeReceivedFile() -- 281
			if path ~= "" then -- 281
				openPackage("receive", path) -- 282
			end -- 282
		end -- 282
		return false -- 284
	end) -- 276
	local function setTab(next) -- 287
		if not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 or preparing or creating then -- 287
			return -- 288
		end -- 288
		userSelectedTab = true -- 289
		returnEntry = nil -- 290
		if tab == next then -- 290
			return -- 291
		end -- 291
		if createOpen then -- 291
			blurCreateInput() -- 293
			createOpen = false -- 294
			createName = "" -- 295
			createError = "" -- 296
		end -- 296
		tab = next -- 298
		local target = rememberedEntries[next] -- 299
		local ____temp_11 -- 300
		if target == nil then -- 300
			____temp_11 = nil -- 300
		else -- 300
			____temp_11 = resolveFeedLocation(____local, discover, target) -- 300
		end -- 300
		local location = ____temp_11 -- 300
		index = (location and location.tab) == next and location.index or 0 -- 301
		render() -- 302
	end -- 287
	local function activate(action) -- 304
		local item = current() -- 305
		if not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 or not item or preparing then -- 305
			return -- 306
		end -- 306
		if item.webPlayUrl then -- 306
			local url = action == "play" and item.webPlayUrl or item.sourceUrl -- 308
			if url then -- 308
				App:openURL(url) -- 309
			end -- 309
			return -- 310
		end -- 310
		item.launchError = nil -- 312
		local function done() -- 313
			returnEntry = item -- 313
			local ____temp_14 -- 313
			if action == "play" then -- 313
				____temp_14 = onPlay(item) -- 313
			else -- 313
				____temp_14 = onRemix(item) -- 313
			end -- 313
			return ____temp_14 -- 313
		end -- 313
		if item.kind == "local" or item.installed then -- 313
			done() -- 314
			return -- 314
		end -- 314
		preparing = true -- 315
		prepareProgress = 0 -- 316
		prepareTransferredBytes = 0 -- 317
		prepareCanceled = false -- 318
		prepareStatus = zh and "准备安装…" or "Preparing install…" -- 319
		render() -- 320
		local repairIncomplete = repairResourceId == item.id -- 321
		repairResourceId = "" -- 322
		prepare( -- 323
			item, -- 323
			repairIncomplete, -- 323
			function(progress, message, transferredBytes) -- 323
				if not isActive() then -- 323
					return -- 324
				end -- 324
				prepareProgress = math.max( -- 325
					0, -- 325
					math.min(1, progress) -- 325
				) -- 325
				if transferredBytes ~= nil then -- 325
					prepareTransferredBytes = math.max(prepareTransferredBytes, transferredBytes) -- 326
				end -- 326
				prepareStatus = message -- 327
				render() -- 328
			end, -- 323
			function(success, ready, message, repairable) -- 329
				if not isActive() then -- 329
					return -- 330
				end -- 330
				preparing = false -- 331
				if not success or not ready then -- 331
					repairResourceId = repairable and item.id or "" -- 333
					prepareStatus = message or (zh and "安装失败，点击按钮重试" or "Install failed; tap to retry") -- 334
					render() -- 335
					return -- 336
				end -- 336
				item.fileName = ready.fileName -- 338
				item.workDir = ready.workDir -- 339
				item.installed = true -- 340
				prepareStatus = "" -- 341
				if HttpServer.wsConnectionCount == 0 and host.visible then -- 341
					done() -- 342
				else -- 342
					render() -- 343
				end -- 343
			end, -- 329
			function() return prepareCanceled end -- 344
		) -- 344
	end -- 304
	local function cancelPrepare() -- 346
		if not preparing or prepareCanceled then -- 346
			return -- 347
		end -- 347
		prepareCanceled = true -- 348
		prepareStatus = zh and "正在中断下载…" or "Canceling download…" -- 349
		render() -- 350
	end -- 346
	local function commit(action) -- 353
		if not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 or preparing or transitioning then -- 353
			return -- 354
		end -- 354
		if action == "play" or action == "remix" then -- 354
			local card = cardRef.current -- 356
			if card then -- 356
				card.position = Vec2.zero -- 357
			end -- 357
		end -- 357
		repeat -- 357
			local ____switch78 = action -- 357
			local ____cond78 = ____switch78 == "previous" or ____switch78 == "next" -- 357
			if ____cond78 then -- 357
				do -- 357
					returnEntry = nil -- 362
					local target = normalizeFeedIndex( -- 363
						index + (action == "next" and 1 or -1), -- 363
						#entries() -- 363
					) -- 363
					if target == index then -- 363
						local card = cardRef.current -- 365
						if card then -- 365
							card:perform(Move(App.reducedMotion and 0 or 0.16, card.position, Vec2.zero, Ease.OutQuad)) -- 366
						end -- 366
						return -- 367
					end -- 367
					local duration = App.reducedMotion and 0 or 0.18 -- 369
					local function finish() -- 370
						if not isActive() then -- 370
							return -- 371
						end -- 371
						index = target -- 372
						transitioning = false -- 373
						App:vibrate(0.012) -- 374
						render() -- 375
					end -- 370
					local card = cardRef.current -- 377
					if duration > 0 and card then -- 377
						transitioning = true -- 379
						card:perform(Move( -- 380
							duration, -- 380
							card.position, -- 380
							Vec2(0, (action == "next" and 1 or -1) * App.safeArea.height), -- 380
							Ease.OutQuad -- 380
						)) -- 380
						thread(function() -- 381
							sleep(duration) -- 381
							finish() -- 381
						end) -- 381
					else -- 381
						finish() -- 382
					end -- 382
					return -- 383
				end -- 383
			end -- 383
			____cond78 = ____cond78 or ____switch78 == "play" -- 383
			if ____cond78 then -- 383
				activate("play") -- 385
				return -- 385
			end -- 385
			____cond78 = ____cond78 or ____switch78 == "remix" -- 385
			if ____cond78 then -- 385
				activate("remix") -- 386
				return -- 386
			end -- 386
			do -- 386
				return -- 387
			end -- 387
		until true -- 387
	end -- 353
	local function switchMode() -- 391
		if not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 or preparing or creating or createOpen or packagePanel or transitioning or not options.onSwitchMode then -- 391
			return -- 392
		end -- 392
		leaving = true -- 393
		options.onSwitchMode() -- 394
	end -- 391
	host:slot("SwitchUIMode", switchMode) -- 396
	render = function() -- 397
		if not isActive() then -- 397
			return -- 398
		end -- 398
		catalogStatusView = nil -- 399
		local safeContentWidth = App.safeArea.width - 40 -- 401
		local shortLandscapeInputWidth = safeContentWidth - 12 - math.min( -- 402
			300, -- 402
			math.floor(safeContentWidth * 0.42) -- 402
		) -- 402
		local expectedInputWidth = App.safeArea.width >= 760 and App.safeArea.height < 500 and shortLandscapeInputWidth or safeContentWidth -- 403
		local ____createOpen_17 = createOpen -- 404
		if ____createOpen_17 then -- 404
			local ____opt_15 = createInputRef.current -- 404
			____createOpen_17 = (____opt_15 and ____opt_15.width) == expectedInputWidth -- 404
		end -- 404
		local keptInput = ____createOpen_17 and createInputRef.current or nil -- 404
		local restoreFocus = createInput.isFocused() -- 405
		if keptInput ~= nil then -- 405
			keptInput:removeFromParent(false) -- 406
		end -- 406
		if not keptInput then -- 406
			createInput.unmount() -- 408
			createInputRef = reference() -- 409
		end -- 409
		local createPanelRef = reference() -- 411
		host:removeAllChildren() -- 412
		host.scaleX = App.devicePixelRatio -- 413
		host.scaleY = App.devicePixelRatio -- 414
		local ____App_visualSize_20 = App.visualSize -- 415
		local width = ____App_visualSize_20.width -- 415
		local height = ____App_visualSize_20.height -- 415
		local safe = App.safeArea -- 416
		local left = safe.left -- 417
		local bottom = safe.bottom -- 418
		local usableWidth = safe.width -- 419
		local usableHeight = safe.height -- 420
		local wide = usableWidth >= 760 -- 421
		local shortLandscape = wide and usableHeight < 500 -- 422
		local compact = not wide and usableHeight < 700 -- 423
		local compactLandscape = compact and usableWidth > usableHeight and usableHeight < 520 -- 424
		local landscapeTopLift = shortLandscape and 28 or 0 -- 425
		local data = entries() -- 426
		index = normalizeFeedIndex(index, #data) -- 427
		local item = current() -- 428
		rememberCurrent() -- 429
		local coverWidth = wide and math.min(usableWidth * 0.54, 680) or usableWidth - 32 -- 430
		local coverHeight = wide and math.min(usableHeight - 118, coverWidth * 0.72) or (compact and math.min(usableHeight * (compactLandscape and 0.43 or 0.49), coverWidth * 0.72) or math.min(usableHeight * 0.54, coverWidth * 1.12)) -- 431
		local coverX = left + 16 -- 436
		local coverY = wide and bottom + (usableHeight - coverHeight) / 2 - 12 + landscapeTopLift or bottom + usableHeight - coverHeight - 82 -- 437
		local infoX = wide and coverX + coverWidth + 28 or left + 20 -- 438
		local infoWidth = wide and usableWidth - coverWidth - 72 or usableWidth - 40 -- 439
		local infoTop = wide and bottom + usableHeight - 122 + landscapeTopLift or coverY - (compactLandscape and 28 or 30) -- 440
		local descriptionY = infoTop - (compactLandscape and 38 or 58) -- 441
		local metadataY = infoTop - (wide and 136 or 118) -- 442
		local actionsY = bottom + (compactLandscape and 18 or 24) -- 443
		local gestureHintY = bottom + (compactLandscape and 88 or 92) -- 444
		local buttonWidth = wide and math.min(190, (infoWidth - 12) / 2) or (infoWidth - 12) / 2 -- 445
		local fontScale = mobileFontScale -- 446
		local cardIndices = getReusableCardIndices(index, #data) -- 447
		local headerRenderOrder = 1000 -- 448
		local ____toNode_59 = toNode -- 450
		local ____React_createElement_58 = React.createElement -- 450
		local ____array_57 = __TS__SparseArrayNew( -- 450
			"node", -- 450
			{ -- 450
				tag = "mobile-feed-scene", -- 450
				x = -width / 2, -- 450
				y = -height / 2, -- 450
				width = width, -- 450
				height = height, -- 450
				anchorX = 0, -- 450
				anchorY = 0, -- 450
				touchEnabled = true, -- 450
				onTapBegan = function() -- 450
					drag = Vec2.zero -- 460
					dragAxis = "none" -- 461
					local ____opt_21 = cardRef.current -- 461
					if ____opt_21 ~= nil then -- 461
						____opt_21:stopAllActions() -- 462
					end -- 462
					if indexRef.current then -- 462
						indexRef.current.opacity = 1 -- 463
					end -- 463
				end, -- 459
				onTapMoved = function(touch) -- 459
					drag = drag:add(touch.delta) -- 466
					if dragAxis == "none" and math.max( -- 466
						math.abs(drag.x), -- 467
						math.abs(drag.y) -- 467
					) >= 12 then -- 467
						dragAxis = math.abs(drag.x) > math.abs(drag.y) * 1.2 and "horizontal" or "vertical" -- 468
					end -- 468
					if cardRef.current then -- 468
						local offset = dragAxis == "horizontal" and Vec2(drag.x * 0.18, 0) or (dragAxis == "vertical" and Vec2(0, drag.y * 0.12) or Vec2.zero) -- 471
						cardRef.current.position = offset -- 472
						if indexRef.current then -- 472
							local headerBottom = bottom + usableHeight - 72 -- 474
							local indexTop = coverY + coverHeight - 14 + offset.y -- 475
							indexRef.current.opacity = dragAxis == "vertical" and math.max( -- 476
								0, -- 477
								math.min(1, (headerBottom - indexTop) / 16) -- 477
							) or 1 -- 477
						end -- 477
					end -- 477
				end, -- 465
				onTapEnded = function() -- 465
					local action = resolveFeedGesture(drag.x, drag.y, usableWidth, usableHeight) -- 483
					drag = Vec2.zero -- 484
					dragAxis = "none" -- 485
					if indexRef.current then -- 485
						indexRef.current.opacity = 1 -- 486
					end -- 486
					if action == "none" and cardRef.current then -- 486
						local card = cardRef.current -- 488
						card:perform(Move(App.reducedMotion and 0 or 0.16, card.position, Vec2.zero, Ease.OutQuad)) -- 489
					end -- 489
					commit(action) -- 491
				end, -- 482
				onMouseWheel = function(delta) return commit(delta.y > 0 and "previous" or "next") end -- 482
			}, -- 482
			React.createElement(VerticalGradient, {width = width, height = height, topColor = 4279310117, bottomColor = 4278716943}) -- 482
		) -- 482
		local ____React_createElement_55 = React.createElement -- 482
		local ____temp_53 = {visible = not projectIndexOpen} -- 482
		local ____createOpen_38 -- 497
		if createOpen then -- 497
			____createOpen_38 = nil -- 497
		else -- 497
			local ____temp_37 -- 497
			if item ~= nil then -- 497
				local ____React_createElement_36 = React.createElement -- 497
				local ____array_35 = __TS__SparseArrayNew( -- 497
					"node", -- 497
					{tag = "mobile-feed-card-" .. item.id, ref = cardRef, key = (tab .. "-") .. item.id}, -- 497
					__TS__ArrayMap( -- 498
						cardIndices, -- 498
						function(____, cardIndex) return React.createElement(Cover, { -- 498
							key = (tab .. "-") .. data[cardIndex + 1].id, -- 498
							entry = data[cardIndex + 1], -- 498
							x = coverX, -- 498
							y = coverY + (index - cardIndex) * usableHeight, -- 498
							width = coverWidth, -- 498
							height = coverHeight -- 498
						}) end -- 498
					), -- 498
					React.createElement( -- 498
						"node", -- 498
						{ -- 498
							tag = "mobile-feed-index", -- 498
							ref = indexRef, -- 498
							order = 10, -- 498
							renderGroup = true, -- 498
							x = coverX + coverWidth - 62, -- 498
							y = coverY + coverHeight - 40, -- 498
							width = 48, -- 498
							height = 26, -- 498
							anchorX = 0, -- 498
							anchorY = 0, -- 498
							touchEnabled = true, -- 498
							swallowTouches = true, -- 498
							onTapped = openProjectIndex -- 498
						}, -- 498
						React.createElement( -- 498
							"clip-node", -- 498
							{ -- 498
								width = 48, -- 498
								height = 26, -- 498
								anchorX = 0, -- 498
								anchorY = 0, -- 498
								stencil = React.createElement(RoundedStencil, {width = 48, height = 26, radius = 13}) -- 498
							}, -- 498
							React.createElement( -- 498
								"draw-node", -- 498
								nil, -- 498
								React.createElement( -- 498
									"verts-shape", -- 498
									{verts = { -- 498
										{ -- 511
											Vec2(0, 0), -- 511
											3759281694 -- 511
										}, -- 511
										{ -- 511
											Vec2(48, 0), -- 511
											3759281694 -- 511
										}, -- 511
										{ -- 511
											Vec2(48, 26), -- 511
											3760730173 -- 511
										}, -- 511
										{ -- 512
											Vec2(0, 0), -- 512
											3759281694 -- 512
										}, -- 512
										{ -- 512
											Vec2(48, 26), -- 512
											3760730173 -- 512
										}, -- 512
										{ -- 512
											Vec2(0, 26), -- 512
											3760730173 -- 512
										} -- 512
									}} -- 512
								) -- 512
							) -- 512
						), -- 512
						React.createElement( -- 512
							"draw-node", -- 512
							{x = 0.5, y = 0.5}, -- 512
							React.createElement( -- 512
								"polygon-shape", -- 512
								{ -- 512
									verts = roundedRectVerts(47, 25, 12.5), -- 512
									fillColor = 0, -- 512
									borderWidth = 0.5, -- 512
									borderColor = 2286967404 -- 512
								} -- 512
							) -- 512
						), -- 512
						React.createElement( -- 512
							"draw-node", -- 512
							{x = 18, y = 2}, -- 512
							React.createElement( -- 512
								"polygon-shape", -- 512
								{ -- 512
									verts = roundedRectVerts(12, 2, 1), -- 512
									fillColor = colors.brand -- 512
								} -- 512
							) -- 512
						), -- 512
						React.createElement( -- 512
							"label", -- 512
							{ -- 512
								x = 24, -- 512
								y = 13, -- 512
								fontName = fontName, -- 512
								fontSize = 11, -- 512
								text = (tostring(index + 1) .. " / ") .. tostring(#data), -- 512
								color3 = 14146531 -- 512
							} -- 512
						) -- 512
					), -- 512
					React.createElement( -- 512
						"label", -- 512
						{ -- 512
							tag = "mobile-feed-current-title", -- 512
							x = infoX, -- 512
							y = infoTop, -- 512
							anchorX = 0, -- 512
							anchorY = 0.5, -- 512
							fontName = fontName, -- 512
							fontSize = math.floor((wide and 30 or 25) * fontScale), -- 512
							text = item.title, -- 512
							textWidth = infoWidth - (item.kind == "local" and canShare and 92 or 0), -- 512
							alignment = "Left", -- 512
							color3 = 16052712 -- 512
						} -- 512
					) -- 512
				) -- 512
				local ____temp_23 -- 521
				if item.kind == "local" and canShare then -- 521
					____temp_23 = React.createElement( -- 521
						MobileButton, -- 521
						{ -- 521
							tag = "mobile-feed-share", -- 521
							x = infoX + infoWidth - 84, -- 521
							y = infoTop - 18, -- 521
							width = 84, -- 521
							height = 36, -- 521
							text = zh and "分享作品" or "Share", -- 521
							fontSize = 13, -- 521
							onTapped = function() return openPackage("share") end -- 521
						} -- 521
					) -- 521
				else -- 521
					____temp_23 = nil -- 521
				end -- 521
				__TS__SparseArrayPush( -- 521
					____array_35, -- 521
					____temp_23, -- 521
					React.createElement( -- 521
						"label", -- 521
						{ -- 521
							tag = "mobile-feed-description", -- 521
							x = infoX, -- 521
							y = descriptionY, -- 521
							anchorX = 0, -- 521
							anchorY = 0.5, -- 521
							fontName = fontName, -- 521
							fontSize = math.floor(15 * fontScale), -- 521
							text = conciseDescription(item.description, wide and 80 or (compact and 28 or 42)), -- 521
							textWidth = infoWidth, -- 521
							alignment = "Left", -- 521
							color3 = 11055037 -- 521
						} -- 521
					) -- 521
				) -- 521
				local ____temp_24 -- 524
				if compact or shortLandscape then -- 524
					____temp_24 = nil -- 524
				else -- 524
					____temp_24 = React.createElement( -- 524
						"node", -- 524
						{ -- 524
							x = infoX, -- 524
							y = metadataY, -- 524
							width = wide and 176 or 164, -- 524
							height = 28, -- 524
							anchorX = 0, -- 524
							anchorY = 0 -- 524
						}, -- 524
						React.createElement(RoundedSurface, { -- 524
							width = wide and 176 or 164, -- 524
							height = 28, -- 524
							radius = 14, -- 524
							topColor = 1714436683, -- 524
							bottomColor = 1712857131, -- 524
							borderWidth = 1, -- 524
							borderColor = 2288020349 -- 524
						}), -- 524
						React.createElement("label", { -- 524
							x = 12, -- 524
							y = 14, -- 524
							anchorX = 0, -- 524
							fontName = fontName, -- 524
							fontSize = 12, -- 524
							text = item.webPlayUrl and (zh and "发现  ·  在线试玩" or "Discover  ·  Web game") or (item.kind == "local" and (zh and "本地作品  ·  可 Remix" or "Local  ·  Remixable") or (item.installed and (zh and "发现  ·  已安装" or "Discover  ·  Installed") or (zh and "发现  ·  可安装" or "Discover  ·  Installable"))), -- 524
							textWidth = (wide and 176 or 164) - 24, -- 524
							alignment = "Left", -- 524
							color3 = 14475754 -- 524
						}) -- 524
					) -- 524
				end -- 524
				__TS__SparseArrayPush(____array_35, ____temp_24) -- 524
				local ____preparing_33 -- 530
				if preparing then -- 530
					local ____React_createElement_32 = React.createElement -- 530
					local ____array_31 = __TS__SparseArrayNew( -- 530
						"node", -- 530
						{ -- 530
							tag = "mobile-feed-download", -- 530
							x = infoX, -- 530
							y = actionsY, -- 530
							width = infoWidth, -- 530
							height = 48, -- 530
							anchorX = 0, -- 530
							anchorY = 0 -- 530
						}, -- 530
						React.createElement("label", { -- 530
							x = 0, -- 530
							y = 38, -- 530
							anchorX = 0, -- 530
							fontName = fontName, -- 530
							fontSize = 14, -- 530
							text = zh and "正在下载" or "Downloading", -- 530
							color3 = 16763955 -- 530
						}), -- 530
						React.createElement( -- 530
							"label", -- 530
							{ -- 530
								tag = "mobile-feed-download-percent", -- 530
								x = infoWidth - 92, -- 530
								y = 38, -- 530
								anchorX = 1, -- 530
								fontName = fontName, -- 530
								fontSize = 14, -- 530
								text = (tostring(math.floor(prepareProgress * 100)) .. "%") .. (prepareTransferredBytes > 0 and " · " .. formatTransferBytes(prepareTransferredBytes) or ""), -- 530
								color3 = 16763955 -- 530
							} -- 530
						) -- 530
					) -- 530
					local ____React_createElement_30 = React.createElement -- 530
					local ____temp_28 = { -- 530
						tag = "mobile-feed-download-track", -- 530
						width = infoWidth - 92, -- 530
						height = 8, -- 530
						y = 8, -- 530
						anchorX = 0, -- 530
						anchorY = 0 -- 530
					} -- 530
					local ____React_createElement_result_29 = React.createElement(RoundedSurface, {width = infoWidth - 92, height = 8, radius = 4, fillColor = 4280889664}) -- 530
					local ____React_createElement_27 = React.createElement -- 530
					local ____temp_26 = { -- 530
						tag = "mobile-feed-download-fill", -- 530
						width = (infoWidth - 92) * prepareProgress, -- 530
						height = 8, -- 530
						anchorX = 0, -- 530
						anchorY = 0 -- 530
					} -- 530
					local ____temp_25 -- 537
					if prepareProgress > 0 then -- 537
						____temp_25 = React.createElement(RoundedSurface, { -- 537
							width = (infoWidth - 92) * prepareProgress, -- 537
							height = 8, -- 537
							radius = 4, -- 537
							topColor = 4294958955, -- 537
							bottomColor = 4294950190 -- 537
						}) -- 537
					else -- 537
						____temp_25 = nil -- 537
					end -- 537
					__TS__SparseArrayPush( -- 537
						____array_31, -- 537
						____React_createElement_30( -- 537
							"node", -- 537
							____temp_28, -- 537
							____React_createElement_result_29, -- 537
							____React_createElement_27("node", ____temp_26, ____temp_25) -- 537
						), -- 537
						React.createElement(MobileButton, { -- 537
							tag = "mobile-feed-download-cancel", -- 537
							x = infoWidth - 80, -- 537
							y = 0, -- 537
							width = 80, -- 537
							height = 48, -- 537
							text = prepareCanceled and (zh and "中断中…" or "Canceling…") or (zh and "中断" or "Cancel"), -- 537
							fontSize = 13, -- 537
							danger = true, -- 537
							onTapped = cancelPrepare -- 537
						}) -- 537
					) -- 537
					____preparing_33 = ____React_createElement_32(__TS__SparseArraySpread(____array_31)) -- 537
				else -- 537
					____preparing_33 = React.createElement( -- 537
						"node", -- 537
						nil, -- 537
						React.createElement( -- 537
							MobileButton, -- 543
							{ -- 543
								tag = "mobile-feed-remix", -- 543
								x = infoX, -- 543
								y = actionsY, -- 543
								width = buttonWidth, -- 543
								text = item.webPlayUrl and (zh and "查看源码" or "View source") or (zh and "Remix 作品" or "Remix game"), -- 543
								fontSize = math.floor(16 * fontScale), -- 543
								primary = true, -- 543
								onTapped = function() return activate("remix") end -- 543
							} -- 543
						), -- 543
						React.createElement( -- 543
							MobileButton, -- 545
							{ -- 545
								tag = "mobile-feed-play", -- 545
								x = infoX + buttonWidth + 12, -- 545
								y = actionsY, -- 545
								width = buttonWidth, -- 545
								text = item.webPlayUrl and (zh and "在线试玩" or "Play online") or (zh and "试玩" or "Play"), -- 545
								fontSize = math.floor(17 * fontScale), -- 545
								onTapped = function() return activate("play") end -- 545
							} -- 545
						) -- 545
					) -- 545
				end -- 545
				__TS__SparseArrayPush(____array_35, ____preparing_33) -- 545
				local ____preparing_34 -- 548
				if preparing then -- 548
					____preparing_34 = React.createElement( -- 548
						"clip-node", -- 548
						{ -- 548
							tag = "mobile-feed-download-message-clip", -- 548
							x = infoX, -- 548
							y = gestureHintY - 10, -- 548
							width = infoWidth, -- 548
							height = 20, -- 548
							anchorX = 0, -- 548
							anchorY = 0, -- 548
							stencil = React.createElement(RoundedStencil, {width = infoWidth, height = 20, radius = 0}) -- 548
						}, -- 548
						React.createElement("label", { -- 548
							tag = "mobile-feed-download-message", -- 548
							x = 0, -- 548
							y = 10, -- 548
							anchorX = 0, -- 548
							fontName = fontName, -- 548
							fontSize = 12, -- 548
							text = (string.gsub(prepareStatus, "[\r\n]+", " ")), -- 548
							textWidth = -1, -- 548
							color3 = 11055037 -- 548
						}) -- 548
					) -- 548
				else -- 548
					____preparing_34 = React.createElement("label", { -- 548
						tag = "mobile-feed-gesture-hint", -- 548
						x = infoX, -- 548
						y = gestureHintY, -- 548
						anchorX = 0, -- 548
						anchorY = 0.5, -- 548
						fontName = fontName, -- 548
						fontSize = gamepadUsed and 11 or 14, -- 548
						text = prepareStatus ~= "" and prepareStatus or (item.launchError ~= nil and item.launchError or (item.webPlayUrl and (gamepadUsed and (zh and "↑↓ 浏览 · A 在线试玩 · X 查看源码 · Start 列表" or "↑↓ Browse · A Play online · X Source · Start List") or (zh and "上滑浏览  ·  右滑源码  ·  左滑在线试玩" or "Swipe up  ·  right Source  ·  left Web play")) or (gamepadUsed and (zh and "↑↓ 浏览 · A 确认 · X Remix · Start 列表 · Y 新建" or "↑↓ Browse · A Select · X Remix · Start List · Y New") or (zh and "上滑浏览  ·  右滑 Remix  ·  左滑试玩" or "Swipe up  ·  right Remix  ·  left Play")))), -- 548
						textWidth = infoWidth, -- 548
						alignment = "Left", -- 548
						color3 = item.launchError ~= nil and 16739179 or 11055037 -- 548
					}) -- 548
				end -- 548
				__TS__SparseArrayPush(____array_35, ____preparing_34) -- 548
				____temp_37 = ____React_createElement_36(__TS__SparseArraySpread(____array_35)) -- 548
			else -- 548
				____temp_37 = React.createElement( -- 548
					"node", -- 548
					nil, -- 548
					React.createElement("label", { -- 548
						x = left + usableWidth / 2, -- 548
						y = bottom + usableHeight / 2 + 20, -- 548
						fontName = fontName, -- 548
						fontSize = 22, -- 548
						text = tab == "discover" and (zh and "暂无移动作品" or "No mobile games yet") or (zh and "没有可运行的本地作品" or "No runnable local games"), -- 548
						color3 = 16052712 -- 548
					}), -- 548
					React.createElement("label", { -- 548
						x = left + usableWidth / 2, -- 548
						y = bottom + usableHeight / 2 - 28, -- 548
						fontName = fontName, -- 548
						fontSize = 14, -- 548
						text = tab == "discover" and discoverError ~= "" and discoverError or (zh and "切换标签或稍后重试" or "Switch tabs or retry later"), -- 548
						textWidth = usableWidth - 48, -- 548
						color3 = tab == "discover" and discoverError ~= "" and 16739179 or 11055037 -- 548
					}) -- 548
				) -- 548
			end -- 548
			____createOpen_38 = ____temp_37 -- 497
		end -- 497
		local ____temp_39 -- 564
		if not createOpen and not item and tab == "local" then -- 564
			____temp_39 = React.createElement( -- 564
				"node", -- 564
				nil, -- 564
				React.createElement(MobileButton, { -- 564
					tag = "mobile-empty-new", -- 564
					x = left + 20, -- 564
					y = bottom + 24, -- 564
					width = (usableWidth - 52) / 2, -- 564
					text = zh and "新建作品" or "New game", -- 564
					onTapped = openCreate -- 564
				}), -- 564
				React.createElement( -- 564
					MobileButton, -- 566
					{ -- 566
						tag = "mobile-empty-import", -- 566
						x = left + 32 + (usableWidth - 52) / 2, -- 566
						y = bottom + 24, -- 566
						width = (usableWidth - 52) / 2, -- 566
						text = zh and "导入作品包" or "Import package", -- 566
						fontSize = 15, -- 566
						primary = true, -- 566
						onTapped = function() return openPackage("add", nil, true) end -- 566
					} -- 566
				) -- 566
			) -- 566
		else -- 566
			____temp_39 = nil -- 567
		end -- 567
		local ____temp_40 -- 568
		if not item and tab == "discover" and syncDiscover then -- 568
			____temp_40 = React.createElement(MobileButton, { -- 568
				tag = "mobile-feed-empty-index", -- 568
				x = left + (usableWidth - 160) / 2, -- 568
				y = bottom + 24, -- 568
				width = 160, -- 568
				text = zh and "作品目录" or "Game index", -- 568
				onTapped = openProjectIndex -- 568
			}) -- 568
		else -- 568
			____temp_40 = nil -- 569
		end -- 569
		local ____React_createElement_44 = React.createElement -- 569
		local ____array_43 = __TS__SparseArrayNew("node", {tag = "mobile-feed-header", order = headerRenderOrder}) -- 569
		local ____options_onSwitchMode_41 -- 571
		if options.onSwitchMode then -- 571
			____options_onSwitchMode_41 = React.createElement( -- 571
				"node", -- 571
				{ -- 571
					tag = "mobile-ui-mode-switch", -- 571
					x = left + 12, -- 571
					y = bottom + usableHeight - 58 + landscapeTopLift, -- 571
					width = 72, -- 571
					height = 48, -- 571
					anchorX = 0, -- 571
					anchorY = 0, -- 571
					touchEnabled = true, -- 571
					swallowTouches = true, -- 571
					onTapped = switchMode -- 571
				}, -- 571
				React.createElement("label", { -- 571
					x = 0, -- 571
					y = 30, -- 571
					anchorX = 0, -- 571
					fontName = fontName, -- 571
					fontSize = 16, -- 571
					text = "DORA", -- 571
					color3 = preparing and 7831180 or 16763955 -- 571
				}), -- 571
				React.createElement("label", { -- 571
					x = 0, -- 571
					y = 10, -- 571
					anchorX = 0, -- 571
					fontName = fontName, -- 571
					fontSize = 10, -- 571
					text = zh and "切换传统界面" or "Classic UI", -- 571
					color3 = 7831180 -- 571
				}) -- 571
			) -- 571
		else -- 571
			____options_onSwitchMode_41 = nil -- 575
		end -- 575
		__TS__SparseArrayPush( -- 575
			____array_43, -- 575
			____options_onSwitchMode_41, -- 575
			React.createElement( -- 575
				"label", -- 575
				{ -- 575
					tag = "mobile-feed-discover-tab", -- 575
					x = left + usableWidth / 2 - 44, -- 575
					y = bottom + usableHeight - 34 + landscapeTopLift, -- 575
					fontName = fontName, -- 575
					fontSize = math.floor(17 * fontScale), -- 575
					text = zh and "发现" or "Discover", -- 575
					color3 = tab == "discover" and 16763955 or 11055037, -- 575
					touchEnabled = true, -- 575
					swallowTouches = true, -- 575
					onTapped = function() return setTab("discover") end -- 575
				} -- 575
			), -- 575
			React.createElement( -- 575
				"label", -- 575
				{ -- 575
					tag = "mobile-feed-local-tab", -- 575
					x = left + usableWidth / 2 + 44, -- 575
					y = bottom + usableHeight - 34 + landscapeTopLift, -- 575
					fontName = fontName, -- 575
					fontSize = math.floor(17 * fontScale), -- 575
					text = zh and "本地" or "Local", -- 575
					color3 = tab == "local" and 16763955 or 11055037, -- 575
					touchEnabled = true, -- 575
					swallowTouches = true, -- 575
					onTapped = function() -- 575
						____local = getLocalEntries() -- 581
						setTab("local") -- 581
					end -- 581
				} -- 581
			), -- 581
			React.createElement(RoundedSurface, { -- 581
				x = left + usableWidth / 2 + (tab == "discover" and -58 or 30), -- 581
				y = bottom + usableHeight - 56 + landscapeTopLift, -- 581
				width = 28, -- 581
				height = 3, -- 581
				radius = 1.5, -- 581
				fillColor = colors.brand, -- 581
				renderOrder = headerRenderOrder + 1 -- 581
			}) -- 581
		) -- 581
		local ____temp_42 -- 583
		if tab == "local" and options.createProject then -- 583
			____temp_42 = React.createElement( -- 583
				MobileNewButton, -- 583
				{ -- 583
					tag = "mobile-feed-create", -- 583
					x = left + usableWidth - 82, -- 583
					y = bottom + usableHeight - 56 + landscapeTopLift, -- 583
					text = zh and "+ 新建" or "+ New", -- 583
					renderOrder = headerRenderOrder + 1, -- 583
					onTapped = function() return openPackage("add") end -- 583
				} -- 583
			) -- 583
		else -- 583
			____temp_42 = nil -- 585
		end -- 585
		__TS__SparseArrayPush(____array_43, ____temp_42) -- 585
		local ____React_createElement_44_result_54 = ____React_createElement_44(__TS__SparseArraySpread(____array_43)) -- 585
		local ____createOpen_52 -- 587
		if createOpen then -- 587
			____createOpen_52 = (function() -- 587
				local sheetHeight = math.min(createSheetHeight, usableHeight - 64) -- 588
				local sheetWidth = usableWidth -- 589
				local contentWidth = sheetWidth - 40 -- 590
				local actionGap = 12 -- 591
				local actionsWidth = shortLandscape and math.min( -- 592
					300, -- 592
					math.floor(contentWidth * 0.42) -- 592
				) or contentWidth -- 592
				local inputWidth = shortLandscape and contentWidth - actionGap - actionsWidth or contentWidth -- 593
				local actionX = shortLandscape and 20 + inputWidth + actionGap or 20 -- 594
				local actionY = shortLandscape and sheetHeight - createInputTop - createInputHeight or 20 -- 595
				local cancelWidth = math.floor((actionsWidth - actionGap) * (shortLandscape and 0.34 or 0.38)) -- 596
				local ____React_createElement_51 = React.createElement -- 596
				local ____array_50 = __TS__SparseArrayNew( -- 596
					"node", -- 596
					{ -- 596
						tag = "mobile-project-create-sheet", -- 596
						order = 10000, -- 596
						width = width, -- 596
						height = height, -- 596
						anchorX = 0, -- 596
						anchorY = 0, -- 596
						touchEnabled = true, -- 596
						swallowTouches = true -- 596
					}, -- 596
					React.createElement( -- 596
						"node", -- 596
						{ -- 596
							tag = "mobile-project-create-focus-observer", -- 596
							order = 1000, -- 596
							width = width, -- 596
							height = height, -- 596
							anchorX = 0, -- 596
							anchorY = 0, -- 596
							touchEnabled = true, -- 596
							swallowTouches = false, -- 596
							swallowMouseWheel = false, -- 596
							onTapFilter = function(touch) -- 596
								touch.enabled = false -- 600
								if not canEditCreate() then -- 600
									return -- 601
								end -- 601
								local input = createInputRef.current -- 602
								local point = input and input:convertToNodeSpace(touch.worldLocation) -- 603
								local inside = input and point and point.x >= 0 and point.y >= 0 and point.x <= input.width and point.y <= input.height -- 604
								dismissedCreateComposition = not inside and createInput.isComposing() -- 605
								if not inside then -- 605
									blurCreateInput() -- 606
								end -- 606
							end -- 599
						} -- 599
					), -- 599
					React.createElement( -- 599
						"draw-node", -- 599
						{ -- 599
							tag = "mobile-project-create-backdrop", -- 599
							order = 0, -- 599
							renderOrder = 0, -- 599
							x = width / 2, -- 599
							y = bottom + sheetHeight + (height - bottom - sheetHeight) / 2 -- 599
						}, -- 599
						React.createElement("rect-shape", {width = width, height = height - bottom - sheetHeight, fillColor = 2348810240}) -- 599
					) -- 599
				) -- 599
				local ____React_createElement_49 = React.createElement -- 599
				local ____array_48 = __TS__SparseArrayNew( -- 599
					"node", -- 599
					{ -- 599
						ref = createPanelRef, -- 599
						order = 10, -- 599
						renderOrder = 10, -- 599
						x = left, -- 599
						y = bottom, -- 599
						width = sheetWidth, -- 599
						height = sheetHeight, -- 599
						anchorX = 0, -- 599
						anchorY = 0, -- 599
						touchEnabled = true, -- 599
						swallowTouches = true -- 599
					}, -- 599
					React.createElement(MobilePanelSurface, {width = sheetWidth, height = sheetHeight, renderOrder = 10}), -- 599
					React.createElement("label", { -- 599
						x = 20, -- 599
						y = sheetHeight - 24, -- 599
						anchorX = 0, -- 599
						anchorY = 1, -- 599
						fontName = fontName, -- 599
						fontSize = 22, -- 599
						text = zh and "新建项目" or "New project", -- 599
						color3 = 16052712 -- 599
					}), -- 599
					__TS__ArrayMap( -- 614
						{"typescript", "lua"}, -- 614
						function(____, language, i) return React.createElement( -- 614
							MobileChoiceButton, -- 614
							{ -- 614
								tag = "mobile-project-create-language-" .. language, -- 614
								x = 20 + i * 144, -- 614
								y = sheetHeight - 98, -- 614
								width = language == "lua" and 84 or 132, -- 614
								text = language == "lua" and "Lua" or "TypeScript", -- 614
								selected = createLanguage == language, -- 614
								renderOrder = 10, -- 614
								onTapped = function() -- 614
									if not canEditCreate() then -- 614
										return -- 618
									end -- 618
									blurCreateInput() -- 619
									createLanguage = language -- 619
									render() -- 619
								end -- 617
							} -- 617
						) end -- 617
					), -- 617
					React.createElement("label", { -- 617
						x = 20, -- 617
						y = sheetHeight - 110, -- 617
						anchorX = 0, -- 617
						anchorY = 1, -- 617
						fontName = fontName, -- 617
						fontSize = 14, -- 617
						text = zh and "项目名称" or "Project name", -- 617
						color3 = 11055037 -- 617
					}) -- 617
				) -- 617
				local ____keptInput_47 -- 622
				if keptInput then -- 622
					____keptInput_47 = nil -- 622
				else -- 622
					____keptInput_47 = React.createElement("node", { -- 622
						tag = "mobile-project-create-input", -- 622
						ref = createInputRef, -- 622
						renderOrder = 10, -- 622
						x = 20, -- 622
						y = sheetHeight - createInputTop - createInputHeight, -- 622
						width = inputWidth, -- 622
						height = createInputHeight, -- 622
						anchorX = 0, -- 622
						anchorY = 0, -- 622
						onMount = createInput.mount -- 622
					}) -- 622
				end -- 622
				__TS__SparseArrayPush( -- 622
					____array_48, -- 622
					____keptInput_47, -- 622
					React.createElement("label", { -- 622
						tag = "mobile-project-create-error", -- 622
						x = 20, -- 622
						y = shortLandscape and sheetHeight - createInputTop + 12 or sheetHeight - createInputTop - createInputHeight - 12, -- 622
						anchorX = 0, -- 622
						anchorY = 1, -- 622
						fontName = fontName, -- 622
						fontSize = 12, -- 622
						text = createError ~= "" and createError or (zh and ("将创建可运行的 " .. (createLanguage == "lua" and "Lua" or "TypeScript")) .. " 起始项目" or ("Creates a runnable " .. (createLanguage == "lua" and "Lua" or "TypeScript")) .. " starter project"), -- 622
						textWidth = inputWidth, -- 622
						alignment = "Left", -- 622
						color3 = createError ~= "" and 16739179 or 11055037 -- 622
					}), -- 622
					React.createElement(MobileButton, { -- 622
						tag = "mobile-project-create-cancel", -- 622
						x = actionX, -- 622
						y = actionY, -- 622
						width = cancelWidth, -- 622
						text = zh and "取消" or "Cancel", -- 622
						renderOrder = 10, -- 622
						onTapped = closeCreate -- 622
					}), -- 622
					React.createElement( -- 622
						MobileButton, -- 628
						{ -- 628
							tag = "mobile-project-create-submit", -- 628
							x = actionX + cancelWidth + actionGap, -- 628
							y = actionY, -- 628
							width = actionsWidth - cancelWidth - actionGap, -- 628
							text = creating and (zh and "创建中…" or "Creating…") or (zh and "创建并进入 Remix" or "Create and Remix"), -- 628
							primary = true, -- 628
							renderOrder = 10, -- 628
							onTapped = function() -- 628
								if not dismissedCreateComposition then -- 628
									submitCreate() -- 629
								end -- 629
								dismissedCreateComposition = false -- 629
							end -- 629
						} -- 629
					) -- 629
				) -- 629
				__TS__SparseArrayPush( -- 629
					____array_50, -- 629
					____React_createElement_49(__TS__SparseArraySpread(____array_48)) -- 629
				) -- 629
				return ____React_createElement_51(__TS__SparseArraySpread(____array_50)) -- 597
			end)() -- 587
		else -- 587
			____createOpen_52 = nil -- 632
		end -- 632
		__TS__SparseArrayPush( -- 632
			____array_57, -- 632
			____React_createElement_55( -- 632
				"node", -- 632
				____temp_53, -- 632
				____createOpen_38, -- 632
				____temp_39, -- 632
				____temp_40, -- 632
				____React_createElement_44_result_54, -- 632
				____createOpen_52 -- 632
			) -- 632
		) -- 632
		local ____projectIndexOpen_56 -- 634
		if projectIndexOpen then -- 634
			____projectIndexOpen_56 = React.createElement( -- 634
				ProjectIndex, -- 634
				{ -- 634
					entries = entries(), -- 634
					kind = tab, -- 634
					current = current(), -- 634
					x = left, -- 634
					y = bottom, -- 634
					width = usableWidth, -- 634
					height = usableHeight, -- 634
					zh = zh, -- 634
					refreshing = catalogSyncing, -- 634
					refreshStatus = catalogStatus, -- 634
					onRefresh = syncDiscover and (function() return refreshDiscover(true) end) or nil, -- 634
					onStatusReady = function(____, update) -- 634
						catalogStatusView = update -- 637
					end, -- 637
					onClose = function() -- 637
						projectIndexOpen = false -- 638
						render() -- 638
					end, -- 638
					onSelect = function(____, entry) -- 638
						projectIndexOpen = false -- 640
						local location = resolveFeedLocation(____local, discover, entry) -- 641
						tab = location.tab -- 642
						index = location.index -- 642
						render() -- 643
					end -- 639
				} -- 639
			) -- 639
		else -- 639
			____projectIndexOpen_56 = nil -- 644
		end -- 644
		__TS__SparseArrayPush(____array_57, ____projectIndexOpen_56) -- 644
		local scene = ____toNode_59(____React_createElement_58(__TS__SparseArraySpread(____array_57))) -- 450
		if scene ~= nil then -- 450
			host:addChild(scene) -- 646
		end -- 646
		if keptInput and createPanelRef.current then -- 646
			keptInput.position = Vec2( -- 648
				20, -- 648
				math.min(createSheetHeight, usableHeight - 64) - createInputTop - createInputHeight -- 648
			) -- 648
			createPanelRef.current:addChild(keptInput) -- 649
		end -- 649
		createInput.refresh() -- 651
		if restoreFocus and not keptInput and createOpen then -- 651
			createInput.focus(false) -- 652
		end -- 652
	end -- 397
	attachGamepad( -- 655
		host, -- 655
		{ -- 655
			initialTag = "mobile-feed-play", -- 656
			isEnabled = function() return isActive() and not packagePanel and not preparing and not transitioning and not creating end, -- 657
			onActive = function() -- 658
				gamepadUsed = true -- 658
				render() -- 658
			end, -- 658
			onBack = function() -- 659
				if createInput.isFocused() then -- 659
					blurCreateInput() -- 659
				elseif createOpen then -- 659
					closeCreate() -- 659
				else -- 659
					switchMode() -- 659
				end -- 659
			end, -- 659
			onActivate = function(target) -- 660
				if target.tag == "mobile-project-create-input" then -- 660
					target:emit("GamepadActivate") -- 661
				else -- 661
					if createInput.isComposing() then -- 661
						blurCreateInput() -- 663
						return -- 663
					end -- 663
					blurCreateInput() -- 664
					dismissedCreateComposition = false -- 665
					target:emit("Tapped") -- 666
				end -- 666
			end, -- 660
			onButton = function(button) -- 669
				if createOpen then -- 669
					return false -- 670
				end -- 670
				repeat -- 670
					local ____switch138 = button -- 670
					local ____cond138 = ____switch138 == "dpup" -- 670
					if ____cond138 then -- 670
						commit("previous") -- 672
						return true -- 672
					end -- 672
					____cond138 = ____cond138 or ____switch138 == "dpdown" -- 672
					if ____cond138 then -- 672
						commit("next") -- 673
						return true -- 673
					end -- 673
					____cond138 = ____cond138 or ____switch138 == "leftshoulder" -- 673
					if ____cond138 then -- 673
						setTab("discover") -- 674
						return true -- 674
					end -- 674
					____cond138 = ____cond138 or ____switch138 == "rightshoulder" -- 674
					if ____cond138 then -- 674
						setTab("local") -- 675
						return true -- 675
					end -- 675
					____cond138 = ____cond138 or ____switch138 == "x" -- 675
					if ____cond138 then -- 675
						commit("remix") -- 676
						return true -- 676
					end -- 676
					____cond138 = ____cond138 or ____switch138 == "y" -- 676
					if ____cond138 then -- 676
						local ____opt_60 = findGamepadNode(host, "mobile-feed-create") -- 676
						if ____opt_60 ~= nil then -- 676
							____opt_60:emit("Tapped") -- 677
						end -- 677
						return true -- 677
					end -- 677
					____cond138 = ____cond138 or ____switch138 == "start" -- 677
					if ____cond138 then -- 677
						openProjectIndex() -- 678
						return true -- 678
					end -- 678
					do -- 678
						return false -- 679
					end -- 679
				until true -- 679
			end -- 669
		} -- 669
	) -- 669
	host:onAppChange(function(setting) -- 683
		if setting == "Locale" then -- 683
			local activeEntry = current() -- 685
			zh = (string.match(App.locale, "^zh")) ~= nil -- 686
			____local = getLocalEntries() -- 687
			discover = getDiscoverEntries() -- 688
			local location = resolveFeedLocation(____local, discover, activeEntry) -- 689
			tab = location.tab -- 690
			index = location.index -- 691
			render() -- 692
		elseif setting == "Size" then -- 692
			render() -- 693
		end -- 693
	end) -- 683
	host:onAppEvent(function(event) -- 695
		if event == "BackButton" then -- 695
			if projectIndexOpen then -- 695
				projectIndexOpen = false -- 697
				render() -- 697
			elseif createOpen and not creating then -- 697
				closeCreate() -- 698
			end -- 698
		elseif event == "WillEnterBackground" or event == "DidEnterBackground" then -- 698
			blurCreateInput() -- 699
		end -- 699
	end) -- 695
	host:onCleanup(function() -- 701
		blurCreateInput() -- 701
		active = false -- 701
		if packagePanel ~= nil then -- 701
			packagePanel:removeFromParent(true) -- 701
		end -- 701
		packagePanel = nil -- 701
	end) -- 701
	host:slot( -- 702
		"RestoreFeedEntry", -- 702
		function(entry) -- 702
			if not isActive() or HttpServer.wsConnectionCount > 0 then -- 702
				return -- 703
			end -- 703
			returnEntry = entry -- 704
			____local = getLocalEntries() -- 705
			discover = getDiscoverEntries() -- 706
			local location = resolveFeedLocation(____local, discover, entry) -- 707
			tab = location.tab -- 708
			index = location.index -- 709
			render() -- 710
		end -- 702
	) -- 702
	host:slot("SuspendLocalUI", blurCreateInput) -- 712
	host:slot( -- 713
		"ResumeLocalUI", -- 713
		function() -- 713
			leaving = false -- 713
			render() -- 713
		end -- 713
	) -- 713
	refreshDiscover = function(force) -- 714
		if not syncDiscover or catalogSyncing or not isActive() then -- 714
			return -- 715
		end -- 715
		catalogSyncing = true -- 716
		catalogStatus = zh and "正在同步资源目录…" or "Syncing Catalog…" -- 717
		if #discover == 0 then -- 717
			discoverError = catalogStatus -- 719
		end -- 719
		render() -- 721
		syncDiscover( -- 722
			function(message) -- 722
				if not isActive() then -- 722
					return -- 723
				end -- 723
				catalogStatus = message -- 724
				if catalogStatusView ~= nil then -- 724
					catalogStatusView(message) -- 725
				end -- 725
				if projectIndexOpen or #discover > 0 then -- 725
					return -- 726
				end -- 726
				discoverError = message -- 727
				render() -- 728
			end, -- 722
			function(success, message) -- 729
				if not isActive() then -- 729
					return -- 730
				end -- 730
				catalogSyncing = false -- 731
				catalogStatus = success and (zh and "目录已更新" or "Catalog updated") or (zh and "刷新失败：" or "Refresh failed: ") .. (message or (zh and "请重试" or "Try again")) -- 732
				local selected = force and current() or (returnEntry or rememberedEntries[tab] or current()) -- 733
				local previousCount = #discover -- 734
				discover = getDiscoverEntries() -- 735
				discoverError = success and (#discover == 0 and (zh and "目录中暂无可运行作品" or "No runnable Catalog games") or "") or (message or (zh and "资源目录同步失败" or "Catalog sync failed")) -- 736
				if not force and not projectIndexOpen then -- 736
					tab = resolveDiscoverRefreshTab( -- 741
						tab, -- 741
						userSelectedTab, -- 741
						previousCount, -- 741
						#discover, -- 741
						#____local -- 741
					) -- 741
				end -- 741
				if selected ~= nil then -- 741
					local location = resolveFeedLocation(____local, discover, selected) -- 743
					if location.tab == tab then -- 743
						index = location.index -- 744
					end -- 744
				end -- 744
				index = normalizeFeedIndex( -- 746
					index, -- 746
					#entries() -- 746
				) -- 746
				render() -- 747
			end, -- 729
			force -- 748
		) -- 748
	end -- 714
	render() -- 750
	refreshDiscover(false) -- 751
	return host -- 752
end -- 109
return ____exports -- 109