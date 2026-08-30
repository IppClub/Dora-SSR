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
local colors = { -- 24
	background = 4278914322, -- 25
	panel = 4279572770, -- 26
	panelRaised = 4280297010, -- 27
	text = 4294242792, -- 28
	muted = 4289245117, -- 29
	brand = 4294954035, -- 30
	border = 4281613128, -- 31
	danger = 4294929259 -- 32
} -- 32
local fontName = "sarasa-mono-sc-regular" -- 35
local function Button(props) -- 37
	return React.createElement( -- 47
		"node", -- 47
		{ -- 47
			tag = props.tag, -- 47
			x = props.x, -- 47
			y = props.y, -- 47
			anchorX = 0, -- 47
			anchorY = 0, -- 47
			width = props.width, -- 47
			height = 48, -- 47
			touchEnabled = true, -- 47
			swallowTouches = true, -- 47
			onTapped = props.onTapped -- 47
		}, -- 47
		React.createElement( -- 47
			"draw-node", -- 47
			{x = props.width / 2, y = 24}, -- 47
			React.createElement("rect-shape", { -- 47
				width = props.width, -- 47
				height = 48, -- 47
				fillColor = props.primary and colors.brand or colors.panelRaised, -- 47
				borderWidth = 1, -- 47
				borderColor = props.primary and colors.brand or colors.border -- 47
			}) -- 47
		), -- 47
		React.createElement("label", { -- 47
			x = props.width / 2, -- 47
			y = 24, -- 47
			fontName = fontName, -- 47
			fontSize = props.fontSize or 17, -- 47
			text = props.text, -- 47
			color3 = props.primary and 1512202 or 16052712 -- 47
		}) -- 47
	) -- 47
