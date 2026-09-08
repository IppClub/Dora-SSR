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
local function Cover(props) -- 58
	local file = props.entry.bannerFile -- 59
	local function scaleSprite(sprite, mode) -- 60
		local scales = getCoverScales(sprite.width, sprite.height, props.width, props.height) -- 61
		sprite.scaleX = scales[mode] -- 62
		sprite.scaleY = scales[mode] -- 63
	end -- 60
	local ____React_createElement_5 = React.createElement -- 60
	local ____temp_3 = { -- 60
		x = props.x, -- 60
		y = props.y, -- 60
		width = props.width, -- 60
		height = props.height, -- 60
		anchorX = 0, -- 60
		anchorY = 0 -- 60
	} -- 60
	local ____React_createElement_result_4 = React.createElement( -- 60
		RoundedSurface, -- 66
		{ -- 66
			width = props.width, -- 66
			height = props.height, -- 66
			radius = 22, -- 66
			topColor = stableCoverColor(props.entry.id), -- 66
			bottomColor = 4279310115, -- 66
			shadow = true -- 66
		} -- 66
	) -- 66
	local ____file_0 -- 68
	if file then -- 68
		____file_0 = React.createElement( -- 68
			"clip-node", -- 68
			{ -- 68
				width = props.width, -- 68
				height = props.height, -- 68
				anchorX = 0, -- 68
				anchorY = 0, -- 68
				stencil = React.createElement(RoundedStencil, {width = props.width, height = props.height, radius = 22}) -- 68
			}, -- 68
			React.createElement( -- 68
				"sprite", -- 68
				{ -- 68
					file = file, -- 68
					x = props.width / 2 - 5, -- 68
					y = props.height / 2, -- 68
					opacity = 0.08, -- 68
					onMount = function(sprite) return scaleSprite(sprite, "cover") end -- 68
				} -- 68
			), -- 68
			React.createElement( -- 68
				"sprite", -- 68
				{ -- 68
					file = file, -- 68
					x = props.width / 2 + 5, -- 68
					y = props.height / 2, -- 68
					opacity = 0.08, -- 68
					onMount = function(sprite) return scaleSprite(sprite, "cover") end -- 68
				} -- 68
			), -- 68
			React.createElement( -- 68
				"sprite", -- 68
				{ -- 68
					file = file, -- 68
					x = props.width / 2, -- 68
					y = props.height / 2 - 5, -- 68
					opacity = 0.08, -- 68
					onMount = function(sprite) return scaleSprite(sprite, "cover") end -- 68
				} -- 68
			), -- 68
			React.createElement( -- 68
				"draw-node", -- 68
				{x = props.width / 2, y = props.height / 2}, -- 68
				React.createElement("rect-shape", {width = props.width, height = props.height, fillColor = 2953514258}) -- 68
			), -- 68
			React.createElement( -- 68
				"sprite", -- 68
				{ -- 68
					file = file, -- 68
					x = props.width / 2, -- 68
					y = props.height / 2, -- 68
					onMount = function(sprite) return scaleSprite(sprite, "contain") end -- 68
				} -- 68
			) -- 68
		) -- 68
	else -- 68
		____file_0 = React.createElement( -- 68
			"label", -- 68
			{ -- 68
				x = props.width / 2, -- 68
				y = props.height / 2 + 10, -- 68
				fontName = fontName, -- 68
				fontSize = math.floor(math.max( -- 68
					22, -- 80
					math.min(34, props.width / 12) -- 80
				)), -- 80
				text = props.entry.title, -- 80
				textWidth = props.width - 40, -- 80
				color3 = 16052712 -- 80
			} -- 80
		) -- 80
	end -- 80
	local ____file_1 -- 85
	if file then -- 85
		____file_1 = nil -- 85
	else -- 85
		____file_1 = React.createElement("label", { -- 85
			x = props.width / 2, -- 85
			y = 30, -- 85
			fontName = fontName, -- 85
			fontSize = 14, -- 85
			text = "DORA SSR · REMIXABLE", -- 85
			color3 = 16763955 -- 85
		}) -- 85
	end -- 85
	local ____file_2 -- 93
	if file then -- 93
		____file_2 = nil -- 93
	else -- 93
		____file_2 = React.createElement(DoraMascot, {state = "idle", x = props.width - 46, y = 64, size = 42}) -- 93
	end -- 93
	return ____React_createElement_5( -- 65
		"node", -- 65
		____temp_3, -- 65
		____React_createElement_result_4, -- 65
		____file_0, -- 65
		____file_1, -- 65
		____file_2, -- 65
		React.createElement(RoundedSurface, { -- 65
			width = props.width, -- 65
			height = props.height, -- 65
			radius = 22, -- 65
			fillColor = 0, -- 65
			borderWidth = 1, -- 65
			borderColor = 4282074454 -- 65
		}) -- 65
	) -- 65
