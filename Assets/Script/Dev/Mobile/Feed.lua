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
local ____Visual = require("Dev.Mobile.Visual") -- 7
local RoundedStencil = ____Visual.RoundedStencil -- 7
local RoundedSurface = ____Visual.RoundedSurface -- 7
local VerticalGradient = ____Visual.VerticalGradient -- 7
local colors = { -- 27
	background = 4278914322, -- 28
	panel = 4279572770, -- 29
	panelRaised = 4280297010, -- 30
	text = 4294242792, -- 31
	muted = 4289245117, -- 32
	brand = 4294954035, -- 33
	border = 4281613128, -- 34
	danger = 4294929259 -- 35
} -- 35
local fontName = "sarasa-mono-sc-regular" -- 38
local createSheetHeight = 260 -- 39
local createInputHeight = 44 -- 40
local createInputTop = 96 -- 41
local function conciseDescription(text, limit) -- 43
	local length = (utf8.len(text)) or 0 -- 44
	if length <= limit then -- 44
		return text -- 45
	end -- 45
	local stop = utf8.offset(text, limit + 1) or #text + 1 -- 46
	return string.sub(text, 1, stop - 1) .. "…" -- 47
end -- 43
local function Button(props) -- 50
	return React.createElement( -- 61
		"node", -- 61
		{ -- 61
			tag = props.tag, -- 61
			x = props.x, -- 61
			y = props.y, -- 61
			anchorX = 0, -- 61
			anchorY = 0, -- 61
			width = props.width, -- 61
			height = 48, -- 61
			renderOrder = props.renderOrder, -- 61
			touchEnabled = true, -- 61
			swallowTouches = true, -- 61
			onTapped = props.onTapped -- 61
		}, -- 61
		React.createElement(RoundedSurface, { -- 61
			width = props.width, -- 61
			height = 48, -- 61
			radius = 14, -- 61
			renderOrder = props.renderOrder, -- 61
			topColor = props.primary and 4294958955 or 4280889664, -- 61
			bottomColor = props.primary and 4294950190 or 4279967787, -- 61
			borderWidth = 1, -- 61
			borderColor = props.primary and 4294958435 or colors.border, -- 61
			shadow = props.primary -- 61
		}), -- 61
		React.createElement("label", { -- 61
			x = props.width / 2, -- 61
			y = 24, -- 61
			fontName = fontName, -- 61
			fontSize = props.fontSize or 17, -- 61
			text = props.text, -- 61
			color3 = props.primary and 1512202 or 16052712 -- 61
		}) -- 61
	) -- 61
end -- 50
local function Cover(props) -- 89
	local file = props.entry.bannerFile -- 90
	local function scaleSprite(sprite, mode) -- 91
		local scales = getCoverScales(sprite.width, sprite.height, props.width, props.height) -- 92
		sprite.scaleX = scales[mode] -- 93
		sprite.scaleY = scales[mode] -- 94
	end -- 91
	local ____React_createElement_5 = React.createElement -- 91
	local ____temp_3 = { -- 91
		x = props.x, -- 91
		y = props.y, -- 91
		width = props.width, -- 91
		height = props.height, -- 91
		anchorX = 0, -- 91
		anchorY = 0 -- 91
	} -- 91
	local ____React_createElement_result_4 = React.createElement( -- 91
		RoundedSurface, -- 97
		{ -- 97
			width = props.width, -- 97
			height = props.height, -- 97
			radius = 22, -- 97
			topColor = stableCoverColor(props.entry.id), -- 97
			bottomColor = 4279310115, -- 97
			shadow = true -- 97
		} -- 97
	) -- 97
	local ____file_0 -- 99
	if file then -- 99
		____file_0 = React.createElement( -- 99
			"clip-node", -- 99
			{ -- 99
				width = props.width, -- 99
				height = props.height, -- 99
				anchorX = 0, -- 99
				anchorY = 0, -- 99
				stencil = React.createElement(RoundedStencil, {width = props.width, height = props.height, radius = 22}) -- 99
			}, -- 99
			React.createElement( -- 99
				"sprite", -- 99
				{ -- 99
					file = file, -- 99
					x = props.width / 2 - 5, -- 99
					y = props.height / 2, -- 99
					opacity = 0.08, -- 99
					onMount = function(sprite) return scaleSprite(sprite, "cover") end -- 99
				} -- 99
			), -- 99
			React.createElement( -- 99
				"sprite", -- 99
				{ -- 99
					file = file, -- 99
					x = props.width / 2 + 5, -- 99
					y = props.height / 2, -- 99
					opacity = 0.08, -- 99
					onMount = function(sprite) return scaleSprite(sprite, "cover") end -- 99
				} -- 99
			), -- 99
			React.createElement( -- 99
				"sprite", -- 99
				{ -- 99
					file = file, -- 99
					x = props.width / 2, -- 99
					y = props.height / 2 - 5, -- 99
					opacity = 0.08, -- 99
					onMount = function(sprite) return scaleSprite(sprite, "cover") end -- 99
				} -- 99
			), -- 99
			React.createElement( -- 99
				"draw-node", -- 99
				{x = props.width / 2, y = props.height / 2}, -- 99
				React.createElement("rect-shape", {width = props.width, height = props.height, fillColor = 2953514258}) -- 99
			), -- 99
			React.createElement( -- 99
				"sprite", -- 99
				{ -- 99
					file = file, -- 99
					x = props.width / 2, -- 99
					y = props.height / 2, -- 99
					onMount = function(sprite) return scaleSprite(sprite, "contain") end -- 99
				} -- 99
			) -- 99
		) -- 99
	else -- 99
		____file_0 = React.createElement( -- 99
			"label", -- 99
			{ -- 99
				x = props.width / 2, -- 99
				y = props.height / 2 + 10, -- 99
				fontName = fontName, -- 99
				fontSize = math.floor(math.max( -- 99
					22, -- 111
					math.min(34, props.width / 12) -- 111
				)), -- 111
				text = props.entry.title, -- 111
				textWidth = props.width - 40, -- 111
				color3 = 16052712 -- 111
			} -- 111
		) -- 111
	end -- 111
	local ____file_1 -- 116
	if file then -- 116
		____file_1 = nil -- 116
	else -- 116
		____file_1 = React.createElement("label", { -- 116
			x = props.width / 2, -- 116
			y = 30, -- 116
			fontName = fontName, -- 116
			fontSize = 14, -- 116
			text = "DORA SSR · REMIXABLE", -- 116
			color3 = 16763955 -- 116
		}) -- 116
	end -- 116
	local ____file_2 -- 124
	if file then -- 124
		____file_2 = nil -- 124
	else -- 124
		____file_2 = React.createElement(DoraMascot, {state = "idle", x = props.width - 46, y = 64, size = 42}) -- 124
	end -- 124
	return ____React_createElement_5( -- 96
		"node", -- 96
		____temp_3, -- 96
		____React_createElement_result_4, -- 96
		____file_0, -- 96
		____file_1, -- 96
		____file_2, -- 96
		React.createElement(RoundedSurface, { -- 96
			width = props.width, -- 96
			height = props.height, -- 96
			radius = 22, -- 96
			fillColor = 0, -- 96
			borderWidth = 1, -- 96
			borderColor = 4282074454 -- 96
		}) -- 96
	) -- 96