end -- 37
local function Cover(props) -- 79
	local file = props.entry.bannerFile -- 80
	local function scaleSprite(sprite, mode) -- 81
		local scales = getCoverScales(sprite.width, sprite.height, props.width, props.height) -- 82
		sprite.scaleX = scales[mode] -- 83
		sprite.scaleY = scales[mode] -- 84
	end -- 81
	local ____React_createElement_5 = React.createElement -- 81
	local ____temp_3 = { -- 81
		x = props.x, -- 81
		y = props.y, -- 81
		width = props.width, -- 81
		height = props.height, -- 81
		anchorX = 0, -- 81
		anchorY = 0 -- 81
	} -- 81
	local ____React_createElement_result_4 = React.createElement( -- 81
		"draw-node", -- 81
		{x = props.width / 2, y = props.height / 2}, -- 81
		React.createElement( -- 81
			"rect-shape", -- 81
			{ -- 81
				width = props.width, -- 81
				height = props.height, -- 81
				fillColor = stableCoverColor(props.entry.id), -- 81
				borderWidth = 1, -- 81
				borderColor = colors.border -- 81
			} -- 81
		) -- 81
	) -- 81
	local ____file_0 -- 96
	if file then -- 96
		____file_0 = React.createElement( -- 96
			"clip-node", -- 96
			{ -- 96
				width = props.width, -- 96
				height = props.height, -- 96
				anchorX = 0, -- 96
				anchorY = 0, -- 96
				stencil = React.createElement( -- 96
					"draw-node", -- 96
					{x = props.width / 2, y = props.height / 2}, -- 96
					React.createElement("rect-shape", {width = props.width, height = props.height, fillColor = 4294967295}) -- 96
				) -- 96
			}, -- 96
			React.createElement( -- 96
				"sprite", -- 96
				{ -- 96
					file = file, -- 96
					x = props.width / 2 - 5, -- 96
					y = props.height / 2, -- 96
					opacity = 0.08, -- 96
					onMount = function(sprite) return scaleSprite(sprite, "cover") end -- 96
				} -- 96
			), -- 96
			React.createElement( -- 96
				"sprite", -- 96
				{ -- 96
					file = file, -- 96
					x = props.width / 2 + 5, -- 96
					y = props.height / 2, -- 96
					opacity = 0.08, -- 96
					onMount = function(sprite) return scaleSprite(sprite, "cover") end -- 96
				} -- 96
			), -- 96
			React.createElement( -- 96
				"sprite", -- 96
				{ -- 96
					file = file, -- 96
					x = props.width / 2, -- 96
					y = props.height / 2 - 5, -- 96
					opacity = 0.08, -- 96
					onMount = function(sprite) return scaleSprite(sprite, "cover") end -- 96
				} -- 96
			), -- 96
			React.createElement( -- 96
				"draw-node", -- 96
				{x = props.width / 2, y = props.height / 2}, -- 96
				React.createElement("rect-shape", {width = props.width, height = props.height, fillColor = 2953514258}) -- 96
			), -- 96
			React.createElement( -- 96
				"sprite", -- 96
				{ -- 96
					file = file, -- 96
					x = props.width / 2, -- 96
					y = props.height / 2, -- 96
					onMount = function(sprite) return scaleSprite(sprite, "contain") end -- 96
				} -- 96
			) -- 96
		) -- 96
	else -- 96
		____file_0 = React.createElement( -- 96
			"label", -- 96
			{ -- 96
				x = props.width / 2, -- 96
				y = props.height / 2 + 10, -- 96
				fontName = fontName, -- 96
				fontSize = math.floor(math.max( -- 96
					22, -- 110
					math.min(34, props.width / 12) -- 110
				)), -- 110
				text = props.entry.title, -- 110
				textWidth = props.width - 40, -- 110
				color3 = 16052712 -- 110
			} -- 110
		) -- 110
	end -- 110
	local ____file_1 -- 115
	if file then -- 115
		____file_1 = nil -- 115
	else -- 115
		____file_1 = React.createElement("label", { -- 115
			x = props.width / 2, -- 115
			y = 30, -- 115
			fontName = fontName, -- 115
			fontSize = 14, -- 115
			text = "DORA SSR · REMIXABLE", -- 115
			color3 = 16763955 -- 115
		}) -- 115
	end -- 115
	local ____file_2 -- 123
	if file then -- 123
		____file_2 = nil -- 123
	else -- 123
		____file_2 = React.createElement(DoraMascot, {state = "idle", x = props.width - 46, y = 64, size = 42}) -- 123
	end -- 123
	return ____React_createElement_5( -- 86
		"node", -- 86
		____temp_3, -- 86
		____React_createElement_result_4, -- 86
		____file_0, -- 86
		____file_1, -- 86
		____file_2 -- 86
	) -- 86
