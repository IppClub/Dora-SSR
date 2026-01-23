-- [yue]: Script/Lib/UI/Control/Basic/ScrollArea.yue
local _module_0 = nil -- 1
local _ENV = Dora -- 9
local ScrollArea = require("UI.View.Control.Basic.ScrollArea") -- 10
local SolidRect = require("UI.View.Shape.SolidRect") -- 11
local Class <const> = Class -- 12
local App <const> = App -- 12
local math <const> = math -- 12
local Vec2 <const> = Vec2 -- 12
local View <const> = View -- 12
local Size <const> = Size -- 12
local once <const> = once -- 12
local sleep <const> = sleep -- 12
local Ease <const> = Ease -- 12
local Rect <const> = Rect -- 12
local Sequence <const> = Sequence -- 12
local Show <const> = Show -- 12
local Opacity <const> = Opacity -- 12
local Delay <const> = Delay -- 12
local Hide <const> = Hide -- 12
local Action <const> = Action -- 12
local property <const> = property -- 12
local cycle <const> = cycle -- 12
_module_0 = Class(ScrollArea, { -- 25
	__init = function(self, args) -- 25
		local selfX, selfY, width, height, viewWidth, viewHeight, scrollBar, scrollBarColor3, clipping = args.x, args.y, args.width, args.height, args.viewWidth, args.viewHeight, args.scrollBar, args.scrollBarColor3, args.clipping -- 26
		if selfX == nil then -- 27
			selfX = 0 -- 27
		end -- 27
		if selfY == nil then -- 28
			selfY = 0 -- 28
		end -- 28
		if width == nil then -- 29
			width = 0 -- 29
		end -- 29
		if height == nil then -- 30
			height = 0 -- 30
		end -- 30
		if viewWidth == nil then -- 31
			viewWidth = width -- 31
		end -- 31
		if viewHeight == nil then -- 32
			viewHeight = height -- 32
		end -- 32
		if scrollBar == nil then -- 33
			scrollBar = true -- 33
		end -- 33
		if scrollBarColor3 == nil then -- 34
			scrollBarColor3 = App.themeColor:toARGB() -- 34
		end -- 34
		if clipping == nil then -- 35
			clipping = true -- 35
		end -- 35
		self.x = selfX -- 37
		self.y = selfY -- 38
		viewWidth = math.max(viewWidth, width) -- 39
		viewHeight = math.max(viewHeight, height) -- 40
		local screenSize = (Vec2(View.size)).length -- 41
		local moveY = viewHeight - height -- 42
		local moveX = viewWidth - width -- 43
		local deltaX, deltaY = 0, 0 -- 44
		local paddingX, paddingY = args.paddingX, args.paddingY -- 45
		if paddingX == nil then -- 45
			paddingX = 200 -- 45
		end -- 45
		if paddingY == nil then -- 45
			paddingY = 200 -- 45
		end -- 45
		local posX, posY = 0, 0 -- 46
		local timePassed = 0 -- 47
		local S = Vec2.zero -- 48
		local V = Vec2.zero -- 49
		local deltaMoveLength = 0 -- 50
		self.contentSize = Size(width, height) -- 51
		self:setupMenuScroll(self.view) -- 52
		self.view:slot("Tapped", function() -- 54
			local enabled = self.view.touchEnabled -- 55
			self.view.touchEnabled = false -- 56
			return self.view:schedule(once(function() -- 57
				sleep() -- 58
				self.view.touchEnabled = enabled -- 59
			end)) -- 57
		end) -- 54
		local updateReset -- 61
		updateReset = function(deltaTime) -- 61
			local x, y -- 62
			timePassed = timePassed + deltaTime -- 63
			local t = math.min(timePassed * 4, 1) -- 64
			if posX < -moveX then -- 66
				local tmp = deltaX -- 67
				deltaX = posX - (moveX + posX) * Ease:func(Ease.OutQuad, t) -- 68
				x = deltaX - tmp -- 69
			elseif posX > 0 then -- 70
				local tmp = deltaX -- 71
				deltaX = posX - posX * Ease:func(Ease.OutQuad, t) -- 72
				x = deltaX - tmp -- 73
			end -- 66
			if posY < 0 then -- 74
				local tmp = deltaY -- 75
				deltaY = posY - posY * Ease:func(Ease.OutQuad, t) -- 76
				y = deltaY - tmp -- 77
			elseif posY > moveY then -- 78
				local tmp = deltaY -- 79
				deltaY = posY + (moveY - posY) * Ease:func(Ease.OutQuad, t) -- 80
				y = deltaY - tmp -- 81
			end -- 74
			x = x or 0 -- 82
			y = y or 0 -- 83
			self:emit("Scrolled", Vec2(x, y)) -- 84
			if t == 1 then -- 85
				self:unschedule() -- 86
				self:emit("ScrollEnd") -- 87
			end -- 85
			return false -- 88
		end -- 61
		local isReseting -- 90
		isReseting = function() -- 90
			return not self.dragging and (deltaX > 0 or deltaX < -moveX or deltaY > moveY or deltaY < 0) -- 91
		end -- 90
		local startReset -- 93
		startReset = function() -- 93
			posX = deltaX -- 94
			posY = deltaY -- 95
			timePassed = 0 -- 96
			return self:schedule(updateReset) -- 97
		end -- 93
		local setOffset -- 99
		setOffset = function(delta, touching) -- 99
			local dPosX = delta.x -- 100
			local dPosY = delta.y -- 101
			local newPosX = deltaX + dPosX -- 102
			local newPosY = deltaY + dPosY -- 103
			newPosX = math.min(newPosX, paddingX) -- 105
			newPosX = math.max(newPosX, -moveX - paddingX) -- 106
			newPosY = math.max(newPosY, -paddingY) -- 107
			newPosY = math.min(newPosY, moveY + paddingY) -- 108
			dPosX = newPosX - deltaX -- 109
			dPosY = newPosY - deltaY -- 110
			if touching then -- 112
				local lenY -- 113
				if newPosY < 0 then -- 113
					lenY = (0 - newPosY) / paddingY -- 114
				elseif newPosY > moveY then -- 115
					lenY = (newPosY - moveY) / paddingY -- 116
				else -- 117
					lenY = 0 -- 117
				end -- 113
				local lenX -- 118
				if newPosX > 0 then -- 118
					lenX = (newPosX - 0) / paddingX -- 119
				elseif newPosX < -moveX then -- 120
					lenX = (-moveX - newPosX) / paddingX -- 121
				else -- 122
					lenX = 0 -- 122
				end -- 118
				if lenY > 0 then -- 124
					local v = lenY * 3 -- 125
					dPosY = dPosY / math.max(v * v, 1) -- 126
				end -- 124
				if lenX > 0 then -- 127
					local v = lenX * 3 -- 128
					dPosX = dPosX / math.max(v * v, 1) -- 129
				end -- 127
			end -- 112
			deltaX = deltaX + dPosX -- 131
			deltaY = deltaY + dPosY -- 132
			self:emit("Scrolled", Vec2(dPosX, dPosY)) -- 134
			if not touching and (newPosY < -paddingY * 0.5 or newPosY > moveY + paddingY * 0.5 or newPosX > paddingX * 0.5 or newPosX < -moveX - paddingX * 0.5) then -- 136
				return startReset() -- 136
			end -- 136
		end -- 99
		local accel = screenSize * 2 -- 142
		local updateSpeed -- 143
		updateSpeed = function(dt) -- 143
			V = S / dt -- 144
			if V.length > accel then -- 145
				V = V:normalize() -- 146
				V = V * accel -- 147
			end -- 145
			S = Vec2.zero -- 148
			return false -- 149
		end -- 143
		local updatePos -- 151
		updatePos = function(dt) -- 151
			local dir = Vec2(V.x, V.y) -- 152
			dir = dir:normalize() -- 153
			local A = dir * -accel -- 154
			local incX = V.x > 0 -- 155
			local incY = V.y > 0 -- 156
			V = V + A * dt * 0.5 -- 157
			local decX = V.x < 0 -- 158
			local decY = V.y < 0 -- 159
			if incX == decX and incY == decY then -- 160
				if isReseting() then -- 161
					startReset() -- 162
				else -- 164
					self:unschedule() -- 164
					self:emit("ScrollEnd") -- 165
				end -- 161
			else -- 167
				local dS = V * dt -- 167
				setOffset(dS, false) -- 168
			end -- 160
			return false -- 169
		end -- 151
		self:slot("TapFilter", function(touch) -- 171
			if not touch.first or not Rect(-width / 2, -height / 2, width, height):containsPoint(touch.location) then -- 172
				touch.enabled = false -- 173
			end -- 172
		end) -- 171
		self:slot("TapBegan", function(_touch) -- 175
			deltaMoveLength = 0 -- 176
			S = Vec2.zero -- 177
			V = Vec2.zero -- 178
			self:schedule(updateSpeed) -- 179
			return self:emit("ScrollTouchBegan") -- 180
		end) -- 175
		self:slot("TapEnded", function() -- 182
			if not self.dragging then -- 183
				self:emit("NoneScrollTapped") -- 184
			end -- 183
			self.dragging = false -- 185
			if isReseting() then -- 186
				startReset() -- 187
			elseif V ~= Vec2.zero and deltaMoveLength > 10 then -- 188
				self:schedule(updatePos) -- 189
			else -- 191
				self:emit("ScrollEnd") -- 191
			end -- 186
			return self:emit("ScrollTouchEnded") -- 192
		end) -- 182
		self:slot("TapMoved", function(touch) -- 194
			local lastMoveLength = deltaMoveLength -- 195
			S = touch.delta -- 196
			deltaMoveLength = deltaMoveLength + S.length -- 197
			if deltaMoveLength > 10 then -- 198
				setOffset(S, true) -- 199
				if lastMoveLength <= 10 then -- 200
					self.dragging = true -- 201
					return self:emit("ScrollStart") -- 202
				end -- 200
			end -- 198
		end) -- 194
		self.area:slot("MouseWheel", function(delta) -- 204
			local px, py = paddingX, paddingY -- 205
			paddingX, paddingY = 0, 0 -- 206
			setOffset(delta * -20) -- 207
			paddingX, paddingY = px, py -- 208
		end) -- 204
		if scrollBar then -- 210
			local getScrollBarX -- 211
			getScrollBarX = function() -- 211
				if self.barX then -- 212
					return self.barX -- 212
				end -- 212
				local barX = SolidRect({ -- 214
					width = 50, -- 214
					height = 10, -- 215
					color = 0x66000000 + scrollBarColor3 -- 216
				}) -- 213
				local barBgX = SolidRect({ -- 218
					width = self.area.width, -- 218
					height = 10, -- 219
					color = 0x22000000 + scrollBarColor3 -- 220
				}) -- 217
				barBgX:addChild(barX) -- 221
				self.area:addChild(barBgX) -- 222
				self.barX = barX -- 223
				self.barBgX = barBgX -- 224
				return barX -- 225
			end -- 211
			local getScrollBarY -- 226
			getScrollBarY = function() -- 226
				if self.barY then -- 227
					return self.barY -- 227
				end -- 227
				local barY = SolidRect({ -- 229
					width = 10, -- 229
					height = 50, -- 230
					color = 0x66000000 + scrollBarColor3 -- 231
				}) -- 228
				local barBgY = SolidRect({ -- 233
					width = 10, -- 233
					height = self.area.height, -- 234
					color = 0x22000000 + scrollBarColor3 -- 235
				}) -- 232
				barBgY.x = self.area.width - 10 -- 236
				barBgY:addChild(barY) -- 237
				self.area:addChild(barBgY) -- 238
				self.barY = barY -- 239
				self.barBgY = barBgY -- 240
				return barY -- 241
			end -- 226
			local fadeSeq = Sequence(Show(), Opacity(0, 1, 1), Delay(1), Opacity(0.4, 1, 0, Ease.OutQuad), Hide()) -- 242
			local fadeBarX = Action(fadeSeq) -- 249
			local fadeBarY = Action(fadeSeq) -- 250
			self:slot("Scrolled", function(delta) -- 251
				if delta.x ~= 0 then -- 252
					local barX = getScrollBarX() -- 253
					barX.x = (self.area.width - 50) * math.max(math.min(-self.offset.x / (viewWidth - width), 1), 0) -- 254
					self.barBgX:perform(fadeBarX) -- 255
				end -- 252
				if delta.y ~= 0 then -- 256
					local barY = getScrollBarY() -- 257
					barY.y = (self.area.height - 50) * math.max(math.min(1 - self.offset.y / (viewHeight - height), 1), 0) -- 258
					return self.barBgY:perform(fadeBarY) -- 259
				end -- 256
			end) -- 251
		end -- 210
		self:slot("Enter", function() -- 261
			return self:emit("Scrolled", Vec2.zero) -- 261
		end) -- 261
		self.scroll = function(self, delta) -- 263
			if delta then -- 264
				deltaX = deltaX + delta.x -- 265
				deltaY = deltaY + delta.y -- 266
				self:emit("Scrolled", Vec2(delta.x, delta.y)) -- 267
			end -- 264
			if isReseting() then -- 268
				return startReset() -- 268
			end -- 268
		end -- 263
		self.scrollTo = function(self, offset) -- 270
			local delta = offset - Vec2(deltaX, deltaY) -- 271
			deltaX = offset.x -- 272
			deltaY = offset.y -- 273
			return self:emit("Scrolled", delta) -- 274
		end -- 270
		self.updatePadding = function(self, padX, padY) -- 276
			paddingX = padX -- 277
			paddingY = padY -- 278
			return self:scroll(Vec2.zero) -- 279
		end -- 276
		self.getPadding = function() -- 281
			return Vec2(paddingX, paddingY) -- 281
		end -- 281
		self.getViewSize = function() -- 282
			return Size(viewWidth, viewHeight) -- 282
		end -- 282
		self.getTotalDelta = function() -- 283
			return Vec2(deltaX, deltaY) -- 283
		end -- 283
		self.resetSize = function(self, w, h, viewW, viewH) -- 284
			local offset = self.offset -- 285
			self.offset = Vec2.zero -- 286
			width, height = w, h -- 287
			viewWidth = math.max(viewW or w, w) -- 288
			viewHeight = math.max(viewH or h, h) -- 289
			moveY = viewHeight - height -- 290
			moveX = viewWidth - width -- 291
			local size = Size(w, h) -- 292
			self.contentSize = size -- 293
			self.area.size = size -- 294
			self.view.size = size -- 295
			if clipping then -- 296
				self.area.stencil = SolidRect({ -- 296
					width = w, -- 296
					height = h -- 296
				}) -- 296
			end -- 296
			self.offset = offset -- 297
			if self.barBgX then -- 298
				self.area:removeChild(self.barBgX) -- 299
				self.barBgX = nil -- 300
				self.barX = nil -- 301
			end -- 298
			if self.barBgY then -- 302
				self.area:removeChild(self.barBgY) -- 303
				self.barBgY = nil -- 304
				self.barY = nil -- 305
			end -- 302
		end -- 284
	end, -- 25
	offset = property(function(self) -- 307
		return self:getTotalDelta() -- 307
	end, function(self, offset) -- 308
		return self:scroll(offset - self:getTotalDelta()) -- 308
	end), -- 307
	viewSize = property(function(self) -- 310
		return self:getViewSize() -- 310
	end, function(self, size) -- 311
		return self:resetSize(self.contentSize.width, self.contentSize.height, size.width, size.height) -- 312
	end), -- 310
	padding = property(function(self) -- 319
		return self:getPadding() -- 319
	end, function(self, padding) -- 320
		return self:updatePadding(padding.x, padding.y) -- 320
	end), -- 319
	setupMenuScroll = function(self, menu) -- 322
		self:slot("Scrolled", function(delta) -- 323
			return menu:moveAndCullItems(delta) -- 324
		end) -- 323
		local menuEnabled = true -- 325
		self:slot("ScrollStart", function() -- 326
			menuEnabled = menu.enabled -- 327
			menu.enabled = false -- 328
		end) -- 326
		return self:slot("ScrollTouchEnded", function() -- 329
			if not menu.enabled then -- 330
				menu.enabled = menuEnabled -- 330
			end -- 330
		end) -- 329
	end, -- 322
	adjustSizeWithAlign = function(self, alignMode, padding, size, viewSize) -- 332
		if alignMode == nil then -- 332
			alignMode = "Auto" -- 332
		end -- 332
		if padding == nil then -- 332
			padding = 10 -- 332
		end -- 332
		if size == nil then -- 332
			size = self.area.size -- 332
		end -- 332
		viewSize = viewSize or size -- 334
		local offset = self.offset -- 335
		self.offset = Vec2.zero -- 336
		if "Auto" == alignMode then -- 338
			viewSize = self.view:alignItems(Size(viewSize.width, size.height), padding) -- 339
		elseif "Vertical" == alignMode then -- 340
			viewSize = self.view:alignItemsVertically(size, padding) -- 341
		elseif "Horizontal" == alignMode then -- 342
			viewSize = self.view:alignItemsHorizontally(size, padding) -- 343
		end -- 337
		self:resetSize(size.width, size.height, viewSize.width, viewSize.height + padding) -- 344
		self.offset = offset -- 350
	end, -- 332
	scrollToPosY = function(self, posY, time) -- 352
		if time == nil then -- 352
			time = 0.3 -- 352
		end -- 352
		local height = self.contentSize.height -- 353
		local offset = self.offset -- 354
		local viewHeight = self.viewSize.height -- 355
		local deltaY = height / 2 - posY -- 356
		local startY = offset.y -- 357
		local endY = startY + deltaY -- 358
		if viewHeight <= height then -- 359
			endY = 0 -- 360
		else -- 362
			endY = math.max(endY, 0) -- 362
			endY = math.min(endY, viewHeight - height) -- 363
		end -- 359
		return self:schedule(once(function() -- 364
			local changeY = endY - startY -- 365
			cycle(time, function(progress) -- 366
				offset = Vec2(offset.x, startY + changeY * Ease:func(Ease.OutQuad, progress)) -- 367
				return self:scrollTo(offset) -- 368
			end) -- 366
			offset = Vec2(offset.x, endY) -- 369
			return self:scrollTo(offset) -- 370
		end)) -- 364
	end -- 352
}) -- 24
return _module_0 -- 1
