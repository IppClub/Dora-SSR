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
local ____ProjectIndex = require("Dev.Mobile.ProjectIndex") -- 10
local ProjectIndex = ____ProjectIndex.ProjectIndex -- 10
local colors = { -- 32
	background = 4278914322, -- 33
	panel = 4279572770, -- 34
	panelRaised = 4280297010, -- 35
	text = 4294242792, -- 36
	muted = 4289245117, -- 37
	brand = 4294954035, -- 38
	border = 4281613128, -- 39
	danger = 4294929259 -- 40
} -- 40
local fontName = "sarasa-mono-sc-regular" -- 43
local createSheetHeight = 260 -- 44
local createInputHeight = 44 -- 45
local createInputTop = 96 -- 46
local function conciseDescription(text, limit) -- 48
	local length = (utf8.len(text)) or 0 -- 49
	if length <= limit then -- 49
		return text -- 50
	end -- 50
	local stop = utf8.offset(text, limit + 1) or #text + 1 -- 51
	return string.sub(text, 1, stop - 1) .. "…" -- 52
end -- 48
local function Cover(props) -- 55
	local file = props.entry.bannerFile -- 56
	local function scaleSprite(sprite, mode) -- 57
		local scales = getCoverScales(sprite.width, sprite.height, props.width, props.height) -- 58
		sprite.scaleX = scales[mode] -- 59
		sprite.scaleY = scales[mode] -- 60
	end -- 57
	local ____React_createElement_5 = React.createElement -- 57
	local ____temp_3 = { -- 57
		x = props.x, -- 57
		y = props.y, -- 57
		width = props.width, -- 57
		height = props.height, -- 57
		anchorX = 0, -- 57
		anchorY = 0 -- 57
	} -- 57
	local ____React_createElement_result_4 = React.createElement( -- 57
		RoundedSurface, -- 63
		{ -- 63
			width = props.width, -- 63
			height = props.height, -- 63
			radius = 22, -- 63
			topColor = stableCoverColor(props.entry.id), -- 63
			bottomColor = 4279310115, -- 63
			shadow = true -- 63
		} -- 63
	) -- 63
	local ____file_0 -- 65
	if file then -- 65
		____file_0 = React.createElement( -- 65
			"clip-node", -- 65
			{ -- 65
				width = props.width, -- 65
				height = props.height, -- 65
				anchorX = 0, -- 65
				anchorY = 0, -- 65
				stencil = React.createElement(RoundedStencil, {width = props.width, height = props.height, radius = 22}) -- 65
			}, -- 65
			React.createElement( -- 65
				"sprite", -- 65
				{ -- 65
					file = file, -- 65
					x = props.width / 2 - 5, -- 65
					y = props.height / 2, -- 65
					opacity = 0.08, -- 65
					onMount = function(sprite) return scaleSprite(sprite, "cover") end -- 65
				} -- 65
			), -- 65
			React.createElement( -- 65
				"sprite", -- 65
				{ -- 65
					file = file, -- 65
					x = props.width / 2 + 5, -- 65
					y = props.height / 2, -- 65
					opacity = 0.08, -- 65
					onMount = function(sprite) return scaleSprite(sprite, "cover") end -- 65
				} -- 65
			), -- 65
			React.createElement( -- 65
				"sprite", -- 65
				{ -- 65
					file = file, -- 65
					x = props.width / 2, -- 65
					y = props.height / 2 - 5, -- 65
					opacity = 0.08, -- 65
					onMount = function(sprite) return scaleSprite(sprite, "cover") end -- 65
				} -- 65
			), -- 65
			React.createElement( -- 65
				"draw-node", -- 65
				{x = props.width / 2, y = props.height / 2}, -- 65
				React.createElement("rect-shape", {width = props.width, height = props.height, fillColor = 2953514258}) -- 65
			), -- 65
			React.createElement( -- 65
				"sprite", -- 65
				{ -- 65
					file = file, -- 65
					x = props.width / 2, -- 65
					y = props.height / 2, -- 65
					onMount = function(sprite) return scaleSprite(sprite, "contain") end -- 65
				} -- 65
			) -- 65
		) -- 65
	else -- 65
		____file_0 = React.createElement( -- 65
			"label", -- 65
			{ -- 65
				x = props.width / 2, -- 65
				y = props.height / 2 + 10, -- 65
				fontName = fontName, -- 65
				fontSize = math.floor(math.max( -- 65
					22, -- 77
					math.min(34, props.width / 12) -- 77
				)), -- 77
				text = props.entry.title, -- 77
				textWidth = props.width - 40, -- 77
				color3 = 16052712 -- 77
			} -- 77
		) -- 77
	end -- 77
	local ____file_1 -- 82
	if file then -- 82
		____file_1 = nil -- 82
	else -- 82
		____file_1 = React.createElement("label", { -- 82
			x = props.width / 2, -- 82
			y = 30, -- 82
			fontName = fontName, -- 82
			fontSize = 14, -- 82
			text = "DORA SSR · REMIXABLE", -- 82
			color3 = 16763955 -- 82
		}) -- 82
	end -- 82
	local ____file_2 -- 90
	if file then -- 90
		____file_2 = nil -- 90
	else -- 90
		____file_2 = React.createElement(DoraMascot, {state = "idle", x = props.width - 46, y = 64, size = 42}) -- 90
	end -- 90
	return ____React_createElement_5( -- 62
		"node", -- 62
		____temp_3, -- 62
		____React_createElement_result_4, -- 62
		____file_0, -- 62
		____file_1, -- 62
		____file_2, -- 62
		React.createElement(RoundedSurface, { -- 62
			width = props.width, -- 62
			height = props.height, -- 62
			radius = 22, -- 62
			fillColor = 0, -- 62
			borderWidth = 1, -- 62
			borderColor = 4282074454 -- 62
		}) -- 62
	) -- 62
