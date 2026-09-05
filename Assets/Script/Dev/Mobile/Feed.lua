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
local MobileNewButton = ____Controls.MobileNewButton -- 8
local MobilePanelSurface = ____Controls.MobilePanelSurface -- 8
local ____Visual = require("Dev.Mobile.Visual") -- 9
local RoundedStencil = ____Visual.RoundedStencil -- 9
local RoundedSurface = ____Visual.RoundedSurface -- 9
local VerticalGradient = ____Visual.VerticalGradient -- 9
local ____PackagePanel = require("Dev.Mobile.PackagePanel") -- 10
local startPackagePanel = ____PackagePanel.startPackagePanel -- 10
local ____ProjectIndex = require("Dev.Mobile.ProjectIndex") -- 11
local ProjectIndex = ____ProjectIndex.ProjectIndex -- 11
local colors = { -- 34
	background = 4278914322, -- 35
	panel = 4279572770, -- 36
	panelRaised = 4280297010, -- 37
	text = 4294242792, -- 38
	muted = 4289245117, -- 39
	brand = 4294954035, -- 40
	border = 4281613128, -- 41
	danger = 4294929259 -- 42
} -- 42
local fontName = "sarasa-mono-sc-regular" -- 45
local createSheetHeight = 260 -- 46
local createInputHeight = 44 -- 47
local createInputTop = 96 -- 48
local function conciseDescription(text, limit) -- 50
	local length = (utf8.len(text)) or 0 -- 51
	if length <= limit then -- 51
		return text -- 52
	end -- 52
	local stop = utf8.offset(text, limit + 1) or #text + 1 -- 53
	return string.sub(text, 1, stop - 1) .. "…" -- 54
end -- 50
local function Cover(props) -- 57
	local file = props.entry.bannerFile -- 58
	local function scaleSprite(sprite, mode) -- 59
		local scales = getCoverScales(sprite.width, sprite.height, props.width, props.height) -- 60
		sprite.scaleX = scales[mode] -- 61
		sprite.scaleY = scales[mode] -- 62
	end -- 59
	local ____React_createElement_5 = React.createElement -- 59
	local ____temp_3 = { -- 59
		x = props.x, -- 59
		y = props.y, -- 59
		width = props.width, -- 59
		height = props.height, -- 59
		anchorX = 0, -- 59
		anchorY = 0 -- 59
	} -- 59
	local ____React_createElement_result_4 = React.createElement( -- 59
		RoundedSurface, -- 65
		{ -- 65
			width = props.width, -- 65
			height = props.height, -- 65
			radius = 22, -- 65
			topColor = stableCoverColor(props.entry.id), -- 65
			bottomColor = 4279310115, -- 65
			shadow = true -- 65
		} -- 65
	) -- 65
	local ____file_0 -- 67
	if file then -- 67
		____file_0 = React.createElement( -- 67
			"clip-node", -- 67
			{ -- 67
				width = props.width, -- 67
				height = props.height, -- 67
				anchorX = 0, -- 67
				anchorY = 0, -- 67
				stencil = React.createElement(RoundedStencil, {width = props.width, height = props.height, radius = 22}) -- 67
			}, -- 67
			React.createElement( -- 67
				"sprite", -- 67
				{ -- 67
					file = file, -- 67
					x = props.width / 2 - 5, -- 67
					y = props.height / 2, -- 67
					opacity = 0.08, -- 67
					onMount = function(sprite) return scaleSprite(sprite, "cover") end -- 67
				} -- 67
			), -- 67
			React.createElement( -- 67
				"sprite", -- 67
				{ -- 67
					file = file, -- 67
					x = props.width / 2 + 5, -- 67
					y = props.height / 2, -- 67
					opacity = 0.08, -- 67
					onMount = function(sprite) return scaleSprite(sprite, "cover") end -- 67
				} -- 67
			), -- 67
			React.createElement( -- 67
				"sprite", -- 67
				{ -- 67
					file = file, -- 67
					x = props.width / 2, -- 67
					y = props.height / 2 - 5, -- 67
					opacity = 0.08, -- 67
					onMount = function(sprite) return scaleSprite(sprite, "cover") end -- 67
				} -- 67
			), -- 67
			React.createElement( -- 67
				"draw-node", -- 67
				{x = props.width / 2, y = props.height / 2}, -- 67
				React.createElement("rect-shape", {width = props.width, height = props.height, fillColor = 2953514258}) -- 67
			), -- 67
			React.createElement( -- 67
				"sprite", -- 67
				{ -- 67
					file = file, -- 67
					x = props.width / 2, -- 67
					y = props.height / 2, -- 67
					onMount = function(sprite) return scaleSprite(sprite, "contain") end -- 67
				} -- 67
			) -- 67
		) -- 67
	else -- 67
		____file_0 = React.createElement( -- 67
			"label", -- 67
			{ -- 67
				x = props.width / 2, -- 67
				y = props.height / 2 + 10, -- 67
				fontName = fontName, -- 67
				fontSize = math.floor(math.max( -- 67
					22, -- 79
					math.min(34, props.width / 12) -- 79
				)), -- 79
				text = props.entry.title, -- 79
				textWidth = props.width - 40, -- 79
				color3 = 16052712 -- 79
			} -- 79
		) -- 79
	end -- 79
	local ____file_1 -- 84
	if file then -- 84
		____file_1 = nil -- 84
	else -- 84
		____file_1 = React.createElement("label", { -- 84
			x = props.width / 2, -- 84
			y = 30, -- 84
			fontName = fontName, -- 84
			fontSize = 14, -- 84
			text = "DORA SSR · REMIXABLE", -- 84
			color3 = 16763955 -- 84
		}) -- 84
	end -- 84
	local ____file_2 -- 92
	if file then -- 92
		____file_2 = nil -- 92
	else -- 92
		____file_2 = React.createElement(DoraMascot, {state = "idle", x = props.width - 46, y = 64, size = 42}) -- 92
	end -- 92
	return ____React_createElement_5( -- 64
		"node", -- 64
		____temp_3, -- 64
		____React_createElement_result_4, -- 64
		____file_0, -- 64
		____file_1, -- 64
		____file_2, -- 64
		React.createElement(RoundedSurface, { -- 64
			width = props.width, -- 64
			height = props.height, -- 64
			radius = 22, -- 64
			fillColor = 0, -- 64
			borderWidth = 1, -- 64
			borderColor = 4282074454 -- 64
		}) -- 64
	) -- 64
