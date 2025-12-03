-- [yue]: Script/Lib/UI/Control/Basic/ScrollArea.yue
local Class = Dora.Class -- 1
local App = Dora.App -- 1
local math = _G.math -- 1
local Vec2 = Dora.Vec2 -- 1
local View = Dora.View -- 1
local Size = Dora.Size -- 1
local once = Dora.once -- 1
local sleep = Dora.sleep -- 1
local Ease = Dora.Ease -- 1
local Rect = Dora.Rect -- 1
local Sequence = Dora.Sequence -- 1
local Show = Dora.Show -- 1
local Opacity = Dora.Opacity -- 1
local Delay = Dora.Delay -- 1
local Hide = Dora.Hide -- 1
local Action = Dora.Action -- 1
local property = Dora.property -- 1
local cycle = Dora.cycle -- 1
local _module_0 = nil -- 1
local ScrollArea = require("UI.View.Control.Basic.ScrollArea") -- 10
local SolidRect = require("UI.View.Shape.SolidRect") -- 11
_module_0 = Class(ScrollArea, { -- 24
	__init = function(self, args) -- 24
		local selfX, selfY, width, height, viewWidth, viewHeight, scrollBar, scrollBarColor3, clipping = args.x, args.y, args.width, args.height, args.viewWidth, args.viewHeight, args.scrollBar, args.scrollBarColor3, args.clipping -- 25
		if selfX == nil then -- 26
			selfX = 0 -- 26
		end -- 26
		if selfY == nil then -- 27
			selfY = 0 -- 27
		end -- 27
		if width == nil then -- 28
			width = 0 -- 28
		end -- 28
		if height == nil then -- 29
			height = 0 -- 29
		end -- 29
		if viewWidth == nil then -- 30
			viewWidth = width -- 30
		end -- 30
		if viewHeight == nil then -- 31
			viewHeight = height -- 31
		end -- 31
		if scrollBar == nil then -- 32
			scrollBar = true -- 32
		end -- 32
		if scrollBarColor3 == nil then -- 33
			scrollBarColor3 = App.themeColor:toARGB() -- 33
		end -- 33
		if clipping == nil then -- 34
			clipping = true -- 34
		end -- 34
		self.x = selfX -- 36
		self.y = selfY -- 37
		viewWidth = math.max(viewWidth, width) -- 38
		viewHeight = math.max(viewHeight, height) -- 39
		local screenSize = (Vec2(View.size)).length -- 40
		local moveY = viewHeight - height -- 41
		local moveX = viewWidth - width -- 42
		local deltaX, deltaY = 0, 0 -- 43
		local paddingX, paddingY = args.paddingX, args.paddingY -- 44
		if paddingX == nil then -- 44
			paddingX = 200 -- 44
		end -- 44
		if paddingY == nil then -- 44
			paddingY = 200 -- 44
		end -- 44
		local posX, posY = 0, 0 -- 45
		local timePassed = 0 -- 46
		local S = Vec2.zero -- 47
		local V = Vec2.zero -- 48
		local deltaMoveLength = 0 -- 49
		self.contentSize = Size(width, height) -- 50
		self:setupMenuScroll(self.view) -- 51
		self.view:slot("Tapped", function() -- 53
			local enabled = self.view.touchEnabled -- 54
			self.view.touchEnabled = false -- 55
			return self.view:schedule(once(function() -- 56
				sleep() -- 57
				self.view.touchEnabled = enabled -- 58
			end)) -- 56
		end) -- 53
		local updateReset -- 60
		updateReset = function(deltaTime) -- 60
			local x, y -- 61
			timePassed = timePassed + deltaTime -- 62
			local t = math.min(timePassed * 4, 1) -- 63
			do -- 64
				local _with_0 = Ease -- 64
				if posX < -moveX then -- 65
					local tmp = deltaX -- 66
					deltaX = posX - (moveX + posX) * _with_0:func(_with_0.OutQuad, t) -- 67
					x = deltaX - tmp -- 68
				elseif posX > 0 then -- 69
					local tmp = deltaX -- 70
					deltaX = posX - posX * _with_0:func(_with_0.OutQuad, t) -- 71
					x = deltaX - tmp -- 72
				end -- 65
				if posY < 0 then -- 73
					local tmp = deltaY -- 74
					deltaY = posY - posY * _with_0:func(_with_0.OutQuad, t) -- 75
					y = deltaY - tmp -- 76
				elseif posY > moveY then -- 77
					local tmp = deltaY -- 78
					deltaY = posY + (moveY - posY) * _with_0:func(_with_0.OutQuad, t) -- 79
					y = deltaY - tmp -- 80
				end -- 73
			end -- 64
			x = x or 0 -- 81
			y = y or 0 -- 82
			self:emit("Scrolled", Vec2(x, y)) -- 83
			if t == 1 then -- 84
				self:unschedule() -- 85
				self:emit("ScrollEnd") -- 86
			end -- 84
			return false -- 87
		end -- 60
		local isReseting -- 89
		isReseting = function() -- 89
			return not self.dragging and (deltaX > 0 or deltaX < -moveX or deltaY > moveY or deltaY < 0) -- 90
		end -- 89
		local startReset -- 92
		startReset = function() -- 92
			posX = deltaX -- 93
			posY = deltaY -- 94
			timePassed = 0 -- 95
			return self:schedule(updateReset) -- 96
		end -- 92
		local setOffset -- 98
		setOffset = function(delta, touching) -- 98
			local dPosX = delta.x -- 99
			local dPosY = delta.y -- 100
			local newPosX = deltaX + dPosX -- 101
			local newPosY = deltaY + dPosY -- 102
			newPosX = math.min(newPosX, paddingX) -- 104
			newPosX = math.max(newPosX, -moveX - paddingX) -- 105
			newPosY = math.max(newPosY, -paddingY) -- 106
			newPosY = math.min(newPosY, moveY + paddingY) -- 107
			dPosX = newPosX - deltaX -- 108
			dPosY = newPosY - deltaY -- 109
			if touching then -- 111
				local lenY -- 112
				if newPosY < 0 then -- 112
					lenY = (0 - newPosY) / paddingY -- 113
				elseif newPosY > moveY then -- 114
					lenY = (newPosY - moveY) / paddingY -- 115
				else -- 116
					lenY = 0 -- 116
				end -- 112
				local lenX -- 117
				if newPosX > 0 then -- 117
					lenX = (newPosX - 0) / paddingX -- 118
				elseif newPosX < -moveX then -- 119
					lenX = (-moveX - newPosX) / paddingX -- 120
				else -- 121
					lenX = 0 -- 121
				end -- 117
				if lenY > 0 then -- 123
					local v = lenY * 3 -- 124
					dPosY = dPosY / math.max(v * v, 1) -- 125
				end -- 123
				if lenX > 0 then -- 126
					local v = lenX * 3 -- 127
					dPosX = dPosX / math.max(v * v, 1) -- 128
				end -- 126
			end -- 111
			deltaX = deltaX + dPosX -- 130
			deltaY = deltaY + dPosY -- 131
			self:emit("Scrolled", Vec2(dPosX, dPosY)) -- 133
			if not touching and (newPosY < -paddingY * 0.5 or newPosY > moveY + paddingY * 0.5 or newPosX > paddingX * 0.5 or newPosX < -moveX - paddingX * 0.5) then -- 135
				return startReset() -- 135
			end -- 135
		end -- 98
		local accel = screenSize * 2 -- 141
		local updateSpeed -- 142
		updateSpeed = function(dt) -- 142
			V = S / dt -- 143
			if V.length > accel then -- 144
				V = V:normalize() -- 145
				V = V * accel -- 146
			end -- 144
			S = Vec2.zero -- 147
			return false -- 148
		end -- 142
		local updatePos -- 150
		updatePos = function(dt) -- 150
			local dir = Vec2(V.x, V.y) -- 151
			dir = dir:normalize() -- 152
			local A = dir * -accel -- 153
			local incX = V.x > 0 -- 154
			local incY = V.y > 0 -- 155
			V = V + A * dt * 0.5 -- 156
			local decX = V.x < 0 -- 157
			local decY = V.y < 0 -- 158
			if incX == decX and incY == decY then -- 159
				if isReseting() then -- 160
					startReset() -- 161
				else -- 163
					self:unschedule() -- 163
					self:emit("ScrollEnd") -- 164
				end -- 160
			else -- 166
				local dS = V * dt -- 166
				setOffset(dS, false) -- 167
			end -- 159
			return false -- 168
		end -- 150
		self:slot("TapFilter", function(touch) -- 170
			if not touch.first or not Rect(-width / 2, -height / 2, width, height):containsPoint(touch.location) then -- 171
				touch.enabled = false -- 172
			end -- 171
		end) -- 170
		self:slot("TapBegan", function(touch) -- 174
			deltaMoveLength = 0 -- 175
			S = Vec2.zero -- 176
			V = Vec2.zero -- 177
			self:schedule(updateSpeed) -- 178
			return self:emit("ScrollTouchBegan") -- 179
		end) -- 174
		self:slot("TapEnded", function() -- 181
			if not self.dragging then -- 182
				self:emit("NoneScrollTapped") -- 183
			end -- 182
			self.dragging = false -- 184
			if isReseting() then -- 185
				startReset() -- 186
			elseif V ~= Vec2.zero and deltaMoveLength > 10 then -- 187
				self:schedule(updatePos) -- 188
			else -- 190
				self:emit("ScrollEnd") -- 190
			end -- 185
			return self:emit("ScrollTouchEnded") -- 191
		end) -- 181
		self:slot("TapMoved", function(touch) -- 193
			local lastMoveLength = deltaMoveLength -- 194
			S = touch.delta -- 195
			deltaMoveLength = deltaMoveLength + S.length -- 196
			if deltaMoveLength > 10 then -- 197
				setOffset(S, true) -- 198
				if lastMoveLength <= 10 then -- 199
					self.dragging = true -- 200
					return self:emit("ScrollStart") -- 201
				end -- 199
			end -- 197
		end) -- 193
		self.area:slot("MouseWheel", function(delta) -- 203
			local px, py = paddingX, paddingY -- 204
			paddingX, paddingY = 0, 0 -- 205
			setOffset(delta * -20) -- 206
			paddingX, paddingY = px, py -- 207
		end) -- 203
		if scrollBar then -- 209
			local getScrollBarX -- 210
			getScrollBarX = function() -- 210
				if self.barX then -- 211
					return self.barX -- 211
				end -- 211
				local barX = SolidRect({ -- 213
					width = 50, -- 213
					height = 10, -- 214
					color = 0x66000000 + scrollBarColor3 -- 215
				}) -- 212
				local barBgX = SolidRect({ -- 217
					width = self.area.width, -- 217
					height = 10, -- 218
					color = 0x22000000 + scrollBarColor3 -- 219
				}) -- 216
				barBgX:addChild(barX) -- 220
				self.area:addChild(barBgX) -- 221
				self.barX = barX -- 222
				self.barBgX = barBgX -- 223
				return barX -- 224
			end -- 210
			local getScrollBarY -- 225
			getScrollBarY = function() -- 225
				if self.barY then -- 226
					return self.barY -- 226
				end -- 226
				local barY = SolidRect({ -- 228
					width = 10, -- 228
					height = 50, -- 229
					color = 0x66000000 + scrollBarColor3 -- 230
				}) -- 227
				local barBgY = SolidRect({ -- 232
					width = 10, -- 232
					height = self.area.height, -- 233
					color = 0x22000000 + scrollBarColor3 -- 234
				}) -- 231
				barBgY.x = self.area.width - 10 -- 235
				barBgY:addChild(barY) -- 236
				self.area:addChild(barBgY) -- 237
				self.barY = barY -- 238
				self.barBgY = barBgY -- 239
				return barY -- 240
			end -- 225
			local fadeSeq = Sequence(Show(), Opacity(0, 1, 1), Delay(1), Opacity(0.4, 1, 0, Ease.OutQuad), Hide()) -- 241
			local fadeBarX = Action(fadeSeq) -- 248
			local fadeBarY = Action(fadeSeq) -- 249
			self:slot("Scrolled", function(delta) -- 250
				if delta.x ~= 0 then -- 251
					local barX = getScrollBarX() -- 252
					barX.x = (self.area.width - 50) * math.max(math.min(-self.offset.x / (viewWidth - width), 1), 0) -- 253
					self.barBgX:perform(fadeBarX) -- 254
				end -- 251
				if delta.y ~= 0 then -- 255
					local barY = getScrollBarY() -- 256
					barY.y = (self.area.height - 50) * math.max(math.min(1 - self.offset.y / (viewHeight - height), 1), 0) -- 257
					return self.barBgY:perform(fadeBarY) -- 258
				end -- 255
			end) -- 250
		end -- 209
		self:slot("Enter", function() -- 260
			return self:emit("Scrolled", Vec2.zero) -- 260
		end) -- 260
		self.scroll = function(self, delta) -- 262
			if delta then -- 263
				deltaX = deltaX + delta.x -- 264
				deltaY = deltaY + delta.y -- 265
				self:emit("Scrolled", Vec2(delta.x, delta.y)) -- 266
			end -- 263
			if isReseting() then -- 267
				return startReset() -- 267
			end -- 267
		end -- 262
		self.scrollTo = function(self, offset) -- 269
			local delta = offset - Vec2(deltaX, deltaY) -- 270
			deltaX = offset.x -- 271
			deltaY = offset.y -- 272
			return self:emit("Scrolled", delta) -- 273
		end -- 269
		self.updatePadding = function(self, padX, padY) -- 275
			paddingX = padX -- 276
			paddingY = padY -- 277
			return self:scroll(Vec2.zero) -- 278
		end -- 275
		self.getPadding = function() -- 280
			return Vec2(paddingX, paddingY) -- 280
		end -- 280
		self.getViewSize = function() -- 281
			return Size(viewWidth, viewHeight) -- 281
		end -- 281
		self.getTotalDelta = function() -- 282
			return Vec2(deltaX, deltaY) -- 282
		end -- 282
		self.resetSize = function(self, w, h, viewW, viewH) -- 283
			local offset = self.offset -- 284
			self.offset = Vec2.zero -- 285
			width, height = w, h -- 286
			viewWidth = math.max(viewW or w, w) -- 287
			viewHeight = math.max(viewH or h, h) -- 288
			moveY = viewHeight - height -- 289
			moveX = viewWidth - width -- 290
			local size = Size(w, h) -- 291
			self.contentSize = size -- 292
			self.area.size = size -- 293
			self.view.size = size -- 294
			if clipping then -- 295
				self.area.stencil = SolidRect({ -- 295
					width = w, -- 295
					height = h -- 295
				}) -- 295
			end -- 295
			self.offset = offset -- 296
			if self.barBgX then -- 297
				self.area:removeChild(self.barBgX) -- 298
				self.barBgX = nil -- 299
				self.barX = nil -- 300
			end -- 297
			if self.barBgY then -- 301
				self.area:removeChild(self.barBgY) -- 302
				self.barBgY = nil -- 303
				self.barY = nil -- 304
			end -- 301
		end -- 283
	end, -- 24
	offset = property(function(self) -- 306
		return self:getTotalDelta() -- 306
	end, function(self, offset) -- 307
		return self:scroll(offset - self:getTotalDelta()) -- 307
	end), -- 306
	viewSize = property(function(self) -- 309
		return self:getViewSize() -- 309
	end, function(self, size) -- 310
		return self:resetSize(self.contentSize.width, self.contentSize.height, size.width, size.height) -- 311
	end), -- 309
	padding = property(function(self) -- 318
		return self:getPadding() -- 318
	end, function(self, padding) -- 319
		return self:updatePadding(padding.x, padding.y) -- 319
	end), -- 318
	setupMenuScroll = function(self, menu) -- 321
		self:slot("Scrolled", function(delta) -- 322
			return menu:moveAndCullItems(delta) -- 323
		end) -- 322
		local menuEnabled = true -- 324
		self:slot("ScrollStart", function() -- 325
			menuEnabled = menu.enabled -- 326
			menu.enabled = false -- 327
		end) -- 325
		return self:slot("ScrollTouchEnded", function() -- 328
			if not menu.enabled then -- 329
				menu.enabled = menuEnabled -- 329
			end -- 329
		end) -- 328
	end, -- 321
	adjustSizeWithAlign = function(self, alignMode, padding, size, viewSize) -- 331
		if alignMode == nil then -- 331
			alignMode = "Auto" -- 331
		end -- 331
		if padding == nil then -- 331
			padding = 10 -- 331
		end -- 331
		if size == nil then -- 331
			size = self.area.size -- 331
		end -- 331
		viewSize = viewSize or size -- 333
		local offset = self.offset -- 334
		self.offset = Vec2.zero -- 335
		if "Auto" == alignMode then -- 337
			viewSize = self.view:alignItems(Size(viewSize.width, size.height), padding) -- 338
		elseif "Vertical" == alignMode then -- 339
			viewSize = self.view:alignItemsVertically(size, padding) -- 340
		elseif "Horizontal" == alignMode then -- 341
			viewSize = self.view:alignItemsHorizontally(size, padding) -- 342
		end -- 336
		self:resetSize(size.width, size.height, viewSize.width, viewSize.height + padding) -- 343
		self.offset = offset -- 349
	end, -- 331
	scrollToPosY = function(self, posY, time) -- 351
		if time == nil then -- 351
			time = 0.3 -- 351
		end -- 351
		local height = self.contentSize.height -- 352
		local offset = self.offset -- 353
		local viewHeight = self.viewSize.height -- 354
		local deltaY = height / 2 - posY -- 355
		local startY = offset.y -- 356
		local endY = startY + deltaY -- 357
		if viewHeight <= height then -- 358
			endY = 0 -- 359
		else -- 361
			endY = math.max(endY, 0) -- 361
			endY = math.min(endY, viewHeight - height) -- 362
		end -- 358
		return self:schedule(once(function() -- 363
			local changeY = endY - startY -- 364
			cycle(time, function(progress) -- 365
				offset = Vec2(offset.x, startY + changeY * Ease:func(Ease.OutQuad, progress)) -- 366
				return self:scrollTo(offset) -- 367
			end) -- 365
			offset = Vec2(offset.x, endY) -- 368
			return self:scrollTo(offset) -- 369
		end)) -- 363
	end -- 351
}) -- 23
return _module_0 -- 1
