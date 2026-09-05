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
local roundedRectVerts = ____Visual.roundedRectVerts -- 9
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
	local canShare = App.platform == "Android" or App.platform == "iOS" -- 104
	local zh = (string.match(App.locale, "^zh")) ~= nil -- 105
	local tab = "local" -- 106
	local index = 0 -- 107
	local drag = Vec2.zero -- 108
	local dragAxis = "none" -- 109
	local discoverError = "" -- 110
	local preparing = false -- 111
	local transitioning = false -- 112
	local prepareStatus = "" -- 113
	local repairResourceId = "" -- 114
	local userSelectedTab = false -- 115
	local active = true -- 116
	local leaving = false -- 117
	local packagePanel -- 118
	local createOpen = false -- 119
	local projectIndexOpen = false -- 120
	local creating = false -- 121
	local createName = "" -- 122
	local dismissedCreateComposition = false -- 123
	local createError = "" -- 124
	local gamepadUsed = false -- 125
	local returnEntry = options.initialEntry -- 126
	local ____opt_6 = options.initialEntries -- 126
	local ____temp_10 = ____opt_6 and ____opt_6["local"] -- 128
	local ____opt_8 = options.initialEntries -- 128
	local rememberedEntries = {["local"] = ____temp_10, discover = ____opt_8 and ____opt_8.discover} -- 127
	local cardRef = reference() -- 131
	local indexRef = reference() -- 132
	local createInputRef = reference() -- 133
	local discover = getDiscoverEntries() -- 134
	local ____local = getLocalEntries() -- 135
	if #discover == 0 then -- 135
		discoverError = zh and "资源目录暂不可用" or "Catalog is unavailable" -- 138
	end -- 138
	local initialLocation = resolveFeedLocation(____local, discover, returnEntry) -- 140
	tab = initialLocation.tab -- 141
	index = initialLocation.index -- 142
	local host = Node() -- 144
	host.tag = "mobile-feed" -- 145
	host.scaleX = App.devicePixelRatio -- 146
	host.scaleY = App.devicePixelRatio -- 147
	host:addTo(Director.systemUI) -- 148
	local function isActive() -- 150
		return active and not leaving and host.parent ~= nil -- 150
	end -- 150
	local function entries() -- 152
		return tab == "discover" and discover or ____local -- 152
	end -- 152
	local function current() -- 153
		return entries()[normalizeFeedIndex( -- 153
			index, -- 153
			#entries() -- 153
		) + 1] -- 153
	end -- 153
	local rememberedEntryKey = "" -- 154
	local function rememberCurrent() -- 155
		local item = current() -- 156
		if not item or not options.onCurrentEntryChanged then -- 156
			return -- 157
		end -- 157
		local key = (((((item.kind .. "\n") .. item.id) .. "\n") .. (item.workDir or "")) .. "\n") .. (item.fileName or "") -- 158
		if key == rememberedEntryKey then -- 158
			return -- 159
		end -- 159
		rememberedEntryKey = key -- 160
		rememberedEntries[item.kind] = item -- 161
		options.onCurrentEntryChanged(item) -- 162
	end -- 155
	local function canEditCreate() -- 164
		return createOpen and not creating and isActive() and host.visible and HttpServer.wsConnectionCount == 0 -- 164
	end -- 164
	local createInput = createTextInput({ -- 165
		fontSize = math.floor(16 * mobileFontScale), -- 166
		singleLine = true, -- 167
		background = colors.background, -- 168
		getText = function() return createName end, -- 169
		setText = function(text) -- 170
			createName = text -- 170
		end, -- 170
		getPlaceholder = function() return zh and "例如：星际花园" or "For example: Star Garden" end, -- 171
		isEnabled = canEditCreate, -- 172
		onReturn = function() -- 173
			submitCreate() -- 173
			return true -- 173
		end -- 173
	}) -- 173
	local blurCreateInput = createInput.blur -- 175
	local function closeCreate() -- 176
		if creating then -- 176
			return -- 177
		end -- 177
		blurCreateInput() -- 178
		createOpen = false -- 179
		createName = "" -- 180
		createError = "" -- 181
		render() -- 182
	end -- 176
	local function openCreate() -- 184
		if not options.createProject or preparing or transitioning or creating or createOpen or HttpServer.wsConnectionCount > 0 then -- 184
			return -- 185
		end -- 185
		projectIndexOpen = false -- 186
		createOpen = true -- 187
		createName = "" -- 188
		dismissedCreateComposition = false -- 189
		createError = "" -- 190
		render() -- 191
		createInput.deferFocus() -- 192
	end -- 184
	local function openProjectIndex() -- 194
		if tab ~= "local" or preparing or transitioning or creating or createOpen or HttpServer.wsConnectionCount > 0 then -- 194
			return -- 195
		end -- 195
		____local = getLocalEntries() -- 196
		projectIndexOpen = true -- 197
		render() -- 198
	end -- 194
	local function createErrorText(____error) -- 200
		repeat -- 200
			local ____switch30 = ____error -- 200
			local ____cond30 = ____switch30 == "invalid-name" -- 200
			if ____cond30 then -- 200
				return zh and "请输入不含路径分隔符的项目名称" or "Enter a project name without path separators" -- 202
			end -- 202
			____cond30 = ____cond30 or ____switch30 == "target-existed" -- 202
			if ____cond30 then -- 202
				return zh and "已有同名项目，请换一个名称" or "A project with that name already exists" -- 203
			end -- 203
			____cond30 = ____cond30 or ____switch30 == "create-folder-failed" -- 203
			if ____cond30 then -- 203
				return zh and "无法创建项目目录，请检查工作目录后重试" or "Could not create the project folder; check the workspace and retry" -- 204
			end -- 204
			____cond30 = ____cond30 or ____switch30 == "create-entry-failed" -- 204
			if ____cond30 then -- 204
				return zh and "无法写入项目入口，未完成项目已回滚" or "Could not write the project entry; the incomplete project was rolled back" -- 205
			end -- 205
			____cond30 = ____cond30 or ____switch30 == "created-project-not-found" -- 205
			if ____cond30 then -- 205
				return zh and "项目已创建，但本地列表未能找到它，请返回后重试" or "The project was created but could not be found in Local; return and retry" -- 206
			end -- 206
			do -- 206
				return zh and "创建失败，请重试" or "Project creation failed; try again" -- 207
			end -- 207
		until true -- 207
	end -- 200
	submitCreate = function() -- 210
		if not options.createProject or creating or not createOpen or not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 then -- 210
			return -- 211
		end -- 211
		if createInput.isComposing() then -- 211
			return -- 212
		end -- 212
		creating = true -- 213
		createError = "" -- 214
		blurCreateInput() -- 215
		render() -- 216
		local result = options.createProject(createName) -- 217
		if not isActive() then -- 217
			return -- 218
		end -- 218
		creating = false -- 219
		if not result.success then -- 219
			createError = createErrorText(result.error) -- 221
			render() -- 222
			return -- 223
		end -- 223
		createOpen = false -- 225
		createName = "" -- 226
		____local = getLocalEntries() -- 227
		returnEntry = result.entry -- 228
		local location = resolveFeedLocation(____local, discover, result.entry) -- 229
		tab = location.tab -- 230
		index = location.index -- 231
		render() -- 232
		onRemix(result.entry) -- 233
	end -- 210
	local function openPackage(mode, path, pickOnOpen) -- 236
		if pickOnOpen == nil then -- 236
			pickOnOpen = false -- 236
		end -- 236
		if not isActive() or not host.visible or packagePanel or preparing or transitioning or creating or createOpen or HttpServer.wsConnectionCount > 0 then -- 236
			return -- 237
		end -- 237
		projectIndexOpen = false -- 238
		packagePanel = startPackagePanel({ -- 239
			mode = mode, -- 240
			path = path, -- 240
			pickOnOpen = pickOnOpen, -- 240
			entry = current(), -- 240
			onNew = openCreate, -- 241
			onClosed = function() -- 242
				packagePanel = nil -- 242
			end, -- 242
			onImported = function(entry, play) -- 243
				if not isActive() then -- 243
					return -- 244
				end -- 244
				____local = getLocalEntries(entry.workDir) -- 245
				local imported = __TS__ArrayFind( -- 246
					____local, -- 246
					function(____, item) return item.workDir == entry.workDir end -- 246
				) or entry -- 246
				returnEntry = imported -- 247
				local location = resolveFeedLocation(____local, discover, imported) -- 248
				tab = "local" -- 249
				index = location.index -- 249
				render() -- 250
				if play then -- 250
					onPlay(imported) -- 251
				end -- 251
			end -- 243
		}) -- 243
	end -- 236
	local receiveElapsed = 0 -- 255
	host:schedule(function(dt) -- 256
		receiveElapsed = receiveElapsed + dt -- 257
		if receiveElapsed < 0.5 then -- 257
			return false -- 258
		end -- 258
		receiveElapsed = 0 -- 259
		if isActive() and host.visible and not packagePanel and not createOpen and not projectIndexOpen and not preparing and not transitioning and HttpServer.wsConnectionCount == 0 then -- 259
			local path = options.takeReceivedFile and options.takeReceivedFile() or App:takeReceivedFile() -- 261
			if path ~= "" then -- 261
				openPackage("receive", path) -- 262
			end -- 262
		end -- 262
		return false -- 264
	end) -- 256
	local function setTab(next) -- 267
		if not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 or preparing or creating then -- 267
			return -- 268
		end -- 268
		userSelectedTab = true -- 269
		returnEntry = nil -- 270
		if tab == next then -- 270
			return -- 271
		end -- 271
		if createOpen then -- 271
			blurCreateInput() -- 273
			createOpen = false -- 274
			createName = "" -- 275
			createError = "" -- 276
		end -- 276
		tab = next -- 278
		local target = rememberedEntries[next] -- 279
		local ____temp_11 -- 280
		if target == nil then -- 280
			____temp_11 = nil -- 280
		else -- 280
			____temp_11 = resolveFeedLocation(____local, discover, target) -- 280
		end -- 280
		local location = ____temp_11 -- 280
		index = (location and location.tab) == next and location.index or 0 -- 281
		render() -- 282
	end -- 267
	local function activate(action) -- 284
		local item = current() -- 285
		if not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 or not item or preparing then -- 285
			return -- 286
		end -- 286
		item.launchError = nil -- 287
		local function done() -- 288
			returnEntry = item -- 288
			local ____temp_14 -- 288
			if action == "play" then -- 288
				____temp_14 = onPlay(item) -- 288
			else -- 288
				____temp_14 = onRemix(item) -- 288
			end -- 288
			return ____temp_14 -- 288
		end -- 288
		if item.kind == "local" or item.installed then -- 288
			done() -- 289
			return -- 289
		end -- 289
		preparing = true -- 290
		prepareStatus = zh and "准备安装…" or "Preparing install…" -- 291
		render() -- 292
		local repairIncomplete = repairResourceId == item.id -- 293
		repairResourceId = "" -- 294
		prepare( -- 295
			item, -- 295
			repairIncomplete, -- 295
			function(progress, message) -- 295
				if not isActive() then -- 295
					return -- 296
				end -- 296
				prepareStatus = (tostring(math.floor(progress * 100)) .. "% · ") .. message -- 297
				render() -- 298
			end, -- 295
			function(success, ready, message, repairable) -- 299
				if not isActive() then -- 299
					return -- 300
				end -- 300
				preparing = false -- 301
				if not success or not ready then -- 301
					repairResourceId = repairable and item.id or "" -- 303
					prepareStatus = message or (zh and "安装失败，点击按钮重试" or "Install failed; tap to retry") -- 304
					render() -- 305
					return -- 306
				end -- 306
				item.fileName = ready.fileName -- 308
				item.workDir = ready.workDir -- 309
				item.installed = true -- 310
				prepareStatus = "" -- 311
				if HttpServer.wsConnectionCount == 0 and host.visible then -- 311
					done() -- 312
				else -- 312
					render() -- 313
				end -- 313
			end -- 299
		) -- 299
	end -- 284
	local function commit(action) -- 317
		if not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 or preparing or transitioning then -- 317
			return -- 318
		end -- 318
		if action == "play" or action == "remix" then -- 318
			local card = cardRef.current -- 320
			if card then -- 320
				card.position = Vec2.zero -- 321
			end -- 321
		end -- 321
		repeat -- 321
			local ____switch66 = action -- 321
			local ____cond66 = ____switch66 == "previous" or ____switch66 == "next" -- 321
			if ____cond66 then -- 321
				do -- 321
					returnEntry = nil -- 326
					local target = normalizeFeedIndex( -- 327
						index + (action == "next" and 1 or -1), -- 327
						#entries() -- 327
					) -- 327
					if target == index then -- 327
						local card = cardRef.current -- 329
						if card then -- 329
							card:perform(Move(App.reducedMotion and 0 or 0.16, card.position, Vec2.zero, Ease.OutQuad)) -- 330
						end -- 330
						return -- 331
					end -- 331
					local duration = App.reducedMotion and 0 or 0.18 -- 333
					local function finish() -- 334
						if not isActive() then -- 334
							return -- 335
						end -- 335
						index = target -- 336
						transitioning = false -- 337
						App:vibrate(0.012) -- 338
						render() -- 339
					end -- 334
					local card = cardRef.current -- 341
					if duration > 0 and card then -- 341
						transitioning = true -- 343
						card:perform(Move( -- 344
							duration, -- 344
							card.position, -- 344
							Vec2(0, (action == "next" and 1 or -1) * App.safeArea.height), -- 344
							Ease.OutQuad -- 344
						)) -- 344
						thread(function() -- 345
							sleep(duration) -- 345
							finish() -- 345
						end) -- 345
					else -- 345
						finish() -- 346
					end -- 346
					return -- 347
				end -- 347
			end -- 347
			____cond66 = ____cond66 or ____switch66 == "play" -- 347
			if ____cond66 then -- 347
				activate("play") -- 349
				return -- 349
			end -- 349
			____cond66 = ____cond66 or ____switch66 == "remix" -- 349
			if ____cond66 then -- 349
				activate("remix") -- 350
				return -- 350
			end -- 350
			do -- 350
				return -- 351
			end -- 351
		until true -- 351
	end -- 317
	local function switchMode() -- 355
		if not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 or preparing or creating or createOpen or packagePanel or transitioning or not options.onSwitchMode then -- 355
			return -- 356
		end -- 356
		leaving = true -- 357
		options.onSwitchMode() -- 358
	end -- 355
	host:slot("SwitchUIMode", switchMode) -- 360
	render = function() -- 361
		if not isActive() then -- 361
			return -- 362
		end -- 362
		local safeContentWidth = App.safeArea.width - 40 -- 364
		local shortLandscapeInputWidth = safeContentWidth - 12 - math.min( -- 365
			300, -- 365
			math.floor(safeContentWidth * 0.42) -- 365
		) -- 365
		local expectedInputWidth = App.safeArea.width >= 760 and App.safeArea.height < 500 and shortLandscapeInputWidth or safeContentWidth -- 366
		local ____createOpen_17 = createOpen -- 367
		if ____createOpen_17 then -- 367
			local ____opt_15 = createInputRef.current -- 367
			____createOpen_17 = (____opt_15 and ____opt_15.width) == expectedInputWidth -- 367
		end -- 367
		local keptInput = ____createOpen_17 and createInputRef.current or nil -- 367
		local restoreFocus = createInput.isFocused() -- 368
		if keptInput ~= nil then -- 368
			keptInput:removeFromParent(false) -- 369
		end -- 369
		if not keptInput then -- 369
			createInput.unmount() -- 371
			createInputRef = reference() -- 372
		end -- 372
		local createPanelRef = reference() -- 374
		host:removeAllChildren() -- 375
		host.scaleX = App.devicePixelRatio -- 376
		host.scaleY = App.devicePixelRatio -- 377
		local ____App_visualSize_20 = App.visualSize -- 378
		local width = ____App_visualSize_20.width -- 378
		local height = ____App_visualSize_20.height -- 378
		local safe = App.safeArea -- 379
		local left = safe.left -- 380
		local bottom = safe.bottom -- 381
		local usableWidth = safe.width -- 382
		local usableHeight = safe.height -- 383
		local wide = usableWidth >= 760 -- 384
		local shortLandscape = wide and usableHeight < 500 -- 385
		local compact = not wide and usableHeight < 700 -- 386
		local compactLandscape = compact and usableWidth > usableHeight and usableHeight < 520 -- 387
		local landscapeTopLift = shortLandscape and 28 or 0 -- 388
		local data = entries() -- 389
		index = normalizeFeedIndex(index, #data) -- 390
		local item = current() -- 391
		rememberCurrent() -- 392
		local coverWidth = wide and math.min(usableWidth * 0.54, 680) or usableWidth - 32 -- 393
		local coverHeight = wide and math.min(usableHeight - 118, coverWidth * 0.72) or (compact and math.min(usableHeight * (compactLandscape and 0.43 or 0.49), coverWidth * 0.72) or math.min(usableHeight * 0.54, coverWidth * 1.12)) -- 394
		local coverX = left + 16 -- 399
		local coverY = wide and bottom + (usableHeight - coverHeight) / 2 - 12 + landscapeTopLift or bottom + usableHeight - coverHeight - 82 -- 400
		local infoX = wide and coverX + coverWidth + 28 or left + 20 -- 401
		local infoWidth = wide and usableWidth - coverWidth - 72 or usableWidth - 40 -- 402
		local infoTop = wide and bottom + usableHeight - 122 + landscapeTopLift or coverY - (compactLandscape and 28 or 30) -- 403
		local descriptionY = infoTop - (compactLandscape and 38 or 58) -- 404
		local actionsY = bottom + (compactLandscape and 18 or 24) -- 405
		local gestureHintY = bottom + (compactLandscape and 88 or 92) -- 406
		local buttonWidth = wide and math.min(190, (infoWidth - 12) / 2) or (infoWidth - 12) / 2 -- 407
		local fontScale = mobileFontScale -- 408
		local cardIndices = getReusableCardIndices(index, #data) -- 409
		local headerRenderOrder = 1000 -- 410
		local ____toNode_51 = toNode -- 412
		local ____React_createElement_50 = React.createElement -- 412
		local ____array_49 = __TS__SparseArrayNew( -- 412
			"node", -- 412
			{ -- 412
				tag = "mobile-feed-scene", -- 412
				x = -width / 2, -- 412
				y = -height / 2, -- 412
				width = width, -- 412
				height = height, -- 412
				anchorX = 0, -- 412
				anchorY = 0, -- 412
				touchEnabled = true, -- 412
				onTapBegan = function() -- 412
					drag = Vec2.zero -- 422
					dragAxis = "none" -- 423
					local ____opt_21 = cardRef.current -- 423
					if ____opt_21 ~= nil then -- 423
						____opt_21:stopAllActions() -- 424
					end -- 424
					if indexRef.current then -- 424
						indexRef.current.opacity = 1 -- 425
					end -- 425
				end, -- 421
				onTapMoved = function(touch) -- 421
					drag = drag:add(touch.delta) -- 428
					if dragAxis == "none" and math.max( -- 428
						math.abs(drag.x), -- 429
						math.abs(drag.y) -- 429
					) >= 12 then -- 429
						dragAxis = math.abs(drag.x) > math.abs(drag.y) * 1.2 and "horizontal" or "vertical" -- 430
					end -- 430
					if cardRef.current then -- 430
						local offset = dragAxis == "horizontal" and Vec2(drag.x * 0.18, 0) or (dragAxis == "vertical" and Vec2(0, drag.y * 0.12) or Vec2.zero) -- 433
						cardRef.current.position = offset -- 434
						if indexRef.current then -- 434
							local headerBottom = bottom + usableHeight - 72 -- 436
							local indexTop = coverY + coverHeight - 14 + offset.y -- 437
							indexRef.current.opacity = dragAxis == "vertical" and math.max( -- 438
								0, -- 439
								math.min(1, (headerBottom - indexTop) / 16) -- 439
							) or 1 -- 439
						end -- 439
					end -- 439
				end, -- 427
				onTapEnded = function() -- 427
					local action = resolveFeedGesture(drag.x, drag.y, usableWidth, usableHeight) -- 445
					drag = Vec2.zero -- 446
					dragAxis = "none" -- 447
					if indexRef.current then -- 447
						indexRef.current.opacity = 1 -- 448
					end -- 448
					if action == "none" and cardRef.current then -- 448
						local card = cardRef.current -- 450
						card:perform(Move(App.reducedMotion and 0 or 0.16, card.position, Vec2.zero, Ease.OutQuad)) -- 451
					end -- 451
					commit(action) -- 453
				end, -- 444
				onMouseWheel = function(delta) return commit(delta.y > 0 and "previous" or "next") end -- 444
			}, -- 444
			React.createElement(VerticalGradient, {width = width, height = height, topColor = 4279310117, bottomColor = 4278716943}) -- 444
		) -- 444
		local ____React_createElement_47 = React.createElement -- 444
		local ____temp_45 = {visible = not projectIndexOpen} -- 444
		local ____createOpen_31 -- 459
		if createOpen then -- 459
			____createOpen_31 = nil -- 459
		else -- 459
			local ____temp_30 -- 459
			if item ~= nil then -- 459
				local ____React_createElement_29 = React.createElement -- 459
				local ____array_28 = __TS__SparseArrayNew( -- 459
					"node", -- 459
					{tag = "mobile-feed-card-" .. item.id, ref = cardRef, key = (tab .. "-") .. item.id}, -- 459
					__TS__ArrayMap( -- 460
						cardIndices, -- 460
						function(____, cardIndex) return React.createElement(Cover, { -- 460
							key = (tab .. "-") .. data[cardIndex + 1].id, -- 460
							entry = data[cardIndex + 1], -- 460
							x = coverX, -- 460
							y = coverY + (index - cardIndex) * usableHeight, -- 460
							width = coverWidth, -- 460
							height = coverHeight -- 460
						}) end -- 460
					) -- 460
				) -- 460
				local ____React_createElement_25 = React.createElement -- 460
				local ____array_24 = __TS__SparseArrayNew( -- 460
					"node", -- 460
					{ -- 460
						tag = "mobile-feed-index", -- 460
						ref = indexRef, -- 460
						order = 10, -- 460
						renderGroup = true, -- 460
						x = coverX + coverWidth - 62, -- 460
						y = coverY + coverHeight - 40, -- 460
						width = 48, -- 460
						height = 26, -- 460
						anchorX = 0, -- 460
						anchorY = 0, -- 460
						touchEnabled = tab == "local", -- 460
						swallowTouches = tab == "local", -- 460
						onTapped = tab == "local" and openProjectIndex or nil -- 460
					}, -- 460
					React.createElement( -- 460
						"clip-node", -- 460
						{ -- 460
							width = 48, -- 460
							height = 26, -- 460
							anchorX = 0, -- 460
							anchorY = 0, -- 460
							stencil = React.createElement(RoundedStencil, {width = 48, height = 26, radius = 13}) -- 460
						}, -- 460
						React.createElement( -- 460
							"draw-node", -- 460
							nil, -- 460
							React.createElement( -- 460
								"verts-shape", -- 460
								{verts = { -- 460
									{ -- 473
										Vec2(0, 0), -- 473
										3759281694 -- 473
									}, -- 473
									{ -- 473
										Vec2(48, 0), -- 473
										3759281694 -- 473
									}, -- 473
									{ -- 473
										Vec2(48, 26), -- 473
										3760730173 -- 473
									}, -- 473
									{ -- 474
										Vec2(0, 0), -- 474
										3759281694 -- 474
									}, -- 474
									{ -- 474
										Vec2(48, 26), -- 474
										3760730173 -- 474
									}, -- 474
									{ -- 474
										Vec2(0, 26), -- 474
										3760730173 -- 474
									} -- 474
								}} -- 474
							) -- 474
						) -- 474
					), -- 474
					React.createElement( -- 474
						"draw-node", -- 474
						{x = 0.5, y = 0.5}, -- 474
						React.createElement( -- 474
							"polygon-shape", -- 474
							{ -- 474
								verts = roundedRectVerts(47, 25, 12.5), -- 474
								fillColor = 0, -- 474
								borderWidth = 0.5, -- 474
								borderColor = 2286967404 -- 474
							} -- 474
						) -- 474
					) -- 474
				) -- 474
				local ____temp_23 -- 478
				if tab == "local" then -- 478
					____temp_23 = React.createElement( -- 478
						"draw-node", -- 478
						{x = 18, y = 2}, -- 478
						React.createElement( -- 478
							"polygon-shape", -- 478
							{ -- 478
								verts = roundedRectVerts(12, 2, 1), -- 478
								fillColor = colors.brand -- 478
							} -- 478
						) -- 478
					) -- 478
				else -- 478
					____temp_23 = nil -- 478
				end -- 478
				__TS__SparseArrayPush( -- 478
					____array_24, -- 478
					____temp_23, -- 478
					React.createElement( -- 478
						"label", -- 478
						{ -- 478
							x = 24, -- 478
							y = 13, -- 478
							fontName = fontName, -- 478
							fontSize = 11, -- 478
							text = (tostring(index + 1) .. " / ") .. tostring(#data), -- 478
							color3 = 14146531 -- 478
						} -- 478
					) -- 478
				) -- 478
				__TS__SparseArrayPush( -- 478
					____array_28, -- 478
					____React_createElement_25(__TS__SparseArraySpread(____array_24)), -- 478
					React.createElement( -- 478
						"label", -- 478
						{ -- 478
							tag = "mobile-feed-current-title", -- 478
							x = infoX, -- 478
							y = infoTop, -- 478
							anchorX = 0, -- 478
							anchorY = 0.5, -- 478
							fontName = fontName, -- 478
							fontSize = math.floor((wide and 30 or 25) * fontScale), -- 478
							text = item.title, -- 478
							textWidth = infoWidth - (item.kind == "local" and canShare and 92 or 0), -- 478
							alignment = "Left", -- 478
							color3 = 16052712 -- 478
						} -- 478
					) -- 478
				) -- 478
				local ____temp_26 -- 483
				if item.kind == "local" and canShare then -- 483
					____temp_26 = React.createElement( -- 483
						MobileButton, -- 483
						{ -- 483
							tag = "mobile-feed-share", -- 483
							x = infoX + infoWidth - 84, -- 483
							y = infoTop - 18, -- 483
							width = 84, -- 483
							height = 36, -- 483
							text = zh and "分享作品" or "Share", -- 483
							fontSize = 13, -- 483
							onTapped = function() return openPackage("share") end -- 483
						} -- 483
					) -- 483
				else -- 483
					____temp_26 = nil -- 483
				end -- 483
				__TS__SparseArrayPush( -- 483
					____array_28, -- 483
					____temp_26, -- 483
					React.createElement( -- 483
						"label", -- 483
						{ -- 483
							tag = "mobile-feed-description", -- 483
							x = infoX, -- 483
							y = descriptionY, -- 483
							anchorX = 0, -- 483
							anchorY = 0.5, -- 483
							fontName = fontName, -- 483
							fontSize = math.floor(15 * fontScale), -- 483
							text = conciseDescription(item.description, wide and 80 or (compact and 28 or 42)), -- 483
							textWidth = infoWidth, -- 483
							alignment = "Left", -- 483
							color3 = 11055037 -- 483
						} -- 483
					) -- 483
				) -- 483
				local ____temp_27 -- 486
				if compact or shortLandscape then -- 486
					____temp_27 = nil -- 486
				else -- 486
					____temp_27 = React.createElement( -- 486
						"node", -- 486
						{ -- 486
							x = infoX, -- 486
							y = infoTop - 118, -- 486
							width = wide and 176 or 164, -- 486
							height = 28, -- 486
							anchorX = 0, -- 486
							anchorY = 0 -- 486
						}, -- 486
						React.createElement(RoundedSurface, { -- 486
							width = wide and 176 or 164, -- 486
							height = 28, -- 486
							radius = 14, -- 486
							topColor = 1714436683, -- 486
							bottomColor = 1712857131, -- 486
							borderWidth = 1, -- 486
							borderColor = 2288020349 -- 486
						}), -- 486
						React.createElement("label", { -- 486
							x = 12, -- 486
							y = 14, -- 486
							anchorX = 0, -- 486
							fontName = fontName, -- 486
							fontSize = 12, -- 486
							text = item.kind == "local" and (zh and "本地作品  ·  可 Remix" or "Local  ·  Remixable") or (item.installed and (zh and "发现  ·  已安装" or "Discover  ·  Installed") or (zh and "发现  ·  可安装" or "Discover  ·  Installable")), -- 486
							textWidth = (wide and 176 or 164) - 24, -- 486
							alignment = "Left", -- 486
							color3 = 14475754 -- 486
						}) -- 486
					) -- 486
				end -- 486
				__TS__SparseArrayPush( -- 486
					____array_28, -- 486
					____temp_27, -- 486
					React.createElement( -- 486
						MobileButton, -- 492
						{ -- 492
							tag = "mobile-feed-remix", -- 492
							x = infoX, -- 492
							y = actionsY, -- 492
							width = buttonWidth, -- 492
							text = zh and "Remix 作品" or "Remix game", -- 492
							fontSize = math.floor(16 * fontScale), -- 492
							primary = true, -- 492
							onTapped = function() return activate("remix") end -- 492
						} -- 492
					), -- 492
					React.createElement( -- 492
						MobileButton, -- 494
						{ -- 494
							tag = "mobile-feed-play", -- 494
							x = infoX + buttonWidth + 12, -- 494
							y = actionsY, -- 494
							width = buttonWidth, -- 494
							text = zh and "试玩" or "Play", -- 494
							fontSize = math.floor(17 * fontScale), -- 494
							onTapped = function() return activate("play") end -- 494
						} -- 494
					), -- 494
					React.createElement("label", { -- 494
						tag = "mobile-feed-gesture-hint", -- 494
						x = infoX, -- 494
						y = gestureHintY, -- 494
						anchorX = 0, -- 494
						anchorY = 0.5, -- 494
						fontName = fontName, -- 494
						fontSize = gamepadUsed and 11 or 14, -- 494
						text = prepareStatus ~= "" and prepareStatus or (item.launchError ~= nil and item.launchError or (gamepadUsed and (zh and "↑↓ 浏览 · A 确认 · X Remix · Start 列表 · Y 新建" or "↑↓ Browse · A Select · X Remix · Start List · Y New") or (zh and "上滑浏览  ·  右滑 Remix  ·  左滑试玩" or "Swipe up  ·  right Remix  ·  left Play"))), -- 494
						textWidth = infoWidth, -- 494
						alignment = "Left", -- 494
						color3 = item.launchError ~= nil and 16739179 or 11055037 -- 494
					}) -- 494
				) -- 494
				____temp_30 = ____React_createElement_29(__TS__SparseArraySpread(____array_28)) -- 494
			else -- 494
				____temp_30 = React.createElement( -- 494
					"node", -- 494
					nil, -- 494
					React.createElement("label", { -- 494
						x = left + usableWidth / 2, -- 494
						y = bottom + usableHeight / 2 + 20, -- 494
						fontName = fontName, -- 494
						fontSize = 22, -- 494
						text = tab == "discover" and (zh and "暂无移动作品" or "No mobile games yet") or (zh and "没有可运行的本地作品" or "No runnable local games"), -- 494
						color3 = 16052712 -- 494
					}), -- 494
					React.createElement("label", { -- 494
						x = left + usableWidth / 2, -- 494
						y = bottom + usableHeight / 2 - 28, -- 494
						fontName = fontName, -- 494
						fontSize = 14, -- 494
						text = tab == "discover" and discoverError ~= "" and discoverError or (zh and "切换标签或稍后重试" or "Switch tabs or retry later"), -- 494
						textWidth = usableWidth - 48, -- 494
						color3 = tab == "discover" and discoverError ~= "" and 16739179 or 11055037 -- 494
					}) -- 494
				) -- 494
			end -- 494
			____createOpen_31 = ____temp_30 -- 459
		end -- 459
		local ____temp_32 -- 507
		if not createOpen and not item and tab == "local" then -- 507
			____temp_32 = React.createElement( -- 507
				"node", -- 507
				nil, -- 507
				React.createElement(MobileButton, { -- 507
					tag = "mobile-empty-new", -- 507
					x = left + 20, -- 507
					y = bottom + 24, -- 507
					width = (usableWidth - 52) / 2, -- 507
					text = zh and "新建作品" or "New game", -- 507
					onTapped = openCreate -- 507
				}), -- 507
				React.createElement( -- 507
					MobileButton, -- 509
					{ -- 509
						tag = "mobile-empty-import", -- 509
						x = left + 32 + (usableWidth - 52) / 2, -- 509
						y = bottom + 24, -- 509
						width = (usableWidth - 52) / 2, -- 509
						text = zh and "导入作品包" or "Import package", -- 509
						fontSize = 15, -- 509
						primary = true, -- 509
						onTapped = function() return openPackage("add", nil, true) end -- 509
					} -- 509
				) -- 509
			) -- 509
		else -- 509
			____temp_32 = nil -- 510
		end -- 510
		local ____React_createElement_36 = React.createElement -- 510
		local ____array_35 = __TS__SparseArrayNew("node", {tag = "mobile-feed-header", order = headerRenderOrder}) -- 510
		local ____options_onSwitchMode_33 -- 512
		if options.onSwitchMode then -- 512
			____options_onSwitchMode_33 = React.createElement( -- 512
				"node", -- 512
				{ -- 512
					tag = "mobile-ui-mode-switch", -- 512
					x = left + 12, -- 512
					y = bottom + usableHeight - 58 + landscapeTopLift, -- 512
					width = 72, -- 512
					height = 48, -- 512
					anchorX = 0, -- 512
					anchorY = 0, -- 512
					touchEnabled = true, -- 512
					swallowTouches = true, -- 512
					onTapped = switchMode -- 512
				}, -- 512
				React.createElement("label", { -- 512
					x = 0, -- 512
					y = 30, -- 512
					anchorX = 0, -- 512
					fontName = fontName, -- 512
					fontSize = 16, -- 512
					text = "DORA", -- 512
					color3 = preparing and 7831180 or 16763955 -- 512
				}), -- 512
				React.createElement("label", { -- 512
					x = 0, -- 512
					y = 10, -- 512
					anchorX = 0, -- 512
					fontName = fontName, -- 512
					fontSize = 10, -- 512
					text = zh and "切换传统界面" or "Classic UI", -- 512
					color3 = 7831180 -- 512
				}) -- 512
			) -- 512
		else -- 512
			____options_onSwitchMode_33 = nil -- 516
		end -- 516
		__TS__SparseArrayPush( -- 516
			____array_35, -- 516
			____options_onSwitchMode_33, -- 516
			React.createElement( -- 516
				"label", -- 516
				{ -- 516
					tag = "mobile-feed-discover-tab", -- 516
					x = left + usableWidth / 2 - 44, -- 516
					y = bottom + usableHeight - 34 + landscapeTopLift, -- 516
					fontName = fontName, -- 516
					fontSize = math.floor(17 * fontScale), -- 516
					text = zh and "发现" or "Discover", -- 516
					color3 = tab == "discover" and 16763955 or 11055037, -- 516
					touchEnabled = true, -- 516
					swallowTouches = true, -- 516
					onTapped = function() return setTab("discover") end -- 516
				} -- 516
			), -- 516
			React.createElement( -- 516
				"label", -- 516
				{ -- 516
					tag = "mobile-feed-local-tab", -- 516
					x = left + usableWidth / 2 + 44, -- 516
					y = bottom + usableHeight - 34 + landscapeTopLift, -- 516
					fontName = fontName, -- 516
					fontSize = math.floor(17 * fontScale), -- 516
					text = zh and "本地" or "Local", -- 516
					color3 = tab == "local" and 16763955 or 11055037, -- 516
					touchEnabled = true, -- 516
					swallowTouches = true, -- 516
					onTapped = function() -- 516
						____local = getLocalEntries() -- 522
						setTab("local") -- 522
					end -- 522
				} -- 522
			), -- 522
			React.createElement(RoundedSurface, { -- 522
				x = left + usableWidth / 2 + (tab == "discover" and -58 or 30), -- 522
				y = bottom + usableHeight - 56 + landscapeTopLift, -- 522
				width = 28, -- 522
				height = 3, -- 522
				radius = 1.5, -- 522
				fillColor = colors.brand, -- 522
				renderOrder = headerRenderOrder + 1 -- 522
			}) -- 522
		) -- 522
		local ____temp_34 -- 524
		if tab == "local" and options.createProject then -- 524
			____temp_34 = React.createElement( -- 524
				MobileNewButton, -- 524
				{ -- 524
					tag = "mobile-feed-create", -- 524
					x = left + usableWidth - 82, -- 524
					y = bottom + usableHeight - 56 + landscapeTopLift, -- 524
					text = zh and "+ 新建" or "+ New", -- 524
					renderOrder = headerRenderOrder + 1, -- 524
					onTapped = function() return openPackage("add") end -- 524
				} -- 524
			) -- 524
		else -- 524
			____temp_34 = nil -- 526
		end -- 526
		__TS__SparseArrayPush(____array_35, ____temp_34) -- 526
		local ____React_createElement_36_result_46 = ____React_createElement_36(__TS__SparseArraySpread(____array_35)) -- 526
		local ____createOpen_44 -- 528
		if createOpen then -- 528
			____createOpen_44 = (function() -- 528
				local sheetHeight = math.min(createSheetHeight, usableHeight - 64) -- 529
				local sheetWidth = usableWidth -- 530
				local contentWidth = sheetWidth - 40 -- 531
				local actionGap = 12 -- 532
				local actionsWidth = shortLandscape and math.min( -- 533
					300, -- 533
					math.floor(contentWidth * 0.42) -- 533
				) or contentWidth -- 533
				local inputWidth = shortLandscape and contentWidth - actionGap - actionsWidth or contentWidth -- 534
				local actionX = shortLandscape and 20 + inputWidth + actionGap or 20 -- 535
				local actionY = shortLandscape and sheetHeight - createInputTop - createInputHeight or 20 -- 536
				local cancelWidth = math.floor((actionsWidth - actionGap) * (shortLandscape and 0.34 or 0.38)) -- 537
				local ____React_createElement_43 = React.createElement -- 537
				local ____array_42 = __TS__SparseArrayNew( -- 537
					"node", -- 537
					{ -- 537
						tag = "mobile-project-create-sheet", -- 537
						order = 10000, -- 537
						width = width, -- 537
						height = height, -- 537
						anchorX = 0, -- 537
						anchorY = 0, -- 537
						touchEnabled = true, -- 537
						swallowTouches = true -- 537
					}, -- 537
					React.createElement( -- 537
						"node", -- 537
						{ -- 537
							tag = "mobile-project-create-focus-observer", -- 537
							order = 1000, -- 537
							width = width, -- 537
							height = height, -- 537
							anchorX = 0, -- 537
							anchorY = 0, -- 537
							touchEnabled = true, -- 537
							swallowTouches = false, -- 537
							swallowMouseWheel = false, -- 537
							onTapFilter = function(touch) -- 537
								touch.enabled = false -- 541
								if not canEditCreate() then -- 541
									return -- 542
								end -- 542
								local input = createInputRef.current -- 543
								local point = input and input:convertToNodeSpace(touch.worldLocation) -- 544
								local inside = input and point and point.x >= 0 and point.y >= 0 and point.x <= input.width and point.y <= input.height -- 545
								dismissedCreateComposition = not inside and createInput.isComposing() -- 546
								if not inside then -- 546
									blurCreateInput() -- 547
								end -- 547
							end -- 540
						} -- 540
					), -- 540
					React.createElement( -- 540
						"draw-node", -- 540
						{ -- 540
							tag = "mobile-project-create-backdrop", -- 540
							order = 0, -- 540
							renderOrder = 0, -- 540
							x = width / 2, -- 540
							y = bottom + sheetHeight + (height - bottom - sheetHeight) / 2 -- 540
						}, -- 540
						React.createElement("rect-shape", {width = width, height = height - bottom - sheetHeight, fillColor = 2348810240}) -- 540
					) -- 540
				) -- 540
				local ____React_createElement_41 = React.createElement -- 540
				local ____array_40 = __TS__SparseArrayNew( -- 540
					"node", -- 540
					{ -- 540
						ref = createPanelRef, -- 540
						order = 10, -- 540
						renderOrder = 10, -- 540
						x = left, -- 540
						y = bottom, -- 540
						width = sheetWidth, -- 540
						height = sheetHeight, -- 540
						anchorX = 0, -- 540
						anchorY = 0, -- 540
						touchEnabled = true, -- 540
						swallowTouches = true -- 540
					}, -- 540
					React.createElement(MobilePanelSurface, {width = sheetWidth, height = sheetHeight, renderOrder = 10}), -- 540
					React.createElement("label", { -- 540
						x = 20, -- 540
						y = sheetHeight - 24, -- 540
						anchorX = 0, -- 540
						anchorY = 1, -- 540
						fontName = fontName, -- 540
						fontSize = 22, -- 540
						text = zh and "新建项目" or "New project", -- 540
						color3 = 16052712 -- 540
					}), -- 540
					React.createElement("label", { -- 540
						x = 20, -- 540
						y = sheetHeight - 66, -- 540
						anchorX = 0, -- 540
						anchorY = 1, -- 540
						fontName = fontName, -- 540
						fontSize = 14, -- 540
						text = zh and "项目名称" or "Project name", -- 540
						color3 = 11055037 -- 540
					}) -- 540
				) -- 540
				local ____keptInput_39 -- 556
				if keptInput then -- 556
					____keptInput_39 = nil -- 556
				else -- 556
					____keptInput_39 = React.createElement("node", { -- 556
						tag = "mobile-project-create-input", -- 556
						ref = createInputRef, -- 556
						renderOrder = 10, -- 556
						x = 20, -- 556
						y = sheetHeight - createInputTop - createInputHeight, -- 556
						width = inputWidth, -- 556
						height = createInputHeight, -- 556
						anchorX = 0, -- 556
						anchorY = 0, -- 556
						onMount = createInput.mount -- 556
					}) -- 556
				end -- 556
				__TS__SparseArrayPush( -- 556
					____array_40, -- 556
					____keptInput_39, -- 556
					React.createElement("label", { -- 556
						tag = "mobile-project-create-error", -- 556
						x = 20, -- 556
						y = shortLandscape and sheetHeight - createInputTop + 12 or sheetHeight - createInputTop - createInputHeight - 12, -- 556
						anchorX = 0, -- 556
						anchorY = 1, -- 556
						fontName = fontName, -- 556
						fontSize = 12, -- 556
						text = createError ~= "" and createError or (zh and "将创建可运行的 TypeScript 起始项目" or "Creates a runnable TypeScript starter project"), -- 556
						textWidth = inputWidth, -- 556
						alignment = "Left", -- 556
						color3 = createError ~= "" and 16739179 or 11055037 -- 556
					}), -- 556
					React.createElement(MobileButton, { -- 556
						tag = "mobile-project-create-cancel", -- 556
						x = actionX, -- 556
						y = actionY, -- 556
						width = cancelWidth, -- 556
						text = zh and "取消" or "Cancel", -- 556
						renderOrder = 10, -- 556
						onTapped = closeCreate -- 556
					}), -- 556
					React.createElement( -- 556
						MobileButton, -- 562
						{ -- 562
							tag = "mobile-project-create-submit", -- 562
							x = actionX + cancelWidth + actionGap, -- 562
							y = actionY, -- 562
							width = actionsWidth - cancelWidth - actionGap, -- 562
							text = creating and (zh and "创建中…" or "Creating…") or (zh and "创建并进入 Remix" or "Create and Remix"), -- 562
							primary = true, -- 562
							renderOrder = 10, -- 562
							onTapped = function() -- 562
								if not dismissedCreateComposition then -- 562
									submitCreate() -- 563
								end -- 563
								dismissedCreateComposition = false -- 563
							end -- 563
						} -- 563
					) -- 563
				) -- 563
				__TS__SparseArrayPush( -- 563
					____array_42, -- 563
					____React_createElement_41(__TS__SparseArraySpread(____array_40)) -- 563
				) -- 563
				return ____React_createElement_43(__TS__SparseArraySpread(____array_42)) -- 538
			end)() -- 528
		else -- 528
			____createOpen_44 = nil -- 566
		end -- 566
		__TS__SparseArrayPush( -- 566
			____array_49, -- 566
			____React_createElement_47( -- 566
				"node", -- 566
				____temp_45, -- 566
				____createOpen_31, -- 566
				____temp_32, -- 566
				____React_createElement_36_result_46, -- 566
				____createOpen_44 -- 566
			) -- 566
		) -- 566
		local ____projectIndexOpen_48 -- 568
		if projectIndexOpen then -- 568
			____projectIndexOpen_48 = React.createElement( -- 568
				ProjectIndex, -- 568
				{ -- 568
					entries = ____local, -- 568
					current = current(), -- 568
					x = left, -- 568
					y = bottom, -- 568
					width = usableWidth, -- 568
					height = usableHeight, -- 568
					zh = zh, -- 568
					onClose = function() -- 568
						projectIndexOpen = false -- 569
						render() -- 569
					end, -- 569
					onSelect = function(____, entry) -- 569
						projectIndexOpen = false -- 571
						local location = resolveFeedLocation(____local, discover, entry) -- 572
						tab = "local" -- 573
						index = location.tab == "local" and location.index or 0 -- 573
						render() -- 574
					end -- 570
				} -- 570
			) -- 570
		else -- 570
			____projectIndexOpen_48 = nil -- 575
		end -- 575
		__TS__SparseArrayPush(____array_49, ____projectIndexOpen_48) -- 575
		local scene = ____toNode_51(____React_createElement_50(__TS__SparseArraySpread(____array_49))) -- 412
		if scene ~= nil then -- 412
			host:addChild(scene) -- 577
		end -- 577
		if keptInput and createPanelRef.current then -- 577
			keptInput.position = Vec2( -- 579
				20, -- 579
				math.min(createSheetHeight, usableHeight - 64) - createInputTop - createInputHeight -- 579
			) -- 579
			createPanelRef.current:addChild(keptInput) -- 580
		end -- 580
		createInput.refresh() -- 582
		if restoreFocus and not keptInput and createOpen then -- 582
			createInput.focus(false) -- 583
		end -- 583
	end -- 361
	attachGamepad( -- 586
		host, -- 586
		{ -- 586
			initialTag = "mobile-feed-play", -- 587
			isEnabled = function() return isActive() and not packagePanel and not preparing and not transitioning and not creating end, -- 588
			onActive = function() -- 589
				gamepadUsed = true -- 589
				render() -- 589
			end, -- 589
			onBack = function() -- 590
				if createInput.isFocused() then -- 590
					blurCreateInput() -- 590
				elseif createOpen then -- 590
					closeCreate() -- 590
				else -- 590
					switchMode() -- 590
				end -- 590
			end, -- 590
			onActivate = function(target) -- 591
				if target.tag == "mobile-project-create-input" then -- 591
					target:emit("GamepadActivate") -- 592
				else -- 592
					if createInput.isComposing() then -- 592
						blurCreateInput() -- 594
						return -- 594
					end -- 594
					blurCreateInput() -- 595
					dismissedCreateComposition = false -- 596
					target:emit("Tapped") -- 597
				end -- 597
			end, -- 591
			onButton = function(button) -- 600
				if createOpen then -- 600
					return false -- 601
				end -- 601
				repeat -- 601
					local ____switch121 = button -- 601
					local ____cond121 = ____switch121 == "dpup" -- 601
					if ____cond121 then -- 601
						commit("previous") -- 603
						return true -- 603
					end -- 603
					____cond121 = ____cond121 or ____switch121 == "dpdown" -- 603
					if ____cond121 then -- 603
						commit("next") -- 604
						return true -- 604
					end -- 604
					____cond121 = ____cond121 or ____switch121 == "leftshoulder" -- 604
					if ____cond121 then -- 604
						setTab("discover") -- 605
						return true -- 605
					end -- 605
					____cond121 = ____cond121 or ____switch121 == "rightshoulder" -- 605
					if ____cond121 then -- 605
						setTab("local") -- 606
						return true -- 606
					end -- 606
					____cond121 = ____cond121 or ____switch121 == "x" -- 606
					if ____cond121 then -- 606
						commit("remix") -- 607
						return true -- 607
					end -- 607
					____cond121 = ____cond121 or ____switch121 == "y" -- 607
					if ____cond121 then -- 607
						local ____opt_52 = findGamepadNode(host, "mobile-feed-create") -- 607
						if ____opt_52 ~= nil then -- 607
							____opt_52:emit("Tapped") -- 608
						end -- 608
						return true -- 608
					end -- 608
					____cond121 = ____cond121 or ____switch121 == "start" -- 608
					if ____cond121 then -- 608
						openProjectIndex() -- 609
						return true -- 609
					end -- 609
					do -- 609
						return false -- 610
					end -- 610
				until true -- 610
			end -- 600
		} -- 600
	) -- 600
	host:onAppChange(function(setting) -- 614
		if setting == "Locale" then -- 614
			local activeEntry = current() -- 616
			zh = (string.match(App.locale, "^zh")) ~= nil -- 617
			____local = getLocalEntries() -- 618
			discover = getDiscoverEntries() -- 619
			local location = resolveFeedLocation(____local, discover, activeEntry) -- 620
			tab = location.tab -- 621
			index = location.index -- 622
			render() -- 623
		elseif setting == "Size" then -- 623
			render() -- 624
		end -- 624
	end) -- 614
	host:onAppEvent(function(event) -- 626
		if event == "BackButton" then -- 626
			if projectIndexOpen then -- 626
				projectIndexOpen = false -- 628
				render() -- 628
			elseif createOpen and not creating then -- 628
				closeCreate() -- 629
			end -- 629
		elseif event == "WillEnterBackground" or event == "DidEnterBackground" then -- 629
			blurCreateInput() -- 630
		end -- 630
	end) -- 626
	host:onCleanup(function() -- 632
		blurCreateInput() -- 632
		active = false -- 632
		if packagePanel ~= nil then -- 632
			packagePanel:removeFromParent(true) -- 632
		end -- 632
		packagePanel = nil -- 632
	end) -- 632
	host:slot( -- 633
		"RestoreFeedEntry", -- 633
		function(entry) -- 633
			if not isActive() or HttpServer.wsConnectionCount > 0 then -- 633
				return -- 634
			end -- 634
			returnEntry = entry -- 635
			____local = getLocalEntries() -- 636
			discover = getDiscoverEntries() -- 637
			local location = resolveFeedLocation(____local, discover, entry) -- 638
			tab = location.tab -- 639
			index = location.index -- 640
			render() -- 641
		end -- 633
	) -- 633
	host:slot("SuspendLocalUI", blurCreateInput) -- 643
	host:slot( -- 644
		"ResumeLocalUI", -- 644
		function() -- 644
			leaving = false -- 644
			render() -- 644
		end -- 644
	) -- 644
	render() -- 645
	if syncDiscover then -- 645
		if #discover == 0 then -- 645
			discoverError = zh and "正在同步资源目录…" or "Syncing Catalog…" -- 648
			render() -- 649
		end -- 649
		syncDiscover( -- 651
			function(message) -- 651
				if not isActive() or #discover > 0 then -- 651
					return -- 652
				end -- 652
				discoverError = message -- 653
				render() -- 654
			end, -- 651
			function(success, message) -- 655
				if not isActive() then -- 655
					return -- 656
				end -- 656
				local selected = returnEntry or rememberedEntries[tab] or current() -- 657
				local previousCount = #discover -- 658
				discover = getDiscoverEntries() -- 659
				discoverError = success and (#discover == 0 and (zh and "目录中暂无可运行作品" or "No runnable Catalog games") or "") or (message or (zh and "资源目录同步失败" or "Catalog sync failed")) -- 660
				tab = resolveDiscoverRefreshTab( -- 663
					tab, -- 663
					userSelectedTab, -- 663
					previousCount, -- 663
					#discover, -- 663
					#____local -- 663
				) -- 663
				if selected ~= nil then -- 663
					local location = resolveFeedLocation(____local, discover, selected) -- 665
					tab = location.tab -- 666
					index = location.index -- 667
				end -- 667
				if tab == "discover" then -- 667
					index = normalizeFeedIndex(index, #discover) -- 669
				end -- 669
				render() -- 670
			end -- 655
		) -- 655
	end -- 655
	return host -- 673
end -- 97
return ____exports -- 97