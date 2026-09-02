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
local ____Controls = require("Dev.Mobile.Controls") -- 7
local MobileButton = ____Controls.MobileButton -- 7
local MobilePanelSurface = ____Controls.MobilePanelSurface -- 7
local ____Visual = require("Dev.Mobile.Visual") -- 8
local RoundedStencil = ____Visual.RoundedStencil -- 8
local RoundedSurface = ____Visual.RoundedSurface -- 8
local VerticalGradient = ____Visual.VerticalGradient -- 8
local colors = { -- 30
	background = 4278914322, -- 31
	panel = 4279572770, -- 32
	panelRaised = 4280297010, -- 33
	text = 4294242792, -- 34
	muted = 4289245117, -- 35
	brand = 4294954035, -- 36
	border = 4281613128, -- 37
	danger = 4294929259 -- 38
} -- 38
local fontName = "sarasa-mono-sc-regular" -- 41
local createSheetHeight = 260 -- 42
local createInputHeight = 44 -- 43
local createInputTop = 96 -- 44
local function conciseDescription(text, limit) -- 46
	local length = (utf8.len(text)) or 0 -- 47
	if length <= limit then -- 47
		return text -- 48
	end -- 48
	local stop = utf8.offset(text, limit + 1) or #text + 1 -- 49
	return string.sub(text, 1, stop - 1) .. "…" -- 50
end -- 46
local function Cover(props) -- 53
	local file = props.entry.bannerFile -- 54
	local function scaleSprite(sprite, mode) -- 55
		local scales = getCoverScales(sprite.width, sprite.height, props.width, props.height) -- 56
		sprite.scaleX = scales[mode] -- 57
		sprite.scaleY = scales[mode] -- 58
	end -- 55
	local ____React_createElement_5 = React.createElement -- 55
	local ____temp_3 = { -- 55
		x = props.x, -- 55
		y = props.y, -- 55
		width = props.width, -- 55
		height = props.height, -- 55
		anchorX = 0, -- 55
		anchorY = 0 -- 55
	} -- 55
	local ____React_createElement_result_4 = React.createElement( -- 55
		RoundedSurface, -- 61
		{ -- 61
			width = props.width, -- 61
			height = props.height, -- 61
			radius = 22, -- 61
			topColor = stableCoverColor(props.entry.id), -- 61
			bottomColor = 4279310115, -- 61
			shadow = true -- 61
		} -- 61
	) -- 61
	local ____file_0 -- 63
	if file then -- 63
		____file_0 = React.createElement( -- 63
			"clip-node", -- 63
			{ -- 63
				width = props.width, -- 63
				height = props.height, -- 63
				anchorX = 0, -- 63
				anchorY = 0, -- 63
				stencil = React.createElement(RoundedStencil, {width = props.width, height = props.height, radius = 22}) -- 63
			}, -- 63
			React.createElement( -- 63
				"sprite", -- 63
				{ -- 63
					file = file, -- 63
					x = props.width / 2 - 5, -- 63
					y = props.height / 2, -- 63
					opacity = 0.08, -- 63
					onMount = function(sprite) return scaleSprite(sprite, "cover") end -- 63
				} -- 63
			), -- 63
			React.createElement( -- 63
				"sprite", -- 63
				{ -- 63
					file = file, -- 63
					x = props.width / 2 + 5, -- 63
					y = props.height / 2, -- 63
					opacity = 0.08, -- 63
					onMount = function(sprite) return scaleSprite(sprite, "cover") end -- 63
				} -- 63
			), -- 63
			React.createElement( -- 63
				"sprite", -- 63
				{ -- 63
					file = file, -- 63
					x = props.width / 2, -- 63
					y = props.height / 2 - 5, -- 63
					opacity = 0.08, -- 63
					onMount = function(sprite) return scaleSprite(sprite, "cover") end -- 63
				} -- 63
			), -- 63
			React.createElement( -- 63
				"draw-node", -- 63
				{x = props.width / 2, y = props.height / 2}, -- 63
				React.createElement("rect-shape", {width = props.width, height = props.height, fillColor = 2953514258}) -- 63
			), -- 63
			React.createElement( -- 63
				"sprite", -- 63
				{ -- 63
					file = file, -- 63
					x = props.width / 2, -- 63
					y = props.height / 2, -- 63
					onMount = function(sprite) return scaleSprite(sprite, "contain") end -- 63
				} -- 63
			) -- 63
		) -- 63
	else -- 63
		____file_0 = React.createElement( -- 63
			"label", -- 63
			{ -- 63
				x = props.width / 2, -- 63
				y = props.height / 2 + 10, -- 63
				fontName = fontName, -- 63
				fontSize = math.floor(math.max( -- 63
					22, -- 75
					math.min(34, props.width / 12) -- 75
				)), -- 75
				text = props.entry.title, -- 75
				textWidth = props.width - 40, -- 75
				color3 = 16052712 -- 75
			} -- 75
		) -- 75
	end -- 75
	local ____file_1 -- 80
	if file then -- 80
		____file_1 = nil -- 80
	else -- 80
		____file_1 = React.createElement("label", { -- 80
			x = props.width / 2, -- 80
			y = 30, -- 80
			fontName = fontName, -- 80
			fontSize = 14, -- 80
			text = "DORA SSR · REMIXABLE", -- 80
			color3 = 16763955 -- 80
		}) -- 80
	end -- 80
	local ____file_2 -- 88
	if file then -- 88
		____file_2 = nil -- 88
	else -- 88
		____file_2 = React.createElement(DoraMascot, {state = "idle", x = props.width - 46, y = 64, size = 42}) -- 88
	end -- 88
	return ____React_createElement_5( -- 60
		"node", -- 60
		____temp_3, -- 60
		____React_createElement_result_4, -- 60
		____file_0, -- 60
		____file_1, -- 60
		____file_2, -- 60
		React.createElement(RoundedSurface, { -- 60
			width = props.width, -- 60
			height = props.height, -- 60
			radius = 22, -- 60
			fillColor = 0, -- 60
			borderWidth = 1, -- 60
			borderColor = 4282074454 -- 60
		}) -- 60
	) -- 60