end -- 79
function ____exports.startMobileFeed(options) -- 127
	local render -- 127
	local getLocalEntries = options.getLocalEntries -- 128
	local getDiscoverEntries = options.getDiscoverEntries -- 129
	local onPlay = options.onPlay -- 130
	local onRemix = options.onRemix -- 131
	local prepare = options.prepare -- 132
	local syncDiscover = options.syncDiscover -- 133
	local zh = (string.match(App.locale, "^zh")) ~= nil -- 134
	local tab = "local" -- 135
	local index = 0 -- 136
	local detailsOpen = false -- 137
	local drag = Vec2.zero -- 138
	local dragAxis = "none" -- 139
	local discoverError = "" -- 140
	local preparing = false -- 141
	local transitioning = false -- 142
	local prepareStatus = "" -- 143
	local repairResourceId = "" -- 144
	local userSelectedTab = false -- 145
	local active = true -- 146
	local leaving = false -- 147
	local returnEntry = options.initialEntry -- 148
	local cardRef = reference() -- 149
	local discover = getDiscoverEntries() -- 150
	local ____local = getLocalEntries() -- 151
	if #discover == 0 then -- 151
		discoverError = zh and "资源目录暂不可用" or "Catalog is unavailable" -- 154
	end -- 154
	local initialLocation = resolveFeedLocation(____local, discover, returnEntry) -- 156
	tab = initialLocation.tab -- 157
	index = initialLocation.index -- 158
	local host = Node() -- 160
	host.tag = "mobile-feed" -- 161
	host.scaleX = App.devicePixelRatio -- 162
	host.scaleY = App.devicePixelRatio -- 163
	host:addTo(Director.systemUI) -- 164
	local function isActive() -- 166
		return active and not leaving and host.parent ~= nil -- 166
	end -- 166
	local function entries() -- 168
		return tab == "discover" and discover or ____local -- 168
	end -- 168
	local function current() -- 169
		return entries()[normalizeFeedIndex( -- 169
			index, -- 169
			#entries() -- 169
		) + 1] -- 169
	end -- 169
	local function setTab(next) -- 171
		if not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 or preparing then -- 171
			return -- 172
		end -- 172
		userSelectedTab = true -- 173
		returnEntry = nil -- 174
		if tab == next then -- 174
			return -- 175
		end -- 175
		tab = next -- 176
		index = 0 -- 177
		detailsOpen = false -- 178
		render() -- 179
	end -- 171
	local function activate(action) -- 181
		local item = current() -- 182
		if not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 or not item or preparing then -- 182
			return -- 183
		end -- 183
		item.launchError = nil -- 184
		local function done() -- 185
			returnEntry = item -- 185
			local ____temp_6 -- 185
			if action == "play" then -- 185
				____temp_6 = onPlay(item) -- 185
			else -- 185
				____temp_6 = onRemix(item) -- 185
			end -- 185
			return ____temp_6 -- 185
		end -- 185
		if item.kind == "local" or item.installed then -- 185
			done() -- 186
			return -- 186
		end -- 186
		preparing = true -- 187
		prepareStatus = zh and "准备安装…" or "Preparing install…" -- 188
		render() -- 189
		local repairIncomplete = repairResourceId == item.id -- 190
		repairResourceId = "" -- 191
		prepare( -- 192
			item, -- 192
			repairIncomplete, -- 192
			function(progress, message) -- 192
				if not isActive() then -- 192
					return -- 193
				end -- 193
				prepareStatus = (tostring(math.floor(progress * 100)) .. "% · ") .. message -- 194
				render() -- 195
			end, -- 192
			function(success, ready, message, repairable) -- 196
				if not isActive() then -- 196
					return -- 197
				end -- 197
				preparing = false -- 198
				if not success or not ready then -- 198
					repairResourceId = repairable and item.id or "" -- 200
					prepareStatus = message or (zh and "安装失败，点击按钮重试" or "Install failed; tap to retry") -- 201
					render() -- 202
					return -- 203
				end -- 203
				item.fileName = ready.fileName -- 205
				item.workDir = ready.workDir -- 206
				item.installed = true -- 207
				prepareStatus = "" -- 208
				if HttpServer.wsConnectionCount == 0 and host.visible then -- 208
					done() -- 209
				else -- 209
					render() -- 210
				end -- 210
			end -- 196
		) -- 196
	end -- 181
	local function commit(action) -- 214
		if not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 or preparing or transitioning then -- 214
			return -- 215
		end -- 215
		if action == "play" or action == "remix" then -- 215
			local card = cardRef.current -- 217
			if card then -- 217
				card.position = Vec2.zero -- 218
			end -- 218
		end -- 218
		repeat -- 218
			local ____switch32 = action -- 218
			local ____cond32 = ____switch32 == "previous" or ____switch32 == "next" -- 218
			if ____cond32 then -- 218
				do -- 218
					returnEntry = nil -- 223
					local target = normalizeFeedIndex( -- 224
						index + (action == "next" and 1 or -1), -- 224
						#entries() -- 224
					) -- 224
					if target == index then -- 224
						local card = cardRef.current -- 226
						if card then -- 226
							card:perform(Move(App.reducedMotion and 0 or 0.16, card.position, Vec2.zero, Ease.OutQuad)) -- 227
						end -- 227
						return -- 228
					end -- 228
					local duration = App.reducedMotion and 0 or 0.18 -- 230
					local function finish() -- 231
						if not isActive() then -- 231
							return -- 232
						end -- 232
						index = target -- 233
						transitioning = false -- 234
						App:vibrate(0.012) -- 235
						detailsOpen = false -- 236
						render() -- 237
					end -- 231
					local card = cardRef.current -- 239
					if duration > 0 and card then -- 239
						transitioning = true -- 241
						card:perform(Move( -- 242
							duration, -- 242
							card.position, -- 242
							Vec2(0, (action == "next" and 1 or -1) * App.safeArea.height), -- 242
							Ease.OutQuad -- 242
						)) -- 242
						thread(function() -- 243
							sleep(duration) -- 243
							finish() -- 243
						end) -- 243
					else -- 243
						finish() -- 244
					end -- 244
					return -- 245
				end -- 245
			end -- 245
			____cond32 = ____cond32 or ____switch32 == "play" -- 245
			if ____cond32 then -- 245
				activate("play") -- 247
				return -- 247
			end -- 247
			____cond32 = ____cond32 or ____switch32 == "remix" -- 247
			if ____cond32 then -- 247
				activate("remix") -- 248
				return -- 248
			end -- 248
			do -- 248
				return -- 249
			end -- 249
		until true -- 249
	end -- 214
	local function switchMode() -- 253
		if not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 or preparing or transitioning or not options.onSwitchMode then -- 253
			return -- 254
		end -- 254
		leaving = true -- 255
		options.onSwitchMode() -- 256
	end -- 253
	host:slot("SwitchUIMode", switchMode) -- 258
	render = function() -- 259
		if not isActive() then -- 259
			return -- 260
		end -- 260
		host:removeAllChildren() -- 261
		host.scaleX = App.devicePixelRatio -- 262
		host.scaleY = App.devicePixelRatio -- 263
		local ____App_visualSize_7 = App.visualSize -- 264
		local width = ____App_visualSize_7.width -- 264
		local height = ____App_visualSize_7.height -- 264
		local safe = App.safeArea -- 265
		local left = safe.left -- 266
		local bottom = safe.bottom -- 267
		local usableWidth = safe.width -- 268
		local usableHeight = safe.height -- 269
		local wide = usableWidth >= 760 -- 270
		local data = entries() -- 271
		index = normalizeFeedIndex(index, #data) -- 272
		local item = current() -- 273
		local coverWidth = wide and math.min(usableWidth * 0.54, 680) or usableWidth - 32 -- 274
		local coverHeight = wide and math.min(usableHeight - 118, coverWidth * 0.72) or math.min(usableHeight * 0.49, coverWidth * 0.72) -- 275
		local coverX = left + 16 -- 276
		local coverY = wide and bottom + (usableHeight - coverHeight) / 2 - 12 or bottom + usableHeight - coverHeight - 82 -- 277
		local infoX = wide and coverX + coverWidth + 28 or left + 20 -- 278
		local infoWidth = wide and usableWidth - coverWidth - 72 or usableWidth - 40 -- 279
		local infoTop = wide and bottom + usableHeight - 122 or coverY - 30 -- 280
		local buttonWidth = wide and math.min(190, (infoWidth - 12) / 2) or (infoWidth - 12) / 2 -- 281
		local fontScale = mobileFontScale -- 282
		local cardIndices = getReusableCardIndices(index, #data) -- 283
		local ____toNode_17 = toNode -- 285
		local ____React_createElement_16 = React.createElement -- 285
		local ____array_15 = __TS__SparseArrayNew( -- 285
			"node", -- 285
			{ -- 285
				tag = "mobile-feed-scene", -- 285
				x = -width / 2, -- 285
				y = -height / 2, -- 285
				width = width, -- 285
				height = height, -- 285
				anchorX = 0, -- 285
				anchorY = 0, -- 285
				touchEnabled = true, -- 285
				onTapBegan = function() -- 285
					drag = Vec2.zero -- 294
					dragAxis = "none" -- 294
					local ____opt_8 = cardRef.current -- 294
					if ____opt_8 ~= nil then -- 294
						____opt_8:stopAllActions() -- 294
					end -- 294
				end, -- 294
				onTapMoved = function(touch) -- 294
					drag = drag:add(touch.delta) -- 296
					if dragAxis == "none" and math.max( -- 296
						math.abs(drag.x), -- 297
						math.abs(drag.y) -- 297
					) >= 12 then -- 297
						dragAxis = math.abs(drag.x) > math.abs(drag.y) * 1.2 and "horizontal" or "vertical" -- 298
					end -- 298
					if cardRef.current then -- 298
						cardRef.current.position = dragAxis == "horizontal" and Vec2(drag.x * 0.18, 0) or (dragAxis == "vertical" and Vec2(0, drag.y * 0.12) or Vec2.zero) -- 301
					end -- 301
				end, -- 295
				onTapEnded = function() -- 295
					local action = resolveFeedGesture(drag.x, drag.y, usableWidth, usableHeight) -- 305
					drag = Vec2.zero -- 306
					dragAxis = "none" -- 307
					if action == "none" and cardRef.current then -- 307
						local card = cardRef.current -- 309
						card:perform(Move(App.reducedMotion and 0 or 0.16, card.position, Vec2.zero, Ease.OutQuad)) -- 310
					end -- 310
					commit(action) -- 312
				end, -- 304
				onMouseWheel = function(delta) return commit(delta.y > 0 and "previous" or "next") end -- 304
			}, -- 304
			React.createElement( -- 304
				"draw-node", -- 304
				{x = width / 2, y = height / 2}, -- 304
				React.createElement("rect-shape", {width = width, height = height, fillColor = colors.background}) -- 304
			) -- 304
		) -- 304
		local ____options_onSwitchMode_10 -- 319
		if options.onSwitchMode then -- 319
			____options_onSwitchMode_10 = React.createElement( -- 319
				"node", -- 319
				{ -- 319
					tag = "mobile-ui-mode-switch", -- 319
					x = left + 12, -- 319
					y = bottom + usableHeight - 56, -- 319
					width = 72, -- 319
					height = 44, -- 319
					anchorX = 0, -- 319
					anchorY = 0, -- 319
					touchEnabled = true, -- 319
					swallowTouches = true, -- 319
					onTapped = switchMode -- 319
				}, -- 319
				React.createElement( -- 319
					"draw-node", -- 319
					{x = 36, y = 22}, -- 319
					React.createElement("rect-shape", { -- 319
						width = 72, -- 319
						height = 44, -- 319
						fillColor = colors.panelRaised, -- 319
						borderWidth = 1, -- 319
						borderColor = colors.border -- 319
					}) -- 319
				), -- 319
				React.createElement("label", { -- 319
					x = 36, -- 319
					y = 22, -- 319
					fontName = fontName, -- 319
					fontSize = 13, -- 319
					text = zh and "传统模式" or "Classic UI", -- 319
					color3 = preparing and 7831180 or 16052712 -- 319
				}) -- 319
			) -- 319
		else -- 319
			____options_onSwitchMode_10 = nil -- 323
		end -- 323
		__TS__SparseArrayPush( -- 323
			____array_15, -- 323
			____options_onSwitchMode_10, -- 323
			React.createElement( -- 323
				"label", -- 323
				{ -- 323
					tag = "mobile-feed-discover-tab", -- 323
					x = left + usableWidth / 2 - (options.onSwitchMode and 40 or 70), -- 323
					y = bottom + usableHeight - 34, -- 323
					fontName = fontName, -- 323
					fontSize = math.floor(18 * fontScale), -- 323
					text = zh and "发现" or "Discover", -- 323
					color3 = tab == "discover" and 16763955 or 11055037, -- 323
					touchEnabled = true, -- 323
					swallowTouches = true, -- 323
					onTapped = function() return setTab("discover") end -- 323
				} -- 323
			), -- 323
			React.createElement( -- 323
				"label", -- 323
				{ -- 323
					tag = "mobile-feed-local-tab", -- 323
					x = left + usableWidth / 2 + (options.onSwitchMode and 56 or 70), -- 323
					y = bottom + usableHeight - 34, -- 323
					fontName = fontName, -- 323
					fontSize = math.floor(18 * fontScale), -- 323
					text = zh and "本地" or "Local", -- 323
					color3 = tab == "local" and 16763955 or 11055037, -- 323
					touchEnabled = true, -- 323
					swallowTouches = true, -- 323
					onTapped = function() -- 323
						____local = getLocalEntries() -- 329
						setTab("local") -- 329
					end -- 329
				} -- 329
			) -- 329
		) -- 329
		local ____temp_14 -- 330
		if item ~= nil then -- 330
			local ____React_createElement_13 = React.createElement -- 330
			local ____array_12 = __TS__SparseArrayNew( -- 330
				"node", -- 330
				{tag = "mobile-feed-card-" .. item.id, ref = cardRef, key = (tab .. "-") .. item.id}, -- 330
				__TS__ArrayMap( -- 331
					cardIndices, -- 331
					function(____, cardIndex) return React.createElement(Cover, { -- 331
						key = (tab .. "-") .. data[cardIndex + 1].id, -- 331
						entry = data[cardIndex + 1], -- 331
						x = coverX, -- 331
						y = coverY + (index - cardIndex) * usableHeight, -- 331
						width = coverWidth, -- 331
						height = coverHeight -- 331
					}) end -- 331
				), -- 331
				React.createElement( -- 331
					"label", -- 331
					{ -- 331
						tag = "mobile-feed-current-title", -- 331
						x = infoX, -- 331
						y = infoTop, -- 331
						anchorX = 0, -- 331
						anchorY = 0.5, -- 331
						fontName = fontName, -- 331
						fontSize = math.floor((wide and 30 or 25) * fontScale), -- 331
						text = item.title, -- 331
						textWidth = infoWidth, -- 331
						alignment = "Left", -- 331
						color3 = 16052712 -- 331
					} -- 331
				), -- 331
				React.createElement( -- 331
					"label", -- 331
					{ -- 331
						x = infoX, -- 331
						y = infoTop - 58, -- 331
						anchorX = 0, -- 331
						anchorY = 0.5, -- 331
						fontName = fontName, -- 331
						fontSize = math.floor(15 * fontScale), -- 331
						text = item.description, -- 331
						textWidth = infoWidth, -- 331
						alignment = "Left", -- 331
						color3 = 11055037 -- 331
					} -- 331
				), -- 331
				React.createElement( -- 331
					Button, -- 343
					{ -- 343
						tag = "mobile-feed-remix", -- 343
						x = infoX, -- 343
						y = bottom + 24, -- 343
						width = buttonWidth, -- 343
						text = zh and "Remix" or "Remix", -- 343
						fontSize = math.floor(17 * fontScale), -- 343
						primary = true, -- 343
						onTapped = function() return activate("remix") end -- 343
					} -- 343
				), -- 343
				React.createElement( -- 343
					Button, -- 345
					{ -- 345
						tag = "mobile-feed-play", -- 345
						x = infoX + buttonWidth + 12, -- 345
						y = bottom + 24, -- 345
						width = buttonWidth, -- 345
						text = zh and "试玩" or "Play", -- 345
						fontSize = math.floor(17 * fontScale), -- 345
						onTapped = function() return activate("play") end -- 345
					} -- 345
				), -- 345
				React.createElement( -- 345
					"label", -- 345
					{ -- 345
						x = infoX, -- 345
						y = bottom + 92, -- 345
						anchorX = 0, -- 345
						anchorY = 0.5, -- 345
						fontName = fontName, -- 345
						fontSize = 14, -- 345
						text = prepareStatus ~= "" and prepareStatus or (item.launchError ~= nil and item.launchError or (((tostring(index + 1) .. " / ") .. tostring(#data)) .. "  ·  ") .. (zh and "上滑下一项 · 右滑 Remix · 左滑试玩" or "Swipe up next · right Remix · left Play")), -- 345
						textWidth = infoWidth, -- 345
						alignment = "Left", -- 345
						color3 = item.launchError ~= nil and 16739179 or 11055037 -- 345
					} -- 345
				), -- 345
				React.createElement( -- 345
					"label", -- 345
					{ -- 345
						x = infoX + infoWidth, -- 345
						y = infoTop, -- 345
						anchorX = 1, -- 345
						anchorY = 0.5, -- 345
						fontName = fontName, -- 345
						fontSize = 14, -- 345
						text = zh and "详情" or "Details", -- 345
						color3 = 16763955, -- 345
						touchEnabled = true, -- 345
						swallowTouches = true, -- 345
						onTapped = function() -- 345
							detailsOpen = not detailsOpen -- 352
							render() -- 352
						end -- 352
					} -- 352
				) -- 352
			) -- 352
			local ____detailsOpen_11 -- 353
			if detailsOpen then -- 353
				____detailsOpen_11 = React.createElement( -- 353
					"node", -- 353
					{ -- 353
						x = left + 12, -- 353
						y = bottom + 10, -- 353
						width = usableWidth - 24, -- 353
						height = math.min(usableHeight * 0.48, 360), -- 353
						anchorX = 0, -- 353
						anchorY = 0, -- 353
						touchEnabled = true, -- 353
						swallowTouches = true -- 353
					}, -- 353
					React.createElement( -- 353
						"draw-node", -- 353
						{ -- 353
							x = (usableWidth - 24) / 2, -- 353
							y = math.min(usableHeight * 0.48, 360) / 2 -- 353
						}, -- 353
						React.createElement( -- 353
							"rect-shape", -- 353
							{ -- 353
								width = usableWidth - 24, -- 353
								height = math.min(usableHeight * 0.48, 360), -- 353
								fillColor = colors.panelRaised, -- 353
								borderWidth = 1, -- 353
								borderColor = colors.border -- 353
							} -- 353
						) -- 353
					), -- 353
					React.createElement( -- 353
						"label", -- 353
						{ -- 353
							x = 20, -- 353
							y = math.min(usableHeight * 0.48, 360) - 36, -- 353
							anchorX = 0, -- 353
							anchorY = 0.5, -- 353
							fontName = fontName, -- 353
							fontSize = 18, -- 353
							text = item.title, -- 353
							textWidth = usableWidth - 64, -- 353
							alignment = "Left", -- 353
							color3 = 16052712 -- 353
						} -- 353
					), -- 353
					React.createElement( -- 353
						"label", -- 353
						{ -- 353
							x = 20, -- 353
							y = math.min(usableHeight * 0.48, 360) - 88, -- 353
							anchorX = 0, -- 353
							anchorY = 0.5, -- 353
							fontName = fontName, -- 353
							fontSize = 15, -- 353
							text = item.description, -- 353
							textWidth = usableWidth - 64, -- 353
							alignment = "Left", -- 353
							color3 = 11055037 -- 353
						} -- 353
					) -- 353
				) -- 353
			else -- 353
				____detailsOpen_11 = nil -- 362
			end -- 362
			__TS__SparseArrayPush(____array_12, ____detailsOpen_11) -- 362
			____temp_14 = ____React_createElement_13(__TS__SparseArraySpread(____array_12)) -- 362
		else -- 362
			____temp_14 = React.createElement( -- 362
				"node", -- 362
				nil, -- 362
				React.createElement("label", { -- 362
					x = left + usableWidth / 2, -- 362
					y = bottom + usableHeight / 2 + 20, -- 362
					fontName = fontName, -- 362
					fontSize = 22, -- 362
					text = tab == "discover" and (zh and "暂无移动作品" or "No mobile games yet") or (zh and "没有可运行的本地作品" or "No runnable local games"), -- 362
					color3 = 16052712 -- 362
				}), -- 362
				React.createElement("label", { -- 362
					x = left + usableWidth / 2, -- 362
					y = bottom + usableHeight / 2 - 28, -- 362
					fontName = fontName, -- 362
					fontSize = 14, -- 362
					text = tab == "discover" and discoverError ~= "" and discoverError or (zh and "切换标签或稍后重试" or "Switch tabs or retry later"), -- 362
					textWidth = usableWidth - 48, -- 362
					color3 = tab == "discover" and discoverError ~= "" and 16739179 or 11055037 -- 362
				}) -- 362
			) -- 362
		end -- 362
		__TS__SparseArrayPush(____array_15, ____temp_14) -- 362
		local scene = ____toNode_17(____React_createElement_16(__TS__SparseArraySpread(____array_15))) -- 285
		if scene ~= nil then -- 285
			host:addChild(scene) -- 372
		end -- 372
	end -- 259
	host:onAppChange(function(setting) -- 375
		if setting == "Size" or setting == "Locale" then -- 375
			render() -- 376
		end -- 376
	end) -- 375
	host:onAppEvent(function(event) -- 378
		if event == "BackButton" and detailsOpen then -- 378
			detailsOpen = false -- 380
			render() -- 381
		end -- 381
	end) -- 378
	host:onCleanup(function() -- 384
		active = false -- 384
	end) -- 384
	host:slot( -- 385
		"RestoreFeedEntry", -- 385
		function(entry) -- 385
			if not isActive() or HttpServer.wsConnectionCount > 0 then -- 385
				return -- 386
			end -- 386
			returnEntry = entry -- 387
			____local = getLocalEntries() -- 388
			discover = getDiscoverEntries() -- 389
			local location = resolveFeedLocation(____local, discover, entry) -- 390
			tab = location.tab -- 391
			index = location.index -- 392
			detailsOpen = false -- 393
			render() -- 394
		end -- 385
	) -- 385
	host:slot( -- 396
		"ResumeLocalUI", -- 396
		function() -- 396
			leaving = false -- 396
			render() -- 396
		end -- 396
	) -- 396
	render() -- 397
	if syncDiscover then -- 397
		if #discover == 0 then -- 397
			discoverError = zh and "正在同步资源目录…" or "Syncing Catalog…" -- 400
			render() -- 401
		end -- 401
		syncDiscover( -- 403
			function(message) -- 403
				if not isActive() or #discover > 0 then -- 403
					return -- 404
				end -- 404
				discoverError = message -- 405
				render() -- 406
			end, -- 403
			function(success, message) -- 407
				if not isActive() then -- 407
					return -- 408
				end -- 408
				local selected = returnEntry or current() -- 409
				local previousCount = #discover -- 410
				discover = getDiscoverEntries() -- 411
				discoverError = success and (#discover == 0 and (zh and "目录中暂无可运行作品" or "No runnable Catalog games") or "") or (message or (zh and "资源目录同步失败" or "Catalog sync failed")) -- 412
				tab = resolveDiscoverRefreshTab( -- 415
					tab, -- 415
					userSelectedTab, -- 415
					previousCount, -- 415
					#discover, -- 415
					#____local -- 415
				) -- 415
				if selected ~= nil then -- 415
					local location = resolveFeedLocation(____local, discover, selected) -- 417
					tab = location.tab -- 418
					index = location.index -- 419
				end -- 419
				if tab == "discover" then -- 419
					index = normalizeFeedIndex(index, #discover) -- 421
				end -- 421
				render() -- 422
			end -- 407
		) -- 407
	end -- 407
	return host -- 425
end -- 127
return ____exports -- 127