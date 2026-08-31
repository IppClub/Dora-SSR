-- [tsx]: Feed.tsx
local ____lualib = require("lualib_bundle") -- 1
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
local ____Accessibility = require("Dev.Mobile.Accessibility") -- 4
local mobileFontScale = ____Accessibility.mobileFontScale -- 4
local ____FeedModel = require("Dev.Mobile.FeedModel") -- 5
local getCoverScales = ____FeedModel.getCoverScales -- 5
local getReusableCardIndices = ____FeedModel.getReusableCardIndices -- 5
local normalizeFeedIndex = ____FeedModel.normalizeFeedIndex -- 5
local resolveDiscoverRefreshTab = ____FeedModel.resolveDiscoverRefreshTab -- 5
local resolveFeedGesture = ____FeedModel.resolveFeedGesture -- 5
local resolveFeedLocation = ____FeedModel.resolveFeedLocation -- 5
local stableCoverColor = ____FeedModel.stableCoverColor -- 5
local ____TextInput = require("Dev.Mobile.TextInput") -- 6
local createTextInput = ____TextInput.createTextInput -- 6
local colors = { -- 26
	background = 4278914322, -- 27
	panel = 4279572770, -- 28
	panelRaised = 4280297010, -- 29
	text = 4294242792, -- 30
	muted = 4289245117, -- 31
	brand = 4294954035, -- 32
	border = 4281613128, -- 33
	danger = 4294929259 -- 34
} -- 34
local fontName = "sarasa-mono-sc-regular" -- 37
local createSheetHeight = 260 -- 38
local createInputHeight = 44 -- 39
local createInputTop = 96 -- 40
local function Button(props) -- 42
	return React.createElement( -- 52
		"node", -- 52
		{ -- 52
			tag = props.tag, -- 52
			x = props.x, -- 52
			y = props.y, -- 52
			anchorX = 0, -- 52
			anchorY = 0, -- 52
			width = props.width, -- 52
			height = 48, -- 52
			touchEnabled = true, -- 52
			swallowTouches = true, -- 52
			onTapped = props.onTapped -- 52
		}, -- 52
		React.createElement( -- 52
			"draw-node", -- 52
			{x = props.width / 2, y = 24}, -- 52
			React.createElement("rect-shape", { -- 52
				width = props.width, -- 52
				height = 48, -- 52
				fillColor = props.primary and colors.brand or colors.panelRaised, -- 52
				borderWidth = 1, -- 52
				borderColor = props.primary and colors.brand or colors.border -- 52
			}) -- 52
		), -- 52
		React.createElement("label", { -- 52
			x = props.width / 2, -- 52
			y = 24, -- 52
			fontName = fontName, -- 52
			fontSize = props.fontSize or 17, -- 52
			text = props.text, -- 52
			color3 = props.primary and 1512202 or 16052712 -- 52
		}) -- 52
	) -- 52
end -- 42
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
		"draw-node", -- 86
		{x = props.width / 2, y = props.height / 2}, -- 86
		React.createElement( -- 86
			"rect-shape", -- 86
			{ -- 86
				width = props.width, -- 86
				height = props.height, -- 86
				fillColor = stableCoverColor(props.entry.id), -- 86
				borderWidth = 1, -- 86
				borderColor = colors.border -- 86
			} -- 86
		) -- 86
	) -- 86
	local ____file_0 -- 101
	if file then -- 101
		____file_0 = React.createElement( -- 101
			"clip-node", -- 101
			{ -- 101
				width = props.width, -- 101
				height = props.height, -- 101
				anchorX = 0, -- 101
				anchorY = 0, -- 101
				stencil = React.createElement( -- 101
					"draw-node", -- 101
					{x = props.width / 2, y = props.height / 2}, -- 101
					React.createElement("rect-shape", {width = props.width, height = props.height, fillColor = 4294967295}) -- 101
				) -- 101
			}, -- 101
			React.createElement( -- 101
				"sprite", -- 101
				{ -- 101
					file = file, -- 101
					x = props.width / 2 - 5, -- 101
					y = props.height / 2, -- 101
					opacity = 0.08, -- 101
					onMount = function(sprite) return scaleSprite(sprite, "cover") end -- 101
				} -- 101
			), -- 101
			React.createElement( -- 101
				"sprite", -- 101
				{ -- 101
					file = file, -- 101
					x = props.width / 2 + 5, -- 101
					y = props.height / 2, -- 101
					opacity = 0.08, -- 101
					onMount = function(sprite) return scaleSprite(sprite, "cover") end -- 101
				} -- 101
			), -- 101
			React.createElement( -- 101
				"sprite", -- 101
				{ -- 101
					file = file, -- 101
					x = props.width / 2, -- 101
					y = props.height / 2 - 5, -- 101
					opacity = 0.08, -- 101
					onMount = function(sprite) return scaleSprite(sprite, "cover") end -- 101
				} -- 101
			), -- 101
			React.createElement( -- 101
				"draw-node", -- 101
				{x = props.width / 2, y = props.height / 2}, -- 101
				React.createElement("rect-shape", {width = props.width, height = props.height, fillColor = 2953514258}) -- 101
			), -- 101
			React.createElement( -- 101
				"sprite", -- 101
				{ -- 101
					file = file, -- 101
					x = props.width / 2, -- 101
					y = props.height / 2, -- 101
					onMount = function(sprite) return scaleSprite(sprite, "contain") end -- 101
				} -- 101
			) -- 101
		) -- 101
	else -- 101
		____file_0 = React.createElement( -- 101
			"label", -- 101
			{ -- 101
				x = props.width / 2, -- 101
				y = props.height / 2 + 10, -- 101
				fontName = fontName, -- 101
				fontSize = math.floor(math.max( -- 101
					22, -- 115
					math.min(34, props.width / 12) -- 115
				)), -- 115
				text = props.entry.title, -- 115
				textWidth = props.width - 40, -- 115
				color3 = 16052712 -- 115
			} -- 115
		) -- 115
	end -- 115
	local ____file_1 -- 120
	if file then -- 120
		____file_1 = nil -- 120
	else -- 120
		____file_1 = React.createElement("label", { -- 120
			x = props.width / 2, -- 120
			y = 30, -- 120
			fontName = fontName, -- 120
			fontSize = 14, -- 120
			text = "DORA SSR · REMIXABLE", -- 120
			color3 = 16763955 -- 120
		}) -- 120
	end -- 120
	local ____file_2 -- 128
	if file then -- 128
		____file_2 = nil -- 128
	else -- 128
		____file_2 = React.createElement(DoraMascot, {state = "idle", x = props.width - 46, y = 64, size = 42}) -- 128
	end -- 128
	return ____React_createElement_5( -- 91
		"node", -- 91
		____temp_3, -- 91
		____React_createElement_result_4, -- 91
		____file_0, -- 91
		____file_1, -- 91
		____file_2 -- 91
	) -- 91
