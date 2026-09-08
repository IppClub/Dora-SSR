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
	local submitCreate, render -- 98
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
	local repairResourceId = "" -- 115
	local userSelectedTab = false -- 116
	local active = true -- 117
	local leaving = false -- 118
	local packagePanel -- 119
	local createOpen = false -- 120
	local projectIndexOpen = false -- 121
	local creating = false -- 122
	local createName = "" -- 123
	local createLanguage = "typescript" -- 124
	local dismissedCreateComposition = false -- 125
	local createError = "" -- 126
	local gamepadUsed = false -- 127
	local returnEntry = options.initialEntry -- 128
	local ____opt_6 = options.initialEntries -- 128
	local ____temp_10 = ____opt_6 and ____opt_6["local"] -- 130
	local ____opt_8 = options.initialEntries -- 130
	local rememberedEntries = {["local"] = ____temp_10, discover = ____opt_8 and ____opt_8.discover} -- 129
	local cardRef = reference() -- 133
	local indexRef = reference() -- 134
	local createInputRef = reference() -- 135
	local discover = getDiscoverEntries() -- 136
	local ____local = getLocalEntries() -- 137
	if #discover == 0 then -- 137
		discoverError = zh and "资源目录暂不可用" or "Catalog is unavailable" -- 140
	end -- 140
	local initialLocation = resolveFeedLocation(____local, discover, returnEntry) -- 142
	tab = initialLocation.tab -- 143
	index = initialLocation.index -- 144
	local host = Node() -- 146
	host.tag = "mobile-feed" -- 147
	host.scaleX = App.devicePixelRatio -- 148
	host.scaleY = App.devicePixelRatio -- 149
	host:addTo(Director.systemUI) -- 150
	local function isActive() -- 152
		return active and not leaving and host.parent ~= nil -- 152
	end -- 152
	local function entries() -- 154
		return tab == "discover" and discover or ____local -- 154
	end -- 154
	local function current() -- 155
		return entries()[normalizeFeedIndex( -- 155
			index, -- 155
			#entries() -- 155
		) + 1] -- 155
	end -- 155
	local rememberedEntryKey = "" -- 156
	local function rememberCurrent() -- 157
		local item = current() -- 158
		if not item or not options.onCurrentEntryChanged then -- 158
			return -- 159
		end -- 159
		local key = (((((item.kind .. "\n") .. item.id) .. "\n") .. (item.workDir or "")) .. "\n") .. (item.fileName or "") -- 160
		if key == rememberedEntryKey then -- 160
			return -- 161
		end -- 161
		rememberedEntryKey = key -- 162
		rememberedEntries[item.kind] = item -- 163
		options.onCurrentEntryChanged(item) -- 164
	end -- 157
	local function canEditCreate() -- 166
		return createOpen and not creating and isActive() and host.visible and HttpServer.wsConnectionCount == 0 -- 166
	end -- 166
	local createInput = createTextInput({ -- 167
		fontSize = math.floor(16 * mobileFontScale), -- 168
		singleLine = true, -- 169
		background = colors.background, -- 170
		getText = function() return createName end, -- 171
		setText = function(text) -- 172
			createName = text -- 172
		end, -- 172
		getPlaceholder = function() return zh and "例如：星际花园" or "For example: Star Garden" end, -- 173
		isEnabled = canEditCreate, -- 174
		onReturn = function() -- 175
			submitCreate() -- 175
			return true -- 175
		end -- 175
	}) -- 175
	local blurCreateInput = createInput.blur -- 177
	local function closeCreate() -- 178
		if creating then -- 178
			return -- 179
		end -- 179
		blurCreateInput() -- 180
		createOpen = false -- 181
		createName = "" -- 182
		createError = "" -- 183
		render() -- 184
	end -- 178
	local function openCreate() -- 186
		if not options.createProject or preparing or transitioning or creating or createOpen or HttpServer.wsConnectionCount > 0 then -- 186
			return -- 187
		end -- 187
		projectIndexOpen = false -- 188
		createOpen = true -- 189
		createLanguage = "typescript" -- 190
		createName = "" -- 191
		dismissedCreateComposition = false -- 192
		createError = "" -- 193
		render() -- 194
		createInput.deferFocus() -- 195
	end -- 186
	local function openProjectIndex() -- 197
		if preparing or transitioning or creating or createOpen or HttpServer.wsConnectionCount > 0 then -- 197
			return -- 198
		end -- 198
		if tab == "local" then -- 198
			____local = getLocalEntries() -- 199
		end -- 199
		projectIndexOpen = true -- 200
		render() -- 201
	end -- 197
	local function createErrorText(____error) -- 203
		repeat -- 203
			local ____switch31 = ____error -- 203
			local ____cond31 = ____switch31 == "invalid-name" -- 203
			if ____cond31 then -- 203
				return zh and "请输入不含路径分隔符的项目名称" or "Enter a project name without path separators" -- 205
			end -- 205
			____cond31 = ____cond31 or ____switch31 == "target-existed" -- 205
			if ____cond31 then -- 205
				return zh and "已有同名项目，请换一个名称" or "A project with that name already exists" -- 206
			end -- 206
			____cond31 = ____cond31 or ____switch31 == "create-folder-failed" -- 206
			if ____cond31 then -- 206
				return zh and "无法创建项目目录，请检查工作目录后重试" or "Could not create the project folder; check the workspace and retry" -- 207
			end -- 207
			____cond31 = ____cond31 or ____switch31 == "create-entry-failed" -- 207
			if ____cond31 then -- 207
				return zh and "无法写入项目入口，未完成项目已回滚" or "Could not write the project entry; the incomplete project was rolled back" -- 208
			end -- 208
			____cond31 = ____cond31 or ____switch31 == "created-project-not-found" -- 208
			if ____cond31 then -- 208
				return zh and "项目已创建，但本地列表未能找到它，请返回后重试" or "The project was created but could not be found in Local; return and retry" -- 209
			end -- 209
			do -- 209
				return zh and "创建失败，请重试" or "Project creation failed; try again" -- 210
			end -- 210
		until true -- 210
	end -- 203
	submitCreate = function() -- 213
		if not options.createProject or creating or not createOpen or not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 then -- 213
			return -- 214
		end -- 214
		if createInput.isComposing() then -- 214
			return -- 215
		end -- 215
		creating = true -- 216
		createError = "" -- 217
		blurCreateInput() -- 218
		render() -- 219
		local result = options.createProject(createName, createLanguage) -- 220
		if not isActive() then -- 220
			return -- 221
		end -- 221
		creating = false -- 222
		if not result.success then -- 222
			createError = createErrorText(result.error) -- 224
			render() -- 225
			return -- 226
		end -- 226
		createOpen = false -- 228
		createName = "" -- 229
		____local = getLocalEntries() -- 230
		returnEntry = result.entry -- 231
		local location = resolveFeedLocation(____local, discover, result.entry) -- 232
		tab = location.tab -- 233
		index = location.index -- 234
		render() -- 235
		onRemix(result.entry) -- 236
	end -- 213
	local function openPackage(mode, path, pickOnOpen) -- 239
		if pickOnOpen == nil then -- 239
			pickOnOpen = false -- 239
		end -- 239
		if not isActive() or not host.visible or packagePanel or preparing or transitioning or creating or createOpen or HttpServer.wsConnectionCount > 0 then -- 239
			return -- 240
		end -- 240
		projectIndexOpen = false -- 241
		packagePanel = startPackagePanel({ -- 242
			mode = mode, -- 243
			path = path, -- 243
			pickOnOpen = pickOnOpen, -- 243
			entry = current(), -- 243
			onNew = openCreate, -- 244
			onClosed = function() -- 245
				packagePanel = nil -- 245
			end, -- 245
			onImported = function(entry, play) -- 246
				if not isActive() then -- 246
					return -- 247
				end -- 247
				____local = getLocalEntries(entry.workDir) -- 248
				local imported = __TS__ArrayFind( -- 249
					____local, -- 249
					function(____, item) return item.workDir == entry.workDir end -- 249
				) or entry -- 249
				returnEntry = imported -- 250
				local location = resolveFeedLocation(____local, discover, imported) -- 251
				tab = "local" -- 252
				index = location.index -- 252
				render() -- 253
				if play then -- 253
					onPlay(imported) -- 254
				end -- 254
			end -- 246
		}) -- 246
	end -- 239
	local receiveElapsed = 0 -- 258
	host:schedule(function(dt) -- 259
		receiveElapsed = receiveElapsed + dt -- 260
		if receiveElapsed < 0.5 then -- 260
			return false -- 261
		end -- 261
		receiveElapsed = 0 -- 262
		if isActive() and host.visible and not packagePanel and not createOpen and not projectIndexOpen and not preparing and not transitioning and HttpServer.wsConnectionCount == 0 then -- 262
			local path = options.takeReceivedFile and options.takeReceivedFile() or App:takeReceivedFile() -- 264
			if path ~= "" then -- 264
				openPackage("receive", path) -- 265
			end -- 265
		end -- 265
		return false -- 267
	end) -- 259
	local function setTab(next) -- 270
		if not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 or preparing or creating then -- 270
			return -- 271
		end -- 271
		userSelectedTab = true -- 272
		returnEntry = nil -- 273
		if tab == next then -- 273
			return -- 274
		end -- 274
		if createOpen then -- 274
			blurCreateInput() -- 276
			createOpen = false -- 277
			createName = "" -- 278
			createError = "" -- 279
		end -- 279
		tab = next -- 281
		local target = rememberedEntries[next] -- 282
		local ____temp_11 -- 283
		if target == nil then -- 283
			____temp_11 = nil -- 283
		else -- 283
			____temp_11 = resolveFeedLocation(____local, discover, target) -- 283
		end -- 283
		local location = ____temp_11 -- 283
		index = (location and location.tab) == next and location.index or 0 -- 284
		render() -- 285
	end -- 270
	local function activate(action) -- 287
		local item = current() -- 288
		if not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 or not item or preparing then -- 288
			return -- 289
		end -- 289
		item.launchError = nil -- 290
		local function done() -- 291
			returnEntry = item -- 291
			local ____temp_14 -- 291
			if action == "play" then -- 291
				____temp_14 = onPlay(item) -- 291
			else -- 291
				____temp_14 = onRemix(item) -- 291
			end -- 291
			return ____temp_14 -- 291
		end -- 291
		if item.kind == "local" or item.installed then -- 291
			done() -- 292
			return -- 292
		end -- 292
		preparing = true -- 293
		prepareStatus = zh and "准备安装…" or "Preparing install…" -- 294
		render() -- 295
		local repairIncomplete = repairResourceId == item.id -- 296
		repairResourceId = "" -- 297
		prepare( -- 298
			item, -- 298
			repairIncomplete, -- 298
			function(progress, message) -- 298
				if not isActive() then -- 298
					return -- 299
				end -- 299
				prepareStatus = (tostring(math.floor(progress * 100)) .. "% · ") .. message -- 300
				render() -- 301
			end, -- 298
			function(success, ready, message, repairable) -- 302
				if not isActive() then -- 302
					return -- 303
				end -- 303
				preparing = false -- 304
				if not success or not ready then -- 304
					repairResourceId = repairable and item.id or "" -- 306
					prepareStatus = message or (zh and "安装失败，点击按钮重试" or "Install failed; tap to retry") -- 307
					render() -- 308
					return -- 309
				end -- 309
				item.fileName = ready.fileName -- 311
				item.workDir = ready.workDir -- 312
				item.installed = true -- 313
				prepareStatus = "" -- 314
				if HttpServer.wsConnectionCount == 0 and host.visible then -- 314
					done() -- 315
				else -- 315
					render() -- 316
				end -- 316
			end -- 302
		) -- 302
	end -- 287
	local function commit(action) -- 320
		if not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 or preparing or transitioning then -- 320
			return -- 321
		end -- 321
		if action == "play" or action == "remix" then -- 321
			local card = cardRef.current -- 323
			if card then -- 323
				card.position = Vec2.zero -- 324
			end -- 324
		end -- 324
		repeat -- 324
			local ____switch67 = action -- 324
			local ____cond67 = ____switch67 == "previous" or ____switch67 == "next" -- 324
			if ____cond67 then -- 324
				do -- 324
					returnEntry = nil -- 329
					local target = normalizeFeedIndex( -- 330
						index + (action == "next" and 1 or -1), -- 330
						#entries() -- 330
					) -- 330
					if target == index then -- 330
						local card = cardRef.current -- 332
						if card then -- 332
							card:perform(Move(App.reducedMotion and 0 or 0.16, card.position, Vec2.zero, Ease.OutQuad)) -- 333
						end -- 333
						return -- 334
					end -- 334
					local duration = App.reducedMotion and 0 or 0.18 -- 336
					local function finish() -- 337
						if not isActive() then -- 337
							return -- 338
						end -- 338
						index = target -- 339
						transitioning = false -- 340
						App:vibrate(0.012) -- 341
						render() -- 342
					end -- 337
					local card = cardRef.current -- 344
					if duration > 0 and card then -- 344
						transitioning = true -- 346
						card:perform(Move( -- 347
							duration, -- 347
							card.position, -- 347
							Vec2(0, (action == "next" and 1 or -1) * App.safeArea.height), -- 347
							Ease.OutQuad -- 347
						)) -- 347
						thread(function() -- 348
							sleep(duration) -- 348
							finish() -- 348
						end) -- 348
					else -- 348
						finish() -- 349
					end -- 349
					return -- 350
				end -- 350
			end -- 350
			____cond67 = ____cond67 or ____switch67 == "play" -- 350
			if ____cond67 then -- 350
				activate("play") -- 352
				return -- 352
			end -- 352
			____cond67 = ____cond67 or ____switch67 == "remix" -- 352
			if ____cond67 then -- 352
				activate("remix") -- 353
				return -- 353
			end -- 353
			do -- 353
				return -- 354
			end -- 354
		until true -- 354
	end -- 320
	local function switchMode() -- 358
		if not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 or preparing or creating or createOpen or packagePanel or transitioning or not options.onSwitchMode then -- 358
			return -- 359
		end -- 359
		leaving = true -- 360
		options.onSwitchMode() -- 361
	end -- 358
	host:slot("SwitchUIMode", switchMode) -- 363
	render = function() -- 364
		if not isActive() then -- 364
			return -- 365
		end -- 365
		local safeContentWidth = App.safeArea.width - 40 -- 367
		local shortLandscapeInputWidth = safeContentWidth - 12 - math.min( -- 368
			300, -- 368
			math.floor(safeContentWidth * 0.42) -- 368
		) -- 368
		local expectedInputWidth = App.safeArea.width >= 760 and App.safeArea.height < 500 and shortLandscapeInputWidth or safeContentWidth -- 369
		local ____createOpen_17 = createOpen -- 370
		if ____createOpen_17 then -- 370
			local ____opt_15 = createInputRef.current -- 370
			____createOpen_17 = (____opt_15 and ____opt_15.width) == expectedInputWidth -- 370
		end -- 370
		local keptInput = ____createOpen_17 and createInputRef.current or nil -- 370
		local restoreFocus = createInput.isFocused() -- 371
		if keptInput ~= nil then -- 371
			keptInput:removeFromParent(false) -- 372
		end -- 372
		if not keptInput then -- 372
			createInput.unmount() -- 374
			createInputRef = reference() -- 375
		end -- 375
		local createPanelRef = reference() -- 377
		host:removeAllChildren() -- 378
		host.scaleX = App.devicePixelRatio -- 379
		host.scaleY = App.devicePixelRatio -- 380
		local ____App_visualSize_20 = App.visualSize -- 381
		local width = ____App_visualSize_20.width -- 381
		local height = ____App_visualSize_20.height -- 381
		local safe = App.safeArea -- 382
		local left = safe.left -- 383
		local bottom = safe.bottom -- 384
		local usableWidth = safe.width -- 385
		local usableHeight = safe.height -- 386
		local wide = usableWidth >= 760 -- 387
		local shortLandscape = wide and usableHeight < 500 -- 388
		local compact = not wide and usableHeight < 700 -- 389
		local compactLandscape = compact and usableWidth > usableHeight and usableHeight < 520 -- 390
		local landscapeTopLift = shortLandscape and 28 or 0 -- 391
		local data = entries() -- 392
		index = normalizeFeedIndex(index, #data) -- 393
		local item = current() -- 394
		rememberCurrent() -- 395
		local coverWidth = wide and math.min(usableWidth * 0.54, 680) or usableWidth - 32 -- 396
		local coverHeight = wide and math.min(usableHeight - 118, coverWidth * 0.72) or (compact and math.min(usableHeight * (compactLandscape and 0.43 or 0.49), coverWidth * 0.72) or math.min(usableHeight * 0.54, coverWidth * 1.12)) -- 397
		local coverX = left + 16 -- 402
		local coverY = wide and bottom + (usableHeight - coverHeight) / 2 - 12 + landscapeTopLift or bottom + usableHeight - coverHeight - 82 -- 403
		local infoX = wide and coverX + coverWidth + 28 or left + 20 -- 404
		local infoWidth = wide and usableWidth - coverWidth - 72 or usableWidth - 40 -- 405
		local infoTop = wide and bottom + usableHeight - 122 + landscapeTopLift or coverY - (compactLandscape and 28 or 30) -- 406
		local descriptionY = infoTop - (compactLandscape and 38 or 58) -- 407
		local actionsY = bottom + (compactLandscape and 18 or 24) -- 408
		local gestureHintY = bottom + (compactLandscape and 88 or 92) -- 409
		local buttonWidth = wide and math.min(190, (infoWidth - 12) / 2) or (infoWidth - 12) / 2 -- 410
		local fontScale = mobileFontScale -- 411
		local cardIndices = getReusableCardIndices(index, #data) -- 412
		local headerRenderOrder = 1000 -- 413
		local ____toNode_48 = toNode -- 415
		local ____React_createElement_47 = React.createElement -- 415
		local ____array_46 = __TS__SparseArrayNew( -- 415
			"node", -- 415
			{ -- 415
				tag = "mobile-feed-scene", -- 415
				x = -width / 2, -- 415
				y = -height / 2, -- 415
				width = width, -- 415
				height = height, -- 415
				anchorX = 0, -- 415
				anchorY = 0, -- 415
				touchEnabled = true, -- 415
				onTapBegan = function() -- 415
					drag = Vec2.zero -- 425
					dragAxis = "none" -- 426
					local ____opt_21 = cardRef.current -- 426
					if ____opt_21 ~= nil then -- 426
						____opt_21:stopAllActions() -- 427
					end -- 427
					if indexRef.current then -- 427
						indexRef.current.opacity = 1 -- 428
					end -- 428
				end, -- 424
				onTapMoved = function(touch) -- 424
					drag = drag:add(touch.delta) -- 431
					if dragAxis == "none" and math.max( -- 431
						math.abs(drag.x), -- 432
						math.abs(drag.y) -- 432
					) >= 12 then -- 432
						dragAxis = math.abs(drag.x) > math.abs(drag.y) * 1.2 and "horizontal" or "vertical" -- 433
					end -- 433
					if cardRef.current then -- 433
						local offset = dragAxis == "horizontal" and Vec2(drag.x * 0.18, 0) or (dragAxis == "vertical" and Vec2(0, drag.y * 0.12) or Vec2.zero) -- 436
						cardRef.current.position = offset -- 437
						if indexRef.current then -- 437
							local headerBottom = bottom + usableHeight - 72 -- 439
							local indexTop = coverY + coverHeight - 14 + offset.y -- 440
							indexRef.current.opacity = dragAxis == "vertical" and math.max( -- 441
								0, -- 442
								math.min(1, (headerBottom - indexTop) / 16) -- 442
							) or 1 -- 442
						end -- 442
					end -- 442
				end, -- 430
				onTapEnded = function() -- 430
					local action = resolveFeedGesture(drag.x, drag.y, usableWidth, usableHeight) -- 448
					drag = Vec2.zero -- 449
					dragAxis = "none" -- 450
					if indexRef.current then -- 450
						indexRef.current.opacity = 1 -- 451
					end -- 451
					if action == "none" and cardRef.current then -- 451
						local card = cardRef.current -- 453
						card:perform(Move(App.reducedMotion and 0 or 0.16, card.position, Vec2.zero, Ease.OutQuad)) -- 454
					end -- 454
					commit(action) -- 456
				end, -- 447
				onMouseWheel = function(delta) return commit(delta.y > 0 and "previous" or "next") end -- 447
			}, -- 447
			React.createElement(VerticalGradient, {width = width, height = height, topColor = 4279310117, bottomColor = 4278716943}) -- 447
		) -- 447
		local ____React_createElement_44 = React.createElement -- 447
		local ____temp_42 = {visible = not projectIndexOpen} -- 447
		local ____createOpen_28 -- 462
		if createOpen then -- 462
			____createOpen_28 = nil -- 462
		else -- 462
			local ____temp_27 -- 462
			if item ~= nil then -- 462
				local ____React_createElement_26 = React.createElement -- 462
				local ____array_25 = __TS__SparseArrayNew( -- 462
					"node", -- 462
					{tag = "mobile-feed-card-" .. item.id, ref = cardRef, key = (tab .. "-") .. item.id}, -- 462
					__TS__ArrayMap( -- 463
						cardIndices, -- 463
						function(____, cardIndex) return React.createElement(Cover, { -- 463
							key = (tab .. "-") .. data[cardIndex + 1].id, -- 463
							entry = data[cardIndex + 1], -- 463
							x = coverX, -- 463
							y = coverY + (index - cardIndex) * usableHeight, -- 463
							width = coverWidth, -- 463
							height = coverHeight -- 463
						}) end -- 463
					), -- 463
					React.createElement( -- 463
						"node", -- 463
						{ -- 463
							tag = "mobile-feed-index", -- 463
							ref = indexRef, -- 463
							order = 10, -- 463
							renderGroup = true, -- 463
							x = coverX + coverWidth - 62, -- 463
							y = coverY + coverHeight - 40, -- 463
							width = 48, -- 463
							height = 26, -- 463
							anchorX = 0, -- 463
							anchorY = 0, -- 463
							touchEnabled = true, -- 463
							swallowTouches = true, -- 463
							onTapped = openProjectIndex -- 463
						}, -- 463
						React.createElement( -- 463
							"clip-node", -- 463
							{ -- 463
								width = 48, -- 463
								height = 26, -- 463
								anchorX = 0, -- 463
								anchorY = 0, -- 463
								stencil = React.createElement(RoundedStencil, {width = 48, height = 26, radius = 13}) -- 463
							}, -- 463
							React.createElement( -- 463
								"draw-node", -- 463
								nil, -- 463
								React.createElement( -- 463
									"verts-shape", -- 463
									{verts = { -- 463
										{ -- 476
											Vec2(0, 0), -- 476
											3759281694 -- 476
										}, -- 476
										{ -- 476
											Vec2(48, 0), -- 476
											3759281694 -- 476
										}, -- 476
										{ -- 476
											Vec2(48, 26), -- 476
											3760730173 -- 476
										}, -- 476
										{ -- 477
											Vec2(0, 0), -- 477
											3759281694 -- 477
										}, -- 477
										{ -- 477
											Vec2(48, 26), -- 477
											3760730173 -- 477
										}, -- 477
										{ -- 477
											Vec2(0, 26), -- 477
											3760730173 -- 477
										} -- 477
									}} -- 477
								) -- 477
							) -- 477
						), -- 477
						React.createElement( -- 477
							"draw-node", -- 477
							{x = 0.5, y = 0.5}, -- 477
							React.createElement( -- 477
								"polygon-shape", -- 477
								{ -- 477
									verts = roundedRectVerts(47, 25, 12.5), -- 477
									fillColor = 0, -- 477
									borderWidth = 0.5, -- 477
									borderColor = 2286967404 -- 477
								} -- 477
							) -- 477
						), -- 477
						React.createElement( -- 477
							"draw-node", -- 477
							{x = 18, y = 2}, -- 477
							React.createElement( -- 477
								"polygon-shape", -- 477
								{ -- 477
									verts = roundedRectVerts(12, 2, 1), -- 477
									fillColor = colors.brand -- 477
								} -- 477
							) -- 477
						), -- 477
						React.createElement( -- 477
							"label", -- 477
							{ -- 477
								x = 24, -- 477
								y = 13, -- 477
								fontName = fontName, -- 477
								fontSize = 11, -- 477
								text = (tostring(index + 1) .. " / ") .. tostring(#data), -- 477
								color3 = 14146531 -- 477
							} -- 477
						) -- 477
					), -- 477
					React.createElement( -- 477
						"label", -- 477
						{ -- 477
							tag = "mobile-feed-current-title", -- 477
							x = infoX, -- 477
							y = infoTop, -- 477
							anchorX = 0, -- 477
							anchorY = 0.5, -- 477
							fontName = fontName, -- 477
							fontSize = math.floor((wide and 30 or 25) * fontScale), -- 477
							text = item.title, -- 477
							textWidth = infoWidth - (item.kind == "local" and canShare and 92 or 0), -- 477
							alignment = "Left", -- 477
							color3 = 16052712 -- 477
						} -- 477
					) -- 477
				) -- 477
				local ____temp_23 -- 486
				if item.kind == "local" and canShare then -- 486
					____temp_23 = React.createElement( -- 486
						MobileButton, -- 486
						{ -- 486
							tag = "mobile-feed-share", -- 486
							x = infoX + infoWidth - 84, -- 486
							y = infoTop - 18, -- 486
							width = 84, -- 486
							height = 36, -- 486
							text = zh and "分享作品" or "Share", -- 486
							fontSize = 13, -- 486
							onTapped = function() return openPackage("share") end -- 486
						} -- 486
					) -- 486
				else -- 486
					____temp_23 = nil -- 486
				end -- 486
				__TS__SparseArrayPush( -- 486
					____array_25, -- 486
					____temp_23, -- 486
					React.createElement( -- 486
						"label", -- 486
						{ -- 486
							tag = "mobile-feed-description", -- 486
							x = infoX, -- 486
							y = descriptionY, -- 486
							anchorX = 0, -- 486
							anchorY = 0.5, -- 486
							fontName = fontName, -- 486
							fontSize = math.floor(15 * fontScale), -- 486
							text = conciseDescription(item.description, wide and 80 or (compact and 28 or 42)), -- 486
							textWidth = infoWidth, -- 486
							alignment = "Left", -- 486
							color3 = 11055037 -- 486
						} -- 486
					) -- 486
				) -- 486
				local ____temp_24 -- 489
				if compact or shortLandscape then -- 489
					____temp_24 = nil -- 489
				else -- 489
					____temp_24 = React.createElement( -- 489
						"node", -- 489
						{ -- 489
							x = infoX, -- 489
							y = infoTop - 118, -- 489
							width = wide and 176 or 164, -- 489
							height = 28, -- 489
							anchorX = 0, -- 489
							anchorY = 0 -- 489
						}, -- 489
						React.createElement(RoundedSurface, { -- 489
							width = wide and 176 or 164, -- 489
							height = 28, -- 489
							radius = 14, -- 489
							topColor = 1714436683, -- 489
							bottomColor = 1712857131, -- 489
							borderWidth = 1, -- 489
							borderColor = 2288020349 -- 489
						}), -- 489
						React.createElement("label", { -- 489
							x = 12, -- 489
							y = 14, -- 489
							anchorX = 0, -- 489
							fontName = fontName, -- 489
							fontSize = 12, -- 489
							text = item.kind == "local" and (zh and "本地作品  ·  可 Remix" or "Local  ·  Remixable") or (item.installed and (zh and "发现  ·  已安装" or "Discover  ·  Installed") or (zh and "发现  ·  可安装" or "Discover  ·  Installable")), -- 489
							textWidth = (wide and 176 or 164) - 24, -- 489
							alignment = "Left", -- 489
							color3 = 14475754 -- 489
						}) -- 489
					) -- 489
				end -- 489
				__TS__SparseArrayPush( -- 489
					____array_25, -- 489
					____temp_24, -- 489
					React.createElement( -- 489
						MobileButton, -- 495
						{ -- 495
							tag = "mobile-feed-remix", -- 495
							x = infoX, -- 495
							y = actionsY, -- 495
							width = buttonWidth, -- 495
							text = zh and "Remix 作品" or "Remix game", -- 495
							fontSize = math.floor(16 * fontScale), -- 495
							primary = true, -- 495
							onTapped = function() return activate("remix") end -- 495
						} -- 495
					), -- 495
					React.createElement( -- 495
						MobileButton, -- 497
						{ -- 497
							tag = "mobile-feed-play", -- 497
							x = infoX + buttonWidth + 12, -- 497
							y = actionsY, -- 497
							width = buttonWidth, -- 497
							text = zh and "试玩" or "Play", -- 497
							fontSize = math.floor(17 * fontScale), -- 497
							onTapped = function() return activate("play") end -- 497
						} -- 497
					), -- 497
					React.createElement("label", { -- 497
						tag = "mobile-feed-gesture-hint", -- 497
						x = infoX, -- 497
						y = gestureHintY, -- 497
						anchorX = 0, -- 497
						anchorY = 0.5, -- 497
						fontName = fontName, -- 497
						fontSize = gamepadUsed and 11 or 14, -- 497
						text = prepareStatus ~= "" and prepareStatus or (item.launchError ~= nil and item.launchError or (gamepadUsed and (zh and "↑↓ 浏览 · A 确认 · X Remix · Start 列表 · Y 新建" or "↑↓ Browse · A Select · X Remix · Start List · Y New") or (zh and "上滑浏览  ·  右滑 Remix  ·  左滑试玩" or "Swipe up  ·  right Remix  ·  left Play"))), -- 497
						textWidth = infoWidth, -- 497
						alignment = "Left", -- 497
						color3 = item.launchError ~= nil and 16739179 or 11055037 -- 497
					}) -- 497
				) -- 497
				____temp_27 = ____React_createElement_26(__TS__SparseArraySpread(____array_25)) -- 497
			else -- 497
				____temp_27 = React.createElement( -- 497
					"node", -- 497
					nil, -- 497
					React.createElement("label", { -- 497
						x = left + usableWidth / 2, -- 497
						y = bottom + usableHeight / 2 + 20, -- 497
						fontName = fontName, -- 497
						fontSize = 22, -- 497
						text = tab == "discover" and (zh and "暂无移动作品" or "No mobile games yet") or (zh and "没有可运行的本地作品" or "No runnable local games"), -- 497
						color3 = 16052712 -- 497
					}), -- 497
					React.createElement("label", { -- 497
						x = left + usableWidth / 2, -- 497
						y = bottom + usableHeight / 2 - 28, -- 497
						fontName = fontName, -- 497
						fontSize = 14, -- 497
						text = tab == "discover" and discoverError ~= "" and discoverError or (zh and "切换标签或稍后重试" or "Switch tabs or retry later"), -- 497
						textWidth = usableWidth - 48, -- 497
						color3 = tab == "discover" and discoverError ~= "" and 16739179 or 11055037 -- 497
					}) -- 497
				) -- 497
			end -- 497
			____createOpen_28 = ____temp_27 -- 462
		end -- 462
		local ____temp_29 -- 510
		if not createOpen and not item and tab == "local" then -- 510
			____temp_29 = React.createElement( -- 510
				"node", -- 510
				nil, -- 510
				React.createElement(MobileButton, { -- 510
					tag = "mobile-empty-new", -- 510
					x = left + 20, -- 510
					y = bottom + 24, -- 510
					width = (usableWidth - 52) / 2, -- 510
					text = zh and "新建作品" or "New game", -- 510
					onTapped = openCreate -- 510
				}), -- 510
				React.createElement( -- 510
					MobileButton, -- 512
					{ -- 512
						tag = "mobile-empty-import", -- 512
						x = left + 32 + (usableWidth - 52) / 2, -- 512
						y = bottom + 24, -- 512
						width = (usableWidth - 52) / 2, -- 512
						text = zh and "导入作品包" or "Import package", -- 512
						fontSize = 15, -- 512
						primary = true, -- 512
						onTapped = function() return openPackage("add", nil, true) end -- 512
					} -- 512
				) -- 512
			) -- 512
		else -- 512
			____temp_29 = nil -- 513
		end -- 513
		local ____React_createElement_33 = React.createElement -- 513
		local ____array_32 = __TS__SparseArrayNew("node", {tag = "mobile-feed-header", order = headerRenderOrder}) -- 513
		local ____options_onSwitchMode_30 -- 515
		if options.onSwitchMode then -- 515
			____options_onSwitchMode_30 = React.createElement( -- 515
				"node", -- 515
				{ -- 515
					tag = "mobile-ui-mode-switch", -- 515
					x = left + 12, -- 515
					y = bottom + usableHeight - 58 + landscapeTopLift, -- 515
					width = 72, -- 515
					height = 48, -- 515
					anchorX = 0, -- 515
					anchorY = 0, -- 515
					touchEnabled = true, -- 515
					swallowTouches = true, -- 515
					onTapped = switchMode -- 515
				}, -- 515
				React.createElement("label", { -- 515
					x = 0, -- 515
					y = 30, -- 515
					anchorX = 0, -- 515
					fontName = fontName, -- 515
					fontSize = 16, -- 515
					text = "DORA", -- 515
					color3 = preparing and 7831180 or 16763955 -- 515
				}), -- 515
				React.createElement("label", { -- 515
					x = 0, -- 515
					y = 10, -- 515
					anchorX = 0, -- 515
					fontName = fontName, -- 515
					fontSize = 10, -- 515
					text = zh and "切换传统界面" or "Classic UI", -- 515
					color3 = 7831180 -- 515
				}) -- 515
			) -- 515
		else -- 515
			____options_onSwitchMode_30 = nil -- 519
		end -- 519
		__TS__SparseArrayPush( -- 519
			____array_32, -- 519
			____options_onSwitchMode_30, -- 519
			React.createElement( -- 519
				"label", -- 519
				{ -- 519
					tag = "mobile-feed-discover-tab", -- 519
					x = left + usableWidth / 2 - 44, -- 519
					y = bottom + usableHeight - 34 + landscapeTopLift, -- 519
					fontName = fontName, -- 519
					fontSize = math.floor(17 * fontScale), -- 519
					text = zh and "发现" or "Discover", -- 519
					color3 = tab == "discover" and 16763955 or 11055037, -- 519
					touchEnabled = true, -- 519
					swallowTouches = true, -- 519
					onTapped = function() return setTab("discover") end -- 519
				} -- 519
			), -- 519
			React.createElement( -- 519
				"label", -- 519
				{ -- 519
					tag = "mobile-feed-local-tab", -- 519
					x = left + usableWidth / 2 + 44, -- 519
					y = bottom + usableHeight - 34 + landscapeTopLift, -- 519
					fontName = fontName, -- 519
					fontSize = math.floor(17 * fontScale), -- 519
					text = zh and "本地" or "Local", -- 519
					color3 = tab == "local" and 16763955 or 11055037, -- 519
					touchEnabled = true, -- 519
					swallowTouches = true, -- 519
					onTapped = function() -- 519
						____local = getLocalEntries() -- 525
						setTab("local") -- 525
					end -- 525
				} -- 525
			), -- 525
			React.createElement(RoundedSurface, { -- 525
				x = left + usableWidth / 2 + (tab == "discover" and -58 or 30), -- 525
				y = bottom + usableHeight - 56 + landscapeTopLift, -- 525
				width = 28, -- 525
				height = 3, -- 525
				radius = 1.5, -- 525
				fillColor = colors.brand, -- 525
				renderOrder = headerRenderOrder + 1 -- 525
			}) -- 525
		) -- 525
		local ____temp_31 -- 527
		if tab == "local" and options.createProject then -- 527
			____temp_31 = React.createElement( -- 527
				MobileNewButton, -- 527
				{ -- 527
					tag = "mobile-feed-create", -- 527
					x = left + usableWidth - 82, -- 527
					y = bottom + usableHeight - 56 + landscapeTopLift, -- 527
					text = zh and "+ 新建" or "+ New", -- 527
					renderOrder = headerRenderOrder + 1, -- 527
					onTapped = function() return openPackage("add") end -- 527
				} -- 527
			) -- 527
		else -- 527
			____temp_31 = nil -- 529
		end -- 529
		__TS__SparseArrayPush(____array_32, ____temp_31) -- 529
		local ____React_createElement_33_result_43 = ____React_createElement_33(__TS__SparseArraySpread(____array_32)) -- 529
		local ____createOpen_41 -- 531
		if createOpen then -- 531
			____createOpen_41 = (function() -- 531
				local sheetHeight = math.min(createSheetHeight, usableHeight - 64) -- 532
				local sheetWidth = usableWidth -- 533
				local contentWidth = sheetWidth - 40 -- 534
				local actionGap = 12 -- 535
				local actionsWidth = shortLandscape and math.min( -- 536
					300, -- 536
					math.floor(contentWidth * 0.42) -- 536
				) or contentWidth -- 536
				local inputWidth = shortLandscape and contentWidth - actionGap - actionsWidth or contentWidth -- 537
				local actionX = shortLandscape and 20 + inputWidth + actionGap or 20 -- 538
				local actionY = shortLandscape and sheetHeight - createInputTop - createInputHeight or 20 -- 539
				local cancelWidth = math.floor((actionsWidth - actionGap) * (shortLandscape and 0.34 or 0.38)) -- 540
				local ____React_createElement_40 = React.createElement -- 540
				local ____array_39 = __TS__SparseArrayNew( -- 540
					"node", -- 540
					{ -- 540
						tag = "mobile-project-create-sheet", -- 540
						order = 10000, -- 540
						width = width, -- 540
						height = height, -- 540
						anchorX = 0, -- 540
						anchorY = 0, -- 540
						touchEnabled = true, -- 540
						swallowTouches = true -- 540
					}, -- 540
					React.createElement( -- 540
						"node", -- 540
						{ -- 540
							tag = "mobile-project-create-focus-observer", -- 540
							order = 1000, -- 540
							width = width, -- 540
							height = height, -- 540
							anchorX = 0, -- 540
							anchorY = 0, -- 540
							touchEnabled = true, -- 540
							swallowTouches = false, -- 540
							swallowMouseWheel = false, -- 540
							onTapFilter = function(touch) -- 540
								touch.enabled = false -- 544
								if not canEditCreate() then -- 544
									return -- 545
								end -- 545
								local input = createInputRef.current -- 546
								local point = input and input:convertToNodeSpace(touch.worldLocation) -- 547
								local inside = input and point and point.x >= 0 and point.y >= 0 and point.x <= input.width and point.y <= input.height -- 548
								dismissedCreateComposition = not inside and createInput.isComposing() -- 549
								if not inside then -- 549
									blurCreateInput() -- 550
								end -- 550
							end -- 543
						} -- 543
					), -- 543
					React.createElement( -- 543
						"draw-node", -- 543
						{ -- 543
							tag = "mobile-project-create-backdrop", -- 543
							order = 0, -- 543
							renderOrder = 0, -- 543
							x = width / 2, -- 543
							y = bottom + sheetHeight + (height - bottom - sheetHeight) / 2 -- 543
						}, -- 543
						React.createElement("rect-shape", {width = width, height = height - bottom - sheetHeight, fillColor = 2348810240}) -- 543
					) -- 543
				) -- 543
				local ____React_createElement_38 = React.createElement -- 543
				local ____array_37 = __TS__SparseArrayNew( -- 543
					"node", -- 543
					{ -- 543
						ref = createPanelRef, -- 543
						order = 10, -- 543
						renderOrder = 10, -- 543
						x = left, -- 543
						y = bottom, -- 543
						width = sheetWidth, -- 543
						height = sheetHeight, -- 543
						anchorX = 0, -- 543
						anchorY = 0, -- 543
						touchEnabled = true, -- 543
						swallowTouches = true -- 543
					}, -- 543
					React.createElement(MobilePanelSurface, {width = sheetWidth, height = sheetHeight, renderOrder = 10}), -- 543
					React.createElement("label", { -- 543
						x = 20, -- 543
						y = sheetHeight - 24, -- 543
						anchorX = 0, -- 543
						anchorY = 1, -- 543
						fontName = fontName, -- 543
						fontSize = 22, -- 543
						text = zh and "新建项目" or "New project", -- 543
						color3 = 16052712 -- 543
					}), -- 543
					__TS__ArrayMap( -- 558
						{"typescript", "lua"}, -- 558
						function(____, language, i) return React.createElement( -- 558
							MobileChoiceButton, -- 558
							{ -- 558
								tag = "mobile-project-create-language-" .. language, -- 558
								x = 20 + i * 144, -- 558
								y = sheetHeight - 98, -- 558
								width = language == "lua" and 84 or 132, -- 558
								text = language == "lua" and "Lua" or "TypeScript", -- 558
								selected = createLanguage == language, -- 558
								renderOrder = 10, -- 558
								onTapped = function() -- 558
									if not canEditCreate() then -- 558
										return -- 562
									end -- 562
									blurCreateInput() -- 563
									createLanguage = language -- 563
									render() -- 563
								end -- 561
							} -- 561
						) end -- 561
					), -- 561
					React.createElement("label", { -- 561
						x = 20, -- 561
						y = sheetHeight - 110, -- 561
						anchorX = 0, -- 561
						anchorY = 1, -- 561
						fontName = fontName, -- 561
						fontSize = 14, -- 561
						text = zh and "项目名称" or "Project name", -- 561
						color3 = 11055037 -- 561
					}) -- 561
				) -- 561
				local ____keptInput_36 -- 566
				if keptInput then -- 566
					____keptInput_36 = nil -- 566
				else -- 566
					____keptInput_36 = React.createElement("node", { -- 566
						tag = "mobile-project-create-input", -- 566
						ref = createInputRef, -- 566
						renderOrder = 10, -- 566
						x = 20, -- 566
						y = sheetHeight - createInputTop - createInputHeight, -- 566
						width = inputWidth, -- 566
						height = createInputHeight, -- 566
						anchorX = 0, -- 566
						anchorY = 0, -- 566
						onMount = createInput.mount -- 566
					}) -- 566
				end -- 566
				__TS__SparseArrayPush( -- 566
					____array_37, -- 566
					____keptInput_36, -- 566
					React.createElement("label", { -- 566
						tag = "mobile-project-create-error", -- 566
						x = 20, -- 566
						y = shortLandscape and sheetHeight - createInputTop + 12 or sheetHeight - createInputTop - createInputHeight - 12, -- 566
						anchorX = 0, -- 566
						anchorY = 1, -- 566
						fontName = fontName, -- 566
						fontSize = 12, -- 566
						text = createError ~= "" and createError or (zh and ("将创建可运行的 " .. (createLanguage == "lua" and "Lua" or "TypeScript")) .. " 起始项目" or ("Creates a runnable " .. (createLanguage == "lua" and "Lua" or "TypeScript")) .. " starter project"), -- 566
						textWidth = inputWidth, -- 566
						alignment = "Left", -- 566
						color3 = createError ~= "" and 16739179 or 11055037 -- 566
					}), -- 566
					React.createElement(MobileButton, { -- 566
						tag = "mobile-project-create-cancel", -- 566
						x = actionX, -- 566
						y = actionY, -- 566
						width = cancelWidth, -- 566
						text = zh and "取消" or "Cancel", -- 566
						renderOrder = 10, -- 566
						onTapped = closeCreate -- 566
					}), -- 566
					React.createElement( -- 566
						MobileButton, -- 572
						{ -- 572
							tag = "mobile-project-create-submit", -- 572
							x = actionX + cancelWidth + actionGap, -- 572
							y = actionY, -- 572
							width = actionsWidth - cancelWidth - actionGap, -- 572
							text = creating and (zh and "创建中…" or "Creating…") or (zh and "创建并进入 Remix" or "Create and Remix"), -- 572
							primary = true, -- 572
							renderOrder = 10, -- 572
							onTapped = function() -- 572
								if not dismissedCreateComposition then -- 572
									submitCreate() -- 573
								end -- 573
								dismissedCreateComposition = false -- 573
							end -- 573
						} -- 573
					) -- 573
				) -- 573
				__TS__SparseArrayPush( -- 573
					____array_39, -- 573
					____React_createElement_38(__TS__SparseArraySpread(____array_37)) -- 573
				) -- 573
				return ____React_createElement_40(__TS__SparseArraySpread(____array_39)) -- 541
			end)() -- 531
		else -- 531
			____createOpen_41 = nil -- 576
		end -- 576
		__TS__SparseArrayPush( -- 576
			____array_46, -- 576
			____React_createElement_44( -- 576
				"node", -- 576
				____temp_42, -- 576
				____createOpen_28, -- 576
				____temp_29, -- 576
				____React_createElement_33_result_43, -- 576
				____createOpen_41 -- 576
			) -- 576
		) -- 576
		local ____projectIndexOpen_45 -- 578
		if projectIndexOpen then -- 578
			____projectIndexOpen_45 = React.createElement( -- 578
				ProjectIndex, -- 578
				{ -- 578
					entries = entries(), -- 578
					kind = tab, -- 578
					current = current(), -- 578
					x = left, -- 578
					y = bottom, -- 578
					width = usableWidth, -- 578
					height = usableHeight, -- 578
					zh = zh, -- 578
					onClose = function() -- 578
						projectIndexOpen = false -- 579
						render() -- 579
					end, -- 579
					onSelect = function(____, entry) -- 579
						projectIndexOpen = false -- 581
						local location = resolveFeedLocation(____local, discover, entry) -- 582
						tab = location.tab -- 583
						index = location.index -- 583
						render() -- 584
					end -- 580
				} -- 580
			) -- 580
		else -- 580
			____projectIndexOpen_45 = nil -- 585
		end -- 585
		__TS__SparseArrayPush(____array_46, ____projectIndexOpen_45) -- 585
		local scene = ____toNode_48(____React_createElement_47(__TS__SparseArraySpread(____array_46))) -- 415
		if scene ~= nil then -- 415
			host:addChild(scene) -- 587
		end -- 587
		if keptInput and createPanelRef.current then -- 587
			keptInput.position = Vec2( -- 589
				20, -- 589
				math.min(createSheetHeight, usableHeight - 64) - createInputTop - createInputHeight -- 589
			) -- 589
			createPanelRef.current:addChild(keptInput) -- 590
		end -- 590
		createInput.refresh() -- 592
		if restoreFocus and not keptInput and createOpen then -- 592
			createInput.focus(false) -- 593
		end -- 593
	end -- 364
	attachGamepad( -- 596
		host, -- 596
		{ -- 596
			initialTag = "mobile-feed-play", -- 597
			isEnabled = function() return isActive() and not packagePanel and not preparing and not transitioning and not creating end, -- 598
			onActive = function() -- 599
				gamepadUsed = true -- 599
				render() -- 599
			end, -- 599
			onBack = function() -- 600
				if createInput.isFocused() then -- 600
					blurCreateInput() -- 600
				elseif createOpen then -- 600
					closeCreate() -- 600
				else -- 600
					switchMode() -- 600
				end -- 600
			end, -- 600
			onActivate = function(target) -- 601
				if target.tag == "mobile-project-create-input" then -- 601
					target:emit("GamepadActivate") -- 602
				else -- 602
					if createInput.isComposing() then -- 602
						blurCreateInput() -- 604
						return -- 604
					end -- 604
					blurCreateInput() -- 605
					dismissedCreateComposition = false -- 606
					target:emit("Tapped") -- 607
				end -- 607
			end, -- 601
			onButton = function(button) -- 610
				if createOpen then -- 610
					return false -- 611
				end -- 611
				repeat -- 611
					local ____switch125 = button -- 611
					local ____cond125 = ____switch125 == "dpup" -- 611
					if ____cond125 then -- 611
						commit("previous") -- 613
						return true -- 613
					end -- 613
					____cond125 = ____cond125 or ____switch125 == "dpdown" -- 613
					if ____cond125 then -- 613
						commit("next") -- 614
						return true -- 614
					end -- 614
					____cond125 = ____cond125 or ____switch125 == "leftshoulder" -- 614
					if ____cond125 then -- 614
						setTab("discover") -- 615
						return true -- 615
					end -- 615
					____cond125 = ____cond125 or ____switch125 == "rightshoulder" -- 615
					if ____cond125 then -- 615
						setTab("local") -- 616
						return true -- 616
					end -- 616
					____cond125 = ____cond125 or ____switch125 == "x" -- 616
					if ____cond125 then -- 616
						commit("remix") -- 617
						return true -- 617
					end -- 617
					____cond125 = ____cond125 or ____switch125 == "y" -- 617
					if ____cond125 then -- 617
						local ____opt_49 = findGamepadNode(host, "mobile-feed-create") -- 617
						if ____opt_49 ~= nil then -- 617
							____opt_49:emit("Tapped") -- 618
						end -- 618
						return true -- 618
					end -- 618
					____cond125 = ____cond125 or ____switch125 == "start" -- 618
					if ____cond125 then -- 618
						openProjectIndex() -- 619
						return true -- 619
					end -- 619
					do -- 619
						return false -- 620
					end -- 620
				until true -- 620
			end -- 610
		} -- 610
	) -- 610
	host:onAppChange(function(setting) -- 624
		if setting == "Locale" then -- 624
			local activeEntry = current() -- 626
			zh = (string.match(App.locale, "^zh")) ~= nil -- 627
			____local = getLocalEntries() -- 628
			discover = getDiscoverEntries() -- 629
			local location = resolveFeedLocation(____local, discover, activeEntry) -- 630
			tab = location.tab -- 631
			index = location.index -- 632
			render() -- 633
		elseif setting == "Size" then -- 633
			render() -- 634
		end -- 634
	end) -- 624
	host:onAppEvent(function(event) -- 636
		if event == "BackButton" then -- 636
			if projectIndexOpen then -- 636
				projectIndexOpen = false -- 638
				render() -- 638
			elseif createOpen and not creating then -- 638
				closeCreate() -- 639
			end -- 639
		elseif event == "WillEnterBackground" or event == "DidEnterBackground" then -- 639
			blurCreateInput() -- 640
		end -- 640
	end) -- 636
	host:onCleanup(function() -- 642
		blurCreateInput() -- 642
		active = false -- 642
		if packagePanel ~= nil then -- 642
			packagePanel:removeFromParent(true) -- 642
		end -- 642
		packagePanel = nil -- 642
	end) -- 642
	host:slot( -- 643
		"RestoreFeedEntry", -- 643
		function(entry) -- 643
			if not isActive() or HttpServer.wsConnectionCount > 0 then -- 643
				return -- 644
			end -- 644
			returnEntry = entry -- 645
			____local = getLocalEntries() -- 646
			discover = getDiscoverEntries() -- 647
			local location = resolveFeedLocation(____local, discover, entry) -- 648
			tab = location.tab -- 649
			index = location.index -- 650
			render() -- 651
		end -- 643
	) -- 643
	host:slot("SuspendLocalUI", blurCreateInput) -- 653
	host:slot( -- 654
		"ResumeLocalUI", -- 654
		function() -- 654
			leaving = false -- 654
			render() -- 654
		end -- 654
	) -- 654
	render() -- 655
	if syncDiscover then -- 655
		if #discover == 0 then -- 655
			discoverError = zh and "正在同步资源目录…" or "Syncing Catalog…" -- 658
			render() -- 659
		end -- 659
		syncDiscover( -- 661
			function(message) -- 661
				if not isActive() or #discover > 0 then -- 661
					return -- 662
				end -- 662
				discoverError = message -- 663
				render() -- 664
			end, -- 661
			function(success, message) -- 665
				if not isActive() then -- 665
					return -- 666
				end -- 666
				local selected = returnEntry or rememberedEntries[tab] or current() -- 667
				local previousCount = #discover -- 668
				discover = getDiscoverEntries() -- 669
				discoverError = success and (#discover == 0 and (zh and "目录中暂无可运行作品" or "No runnable Catalog games") or "") or (message or (zh and "资源目录同步失败" or "Catalog sync failed")) -- 670
				tab = resolveDiscoverRefreshTab( -- 673
					tab, -- 673
					userSelectedTab, -- 673
					previousCount, -- 673
					#discover, -- 673
					#____local -- 673
				) -- 673
				if selected ~= nil then -- 673
					local location = resolveFeedLocation(____local, discover, selected) -- 675
					tab = location.tab -- 676
					index = location.index -- 677
				end -- 677
				if tab == "discover" then -- 677
					index = normalizeFeedIndex(index, #discover) -- 679
				end -- 679
				render() -- 680
			end -- 665
		) -- 665
	end -- 665
	return host -- 683
end -- 98
return ____exports -- 98