end -- 55
function ____exports.startMobileFeed(options) -- 95
	local submitCreate, render -- 95
	local getLocalEntries = options.getLocalEntries -- 96
	local getDiscoverEntries = options.getDiscoverEntries -- 97
	local onPlay = options.onPlay -- 98
	local onRemix = options.onRemix -- 99
	local prepare = options.prepare -- 100
	local syncDiscover = options.syncDiscover -- 101
	local zh = (string.match(App.locale, "^zh")) ~= nil -- 102
	local tab = "local" -- 103
	local index = 0 -- 104
	local drag = Vec2.zero -- 105
	local dragAxis = "none" -- 106
	local discoverError = "" -- 107
	local preparing = false -- 108
	local transitioning = false -- 109
	local prepareStatus = "" -- 110
	local repairResourceId = "" -- 111
	local userSelectedTab = false -- 112
	local active = true -- 113
	local leaving = false -- 114
	local createOpen = false -- 115
	local projectIndexOpen = false -- 116
	local creating = false -- 117
	local createName = "" -- 118
	local dismissedCreateComposition = false -- 119
	local createError = "" -- 120
	local gamepadUsed = false -- 121
	local returnEntry = options.initialEntry -- 122
	local ____opt_6 = options.initialEntries -- 122
	local ____temp_10 = ____opt_6 and ____opt_6["local"] -- 124
	local ____opt_8 = options.initialEntries -- 124
	local rememberedEntries = {["local"] = ____temp_10, discover = ____opt_8 and ____opt_8.discover} -- 123
	local cardRef = reference() -- 127
	local indexRef = reference() -- 128
	local createInputRef = reference() -- 129
	local discover = getDiscoverEntries() -- 130
	local ____local = getLocalEntries() -- 131
	if #discover == 0 then -- 131
		discoverError = zh and "资源目录暂不可用" or "Catalog is unavailable" -- 134
	end -- 134
	local initialLocation = resolveFeedLocation(____local, discover, returnEntry) -- 136
	tab = initialLocation.tab -- 137
	index = initialLocation.index -- 138
	local host = Node() -- 140
	host.tag = "mobile-feed" -- 141
	host.scaleX = App.devicePixelRatio -- 142
	host.scaleY = App.devicePixelRatio -- 143
	host:addTo(Director.systemUI) -- 144
	local function isActive() -- 146
		return active and not leaving and host.parent ~= nil -- 146
	end -- 146
	local function entries() -- 148
		return tab == "discover" and discover or ____local -- 148
	end -- 148
	local function current() -- 149
		return entries()[normalizeFeedIndex( -- 149
			index, -- 149
			#entries() -- 149
		) + 1] -- 149
	end -- 149
	local rememberedEntryKey = "" -- 150
	local function rememberCurrent() -- 151
		local item = current() -- 152
		if not item or not options.onCurrentEntryChanged then -- 152
			return -- 153
		end -- 153
		local key = (((((item.kind .. "\n") .. item.id) .. "\n") .. (item.workDir or "")) .. "\n") .. (item.fileName or "") -- 154
		if key == rememberedEntryKey then -- 154
			return -- 155
		end -- 155
		rememberedEntryKey = key -- 156
		rememberedEntries[item.kind] = item -- 157
		options.onCurrentEntryChanged(item) -- 158
	end -- 151
	local function canEditCreate() -- 160
		return createOpen and not creating and isActive() and host.visible and HttpServer.wsConnectionCount == 0 -- 160
	end -- 160
	local createInput = createTextInput({ -- 161
		fontSize = math.floor(16 * mobileFontScale), -- 162
		singleLine = true, -- 163
		background = colors.background, -- 164
		getText = function() return createName end, -- 165
		setText = function(text) -- 166
			createName = text -- 166
		end, -- 166
		getPlaceholder = function() return zh and "例如：星际花园" or "For example: Star Garden" end, -- 167
		isEnabled = canEditCreate, -- 168
		onReturn = function() -- 169
			submitCreate() -- 169
			return true -- 169
		end -- 169
	}) -- 169
	local blurCreateInput = createInput.blur -- 171
	local function closeCreate() -- 172
		if creating then -- 172
			return -- 173
		end -- 173
		blurCreateInput() -- 174
		createOpen = false -- 175
		createName = "" -- 176
		createError = "" -- 177
		render() -- 178
	end -- 172
	local function openCreate() -- 180
		if not options.createProject or preparing or transitioning or creating or createOpen or HttpServer.wsConnectionCount > 0 then -- 180
			return -- 181
		end -- 181
		projectIndexOpen = false -- 182
		createOpen = true -- 183
		createName = "" -- 184
		dismissedCreateComposition = false -- 185
		createError = "" -- 186
		render() -- 187
		createInput.deferFocus() -- 188
	end -- 180
	local function openProjectIndex() -- 190
		if tab ~= "local" or preparing or transitioning or creating or createOpen or HttpServer.wsConnectionCount > 0 then -- 190
			return -- 191
		end -- 191
		____local = getLocalEntries() -- 192
		projectIndexOpen = true -- 193
		render() -- 194
	end -- 190
	local function createErrorText(____error) -- 196
		repeat -- 196
			local ____switch30 = ____error -- 196
			local ____cond30 = ____switch30 == "invalid-name" -- 196
			if ____cond30 then -- 196
				return zh and "请输入不含路径分隔符的项目名称" or "Enter a project name without path separators" -- 198
			end -- 198
			____cond30 = ____cond30 or ____switch30 == "target-existed" -- 198
			if ____cond30 then -- 198
				return zh and "已有同名项目，请换一个名称" or "A project with that name already exists" -- 199
			end -- 199
			____cond30 = ____cond30 or ____switch30 == "create-folder-failed" -- 199
			if ____cond30 then -- 199
				return zh and "无法创建项目目录，请检查工作目录后重试" or "Could not create the project folder; check the workspace and retry" -- 200
			end -- 200
			____cond30 = ____cond30 or ____switch30 == "create-entry-failed" -- 200
			if ____cond30 then -- 200
				return zh and "无法写入项目入口，未完成项目已回滚" or "Could not write the project entry; the incomplete project was rolled back" -- 201
			end -- 201
			____cond30 = ____cond30 or ____switch30 == "created-project-not-found" -- 201
			if ____cond30 then -- 201
				return zh and "项目已创建，但本地列表未能找到它，请返回后重试" or "The project was created but could not be found in Local; return and retry" -- 202
			end -- 202
			do -- 202
				return zh and "创建失败，请重试" or "Project creation failed; try again" -- 203
			end -- 203
		until true -- 203
	end -- 196
	submitCreate = function() -- 206
		if not options.createProject or creating or not createOpen or not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 then -- 206
			return -- 207
		end -- 207
		if createInput.isComposing() then -- 207
			return -- 208
		end -- 208
		creating = true -- 209
		createError = "" -- 210
		blurCreateInput() -- 211
		render() -- 212
		local result = options.createProject(createName) -- 213
		if not isActive() then -- 213
			return -- 214
		end -- 214
		creating = false -- 215
		if not result.success then -- 215
			createError = createErrorText(result.error) -- 217
			render() -- 218
			return -- 219
		end -- 219
		createOpen = false -- 221
		createName = "" -- 222
		____local = getLocalEntries() -- 223
		returnEntry = result.entry -- 224
		local location = resolveFeedLocation(____local, discover, result.entry) -- 225
		tab = location.tab -- 226
		index = location.index -- 227
		render() -- 228
		onRemix(result.entry) -- 229
	end -- 206
	local function setTab(next) -- 232
		if not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 or preparing or creating then -- 232
			return -- 233
		end -- 233
		userSelectedTab = true -- 234
		returnEntry = nil -- 235
		if tab == next then -- 235
			return -- 236
		end -- 236
		if createOpen then -- 236
			blurCreateInput() -- 238
			createOpen = false -- 239
			createName = "" -- 240
			createError = "" -- 241
		end -- 241
		tab = next -- 243
		local target = rememberedEntries[next] -- 244
		local ____temp_11 -- 245
		if target == nil then -- 245
			____temp_11 = nil -- 245
		else -- 245
			____temp_11 = resolveFeedLocation(____local, discover, target) -- 245
		end -- 245
		local location = ____temp_11 -- 245
		index = (location and location.tab) == next and location.index or 0 -- 246
		render() -- 247
	end -- 232
	local function activate(action) -- 249
		local item = current() -- 250
		if not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 or not item or preparing then -- 250
			return -- 251
		end -- 251
		item.launchError = nil -- 252
		local function done() -- 253
			returnEntry = item -- 253
			local ____temp_14 -- 253
			if action == "play" then -- 253
				____temp_14 = onPlay(item) -- 253
			else -- 253
				____temp_14 = onRemix(item) -- 253
			end -- 253
			return ____temp_14 -- 253
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
			local ____switch55 = action -- 286
			local ____cond55 = ____switch55 == "previous" or ____switch55 == "next" -- 286
			if ____cond55 then -- 286
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
			____cond55 = ____cond55 or ____switch55 == "play" -- 312
			if ____cond55 then -- 312
				activate("play") -- 314
				return -- 314
			end -- 314
			____cond55 = ____cond55 or ____switch55 == "remix" -- 314
			if ____cond55 then -- 314
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
		local shortLandscapeInputWidth = safeContentWidth - 12 - math.min( -- 330
			300, -- 330
			math.floor(safeContentWidth * 0.42) -- 330
		) -- 330
		local expectedInputWidth = App.safeArea.width >= 760 and App.safeArea.height < 500 and shortLandscapeInputWidth or safeContentWidth -- 331
		local ____createOpen_17 = createOpen -- 332
		if ____createOpen_17 then -- 332
			local ____opt_15 = createInputRef.current -- 332
			____createOpen_17 = (____opt_15 and ____opt_15.width) == expectedInputWidth -- 332
		end -- 332
		local keptInput = ____createOpen_17 and createInputRef.current or nil -- 332
		local restoreFocus = createInput.isFocused() -- 333
		if keptInput ~= nil then -- 333
			keptInput:removeFromParent(false) -- 334
		end -- 334
		if not keptInput then -- 334
			createInput.unmount() -- 336
			createInputRef = reference() -- 337
		end -- 337
		local createPanelRef = reference() -- 339
		host:removeAllChildren() -- 340
		host.scaleX = App.devicePixelRatio -- 341
		host.scaleY = App.devicePixelRatio -- 342
		local ____App_visualSize_20 = App.visualSize -- 343
		local width = ____App_visualSize_20.width -- 343
		local height = ____App_visualSize_20.height -- 343
		local safe = App.safeArea -- 344
		local left = safe.left -- 345
		local bottom = safe.bottom -- 346
		local usableWidth = safe.width -- 347
		local usableHeight = safe.height -- 348
		local wide = usableWidth >= 760 -- 349
		local shortLandscape = wide and usableHeight < 500 -- 350
		local compact = not wide and usableHeight < 700 -- 351
		local compactLandscape = compact and usableWidth > usableHeight and usableHeight < 520 -- 352
		local landscapeTopLift = shortLandscape and 28 or 0 -- 353
		local data = entries() -- 354
		index = normalizeFeedIndex(index, #data) -- 355
		local item = current() -- 356
		rememberCurrent() -- 357
		local coverWidth = wide and math.min(usableWidth * 0.54, 680) or usableWidth - 32 -- 358
		local coverHeight = wide and math.min(usableHeight - 118, coverWidth * 0.72) or (compact and math.min(usableHeight * (compactLandscape and 0.43 or 0.49), coverWidth * 0.72) or math.min(usableHeight * 0.54, coverWidth * 1.12)) -- 359
		local coverX = left + 16 -- 364
		local coverY = wide and bottom + (usableHeight - coverHeight) / 2 - 12 + landscapeTopLift or bottom + usableHeight - coverHeight - 82 -- 365
		local infoX = wide and coverX + coverWidth + 28 or left + 20 -- 366
		local infoWidth = wide and usableWidth - coverWidth - 72 or usableWidth - 40 -- 367
		local infoTop = wide and bottom + usableHeight - 122 + landscapeTopLift or coverY - (compactLandscape and 28 or 30) -- 368
		local descriptionY = infoTop - (compactLandscape and 38 or 58) -- 369
		local actionsY = bottom + (compactLandscape and 18 or 24) -- 370
		local gestureHintY = bottom + (compactLandscape and 88 or 92) -- 371
		local buttonWidth = wide and math.min(190, (infoWidth - 12) / 2) or (infoWidth - 12) / 2 -- 372
		local fontScale = mobileFontScale -- 373
		local cardIndices = getReusableCardIndices(index, #data) -- 374
		local headerRenderOrder = 1000 -- 375
		local ____toNode_47 = toNode -- 377
		local ____React_createElement_46 = React.createElement -- 377
		local ____array_45 = __TS__SparseArrayNew( -- 377
			"node", -- 377
			{ -- 377
				tag = "mobile-feed-scene", -- 377
				x = -width / 2, -- 377
				y = -height / 2, -- 377
				width = width, -- 377
				height = height, -- 377
				anchorX = 0, -- 377
				anchorY = 0, -- 377
				touchEnabled = true, -- 377
				onTapBegan = function() -- 377
					drag = Vec2.zero -- 387
					dragAxis = "none" -- 388
					local ____opt_21 = cardRef.current -- 388
					if ____opt_21 ~= nil then -- 388
						____opt_21:stopAllActions() -- 389
					end -- 389
					if indexRef.current then -- 389
						indexRef.current.opacity = 1 -- 390
					end -- 390
				end, -- 386
				onTapMoved = function(touch) -- 386
					drag = drag:add(touch.delta) -- 393
					if dragAxis == "none" and math.max( -- 393
						math.abs(drag.x), -- 394
						math.abs(drag.y) -- 394
					) >= 12 then -- 394
						dragAxis = math.abs(drag.x) > math.abs(drag.y) * 1.2 and "horizontal" or "vertical" -- 395
					end -- 395
					if cardRef.current then -- 395
						local offset = dragAxis == "horizontal" and Vec2(drag.x * 0.18, 0) or (dragAxis == "vertical" and Vec2(0, drag.y * 0.12) or Vec2.zero) -- 398
						cardRef.current.position = offset -- 399
						if indexRef.current then -- 399
							local headerBottom = bottom + usableHeight - 72 -- 401
							local indexTop = coverY + coverHeight - 14 + offset.y -- 402
							indexRef.current.opacity = dragAxis == "vertical" and math.max( -- 403
								0, -- 404
								math.min(1, (headerBottom - indexTop) / 16) -- 404
							) or 1 -- 404
						end -- 404
					end -- 404
				end, -- 392
				onTapEnded = function() -- 392
					local action = resolveFeedGesture(drag.x, drag.y, usableWidth, usableHeight) -- 410
					drag = Vec2.zero -- 411
					dragAxis = "none" -- 412
					if indexRef.current then -- 412
						indexRef.current.opacity = 1 -- 413
					end -- 413
					if action == "none" and cardRef.current then -- 413
						local card = cardRef.current -- 415
						card:perform(Move(App.reducedMotion and 0 or 0.16, card.position, Vec2.zero, Ease.OutQuad)) -- 416
					end -- 416
					commit(action) -- 418
				end, -- 409
				onMouseWheel = function(delta) return commit(delta.y > 0 and "previous" or "next") end -- 409
			}, -- 409
			React.createElement(VerticalGradient, {width = width, height = height, topColor = 4279310117, bottomColor = 4278716943}) -- 409
		) -- 409
		local ____createOpen_31 -- 423
		if createOpen then -- 423
			____createOpen_31 = nil -- 423
		else -- 423
			local ____temp_30 -- 423
			if item ~= nil then -- 423
				local ____React_createElement_29 = React.createElement -- 423
				local ____array_28 = __TS__SparseArrayNew( -- 423
					"node", -- 423
					{tag = "mobile-feed-card-" .. item.id, ref = cardRef, key = (tab .. "-") .. item.id}, -- 423
					__TS__ArrayMap( -- 424
						cardIndices, -- 424
						function(____, cardIndex) return React.createElement(Cover, { -- 424
							key = (tab .. "-") .. data[cardIndex + 1].id, -- 424
							entry = data[cardIndex + 1], -- 424
							x = coverX, -- 424
							y = coverY + (index - cardIndex) * usableHeight, -- 424
							width = coverWidth, -- 424
							height = coverHeight -- 424
						}) end -- 424
					) -- 424
				) -- 424
				local ____React_createElement_26 = React.createElement -- 424
				local ____temp_24 = { -- 424
					tag = "mobile-feed-index", -- 424
					ref = indexRef, -- 424
					x = coverX + coverWidth - 62, -- 424
					y = coverY + coverHeight - 40, -- 424
					width = 48, -- 424
					height = 26, -- 424
					anchorX = 0, -- 424
					anchorY = 0, -- 424
					touchEnabled = tab == "local", -- 424
					swallowTouches = tab == "local", -- 424
					onTapped = tab == "local" and openProjectIndex or nil -- 424
				} -- 424
				local ____React_createElement_result_25 = React.createElement(RoundedSurface, { -- 424
					width = 48, -- 424
					height = 26, -- 424
					radius = 13, -- 424
					topColor = 3760730173, -- 424
					bottomColor = 3759281694, -- 424
					borderWidth = 1, -- 424
					borderColor = 2286967404 -- 424
				}) -- 424
				local ____temp_23 -- 436
				if tab == "local" then -- 436
					____temp_23 = React.createElement(RoundedSurface, { -- 436
						x = 18, -- 436
						y = 2, -- 436
						width = 12, -- 436
						height = 2, -- 436
						radius = 1, -- 436
						fillColor = colors.brand -- 436
					}) -- 436
				else -- 436
					____temp_23 = nil -- 436
				end -- 436
				__TS__SparseArrayPush( -- 436
					____array_28, -- 436
					____React_createElement_26( -- 436
						"node", -- 436
						____temp_24, -- 436
						____React_createElement_result_25, -- 436
						____temp_23, -- 436
						React.createElement( -- 436
							"label", -- 436
							{ -- 436
								x = 24, -- 436
								y = 13, -- 436
								fontName = fontName, -- 436
								fontSize = 11, -- 436
								text = (tostring(index + 1) .. " / ") .. tostring(#data), -- 436
								color3 = 14146531 -- 436
							} -- 436
						) -- 436
					), -- 436
					React.createElement( -- 436
						"label", -- 436
						{ -- 436
							tag = "mobile-feed-current-title", -- 436
							x = infoX, -- 436
							y = infoTop, -- 436
							anchorX = 0, -- 436
							anchorY = 0.5, -- 436
							fontName = fontName, -- 436
							fontSize = math.floor((wide and 30 or 25) * fontScale), -- 436
							text = item.title, -- 436
							textWidth = infoWidth, -- 436
							alignment = "Left", -- 436
							color3 = 16052712 -- 436
						} -- 436
					), -- 436
					React.createElement( -- 436
						"label", -- 436
						{ -- 436
							tag = "mobile-feed-description", -- 436
							x = infoX, -- 436
							y = descriptionY, -- 436
							anchorX = 0, -- 436
							anchorY = 0.5, -- 436
							fontName = fontName, -- 436
							fontSize = math.floor(15 * fontScale), -- 436
							text = conciseDescription(item.description, wide and 80 or (compact and 28 or 42)), -- 436
							textWidth = infoWidth, -- 436
							alignment = "Left", -- 436
							color3 = 11055037 -- 436
						} -- 436
					) -- 436
				) -- 436
				local ____temp_27 -- 443
				if compact or shortLandscape then -- 443
					____temp_27 = nil -- 443
				else -- 443
					____temp_27 = React.createElement( -- 443
						"node", -- 443
						{ -- 443
							x = infoX, -- 443
							y = infoTop - 118, -- 443
							width = wide and 176 or 164, -- 443
							height = 28, -- 443
							anchorX = 0, -- 443
							anchorY = 0 -- 443
						}, -- 443
						React.createElement(RoundedSurface, { -- 443
							width = wide and 176 or 164, -- 443
							height = 28, -- 443
							radius = 14, -- 443
							topColor = 1714436683, -- 443
							bottomColor = 1712857131, -- 443
							borderWidth = 1, -- 443
							borderColor = 2288020349 -- 443
						}), -- 443
						React.createElement("label", { -- 443
							x = 12, -- 443
							y = 14, -- 443
							anchorX = 0, -- 443
							fontName = fontName, -- 443
							fontSize = 12, -- 443
							text = item.kind == "local" and (zh and "本地作品  ·  可 Remix" or "Local  ·  Remixable") or (item.installed and (zh and "发现  ·  已安装" or "Discover  ·  Installed") or (zh and "发现  ·  可安装" or "Discover  ·  Installable")), -- 443
							textWidth = (wide and 176 or 164) - 24, -- 443
							alignment = "Left", -- 443
							color3 = 14475754 -- 443
						}) -- 443
					) -- 443
				end -- 443
				__TS__SparseArrayPush( -- 443
					____array_28, -- 443
					____temp_27, -- 443
					React.createElement( -- 443
						MobileButton, -- 449
						{ -- 449
							tag = "mobile-feed-remix", -- 449
							x = infoX, -- 449
							y = actionsY, -- 449
							width = buttonWidth, -- 449
							text = zh and "Remix 作品" or "Remix game", -- 449
							fontSize = math.floor(16 * fontScale), -- 449
							primary = true, -- 449
							onTapped = function() return activate("remix") end -- 449
						} -- 449
					), -- 449
					React.createElement( -- 449
						MobileButton, -- 451
						{ -- 451
							tag = "mobile-feed-play", -- 451
							x = infoX + buttonWidth + 12, -- 451
							y = actionsY, -- 451
							width = buttonWidth, -- 451
							text = zh and "试玩" or "Play", -- 451
							fontSize = math.floor(17 * fontScale), -- 451
							onTapped = function() return activate("play") end -- 451
						} -- 451
					), -- 451
					React.createElement("label", { -- 451
						tag = "mobile-feed-gesture-hint", -- 451
						x = infoX, -- 451
						y = gestureHintY, -- 451
						anchorX = 0, -- 451
						anchorY = 0.5, -- 451
						fontName = fontName, -- 451
						fontSize = gamepadUsed and 11 or 14, -- 451
						text = prepareStatus ~= "" and prepareStatus or (item.launchError ~= nil and item.launchError or (gamepadUsed and (zh and "↑↓ 浏览 · A 确认 · X Remix · Start 列表 · Y 新建" or "↑↓ Browse · A Select · X Remix · Start List · Y New") or (zh and "上滑浏览  ·  右滑 Remix  ·  左滑试玩" or "Swipe up  ·  right Remix  ·  left Play"))), -- 451
						textWidth = infoWidth, -- 451
						alignment = "Left", -- 451
						color3 = item.launchError ~= nil and 16739179 or 11055037 -- 451
					}) -- 451
				) -- 451
				____temp_30 = ____React_createElement_29(__TS__SparseArraySpread(____array_28)) -- 451
			else -- 451
				____temp_30 = React.createElement( -- 451
					"node", -- 451
					nil, -- 451
					React.createElement("label", { -- 451
						x = left + usableWidth / 2, -- 451
						y = bottom + usableHeight / 2 + 20, -- 451
						fontName = fontName, -- 451
						fontSize = 22, -- 451
						text = tab == "discover" and (zh and "暂无移动作品" or "No mobile games yet") or (zh and "没有可运行的本地作品" or "No runnable local games"), -- 451
						color3 = 16052712 -- 451
					}), -- 451
					React.createElement("label", { -- 451
						x = left + usableWidth / 2, -- 451
						y = bottom + usableHeight / 2 - 28, -- 451
						fontName = fontName, -- 451
						fontSize = 14, -- 451
						text = tab == "discover" and discoverError ~= "" and discoverError or (zh and "切换标签或稍后重试" or "Switch tabs or retry later"), -- 451
						textWidth = usableWidth - 48, -- 451
						color3 = tab == "discover" and discoverError ~= "" and 16739179 or 11055037 -- 451
					}) -- 451
				) -- 451
			end -- 451
			____createOpen_31 = ____temp_30 -- 423
		end -- 423
		__TS__SparseArrayPush(____array_45, ____createOpen_31) -- 423
		local ____React_createElement_35 = React.createElement -- 423
		local ____array_34 = __TS__SparseArrayNew("node", {tag = "mobile-feed-header", order = headerRenderOrder}) -- 423
		local ____options_onSwitchMode_32 -- 465
		if options.onSwitchMode then -- 465
			____options_onSwitchMode_32 = React.createElement( -- 465
				"node", -- 465
				{ -- 465
					tag = "mobile-ui-mode-switch", -- 465
					x = left + 12, -- 465
					y = bottom + usableHeight - 58 + landscapeTopLift, -- 465
					width = 72, -- 465
					height = 48, -- 465
					anchorX = 0, -- 465
					anchorY = 0, -- 465
					touchEnabled = true, -- 465
					swallowTouches = true, -- 465
					onTapped = switchMode -- 465
				}, -- 465
				React.createElement("label", { -- 465
					x = 0, -- 465
					y = 30, -- 465
					anchorX = 0, -- 465
					fontName = fontName, -- 465
					fontSize = 16, -- 465
					text = "DORA", -- 465
					color3 = preparing and 7831180 or 16763955 -- 465
				}), -- 465
				React.createElement("label", { -- 465
					x = 0, -- 465
					y = 10, -- 465
					anchorX = 0, -- 465
					fontName = fontName, -- 465
					fontSize = 10, -- 465
					text = zh and "切换传统界面" or "Classic UI", -- 465
					color3 = 7831180 -- 465
				}) -- 465
			) -- 465
		else -- 465
			____options_onSwitchMode_32 = nil -- 469
		end -- 469
		__TS__SparseArrayPush( -- 469
			____array_34, -- 469
			____options_onSwitchMode_32, -- 469
			React.createElement( -- 469
				"label", -- 469
				{ -- 469
					tag = "mobile-feed-discover-tab", -- 469
					x = left + usableWidth / 2 - 44, -- 469
					y = bottom + usableHeight - 34 + landscapeTopLift, -- 469
					fontName = fontName, -- 469
					fontSize = math.floor(17 * fontScale), -- 469
					text = zh and "发现" or "Discover", -- 469
					color3 = tab == "discover" and 16763955 or 11055037, -- 469
					touchEnabled = true, -- 469
					swallowTouches = true, -- 469
					onTapped = function() return setTab("discover") end -- 469
				} -- 469
			), -- 469
			React.createElement( -- 469
				"label", -- 469
				{ -- 469
					tag = "mobile-feed-local-tab", -- 469
					x = left + usableWidth / 2 + 44, -- 469
					y = bottom + usableHeight - 34 + landscapeTopLift, -- 469
					fontName = fontName, -- 469
					fontSize = math.floor(17 * fontScale), -- 469
					text = zh and "本地" or "Local", -- 469
					color3 = tab == "local" and 16763955 or 11055037, -- 469
					touchEnabled = true, -- 469
					swallowTouches = true, -- 469
					onTapped = function() -- 469
						____local = getLocalEntries() -- 475
						setTab("local") -- 475
					end -- 475
				} -- 475
			), -- 475
			React.createElement(RoundedSurface, { -- 475
				x = left + usableWidth / 2 + (tab == "discover" and -58 or 30), -- 475
				y = bottom + usableHeight - 56 + landscapeTopLift, -- 475
				width = 28, -- 475
				height = 3, -- 475
				radius = 1.5, -- 475
				fillColor = colors.brand, -- 475
				renderOrder = headerRenderOrder + 1 -- 475
			}) -- 475
		) -- 475
		local ____temp_33 -- 477
		if tab == "local" and options.createProject then -- 477
			____temp_33 = React.createElement(MobileNewButton, { -- 477
				tag = "mobile-feed-create", -- 477
				x = left + usableWidth - 82, -- 477
				y = bottom + usableHeight - 56 + landscapeTopLift, -- 477
				text = zh and "+ 新建" or "+ New", -- 477
				renderOrder = headerRenderOrder + 1, -- 477
				onTapped = openCreate -- 477
			}) -- 477
		else -- 477
			____temp_33 = nil -- 479
		end -- 479
		__TS__SparseArrayPush(____array_34, ____temp_33) -- 479
		__TS__SparseArrayPush( -- 479
			____array_45, -- 479
			____React_createElement_35(__TS__SparseArraySpread(____array_34)) -- 479
		) -- 479
		local ____createOpen_43 -- 481
		if createOpen then -- 481
			____createOpen_43 = (function() -- 481
				local sheetHeight = math.min(createSheetHeight, usableHeight - 64) -- 482
				local sheetWidth = usableWidth -- 483
				local contentWidth = sheetWidth - 40 -- 484
				local actionGap = 12 -- 485
				local actionsWidth = shortLandscape and math.min( -- 486
					300, -- 486
					math.floor(contentWidth * 0.42) -- 486
				) or contentWidth -- 486
				local inputWidth = shortLandscape and contentWidth - actionGap - actionsWidth or contentWidth -- 487
				local actionX = shortLandscape and 20 + inputWidth + actionGap or 20 -- 488
				local actionY = shortLandscape and sheetHeight - createInputTop - createInputHeight or 20 -- 489
				local cancelWidth = math.floor((actionsWidth - actionGap) * (shortLandscape and 0.34 or 0.38)) -- 490
				local ____React_createElement_42 = React.createElement -- 490
				local ____array_41 = __TS__SparseArrayNew( -- 490
					"node", -- 490
					{ -- 490
						tag = "mobile-project-create-sheet", -- 490
						order = 10000, -- 490
						width = width, -- 490
						height = height, -- 490
						anchorX = 0, -- 490
						anchorY = 0, -- 490
						touchEnabled = true, -- 490
						swallowTouches = true -- 490
					}, -- 490
					React.createElement( -- 490
						"node", -- 490
						{ -- 490
							tag = "mobile-project-create-focus-observer", -- 490
							order = 1000, -- 490
							width = width, -- 490
							height = height, -- 490
							anchorX = 0, -- 490
							anchorY = 0, -- 490
							touchEnabled = true, -- 490
							swallowTouches = false, -- 490
							swallowMouseWheel = false, -- 490
							onTapFilter = function(touch) -- 490
								touch.enabled = false -- 494
								if not canEditCreate() then -- 494
									return -- 495
								end -- 495
								local input = createInputRef.current -- 496
								local point = input and input:convertToNodeSpace(touch.worldLocation) -- 497
								local inside = input and point and point.x >= 0 and point.y >= 0 and point.x <= input.width and point.y <= input.height -- 498
								dismissedCreateComposition = not inside and createInput.isComposing() -- 499
								if not inside then -- 499
									blurCreateInput() -- 500
								end -- 500
							end -- 493
						} -- 493
					), -- 493
					React.createElement( -- 493
						"draw-node", -- 493
						{ -- 493
							tag = "mobile-project-create-backdrop", -- 493
							order = 0, -- 493
							renderOrder = 0, -- 493
							x = width / 2, -- 493
							y = bottom + sheetHeight + (height - bottom - sheetHeight) / 2 -- 493
						}, -- 493
						React.createElement("rect-shape", {width = width, height = height - bottom - sheetHeight, fillColor = 2348810240}) -- 493
					) -- 493
				) -- 493
				local ____React_createElement_40 = React.createElement -- 493
				local ____array_39 = __TS__SparseArrayNew( -- 493
					"node", -- 493
					{ -- 493
						ref = createPanelRef, -- 493
						order = 10, -- 493
						renderOrder = 10, -- 493
						x = left, -- 493
						y = bottom, -- 493
						width = sheetWidth, -- 493
						height = sheetHeight, -- 493
						anchorX = 0, -- 493
						anchorY = 0, -- 493
						touchEnabled = true, -- 493
						swallowTouches = true -- 493
					}, -- 493
					React.createElement(MobilePanelSurface, {width = sheetWidth, height = sheetHeight, renderOrder = 10}), -- 493
					React.createElement("label", { -- 493
						x = 20, -- 493
						y = sheetHeight - 24, -- 493
						anchorX = 0, -- 493
						anchorY = 1, -- 493
						fontName = fontName, -- 493
						fontSize = 22, -- 493
						text = zh and "新建项目" or "New project", -- 493
						color3 = 16052712 -- 493
					}), -- 493
					React.createElement("label", { -- 493
						x = 20, -- 493
						y = sheetHeight - 66, -- 493
						anchorX = 0, -- 493
						anchorY = 1, -- 493
						fontName = fontName, -- 493
						fontSize = 14, -- 493
						text = zh and "项目名称" or "Project name", -- 493
						color3 = 11055037 -- 493
					}) -- 493
				) -- 493
				local ____keptInput_38 -- 509
				if keptInput then -- 509
					____keptInput_38 = nil -- 509
				else -- 509
					____keptInput_38 = React.createElement("node", { -- 509
						tag = "mobile-project-create-input", -- 509
						ref = createInputRef, -- 509
						renderOrder = 10, -- 509
						x = 20, -- 509
						y = sheetHeight - createInputTop - createInputHeight, -- 509
						width = inputWidth, -- 509
						height = createInputHeight, -- 509
						anchorX = 0, -- 509
						anchorY = 0, -- 509
						onMount = createInput.mount -- 509
					}) -- 509
				end -- 509
				__TS__SparseArrayPush( -- 509
					____array_39, -- 509
					____keptInput_38, -- 509
					React.createElement("label", { -- 509
						tag = "mobile-project-create-error", -- 509
						x = 20, -- 509
						y = shortLandscape and sheetHeight - createInputTop + 12 or sheetHeight - createInputTop - createInputHeight - 12, -- 509
						anchorX = 0, -- 509
						anchorY = 1, -- 509
						fontName = fontName, -- 509
						fontSize = 12, -- 509
						text = createError ~= "" and createError or (zh and "将创建可运行的 TypeScript 起始项目" or "Creates a runnable TypeScript starter project"), -- 509
						textWidth = inputWidth, -- 509
						alignment = "Left", -- 509
						color3 = createError ~= "" and 16739179 or 11055037 -- 509
					}), -- 509
					React.createElement(MobileButton, { -- 509
						tag = "mobile-project-create-cancel", -- 509
						x = actionX, -- 509
						y = actionY, -- 509
						width = cancelWidth, -- 509
						text = zh and "取消" or "Cancel", -- 509
						renderOrder = 10, -- 509
						onTapped = closeCreate -- 509
					}), -- 509
					React.createElement( -- 509
						MobileButton, -- 515
						{ -- 515
							tag = "mobile-project-create-submit", -- 515
							x = actionX + cancelWidth + actionGap, -- 515
							y = actionY, -- 515
							width = actionsWidth - cancelWidth - actionGap, -- 515
							text = creating and (zh and "创建中…" or "Creating…") or (zh and "创建并进入 Remix" or "Create and Remix"), -- 515
							primary = true, -- 515
							renderOrder = 10, -- 515
							onTapped = function() -- 515
								if not dismissedCreateComposition then -- 515
									submitCreate() -- 516
								end -- 516
								dismissedCreateComposition = false -- 516
							end -- 516
						} -- 516
					) -- 516
				) -- 516
				__TS__SparseArrayPush( -- 516
					____array_41, -- 516
					____React_createElement_40(__TS__SparseArraySpread(____array_39)) -- 516
				) -- 516
				return ____React_createElement_42(__TS__SparseArraySpread(____array_41)) -- 491
			end)() -- 481
		else -- 481
			____createOpen_43 = nil -- 519
		end -- 519
		__TS__SparseArrayPush(____array_45, ____createOpen_43) -- 519
		local ____projectIndexOpen_44 -- 520
		if projectIndexOpen then -- 520
			____projectIndexOpen_44 = React.createElement( -- 520
				ProjectIndex, -- 520
				{ -- 520
					entries = ____local, -- 520
					current = current(), -- 520
					x = left, -- 520
					y = bottom, -- 520
					width = usableWidth, -- 520
					height = usableHeight, -- 520
					zh = zh, -- 520
					onClose = function() -- 520
						projectIndexOpen = false -- 521
						render() -- 521
					end, -- 521
					onSelect = function(____, entry) -- 521
						projectIndexOpen = false -- 523
						local location = resolveFeedLocation(____local, discover, entry) -- 524
						tab = "local" -- 525
						index = location.tab == "local" and location.index or 0 -- 525
						render() -- 526
					end -- 522
				} -- 522
			) -- 522
		else -- 522
			____projectIndexOpen_44 = nil -- 527
		end -- 527
		__TS__SparseArrayPush(____array_45, ____projectIndexOpen_44) -- 527
		local scene = ____toNode_47(____React_createElement_46(__TS__SparseArraySpread(____array_45))) -- 377
		if scene ~= nil then -- 377
			host:addChild(scene) -- 529
		end -- 529
		if keptInput and createPanelRef.current then -- 529
			keptInput.position = Vec2( -- 531
				20, -- 531
				math.min(createSheetHeight, usableHeight - 64) - createInputTop - createInputHeight -- 531
			) -- 531
			createPanelRef.current:addChild(keptInput) -- 532
		end -- 532
		createInput.refresh() -- 534
		if restoreFocus and not keptInput and createOpen then -- 534
			createInput.focus(false) -- 535
		end -- 535
	end -- 326
	attachGamepad( -- 538
		host, -- 538
		{ -- 538
			initialTag = "mobile-feed-play", -- 539
			isEnabled = function() return isActive() and not preparing and not transitioning and not creating end, -- 540
			onActive = function() -- 541
				gamepadUsed = true -- 541
				render() -- 541
			end, -- 541
			onBack = function() -- 542
				if createInput.isFocused() then -- 542
					blurCreateInput() -- 542
				elseif createOpen then -- 542
					closeCreate() -- 542
				else -- 542
					switchMode() -- 542
				end -- 542
			end, -- 542
			onActivate = function(target) -- 543
				if target.tag == "mobile-project-create-input" then -- 543
					target:emit("GamepadActivate") -- 544
				else -- 544
					if createInput.isComposing() then -- 544
						blurCreateInput() -- 546
						return -- 546
					end -- 546
					blurCreateInput() -- 547
					dismissedCreateComposition = false -- 548
					target:emit("Tapped") -- 549
				end -- 549
			end, -- 543
			onButton = function(button) -- 552
				if createOpen then -- 552
					return false -- 553
				end -- 553
				repeat -- 553
					local ____switch107 = button -- 553
					local ____cond107 = ____switch107 == "dpup" -- 553
					if ____cond107 then -- 553
						commit("previous") -- 555
						return true -- 555
					end -- 555
					____cond107 = ____cond107 or ____switch107 == "dpdown" -- 555
					if ____cond107 then -- 555
						commit("next") -- 556
						return true -- 556
					end -- 556
					____cond107 = ____cond107 or ____switch107 == "leftshoulder" -- 556
					if ____cond107 then -- 556
						setTab("discover") -- 557
						return true -- 557
					end -- 557
					____cond107 = ____cond107 or ____switch107 == "rightshoulder" -- 557
					if ____cond107 then -- 557
						setTab("local") -- 558
						return true -- 558
					end -- 558
					____cond107 = ____cond107 or ____switch107 == "x" -- 558
					if ____cond107 then -- 558
						commit("remix") -- 559
						return true -- 559
					end -- 559
					____cond107 = ____cond107 or ____switch107 == "y" -- 559
					if ____cond107 then -- 559
						local ____opt_48 = findGamepadNode(host, "mobile-feed-create") -- 559
						if ____opt_48 ~= nil then -- 559
							____opt_48:emit("Tapped") -- 560
						end -- 560
						return true -- 560
					end -- 560
					____cond107 = ____cond107 or ____switch107 == "start" -- 560
					if ____cond107 then -- 560
						openProjectIndex() -- 561
						return true -- 561
					end -- 561
					do -- 561
						return false -- 562
					end -- 562
				until true -- 562
			end -- 552
		} -- 552
	) -- 552
	host:onAppChange(function(setting) -- 566
		if setting == "Locale" then -- 566
			local activeEntry = current() -- 568
			zh = (string.match(App.locale, "^zh")) ~= nil -- 569
			____local = getLocalEntries() -- 570
			discover = getDiscoverEntries() -- 571
			local location = resolveFeedLocation(____local, discover, activeEntry) -- 572
			tab = location.tab -- 573
			index = location.index -- 574
			render() -- 575
		elseif setting == "Size" then -- 575
			render() -- 576
		end -- 576
	end) -- 566
	host:onAppEvent(function(event) -- 578
		if event == "BackButton" then -- 578
			if projectIndexOpen then -- 578
				projectIndexOpen = false -- 580
				render() -- 580
			elseif createOpen and not creating then -- 580
				closeCreate() -- 581
			end -- 581
		elseif event == "WillEnterBackground" or event == "DidEnterBackground" then -- 581
			blurCreateInput() -- 582
		end -- 582
	end) -- 578
	host:onCleanup(function() -- 584
		blurCreateInput() -- 584
		active = false -- 584
	end) -- 584
	host:slot( -- 585
		"RestoreFeedEntry", -- 585
		function(entry) -- 585
			if not isActive() or HttpServer.wsConnectionCount > 0 then -- 585
				return -- 586
			end -- 586
			returnEntry = entry -- 587
			____local = getLocalEntries() -- 588
			discover = getDiscoverEntries() -- 589
			local location = resolveFeedLocation(____local, discover, entry) -- 590
			tab = location.tab -- 591
			index = location.index -- 592
			render() -- 593
		end -- 585
	) -- 585
	host:slot("SuspendLocalUI", blurCreateInput) -- 595
	host:slot( -- 596
		"ResumeLocalUI", -- 596
		function() -- 596
			leaving = false -- 596
			render() -- 596
		end -- 596
	) -- 596
	render() -- 597
	if syncDiscover then -- 597
		if #discover == 0 then -- 597
			discoverError = zh and "正在同步资源目录…" or "Syncing Catalog…" -- 600
			render() -- 601
		end -- 601
		syncDiscover( -- 603
			function(message) -- 603
				if not isActive() or #discover > 0 then -- 603
					return -- 604
				end -- 604
				discoverError = message -- 605
				render() -- 606
			end, -- 603
			function(success, message) -- 607
				if not isActive() then -- 607
					return -- 608
				end -- 608
				local selected = returnEntry or rememberedEntries[tab] or current() -- 609
				local previousCount = #discover -- 610
				discover = getDiscoverEntries() -- 611
				discoverError = success and (#discover == 0 and (zh and "目录中暂无可运行作品" or "No runnable Catalog games") or "") or (message or (zh and "资源目录同步失败" or "Catalog sync failed")) -- 612
				tab = resolveDiscoverRefreshTab( -- 615
					tab, -- 615
					userSelectedTab, -- 615
					previousCount, -- 615
					#discover, -- 615
					#____local -- 615
				) -- 615
				if selected ~= nil then -- 615
					local location = resolveFeedLocation(____local, discover, selected) -- 617
					tab = location.tab -- 618
					index = location.index -- 619
				end -- 619
				if tab == "discover" then -- 619
					index = normalizeFeedIndex(index, #discover) -- 621
				end -- 621
				render() -- 622
			end -- 607
		) -- 607
	end -- 607
	return host -- 625
end -- 95
return ____exports -- 95