end -- 84
function ____exports.startMobileFeed(options) -- 132
	local submitCreate, render -- 132
	local getLocalEntries = options.getLocalEntries -- 133
	local getDiscoverEntries = options.getDiscoverEntries -- 134
	local onPlay = options.onPlay -- 135
	local onRemix = options.onRemix -- 136
	local prepare = options.prepare -- 137
	local syncDiscover = options.syncDiscover -- 138
	local zh = (string.match(App.locale, "^zh")) ~= nil -- 139
	local tab = "local" -- 140
	local index = 0 -- 141
	local detailsOpen = false -- 142
	local drag = Vec2.zero -- 143
	local dragAxis = "none" -- 144
	local discoverError = "" -- 145
	local preparing = false -- 146
	local transitioning = false -- 147
	local prepareStatus = "" -- 148
	local repairResourceId = "" -- 149
	local userSelectedTab = false -- 150
	local active = true -- 151
	local leaving = false -- 152
	local createOpen = false -- 153
	local creating = false -- 154
	local createName = "" -- 155
	local dismissedCreateComposition = false -- 156
	local createError = "" -- 157
	local returnEntry = options.initialEntry -- 158
	local cardRef = reference() -- 159
	local createInputRef = reference() -- 160
	local discover = getDiscoverEntries() -- 161
	local ____local = getLocalEntries() -- 162
	if #discover == 0 then -- 162
		discoverError = zh and "资源目录暂不可用" or "Catalog is unavailable" -- 165
	end -- 165
	local initialLocation = resolveFeedLocation(____local, discover, returnEntry) -- 167
	tab = initialLocation.tab -- 168
	index = initialLocation.index -- 169
	local host = Node() -- 171
	host.tag = "mobile-feed" -- 172
	host.scaleX = App.devicePixelRatio -- 173
	host.scaleY = App.devicePixelRatio -- 174
	host:addTo(Director.systemUI) -- 175
	local function isActive() -- 177
		return active and not leaving and host.parent ~= nil -- 177
	end -- 177
	local function entries() -- 179
		return tab == "discover" and discover or ____local -- 179
	end -- 179
	local function current() -- 180
		return entries()[normalizeFeedIndex( -- 180
			index, -- 180
			#entries() -- 180
		) + 1] -- 180
	end -- 180
	local function canEditCreate() -- 181
		return createOpen and not creating and isActive() and host.visible and HttpServer.wsConnectionCount == 0 -- 181
	end -- 181
	local createInput = createTextInput({ -- 182
		fontSize = math.floor(16 * mobileFontScale), -- 183
		singleLine = true, -- 184
		background = colors.background, -- 185
		getText = function() return createName end, -- 186
		setText = function(text) -- 187
			createName = text -- 187
		end, -- 187
		getPlaceholder = function() return zh and "例如：星际花园" or "For example: Star Garden" end, -- 188
		isEnabled = canEditCreate, -- 189
		onReturn = function() -- 190
			submitCreate() -- 190
			return true -- 190
		end -- 190
	}) -- 190
	local blurCreateInput = createInput.blur -- 192
	local function closeCreate() -- 193
		if creating then -- 193
			return -- 194
		end -- 194
		blurCreateInput() -- 195
		createOpen = false -- 196
		createName = "" -- 197
		createError = "" -- 198
		render() -- 199
	end -- 193
	local function createErrorText(____error) -- 201
		repeat -- 201
			local ____switch22 = ____error -- 201
			local ____cond22 = ____switch22 == "invalid-name" -- 201
			if ____cond22 then -- 201
				return zh and "请输入不含路径分隔符的项目名称" or "Enter a project name without path separators" -- 203
			end -- 203
			____cond22 = ____cond22 or ____switch22 == "target-existed" -- 203
			if ____cond22 then -- 203
				return zh and "已有同名项目，请换一个名称" or "A project with that name already exists" -- 204
			end -- 204
			____cond22 = ____cond22 or ____switch22 == "create-folder-failed" -- 204
			if ____cond22 then -- 204
				return zh and "无法创建项目目录，请检查工作目录后重试" or "Could not create the project folder; check the workspace and retry" -- 205
			end -- 205
			____cond22 = ____cond22 or ____switch22 == "create-entry-failed" -- 205
			if ____cond22 then -- 205
				return zh and "无法写入项目入口，未完成项目已回滚" or "Could not write the project entry; the incomplete project was rolled back" -- 206
			end -- 206
			____cond22 = ____cond22 or ____switch22 == "created-project-not-found" -- 206
			if ____cond22 then -- 206
				return zh and "项目已创建，但本地列表未能找到它，请返回后重试" or "The project was created but could not be found in Local; return and retry" -- 207
			end -- 207
			do -- 207
				return zh and "创建失败，请重试" or "Project creation failed; try again" -- 208
			end -- 208
		until true -- 208
	end -- 201
	submitCreate = function() -- 211
		if not options.createProject or creating or not createOpen or not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 then -- 211
			return -- 212
		end -- 212
		if createInput.isComposing() then -- 212
			return -- 213
		end -- 213
		creating = true -- 214
		createError = "" -- 215
		blurCreateInput() -- 216
		render() -- 217
		local result = options.createProject(createName) -- 218
		if not isActive() then -- 218
			return -- 219
		end -- 219
		creating = false -- 220
		if not result.success then -- 220
			createError = createErrorText(result.error) -- 222
			render() -- 223
			return -- 224
		end -- 224
		createOpen = false -- 226
		createName = "" -- 227
		____local = getLocalEntries() -- 228
		returnEntry = result.entry -- 229
		local location = resolveFeedLocation(____local, discover, result.entry) -- 230
		tab = location.tab -- 231
		index = location.index -- 232
		render() -- 233
		onRemix(result.entry) -- 234
	end -- 211
	local function setTab(next) -- 237
		if not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 or preparing or creating then -- 237
			return -- 238
		end -- 238
		userSelectedTab = true -- 239
		returnEntry = nil -- 240
		if tab == next then -- 240
			return -- 241
		end -- 241
		if createOpen then -- 241
			blurCreateInput() -- 243
			createOpen = false -- 244
			createName = "" -- 245
			createError = "" -- 246
		end -- 246
		tab = next -- 248
		index = 0 -- 249
		detailsOpen = false -- 250
		render() -- 251
	end -- 237
	local function activate(action) -- 253
		local item = current() -- 254
		if not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 or not item or preparing then -- 254
			return -- 255
		end -- 255
		item.launchError = nil -- 256
		local function done() -- 257
			returnEntry = item -- 257
			local ____temp_6 -- 257
			if action == "play" then -- 257
				____temp_6 = onPlay(item) -- 257
			else -- 257
				____temp_6 = onRemix(item) -- 257
			end -- 257
			return ____temp_6 -- 257
		end -- 257
		if item.kind == "local" or item.installed then -- 257
			done() -- 258
			return -- 258
		end -- 258
		preparing = true -- 259
		prepareStatus = zh and "准备安装…" or "Preparing install…" -- 260
		render() -- 261
		local repairIncomplete = repairResourceId == item.id -- 262
		repairResourceId = "" -- 263
		prepare( -- 264
			item, -- 264
			repairIncomplete, -- 264
			function(progress, message) -- 264
				if not isActive() then -- 264
					return -- 265
				end -- 265
				prepareStatus = (tostring(math.floor(progress * 100)) .. "% · ") .. message -- 266
				render() -- 267
			end, -- 264
			function(success, ready, message, repairable) -- 268
				if not isActive() then -- 268
					return -- 269
				end -- 269
				preparing = false -- 270
				if not success or not ready then -- 270
					repairResourceId = repairable and item.id or "" -- 272
					prepareStatus = message or (zh and "安装失败，点击按钮重试" or "Install failed; tap to retry") -- 273
					render() -- 274
					return -- 275
				end -- 275
				item.fileName = ready.fileName -- 277
				item.workDir = ready.workDir -- 278
				item.installed = true -- 279
				prepareStatus = "" -- 280
				if HttpServer.wsConnectionCount == 0 and host.visible then -- 280
					done() -- 281
				else -- 281
					render() -- 282
				end -- 282
			end -- 268
		) -- 268
	end -- 253
	local function commit(action) -- 286
		if not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 or preparing or transitioning then -- 286
			return -- 287
		end -- 287
		if action == "play" or action == "remix" then -- 287
			local card = cardRef.current -- 289
			if card then -- 289
				card.position = Vec2.zero -- 290
			end -- 290
		end -- 290
		repeat -- 290
			local ____switch47 = action -- 290
			local ____cond47 = ____switch47 == "previous" or ____switch47 == "next" -- 290
			if ____cond47 then -- 290
				do -- 290
					returnEntry = nil -- 295
					local target = normalizeFeedIndex( -- 296
						index + (action == "next" and 1 or -1), -- 296
						#entries() -- 296
					) -- 296
					if target == index then -- 296
						local card = cardRef.current -- 298
						if card then -- 298
							card:perform(Move(App.reducedMotion and 0 or 0.16, card.position, Vec2.zero, Ease.OutQuad)) -- 299
						end -- 299
						return -- 300
					end -- 300
					local duration = App.reducedMotion and 0 or 0.18 -- 302
					local function finish() -- 303
						if not isActive() then -- 303
							return -- 304
						end -- 304
						index = target -- 305
						transitioning = false -- 306
						App:vibrate(0.012) -- 307
						detailsOpen = false -- 308
						render() -- 309
					end -- 303
					local card = cardRef.current -- 311
					if duration > 0 and card then -- 311
						transitioning = true -- 313
						card:perform(Move( -- 314
							duration, -- 314
							card.position, -- 314
							Vec2(0, (action == "next" and 1 or -1) * App.safeArea.height), -- 314
							Ease.OutQuad -- 314
						)) -- 314
						thread(function() -- 315
							sleep(duration) -- 315
							finish() -- 315
						end) -- 315
					else -- 315
						finish() -- 316
					end -- 316
					return -- 317
				end -- 317
			end -- 317
			____cond47 = ____cond47 or ____switch47 == "play" -- 317
			if ____cond47 then -- 317
				activate("play") -- 319
				return -- 319
			end -- 319
			____cond47 = ____cond47 or ____switch47 == "remix" -- 319
			if ____cond47 then -- 319
				activate("remix") -- 320
				return -- 320
			end -- 320
			do -- 320
				return -- 321
			end -- 321
		until true -- 321
	end -- 286
	local function switchMode() -- 325
		if not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 or preparing or creating or createOpen or transitioning or not options.onSwitchMode then -- 325
			return -- 326
		end -- 326
		leaving = true -- 327
		options.onSwitchMode() -- 328
	end -- 325
	host:slot("SwitchUIMode", switchMode) -- 330
	render = function() -- 331
		if not isActive() then -- 331
			return -- 332
		end -- 332
		local ____createOpen_9 = createOpen -- 334
		if ____createOpen_9 then -- 334
			local ____opt_7 = createInputRef.current -- 334
			____createOpen_9 = (____opt_7 and ____opt_7.width) == App.safeArea.width - 40 -- 334
		end -- 334
		local keptInput = ____createOpen_9 and createInputRef.current or nil -- 334
		local restoreFocus = createInput.isFocused() -- 335
		if keptInput ~= nil then -- 335
			keptInput:removeFromParent(false) -- 336
		end -- 336
		if not keptInput then -- 336
			createInput.unmount() -- 338
			createInputRef = reference() -- 339
		end -- 339
		local createPanelRef = reference() -- 341
		host:removeAllChildren() -- 342
		host.scaleX = App.devicePixelRatio -- 343
		host.scaleY = App.devicePixelRatio -- 344
		local ____App_visualSize_12 = App.visualSize -- 345
		local width = ____App_visualSize_12.width -- 345
		local height = ____App_visualSize_12.height -- 345
		local safe = App.safeArea -- 346
		local left = safe.left -- 347
		local bottom = safe.bottom -- 348
		local usableWidth = safe.width -- 349
		local usableHeight = safe.height -- 350
		local wide = usableWidth >= 760 -- 351
		local data = entries() -- 352
		index = normalizeFeedIndex(index, #data) -- 353
		local item = current() -- 354
		local coverWidth = wide and math.min(usableWidth * 0.54, 680) or usableWidth - 32 -- 355
		local coverHeight = wide and math.min(usableHeight - 118, coverWidth * 0.72) or math.min(usableHeight * 0.49, coverWidth * 0.72) -- 356
		local coverX = left + 16 -- 357
		local coverY = wide and bottom + (usableHeight - coverHeight) / 2 - 12 or bottom + usableHeight - coverHeight - 82 -- 358
		local infoX = wide and coverX + coverWidth + 28 or left + 20 -- 359
		local infoWidth = wide and usableWidth - coverWidth - 72 or usableWidth - 40 -- 360
		local infoTop = wide and bottom + usableHeight - 122 or coverY - 30 -- 361
		local buttonWidth = wide and math.min(190, (infoWidth - 12) / 2) or (infoWidth - 12) / 2 -- 362
		local fontScale = mobileFontScale -- 363
		local cardIndices = getReusableCardIndices(index, #data) -- 364
		local ____toNode_31 = toNode -- 366
		local ____React_createElement_30 = React.createElement -- 366
		local ____array_29 = __TS__SparseArrayNew( -- 366
			"node", -- 366
			{ -- 366
				tag = "mobile-feed-scene", -- 366
				x = -width / 2, -- 366
				y = -height / 2, -- 366
				width = width, -- 366
				height = height, -- 366
				anchorX = 0, -- 366
				anchorY = 0, -- 366
				touchEnabled = true, -- 366
				onTapBegan = function() -- 366
					drag = Vec2.zero -- 375
					dragAxis = "none" -- 375
					local ____opt_13 = cardRef.current -- 375
					if ____opt_13 ~= nil then -- 375
						____opt_13:stopAllActions() -- 375
					end -- 375
				end, -- 375
				onTapMoved = function(touch) -- 375
					drag = drag:add(touch.delta) -- 377
					if dragAxis == "none" and math.max( -- 377
						math.abs(drag.x), -- 378
						math.abs(drag.y) -- 378
					) >= 12 then -- 378
						dragAxis = math.abs(drag.x) > math.abs(drag.y) * 1.2 and "horizontal" or "vertical" -- 379
					end -- 379
					if cardRef.current then -- 379
						cardRef.current.position = dragAxis == "horizontal" and Vec2(drag.x * 0.18, 0) or (dragAxis == "vertical" and Vec2(0, drag.y * 0.12) or Vec2.zero) -- 382
					end -- 382
				end, -- 376
				onTapEnded = function() -- 376
					local action = resolveFeedGesture(drag.x, drag.y, usableWidth, usableHeight) -- 386
					drag = Vec2.zero -- 387
					dragAxis = "none" -- 388
					if action == "none" and cardRef.current then -- 388
						local card = cardRef.current -- 390
						card:perform(Move(App.reducedMotion and 0 or 0.16, card.position, Vec2.zero, Ease.OutQuad)) -- 391
					end -- 391
					commit(action) -- 393
				end, -- 385
				onMouseWheel = function(delta) return commit(delta.y > 0 and "previous" or "next") end -- 385
			}, -- 385
			React.createElement( -- 385
				"draw-node", -- 385
				{x = width / 2, y = height / 2}, -- 385
				React.createElement("rect-shape", {width = width, height = height, fillColor = colors.background}) -- 385
			) -- 385
		) -- 385
		local ____options_onSwitchMode_15 -- 400
		if options.onSwitchMode then -- 400
			____options_onSwitchMode_15 = React.createElement( -- 400
				"node", -- 400
				{ -- 400
					tag = "mobile-ui-mode-switch", -- 400
					x = left + 12, -- 400
					y = bottom + usableHeight - 56, -- 400
					width = 72, -- 400
					height = 44, -- 400
					anchorX = 0, -- 400
					anchorY = 0, -- 400
					touchEnabled = true, -- 400
					swallowTouches = true, -- 400
					onTapped = switchMode -- 400
				}, -- 400
				React.createElement( -- 400
					"draw-node", -- 400
					{x = 36, y = 22}, -- 400
					React.createElement("rect-shape", { -- 400
						width = 72, -- 400
						height = 44, -- 400
						fillColor = colors.panelRaised, -- 400
						borderWidth = 1, -- 400
						borderColor = colors.border -- 400
					}) -- 400
				), -- 400
				React.createElement("label", { -- 400
					x = 36, -- 400
					y = 22, -- 400
					fontName = fontName, -- 400
					fontSize = 13, -- 400
					text = zh and "传统模式" or "Classic UI", -- 400
					color3 = preparing and 7831180 or 16052712 -- 400
				}) -- 400
			) -- 400
		else -- 400
			____options_onSwitchMode_15 = nil -- 404
		end -- 404
		__TS__SparseArrayPush( -- 404
			____array_29, -- 404
			____options_onSwitchMode_15, -- 404
			React.createElement( -- 404
				"label", -- 404
				{ -- 404
					tag = "mobile-feed-discover-tab", -- 404
					x = left + usableWidth / 2 - (options.onSwitchMode and 40 or 70), -- 404
					y = bottom + usableHeight - 34, -- 404
					fontName = fontName, -- 404
					fontSize = math.floor(18 * fontScale), -- 404
					text = zh and "发现" or "Discover", -- 404
					color3 = tab == "discover" and 16763955 or 11055037, -- 404
					touchEnabled = true, -- 404
					swallowTouches = true, -- 404
					onTapped = function() return setTab("discover") end -- 404
				} -- 404
			), -- 404
			React.createElement( -- 404
				"label", -- 404
				{ -- 404
					tag = "mobile-feed-local-tab", -- 404
					x = left + usableWidth / 2 + (options.onSwitchMode and 56 or 70), -- 404
					y = bottom + usableHeight - 34, -- 404
					fontName = fontName, -- 404
					fontSize = math.floor(18 * fontScale), -- 404
					text = zh and "本地" or "Local", -- 404
					color3 = tab == "local" and 16763955 or 11055037, -- 404
					touchEnabled = true, -- 404
					swallowTouches = true, -- 404
					onTapped = function() -- 404
						____local = getLocalEntries() -- 410
						setTab("local") -- 410
					end -- 410
				} -- 410
			) -- 410
		) -- 410
		local ____temp_16 -- 411
		if tab == "local" and options.createProject then -- 411
			____temp_16 = React.createElement( -- 411
				"node", -- 411
				{ -- 411
					tag = "mobile-feed-create", -- 411
					x = left + usableWidth - 82, -- 411
					y = bottom + usableHeight - 56, -- 411
					width = 70, -- 411
					height = 44, -- 411
					anchorX = 0, -- 411
					anchorY = 0, -- 411
					touchEnabled = true, -- 411
					swallowTouches = true, -- 411
					onTapped = function() -- 411
						if preparing or transitioning or creating or createOpen or HttpServer.wsConnectionCount > 0 then -- 411
							return -- 413
						end -- 413
						createOpen = true -- 414
						createName = "" -- 415
						dismissedCreateComposition = false -- 416
						createError = "" -- 417
						render() -- 418
						createInput.deferFocus() -- 419
					end -- 412
				}, -- 412
				React.createElement( -- 412
					"draw-node", -- 412
					{x = 35, y = 22}, -- 412
					React.createElement("rect-shape", { -- 412
						width = 70, -- 412
						height = 44, -- 412
						fillColor = colors.background, -- 412
						borderWidth = 1, -- 412
						borderColor = colors.brand -- 412
					}) -- 412
				), -- 412
				React.createElement("label", { -- 412
					x = 35, -- 412
					y = 22, -- 412
					fontName = fontName, -- 412
					fontSize = 14, -- 412
					text = zh and "+ 新建" or "+ New", -- 412
					color3 = 16763955 -- 412
				}) -- 412
			) -- 412
		else -- 412
			____temp_16 = nil -- 423
		end -- 423
		__TS__SparseArrayPush(____array_29, ____temp_16) -- 423
		local ____temp_20 -- 424
		if item ~= nil then -- 424
			local ____React_createElement_19 = React.createElement -- 424
			local ____array_18 = __TS__SparseArrayNew( -- 424
				"node", -- 424
				{tag = "mobile-feed-card-" .. item.id, ref = cardRef, key = (tab .. "-") .. item.id}, -- 424
				__TS__ArrayMap( -- 425
					cardIndices, -- 425
					function(____, cardIndex) return React.createElement(Cover, { -- 425
						key = (tab .. "-") .. data[cardIndex + 1].id, -- 425
						entry = data[cardIndex + 1], -- 425
						x = coverX, -- 425
						y = coverY + (index - cardIndex) * usableHeight, -- 425
						width = coverWidth, -- 425
						height = coverHeight -- 425
					}) end -- 425
				), -- 425
				React.createElement( -- 425
					"label", -- 425
					{ -- 425
						tag = "mobile-feed-current-title", -- 425
						x = infoX, -- 425
						y = infoTop, -- 425
						anchorX = 0, -- 425
						anchorY = 0.5, -- 425
						fontName = fontName, -- 425
						fontSize = math.floor((wide and 30 or 25) * fontScale), -- 425
						text = item.title, -- 425
						textWidth = infoWidth, -- 425
						alignment = "Left", -- 425
						color3 = 16052712 -- 425
					} -- 425
				), -- 425
				React.createElement( -- 425
					"label", -- 425
					{ -- 425
						x = infoX, -- 425
						y = infoTop - 58, -- 425
						anchorX = 0, -- 425
						anchorY = 0.5, -- 425
						fontName = fontName, -- 425
						fontSize = math.floor(15 * fontScale), -- 425
						text = item.description, -- 425
						textWidth = infoWidth, -- 425
						alignment = "Left", -- 425
						color3 = 11055037 -- 425
					} -- 425
				), -- 425
				React.createElement( -- 425
					Button, -- 437
					{ -- 437
						tag = "mobile-feed-remix", -- 437
						x = infoX, -- 437
						y = bottom + 24, -- 437
						width = buttonWidth, -- 437
						text = zh and "Remix" or "Remix", -- 437
						fontSize = math.floor(17 * fontScale), -- 437
						primary = true, -- 437
						onTapped = function() return activate("remix") end -- 437
					} -- 437
				), -- 437
				React.createElement( -- 437
					Button, -- 439
					{ -- 439
						tag = "mobile-feed-play", -- 439
						x = infoX + buttonWidth + 12, -- 439
						y = bottom + 24, -- 439
						width = buttonWidth, -- 439
						text = zh and "试玩" or "Play", -- 439
						fontSize = math.floor(17 * fontScale), -- 439
						onTapped = function() return activate("play") end -- 439
					} -- 439
				), -- 439
				React.createElement( -- 439
					"label", -- 439
					{ -- 439
						x = infoX, -- 439
						y = bottom + 92, -- 439
						anchorX = 0, -- 439
						anchorY = 0.5, -- 439
						fontName = fontName, -- 439
						fontSize = 14, -- 439
						text = prepareStatus ~= "" and prepareStatus or (item.launchError ~= nil and item.launchError or (((tostring(index + 1) .. " / ") .. tostring(#data)) .. "  ·  ") .. (zh and "上滑下一项 · 右滑 Remix · 左滑试玩" or "Swipe up next · right Remix · left Play")), -- 439
						textWidth = infoWidth, -- 439
						alignment = "Left", -- 439
						color3 = item.launchError ~= nil and 16739179 or 11055037 -- 439
					} -- 439
				), -- 439
				React.createElement( -- 439
					"label", -- 439
					{ -- 439
						x = infoX + infoWidth, -- 439
						y = infoTop, -- 439
						anchorX = 1, -- 439
						anchorY = 0.5, -- 439
						fontName = fontName, -- 439
						fontSize = 14, -- 439
						text = zh and "详情" or "Details", -- 439
						color3 = 16763955, -- 439
						touchEnabled = true, -- 439
						swallowTouches = true, -- 439
						onTapped = function() -- 439
							detailsOpen = not detailsOpen -- 446
							render() -- 446
						end -- 446
					} -- 446
				) -- 446
			) -- 446
			local ____detailsOpen_17 -- 447
			if detailsOpen then -- 447
				____detailsOpen_17 = React.createElement( -- 447
					"node", -- 447
					{ -- 447
						x = left + 12, -- 447
						y = bottom + 10, -- 447
						width = usableWidth - 24, -- 447
						height = math.min(usableHeight * 0.48, 360), -- 447
						anchorX = 0, -- 447
						anchorY = 0, -- 447
						touchEnabled = true, -- 447
						swallowTouches = true -- 447
					}, -- 447
					React.createElement( -- 447
						"draw-node", -- 447
						{ -- 447
							x = (usableWidth - 24) / 2, -- 447
							y = math.min(usableHeight * 0.48, 360) / 2 -- 447
						}, -- 447
						React.createElement( -- 447
							"rect-shape", -- 447
							{ -- 447
								width = usableWidth - 24, -- 447
								height = math.min(usableHeight * 0.48, 360), -- 447
								fillColor = colors.panelRaised, -- 447
								borderWidth = 1, -- 447
								borderColor = colors.border -- 447
							} -- 447
						) -- 447
					), -- 447
					React.createElement( -- 447
						"label", -- 447
						{ -- 447
							x = 20, -- 447
							y = math.min(usableHeight * 0.48, 360) - 36, -- 447
							anchorX = 0, -- 447
							anchorY = 0.5, -- 447
							fontName = fontName, -- 447
							fontSize = 18, -- 447
							text = item.title, -- 447
							textWidth = usableWidth - 64, -- 447
							alignment = "Left", -- 447
							color3 = 16052712 -- 447
						} -- 447
					), -- 447
					React.createElement( -- 447
						"label", -- 447
						{ -- 447
							x = 20, -- 447
							y = math.min(usableHeight * 0.48, 360) - 88, -- 447
							anchorX = 0, -- 447
							anchorY = 0.5, -- 447
							fontName = fontName, -- 447
							fontSize = 15, -- 447
							text = item.description, -- 447
							textWidth = usableWidth - 64, -- 447
							alignment = "Left", -- 447
							color3 = 11055037 -- 447
						} -- 447
					) -- 447
				) -- 447
			else -- 447
				____detailsOpen_17 = nil -- 456
			end -- 456
			__TS__SparseArrayPush(____array_18, ____detailsOpen_17) -- 456
			____temp_20 = ____React_createElement_19(__TS__SparseArraySpread(____array_18)) -- 456
		else -- 456
			____temp_20 = React.createElement( -- 456
				"node", -- 456
				nil, -- 456
				React.createElement("label", { -- 456
					x = left + usableWidth / 2, -- 456
					y = bottom + usableHeight / 2 + 20, -- 456
					fontName = fontName, -- 456
					fontSize = 22, -- 456
					text = tab == "discover" and (zh and "暂无移动作品" or "No mobile games yet") or (zh and "没有可运行的本地作品" or "No runnable local games"), -- 456
					color3 = 16052712 -- 456
				}), -- 456
				React.createElement("label", { -- 456
					x = left + usableWidth / 2, -- 456
					y = bottom + usableHeight / 2 - 28, -- 456
					fontName = fontName, -- 456
					fontSize = 14, -- 456
					text = tab == "discover" and discoverError ~= "" and discoverError or (zh and "切换标签或稍后重试" or "Switch tabs or retry later"), -- 456
					textWidth = usableWidth - 48, -- 456
					color3 = tab == "discover" and discoverError ~= "" and 16739179 or 11055037 -- 456
				}) -- 456
			) -- 456
		end -- 456
		__TS__SparseArrayPush(____array_29, ____temp_20) -- 456
		local ____createOpen_28 -- 465
		if createOpen then -- 465
			____createOpen_28 = (function() -- 465
				local sheetHeight = math.min(createSheetHeight, usableHeight - 64) -- 466
				local sheetWidth = usableWidth -- 467
				local inputWidth = sheetWidth - 40 -- 468
				local actionGap = 12 -- 469
				local cancelWidth = math.floor((inputWidth - actionGap) * 0.38) -- 470
				local ____React_createElement_27 = React.createElement -- 470
				local ____array_26 = __TS__SparseArrayNew( -- 470
					"node", -- 470
					{ -- 470
						tag = "mobile-project-create-sheet", -- 470
						width = width, -- 470
						height = height, -- 470
						anchorX = 0, -- 470
						anchorY = 0, -- 470
						touchEnabled = true, -- 470
						swallowTouches = true -- 470
					}, -- 470
					React.createElement( -- 470
						"node", -- 470
						{ -- 470
							tag = "mobile-project-create-focus-observer", -- 470
							order = 1000, -- 470
							width = width, -- 470
							height = height, -- 470
							anchorX = 0, -- 470
							anchorY = 0, -- 470
							touchEnabled = true, -- 470
							swallowTouches = false, -- 470
							swallowMouseWheel = false, -- 470
							onTapFilter = function(touch) -- 470
								touch.enabled = false -- 474
								if not canEditCreate() then -- 474
									return -- 475
								end -- 475
								local input = createInputRef.current -- 476
								local point = input and input:convertToNodeSpace(touch.worldLocation) -- 477
								local inside = input and point and point.x >= 0 and point.y >= 0 and point.x <= input.width and point.y <= input.height -- 478
								dismissedCreateComposition = not inside and createInput.isComposing() -- 479
								if not inside then -- 479
									blurCreateInput() -- 480
								end -- 480
							end -- 473
						} -- 473
					), -- 473
					React.createElement( -- 473
						"draw-node", -- 473
						{x = width / 2, y = height / 2}, -- 473
						React.createElement("rect-shape", {width = width, height = height, fillColor = 2348810240}) -- 473
					) -- 473
				) -- 473
				local ____React_createElement_25 = React.createElement -- 473
				local ____array_24 = __TS__SparseArrayNew( -- 473
					"node", -- 473
					{ -- 473
						ref = createPanelRef, -- 473
						x = left, -- 473
						y = bottom, -- 473
						width = sheetWidth, -- 473
						height = sheetHeight, -- 473
						anchorX = 0, -- 473
						anchorY = 0, -- 473
						touchEnabled = true, -- 473
						swallowTouches = true -- 473
					}, -- 473
					React.createElement( -- 473
						"draw-node", -- 473
						{x = sheetWidth / 2, y = sheetHeight / 2}, -- 473
						React.createElement("rect-shape", { -- 473
							width = sheetWidth, -- 473
							height = sheetHeight, -- 473
							fillColor = colors.panel, -- 473
							borderWidth = 1, -- 473
							borderColor = colors.border -- 473
						}) -- 473
					), -- 473
					React.createElement("label", { -- 473
						x = 20, -- 473
						y = sheetHeight - 24, -- 473
						anchorX = 0, -- 473
						anchorY = 1, -- 473
						fontName = fontName, -- 473
						fontSize = 22, -- 473
						text = zh and "新建项目" or "New project", -- 473
						color3 = 16052712 -- 473
					}), -- 473
					React.createElement("label", { -- 473
						x = 20, -- 473
						y = sheetHeight - 66, -- 473
						anchorX = 0, -- 473
						anchorY = 1, -- 473
						fontName = fontName, -- 473
						fontSize = 14, -- 473
						text = zh and "项目名称" or "Project name", -- 473
						color3 = 11055037 -- 473
					}) -- 473
				) -- 473
				local ____keptInput_23 -- 487
				if keptInput then -- 487
					____keptInput_23 = nil -- 487
				else -- 487
					____keptInput_23 = React.createElement("node", { -- 487
						tag = "mobile-project-create-input", -- 487
						ref = createInputRef, -- 487
						x = 20, -- 487
						y = sheetHeight - createInputTop - createInputHeight, -- 487
						width = inputWidth, -- 487
						height = createInputHeight, -- 487
						anchorX = 0, -- 487
						anchorY = 0, -- 487
						onMount = createInput.mount -- 487
					}) -- 487
				end -- 487
				__TS__SparseArrayPush( -- 487
					____array_24, -- 487
					____keptInput_23, -- 487
					React.createElement("label", { -- 487
						tag = "mobile-project-create-error", -- 487
						x = 20, -- 487
						y = sheetHeight - createInputTop - createInputHeight - 12, -- 487
						anchorX = 0, -- 487
						anchorY = 1, -- 487
						fontName = fontName, -- 487
						fontSize = 12, -- 487
						text = createError ~= "" and createError or (zh and "将创建可运行的 TypeScript 起始项目" or "Creates a runnable TypeScript starter project"), -- 487
						textWidth = inputWidth, -- 487
						alignment = "Left", -- 487
						color3 = createError ~= "" and 16739179 or 11055037 -- 487
					}), -- 487
					React.createElement(Button, { -- 487
						tag = "mobile-project-create-cancel", -- 487
						x = 20, -- 487
						y = 20, -- 487
						width = cancelWidth, -- 487
						text = zh and "取消" or "Cancel", -- 487
						onTapped = closeCreate -- 487
					}), -- 487
					React.createElement( -- 487
						Button, -- 493
						{ -- 493
							tag = "mobile-project-create-submit", -- 493
							x = 20 + cancelWidth + actionGap, -- 493
							y = 20, -- 493
							width = inputWidth - cancelWidth - actionGap, -- 493
							text = creating and (zh and "创建中…" or "Creating…") or (zh and "创建并进入 Remix" or "Create and Remix"), -- 493
							primary = true, -- 493
							onTapped = function() -- 493
								if not dismissedCreateComposition then -- 493
									submitCreate() -- 494
								end -- 494
								dismissedCreateComposition = false -- 494
							end -- 494
						} -- 494
					) -- 494
				) -- 494
				__TS__SparseArrayPush( -- 494
					____array_26, -- 494
					____React_createElement_25(__TS__SparseArraySpread(____array_24)) -- 494
				) -- 494
				return ____React_createElement_27(__TS__SparseArraySpread(____array_26)) -- 471
			end)() -- 465
		else -- 465
			____createOpen_28 = nil -- 497
		end -- 497
		__TS__SparseArrayPush(____array_29, ____createOpen_28) -- 497
		local scene = ____toNode_31(____React_createElement_30(__TS__SparseArraySpread(____array_29))) -- 366
		if scene ~= nil then -- 366
			host:addChild(scene) -- 499
		end -- 499
		if keptInput and createPanelRef.current then -- 499
			keptInput.position = Vec2( -- 501
				20, -- 501
				math.min(createSheetHeight, usableHeight - 64) - createInputTop - createInputHeight -- 501
			) -- 501
			createPanelRef.current:addChild(keptInput) -- 502
		end -- 502
		createInput.refresh() -- 504
		if restoreFocus and not keptInput and createOpen then -- 504
			createInput.focus(false) -- 505
		end -- 505
	end -- 331
	host:onAppChange(function(setting) -- 508
		if setting == "Size" or setting == "Locale" then -- 508
			render() -- 509
		end -- 509
	end) -- 508
	host:onAppEvent(function(event) -- 511
		if event == "BackButton" then -- 511
			if createOpen and not creating then -- 511
				closeCreate() -- 513
			elseif detailsOpen then -- 513
				detailsOpen = false -- 515
				render() -- 516
			end -- 516
		elseif event == "WillEnterBackground" or event == "DidEnterBackground" then -- 516
			blurCreateInput() -- 518
		end -- 518
	end) -- 511
	host:onCleanup(function() -- 520
		blurCreateInput() -- 520
		active = false -- 520
	end) -- 520
	host:slot( -- 521
		"RestoreFeedEntry", -- 521
		function(entry) -- 521
			if not isActive() or HttpServer.wsConnectionCount > 0 then -- 521
				return -- 522
			end -- 522
			returnEntry = entry -- 523
			____local = getLocalEntries() -- 524
			discover = getDiscoverEntries() -- 525
			local location = resolveFeedLocation(____local, discover, entry) -- 526
			tab = location.tab -- 527
			index = location.index -- 528
			detailsOpen = false -- 529
			render() -- 530
		end -- 521
	) -- 521
	host:slot("SuspendLocalUI", blurCreateInput) -- 532
	host:slot( -- 533
		"ResumeLocalUI", -- 533
		function() -- 533
			leaving = false -- 533
			render() -- 533
		end -- 533
	) -- 533
	render() -- 534
	if syncDiscover then -- 534
		if #discover == 0 then -- 534
			discoverError = zh and "正在同步资源目录…" or "Syncing Catalog…" -- 537
			render() -- 538
		end -- 538
		syncDiscover( -- 540
			function(message) -- 540
				if not isActive() or #discover > 0 then -- 540
					return -- 541
				end -- 541
				discoverError = message -- 542
				render() -- 543
			end, -- 540
			function(success, message) -- 544
				if not isActive() then -- 544
					return -- 545
				end -- 545
				local selected = returnEntry or current() -- 546
				local previousCount = #discover -- 547
				discover = getDiscoverEntries() -- 548
				discoverError = success and (#discover == 0 and (zh and "目录中暂无可运行作品" or "No runnable Catalog games") or "") or (message or (zh and "资源目录同步失败" or "Catalog sync failed")) -- 549
				tab = resolveDiscoverRefreshTab( -- 552
					tab, -- 552
					userSelectedTab, -- 552
					previousCount, -- 552
					#discover, -- 552
					#____local -- 552
				) -- 552
				if selected ~= nil then -- 552
					local location = resolveFeedLocation(____local, discover, selected) -- 554
					tab = location.tab -- 555
					index = location.index -- 556
				end -- 556
				if tab == "discover" then -- 556
					index = normalizeFeedIndex(index, #discover) -- 558
				end -- 558
				render() -- 559
			end -- 544
		) -- 544
	end -- 544
	return host -- 562
end -- 132
return ____exports -- 132