end -- 58
function ____exports.startMobileFeed(options) -- 98
	local submitCreate, render, refreshDiscover -- 98
	local getLocalEntries = options.getLocalEntries -- 99
	local getDiscoverEntries = options.getDiscoverEntries -- 100
	local onPlay = options.onPlay -- 101
	local onRemix = options.onRemix -- 102
	local prepare = options.prepare -- 103
	local syncDiscover = options.syncDiscover -- 104
	local canShare = App.platform == "Android" or App.platform == "iOS" -- 105
	local zh = (string.match(App.locale, "^zh")) ~= nil -- 106
	local tab = "local" -- 107
	local index = 0 -- 108
	local drag = Vec2.zero -- 109
	local dragAxis = "none" -- 110
	local discoverError = "" -- 111
	local preparing = false -- 112
	local transitioning = false -- 113
	local prepareStatus = "" -- 114
	local prepareProgress = 0 -- 115
	local catalogSyncing = false -- 116
	local catalogStatus = "" -- 117
	local catalogStatusView -- 118
	local repairResourceId = "" -- 119
	local userSelectedTab = false -- 120
	local active = true -- 121
	local leaving = false -- 122
	local packagePanel -- 123
	local createOpen = false -- 124
	local projectIndexOpen = false -- 125
	local creating = false -- 126
	local createName = "" -- 127
	local createLanguage = "typescript" -- 128
	local dismissedCreateComposition = false -- 129
	local createError = "" -- 130
	local gamepadUsed = false -- 131
	local returnEntry = options.initialEntry -- 132
	local ____opt_6 = options.initialEntries -- 132
	local ____temp_10 = ____opt_6 and ____opt_6["local"] -- 134
	local ____opt_8 = options.initialEntries -- 134
	local rememberedEntries = {["local"] = ____temp_10, discover = ____opt_8 and ____opt_8.discover} -- 133
	local cardRef = reference() -- 137
	local indexRef = reference() -- 138
	local createInputRef = reference() -- 139
	local discover = getDiscoverEntries() -- 140
	local ____local = getLocalEntries() -- 141
	if #discover == 0 then -- 141
		discoverError = zh and "资源目录暂不可用" or "Catalog is unavailable" -- 144
	end -- 144
	local initialLocation = resolveFeedLocation(____local, discover, returnEntry) -- 146
	tab = initialLocation.tab -- 147
	index = initialLocation.index -- 148
	local host = Node() -- 150
	host.tag = "mobile-feed" -- 151
	host.scaleX = App.devicePixelRatio -- 152
	host.scaleY = App.devicePixelRatio -- 153
	host:addTo(Director.systemUI) -- 154
	local function isActive() -- 156
		return active and not leaving and host.parent ~= nil -- 156
	end -- 156
	local function entries() -- 158
		return tab == "discover" and discover or ____local -- 158
	end -- 158
	local function current() -- 159
		return entries()[normalizeFeedIndex( -- 159
			index, -- 159
			#entries() -- 159
		) + 1] -- 159
	end -- 159
	local rememberedEntryKey = "" -- 160
	local function rememberCurrent() -- 161
		local item = current() -- 162
		if not item or not options.onCurrentEntryChanged then -- 162
			return -- 163
		end -- 163
		local key = (((((item.kind .. "\n") .. item.id) .. "\n") .. (item.workDir or "")) .. "\n") .. (item.fileName or "") -- 164
		if key == rememberedEntryKey then -- 164
			return -- 165
		end -- 165
		rememberedEntryKey = key -- 166
		rememberedEntries[item.kind] = item -- 167
		options.onCurrentEntryChanged(item) -- 168
	end -- 161
	local function canEditCreate() -- 170
		return createOpen and not creating and isActive() and host.visible and HttpServer.wsConnectionCount == 0 -- 170
	end -- 170
	local createInput = createTextInput({ -- 171
		fontSize = math.floor(16 * mobileFontScale), -- 172
		singleLine = true, -- 173
		background = colors.background, -- 174
		getText = function() return createName end, -- 175
		setText = function(text) -- 176
			createName = text -- 176
		end, -- 176
		getPlaceholder = function() return zh and "例如：星际花园" or "For example: Star Garden" end, -- 177
		isEnabled = canEditCreate, -- 178
		onReturn = function() -- 179
			submitCreate() -- 179
			return true -- 179
		end -- 179
	}) -- 179
	local blurCreateInput = createInput.blur -- 181
	local function closeCreate() -- 182
		if creating then -- 182
			return -- 183
		end -- 183
		blurCreateInput() -- 184
		createOpen = false -- 185
		createName = "" -- 186
		createError = "" -- 187
		render() -- 188
	end -- 182
	local function openCreate() -- 190
		if not options.createProject or preparing or transitioning or creating or createOpen or HttpServer.wsConnectionCount > 0 then -- 190
			return -- 191
		end -- 191
		projectIndexOpen = false -- 192
		createOpen = true -- 193
		createLanguage = "typescript" -- 194
		createName = "" -- 195
		dismissedCreateComposition = false -- 196
		createError = "" -- 197
		render() -- 198
		createInput.deferFocus() -- 199
	end -- 190
	local function openProjectIndex() -- 201
		if preparing or transitioning or creating or createOpen or HttpServer.wsConnectionCount > 0 then -- 201
			return -- 202
		end -- 202
		if tab == "local" then -- 202
			____local = getLocalEntries() -- 203
		end -- 203
		projectIndexOpen = true -- 204
		render() -- 205
	end -- 201
	local function createErrorText(____error) -- 207
		repeat -- 207
			local ____switch31 = ____error -- 207
			local ____cond31 = ____switch31 == "invalid-name" -- 207
			if ____cond31 then -- 207
				return zh and "请输入不含路径分隔符的项目名称" or "Enter a project name without path separators" -- 209
			end -- 209
			____cond31 = ____cond31 or ____switch31 == "target-existed" -- 209
			if ____cond31 then -- 209
				return zh and "已有同名项目，请换一个名称" or "A project with that name already exists" -- 210
			end -- 210
			____cond31 = ____cond31 or ____switch31 == "create-folder-failed" -- 210
			if ____cond31 then -- 210
				return zh and "无法创建项目目录，请检查工作目录后重试" or "Could not create the project folder; check the workspace and retry" -- 211
			end -- 211
			____cond31 = ____cond31 or ____switch31 == "create-entry-failed" -- 211
			if ____cond31 then -- 211
				return zh and "无法写入项目入口，未完成项目已回滚" or "Could not write the project entry; the incomplete project was rolled back" -- 212
			end -- 212
			____cond31 = ____cond31 or ____switch31 == "created-project-not-found" -- 212
			if ____cond31 then -- 212
				return zh and "项目已创建，但本地列表未能找到它，请返回后重试" or "The project was created but could not be found in Local; return and retry" -- 213
			end -- 213
			do -- 213
				return zh and "创建失败，请重试" or "Project creation failed; try again" -- 214
			end -- 214
		until true -- 214
	end -- 207
	submitCreate = function() -- 217
		if not options.createProject or creating or not createOpen or not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 then -- 217
			return -- 218
		end -- 218
		if createInput.isComposing() then -- 218
			return -- 219
		end -- 219
		creating = true -- 220
		createError = "" -- 221
		blurCreateInput() -- 222
		render() -- 223
		local result = options.createProject(createName, createLanguage) -- 224
		if not isActive() then -- 224
			return -- 225
		end -- 225
		creating = false -- 226
		if not result.success then -- 226
			createError = createErrorText(result.error) -- 228
			render() -- 229
			return -- 230
		end -- 230
		createOpen = false -- 232
		createName = "" -- 233
		____local = getLocalEntries() -- 234
		returnEntry = result.entry -- 235
		local location = resolveFeedLocation(____local, discover, result.entry) -- 236
		tab = location.tab -- 237
		index = location.index -- 238
		render() -- 239
		onRemix(result.entry) -- 240
	end -- 217
	local function openPackage(mode, path, pickOnOpen) -- 243
		if pickOnOpen == nil then -- 243
			pickOnOpen = false -- 243
		end -- 243
		if not isActive() or not host.visible or packagePanel or preparing or transitioning or creating or createOpen or HttpServer.wsConnectionCount > 0 then -- 243
			return -- 244
		end -- 244
		projectIndexOpen = false -- 245
		packagePanel = startPackagePanel({ -- 246
			mode = mode, -- 247
			path = path, -- 247
			pickOnOpen = pickOnOpen, -- 247
			entry = current(), -- 247
			onNew = openCreate, -- 248
			onClosed = function() -- 249
				packagePanel = nil -- 249
			end, -- 249
			onImported = function(entry, play) -- 250
				if not isActive() then -- 250
					return -- 251
				end -- 251
				____local = getLocalEntries(entry.workDir) -- 252
				local imported = __TS__ArrayFind( -- 253
					____local, -- 253
					function(____, item) return item.workDir == entry.workDir end -- 253
				) or entry -- 253
				returnEntry = imported -- 254
				local location = resolveFeedLocation(____local, discover, imported) -- 255
				tab = "local" -- 256
				index = location.index -- 256
				render() -- 257
				if play then -- 257
					onPlay(imported) -- 258
				end -- 258
			end -- 250
		}) -- 250
	end -- 243
	local receiveElapsed = 0 -- 262
	host:schedule(function(dt) -- 263
		receiveElapsed = receiveElapsed + dt -- 264
		if receiveElapsed < 0.5 then -- 264
			return false -- 265
		end -- 265
		receiveElapsed = 0 -- 266
		if isActive() and host.visible and not packagePanel and not createOpen and not projectIndexOpen and not preparing and not transitioning and HttpServer.wsConnectionCount == 0 then -- 266
			local path = options.takeReceivedFile and options.takeReceivedFile() or App:takeReceivedFile() -- 268
			if path ~= "" then -- 268
				openPackage("receive", path) -- 269
			end -- 269
		end -- 269
		return false -- 271
	end) -- 263
	local function setTab(next) -- 274
		if not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 or preparing or creating then -- 274
			return -- 275
		end -- 275
		userSelectedTab = true -- 276
		returnEntry = nil -- 277
		if tab == next then -- 277
			return -- 278
		end -- 278
		if createOpen then -- 278
			blurCreateInput() -- 280
			createOpen = false -- 281
			createName = "" -- 282
			createError = "" -- 283
		end -- 283
		tab = next -- 285
		local target = rememberedEntries[next] -- 286
		local ____temp_11 -- 287
		if target == nil then -- 287
			____temp_11 = nil -- 287
		else -- 287
			____temp_11 = resolveFeedLocation(____local, discover, target) -- 287
		end -- 287
		local location = ____temp_11 -- 287
		index = (location and location.tab) == next and location.index or 0 -- 288
		render() -- 289
	end -- 274
	local function activate(action) -- 291
		local item = current() -- 292
		if not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 or not item or preparing then -- 292
			return -- 293
		end -- 293
		item.launchError = nil -- 294
		local function done() -- 295
			returnEntry = item -- 295
			local ____temp_14 -- 295
			if action == "play" then -- 295
				____temp_14 = onPlay(item) -- 295
			else -- 295
				____temp_14 = onRemix(item) -- 295
			end -- 295
			return ____temp_14 -- 295
		end -- 295
		if item.kind == "local" or item.installed then -- 295
			done() -- 296
			return -- 296
		end -- 296
		preparing = true -- 297
		prepareProgress = 0 -- 298
		prepareStatus = zh and "准备安装…" or "Preparing install…" -- 299
		render() -- 300
		local repairIncomplete = repairResourceId == item.id -- 301
		repairResourceId = "" -- 302
		prepare( -- 303
			item, -- 303
			repairIncomplete, -- 303
			function(progress, message) -- 303
				if not isActive() then -- 303
					return -- 304
				end -- 304
				prepareProgress = math.max( -- 305
					0, -- 305
					math.min(1, progress) -- 305
				) -- 305
				prepareStatus = message -- 306
				render() -- 307
			end, -- 303
			function(success, ready, message, repairable) -- 308
				if not isActive() then -- 308
					return -- 309
				end -- 309
				preparing = false -- 310
				if not success or not ready then -- 310
					repairResourceId = repairable and item.id or "" -- 312
					prepareStatus = message or (zh and "安装失败，点击按钮重试" or "Install failed; tap to retry") -- 313
					render() -- 314
					return -- 315
				end -- 315
				item.fileName = ready.fileName -- 317
				item.workDir = ready.workDir -- 318
				item.installed = true -- 319
				prepareStatus = "" -- 320
				if HttpServer.wsConnectionCount == 0 and host.visible then -- 320
					done() -- 321
				else -- 321
					render() -- 322
				end -- 322
			end -- 308
		) -- 308
	end -- 291
	local function commit(action) -- 326
		if not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 or preparing or transitioning then -- 326
			return -- 327
		end -- 327
		if action == "play" or action == "remix" then -- 327
			local card = cardRef.current -- 329
			if card then -- 329
				card.position = Vec2.zero -- 330
			end -- 330
		end -- 330
		repeat -- 330
			local ____switch67 = action -- 330
			local ____cond67 = ____switch67 == "previous" or ____switch67 == "next" -- 330
			if ____cond67 then -- 330
				do -- 330
					returnEntry = nil -- 335
					local target = normalizeFeedIndex( -- 336
						index + (action == "next" and 1 or -1), -- 336
						#entries() -- 336
					) -- 336
					if target == index then -- 336
						local card = cardRef.current -- 338
						if card then -- 338
							card:perform(Move(App.reducedMotion and 0 or 0.16, card.position, Vec2.zero, Ease.OutQuad)) -- 339
						end -- 339
						return -- 340
					end -- 340
					local duration = App.reducedMotion and 0 or 0.18 -- 342
					local function finish() -- 343
						if not isActive() then -- 343
							return -- 344
						end -- 344
						index = target -- 345
						transitioning = false -- 346
						App:vibrate(0.012) -- 347
						render() -- 348
					end -- 343
					local card = cardRef.current -- 350
					if duration > 0 and card then -- 350
						transitioning = true -- 352
						card:perform(Move( -- 353
							duration, -- 353
							card.position, -- 353
							Vec2(0, (action == "next" and 1 or -1) * App.safeArea.height), -- 353
							Ease.OutQuad -- 353
						)) -- 353
						thread(function() -- 354
							sleep(duration) -- 354
							finish() -- 354
						end) -- 354
					else -- 354
						finish() -- 355
					end -- 355
					return -- 356
				end -- 356
			end -- 356
			____cond67 = ____cond67 or ____switch67 == "play" -- 356
			if ____cond67 then -- 356
				activate("play") -- 358
				return -- 358
			end -- 358
			____cond67 = ____cond67 or ____switch67 == "remix" -- 358
			if ____cond67 then -- 358
				activate("remix") -- 359
				return -- 359
			end -- 359
			do -- 359
				return -- 360
			end -- 360
		until true -- 360
	end -- 326
	local function switchMode() -- 364
		if not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 or preparing or creating or createOpen or packagePanel or transitioning or not options.onSwitchMode then -- 364
			return -- 365
		end -- 365
		leaving = true -- 366
		options.onSwitchMode() -- 367
	end -- 364
	host:slot("SwitchUIMode", switchMode) -- 369
	render = function() -- 370
		if not isActive() then -- 370
			return -- 371
		end -- 371
		catalogStatusView = nil -- 372
		local safeContentWidth = App.safeArea.width - 40 -- 374
		local shortLandscapeInputWidth = safeContentWidth - 12 - math.min( -- 375
			300, -- 375
			math.floor(safeContentWidth * 0.42) -- 375
		) -- 375
		local expectedInputWidth = App.safeArea.width >= 760 and App.safeArea.height < 500 and shortLandscapeInputWidth or safeContentWidth -- 376
		local ____createOpen_17 = createOpen -- 377
		if ____createOpen_17 then -- 377
			local ____opt_15 = createInputRef.current -- 377
			____createOpen_17 = (____opt_15 and ____opt_15.width) == expectedInputWidth -- 377
		end -- 377
		local keptInput = ____createOpen_17 and createInputRef.current or nil -- 377
		local restoreFocus = createInput.isFocused() -- 378
		if keptInput ~= nil then -- 378
			keptInput:removeFromParent(false) -- 379
		end -- 379
		if not keptInput then -- 379
			createInput.unmount() -- 381
			createInputRef = reference() -- 382
		end -- 382
		local createPanelRef = reference() -- 384
		host:removeAllChildren() -- 385
		host.scaleX = App.devicePixelRatio -- 386
		host.scaleY = App.devicePixelRatio -- 387
		local ____App_visualSize_20 = App.visualSize -- 388
		local width = ____App_visualSize_20.width -- 388
		local height = ____App_visualSize_20.height -- 388
		local safe = App.safeArea -- 389
		local left = safe.left -- 390
		local bottom = safe.bottom -- 391
		local usableWidth = safe.width -- 392
		local usableHeight = safe.height -- 393
		local wide = usableWidth >= 760 -- 394
		local shortLandscape = wide and usableHeight < 500 -- 395
		local compact = not wide and usableHeight < 700 -- 396
		local compactLandscape = compact and usableWidth > usableHeight and usableHeight < 520 -- 397
		local landscapeTopLift = shortLandscape and 28 or 0 -- 398
		local data = entries() -- 399
		index = normalizeFeedIndex(index, #data) -- 400
		local item = current() -- 401
		rememberCurrent() -- 402
		local coverWidth = wide and math.min(usableWidth * 0.54, 680) or usableWidth - 32 -- 403
		local coverHeight = wide and math.min(usableHeight - 118, coverWidth * 0.72) or (compact and math.min(usableHeight * (compactLandscape and 0.43 or 0.49), coverWidth * 0.72) or math.min(usableHeight * 0.54, coverWidth * 1.12)) -- 404
		local coverX = left + 16 -- 409
		local coverY = wide and bottom + (usableHeight - coverHeight) / 2 - 12 + landscapeTopLift or bottom + usableHeight - coverHeight - 82 -- 410
		local infoX = wide and coverX + coverWidth + 28 or left + 20 -- 411
		local infoWidth = wide and usableWidth - coverWidth - 72 or usableWidth - 40 -- 412
		local infoTop = wide and bottom + usableHeight - 122 + landscapeTopLift or coverY - (compactLandscape and 28 or 30) -- 413
		local descriptionY = infoTop - (compactLandscape and 38 or 58) -- 414
		local actionsY = bottom + (compactLandscape and 18 or 24) -- 415
		local gestureHintY = bottom + (compactLandscape and 88 or 92) -- 416
		local buttonWidth = wide and math.min(190, (infoWidth - 12) / 2) or (infoWidth - 12) / 2 -- 417
		local fontScale = mobileFontScale -- 418
		local cardIndices = getReusableCardIndices(index, #data) -- 419
		local headerRenderOrder = 1000 -- 420
		local ____toNode_59 = toNode -- 422
		local ____React_createElement_58 = React.createElement -- 422
		local ____array_57 = __TS__SparseArrayNew( -- 422
			"node", -- 422
			{ -- 422
				tag = "mobile-feed-scene", -- 422
				x = -width / 2, -- 422
				y = -height / 2, -- 422
				width = width, -- 422
				height = height, -- 422
				anchorX = 0, -- 422
				anchorY = 0, -- 422
				touchEnabled = true, -- 422
				onTapBegan = function() -- 422
					drag = Vec2.zero -- 432
					dragAxis = "none" -- 433
					local ____opt_21 = cardRef.current -- 433
					if ____opt_21 ~= nil then -- 433
						____opt_21:stopAllActions() -- 434
					end -- 434
					if indexRef.current then -- 434
						indexRef.current.opacity = 1 -- 435
					end -- 435
				end, -- 431
				onTapMoved = function(touch) -- 431
					drag = drag:add(touch.delta) -- 438
					if dragAxis == "none" and math.max( -- 438
						math.abs(drag.x), -- 439
						math.abs(drag.y) -- 439
					) >= 12 then -- 439
						dragAxis = math.abs(drag.x) > math.abs(drag.y) * 1.2 and "horizontal" or "vertical" -- 440
					end -- 440
					if cardRef.current then -- 440
						local offset = dragAxis == "horizontal" and Vec2(drag.x * 0.18, 0) or (dragAxis == "vertical" and Vec2(0, drag.y * 0.12) or Vec2.zero) -- 443
						cardRef.current.position = offset -- 444
						if indexRef.current then -- 444
							local headerBottom = bottom + usableHeight - 72 -- 446
							local indexTop = coverY + coverHeight - 14 + offset.y -- 447
							indexRef.current.opacity = dragAxis == "vertical" and math.max( -- 448
								0, -- 449
								math.min(1, (headerBottom - indexTop) / 16) -- 449
							) or 1 -- 449
						end -- 449
					end -- 449
				end, -- 437
				onTapEnded = function() -- 437
					local action = resolveFeedGesture(drag.x, drag.y, usableWidth, usableHeight) -- 455
					drag = Vec2.zero -- 456
					dragAxis = "none" -- 457
					if indexRef.current then -- 457
						indexRef.current.opacity = 1 -- 458
					end -- 458
					if action == "none" and cardRef.current then -- 458
						local card = cardRef.current -- 460
						card:perform(Move(App.reducedMotion and 0 or 0.16, card.position, Vec2.zero, Ease.OutQuad)) -- 461
					end -- 461
					commit(action) -- 463
				end, -- 454
				onMouseWheel = function(delta) return commit(delta.y > 0 and "previous" or "next") end -- 454
			}, -- 454
			React.createElement(VerticalGradient, {width = width, height = height, topColor = 4279310117, bottomColor = 4278716943}) -- 454
		) -- 454
		local ____React_createElement_55 = React.createElement -- 454
		local ____temp_53 = {visible = not projectIndexOpen} -- 454
		local ____createOpen_38 -- 469
		if createOpen then -- 469
			____createOpen_38 = nil -- 469
		else -- 469
			local ____temp_37 -- 469
			if item ~= nil then -- 469
				local ____React_createElement_36 = React.createElement -- 469
				local ____array_35 = __TS__SparseArrayNew( -- 469
					"node", -- 469
					{tag = "mobile-feed-card-" .. item.id, ref = cardRef, key = (tab .. "-") .. item.id}, -- 469
					__TS__ArrayMap( -- 470
						cardIndices, -- 470
						function(____, cardIndex) return React.createElement(Cover, { -- 470
							key = (tab .. "-") .. data[cardIndex + 1].id, -- 470
							entry = data[cardIndex + 1], -- 470
							x = coverX, -- 470
							y = coverY + (index - cardIndex) * usableHeight, -- 470
							width = coverWidth, -- 470
							height = coverHeight -- 470
						}) end -- 470
					), -- 470
					React.createElement( -- 470
						"node", -- 470
						{ -- 470
							tag = "mobile-feed-index", -- 470
							ref = indexRef, -- 470
							order = 10, -- 470
							renderGroup = true, -- 470
							x = coverX + coverWidth - 62, -- 470
							y = coverY + coverHeight - 40, -- 470
							width = 48, -- 470
							height = 26, -- 470
							anchorX = 0, -- 470
							anchorY = 0, -- 470
							touchEnabled = true, -- 470
							swallowTouches = true, -- 470
							onTapped = openProjectIndex -- 470
						}, -- 470
						React.createElement( -- 470
							"clip-node", -- 470
							{ -- 470
								width = 48, -- 470
								height = 26, -- 470
								anchorX = 0, -- 470
								anchorY = 0, -- 470
								stencil = React.createElement(RoundedStencil, {width = 48, height = 26, radius = 13}) -- 470
							}, -- 470
							React.createElement( -- 470
								"draw-node", -- 470
								nil, -- 470
								React.createElement( -- 470
									"verts-shape", -- 470
									{verts = { -- 470
										{ -- 483
											Vec2(0, 0), -- 483
											3759281694 -- 483
										}, -- 483
										{ -- 483
											Vec2(48, 0), -- 483
											3759281694 -- 483
										}, -- 483
										{ -- 483
											Vec2(48, 26), -- 483
											3760730173 -- 483
										}, -- 483
										{ -- 484
											Vec2(0, 0), -- 484
											3759281694 -- 484
										}, -- 484
										{ -- 484
											Vec2(48, 26), -- 484
											3760730173 -- 484
										}, -- 484
										{ -- 484
											Vec2(0, 26), -- 484
											3760730173 -- 484
										} -- 484
									}} -- 484
								) -- 484
							) -- 484
						), -- 484
						React.createElement( -- 484
							"draw-node", -- 484
							{x = 0.5, y = 0.5}, -- 484
							React.createElement( -- 484
								"polygon-shape", -- 484
								{ -- 484
									verts = roundedRectVerts(47, 25, 12.5), -- 484
									fillColor = 0, -- 484
									borderWidth = 0.5, -- 484
									borderColor = 2286967404 -- 484
								} -- 484
							) -- 484
						), -- 484
						React.createElement( -- 484
							"draw-node", -- 484
							{x = 18, y = 2}, -- 484
							React.createElement( -- 484
								"polygon-shape", -- 484
								{ -- 484
									verts = roundedRectVerts(12, 2, 1), -- 484
									fillColor = colors.brand -- 484
								} -- 484
							) -- 484
						), -- 484
						React.createElement( -- 484
							"label", -- 484
							{ -- 484
								x = 24, -- 484
								y = 13, -- 484
								fontName = fontName, -- 484
								fontSize = 11, -- 484
								text = (tostring(index + 1) .. " / ") .. tostring(#data), -- 484
								color3 = 14146531 -- 484
							} -- 484
						) -- 484
					), -- 484
					React.createElement( -- 484
						"label", -- 484
						{ -- 484
							tag = "mobile-feed-current-title", -- 484
							x = infoX, -- 484
							y = infoTop, -- 484
							anchorX = 0, -- 484
							anchorY = 0.5, -- 484
							fontName = fontName, -- 484
							fontSize = math.floor((wide and 30 or 25) * fontScale), -- 484
							text = item.title, -- 484
							textWidth = infoWidth - (item.kind == "local" and canShare and 92 or 0), -- 484
							alignment = "Left", -- 484
							color3 = 16052712 -- 484
						} -- 484
					) -- 484
				) -- 484
				local ____temp_23 -- 493
				if item.kind == "local" and canShare then -- 493
					____temp_23 = React.createElement( -- 493
						MobileButton, -- 493
						{ -- 493
							tag = "mobile-feed-share", -- 493
							x = infoX + infoWidth - 84, -- 493
							y = infoTop - 18, -- 493
							width = 84, -- 493
							height = 36, -- 493
							text = zh and "分享作品" or "Share", -- 493
							fontSize = 13, -- 493
							onTapped = function() return openPackage("share") end -- 493
						} -- 493
					) -- 493
				else -- 493
					____temp_23 = nil -- 493
				end -- 493
				__TS__SparseArrayPush( -- 493
					____array_35, -- 493
					____temp_23, -- 493
					React.createElement( -- 493
						"label", -- 493
						{ -- 493
							tag = "mobile-feed-description", -- 493
							x = infoX, -- 493
							y = descriptionY, -- 493
							anchorX = 0, -- 493
							anchorY = 0.5, -- 493
							fontName = fontName, -- 493
							fontSize = math.floor(15 * fontScale), -- 493
							text = conciseDescription(item.description, wide and 80 or (compact and 28 or 42)), -- 493
							textWidth = infoWidth, -- 493
							alignment = "Left", -- 493
							color3 = 11055037 -- 493
						} -- 493
					) -- 493
				) -- 493
				local ____temp_24 -- 496
				if compact or shortLandscape then -- 496
					____temp_24 = nil -- 496
				else -- 496
					____temp_24 = React.createElement( -- 496
						"node", -- 496
						{ -- 496
							x = infoX, -- 496
							y = infoTop - 118, -- 496
							width = wide and 176 or 164, -- 496
							height = 28, -- 496
							anchorX = 0, -- 496
							anchorY = 0 -- 496
						}, -- 496
						React.createElement(RoundedSurface, { -- 496
							width = wide and 176 or 164, -- 496
							height = 28, -- 496
							radius = 14, -- 496
							topColor = 1714436683, -- 496
							bottomColor = 1712857131, -- 496
							borderWidth = 1, -- 496
							borderColor = 2288020349 -- 496
						}), -- 496
						React.createElement("label", { -- 496
							x = 12, -- 496
							y = 14, -- 496
							anchorX = 0, -- 496
							fontName = fontName, -- 496
							fontSize = 12, -- 496
							text = item.kind == "local" and (zh and "本地作品  ·  可 Remix" or "Local  ·  Remixable") or (item.installed and (zh and "发现  ·  已安装" or "Discover  ·  Installed") or (zh and "发现  ·  可安装" or "Discover  ·  Installable")), -- 496
							textWidth = (wide and 176 or 164) - 24, -- 496
							alignment = "Left", -- 496
							color3 = 14475754 -- 496
						}) -- 496
					) -- 496
				end -- 496
				__TS__SparseArrayPush(____array_35, ____temp_24) -- 496
				local ____preparing_33 -- 502
				if preparing then -- 502
					local ____React_createElement_32 = React.createElement -- 502
					local ____array_31 = __TS__SparseArrayNew( -- 502
						"node", -- 502
						{ -- 502
							tag = "mobile-feed-download", -- 502
							x = infoX, -- 502
							y = actionsY, -- 502
							width = infoWidth, -- 502
							height = 48, -- 502
							anchorX = 0, -- 502
							anchorY = 0 -- 502
						}, -- 502
						React.createElement("label", { -- 502
							x = 0, -- 502
							y = 38, -- 502
							anchorX = 0, -- 502
							fontName = fontName, -- 502
							fontSize = 14, -- 502
							text = zh and "正在下载作品" or "Downloading game", -- 502
							color3 = 16763955 -- 502
						}), -- 502
						React.createElement( -- 502
							"label", -- 502
							{ -- 502
								tag = "mobile-feed-download-percent", -- 502
								x = infoWidth, -- 502
								y = 38, -- 502
								anchorX = 1, -- 502
								fontName = fontName, -- 502
								fontSize = 14, -- 502
								text = tostring(math.floor(prepareProgress * 100)) .. "%", -- 502
								color3 = 16763955 -- 502
							} -- 502
						) -- 502
					) -- 502
					local ____React_createElement_30 = React.createElement -- 502
					local ____temp_28 = { -- 502
						tag = "mobile-feed-download-track", -- 502
						width = infoWidth, -- 502
						height = 8, -- 502
						y = 8, -- 502
						anchorX = 0, -- 502
						anchorY = 0 -- 502
					} -- 502
					local ____React_createElement_result_29 = React.createElement(RoundedSurface, {width = infoWidth, height = 8, radius = 4, fillColor = 4280889664}) -- 502
					local ____React_createElement_27 = React.createElement -- 502
					local ____temp_26 = { -- 502
						tag = "mobile-feed-download-fill", -- 502
						width = infoWidth * prepareProgress, -- 502
						height = 8, -- 502
						anchorX = 0, -- 502
						anchorY = 0 -- 502
					} -- 502
					local ____temp_25 -- 508
					if prepareProgress > 0 then -- 508
						____temp_25 = React.createElement(RoundedSurface, { -- 508
							width = infoWidth * prepareProgress, -- 508
							height = 8, -- 508
							radius = 4, -- 508
							topColor = 4294958955, -- 508
							bottomColor = 4294950190 -- 508
						}) -- 508
					else -- 508
						____temp_25 = nil -- 508
					end -- 508
					__TS__SparseArrayPush( -- 508
						____array_31, -- 508
						____React_createElement_30( -- 508
							"node", -- 508
							____temp_28, -- 508
							____React_createElement_result_29, -- 508
							____React_createElement_27("node", ____temp_26, ____temp_25) -- 508
						) -- 508
					) -- 508
					____preparing_33 = ____React_createElement_32(__TS__SparseArraySpread(____array_31)) -- 508
				else -- 508
					____preparing_33 = React.createElement( -- 508
						"node", -- 508
						nil, -- 508
						React.createElement( -- 508
							MobileButton, -- 512
							{ -- 512
								tag = "mobile-feed-remix", -- 512
								x = infoX, -- 512
								y = actionsY, -- 512
								width = buttonWidth, -- 512
								text = zh and "Remix 作品" or "Remix game", -- 512
								fontSize = math.floor(16 * fontScale), -- 512
								primary = true, -- 512
								onTapped = function() return activate("remix") end -- 512
							} -- 512
						), -- 512
						React.createElement( -- 512
							MobileButton, -- 514
							{ -- 514
								tag = "mobile-feed-play", -- 514
								x = infoX + buttonWidth + 12, -- 514
								y = actionsY, -- 514
								width = buttonWidth, -- 514
								text = zh and "试玩" or "Play", -- 514
								fontSize = math.floor(17 * fontScale), -- 514
								onTapped = function() return activate("play") end -- 514
							} -- 514
						) -- 514
					) -- 514
				end -- 514
				__TS__SparseArrayPush(____array_35, ____preparing_33) -- 514
				local ____preparing_34 -- 517
				if preparing then -- 517
					____preparing_34 = React.createElement( -- 517
						"clip-node", -- 517
						{ -- 517
							tag = "mobile-feed-download-message-clip", -- 517
							x = infoX, -- 517
							y = gestureHintY - 10, -- 517
							width = infoWidth, -- 517
							height = 20, -- 517
							anchorX = 0, -- 517
							anchorY = 0, -- 517
							stencil = React.createElement(RoundedStencil, {width = infoWidth, height = 20, radius = 0}) -- 517
						}, -- 517
						React.createElement("label", { -- 517
							tag = "mobile-feed-download-message", -- 517
							x = 0, -- 517
							y = 10, -- 517
							anchorX = 0, -- 517
							fontName = fontName, -- 517
							fontSize = 12, -- 517
							text = (string.gsub(prepareStatus, "[\r\n]+", " ")), -- 517
							textWidth = -1, -- 517
							color3 = 11055037 -- 517
						}) -- 517
					) -- 517
				else -- 517
					____preparing_34 = React.createElement("label", { -- 517
						tag = "mobile-feed-gesture-hint", -- 517
						x = infoX, -- 517
						y = gestureHintY, -- 517
						anchorX = 0, -- 517
						anchorY = 0.5, -- 517
						fontName = fontName, -- 517
						fontSize = gamepadUsed and 11 or 14, -- 517
						text = prepareStatus ~= "" and prepareStatus or (item.launchError ~= nil and item.launchError or (gamepadUsed and (zh and "↑↓ 浏览 · A 确认 · X Remix · Start 列表 · Y 新建" or "↑↓ Browse · A Select · X Remix · Start List · Y New") or (zh and "上滑浏览  ·  右滑 Remix  ·  左滑试玩" or "Swipe up  ·  right Remix  ·  left Play"))), -- 517
						textWidth = infoWidth, -- 517
						alignment = "Left", -- 517
						color3 = item.launchError ~= nil and 16739179 or 11055037 -- 517
					}) -- 517
				end -- 517
				__TS__SparseArrayPush(____array_35, ____preparing_34) -- 517
				____temp_37 = ____React_createElement_36(__TS__SparseArraySpread(____array_35)) -- 517
			else -- 517
				____temp_37 = React.createElement( -- 517
					"node", -- 517
					nil, -- 517
					React.createElement("label", { -- 517
						x = left + usableWidth / 2, -- 517
						y = bottom + usableHeight / 2 + 20, -- 517
						fontName = fontName, -- 517
						fontSize = 22, -- 517
						text = tab == "discover" and (zh and "暂无移动作品" or "No mobile games yet") or (zh and "没有可运行的本地作品" or "No runnable local games"), -- 517
						color3 = 16052712 -- 517
					}), -- 517
					React.createElement("label", { -- 517
						x = left + usableWidth / 2, -- 517
						y = bottom + usableHeight / 2 - 28, -- 517
						fontName = fontName, -- 517
						fontSize = 14, -- 517
						text = tab == "discover" and discoverError ~= "" and discoverError or (zh and "切换标签或稍后重试" or "Switch tabs or retry later"), -- 517
						textWidth = usableWidth - 48, -- 517
						color3 = tab == "discover" and discoverError ~= "" and 16739179 or 11055037 -- 517
					}) -- 517
				) -- 517
			end -- 517
			____createOpen_38 = ____temp_37 -- 469
		end -- 469
		local ____temp_39 -- 533
		if not createOpen and not item and tab == "local" then -- 533
			____temp_39 = React.createElement( -- 533
				"node", -- 533
				nil, -- 533
				React.createElement(MobileButton, { -- 533
					tag = "mobile-empty-new", -- 533
					x = left + 20, -- 533
					y = bottom + 24, -- 533
					width = (usableWidth - 52) / 2, -- 533
					text = zh and "新建作品" or "New game", -- 533
					onTapped = openCreate -- 533
				}), -- 533
				React.createElement( -- 533
					MobileButton, -- 535
					{ -- 535
						tag = "mobile-empty-import", -- 535
						x = left + 32 + (usableWidth - 52) / 2, -- 535
						y = bottom + 24, -- 535
						width = (usableWidth - 52) / 2, -- 535
						text = zh and "导入作品包" or "Import package", -- 535
						fontSize = 15, -- 535
						primary = true, -- 535
						onTapped = function() return openPackage("add", nil, true) end -- 535
					} -- 535
				) -- 535
			) -- 535
		else -- 535
			____temp_39 = nil -- 536
		end -- 536
		local ____temp_40 -- 537
		if not item and tab == "discover" and syncDiscover then -- 537
			____temp_40 = React.createElement(MobileButton, { -- 537
				tag = "mobile-feed-empty-index", -- 537
				x = left + (usableWidth - 160) / 2, -- 537
				y = bottom + 24, -- 537
				width = 160, -- 537
				text = zh and "作品目录" or "Game index", -- 537
				onTapped = openProjectIndex -- 537
			}) -- 537
		else -- 537
			____temp_40 = nil -- 538
		end -- 538
		local ____React_createElement_44 = React.createElement -- 538
		local ____array_43 = __TS__SparseArrayNew("node", {tag = "mobile-feed-header", order = headerRenderOrder}) -- 538
		local ____options_onSwitchMode_41 -- 540
		if options.onSwitchMode then -- 540
			____options_onSwitchMode_41 = React.createElement( -- 540
				"node", -- 540
				{ -- 540
					tag = "mobile-ui-mode-switch", -- 540
					x = left + 12, -- 540
					y = bottom + usableHeight - 58 + landscapeTopLift, -- 540
					width = 72, -- 540
					height = 48, -- 540
					anchorX = 0, -- 540
					anchorY = 0, -- 540
					touchEnabled = true, -- 540
					swallowTouches = true, -- 540
					onTapped = switchMode -- 540
				}, -- 540
				React.createElement("label", { -- 540
					x = 0, -- 540
					y = 30, -- 540
					anchorX = 0, -- 540
					fontName = fontName, -- 540
					fontSize = 16, -- 540
					text = "DORA", -- 540
					color3 = preparing and 7831180 or 16763955 -- 540
				}), -- 540
				React.createElement("label", { -- 540
					x = 0, -- 540
					y = 10, -- 540
					anchorX = 0, -- 540
					fontName = fontName, -- 540
					fontSize = 10, -- 540
					text = zh and "切换传统界面" or "Classic UI", -- 540
					color3 = 7831180 -- 540
				}) -- 540
			) -- 540
		else -- 540
			____options_onSwitchMode_41 = nil -- 544
		end -- 544
		__TS__SparseArrayPush( -- 544
			____array_43, -- 544
			____options_onSwitchMode_41, -- 544
			React.createElement( -- 544
				"label", -- 544
				{ -- 544
					tag = "mobile-feed-discover-tab", -- 544
					x = left + usableWidth / 2 - 44, -- 544
					y = bottom + usableHeight - 34 + landscapeTopLift, -- 544
					fontName = fontName, -- 544
					fontSize = math.floor(17 * fontScale), -- 544
					text = zh and "发现" or "Discover", -- 544
					color3 = tab == "discover" and 16763955 or 11055037, -- 544
					touchEnabled = true, -- 544
					swallowTouches = true, -- 544
					onTapped = function() return setTab("discover") end -- 544
				} -- 544
			), -- 544
			React.createElement( -- 544
				"label", -- 544
				{ -- 544
					tag = "mobile-feed-local-tab", -- 544
					x = left + usableWidth / 2 + 44, -- 544
					y = bottom + usableHeight - 34 + landscapeTopLift, -- 544
					fontName = fontName, -- 544
					fontSize = math.floor(17 * fontScale), -- 544
					text = zh and "本地" or "Local", -- 544
					color3 = tab == "local" and 16763955 or 11055037, -- 544
					touchEnabled = true, -- 544
					swallowTouches = true, -- 544
					onTapped = function() -- 544
						____local = getLocalEntries() -- 550
						setTab("local") -- 550
					end -- 550
				} -- 550
			), -- 550
			React.createElement(RoundedSurface, { -- 550
				x = left + usableWidth / 2 + (tab == "discover" and -58 or 30), -- 550
				y = bottom + usableHeight - 56 + landscapeTopLift, -- 550
				width = 28, -- 550
				height = 3, -- 550
				radius = 1.5, -- 550
				fillColor = colors.brand, -- 550
				renderOrder = headerRenderOrder + 1 -- 550
			}) -- 550
		) -- 550
		local ____temp_42 -- 552
		if tab == "local" and options.createProject then -- 552
			____temp_42 = React.createElement( -- 552
				MobileNewButton, -- 552
				{ -- 552
					tag = "mobile-feed-create", -- 552
					x = left + usableWidth - 82, -- 552
					y = bottom + usableHeight - 56 + landscapeTopLift, -- 552
					text = zh and "+ 新建" or "+ New", -- 552
					renderOrder = headerRenderOrder + 1, -- 552
					onTapped = function() return openPackage("add") end -- 552
				} -- 552
			) -- 552
		else -- 552
			____temp_42 = nil -- 554
		end -- 554
		__TS__SparseArrayPush(____array_43, ____temp_42) -- 554
		local ____React_createElement_44_result_54 = ____React_createElement_44(__TS__SparseArraySpread(____array_43)) -- 554
		local ____createOpen_52 -- 556
		if createOpen then -- 556
			____createOpen_52 = (function() -- 556
				local sheetHeight = math.min(createSheetHeight, usableHeight - 64) -- 557
				local sheetWidth = usableWidth -- 558
				local contentWidth = sheetWidth - 40 -- 559
				local actionGap = 12 -- 560
				local actionsWidth = shortLandscape and math.min( -- 561
					300, -- 561
					math.floor(contentWidth * 0.42) -- 561
				) or contentWidth -- 561
				local inputWidth = shortLandscape and contentWidth - actionGap - actionsWidth or contentWidth -- 562
				local actionX = shortLandscape and 20 + inputWidth + actionGap or 20 -- 563
				local actionY = shortLandscape and sheetHeight - createInputTop - createInputHeight or 20 -- 564
				local cancelWidth = math.floor((actionsWidth - actionGap) * (shortLandscape and 0.34 or 0.38)) -- 565
				local ____React_createElement_51 = React.createElement -- 565
				local ____array_50 = __TS__SparseArrayNew( -- 565
					"node", -- 565
					{ -- 565
						tag = "mobile-project-create-sheet", -- 565
						order = 10000, -- 565
						width = width, -- 565
						height = height, -- 565
						anchorX = 0, -- 565
						anchorY = 0, -- 565
						touchEnabled = true, -- 565
						swallowTouches = true -- 565
					}, -- 565
					React.createElement( -- 565
						"node", -- 565
						{ -- 565
							tag = "mobile-project-create-focus-observer", -- 565
							order = 1000, -- 565
							width = width, -- 565
							height = height, -- 565
							anchorX = 0, -- 565
							anchorY = 0, -- 565
							touchEnabled = true, -- 565
							swallowTouches = false, -- 565
							swallowMouseWheel = false, -- 565
							onTapFilter = function(touch) -- 565
								touch.enabled = false -- 569
								if not canEditCreate() then -- 569
									return -- 570
								end -- 570
								local input = createInputRef.current -- 571
								local point = input and input:convertToNodeSpace(touch.worldLocation) -- 572
								local inside = input and point and point.x >= 0 and point.y >= 0 and point.x <= input.width and point.y <= input.height -- 573
								dismissedCreateComposition = not inside and createInput.isComposing() -- 574
								if not inside then -- 574
									blurCreateInput() -- 575
								end -- 575
							end -- 568
						} -- 568
					), -- 568
					React.createElement( -- 568
						"draw-node", -- 568
						{ -- 568
							tag = "mobile-project-create-backdrop", -- 568
							order = 0, -- 568
							renderOrder = 0, -- 568
							x = width / 2, -- 568
							y = bottom + sheetHeight + (height - bottom - sheetHeight) / 2 -- 568
						}, -- 568
						React.createElement("rect-shape", {width = width, height = height - bottom - sheetHeight, fillColor = 2348810240}) -- 568
					) -- 568
				) -- 568
				local ____React_createElement_49 = React.createElement -- 568
				local ____array_48 = __TS__SparseArrayNew( -- 568
					"node", -- 568
					{ -- 568
						ref = createPanelRef, -- 568
						order = 10, -- 568
						renderOrder = 10, -- 568
						x = left, -- 568
						y = bottom, -- 568
						width = sheetWidth, -- 568
						height = sheetHeight, -- 568
						anchorX = 0, -- 568
						anchorY = 0, -- 568
						touchEnabled = true, -- 568
						swallowTouches = true -- 568
					}, -- 568
					React.createElement(MobilePanelSurface, {width = sheetWidth, height = sheetHeight, renderOrder = 10}), -- 568
					React.createElement("label", { -- 568
						x = 20, -- 568
						y = sheetHeight - 24, -- 568
						anchorX = 0, -- 568
						anchorY = 1, -- 568
						fontName = fontName, -- 568
						fontSize = 22, -- 568
						text = zh and "新建项目" or "New project", -- 568
						color3 = 16052712 -- 568
					}), -- 568
					__TS__ArrayMap( -- 583
						{"typescript", "lua"}, -- 583
						function(____, language, i) return React.createElement( -- 583
							MobileChoiceButton, -- 583
							{ -- 583
								tag = "mobile-project-create-language-" .. language, -- 583
								x = 20 + i * 144, -- 583
								y = sheetHeight - 98, -- 583
								width = language == "lua" and 84 or 132, -- 583
								text = language == "lua" and "Lua" or "TypeScript", -- 583
								selected = createLanguage == language, -- 583
								renderOrder = 10, -- 583
								onTapped = function() -- 583
									if not canEditCreate() then -- 583
										return -- 587
									end -- 587
									blurCreateInput() -- 588
									createLanguage = language -- 588
									render() -- 588
								end -- 586
							} -- 586
						) end -- 586
					), -- 586
					React.createElement("label", { -- 586
						x = 20, -- 586
						y = sheetHeight - 110, -- 586
						anchorX = 0, -- 586
						anchorY = 1, -- 586
						fontName = fontName, -- 586
						fontSize = 14, -- 586
						text = zh and "项目名称" or "Project name", -- 586
						color3 = 11055037 -- 586
					}) -- 586
				) -- 586
				local ____keptInput_47 -- 591
				if keptInput then -- 591
					____keptInput_47 = nil -- 591
				else -- 591
					____keptInput_47 = React.createElement("node", { -- 591
						tag = "mobile-project-create-input", -- 591
						ref = createInputRef, -- 591
						renderOrder = 10, -- 591
						x = 20, -- 591
						y = sheetHeight - createInputTop - createInputHeight, -- 591
						width = inputWidth, -- 591
						height = createInputHeight, -- 591
						anchorX = 0, -- 591
						anchorY = 0, -- 591
						onMount = createInput.mount -- 591
					}) -- 591
				end -- 591
				__TS__SparseArrayPush( -- 591
					____array_48, -- 591
					____keptInput_47, -- 591
					React.createElement("label", { -- 591
						tag = "mobile-project-create-error", -- 591
						x = 20, -- 591
						y = shortLandscape and sheetHeight - createInputTop + 12 or sheetHeight - createInputTop - createInputHeight - 12, -- 591
						anchorX = 0, -- 591
						anchorY = 1, -- 591
						fontName = fontName, -- 591
						fontSize = 12, -- 591
						text = createError ~= "" and createError or (zh and ("将创建可运行的 " .. (createLanguage == "lua" and "Lua" or "TypeScript")) .. " 起始项目" or ("Creates a runnable " .. (createLanguage == "lua" and "Lua" or "TypeScript")) .. " starter project"), -- 591
						textWidth = inputWidth, -- 591
						alignment = "Left", -- 591
						color3 = createError ~= "" and 16739179 or 11055037 -- 591
					}), -- 591
					React.createElement(MobileButton, { -- 591
						tag = "mobile-project-create-cancel", -- 591
						x = actionX, -- 591
						y = actionY, -- 591
						width = cancelWidth, -- 591
						text = zh and "取消" or "Cancel", -- 591
						renderOrder = 10, -- 591
						onTapped = closeCreate -- 591
					}), -- 591
					React.createElement( -- 591
						MobileButton, -- 597
						{ -- 597
							tag = "mobile-project-create-submit", -- 597
							x = actionX + cancelWidth + actionGap, -- 597
							y = actionY, -- 597
							width = actionsWidth - cancelWidth - actionGap, -- 597
							text = creating and (zh and "创建中…" or "Creating…") or (zh and "创建并进入 Remix" or "Create and Remix"), -- 597
							primary = true, -- 597
							renderOrder = 10, -- 597
							onTapped = function() -- 597
								if not dismissedCreateComposition then -- 597
									submitCreate() -- 598
								end -- 598
								dismissedCreateComposition = false -- 598
							end -- 598
						} -- 598
					) -- 598
				) -- 598
				__TS__SparseArrayPush( -- 598
					____array_50, -- 598
					____React_createElement_49(__TS__SparseArraySpread(____array_48)) -- 598
				) -- 598
				return ____React_createElement_51(__TS__SparseArraySpread(____array_50)) -- 566
			end)() -- 556
		else -- 556
			____createOpen_52 = nil -- 601
		end -- 601
		__TS__SparseArrayPush( -- 601
			____array_57, -- 601
			____React_createElement_55( -- 601
				"node", -- 601
				____temp_53, -- 601
				____createOpen_38, -- 601
				____temp_39, -- 601
				____temp_40, -- 601
				____React_createElement_44_result_54, -- 601
				____createOpen_52 -- 601
			) -- 601
		) -- 601
		local ____projectIndexOpen_56 -- 603
		if projectIndexOpen then -- 603
			____projectIndexOpen_56 = React.createElement( -- 603
				ProjectIndex, -- 603
				{ -- 603
					entries = entries(), -- 603
					kind = tab, -- 603
					current = current(), -- 603
					x = left, -- 603
					y = bottom, -- 603
					width = usableWidth, -- 603
					height = usableHeight, -- 603
					zh = zh, -- 603
					refreshing = catalogSyncing, -- 603
					refreshStatus = catalogStatus, -- 603
					onRefresh = syncDiscover and (function() return refreshDiscover(true) end) or nil, -- 603
					onStatusReady = function(____, update) -- 603
						catalogStatusView = update -- 606
					end, -- 606
					onClose = function() -- 606
						projectIndexOpen = false -- 607
						render() -- 607
					end, -- 607
					onSelect = function(____, entry) -- 607
						projectIndexOpen = false -- 609
						local location = resolveFeedLocation(____local, discover, entry) -- 610
						tab = location.tab -- 611
						index = location.index -- 611
						render() -- 612
					end -- 608
				} -- 608
			) -- 608
		else -- 608
			____projectIndexOpen_56 = nil -- 613
		end -- 613
		__TS__SparseArrayPush(____array_57, ____projectIndexOpen_56) -- 613
		local scene = ____toNode_59(____React_createElement_58(__TS__SparseArraySpread(____array_57))) -- 422
		if scene ~= nil then -- 422
			host:addChild(scene) -- 615
		end -- 615
		if keptInput and createPanelRef.current then -- 615
			keptInput.position = Vec2( -- 617
				20, -- 617
				math.min(createSheetHeight, usableHeight - 64) - createInputTop - createInputHeight -- 617
			) -- 617
			createPanelRef.current:addChild(keptInput) -- 618
		end -- 618
		createInput.refresh() -- 620
		if restoreFocus and not keptInput and createOpen then -- 620
			createInput.focus(false) -- 621
		end -- 621
	end -- 370
	attachGamepad( -- 624
		host, -- 624
		{ -- 624
			initialTag = "mobile-feed-play", -- 625
			isEnabled = function() return isActive() and not packagePanel and not preparing and not transitioning and not creating end, -- 626
			onActive = function() -- 627
				gamepadUsed = true -- 627
				render() -- 627
			end, -- 627
			onBack = function() -- 628
				if createInput.isFocused() then -- 628
					blurCreateInput() -- 628
				elseif createOpen then -- 628
					closeCreate() -- 628
				else -- 628
					switchMode() -- 628
				end -- 628
			end, -- 628
			onActivate = function(target) -- 629
				if target.tag == "mobile-project-create-input" then -- 629
					target:emit("GamepadActivate") -- 630
				else -- 630
					if createInput.isComposing() then -- 630
						blurCreateInput() -- 632
						return -- 632
					end -- 632
					blurCreateInput() -- 633
					dismissedCreateComposition = false -- 634
					target:emit("Tapped") -- 635
				end -- 635
			end, -- 629
			onButton = function(button) -- 638
				if createOpen then -- 638
					return false -- 639
				end -- 639
				repeat -- 639
					local ____switch127 = button -- 639
					local ____cond127 = ____switch127 == "dpup" -- 639
					if ____cond127 then -- 639
						commit("previous") -- 641
						return true -- 641
					end -- 641
					____cond127 = ____cond127 or ____switch127 == "dpdown" -- 641
					if ____cond127 then -- 641
						commit("next") -- 642
						return true -- 642
					end -- 642
					____cond127 = ____cond127 or ____switch127 == "leftshoulder" -- 642
					if ____cond127 then -- 642
						setTab("discover") -- 643
						return true -- 643
					end -- 643
					____cond127 = ____cond127 or ____switch127 == "rightshoulder" -- 643
					if ____cond127 then -- 643
						setTab("local") -- 644
						return true -- 644
					end -- 644
					____cond127 = ____cond127 or ____switch127 == "x" -- 644
					if ____cond127 then -- 644
						commit("remix") -- 645
						return true -- 645
					end -- 645
					____cond127 = ____cond127 or ____switch127 == "y" -- 645
					if ____cond127 then -- 645
						local ____opt_60 = findGamepadNode(host, "mobile-feed-create") -- 645
						if ____opt_60 ~= nil then -- 645
							____opt_60:emit("Tapped") -- 646
						end -- 646
						return true -- 646
					end -- 646
					____cond127 = ____cond127 or ____switch127 == "start" -- 646
					if ____cond127 then -- 646
						openProjectIndex() -- 647
						return true -- 647
					end -- 647
					do -- 647
						return false -- 648
					end -- 648
				until true -- 648
			end -- 638
		} -- 638
	) -- 638
	host:onAppChange(function(setting) -- 652
		if setting == "Locale" then -- 652
			local activeEntry = current() -- 654
			zh = (string.match(App.locale, "^zh")) ~= nil -- 655
			____local = getLocalEntries() -- 656
			discover = getDiscoverEntries() -- 657
			local location = resolveFeedLocation(____local, discover, activeEntry) -- 658
			tab = location.tab -- 659
			index = location.index -- 660
			render() -- 661
		elseif setting == "Size" then -- 661
			render() -- 662
		end -- 662
	end) -- 652
	host:onAppEvent(function(event) -- 664
		if event == "BackButton" then -- 664
			if projectIndexOpen then -- 664
				projectIndexOpen = false -- 666
				render() -- 666
			elseif createOpen and not creating then -- 666
				closeCreate() -- 667
			end -- 667
		elseif event == "WillEnterBackground" or event == "DidEnterBackground" then -- 667
			blurCreateInput() -- 668
		end -- 668
	end) -- 664
	host:onCleanup(function() -- 670
		blurCreateInput() -- 670
		active = false -- 670
		if packagePanel ~= nil then -- 670
			packagePanel:removeFromParent(true) -- 670
		end -- 670
		packagePanel = nil -- 670
	end) -- 670
	host:slot( -- 671
		"RestoreFeedEntry", -- 671
		function(entry) -- 671
			if not isActive() or HttpServer.wsConnectionCount > 0 then -- 671
				return -- 672
			end -- 672
			returnEntry = entry -- 673
			____local = getLocalEntries() -- 674
			discover = getDiscoverEntries() -- 675
			local location = resolveFeedLocation(____local, discover, entry) -- 676
			tab = location.tab -- 677
			index = location.index -- 678
			render() -- 679
		end -- 671
	) -- 671
	host:slot("SuspendLocalUI", blurCreateInput) -- 681
	host:slot( -- 682
		"ResumeLocalUI", -- 682
		function() -- 682
			leaving = false -- 682
			render() -- 682
		end -- 682
	) -- 682
	refreshDiscover = function(force) -- 683
		if not syncDiscover or catalogSyncing or not isActive() then -- 683
			return -- 684
		end -- 684
		catalogSyncing = true -- 685
		catalogStatus = zh and "正在同步资源目录…" or "Syncing Catalog…" -- 686
		if #discover == 0 then -- 686
			discoverError = catalogStatus -- 688
		end -- 688
		render() -- 690
		syncDiscover( -- 691
			function(message) -- 691
				if not isActive() then -- 691
					return -- 692
				end -- 692
				catalogStatus = message -- 693
				if catalogStatusView ~= nil then -- 693
					catalogStatusView(message) -- 694
				end -- 694
				if projectIndexOpen or #discover > 0 then -- 694
					return -- 695
				end -- 695
				discoverError = message -- 696
				render() -- 697
			end, -- 691
			function(success, message) -- 698
				if not isActive() then -- 698
					return -- 699
				end -- 699
				catalogSyncing = false -- 700
				catalogStatus = success and (zh and "目录已更新" or "Catalog updated") or (zh and "刷新失败：" or "Refresh failed: ") .. (message or (zh and "请重试" or "Try again")) -- 701
				local selected = force and current() or (returnEntry or rememberedEntries[tab] or current()) -- 702
				local previousCount = #discover -- 703
				discover = getDiscoverEntries() -- 704
				discoverError = success and (#discover == 0 and (zh and "目录中暂无可运行作品" or "No runnable Catalog games") or "") or (message or (zh and "资源目录同步失败" or "Catalog sync failed")) -- 705
				if not force and not projectIndexOpen then -- 705
					tab = resolveDiscoverRefreshTab( -- 710
						tab, -- 710
						userSelectedTab, -- 710
						previousCount, -- 710
						#discover, -- 710
						#____local -- 710
					) -- 710
				end -- 710
				if selected ~= nil then -- 710
					local location = resolveFeedLocation(____local, discover, selected) -- 712
					if location.tab == tab then -- 712
						index = location.index -- 713
					end -- 713
				end -- 713
				index = normalizeFeedIndex( -- 715
					index, -- 715
					#entries() -- 715
				) -- 715
				render() -- 716
			end, -- 698
			force -- 717
		) -- 717
	end -- 683
	render() -- 719
	refreshDiscover(false) -- 720
	return host -- 721
end -- 98
return ____exports -- 98