end -- 57
function ____exports.startMobileFeed(options) -- 97
	local submitCreate, render -- 97
	local getLocalEntries = options.getLocalEntries -- 98
	local getDiscoverEntries = options.getDiscoverEntries -- 99
	local onPlay = options.onPlay -- 100
	local onRemix = options.onRemix -- 101
	local prepare = options.prepare -- 102
	local syncDiscover = options.syncDiscover -- 103
	local zh = (string.match(App.locale, "^zh")) ~= nil -- 104
	local tab = "local" -- 105
	local index = 0 -- 106
	local drag = Vec2.zero -- 107
	local dragAxis = "none" -- 108
	local discoverError = "" -- 109
	local preparing = false -- 110
	local transitioning = false -- 111
	local prepareStatus = "" -- 112
	local repairResourceId = "" -- 113
	local userSelectedTab = false -- 114
	local active = true -- 115
	local leaving = false -- 116
	local packagePanel -- 117
	local createOpen = false -- 118
	local projectIndexOpen = false -- 119
	local creating = false -- 120
	local createName = "" -- 121
	local dismissedCreateComposition = false -- 122
	local createError = "" -- 123
	local gamepadUsed = false -- 124
	local returnEntry = options.initialEntry -- 125
	local ____opt_6 = options.initialEntries -- 125
	local ____temp_10 = ____opt_6 and ____opt_6["local"] -- 127
	local ____opt_8 = options.initialEntries -- 127
	local rememberedEntries = {["local"] = ____temp_10, discover = ____opt_8 and ____opt_8.discover} -- 126
	local cardRef = reference() -- 130
	local indexRef = reference() -- 131
	local createInputRef = reference() -- 132
	local discover = getDiscoverEntries() -- 133
	local ____local = getLocalEntries() -- 134
	if #discover == 0 then -- 134
		discoverError = zh and "资源目录暂不可用" or "Catalog is unavailable" -- 137
	end -- 137
	local initialLocation = resolveFeedLocation(____local, discover, returnEntry) -- 139
	tab = initialLocation.tab -- 140
	index = initialLocation.index -- 141
	local host = Node() -- 143
	host.tag = "mobile-feed" -- 144
	host.scaleX = App.devicePixelRatio -- 145
	host.scaleY = App.devicePixelRatio -- 146
	host:addTo(Director.systemUI) -- 147
	local function isActive() -- 149
		return active and not leaving and host.parent ~= nil -- 149
	end -- 149
	local function entries() -- 151
		return tab == "discover" and discover or ____local -- 151
	end -- 151
	local function current() -- 152
		return entries()[normalizeFeedIndex( -- 152
			index, -- 152
			#entries() -- 152
		) + 1] -- 152
	end -- 152
	local rememberedEntryKey = "" -- 153
	local function rememberCurrent() -- 154
		local item = current() -- 155
		if not item or not options.onCurrentEntryChanged then -- 155
			return -- 156
		end -- 156
		local key = (((((item.kind .. "\n") .. item.id) .. "\n") .. (item.workDir or "")) .. "\n") .. (item.fileName or "") -- 157
		if key == rememberedEntryKey then -- 157
			return -- 158
		end -- 158
		rememberedEntryKey = key -- 159
		rememberedEntries[item.kind] = item -- 160
		options.onCurrentEntryChanged(item) -- 161
	end -- 154
	local function canEditCreate() -- 163
		return createOpen and not creating and isActive() and host.visible and HttpServer.wsConnectionCount == 0 -- 163
	end -- 163
	local createInput = createTextInput({ -- 164
		fontSize = math.floor(16 * mobileFontScale), -- 165
		singleLine = true, -- 166
		background = colors.background, -- 167
		getText = function() return createName end, -- 168
		setText = function(text) -- 169
			createName = text -- 169
		end, -- 169
		getPlaceholder = function() return zh and "例如：星际花园" or "For example: Star Garden" end, -- 170
		isEnabled = canEditCreate, -- 171
		onReturn = function() -- 172
			submitCreate() -- 172
			return true -- 172
		end -- 172
	}) -- 172
	local blurCreateInput = createInput.blur -- 174
	local function closeCreate() -- 175
		if creating then -- 175
			return -- 176
		end -- 176
		blurCreateInput() -- 177
		createOpen = false -- 178
		createName = "" -- 179
		createError = "" -- 180
		render() -- 181
	end -- 175
	local function openCreate() -- 183
		if not options.createProject or preparing or transitioning or creating or createOpen or HttpServer.wsConnectionCount > 0 then -- 183
			return -- 184
		end -- 184
		projectIndexOpen = false -- 185
		createOpen = true -- 186
		createName = "" -- 187
		dismissedCreateComposition = false -- 188
		createError = "" -- 189
		render() -- 190
		createInput.deferFocus() -- 191
	end -- 183
	local function openProjectIndex() -- 193
		if tab ~= "local" or preparing or transitioning or creating or createOpen or HttpServer.wsConnectionCount > 0 then -- 193
			return -- 194
		end -- 194
		____local = getLocalEntries() -- 195
		projectIndexOpen = true -- 196
		render() -- 197
	end -- 193
	local function createErrorText(____error) -- 199
		repeat -- 199
			local ____switch30 = ____error -- 199
			local ____cond30 = ____switch30 == "invalid-name" -- 199
			if ____cond30 then -- 199
				return zh and "请输入不含路径分隔符的项目名称" or "Enter a project name without path separators" -- 201
			end -- 201
			____cond30 = ____cond30 or ____switch30 == "target-existed" -- 201
			if ____cond30 then -- 201
				return zh and "已有同名项目，请换一个名称" or "A project with that name already exists" -- 202
			end -- 202
			____cond30 = ____cond30 or ____switch30 == "create-folder-failed" -- 202
			if ____cond30 then -- 202
				return zh and "无法创建项目目录，请检查工作目录后重试" or "Could not create the project folder; check the workspace and retry" -- 203
			end -- 203
			____cond30 = ____cond30 or ____switch30 == "create-entry-failed" -- 203
			if ____cond30 then -- 203
				return zh and "无法写入项目入口，未完成项目已回滚" or "Could not write the project entry; the incomplete project was rolled back" -- 204
			end -- 204
			____cond30 = ____cond30 or ____switch30 == "created-project-not-found" -- 204
			if ____cond30 then -- 204
				return zh and "项目已创建，但本地列表未能找到它，请返回后重试" or "The project was created but could not be found in Local; return and retry" -- 205
			end -- 205
			do -- 205
				return zh and "创建失败，请重试" or "Project creation failed; try again" -- 206
			end -- 206
		until true -- 206
	end -- 199
	submitCreate = function() -- 209
		if not options.createProject or creating or not createOpen or not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 then -- 209
			return -- 210
		end -- 210
		if createInput.isComposing() then -- 210
			return -- 211
		end -- 211
		creating = true -- 212
		createError = "" -- 213
		blurCreateInput() -- 214
		render() -- 215
		local result = options.createProject(createName) -- 216
		if not isActive() then -- 216
			return -- 217
		end -- 217
		creating = false -- 218
		if not result.success then -- 218
			createError = createErrorText(result.error) -- 220
			render() -- 221
			return -- 222
		end -- 222
		createOpen = false -- 224
		createName = "" -- 225
		____local = getLocalEntries() -- 226
		returnEntry = result.entry -- 227
		local location = resolveFeedLocation(____local, discover, result.entry) -- 228
		tab = location.tab -- 229
		index = location.index -- 230
		render() -- 231
		onRemix(result.entry) -- 232
	end -- 209
	local function openPackage(mode, path) -- 235
		if not isActive() or not host.visible or packagePanel or preparing or transitioning or creating or createOpen or HttpServer.wsConnectionCount > 0 then -- 235
			return -- 236
		end -- 236
		projectIndexOpen = false -- 237
		packagePanel = startPackagePanel({ -- 238
			mode = mode, -- 239
			path = path, -- 239
			entry = current(), -- 239
			onNew = openCreate, -- 240
			onClosed = function() -- 241
				packagePanel = nil -- 241
			end, -- 241
			onImported = function(entry, play) -- 242
				if not isActive() then -- 242
					return -- 243
				end -- 243
				____local = getLocalEntries(entry.workDir) -- 244
				local imported = __TS__ArrayFind( -- 245
					____local, -- 245
					function(____, item) return item.workDir == entry.workDir end -- 245
				) or entry -- 245
				returnEntry = imported -- 246
				local location = resolveFeedLocation(____local, discover, imported) -- 247
				tab = "local" -- 248
				index = location.index -- 248
				render() -- 249
				if play then -- 249
					onPlay(imported) -- 250
				end -- 250
			end -- 242
		}) -- 242
	end -- 235
	local receiveElapsed = 0 -- 254
	host:schedule(function(dt) -- 255
		receiveElapsed = receiveElapsed + dt -- 256
		if receiveElapsed < 0.5 then -- 256
			return false -- 257
		end -- 257
		receiveElapsed = 0 -- 258
		if isActive() and host.visible and not packagePanel and not createOpen and not projectIndexOpen and not preparing and not transitioning and HttpServer.wsConnectionCount == 0 then -- 258
			local path = options.takeReceivedFile and options.takeReceivedFile() or App:takeReceivedFile() -- 260
			if path ~= "" then -- 260
				openPackage("receive", path) -- 261
			end -- 261
		end -- 261
		return false -- 263
	end) -- 255
	local function setTab(next) -- 266
		if not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 or preparing or creating then -- 266
			return -- 267
		end -- 267
		userSelectedTab = true -- 268
		returnEntry = nil -- 269
		if tab == next then -- 269
			return -- 270
		end -- 270
		if createOpen then -- 270
			blurCreateInput() -- 272
			createOpen = false -- 273
			createName = "" -- 274
			createError = "" -- 275
		end -- 275
		tab = next -- 277
		local target = rememberedEntries[next] -- 278
		local ____temp_11 -- 279
		if target == nil then -- 279
			____temp_11 = nil -- 279
		else -- 279
			____temp_11 = resolveFeedLocation(____local, discover, target) -- 279
		end -- 279
		local location = ____temp_11 -- 279
		index = (location and location.tab) == next and location.index or 0 -- 280
		render() -- 281
	end -- 266
	local function activate(action) -- 283
		local item = current() -- 284
		if not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 or not item or preparing then -- 284
			return -- 285
		end -- 285
		item.launchError = nil -- 286
		local function done() -- 287
			returnEntry = item -- 287
			local ____temp_14 -- 287
			if action == "play" then -- 287
				____temp_14 = onPlay(item) -- 287
			else -- 287
				____temp_14 = onRemix(item) -- 287
			end -- 287
			return ____temp_14 -- 287
		end -- 287
		if item.kind == "local" or item.installed then -- 287
			done() -- 288
			return -- 288
		end -- 288
		preparing = true -- 289
		prepareStatus = zh and "准备安装…" or "Preparing install…" -- 290
		render() -- 291
		local repairIncomplete = repairResourceId == item.id -- 292
		repairResourceId = "" -- 293
		prepare( -- 294
			item, -- 294
			repairIncomplete, -- 294
			function(progress, message) -- 294
				if not isActive() then -- 294
					return -- 295
				end -- 295
				prepareStatus = (tostring(math.floor(progress * 100)) .. "% · ") .. message -- 296
				render() -- 297
			end, -- 294
			function(success, ready, message, repairable) -- 298
				if not isActive() then -- 298
					return -- 299
				end -- 299
				preparing = false -- 300
				if not success or not ready then -- 300
					repairResourceId = repairable and item.id or "" -- 302
					prepareStatus = message or (zh and "安装失败，点击按钮重试" or "Install failed; tap to retry") -- 303
					render() -- 304
					return -- 305
				end -- 305
				item.fileName = ready.fileName -- 307
				item.workDir = ready.workDir -- 308
				item.installed = true -- 309
				prepareStatus = "" -- 310
				if HttpServer.wsConnectionCount == 0 and host.visible then -- 310
					done() -- 311
				else -- 311
					render() -- 312
				end -- 312
			end -- 298
		) -- 298
	end -- 283
	local function commit(action) -- 316
		if not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 or preparing or transitioning then -- 316
			return -- 317
		end -- 317
		if action == "play" or action == "remix" then -- 317
			local card = cardRef.current -- 319
			if card then -- 319
				card.position = Vec2.zero -- 320
			end -- 320
		end -- 320
		repeat -- 320
			local ____switch66 = action -- 320
			local ____cond66 = ____switch66 == "previous" or ____switch66 == "next" -- 320
			if ____cond66 then -- 320
				do -- 320
					returnEntry = nil -- 325
					local target = normalizeFeedIndex( -- 326
						index + (action == "next" and 1 or -1), -- 326
						#entries() -- 326
					) -- 326
					if target == index then -- 326
						local card = cardRef.current -- 328
						if card then -- 328
							card:perform(Move(App.reducedMotion and 0 or 0.16, card.position, Vec2.zero, Ease.OutQuad)) -- 329
						end -- 329
						return -- 330
					end -- 330
					local duration = App.reducedMotion and 0 or 0.18 -- 332
					local function finish() -- 333
						if not isActive() then -- 333
							return -- 334
						end -- 334
						index = target -- 335
						transitioning = false -- 336
						App:vibrate(0.012) -- 337
						render() -- 338
					end -- 333
					local card = cardRef.current -- 340
					if duration > 0 and card then -- 340
						transitioning = true -- 342
						card:perform(Move( -- 343
							duration, -- 343
							card.position, -- 343
							Vec2(0, (action == "next" and 1 or -1) * App.safeArea.height), -- 343
							Ease.OutQuad -- 343
						)) -- 343
						thread(function() -- 344
							sleep(duration) -- 344
							finish() -- 344
						end) -- 344
					else -- 344
						finish() -- 345
					end -- 345
					return -- 346
				end -- 346
			end -- 346
			____cond66 = ____cond66 or ____switch66 == "play" -- 346
			if ____cond66 then -- 346
				activate("play") -- 348
				return -- 348
			end -- 348
			____cond66 = ____cond66 or ____switch66 == "remix" -- 348
			if ____cond66 then -- 348
				activate("remix") -- 349
				return -- 349
			end -- 349
			do -- 349
				return -- 350
			end -- 350
		until true -- 350
	end -- 316
	local function switchMode() -- 354
		if not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 or preparing or creating or createOpen or packagePanel or transitioning or not options.onSwitchMode then -- 354
			return -- 355
		end -- 355
		leaving = true -- 356
		options.onSwitchMode() -- 357
	end -- 354
	host:slot("SwitchUIMode", switchMode) -- 359
	render = function() -- 360
		if not isActive() then -- 360
			return -- 361
		end -- 361
		local safeContentWidth = App.safeArea.width - 40 -- 363
		local shortLandscapeInputWidth = safeContentWidth - 12 - math.min( -- 364
			300, -- 364
			math.floor(safeContentWidth * 0.42) -- 364
		) -- 364
		local expectedInputWidth = App.safeArea.width >= 760 and App.safeArea.height < 500 and shortLandscapeInputWidth or safeContentWidth -- 365
		local ____createOpen_17 = createOpen -- 366
		if ____createOpen_17 then -- 366
			local ____opt_15 = createInputRef.current -- 366
			____createOpen_17 = (____opt_15 and ____opt_15.width) == expectedInputWidth -- 366
		end -- 366
		local keptInput = ____createOpen_17 and createInputRef.current or nil -- 366
		local restoreFocus = createInput.isFocused() -- 367
		if keptInput ~= nil then -- 367
			keptInput:removeFromParent(false) -- 368
		end -- 368
		if not keptInput then -- 368
			createInput.unmount() -- 370
			createInputRef = reference() -- 371
		end -- 371
		local createPanelRef = reference() -- 373
		host:removeAllChildren() -- 374
		host.scaleX = App.devicePixelRatio -- 375
		host.scaleY = App.devicePixelRatio -- 376
		local ____App_visualSize_20 = App.visualSize -- 377
		local width = ____App_visualSize_20.width -- 377
		local height = ____App_visualSize_20.height -- 377
		local safe = App.safeArea -- 378
		local left = safe.left -- 379
		local bottom = safe.bottom -- 380
		local usableWidth = safe.width -- 381
		local usableHeight = safe.height -- 382
		local wide = usableWidth >= 760 -- 383
		local shortLandscape = wide and usableHeight < 500 -- 384
		local compact = not wide and usableHeight < 700 -- 385
		local compactLandscape = compact and usableWidth > usableHeight and usableHeight < 520 -- 386
		local landscapeTopLift = shortLandscape and 28 or 0 -- 387
		local data = entries() -- 388
		index = normalizeFeedIndex(index, #data) -- 389
		local item = current() -- 390
		rememberCurrent() -- 391
		local coverWidth = wide and math.min(usableWidth * 0.54, 680) or usableWidth - 32 -- 392
		local coverHeight = wide and math.min(usableHeight - 118, coverWidth * 0.72) or (compact and math.min(usableHeight * (compactLandscape and 0.43 or 0.49), coverWidth * 0.72) or math.min(usableHeight * 0.54, coverWidth * 1.12)) -- 393
		local coverX = left + 16 -- 398
		local coverY = wide and bottom + (usableHeight - coverHeight) / 2 - 12 + landscapeTopLift or bottom + usableHeight - coverHeight - 82 -- 399
		local infoX = wide and coverX + coverWidth + 28 or left + 20 -- 400
		local infoWidth = wide and usableWidth - coverWidth - 72 or usableWidth - 40 -- 401
		local infoTop = wide and bottom + usableHeight - 122 + landscapeTopLift or coverY - (compactLandscape and 28 or 30) -- 402
		local descriptionY = infoTop - (compactLandscape and 38 or 58) -- 403
		local actionsY = bottom + (compactLandscape and 18 or 24) -- 404
		local gestureHintY = bottom + (compactLandscape and 88 or 92) -- 405
		local buttonWidth = wide and math.min(190, (infoWidth - 12) / 2) or (infoWidth - 12) / 2 -- 406
		local fontScale = mobileFontScale -- 407
		local cardIndices = getReusableCardIndices(index, #data) -- 408
		local headerRenderOrder = 1000 -- 409
		local ____toNode_49 = toNode -- 411
		local ____React_createElement_48 = React.createElement -- 411
		local ____array_47 = __TS__SparseArrayNew( -- 411
			"node", -- 411
			{ -- 411
				tag = "mobile-feed-scene", -- 411
				x = -width / 2, -- 411
				y = -height / 2, -- 411
				width = width, -- 411
				height = height, -- 411
				anchorX = 0, -- 411
				anchorY = 0, -- 411
				touchEnabled = true, -- 411
				onTapBegan = function() -- 411
					drag = Vec2.zero -- 421
					dragAxis = "none" -- 422
					local ____opt_21 = cardRef.current -- 422
					if ____opt_21 ~= nil then -- 422
						____opt_21:stopAllActions() -- 423
					end -- 423
					if indexRef.current then -- 423
						indexRef.current.opacity = 1 -- 424
					end -- 424
				end, -- 420
				onTapMoved = function(touch) -- 420
					drag = drag:add(touch.delta) -- 427
					if dragAxis == "none" and math.max( -- 427
						math.abs(drag.x), -- 428
						math.abs(drag.y) -- 428
					) >= 12 then -- 428
						dragAxis = math.abs(drag.x) > math.abs(drag.y) * 1.2 and "horizontal" or "vertical" -- 429
					end -- 429
					if cardRef.current then -- 429
						local offset = dragAxis == "horizontal" and Vec2(drag.x * 0.18, 0) or (dragAxis == "vertical" and Vec2(0, drag.y * 0.12) or Vec2.zero) -- 432
						cardRef.current.position = offset -- 433
						if indexRef.current then -- 433
							local headerBottom = bottom + usableHeight - 72 -- 435
							local indexTop = coverY + coverHeight - 14 + offset.y -- 436
							indexRef.current.opacity = dragAxis == "vertical" and math.max( -- 437
								0, -- 438
								math.min(1, (headerBottom - indexTop) / 16) -- 438
							) or 1 -- 438
						end -- 438
					end -- 438
				end, -- 426
				onTapEnded = function() -- 426
					local action = resolveFeedGesture(drag.x, drag.y, usableWidth, usableHeight) -- 444
					drag = Vec2.zero -- 445
					dragAxis = "none" -- 446
					if indexRef.current then -- 446
						indexRef.current.opacity = 1 -- 447
					end -- 447
					if action == "none" and cardRef.current then -- 447
						local card = cardRef.current -- 449
						card:perform(Move(App.reducedMotion and 0 or 0.16, card.position, Vec2.zero, Ease.OutQuad)) -- 450
					end -- 450
					commit(action) -- 452
				end, -- 443
				onMouseWheel = function(delta) return commit(delta.y > 0 and "previous" or "next") end -- 443
			}, -- 443
			React.createElement(VerticalGradient, {width = width, height = height, topColor = 4279310117, bottomColor = 4278716943}) -- 443
		) -- 443
		local ____createOpen_32 -- 457
		if createOpen then -- 457
			____createOpen_32 = nil -- 457
		else -- 457
			local ____temp_31 -- 457
			if item ~= nil then -- 457
				local ____React_createElement_30 = React.createElement -- 457
				local ____array_29 = __TS__SparseArrayNew( -- 457
					"node", -- 457
					{tag = "mobile-feed-card-" .. item.id, ref = cardRef, key = (tab .. "-") .. item.id}, -- 457
					__TS__ArrayMap( -- 458
						cardIndices, -- 458
						function(____, cardIndex) return React.createElement(Cover, { -- 458
							key = (tab .. "-") .. data[cardIndex + 1].id, -- 458
							entry = data[cardIndex + 1], -- 458
							x = coverX, -- 458
							y = coverY + (index - cardIndex) * usableHeight, -- 458
							width = coverWidth, -- 458
							height = coverHeight -- 458
						}) end -- 458
					) -- 458
				) -- 458
				local ____React_createElement_26 = React.createElement -- 458
				local ____temp_24 = { -- 458
					tag = "mobile-feed-index", -- 458
					ref = indexRef, -- 458
					x = coverX + coverWidth - 62, -- 458
					y = coverY + coverHeight - 40, -- 458
					width = 48, -- 458
					height = 26, -- 458
					anchorX = 0, -- 458
					anchorY = 0, -- 458
					touchEnabled = tab == "local", -- 458
					swallowTouches = tab == "local", -- 458
					onTapped = tab == "local" and openProjectIndex or nil -- 458
				} -- 458
				local ____React_createElement_result_25 = React.createElement(RoundedSurface, { -- 458
					width = 48, -- 458
					height = 26, -- 458
					radius = 13, -- 458
					topColor = 3760730173, -- 458
					bottomColor = 3759281694, -- 458
					borderWidth = 1, -- 458
					borderColor = 2286967404 -- 458
				}) -- 458
				local ____temp_23 -- 470
				if tab == "local" then -- 470
					____temp_23 = React.createElement(RoundedSurface, { -- 470
						x = 18, -- 470
						y = 2, -- 470
						width = 12, -- 470
						height = 2, -- 470
						radius = 1, -- 470
						fillColor = colors.brand -- 470
					}) -- 470
				else -- 470
					____temp_23 = nil -- 470
				end -- 470
				__TS__SparseArrayPush( -- 470
					____array_29, -- 470
					____React_createElement_26( -- 470
						"node", -- 470
						____temp_24, -- 470
						____React_createElement_result_25, -- 470
						____temp_23, -- 470
						React.createElement( -- 470
							"label", -- 470
							{ -- 470
								x = 24, -- 470
								y = 13, -- 470
								fontName = fontName, -- 470
								fontSize = 11, -- 470
								text = (tostring(index + 1) .. " / ") .. tostring(#data), -- 470
								color3 = 14146531 -- 470
							} -- 470
						) -- 470
					), -- 470
					React.createElement( -- 470
						"label", -- 470
						{ -- 470
							tag = "mobile-feed-current-title", -- 470
							x = infoX, -- 470
							y = infoTop, -- 470
							anchorX = 0, -- 470
							anchorY = 0.5, -- 470
							fontName = fontName, -- 470
							fontSize = math.floor((wide and 30 or 25) * fontScale), -- 470
							text = item.title, -- 470
							textWidth = infoWidth - (item.kind == "local" and 92 or 0), -- 470
							alignment = "Left", -- 470
							color3 = 16052712 -- 470
						} -- 470
					) -- 470
				) -- 470
				local ____temp_27 -- 475
				if item.kind == "local" then -- 475
					____temp_27 = React.createElement( -- 475
						MobileButton, -- 475
						{ -- 475
							tag = "mobile-feed-share", -- 475
							x = infoX + infoWidth - 84, -- 475
							y = infoTop - 18, -- 475
							width = 84, -- 475
							height = 36, -- 475
							text = zh and "分享作品" or "Share", -- 475
							fontSize = 13, -- 475
							onTapped = function() return openPackage("share") end -- 475
						} -- 475
					) -- 475
				else -- 475
					____temp_27 = nil -- 475
				end -- 475
				__TS__SparseArrayPush( -- 475
					____array_29, -- 475
					____temp_27, -- 475
					React.createElement( -- 475
						"label", -- 475
						{ -- 475
							tag = "mobile-feed-description", -- 475
							x = infoX, -- 475
							y = descriptionY, -- 475
							anchorX = 0, -- 475
							anchorY = 0.5, -- 475
							fontName = fontName, -- 475
							fontSize = math.floor(15 * fontScale), -- 475
							text = conciseDescription(item.description, wide and 80 or (compact and 28 or 42)), -- 475
							textWidth = infoWidth, -- 475
							alignment = "Left", -- 475
							color3 = 11055037 -- 475
						} -- 475
					) -- 475
				) -- 475
				local ____temp_28 -- 478
				if compact or shortLandscape then -- 478
					____temp_28 = nil -- 478
				else -- 478
					____temp_28 = React.createElement( -- 478
						"node", -- 478
						{ -- 478
							x = infoX, -- 478
							y = infoTop - 118, -- 478
							width = wide and 176 or 164, -- 478
							height = 28, -- 478
							anchorX = 0, -- 478
							anchorY = 0 -- 478
						}, -- 478
						React.createElement(RoundedSurface, { -- 478
							width = wide and 176 or 164, -- 478
							height = 28, -- 478
							radius = 14, -- 478
							topColor = 1714436683, -- 478
							bottomColor = 1712857131, -- 478
							borderWidth = 1, -- 478
							borderColor = 2288020349 -- 478
						}), -- 478
						React.createElement("label", { -- 478
							x = 12, -- 478
							y = 14, -- 478
							anchorX = 0, -- 478
							fontName = fontName, -- 478
							fontSize = 12, -- 478
							text = item.kind == "local" and (zh and "本地作品  ·  可 Remix" or "Local  ·  Remixable") or (item.installed and (zh and "发现  ·  已安装" or "Discover  ·  Installed") or (zh and "发现  ·  可安装" or "Discover  ·  Installable")), -- 478
							textWidth = (wide and 176 or 164) - 24, -- 478
							alignment = "Left", -- 478
							color3 = 14475754 -- 478
						}) -- 478
					) -- 478
				end -- 478
				__TS__SparseArrayPush( -- 478
					____array_29, -- 478
					____temp_28, -- 478
					React.createElement( -- 478
						MobileButton, -- 484
						{ -- 484
							tag = "mobile-feed-remix", -- 484
							x = infoX, -- 484
							y = actionsY, -- 484
							width = buttonWidth, -- 484
							text = zh and "Remix 作品" or "Remix game", -- 484
							fontSize = math.floor(16 * fontScale), -- 484
							primary = true, -- 484
							onTapped = function() return activate("remix") end -- 484
						} -- 484
					), -- 484
					React.createElement( -- 484
						MobileButton, -- 486
						{ -- 486
							tag = "mobile-feed-play", -- 486
							x = infoX + buttonWidth + 12, -- 486
							y = actionsY, -- 486
							width = buttonWidth, -- 486
							text = zh and "试玩" or "Play", -- 486
							fontSize = math.floor(17 * fontScale), -- 486
							onTapped = function() return activate("play") end -- 486
						} -- 486
					), -- 486
					React.createElement("label", { -- 486
						tag = "mobile-feed-gesture-hint", -- 486
						x = infoX, -- 486
						y = gestureHintY, -- 486
						anchorX = 0, -- 486
						anchorY = 0.5, -- 486
						fontName = fontName, -- 486
						fontSize = gamepadUsed and 11 or 14, -- 486
						text = prepareStatus ~= "" and prepareStatus or (item.launchError ~= nil and item.launchError or (gamepadUsed and (zh and "↑↓ 浏览 · A 确认 · X Remix · Start 列表 · Y 新建" or "↑↓ Browse · A Select · X Remix · Start List · Y New") or (zh and "上滑浏览  ·  右滑 Remix  ·  左滑试玩" or "Swipe up  ·  right Remix  ·  left Play"))), -- 486
						textWidth = infoWidth, -- 486
						alignment = "Left", -- 486
						color3 = item.launchError ~= nil and 16739179 or 11055037 -- 486
					}) -- 486
				) -- 486
				____temp_31 = ____React_createElement_30(__TS__SparseArraySpread(____array_29)) -- 486
			else -- 486
				____temp_31 = React.createElement( -- 486
					"node", -- 486
					nil, -- 486
					React.createElement("label", { -- 486
						x = left + usableWidth / 2, -- 486
						y = bottom + usableHeight / 2 + 20, -- 486
						fontName = fontName, -- 486
						fontSize = 22, -- 486
						text = tab == "discover" and (zh and "暂无移动作品" or "No mobile games yet") or (zh and "没有可运行的本地作品" or "No runnable local games"), -- 486
						color3 = 16052712 -- 486
					}), -- 486
					React.createElement("label", { -- 486
						x = left + usableWidth / 2, -- 486
						y = bottom + usableHeight / 2 - 28, -- 486
						fontName = fontName, -- 486
						fontSize = 14, -- 486
						text = tab == "discover" and discoverError ~= "" and discoverError or (zh and "切换标签或稍后重试" or "Switch tabs or retry later"), -- 486
						textWidth = usableWidth - 48, -- 486
						color3 = tab == "discover" and discoverError ~= "" and 16739179 or 11055037 -- 486
					}) -- 486
				) -- 486
			end -- 486
			____createOpen_32 = ____temp_31 -- 457
		end -- 457
		__TS__SparseArrayPush(____array_47, ____createOpen_32) -- 457
		local ____temp_33 -- 499
		if not item and tab == "local" then -- 499
			____temp_33 = React.createElement( -- 499
				"node", -- 499
				nil, -- 499
				React.createElement(MobileButton, { -- 499
					tag = "mobile-empty-new", -- 499
					x = left + 20, -- 499
					y = bottom + 24, -- 499
					width = (usableWidth - 52) / 2, -- 499
					text = zh and "新建作品" or "New game", -- 499
					onTapped = openCreate -- 499
				}), -- 499
				React.createElement( -- 499
					MobileButton, -- 501
					{ -- 501
						tag = "mobile-empty-import", -- 501
						x = left + 32 + (usableWidth - 52) / 2, -- 501
						y = bottom + 24, -- 501
						width = (usableWidth - 52) / 2, -- 501
						text = zh and "导入作品包" or "Import package", -- 501
						fontSize = 15, -- 501
						primary = true, -- 501
						onTapped = function() return openPackage("add") end -- 501
					} -- 501
				) -- 501
			) -- 501
		else -- 501
			____temp_33 = nil -- 502
		end -- 502
		__TS__SparseArrayPush(____array_47, ____temp_33) -- 502
		local ____React_createElement_37 = React.createElement -- 502
		local ____array_36 = __TS__SparseArrayNew("node", {tag = "mobile-feed-header", order = headerRenderOrder}) -- 502
		local ____options_onSwitchMode_34 -- 504
		if options.onSwitchMode then -- 504
			____options_onSwitchMode_34 = React.createElement( -- 504
				"node", -- 504
				{ -- 504
					tag = "mobile-ui-mode-switch", -- 504
					x = left + 12, -- 504
					y = bottom + usableHeight - 58 + landscapeTopLift, -- 504
					width = 72, -- 504
					height = 48, -- 504
					anchorX = 0, -- 504
					anchorY = 0, -- 504
					touchEnabled = true, -- 504
					swallowTouches = true, -- 504
					onTapped = switchMode -- 504
				}, -- 504
				React.createElement("label", { -- 504
					x = 0, -- 504
					y = 30, -- 504
					anchorX = 0, -- 504
					fontName = fontName, -- 504
					fontSize = 16, -- 504
					text = "DORA", -- 504
					color3 = preparing and 7831180 or 16763955 -- 504
				}), -- 504
				React.createElement("label", { -- 504
					x = 0, -- 504
					y = 10, -- 504
					anchorX = 0, -- 504
					fontName = fontName, -- 504
					fontSize = 10, -- 504
					text = zh and "切换传统界面" or "Classic UI", -- 504
					color3 = 7831180 -- 504
				}) -- 504
			) -- 504
		else -- 504
			____options_onSwitchMode_34 = nil -- 508
		end -- 508
		__TS__SparseArrayPush( -- 508
			____array_36, -- 508
			____options_onSwitchMode_34, -- 508
			React.createElement( -- 508
				"label", -- 508
				{ -- 508
					tag = "mobile-feed-discover-tab", -- 508
					x = left + usableWidth / 2 - 44, -- 508
					y = bottom + usableHeight - 34 + landscapeTopLift, -- 508
					fontName = fontName, -- 508
					fontSize = math.floor(17 * fontScale), -- 508
					text = zh and "发现" or "Discover", -- 508
					color3 = tab == "discover" and 16763955 or 11055037, -- 508
					touchEnabled = true, -- 508
					swallowTouches = true, -- 508
					onTapped = function() return setTab("discover") end -- 508
				} -- 508
			), -- 508
			React.createElement( -- 508
				"label", -- 508
				{ -- 508
					tag = "mobile-feed-local-tab", -- 508
					x = left + usableWidth / 2 + 44, -- 508
					y = bottom + usableHeight - 34 + landscapeTopLift, -- 508
					fontName = fontName, -- 508
					fontSize = math.floor(17 * fontScale), -- 508
					text = zh and "本地" or "Local", -- 508
					color3 = tab == "local" and 16763955 or 11055037, -- 508
					touchEnabled = true, -- 508
					swallowTouches = true, -- 508
					onTapped = function() -- 508
						____local = getLocalEntries() -- 514
						setTab("local") -- 514
					end -- 514
				} -- 514
			), -- 514
			React.createElement(RoundedSurface, { -- 514
				x = left + usableWidth / 2 + (tab == "discover" and -58 or 30), -- 514
				y = bottom + usableHeight - 56 + landscapeTopLift, -- 514
				width = 28, -- 514
				height = 3, -- 514
				radius = 1.5, -- 514
				fillColor = colors.brand, -- 514
				renderOrder = headerRenderOrder + 1 -- 514
			}) -- 514
		) -- 514
		local ____temp_35 -- 516
		if tab == "local" and options.createProject then -- 516
			____temp_35 = React.createElement( -- 516
				MobileNewButton, -- 516
				{ -- 516
					tag = "mobile-feed-create", -- 516
					x = left + usableWidth - 82, -- 516
					y = bottom + usableHeight - 56 + landscapeTopLift, -- 516
					text = zh and "+ 新建" or "+ New", -- 516
					renderOrder = headerRenderOrder + 1, -- 516
					onTapped = function() return openPackage("add") end -- 516
				} -- 516
			) -- 516
		else -- 516
			____temp_35 = nil -- 518
		end -- 518
		__TS__SparseArrayPush(____array_36, ____temp_35) -- 518
		__TS__SparseArrayPush( -- 518
			____array_47, -- 518
			____React_createElement_37(__TS__SparseArraySpread(____array_36)) -- 518
		) -- 518
		local ____createOpen_45 -- 520
		if createOpen then -- 520
			____createOpen_45 = (function() -- 520
				local sheetHeight = math.min(createSheetHeight, usableHeight - 64) -- 521
				local sheetWidth = usableWidth -- 522
				local contentWidth = sheetWidth - 40 -- 523
				local actionGap = 12 -- 524
				local actionsWidth = shortLandscape and math.min( -- 525
					300, -- 525
					math.floor(contentWidth * 0.42) -- 525
				) or contentWidth -- 525
				local inputWidth = shortLandscape and contentWidth - actionGap - actionsWidth or contentWidth -- 526
				local actionX = shortLandscape and 20 + inputWidth + actionGap or 20 -- 527
				local actionY = shortLandscape and sheetHeight - createInputTop - createInputHeight or 20 -- 528
				local cancelWidth = math.floor((actionsWidth - actionGap) * (shortLandscape and 0.34 or 0.38)) -- 529
				local ____React_createElement_44 = React.createElement -- 529
				local ____array_43 = __TS__SparseArrayNew( -- 529
					"node", -- 529
					{ -- 529
						tag = "mobile-project-create-sheet", -- 529
						order = 10000, -- 529
						width = width, -- 529
						height = height, -- 529
						anchorX = 0, -- 529
						anchorY = 0, -- 529
						touchEnabled = true, -- 529
						swallowTouches = true -- 529
					}, -- 529
					React.createElement( -- 529
						"node", -- 529
						{ -- 529
							tag = "mobile-project-create-focus-observer", -- 529
							order = 1000, -- 529
							width = width, -- 529
							height = height, -- 529
							anchorX = 0, -- 529
							anchorY = 0, -- 529
							touchEnabled = true, -- 529
							swallowTouches = false, -- 529
							swallowMouseWheel = false, -- 529
							onTapFilter = function(touch) -- 529
								touch.enabled = false -- 533
								if not canEditCreate() then -- 533
									return -- 534
								end -- 534
								local input = createInputRef.current -- 535
								local point = input and input:convertToNodeSpace(touch.worldLocation) -- 536
								local inside = input and point and point.x >= 0 and point.y >= 0 and point.x <= input.width and point.y <= input.height -- 537
								dismissedCreateComposition = not inside and createInput.isComposing() -- 538
								if not inside then -- 538
									blurCreateInput() -- 539
								end -- 539
							end -- 532
						} -- 532
					), -- 532
					React.createElement( -- 532
						"draw-node", -- 532
						{ -- 532
							tag = "mobile-project-create-backdrop", -- 532
							order = 0, -- 532
							renderOrder = 0, -- 532
							x = width / 2, -- 532
							y = bottom + sheetHeight + (height - bottom - sheetHeight) / 2 -- 532
						}, -- 532
						React.createElement("rect-shape", {width = width, height = height - bottom - sheetHeight, fillColor = 2348810240}) -- 532
					) -- 532
				) -- 532
				local ____React_createElement_42 = React.createElement -- 532
				local ____array_41 = __TS__SparseArrayNew( -- 532
					"node", -- 532
					{ -- 532
						ref = createPanelRef, -- 532
						order = 10, -- 532
						renderOrder = 10, -- 532
						x = left, -- 532
						y = bottom, -- 532
						width = sheetWidth, -- 532
						height = sheetHeight, -- 532
						anchorX = 0, -- 532
						anchorY = 0, -- 532
						touchEnabled = true, -- 532
						swallowTouches = true -- 532
					}, -- 532
					React.createElement(MobilePanelSurface, {width = sheetWidth, height = sheetHeight, renderOrder = 10}), -- 532
					React.createElement("label", { -- 532
						x = 20, -- 532
						y = sheetHeight - 24, -- 532
						anchorX = 0, -- 532
						anchorY = 1, -- 532
						fontName = fontName, -- 532
						fontSize = 22, -- 532
						text = zh and "新建项目" or "New project", -- 532
						color3 = 16052712 -- 532
					}), -- 532
					React.createElement("label", { -- 532
						x = 20, -- 532
						y = sheetHeight - 66, -- 532
						anchorX = 0, -- 532
						anchorY = 1, -- 532
						fontName = fontName, -- 532
						fontSize = 14, -- 532
						text = zh and "项目名称" or "Project name", -- 532
						color3 = 11055037 -- 532
					}) -- 532
				) -- 532
				local ____keptInput_40 -- 548
				if keptInput then -- 548
					____keptInput_40 = nil -- 548
				else -- 548
					____keptInput_40 = React.createElement("node", { -- 548
						tag = "mobile-project-create-input", -- 548
						ref = createInputRef, -- 548
						renderOrder = 10, -- 548
						x = 20, -- 548
						y = sheetHeight - createInputTop - createInputHeight, -- 548
						width = inputWidth, -- 548
						height = createInputHeight, -- 548
						anchorX = 0, -- 548
						anchorY = 0, -- 548
						onMount = createInput.mount -- 548
					}) -- 548
				end -- 548
				__TS__SparseArrayPush( -- 548
					____array_41, -- 548
					____keptInput_40, -- 548
					React.createElement("label", { -- 548
						tag = "mobile-project-create-error", -- 548
						x = 20, -- 548
						y = shortLandscape and sheetHeight - createInputTop + 12 or sheetHeight - createInputTop - createInputHeight - 12, -- 548
						anchorX = 0, -- 548
						anchorY = 1, -- 548
						fontName = fontName, -- 548
						fontSize = 12, -- 548
						text = createError ~= "" and createError or (zh and "将创建可运行的 TypeScript 起始项目" or "Creates a runnable TypeScript starter project"), -- 548
						textWidth = inputWidth, -- 548
						alignment = "Left", -- 548
						color3 = createError ~= "" and 16739179 or 11055037 -- 548
					}), -- 548
					React.createElement(MobileButton, { -- 548
						tag = "mobile-project-create-cancel", -- 548
						x = actionX, -- 548
						y = actionY, -- 548
						width = cancelWidth, -- 548
						text = zh and "取消" or "Cancel", -- 548
						renderOrder = 10, -- 548
						onTapped = closeCreate -- 548
					}), -- 548
					React.createElement( -- 548
						MobileButton, -- 554
						{ -- 554
							tag = "mobile-project-create-submit", -- 554
							x = actionX + cancelWidth + actionGap, -- 554
							y = actionY, -- 554
							width = actionsWidth - cancelWidth - actionGap, -- 554
							text = creating and (zh and "创建中…" or "Creating…") or (zh and "创建并进入 Remix" or "Create and Remix"), -- 554
							primary = true, -- 554
							renderOrder = 10, -- 554
							onTapped = function() -- 554
								if not dismissedCreateComposition then -- 554
									submitCreate() -- 555
								end -- 555
								dismissedCreateComposition = false -- 555
							end -- 555
						} -- 555
					) -- 555
				) -- 555
				__TS__SparseArrayPush( -- 555
					____array_43, -- 555
					____React_createElement_42(__TS__SparseArraySpread(____array_41)) -- 555
				) -- 555
				return ____React_createElement_44(__TS__SparseArraySpread(____array_43)) -- 530
			end)() -- 520
		else -- 520
			____createOpen_45 = nil -- 558
		end -- 558
		__TS__SparseArrayPush(____array_47, ____createOpen_45) -- 558
		local ____projectIndexOpen_46 -- 559
		if projectIndexOpen then -- 559
			____projectIndexOpen_46 = React.createElement( -- 559
				ProjectIndex, -- 559
				{ -- 559
					entries = ____local, -- 559
					current = current(), -- 559
					x = left, -- 559
					y = bottom, -- 559
					width = usableWidth, -- 559
					height = usableHeight, -- 559
					zh = zh, -- 559
					onClose = function() -- 559
						projectIndexOpen = false -- 560
						render() -- 560
					end, -- 560
					onSelect = function(____, entry) -- 560
						projectIndexOpen = false -- 562
						local location = resolveFeedLocation(____local, discover, entry) -- 563
						tab = "local" -- 564
						index = location.tab == "local" and location.index or 0 -- 564
						render() -- 565
					end -- 561
				} -- 561
			) -- 561
		else -- 561
			____projectIndexOpen_46 = nil -- 566
		end -- 566
		__TS__SparseArrayPush(____array_47, ____projectIndexOpen_46) -- 566
		local scene = ____toNode_49(____React_createElement_48(__TS__SparseArraySpread(____array_47))) -- 411
		if scene ~= nil then -- 411
			host:addChild(scene) -- 568
		end -- 568
		if keptInput and createPanelRef.current then -- 568
			keptInput.position = Vec2( -- 570
				20, -- 570
				math.min(createSheetHeight, usableHeight - 64) - createInputTop - createInputHeight -- 570
			) -- 570
			createPanelRef.current:addChild(keptInput) -- 571
		end -- 571
		createInput.refresh() -- 573
		if restoreFocus and not keptInput and createOpen then -- 573
			createInput.focus(false) -- 574
		end -- 574
	end -- 360
	attachGamepad( -- 577
		host, -- 577
		{ -- 577
			initialTag = "mobile-feed-play", -- 578
			isEnabled = function() return isActive() and not packagePanel and not preparing and not transitioning and not creating end, -- 579
			onActive = function() -- 580
				gamepadUsed = true -- 580
				render() -- 580
			end, -- 580
			onBack = function() -- 581
				if createInput.isFocused() then -- 581
					blurCreateInput() -- 581
				elseif createOpen then -- 581
					closeCreate() -- 581
				else -- 581
					switchMode() -- 581
				end -- 581
			end, -- 581
			onActivate = function(target) -- 582
				if target.tag == "mobile-project-create-input" then -- 582
					target:emit("GamepadActivate") -- 583
				else -- 583
					if createInput.isComposing() then -- 583
						blurCreateInput() -- 585
						return -- 585
					end -- 585
					blurCreateInput() -- 586
					dismissedCreateComposition = false -- 587
					target:emit("Tapped") -- 588
				end -- 588
			end, -- 582
			onButton = function(button) -- 591
				if createOpen then -- 591
					return false -- 592
				end -- 592
				repeat -- 592
					local ____switch121 = button -- 592
					local ____cond121 = ____switch121 == "dpup" -- 592
					if ____cond121 then -- 592
						commit("previous") -- 594
						return true -- 594
					end -- 594
					____cond121 = ____cond121 or ____switch121 == "dpdown" -- 594
					if ____cond121 then -- 594
						commit("next") -- 595
						return true -- 595
					end -- 595
					____cond121 = ____cond121 or ____switch121 == "leftshoulder" -- 595
					if ____cond121 then -- 595
						setTab("discover") -- 596
						return true -- 596
					end -- 596
					____cond121 = ____cond121 or ____switch121 == "rightshoulder" -- 596
					if ____cond121 then -- 596
						setTab("local") -- 597
						return true -- 597
					end -- 597
					____cond121 = ____cond121 or ____switch121 == "x" -- 597
					if ____cond121 then -- 597
						commit("remix") -- 598
						return true -- 598
					end -- 598
					____cond121 = ____cond121 or ____switch121 == "y" -- 598
					if ____cond121 then -- 598
						local ____opt_50 = findGamepadNode(host, "mobile-feed-create") -- 598
						if ____opt_50 ~= nil then -- 598
							____opt_50:emit("Tapped") -- 599
						end -- 599
						return true -- 599
					end -- 599
					____cond121 = ____cond121 or ____switch121 == "start" -- 599
					if ____cond121 then -- 599
						openProjectIndex() -- 600
						return true -- 600
					end -- 600
					do -- 600
						return false -- 601
					end -- 601
				until true -- 601
			end -- 591
		} -- 591
	) -- 591
	host:onAppChange(function(setting) -- 605
		if setting == "Locale" then -- 605
			local activeEntry = current() -- 607
			zh = (string.match(App.locale, "^zh")) ~= nil -- 608
			____local = getLocalEntries() -- 609
			discover = getDiscoverEntries() -- 610
			local location = resolveFeedLocation(____local, discover, activeEntry) -- 611
			tab = location.tab -- 612
			index = location.index -- 613
			render() -- 614
		elseif setting == "Size" then -- 614
			render() -- 615
		end -- 615
	end) -- 605
	host:onAppEvent(function(event) -- 617
		if event == "BackButton" then -- 617
			if projectIndexOpen then -- 617
				projectIndexOpen = false -- 619
				render() -- 619
			elseif createOpen and not creating then -- 619
				closeCreate() -- 620
			end -- 620
		elseif event == "WillEnterBackground" or event == "DidEnterBackground" then -- 620
			blurCreateInput() -- 621
		end -- 621
	end) -- 617
	host:onCleanup(function() -- 623
		blurCreateInput() -- 623
		active = false -- 623
		if packagePanel ~= nil then -- 623
			packagePanel:removeFromParent(true) -- 623
		end -- 623
		packagePanel = nil -- 623
	end) -- 623
	host:slot( -- 624
		"RestoreFeedEntry", -- 624
		function(entry) -- 624
			if not isActive() or HttpServer.wsConnectionCount > 0 then -- 624
				return -- 625
			end -- 625
			returnEntry = entry -- 626
			____local = getLocalEntries() -- 627
			discover = getDiscoverEntries() -- 628
			local location = resolveFeedLocation(____local, discover, entry) -- 629
			tab = location.tab -- 630
			index = location.index -- 631
			render() -- 632
		end -- 624
	) -- 624
	host:slot("SuspendLocalUI", blurCreateInput) -- 634
	host:slot( -- 635
		"ResumeLocalUI", -- 635
		function() -- 635
			leaving = false -- 635
			render() -- 635
		end -- 635
	) -- 635
	render() -- 636
	if syncDiscover then -- 636
		if #discover == 0 then -- 636
			discoverError = zh and "正在同步资源目录…" or "Syncing Catalog…" -- 639
			render() -- 640
		end -- 640
		syncDiscover( -- 642
			function(message) -- 642
				if not isActive() or #discover > 0 then -- 642
					return -- 643
				end -- 643
				discoverError = message -- 644
				render() -- 645
			end, -- 642
			function(success, message) -- 646
				if not isActive() then -- 646
					return -- 647
				end -- 647
				local selected = returnEntry or rememberedEntries[tab] or current() -- 648
				local previousCount = #discover -- 649
				discover = getDiscoverEntries() -- 650
				discoverError = success and (#discover == 0 and (zh and "目录中暂无可运行作品" or "No runnable Catalog games") or "") or (message or (zh and "资源目录同步失败" or "Catalog sync failed")) -- 651
				tab = resolveDiscoverRefreshTab( -- 654
					tab, -- 654
					userSelectedTab, -- 654
					previousCount, -- 654
					#discover, -- 654
					#____local -- 654
				) -- 654
				if selected ~= nil then -- 654
					local location = resolveFeedLocation(____local, discover, selected) -- 656
					tab = location.tab -- 657
					index = location.index -- 658
				end -- 658
				if tab == "discover" then -- 658
					index = normalizeFeedIndex(index, #discover) -- 660
				end -- 660
				render() -- 661
			end -- 646
		) -- 646
	end -- 646
	return host -- 664
end -- 97
return ____exports -- 97