end -- 89
function ____exports.startMobileFeed(options) -- 129
	local submitCreate, render -- 129
	local getLocalEntries = options.getLocalEntries -- 130
	local getDiscoverEntries = options.getDiscoverEntries -- 131
	local onPlay = options.onPlay -- 132
	local onRemix = options.onRemix -- 133
	local prepare = options.prepare -- 134
	local syncDiscover = options.syncDiscover -- 135
	local zh = (string.match(App.locale, "^zh")) ~= nil -- 136
	local tab = "local" -- 137
	local index = 0 -- 138
	local drag = Vec2.zero -- 139
	local dragAxis = "none" -- 140
	local discoverError = "" -- 141
	local preparing = false -- 142
	local transitioning = false -- 143
	local prepareStatus = "" -- 144
	local repairResourceId = "" -- 145
	local userSelectedTab = false -- 146
	local active = true -- 147
	local leaving = false -- 148
	local createOpen = false -- 149
	local creating = false -- 150
	local createName = "" -- 151
	local dismissedCreateComposition = false -- 152
	local createError = "" -- 153
	local returnEntry = options.initialEntry -- 154
	local rememberedEntries = {
		["local"] = options.initialEntries and options.initialEntries["local"],
		["discover"] = options.initialEntries and options.initialEntries["discover"]
	}
	local cardRef = reference() -- 155
	local indexRef = reference() -- 156
	local createInputRef = reference() -- 157
	local discover = getDiscoverEntries() -- 158
	local ____local = getLocalEntries() -- 159
	if #discover == 0 then -- 159
		discoverError = zh and "资源目录暂不可用" or "Catalog is unavailable" -- 162
	end -- 162
	local initialLocation = resolveFeedLocation(____local, discover, returnEntry) -- 164
	tab = initialLocation.tab -- 165
	index = initialLocation.index -- 166
	local host = Node() -- 168
	host.tag = "mobile-feed" -- 169
	host.scaleX = App.devicePixelRatio -- 170
	host.scaleY = App.devicePixelRatio -- 171
	host:addTo(Director.systemUI) -- 172
	local function isActive() -- 174
		return active and not leaving and host.parent ~= nil -- 174
	end -- 174
	local function entries() -- 176
		return tab == "discover" and discover or ____local -- 176
	end -- 176
	local function current() -- 177
		return entries()[normalizeFeedIndex( -- 177
			index, -- 177
			#entries() -- 177
		) + 1] -- 177
	end -- 177
	local rememberedEntryKey = ""
	local function rememberCurrent()
		local item = current()
		if not item or not options.onCurrentEntryChanged then
			return
		end
		local key = (((((item.kind .. "\n") .. item.id) .. "\n") .. (item.workDir or "")) .. "\n") .. (item.fileName or "")
		if key == rememberedEntryKey then
			return
		end
		rememberedEntryKey = key
		rememberedEntries[item.kind] = item
		options.onCurrentEntryChanged(item)
	end
	local function canEditCreate() -- 178
		return createOpen and not creating and isActive() and host.visible and HttpServer.wsConnectionCount == 0 -- 178
	end -- 178
	local createInput = createTextInput({ -- 179
		fontSize = math.floor(16 * mobileFontScale), -- 180
		singleLine = true, -- 181
		background = colors.background, -- 182
		getText = function() return createName end, -- 183
		setText = function(text) -- 184
			createName = text -- 184
		end, -- 184
		getPlaceholder = function() return zh and "例如：星际花园" or "For example: Star Garden" end, -- 185
		isEnabled = canEditCreate, -- 186
		onReturn = function() -- 187
			submitCreate() -- 187
			return true -- 187
		end -- 187
	}) -- 187
	local blurCreateInput = createInput.blur -- 189
	local function closeCreate() -- 190
		if creating then -- 190
			return -- 191
		end -- 191
		blurCreateInput() -- 192
		createOpen = false -- 193
		createName = "" -- 194
		createError = "" -- 195
		render() -- 196
	end -- 190
	local function createErrorText(____error) -- 198
		repeat -- 198
			local ____switch24 = ____error -- 198
			local ____cond24 = ____switch24 == "invalid-name" -- 198
			if ____cond24 then -- 198
				return zh and "请输入不含路径分隔符的项目名称" or "Enter a project name without path separators" -- 200
			end -- 200
			____cond24 = ____cond24 or ____switch24 == "target-existed" -- 200
			if ____cond24 then -- 200
				return zh and "已有同名项目，请换一个名称" or "A project with that name already exists" -- 201
			end -- 201
			____cond24 = ____cond24 or ____switch24 == "create-folder-failed" -- 201
			if ____cond24 then -- 201
				return zh and "无法创建项目目录，请检查工作目录后重试" or "Could not create the project folder; check the workspace and retry" -- 202
			end -- 202
			____cond24 = ____cond24 or ____switch24 == "create-entry-failed" -- 202
			if ____cond24 then -- 202
				return zh and "无法写入项目入口，未完成项目已回滚" or "Could not write the project entry; the incomplete project was rolled back" -- 203
			end -- 203
			____cond24 = ____cond24 or ____switch24 == "created-project-not-found" -- 203
			if ____cond24 then -- 203
				return zh and "项目已创建，但本地列表未能找到它，请返回后重试" or "The project was created but could not be found in Local; return and retry" -- 204
			end -- 204
			do -- 204
				return zh and "创建失败，请重试" or "Project creation failed; try again" -- 205
			end -- 205
		until true -- 205
	end -- 198
	submitCreate = function() -- 208
		if not options.createProject or creating or not createOpen or not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 then -- 208
			return -- 209
		end -- 209
		if createInput.isComposing() then -- 209
			return -- 210
		end -- 210
		creating = true -- 211
		createError = "" -- 212
		blurCreateInput() -- 213
		render() -- 214
		local result = options.createProject(createName) -- 215
		if not isActive() then -- 215
			return -- 216
		end -- 216
		creating = false -- 217
		if not result.success then -- 217
			createError = createErrorText(result.error) -- 219
			render() -- 220
			return -- 221
		end -- 221
		createOpen = false -- 223
		createName = "" -- 224
		____local = getLocalEntries() -- 225
		returnEntry = result.entry -- 226
		local location = resolveFeedLocation(____local, discover, result.entry) -- 227
		tab = location.tab -- 228
		index = location.index -- 229
		render() -- 230
		onRemix(result.entry) -- 231
	end -- 208
	local function setTab(next) -- 234
		if not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 or preparing or creating then -- 234
			return -- 235
		end -- 235
		userSelectedTab = true -- 236
		returnEntry = nil -- 237
		if tab == next then -- 237
			return -- 238
		end -- 238
		if createOpen then -- 238
			blurCreateInput() -- 240
			createOpen = false -- 241
			createName = "" -- 242
			createError = "" -- 243
		end -- 243
		tab = next -- 245
		local target = rememberedEntries[next]
		local location = target and resolveFeedLocation(____local, discover, target)
		index = location and location.tab == next and location.index or 0 -- 246
		render() -- 247
	end -- 234
	local function activate(action) -- 249
		local item = current() -- 250
		if not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 or not item or preparing then -- 250
			return -- 251
		end -- 251
		item.launchError = nil -- 252
		local function done() -- 253
			returnEntry = item -- 253
			local ____temp_6 -- 253
			if action == "play" then -- 253
				____temp_6 = onPlay(item) -- 253
			else -- 253
				____temp_6 = onRemix(item) -- 253
			end -- 253
			return ____temp_6 -- 253
		end -- 253
		if item.kind == "local" or item.installed then -- 253
			done() -- 254
			return -- 254
		end -- 254
		preparing = true -- 255
		prepareStatus = zh and "准备安装…" or "Preparing install…" -- 256
		render() -- 257
		local repairIncomplete = repairResourceId == item.id -- 258
		repairResourceId = "" -- 259
		prepare( -- 260
			item, -- 260
			repairIncomplete, -- 260
			function(progress, message) -- 260
				if not isActive() then -- 260
					return -- 261
				end -- 261
				prepareStatus = (tostring(math.floor(progress * 100)) .. "% · ") .. message -- 262
				render() -- 263
			end, -- 260
			function(success, ready, message, repairable) -- 264
				if not isActive() then -- 264
					return -- 265
				end -- 265
				preparing = false -- 266
				if not success or not ready then -- 266
					repairResourceId = repairable and item.id or "" -- 268
					prepareStatus = message or (zh and "安装失败，点击按钮重试" or "Install failed; tap to retry") -- 269
					render() -- 270
					return -- 271
				end -- 271
				item.fileName = ready.fileName -- 273
				item.workDir = ready.workDir -- 274
				item.installed = true -- 275
				prepareStatus = "" -- 276
				if HttpServer.wsConnectionCount == 0 and host.visible then -- 276
					done() -- 277
				else -- 277
					render() -- 278
				end -- 278
			end -- 264
		) -- 264
	end -- 249
	local function commit(action) -- 282
		if not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 or preparing or transitioning then -- 282
			return -- 283
		end -- 283
		if action == "play" or action == "remix" then -- 283
			local card = cardRef.current -- 285
			if card then -- 285
				card.position = Vec2.zero -- 286
			end -- 286
		end -- 286
		repeat -- 286
			local ____switch49 = action -- 286
			local ____cond49 = ____switch49 == "previous" or ____switch49 == "next" -- 286
			if ____cond49 then -- 286
				do -- 286
					returnEntry = nil -- 291
					local target = normalizeFeedIndex( -- 292
						index + (action == "next" and 1 or -1), -- 292
						#entries() -- 292
					) -- 292
					if target == index then -- 292
						local card = cardRef.current -- 294
						if card then -- 294
							card:perform(Move(App.reducedMotion and 0 or 0.16, card.position, Vec2.zero, Ease.OutQuad)) -- 295
						end -- 295
						return -- 296
					end -- 296
					local duration = App.reducedMotion and 0 or 0.18 -- 298
					local function finish() -- 299
						if not isActive() then -- 299
							return -- 300
						end -- 300
						index = target -- 301
						transitioning = false -- 302
						App:vibrate(0.012) -- 303
						render() -- 304
					end -- 299
					local card = cardRef.current -- 306
					if duration > 0 and card then -- 306
						transitioning = true -- 308
						card:perform(Move( -- 309
							duration, -- 309
							card.position, -- 309
							Vec2(0, (action == "next" and 1 or -1) * App.safeArea.height), -- 309
							Ease.OutQuad -- 309
						)) -- 309
						thread(function() -- 310
							sleep(duration) -- 310
							finish() -- 310
						end) -- 310
					else -- 310
						finish() -- 311
					end -- 311
					return -- 312
				end -- 312
			end -- 312
			____cond49 = ____cond49 or ____switch49 == "play" -- 312
			if ____cond49 then -- 312
				activate("play") -- 314
				return -- 314
			end -- 314
			____cond49 = ____cond49 or ____switch49 == "remix" -- 314
			if ____cond49 then -- 314
				activate("remix") -- 315
				return -- 315
			end -- 315
			do -- 315
				return -- 316
			end -- 316
		until true -- 316
	end -- 282
	local function switchMode() -- 320
		if not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 or preparing or creating or createOpen or transitioning or not options.onSwitchMode then -- 320
			return -- 321
		end -- 321
		leaving = true -- 322
		options.onSwitchMode() -- 323
	end -- 320
	host:slot("SwitchUIMode", switchMode) -- 325
	render = function() -- 326
		if not isActive() then -- 326
			return -- 327
		end -- 327
		local safeContentWidth = App.safeArea.width - 40 -- 329
		local shortLandscapeInputWidth = safeContentWidth - 12 - math.min(300, math.floor(safeContentWidth * 0.42)) -- 330
		local expectedInputWidth = App.safeArea.width >= 760 and App.safeArea.height < 500 and shortLandscapeInputWidth or safeContentWidth -- 331
		local ____createOpen_9 = createOpen -- 332
		if ____createOpen_9 then -- 329
			local ____opt_7 = createInputRef.current -- 329
			____createOpen_9 = (____opt_7 and ____opt_7.width) == expectedInputWidth -- 332
		end -- 329
		local keptInput = ____createOpen_9 and createInputRef.current or nil -- 329
		local restoreFocus = createInput.isFocused() -- 330
		if keptInput ~= nil then -- 330
			keptInput:removeFromParent(false) -- 331
		end -- 331
		if not keptInput then -- 331
			createInput.unmount() -- 333
			createInputRef = reference() -- 334
		end -- 334
		local createPanelRef = reference() -- 336
		host:removeAllChildren() -- 337
		host.scaleX = App.devicePixelRatio -- 338
		host.scaleY = App.devicePixelRatio -- 339
		local ____App_visualSize_12 = App.visualSize -- 340
		local width = ____App_visualSize_12.width -- 340
		local height = ____App_visualSize_12.height -- 340
		local safe = App.safeArea -- 341
		local left = safe.left -- 342
		local bottom = safe.bottom -- 343
		local usableWidth = safe.width -- 344
		local usableHeight = safe.height -- 345
		local wide = usableWidth >= 760 -- 346
		local shortLandscape = wide and usableHeight < 500 -- 347
		local compact = not wide and usableHeight < 700 -- 347
		local landscapeTopLift = shortLandscape and 28 or 0 -- 348
		local data = entries() -- 348
		index = normalizeFeedIndex(index, #data) -- 349
		local item = current() -- 350
		rememberCurrent()
		local coverWidth = wide and math.min(usableWidth * 0.54, 680) or usableWidth - 32 -- 351
		local coverHeight = wide and math.min(usableHeight - 118, coverWidth * 0.72) or (compact and math.min(usableHeight * 0.49, coverWidth * 0.72) or math.min(usableHeight * 0.54, coverWidth * 1.12)) -- 352
		local coverX = left + 16 -- 357
		local coverY = wide and bottom + (usableHeight - coverHeight) / 2 - 12 + landscapeTopLift or bottom + usableHeight - coverHeight - 82 -- 358
		local infoX = wide and coverX + coverWidth + 28 or left + 20 -- 359
		local infoWidth = wide and usableWidth - coverWidth - 72 or usableWidth - 40 -- 360
		local infoTop = wide and bottom + usableHeight - 122 + landscapeTopLift or coverY - 30 -- 361
		local buttonWidth = wide and math.min(190, (infoWidth - 12) / 2) or (infoWidth - 12) / 2 -- 362
		local fontScale = mobileFontScale -- 363
		local cardIndices = getReusableCardIndices(index, #data) -- 364
		local headerRenderOrder = 1000 -- 365
		local ____toNode_34 = toNode -- 367
		local ____React_createElement_33 = React.createElement -- 367
		local ____array_32 = __TS__SparseArrayNew( -- 367
			"node", -- 367
			{ -- 367
				tag = "mobile-feed-scene", -- 367
				x = -width / 2, -- 367
				y = -height / 2, -- 367
				width = width, -- 367
				height = height, -- 367
				anchorX = 0, -- 367
				anchorY = 0, -- 367
				touchEnabled = true, -- 367
				onTapBegan = function() -- 367
					drag = Vec2.zero -- 377
					dragAxis = "none" -- 378
					local ____opt_13 = cardRef.current -- 378
					if ____opt_13 ~= nil then -- 378
						____opt_13:stopAllActions() -- 379
					end -- 379
					if indexRef.current then -- 379
						indexRef.current.opacity = 1 -- 380
					end -- 380
				end, -- 376
				onTapMoved = function(touch) -- 376
					drag = drag:add(touch.delta) -- 383
					if dragAxis == "none" and math.max( -- 383
						math.abs(drag.x), -- 384
						math.abs(drag.y) -- 384
					) >= 12 then -- 384
						dragAxis = math.abs(drag.x) > math.abs(drag.y) * 1.2 and "horizontal" or "vertical" -- 385
					end -- 385
					if cardRef.current then -- 385
						local offset = dragAxis == "horizontal" and Vec2(drag.x * 0.18, 0) or (dragAxis == "vertical" and Vec2(0, drag.y * 0.12) or Vec2.zero) -- 388
						cardRef.current.position = offset -- 389
						if indexRef.current then -- 389
							local headerBottom = bottom + usableHeight - 72 -- 391
							local indexTop = coverY + coverHeight - 14 + offset.y -- 392
							indexRef.current.opacity = dragAxis == "vertical" and math.max( -- 393
								0, -- 394
								math.min(1, (headerBottom - indexTop) / 16) -- 394
							) or 1 -- 394
						end -- 394
					end -- 394
				end, -- 382
				onTapEnded = function() -- 382
					local action = resolveFeedGesture(drag.x, drag.y, usableWidth, usableHeight) -- 400
					drag = Vec2.zero -- 401
					dragAxis = "none" -- 402
					if indexRef.current then -- 402
						indexRef.current.opacity = 1 -- 403
					end -- 403
					if action == "none" and cardRef.current then -- 403
						local card = cardRef.current -- 405
						card:perform(Move(App.reducedMotion and 0 or 0.16, card.position, Vec2.zero, Ease.OutQuad)) -- 406
					end -- 406
					commit(action) -- 408
				end, -- 399
				onMouseWheel = function(delta) return commit(delta.y > 0 and "previous" or "next") end -- 399
			}, -- 399
			React.createElement(VerticalGradient, {width = width, height = height, topColor = 4279310117, bottomColor = 4278716943}) -- 399
		) -- 399
		local ____createOpen_19 -- 413
		if createOpen then -- 413
			____createOpen_19 = nil -- 413
		else -- 413
			local ____temp_18 -- 413
			if item ~= nil then -- 413
				local ____React_createElement_17 = React.createElement -- 413
				local ____array_16 = __TS__SparseArrayNew( -- 413
					"node", -- 413
					{tag = "mobile-feed-card-" .. item.id, ref = cardRef, key = (tab .. "-") .. item.id}, -- 413
					__TS__ArrayMap( -- 414
						cardIndices, -- 414
						function(____, cardIndex) return React.createElement(Cover, { -- 414
							key = (tab .. "-") .. data[cardIndex + 1].id, -- 414
							entry = data[cardIndex + 1], -- 414
							x = coverX, -- 414
							y = coverY + (index - cardIndex) * usableHeight, -- 414
							width = coverWidth, -- 414
							height = coverHeight -- 414
						}) end -- 414
					), -- 414
					React.createElement( -- 414
						"node", -- 414
						{ -- 414
							tag = "mobile-feed-index", -- 414
							ref = indexRef, -- 414
							x = coverX + coverWidth - 62, -- 414
							y = coverY + coverHeight - 40, -- 414
							width = 48, -- 414
							height = 26, -- 414
							anchorX = 0, -- 414
							anchorY = 0 -- 414
						}, -- 414
						React.createElement(RoundedSurface, { -- 414
							width = 48, -- 414
							height = 26, -- 414
							radius = 13, -- 414
							topColor = 3760730173, -- 414
							bottomColor = 3759281694, -- 414
							borderWidth = 1, -- 414
							borderColor = 2286967404 -- 414
						}), -- 414
						React.createElement( -- 414
							"label", -- 414
							{ -- 414
								x = 24, -- 414
								y = 13, -- 414
								fontName = fontName, -- 414
								fontSize = 11, -- 414
								text = (tostring(index + 1) .. " / ") .. tostring(#data), -- 414
								color3 = 14146531 -- 414
							} -- 414
						) -- 414
					), -- 414
					React.createElement( -- 414
						"label", -- 414
						{ -- 414
							tag = "mobile-feed-current-title", -- 414
							x = infoX, -- 414
							y = infoTop, -- 414
							anchorX = 0, -- 414
							anchorY = 0.5, -- 414
							fontName = fontName, -- 414
							fontSize = math.floor((wide and 30 or 25) * fontScale), -- 414
							text = item.title, -- 414
							textWidth = infoWidth, -- 414
							alignment = "Left", -- 414
							color3 = 16052712 -- 414
						} -- 414
					), -- 414
					React.createElement( -- 414
						"label", -- 414
						{ -- 414
							x = infoX, -- 414
							y = infoTop - 58, -- 414
							anchorX = 0, -- 414
							anchorY = 0.5, -- 414
							fontName = fontName, -- 414
							fontSize = math.floor(15 * fontScale), -- 414
							text = conciseDescription(item.description, wide and 80 or (compact and 28 or 42)), -- 414
							textWidth = infoWidth, -- 414
							alignment = "Left", -- 414
							color3 = 11055037 -- 414
						} -- 414
					) -- 414
				) -- 414
				local ____compact_15 -- 430
				if compact or shortLandscape then -- 430
					____compact_15 = nil -- 430
				else -- 430
					____compact_15 = React.createElement( -- 430
						"node", -- 430
						{ -- 430
							x = infoX, -- 430
							y = infoTop - 118, -- 430
							width = wide and 176 or 164, -- 430
							height = 28, -- 430
							anchorX = 0, -- 430
							anchorY = 0 -- 430
						}, -- 430
						React.createElement(RoundedSurface, { -- 430
							width = wide and 176 or 164, -- 430
							height = 28, -- 430
							radius = 14, -- 430
							topColor = 1714436683, -- 430
							bottomColor = 1712857131, -- 430
							borderWidth = 1, -- 430
							borderColor = 2288020349 -- 430
						}), -- 430
						React.createElement("label", { -- 430
							x = 12, -- 430
							y = 14, -- 430
							anchorX = 0, -- 430
							fontName = fontName, -- 430
							fontSize = 12, -- 430
							text = item.kind == "local" and (zh and "本地作品  ·  可 Remix" or "Local  ·  Remixable") or (item.installed and (zh and "发现  ·  已安装" or "Discover  ·  Installed") or (zh and "发现  ·  可安装" or "Discover  ·  Installable")), -- 430
							textWidth = (wide and 176 or 164) - 24, -- 430
							alignment = "Left", -- 430
							color3 = 14475754 -- 430
						}) -- 430
					) -- 430
				end -- 430
				__TS__SparseArrayPush( -- 430
					____array_16, -- 430
					____compact_15, -- 430
					React.createElement( -- 430
						Button, -- 436
						{ -- 436
							tag = "mobile-feed-remix", -- 436
							x = infoX, -- 436
							y = bottom + 24, -- 436
							width = buttonWidth, -- 436
							text = zh and "Remix 作品" or "Remix game", -- 436
							fontSize = math.floor(16 * fontScale), -- 436
							primary = true, -- 436
							onTapped = function() return activate("remix") end -- 436
						} -- 436
					), -- 436
					React.createElement( -- 436
						Button, -- 438
						{ -- 438
							tag = "mobile-feed-play", -- 438
							x = infoX + buttonWidth + 12, -- 438
							y = bottom + 24, -- 438
							width = buttonWidth, -- 438
							text = zh and "试玩" or "Play", -- 438
							fontSize = math.floor(17 * fontScale), -- 438
							onTapped = function() return activate("play") end -- 438
						} -- 438
					), -- 438
					React.createElement("label", { -- 438
						x = infoX, -- 438
						y = bottom + 92, -- 438
						anchorX = 0, -- 438
						anchorY = 0.5, -- 438
						fontName = fontName, -- 438
						fontSize = 14, -- 438
						text = prepareStatus ~= "" and prepareStatus or (item.launchError ~= nil and item.launchError or (zh and "上滑浏览  ·  右滑 Remix  ·  左滑试玩" or "Swipe up  ·  right Remix  ·  left Play")), -- 438
						textWidth = infoWidth, -- 438
						alignment = "Left", -- 438
						color3 = item.launchError ~= nil and 16739179 or 11055037 -- 438
					}) -- 438
				) -- 438
				____temp_18 = ____React_createElement_17(__TS__SparseArraySpread(____array_16)) -- 438
			else -- 438
				____temp_18 = React.createElement( -- 438
					"node", -- 438
					nil, -- 438
					React.createElement("label", { -- 438
						x = left + usableWidth / 2, -- 438
						y = bottom + usableHeight / 2 + 20, -- 438
						fontName = fontName, -- 438
						fontSize = 22, -- 438
						text = tab == "discover" and (zh and "暂无移动作品" or "No mobile games yet") or (zh and "没有可运行的本地作品" or "No runnable local games"), -- 438
						color3 = 16052712 -- 438
					}), -- 438
					React.createElement("label", { -- 438
						x = left + usableWidth / 2, -- 438
						y = bottom + usableHeight / 2 - 28, -- 438
						fontName = fontName, -- 438
						fontSize = 14, -- 438
						text = tab == "discover" and discoverError ~= "" and discoverError or (zh and "切换标签或稍后重试" or "Switch tabs or retry later"), -- 438
						textWidth = usableWidth - 48, -- 438
						color3 = tab == "discover" and discoverError ~= "" and 16739179 or 11055037 -- 438
					}) -- 438
				) -- 438
			end -- 438
			____createOpen_19 = ____temp_18 -- 413
		end -- 413
		__TS__SparseArrayPush(____array_32, ____createOpen_19) -- 413
		local ____React_createElement_23 = React.createElement -- 413
		local ____array_22 = __TS__SparseArrayNew("node", {tag = "mobile-feed-header", order = headerRenderOrder}) -- 413
		local ____options_onSwitchMode_20 -- 452
		if options.onSwitchMode then -- 452
			____options_onSwitchMode_20 = React.createElement( -- 452
				"node", -- 452
				{ -- 452
					tag = "mobile-ui-mode-switch", -- 452
					x = left + 12, -- 452
					y = bottom + usableHeight - 58 + landscapeTopLift, -- 452
					width = 72, -- 452
					height = 48, -- 452
					anchorX = 0, -- 452
					anchorY = 0, -- 452
					touchEnabled = true, -- 452
					swallowTouches = true, -- 452
					onTapped = switchMode -- 452
				}, -- 452
				React.createElement("label", { -- 452
					x = 0, -- 452
					y = 30, -- 452
					anchorX = 0, -- 452
					fontName = fontName, -- 452
					fontSize = 16, -- 452
					text = "DORA", -- 452
					color3 = preparing and 7831180 or 16763955 -- 452
				}), -- 452
				React.createElement("label", { -- 452
					x = 0, -- 452
					y = 10, -- 452
					anchorX = 0, -- 452
					fontName = fontName, -- 452
					fontSize = 10, -- 452
					text = zh and "切换传统界面" or "Classic UI", -- 452
					color3 = 7831180 -- 452
				}) -- 452
			) -- 452
		else -- 452
			____options_onSwitchMode_20 = nil -- 456
		end -- 456
		__TS__SparseArrayPush( -- 456
			____array_22, -- 456
			____options_onSwitchMode_20, -- 456
			React.createElement( -- 456
				"label", -- 456
				{ -- 456
					tag = "mobile-feed-discover-tab", -- 456
					x = left + usableWidth / 2 - 44, -- 456
					y = bottom + usableHeight - 34 + landscapeTopLift, -- 456
					fontName = fontName, -- 456
					fontSize = math.floor(17 * fontScale), -- 456
					text = zh and "发现" or "Discover", -- 456
					color3 = tab == "discover" and 16763955 or 11055037, -- 456
					touchEnabled = true, -- 456
					swallowTouches = true, -- 456
					onTapped = function() return setTab("discover") end -- 456
				} -- 456
			), -- 456
			React.createElement( -- 456
				"label", -- 456
				{ -- 456
					tag = "mobile-feed-local-tab", -- 456
					x = left + usableWidth / 2 + 44, -- 456
					y = bottom + usableHeight - 34 + landscapeTopLift, -- 456
					fontName = fontName, -- 456
					fontSize = math.floor(17 * fontScale), -- 456
					text = zh and "本地" or "Local", -- 456
					color3 = tab == "local" and 16763955 or 11055037, -- 456
					touchEnabled = true, -- 456
					swallowTouches = true, -- 456
					onTapped = function() -- 456
						____local = getLocalEntries() -- 462
						setTab("local") -- 462
					end -- 462
				} -- 462
			), -- 462
			React.createElement(RoundedSurface, { -- 462
				x = left + usableWidth / 2 + (tab == "discover" and -58 or 30), -- 462
				y = bottom + usableHeight - 56 + landscapeTopLift, -- 462
				width = 28, -- 462
				height = 3, -- 462
				radius = 1.5, -- 462
				fillColor = colors.brand, -- 462
				renderOrder = headerRenderOrder + 1 -- 462
			}) -- 462
		) -- 462
		local ____temp_21 -- 464
		if tab == "local" and options.createProject then -- 464
			____temp_21 = React.createElement( -- 464
				"node", -- 464
				{ -- 464
					tag = "mobile-feed-create", -- 464
					x = left + usableWidth - 82, -- 464
					y = bottom + usableHeight - 56 + landscapeTopLift, -- 464
					width = 70, -- 464
					height = 44, -- 464
					anchorX = 0, -- 464
					anchorY = 0, -- 464
					touchEnabled = true, -- 464
					swallowTouches = true, -- 464
					onTapped = function() -- 464
						if preparing or transitioning or creating or createOpen or HttpServer.wsConnectionCount > 0 then -- 464
							return -- 466
						end -- 466
						createOpen = true -- 467
						createName = "" -- 468
						dismissedCreateComposition = false -- 469
						createError = "" -- 470
						render() -- 471
						createInput.deferFocus() -- 472
					end -- 465
				}, -- 465
				React.createElement(RoundedSurface, { -- 465
					width = 70, -- 465
					height = 44, -- 465
					radius = 22, -- 465
					topColor = 858534978, -- 465
					bottomColor = 856824097, -- 465
					borderWidth = 1, -- 465
					borderColor = colors.brand, -- 465
					renderOrder = headerRenderOrder + 1 -- 465
				}), -- 465
				React.createElement("label", { -- 465
					x = 35, -- 465
					y = 22, -- 465
					fontName = fontName, -- 465
					fontSize = 14, -- 465
					text = zh and "+ 新建" or "+ New", -- 465
					color3 = 16763955 -- 465
				}) -- 465
			) -- 465
		else -- 465
			____temp_21 = nil -- 476
		end -- 476
		__TS__SparseArrayPush(____array_22, ____temp_21) -- 476
		__TS__SparseArrayPush( -- 476
			____array_32, -- 476
			____React_createElement_23(__TS__SparseArraySpread(____array_22)) -- 476
		) -- 476
		local ____createOpen_31 -- 478
		if createOpen then -- 478
			____createOpen_31 = (function() -- 478
				local sheetHeight = math.min(createSheetHeight, usableHeight - 64) -- 479
				local sheetWidth = usableWidth -- 480
				local contentWidth = sheetWidth - 40 -- 481
				local actionGap = 12 -- 482
				local actionsWidth = shortLandscape and math.min(300, math.floor(contentWidth * 0.42)) or contentWidth -- 483
				local inputWidth = shortLandscape and contentWidth - actionGap - actionsWidth or contentWidth -- 484
				local actionX = shortLandscape and 20 + inputWidth + actionGap or 20 -- 485
				local actionY = shortLandscape and sheetHeight - createInputTop - createInputHeight or 20 -- 486
				local cancelWidth = math.floor((actionsWidth - actionGap) * (shortLandscape and 0.34 or 0.38)) -- 487
				local ____React_createElement_30 = React.createElement -- 483
				local ____array_29 = __TS__SparseArrayNew( -- 483
					"node", -- 483
					{ -- 483
						tag = "mobile-project-create-sheet", -- 483
						order = 10000, -- 483
						width = width, -- 483
						height = height, -- 483
						anchorX = 0, -- 483
						anchorY = 0, -- 483
						touchEnabled = true, -- 483
						swallowTouches = true -- 483
					}, -- 483
					React.createElement( -- 483
						"node", -- 483
						{ -- 483
							tag = "mobile-project-create-focus-observer", -- 483
							order = 1000, -- 483
							width = width, -- 483
							height = height, -- 483
							anchorX = 0, -- 483
							anchorY = 0, -- 483
							touchEnabled = true, -- 483
							swallowTouches = false, -- 483
							swallowMouseWheel = false, -- 483
							onTapFilter = function(touch) -- 483
								touch.enabled = false -- 487
								if not canEditCreate() then -- 487
									return -- 488
								end -- 488
								local input = createInputRef.current -- 489
								local point = input and input:convertToNodeSpace(touch.worldLocation) -- 490
								local inside = input and point and point.x >= 0 and point.y >= 0 and point.x <= input.width and point.y <= input.height -- 491
								dismissedCreateComposition = not inside and createInput.isComposing() -- 492
								if not inside then -- 492
									blurCreateInput() -- 493
								end -- 493
							end -- 486
						} -- 486
					), -- 486
					React.createElement( -- 486
						"draw-node", -- 486
						{ -- 486
							tag = "mobile-project-create-backdrop", -- 486
							order = 0, -- 486
							renderOrder = 0, -- 486
							x = width / 2, -- 486
							y = bottom + sheetHeight + (height - bottom - sheetHeight) / 2 -- 486
						}, -- 486
						React.createElement("rect-shape", {width = width, height = height - bottom - sheetHeight, fillColor = 2348810240}) -- 486
					) -- 486
				) -- 486
				local ____React_createElement_28 = React.createElement -- 486
				local ____array_27 = __TS__SparseArrayNew( -- 486
					"node", -- 486
					{ -- 486
						ref = createPanelRef, -- 486
						order = 10, -- 486
						renderOrder = 10, -- 486
						x = left, -- 486
						y = bottom, -- 486
						width = sheetWidth, -- 486
						height = sheetHeight, -- 486
						anchorX = 0, -- 486
						anchorY = 0, -- 486
						touchEnabled = true, -- 486
						swallowTouches = true -- 486
					}, -- 486
					React.createElement(RoundedSurface, { -- 486
						width = sheetWidth, -- 486
						height = sheetHeight, -- 486
						radius = 24, -- 486
						topColor = 4280560956, -- 486
						bottomColor = 4279309856, -- 486
						borderWidth = 1, -- 486
						borderColor = 4283061608, -- 486
						shadow = true, -- 486
						renderOrder = 10 -- 486
					}), -- 486
					React.createElement("label", { -- 486
						x = 20, -- 486
						y = sheetHeight - 24, -- 486
						anchorX = 0, -- 486
						anchorY = 1, -- 486
						fontName = fontName, -- 486
						fontSize = 22, -- 486
						text = zh and "新建项目" or "New project", -- 486
						color3 = 16052712 -- 486
					}), -- 486
					React.createElement("label", { -- 486
						x = 20, -- 486
						y = sheetHeight - 66, -- 486
						anchorX = 0, -- 486
						anchorY = 1, -- 486
						fontName = fontName, -- 486
						fontSize = 14, -- 486
						text = zh and "项目名称" or "Project name", -- 486
						color3 = 11055037 -- 486
					}) -- 486
				) -- 486
				local ____keptInput_26 -- 500
				if keptInput then -- 500
					____keptInput_26 = nil -- 500
				else -- 500
					____keptInput_26 = React.createElement("node", { -- 500
						tag = "mobile-project-create-input", -- 500
						ref = createInputRef, -- 500
						renderOrder = 10, -- 500
						x = 20, -- 500
						y = sheetHeight - createInputTop - createInputHeight, -- 500
						width = inputWidth, -- 500
						height = createInputHeight, -- 500
						anchorX = 0, -- 500
						anchorY = 0, -- 500
						onMount = createInput.mount -- 500
					}) -- 500
				end -- 500
				__TS__SparseArrayPush( -- 500
					____array_27, -- 500
					____keptInput_26, -- 500
					React.createElement("label", { -- 500
						tag = "mobile-project-create-error", -- 500
						x = 20, -- 500
						y = shortLandscape and sheetHeight - createInputTop + 12 or sheetHeight - createInputTop - createInputHeight - 12, -- 500
						anchorX = 0, -- 500
						anchorY = 1, -- 500
						fontName = fontName, -- 500
						fontSize = 12, -- 500
						text = createError ~= "" and createError or (zh and "将创建可运行的 TypeScript 起始项目" or "Creates a runnable TypeScript starter project"), -- 500
						textWidth = inputWidth, -- 500
						alignment = "Left", -- 500
						color3 = createError ~= "" and 16739179 or 11055037 -- 500
					}), -- 500
					React.createElement(Button, { -- 500
						tag = "mobile-project-create-cancel", -- 500
						x = actionX, -- 500
						y = actionY, -- 500
						width = cancelWidth, -- 500
						text = zh and "取消" or "Cancel", -- 500
						renderOrder = 10, -- 500
						onTapped = closeCreate -- 500
					}), -- 500
					React.createElement( -- 500
						Button, -- 506
						{ -- 506
							tag = "mobile-project-create-submit", -- 506
							x = actionX + cancelWidth + actionGap, -- 506
							y = actionY, -- 506
							width = actionsWidth - cancelWidth - actionGap, -- 506
							text = creating and (zh and "创建中…" or "Creating…") or (zh and "创建并进入 Remix" or "Create and Remix"), -- 506
							primary = true, -- 506
							renderOrder = 10, -- 506
							onTapped = function() -- 506
								if not dismissedCreateComposition then -- 506
									submitCreate() -- 507
								end -- 507
								dismissedCreateComposition = false -- 507
							end -- 507
						} -- 507
					) -- 507
				) -- 507
				__TS__SparseArrayPush( -- 507
					____array_29, -- 507
					____React_createElement_28(__TS__SparseArraySpread(____array_27)) -- 507
				) -- 507
				return ____React_createElement_30(__TS__SparseArraySpread(____array_29)) -- 484
			end)() -- 478
		else -- 478
			____createOpen_31 = nil -- 510
		end -- 510
		__TS__SparseArrayPush(____array_32, ____createOpen_31) -- 510
		local scene = ____toNode_34(____React_createElement_33(__TS__SparseArraySpread(____array_32))) -- 367
		if scene ~= nil then -- 367
			host:addChild(scene) -- 512
		end -- 512
		if keptInput and createPanelRef.current then -- 512
			keptInput.position = Vec2( -- 514
				20, -- 514
				math.min(createSheetHeight, usableHeight - 64) - createInputTop - createInputHeight -- 514
			) -- 514
			createPanelRef.current:addChild(keptInput) -- 515
		end -- 515
		createInput.refresh() -- 517
		if restoreFocus and not keptInput and createOpen then -- 517
			createInput.focus(false) -- 518
		end -- 518
	end -- 326
	host:onAppChange(function(setting) -- 521
		if setting == "Size" or setting == "Locale" then -- 521
			render() -- 522
		end -- 522
	end) -- 521
	host:onAppEvent(function(event) -- 524
		if event == "BackButton" then -- 524
			if createOpen and not creating then -- 524
				closeCreate() -- 526
			end -- 526
		elseif event == "WillEnterBackground" or event == "DidEnterBackground" then -- 526
			blurCreateInput() -- 527
		end -- 527
	end) -- 524
	host:onCleanup(function() -- 529
		blurCreateInput() -- 529
		active = false -- 529
	end) -- 529
	host:slot( -- 530
		"RestoreFeedEntry", -- 530
		function(entry) -- 530
			if not isActive() or HttpServer.wsConnectionCount > 0 then -- 530
				return -- 531
			end -- 531
			returnEntry = entry -- 532
			____local = getLocalEntries() -- 533
			discover = getDiscoverEntries() -- 534
			local location = resolveFeedLocation(____local, discover, entry) -- 535
			tab = location.tab -- 536
			index = location.index -- 537
			render() -- 538
		end -- 530
	) -- 530
	host:slot("SuspendLocalUI", blurCreateInput) -- 540
	host:slot( -- 541
		"ResumeLocalUI", -- 541
		function() -- 541
			leaving = false -- 541
			render() -- 541
		end -- 541
	) -- 541
	render() -- 542
	if syncDiscover then -- 542
		if #discover == 0 then -- 542
			discoverError = zh and "正在同步资源目录…" or "Syncing Catalog…" -- 545
			render() -- 546
		end -- 546
		syncDiscover( -- 548
			function(message) -- 548
				if not isActive() or #discover > 0 then -- 548
					return -- 549
				end -- 549
				discoverError = message -- 550
				render() -- 551
			end, -- 548
			function(success, message) -- 552
				if not isActive() then -- 552
					return -- 553
				end -- 553
				local selected = returnEntry or rememberedEntries[tab] or current() -- 554
				local previousCount = #discover -- 555
				discover = getDiscoverEntries() -- 556
				discoverError = success and (#discover == 0 and (zh and "目录中暂无可运行作品" or "No runnable Catalog games") or "") or (message or (zh and "资源目录同步失败" or "Catalog sync failed")) -- 557
				tab = resolveDiscoverRefreshTab( -- 560
					tab, -- 560
					userSelectedTab, -- 560
					previousCount, -- 560
					#discover, -- 560
					#____local -- 560
				) -- 560
				if selected ~= nil then -- 560
					local location = resolveFeedLocation(____local, discover, selected) -- 562
					tab = location.tab -- 563
					index = location.index -- 564
				end -- 564
				if tab == "discover" then -- 564
					index = normalizeFeedIndex(index, #discover) -- 566
				end -- 566
				render() -- 567
			end -- 552
		) -- 552
	end -- 552
	return host -- 570
end -- 129
return ____exports -- 129