end -- 53
function ____exports.startMobileFeed(options) -- 93
	local submitCreate, render -- 93
	local getLocalEntries = options.getLocalEntries -- 94
	local getDiscoverEntries = options.getDiscoverEntries -- 95
	local onPlay = options.onPlay -- 96
	local onRemix = options.onRemix -- 97
	local prepare = options.prepare -- 98
	local syncDiscover = options.syncDiscover -- 99
	local zh = (string.match(App.locale, "^zh")) ~= nil -- 100
	local tab = "local" -- 101
	local index = 0 -- 102
	local drag = Vec2.zero -- 103
	local dragAxis = "none" -- 104
	local discoverError = "" -- 105
	local preparing = false -- 106
	local transitioning = false -- 107
	local prepareStatus = "" -- 108
	local repairResourceId = "" -- 109
	local userSelectedTab = false -- 110
	local active = true -- 111
	local leaving = false -- 112
	local createOpen = false -- 113
	local creating = false -- 114
	local createName = "" -- 115
	local dismissedCreateComposition = false -- 116
	local createError = "" -- 117
	local returnEntry = options.initialEntry -- 118
	local ____opt_6 = options.initialEntries -- 118
	local ____temp_10 = ____opt_6 and ____opt_6["local"] -- 120
	local ____opt_8 = options.initialEntries -- 120
	local rememberedEntries = {["local"] = ____temp_10, discover = ____opt_8 and ____opt_8.discover} -- 119
	local cardRef = reference() -- 123
	local indexRef = reference() -- 124
	local createInputRef = reference() -- 125
	local discover = getDiscoverEntries() -- 126
	local ____local = getLocalEntries() -- 127
	if #discover == 0 then -- 127
		discoverError = zh and "资源目录暂不可用" or "Catalog is unavailable" -- 130
	end -- 130
	local initialLocation = resolveFeedLocation(____local, discover, returnEntry) -- 132
	tab = initialLocation.tab -- 133
	index = initialLocation.index -- 134
	local host = Node() -- 136
	host.tag = "mobile-feed" -- 137
	host.scaleX = App.devicePixelRatio -- 138
	host.scaleY = App.devicePixelRatio -- 139
	host:addTo(Director.systemUI) -- 140
	local function isActive() -- 142
		return active and not leaving and host.parent ~= nil -- 142
	end -- 142
	local function entries() -- 144
		return tab == "discover" and discover or ____local -- 144
	end -- 144
	local function current() -- 145
		return entries()[normalizeFeedIndex( -- 145
			index, -- 145
			#entries() -- 145
		) + 1] -- 145
	end -- 145
	local rememberedEntryKey = "" -- 146
	local function rememberCurrent() -- 147
		local item = current() -- 148
		if not item or not options.onCurrentEntryChanged then -- 148
			return -- 149
		end -- 149
		local key = (((((item.kind .. "\n") .. item.id) .. "\n") .. (item.workDir or "")) .. "\n") .. (item.fileName or "") -- 150
		if key == rememberedEntryKey then -- 150
			return -- 151
		end -- 151
		rememberedEntryKey = key -- 152
		rememberedEntries[item.kind] = item -- 153
		options.onCurrentEntryChanged(item) -- 154
	end -- 147
	local function canEditCreate() -- 156
		return createOpen and not creating and isActive() and host.visible and HttpServer.wsConnectionCount == 0 -- 156
	end -- 156
	local createInput = createTextInput({ -- 157
		fontSize = math.floor(16 * mobileFontScale), -- 158
		singleLine = true, -- 159
		background = colors.background, -- 160
		getText = function() return createName end, -- 161
		setText = function(text) -- 162
			createName = text -- 162
		end, -- 162
		getPlaceholder = function() return zh and "例如：星际花园" or "For example: Star Garden" end, -- 163
		isEnabled = canEditCreate, -- 164
		onReturn = function() -- 165
			submitCreate() -- 165
			return true -- 165
		end -- 165
	}) -- 165
	local blurCreateInput = createInput.blur -- 167
	local function closeCreate() -- 168
		if creating then -- 168
			return -- 169
		end -- 169
		blurCreateInput() -- 170
		createOpen = false -- 171
		createName = "" -- 172
		createError = "" -- 173
		render() -- 174
	end -- 168
	local function createErrorText(____error) -- 176
		repeat -- 176
			local ____switch26 = ____error -- 176
			local ____cond26 = ____switch26 == "invalid-name" -- 176
			if ____cond26 then -- 176
				return zh and "请输入不含路径分隔符的项目名称" or "Enter a project name without path separators" -- 178
			end -- 178
			____cond26 = ____cond26 or ____switch26 == "target-existed" -- 178
			if ____cond26 then -- 178
				return zh and "已有同名项目，请换一个名称" or "A project with that name already exists" -- 179
			end -- 179
			____cond26 = ____cond26 or ____switch26 == "create-folder-failed" -- 179
			if ____cond26 then -- 179
				return zh and "无法创建项目目录，请检查工作目录后重试" or "Could not create the project folder; check the workspace and retry" -- 180
			end -- 180
			____cond26 = ____cond26 or ____switch26 == "create-entry-failed" -- 180
			if ____cond26 then -- 180
				return zh and "无法写入项目入口，未完成项目已回滚" or "Could not write the project entry; the incomplete project was rolled back" -- 181
			end -- 181
			____cond26 = ____cond26 or ____switch26 == "created-project-not-found" -- 181
			if ____cond26 then -- 181
				return zh and "项目已创建，但本地列表未能找到它，请返回后重试" or "The project was created but could not be found in Local; return and retry" -- 182
			end -- 182
			do -- 182
				return zh and "创建失败，请重试" or "Project creation failed; try again" -- 183
			end -- 183
		until true -- 183
	end -- 176
	submitCreate = function() -- 186
		if not options.createProject or creating or not createOpen or not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 then -- 186
			return -- 187
		end -- 187
		if createInput.isComposing() then -- 187
			return -- 188
		end -- 188
		creating = true -- 189
		createError = "" -- 190
		blurCreateInput() -- 191
		render() -- 192
		local result = options.createProject(createName) -- 193
		if not isActive() then -- 193
			return -- 194
		end -- 194
		creating = false -- 195
		if not result.success then -- 195
			createError = createErrorText(result.error) -- 197
			render() -- 198
			return -- 199
		end -- 199
		createOpen = false -- 201
		createName = "" -- 202
		____local = getLocalEntries() -- 203
		returnEntry = result.entry -- 204
		local location = resolveFeedLocation(____local, discover, result.entry) -- 205
		tab = location.tab -- 206
		index = location.index -- 207
		render() -- 208
		onRemix(result.entry) -- 209
	end -- 186
	local function setTab(next) -- 212
		if not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 or preparing or creating then -- 212
			return -- 213
		end -- 213
		userSelectedTab = true -- 214
		returnEntry = nil -- 215
		if tab == next then -- 215
			return -- 216
		end -- 216
		if createOpen then -- 216
			blurCreateInput() -- 218
			createOpen = false -- 219
			createName = "" -- 220
			createError = "" -- 221
		end -- 221
		tab = next -- 223
		local target = rememberedEntries[next] -- 224
		local ____temp_11 -- 225
		if target == nil then -- 225
			____temp_11 = nil -- 225
		else -- 225
			____temp_11 = resolveFeedLocation(____local, discover, target) -- 225
		end -- 225
		local location = ____temp_11 -- 225
		index = (location and location.tab) == next and location.index or 0 -- 226
		render() -- 227
	end -- 212
	local function activate(action) -- 229
		local item = current() -- 230
		if not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 or not item or preparing then -- 230
			return -- 231
		end -- 231
		item.launchError = nil -- 232
		local function done() -- 233
			returnEntry = item -- 233
			local ____temp_14 -- 233
			if action == "play" then -- 233
				____temp_14 = onPlay(item) -- 233
			else -- 233
				____temp_14 = onRemix(item) -- 233
			end -- 233
			return ____temp_14 -- 233
		end -- 233
		if item.kind == "local" or item.installed then -- 233
			done() -- 234
			return -- 234
		end -- 234
		preparing = true -- 235
		prepareStatus = zh and "准备安装…" or "Preparing install…" -- 236
		render() -- 237
		local repairIncomplete = repairResourceId == item.id -- 238
		repairResourceId = "" -- 239
		prepare( -- 240
			item, -- 240
			repairIncomplete, -- 240
			function(progress, message) -- 240
				if not isActive() then -- 240
					return -- 241
				end -- 241
				prepareStatus = (tostring(math.floor(progress * 100)) .. "% · ") .. message -- 242
				render() -- 243
			end, -- 240
			function(success, ready, message, repairable) -- 244
				if not isActive() then -- 244
					return -- 245
				end -- 245
				preparing = false -- 246
				if not success or not ready then -- 246
					repairResourceId = repairable and item.id or "" -- 248
					prepareStatus = message or (zh and "安装失败，点击按钮重试" or "Install failed; tap to retry") -- 249
					render() -- 250
					return -- 251
				end -- 251
				item.fileName = ready.fileName -- 253
				item.workDir = ready.workDir -- 254
				item.installed = true -- 255
				prepareStatus = "" -- 256
				if HttpServer.wsConnectionCount == 0 and host.visible then -- 256
					done() -- 257
				else -- 257
					render() -- 258
				end -- 258
			end -- 244
		) -- 244
	end -- 229
	local function commit(action) -- 262
		if not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 or preparing or transitioning then -- 262
			return -- 263
		end -- 263
		if action == "play" or action == "remix" then -- 263
			local card = cardRef.current -- 265
			if card then -- 265
				card.position = Vec2.zero -- 266
			end -- 266
		end -- 266
		repeat -- 266
			local ____switch51 = action -- 266
			local ____cond51 = ____switch51 == "previous" or ____switch51 == "next" -- 266
			if ____cond51 then -- 266
				do -- 266
					returnEntry = nil -- 271
					local target = normalizeFeedIndex( -- 272
						index + (action == "next" and 1 or -1), -- 272
						#entries() -- 272
					) -- 272
					if target == index then -- 272
						local card = cardRef.current -- 274
						if card then -- 274
							card:perform(Move(App.reducedMotion and 0 or 0.16, card.position, Vec2.zero, Ease.OutQuad)) -- 275
						end -- 275
						return -- 276
					end -- 276
					local duration = App.reducedMotion and 0 or 0.18 -- 278
					local function finish() -- 279
						if not isActive() then -- 279
							return -- 280
						end -- 280
						index = target -- 281
						transitioning = false -- 282
						App:vibrate(0.012) -- 283
						render() -- 284
					end -- 279
					local card = cardRef.current -- 286
					if duration > 0 and card then -- 286
						transitioning = true -- 288
						card:perform(Move( -- 289
							duration, -- 289
							card.position, -- 289
							Vec2(0, (action == "next" and 1 or -1) * App.safeArea.height), -- 289
							Ease.OutQuad -- 289
						)) -- 289
						thread(function() -- 290
							sleep(duration) -- 290
							finish() -- 290
						end) -- 290
					else -- 290
						finish() -- 291
					end -- 291
					return -- 292
				end -- 292
			end -- 292
			____cond51 = ____cond51 or ____switch51 == "play" -- 292
			if ____cond51 then -- 292
				activate("play") -- 294
				return -- 294
			end -- 294
			____cond51 = ____cond51 or ____switch51 == "remix" -- 294
			if ____cond51 then -- 294
				activate("remix") -- 295
				return -- 295
			end -- 295
			do -- 295
				return -- 296
			end -- 296
		until true -- 296
	end -- 262
	local function switchMode() -- 300
		if not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 or preparing or creating or createOpen or transitioning or not options.onSwitchMode then -- 300
			return -- 301
		end -- 301
		leaving = true -- 302
		options.onSwitchMode() -- 303
	end -- 300
	host:slot("SwitchUIMode", switchMode) -- 305
	render = function() -- 306
		if not isActive() then -- 306
			return -- 307
		end -- 307
		local safeContentWidth = App.safeArea.width - 40 -- 309
		local shortLandscapeInputWidth = safeContentWidth - 12 - math.min( -- 310
			300, -- 310
			math.floor(safeContentWidth * 0.42) -- 310
		) -- 310
		local expectedInputWidth = App.safeArea.width >= 760 and App.safeArea.height < 500 and shortLandscapeInputWidth or safeContentWidth -- 311
		local ____createOpen_17 = createOpen -- 312
		if ____createOpen_17 then -- 312
			local ____opt_15 = createInputRef.current -- 312
			____createOpen_17 = (____opt_15 and ____opt_15.width) == expectedInputWidth -- 312
		end -- 312
		local keptInput = ____createOpen_17 and createInputRef.current or nil -- 312
		local restoreFocus = createInput.isFocused() -- 313
		if keptInput ~= nil then -- 313
			keptInput:removeFromParent(false) -- 314
		end -- 314
		if not keptInput then -- 314
			createInput.unmount() -- 316
			createInputRef = reference() -- 317
		end -- 317
		local createPanelRef = reference() -- 319
		host:removeAllChildren() -- 320
		host.scaleX = App.devicePixelRatio -- 321
		host.scaleY = App.devicePixelRatio -- 322
		local ____App_visualSize_20 = App.visualSize -- 323
		local width = ____App_visualSize_20.width -- 323
		local height = ____App_visualSize_20.height -- 323
		local safe = App.safeArea -- 324
		local left = safe.left -- 325
		local bottom = safe.bottom -- 326
		local usableWidth = safe.width -- 327
		local usableHeight = safe.height -- 328
		local wide = usableWidth >= 760 -- 329
		local shortLandscape = wide and usableHeight < 500 -- 330
		local compact = not wide and usableHeight < 700 -- 331
		local landscapeTopLift = shortLandscape and 28 or 0 -- 332
		local data = entries() -- 333
		index = normalizeFeedIndex(index, #data) -- 334
		local item = current() -- 335
		rememberCurrent() -- 336
		local coverWidth = wide and math.min(usableWidth * 0.54, 680) or usableWidth - 32 -- 337
		local coverHeight = wide and math.min(usableHeight - 118, coverWidth * 0.72) or (compact and math.min(usableHeight * 0.49, coverWidth * 0.72) or math.min(usableHeight * 0.54, coverWidth * 1.12)) -- 338
		local coverX = left + 16 -- 343
		local coverY = wide and bottom + (usableHeight - coverHeight) / 2 - 12 + landscapeTopLift or bottom + usableHeight - coverHeight - 82 -- 344
		local infoX = wide and coverX + coverWidth + 28 or left + 20 -- 345
		local infoWidth = wide and usableWidth - coverWidth - 72 or usableWidth - 40 -- 346
		local infoTop = wide and bottom + usableHeight - 122 + landscapeTopLift or coverY - 30 -- 347
		local buttonWidth = wide and math.min(190, (infoWidth - 12) / 2) or (infoWidth - 12) / 2 -- 348
		local fontScale = mobileFontScale -- 349
		local cardIndices = getReusableCardIndices(index, #data) -- 350
		local headerRenderOrder = 1000 -- 351
		local ____toNode_42 = toNode -- 353
		local ____React_createElement_41 = React.createElement -- 353
		local ____array_40 = __TS__SparseArrayNew( -- 353
			"node", -- 353
			{ -- 353
				tag = "mobile-feed-scene", -- 353
				x = -width / 2, -- 353
				y = -height / 2, -- 353
				width = width, -- 353
				height = height, -- 353
				anchorX = 0, -- 353
				anchorY = 0, -- 353
				touchEnabled = true, -- 353
				onTapBegan = function() -- 353
					drag = Vec2.zero -- 363
					dragAxis = "none" -- 364
					local ____opt_21 = cardRef.current -- 364
					if ____opt_21 ~= nil then -- 364
						____opt_21:stopAllActions() -- 365
					end -- 365
					if indexRef.current then -- 365
						indexRef.current.opacity = 1 -- 366
					end -- 366
				end, -- 362
				onTapMoved = function(touch) -- 362
					drag = drag:add(touch.delta) -- 369
					if dragAxis == "none" and math.max( -- 369
						math.abs(drag.x), -- 370
						math.abs(drag.y) -- 370
					) >= 12 then -- 370
						dragAxis = math.abs(drag.x) > math.abs(drag.y) * 1.2 and "horizontal" or "vertical" -- 371
					end -- 371
					if cardRef.current then -- 371
						local offset = dragAxis == "horizontal" and Vec2(drag.x * 0.18, 0) or (dragAxis == "vertical" and Vec2(0, drag.y * 0.12) or Vec2.zero) -- 374
						cardRef.current.position = offset -- 375
						if indexRef.current then -- 375
							local headerBottom = bottom + usableHeight - 72 -- 377
							local indexTop = coverY + coverHeight - 14 + offset.y -- 378
							indexRef.current.opacity = dragAxis == "vertical" and math.max( -- 379
								0, -- 380
								math.min(1, (headerBottom - indexTop) / 16) -- 380
							) or 1 -- 380
						end -- 380
					end -- 380
				end, -- 368
				onTapEnded = function() -- 368
					local action = resolveFeedGesture(drag.x, drag.y, usableWidth, usableHeight) -- 386
					drag = Vec2.zero -- 387
					dragAxis = "none" -- 388
					if indexRef.current then -- 388
						indexRef.current.opacity = 1 -- 389
					end -- 389
					if action == "none" and cardRef.current then -- 389
						local card = cardRef.current -- 391
						card:perform(Move(App.reducedMotion and 0 or 0.16, card.position, Vec2.zero, Ease.OutQuad)) -- 392
					end -- 392
					commit(action) -- 394
				end, -- 385
				onMouseWheel = function(delta) return commit(delta.y > 0 and "previous" or "next") end -- 385
			}, -- 385
			React.createElement(VerticalGradient, {width = width, height = height, topColor = 4279310117, bottomColor = 4278716943}) -- 385
		) -- 385
		local ____createOpen_27 -- 399
		if createOpen then -- 399
			____createOpen_27 = nil -- 399
		else -- 399
			local ____temp_26 -- 399
			if item ~= nil then -- 399
				local ____React_createElement_25 = React.createElement -- 399
				local ____array_24 = __TS__SparseArrayNew( -- 399
					"node", -- 399
					{tag = "mobile-feed-card-" .. item.id, ref = cardRef, key = (tab .. "-") .. item.id}, -- 399
					__TS__ArrayMap( -- 400
						cardIndices, -- 400
						function(____, cardIndex) return React.createElement(Cover, { -- 400
							key = (tab .. "-") .. data[cardIndex + 1].id, -- 400
							entry = data[cardIndex + 1], -- 400
							x = coverX, -- 400
							y = coverY + (index - cardIndex) * usableHeight, -- 400
							width = coverWidth, -- 400
							height = coverHeight -- 400
						}) end -- 400
					), -- 400
					React.createElement( -- 400
						"node", -- 400
						{ -- 400
							tag = "mobile-feed-index", -- 400
							ref = indexRef, -- 400
							x = coverX + coverWidth - 62, -- 400
							y = coverY + coverHeight - 40, -- 400
							width = 48, -- 400
							height = 26, -- 400
							anchorX = 0, -- 400
							anchorY = 0 -- 400
						}, -- 400
						React.createElement(RoundedSurface, { -- 400
							width = 48, -- 400
							height = 26, -- 400
							radius = 13, -- 400
							topColor = 3760730173, -- 400
							bottomColor = 3759281694, -- 400
							borderWidth = 1, -- 400
							borderColor = 2286967404 -- 400
						}), -- 400
						React.createElement( -- 400
							"label", -- 400
							{ -- 400
								x = 24, -- 400
								y = 13, -- 400
								fontName = fontName, -- 400
								fontSize = 11, -- 400
								text = (tostring(index + 1) .. " / ") .. tostring(#data), -- 400
								color3 = 14146531 -- 400
							} -- 400
						) -- 400
					), -- 400
					React.createElement( -- 400
						"label", -- 400
						{ -- 400
							tag = "mobile-feed-current-title", -- 400
							x = infoX, -- 400
							y = infoTop, -- 400
							anchorX = 0, -- 400
							anchorY = 0.5, -- 400
							fontName = fontName, -- 400
							fontSize = math.floor((wide and 30 or 25) * fontScale), -- 400
							text = item.title, -- 400
							textWidth = infoWidth, -- 400
							alignment = "Left", -- 400
							color3 = 16052712 -- 400
						} -- 400
					), -- 400
					React.createElement( -- 400
						"label", -- 400
						{ -- 400
							x = infoX, -- 400
							y = infoTop - 58, -- 400
							anchorX = 0, -- 400
							anchorY = 0.5, -- 400
							fontName = fontName, -- 400
							fontSize = math.floor(15 * fontScale), -- 400
							text = conciseDescription(item.description, wide and 80 or (compact and 28 or 42)), -- 400
							textWidth = infoWidth, -- 400
							alignment = "Left", -- 400
							color3 = 11055037 -- 400
						} -- 400
					) -- 400
				) -- 400
				local ____temp_23 -- 416
				if compact or shortLandscape then -- 416
					____temp_23 = nil -- 416
				else -- 416
					____temp_23 = React.createElement( -- 416
						"node", -- 416
						{ -- 416
							x = infoX, -- 416
							y = infoTop - 118, -- 416
							width = wide and 176 or 164, -- 416
							height = 28, -- 416
							anchorX = 0, -- 416
							anchorY = 0 -- 416
						}, -- 416
						React.createElement(RoundedSurface, { -- 416
							width = wide and 176 or 164, -- 416
							height = 28, -- 416
							radius = 14, -- 416
							topColor = 1714436683, -- 416
							bottomColor = 1712857131, -- 416
							borderWidth = 1, -- 416
							borderColor = 2288020349 -- 416
						}), -- 416
						React.createElement("label", { -- 416
							x = 12, -- 416
							y = 14, -- 416
							anchorX = 0, -- 416
							fontName = fontName, -- 416
							fontSize = 12, -- 416
							text = item.kind == "local" and (zh and "本地作品  ·  可 Remix" or "Local  ·  Remixable") or (item.installed and (zh and "发现  ·  已安装" or "Discover  ·  Installed") or (zh and "发现  ·  可安装" or "Discover  ·  Installable")), -- 416
							textWidth = (wide and 176 or 164) - 24, -- 416
							alignment = "Left", -- 416
							color3 = 14475754 -- 416
						}) -- 416
					) -- 416
				end -- 416
				__TS__SparseArrayPush( -- 416
					____array_24, -- 416
					____temp_23, -- 416
					React.createElement( -- 416
						MobileButton, -- 422
						{ -- 422
							tag = "mobile-feed-remix", -- 422
							x = infoX, -- 422
							y = bottom + 24, -- 422
							width = buttonWidth, -- 422
							text = zh and "Remix 作品" or "Remix game", -- 422
							fontSize = math.floor(16 * fontScale), -- 422
							primary = true, -- 422
							onTapped = function() return activate("remix") end -- 422
						} -- 422
					), -- 422
					React.createElement( -- 422
						MobileButton, -- 424
						{ -- 424
							tag = "mobile-feed-play", -- 424
							x = infoX + buttonWidth + 12, -- 424
							y = bottom + 24, -- 424
							width = buttonWidth, -- 424
							text = zh and "试玩" or "Play", -- 424
							fontSize = math.floor(17 * fontScale), -- 424
							onTapped = function() return activate("play") end -- 424
						} -- 424
					), -- 424
					React.createElement("label", { -- 424
						x = infoX, -- 424
						y = bottom + 92, -- 424
						anchorX = 0, -- 424
						anchorY = 0.5, -- 424
						fontName = fontName, -- 424
						fontSize = 14, -- 424
						text = prepareStatus ~= "" and prepareStatus or (item.launchError ~= nil and item.launchError or (zh and "上滑浏览  ·  右滑 Remix  ·  左滑试玩" or "Swipe up  ·  right Remix  ·  left Play")), -- 424
						textWidth = infoWidth, -- 424
						alignment = "Left", -- 424
						color3 = item.launchError ~= nil and 16739179 or 11055037 -- 424
					}) -- 424
				) -- 424
				____temp_26 = ____React_createElement_25(__TS__SparseArraySpread(____array_24)) -- 424
			else -- 424
				____temp_26 = React.createElement( -- 424
					"node", -- 424
					nil, -- 424
					React.createElement("label", { -- 424
						x = left + usableWidth / 2, -- 424
						y = bottom + usableHeight / 2 + 20, -- 424
						fontName = fontName, -- 424
						fontSize = 22, -- 424
						text = tab == "discover" and (zh and "暂无移动作品" or "No mobile games yet") or (zh and "没有可运行的本地作品" or "No runnable local games"), -- 424
						color3 = 16052712 -- 424
					}), -- 424
					React.createElement("label", { -- 424
						x = left + usableWidth / 2, -- 424
						y = bottom + usableHeight / 2 - 28, -- 424
						fontName = fontName, -- 424
						fontSize = 14, -- 424
						text = tab == "discover" and discoverError ~= "" and discoverError or (zh and "切换标签或稍后重试" or "Switch tabs or retry later"), -- 424
						textWidth = usableWidth - 48, -- 424
						color3 = tab == "discover" and discoverError ~= "" and 16739179 or 11055037 -- 424
					}) -- 424
				) -- 424
			end -- 424
			____createOpen_27 = ____temp_26 -- 399
		end -- 399
		__TS__SparseArrayPush(____array_40, ____createOpen_27) -- 399
		local ____React_createElement_31 = React.createElement -- 399
		local ____array_30 = __TS__SparseArrayNew("node", {tag = "mobile-feed-header", order = headerRenderOrder}) -- 399
		local ____options_onSwitchMode_28 -- 438
		if options.onSwitchMode then -- 438
			____options_onSwitchMode_28 = React.createElement( -- 438
				"node", -- 438
				{ -- 438
					tag = "mobile-ui-mode-switch", -- 438
					x = left + 12, -- 438
					y = bottom + usableHeight - 58 + landscapeTopLift, -- 438
					width = 72, -- 438
					height = 48, -- 438
					anchorX = 0, -- 438
					anchorY = 0, -- 438
					touchEnabled = true, -- 438
					swallowTouches = true, -- 438
					onTapped = switchMode -- 438
				}, -- 438
				React.createElement("label", { -- 438
					x = 0, -- 438
					y = 30, -- 438
					anchorX = 0, -- 438
					fontName = fontName, -- 438
					fontSize = 16, -- 438
					text = "DORA", -- 438
					color3 = preparing and 7831180 or 16763955 -- 438
				}), -- 438
				React.createElement("label", { -- 438
					x = 0, -- 438
					y = 10, -- 438
					anchorX = 0, -- 438
					fontName = fontName, -- 438
					fontSize = 10, -- 438
					text = zh and "切换传统界面" or "Classic UI", -- 438
					color3 = 7831180 -- 438
				}) -- 438
			) -- 438
		else -- 438
			____options_onSwitchMode_28 = nil -- 442
		end -- 442
		__TS__SparseArrayPush( -- 442
			____array_30, -- 442
			____options_onSwitchMode_28, -- 442
			React.createElement( -- 442
				"label", -- 442
				{ -- 442
					tag = "mobile-feed-discover-tab", -- 442
					x = left + usableWidth / 2 - 44, -- 442
					y = bottom + usableHeight - 34 + landscapeTopLift, -- 442
					fontName = fontName, -- 442
					fontSize = math.floor(17 * fontScale), -- 442
					text = zh and "发现" or "Discover", -- 442
					color3 = tab == "discover" and 16763955 or 11055037, -- 442
					touchEnabled = true, -- 442
					swallowTouches = true, -- 442
					onTapped = function() return setTab("discover") end -- 442
				} -- 442
			), -- 442
			React.createElement( -- 442
				"label", -- 442
				{ -- 442
					tag = "mobile-feed-local-tab", -- 442
					x = left + usableWidth / 2 + 44, -- 442
					y = bottom + usableHeight - 34 + landscapeTopLift, -- 442
					fontName = fontName, -- 442
					fontSize = math.floor(17 * fontScale), -- 442
					text = zh and "本地" or "Local", -- 442
					color3 = tab == "local" and 16763955 or 11055037, -- 442
					touchEnabled = true, -- 442
					swallowTouches = true, -- 442
					onTapped = function() -- 442
						____local = getLocalEntries() -- 448
						setTab("local") -- 448
					end -- 448
				} -- 448
			), -- 448
			React.createElement(RoundedSurface, { -- 448
				x = left + usableWidth / 2 + (tab == "discover" and -58 or 30), -- 448
				y = bottom + usableHeight - 56 + landscapeTopLift, -- 448
				width = 28, -- 448
				height = 3, -- 448
				radius = 1.5, -- 448
				fillColor = colors.brand, -- 448
				renderOrder = headerRenderOrder + 1 -- 448
			}) -- 448
		) -- 448
		local ____temp_29 -- 450
		if tab == "local" and options.createProject then -- 450
			____temp_29 = React.createElement( -- 450
				"node", -- 450
				{ -- 450
					tag = "mobile-feed-create", -- 450
					x = left + usableWidth - 82, -- 450
					y = bottom + usableHeight - 56 + landscapeTopLift, -- 450
					width = 70, -- 450
					height = 44, -- 450
					anchorX = 0, -- 450
					anchorY = 0, -- 450
					touchEnabled = true, -- 450
					swallowTouches = true, -- 450
					onTapped = function() -- 450
						if preparing or transitioning or creating or createOpen or HttpServer.wsConnectionCount > 0 then -- 450
							return -- 452
						end -- 452
						createOpen = true -- 453
						createName = "" -- 454
						dismissedCreateComposition = false -- 455
						createError = "" -- 456
						render() -- 457
						createInput.deferFocus() -- 458
					end -- 451
				}, -- 451
				React.createElement(RoundedSurface, { -- 451
					width = 70, -- 451
					height = 44, -- 451
					radius = 22, -- 451
					topColor = 858534978, -- 451
					bottomColor = 856824097, -- 451
					borderWidth = 1, -- 451
					borderColor = colors.brand, -- 451
					renderOrder = headerRenderOrder + 1 -- 451
				}), -- 451
				React.createElement("label", { -- 451
					x = 35, -- 451
					y = 22, -- 451
					fontName = fontName, -- 451
					fontSize = 14, -- 451
					text = zh and "+ 新建" or "+ New", -- 451
					color3 = 16763955 -- 451
				}) -- 451
			) -- 451
		else -- 451
			____temp_29 = nil -- 462
		end -- 462
		__TS__SparseArrayPush(____array_30, ____temp_29) -- 462
		__TS__SparseArrayPush( -- 462
			____array_40, -- 462
			____React_createElement_31(__TS__SparseArraySpread(____array_30)) -- 462
		) -- 462
		local ____createOpen_39 -- 464
		if createOpen then -- 464
			____createOpen_39 = (function() -- 464
				local sheetHeight = math.min(createSheetHeight, usableHeight - 64) -- 465
				local sheetWidth = usableWidth -- 466
				local contentWidth = sheetWidth - 40 -- 467
				local actionGap = 12 -- 468
				local actionsWidth = shortLandscape and math.min( -- 469
					300, -- 469
					math.floor(contentWidth * 0.42) -- 469
				) or contentWidth -- 469
				local inputWidth = shortLandscape and contentWidth - actionGap - actionsWidth or contentWidth -- 470
				local actionX = shortLandscape and 20 + inputWidth + actionGap or 20 -- 471
				local actionY = shortLandscape and sheetHeight - createInputTop - createInputHeight or 20 -- 472
				local cancelWidth = math.floor((actionsWidth - actionGap) * (shortLandscape and 0.34 or 0.38)) -- 473
				local ____React_createElement_38 = React.createElement -- 473
				local ____array_37 = __TS__SparseArrayNew( -- 473
					"node", -- 473
					{ -- 473
						tag = "mobile-project-create-sheet", -- 473
						order = 10000, -- 473
						width = width, -- 473
						height = height, -- 473
						anchorX = 0, -- 473
						anchorY = 0, -- 473
						touchEnabled = true, -- 473
						swallowTouches = true -- 473
					}, -- 473
					React.createElement( -- 473
						"node", -- 473
						{ -- 473
							tag = "mobile-project-create-focus-observer", -- 473
							order = 1000, -- 473
							width = width, -- 473
							height = height, -- 473
							anchorX = 0, -- 473
							anchorY = 0, -- 473
							touchEnabled = true, -- 473
							swallowTouches = false, -- 473
							swallowMouseWheel = false, -- 473
							onTapFilter = function(touch) -- 473
								touch.enabled = false -- 477
								if not canEditCreate() then -- 477
									return -- 478
								end -- 478
								local input = createInputRef.current -- 479
								local point = input and input:convertToNodeSpace(touch.worldLocation) -- 480
								local inside = input and point and point.x >= 0 and point.y >= 0 and point.x <= input.width and point.y <= input.height -- 481
								dismissedCreateComposition = not inside and createInput.isComposing() -- 482
								if not inside then -- 482
									blurCreateInput() -- 483
								end -- 483
							end -- 476
						} -- 476
					), -- 476
					React.createElement( -- 476
						"draw-node", -- 476
						{ -- 476
							tag = "mobile-project-create-backdrop", -- 476
							order = 0, -- 476
							renderOrder = 0, -- 476
							x = width / 2, -- 476
							y = bottom + sheetHeight + (height - bottom - sheetHeight) / 2 -- 476
						}, -- 476
						React.createElement("rect-shape", {width = width, height = height - bottom - sheetHeight, fillColor = 2348810240}) -- 476
					) -- 476
				) -- 476
				local ____React_createElement_36 = React.createElement -- 476
				local ____array_35 = __TS__SparseArrayNew( -- 476
					"node", -- 476
					{ -- 476
						ref = createPanelRef, -- 476
						order = 10, -- 476
						renderOrder = 10, -- 476
						x = left, -- 476
						y = bottom, -- 476
						width = sheetWidth, -- 476
						height = sheetHeight, -- 476
						anchorX = 0, -- 476
						anchorY = 0, -- 476
						touchEnabled = true, -- 476
						swallowTouches = true -- 476
					}, -- 476
					React.createElement(MobilePanelSurface, {width = sheetWidth, height = sheetHeight, renderOrder = 10}), -- 476
					React.createElement("label", { -- 476
						x = 20, -- 476
						y = sheetHeight - 24, -- 476
						anchorX = 0, -- 476
						anchorY = 1, -- 476
						fontName = fontName, -- 476
						fontSize = 22, -- 476
						text = zh and "新建项目" or "New project", -- 476
						color3 = 16052712 -- 476
					}), -- 476
					React.createElement("label", { -- 476
						x = 20, -- 476
						y = sheetHeight - 66, -- 476
						anchorX = 0, -- 476
						anchorY = 1, -- 476
						fontName = fontName, -- 476
						fontSize = 14, -- 476
						text = zh and "项目名称" or "Project name", -- 476
						color3 = 11055037 -- 476
					}) -- 476
				) -- 476
				local ____keptInput_34 -- 492
				if keptInput then -- 492
					____keptInput_34 = nil -- 492
				else -- 492
					____keptInput_34 = React.createElement("node", { -- 492
						tag = "mobile-project-create-input", -- 492
						ref = createInputRef, -- 492
						renderOrder = 10, -- 492
						x = 20, -- 492
						y = sheetHeight - createInputTop - createInputHeight, -- 492
						width = inputWidth, -- 492
						height = createInputHeight, -- 492
						anchorX = 0, -- 492
						anchorY = 0, -- 492
						onMount = createInput.mount -- 492
					}) -- 492
				end -- 492
				__TS__SparseArrayPush( -- 492
					____array_35, -- 492
					____keptInput_34, -- 492
					React.createElement("label", { -- 492
						tag = "mobile-project-create-error", -- 492
						x = 20, -- 492
						y = shortLandscape and sheetHeight - createInputTop + 12 or sheetHeight - createInputTop - createInputHeight - 12, -- 492
						anchorX = 0, -- 492
						anchorY = 1, -- 492
						fontName = fontName, -- 492
						fontSize = 12, -- 492
						text = createError ~= "" and createError or (zh and "将创建可运行的 TypeScript 起始项目" or "Creates a runnable TypeScript starter project"), -- 492
						textWidth = inputWidth, -- 492
						alignment = "Left", -- 492
						color3 = createError ~= "" and 16739179 or 11055037 -- 492
					}), -- 492
					React.createElement(MobileButton, { -- 492
						tag = "mobile-project-create-cancel", -- 492
						x = actionX, -- 492
						y = actionY, -- 492
						width = cancelWidth, -- 492
						text = zh and "取消" or "Cancel", -- 492
						renderOrder = 10, -- 492
						onTapped = closeCreate -- 492
					}), -- 492
					React.createElement( -- 492
						MobileButton, -- 498
						{ -- 498
							tag = "mobile-project-create-submit", -- 498
							x = actionX + cancelWidth + actionGap, -- 498
							y = actionY, -- 498
							width = actionsWidth - cancelWidth - actionGap, -- 498
							text = creating and (zh and "创建中…" or "Creating…") or (zh and "创建并进入 Remix" or "Create and Remix"), -- 498
							primary = true, -- 498
							renderOrder = 10, -- 498
							onTapped = function() -- 498
								if not dismissedCreateComposition then -- 498
									submitCreate() -- 499
								end -- 499
								dismissedCreateComposition = false -- 499
							end -- 499
						} -- 499
					) -- 499
				) -- 499
				__TS__SparseArrayPush( -- 499
					____array_37, -- 499
					____React_createElement_36(__TS__SparseArraySpread(____array_35)) -- 499
				) -- 499
				return ____React_createElement_38(__TS__SparseArraySpread(____array_37)) -- 474
			end)() -- 464
		else -- 464
			____createOpen_39 = nil -- 502
		end -- 502
		__TS__SparseArrayPush(____array_40, ____createOpen_39) -- 502
		local scene = ____toNode_42(____React_createElement_41(__TS__SparseArraySpread(____array_40))) -- 353
		if scene ~= nil then -- 353
			host:addChild(scene) -- 504
		end -- 504
		if keptInput and createPanelRef.current then -- 504
			keptInput.position = Vec2( -- 506
				20, -- 506
				math.min(createSheetHeight, usableHeight - 64) - createInputTop - createInputHeight -- 506
			) -- 506
			createPanelRef.current:addChild(keptInput) -- 507
		end -- 507
		createInput.refresh() -- 509
		if restoreFocus and not keptInput and createOpen then -- 509
			createInput.focus(false) -- 510
		end -- 510
	end -- 306
	host:onAppChange(function(setting) -- 513
		if setting == "Size" or setting == "Locale" then -- 513
			render() -- 514
		end -- 514
	end) -- 513
	host:onAppEvent(function(event) -- 516
		if event == "BackButton" then -- 516
			if createOpen and not creating then -- 516
				closeCreate() -- 518
			end -- 518
		elseif event == "WillEnterBackground" or event == "DidEnterBackground" then -- 518
			blurCreateInput() -- 519
		end -- 519
	end) -- 516
	host:onCleanup(function() -- 521
		blurCreateInput() -- 521
		active = false -- 521
	end) -- 521
	host:slot( -- 522
		"RestoreFeedEntry", -- 522
		function(entry) -- 522
			if not isActive() or HttpServer.wsConnectionCount > 0 then -- 522
				return -- 523
			end -- 523
			returnEntry = entry -- 524
			____local = getLocalEntries() -- 525
			discover = getDiscoverEntries() -- 526
			local location = resolveFeedLocation(____local, discover, entry) -- 527
			tab = location.tab -- 528
			index = location.index -- 529
			render() -- 530
		end -- 522
	) -- 522
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
				local selected = returnEntry or rememberedEntries[tab] or current() -- 546
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
end -- 93
return ____exports -- 93