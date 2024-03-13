-- [yue]: Script/Lib/UI/Control/Basic/ScrollArea.yue
local Class = dora.Class -- 1
local App = dora.App -- 1
local math = _G.math -- 1
local Vec2 = dora.Vec2 -- 1
local View = dora.View -- 1
local Size = dora.Size -- 1
local once = dora.once -- 1
local sleep = dora.sleep -- 1
local Ease = dora.Ease -- 1
local Rect = dora.Rect -- 1
local Sequence = dora.Sequence -- 1
local Show = dora.Show -- 1
local Opacity = dora.Opacity -- 1
local Delay = dora.Delay -- 1
local Hide = dora.Hide -- 1
local Action = dora.Action -- 1
local property = dora.property -- 1
local cycle = dora.cycle -- 1
local _module_0 = nil -- 1
local ScrollArea = require("UI.View.Control.Basic.ScrollArea") -- 2
local SolidRect = require("UI.View.Shape.SolidRect") -- 3
_module_0 = Class(ScrollArea, { -- 16
	__init = function(self, args) -- 16
		local selfX, selfY, width, height, viewWidth, viewHeight, scrollBar, scrollBarColor3, clipping = args.x, args.y, args.width, args.height, args.viewWidth, args.viewHeight, args.scrollBar, args.scrollBarColor3, args.clipping -- 17
		if selfX == nil then -- 18
			selfX = 0 -- 18
		end -- 18
		if selfY == nil then -- 19
			selfY = 0 -- 19
		end -- 19
		if width == nil then -- 20
			width = 0 -- 20
		end -- 20
		if height == nil then -- 21
			height = 0 -- 21
		end -- 21
		if viewWidth == nil then -- 22
			viewWidth = width -- 22
		end -- 22
		if viewHeight == nil then -- 23
			viewHeight = height -- 23
		end -- 23
		if scrollBar == nil then -- 24
			scrollBar = true -- 24
		end -- 24
		if scrollBarColor3 == nil then -- 25
			scrollBarColor3 = App.themeColor:toARGB() -- 25
		end -- 25
		if clipping == nil then -- 26
			clipping = true -- 26
		end -- 26
		self.x = selfX -- 28
		self.y = selfY -- 29
		viewWidth = math.max(viewWidth, width) -- 30
		viewHeight = math.max(viewHeight, height) -- 31
		local screenSize = (Vec2(View.size)).length -- 32
		local moveY = viewHeight - height -- 33
		local moveX = viewWidth - width -- 34
		local deltaX, deltaY = 0, 0 -- 35
		local paddingX, paddingY = args.paddingX, args.paddingY -- 36
		if paddingX == nil then -- 36
			paddingX = 200 -- 36
		end -- 36
		if paddingY == nil then -- 36
			paddingY = 200 -- 36
		end -- 36
		local posX, posY = 0, 0 -- 37
		local timePassed = 0 -- 38
		local S = Vec2.zero -- 39
		local V = Vec2.zero -- 40
		local deltaMoveLength = 0 -- 41
		self.contentSize = Size(width, height) -- 42
		self:setupMenuScroll(self.view) -- 43
		self.view:slot("Tapped", function() -- 45
			local enabled = self.view.touchEnabled -- 46
			self.view.touchEnabled = false -- 47
			return self.view:schedule(once(function() -- 48
				sleep() -- 49
				self.view.touchEnabled = enabled -- 50
			end)) -- 50
		end) -- 45
		local updateReset -- 52
		updateReset = function(deltaTime) -- 52
			local x, y -- 53
			timePassed = timePassed + deltaTime -- 54
			local t = math.min(timePassed * 4, 1) -- 55
			do -- 56
				local _with_0 = Ease -- 56
				if posX < -moveX then -- 57
					local tmp = deltaX -- 58
					deltaX = posX - (moveX + posX) * _with_0:func(_with_0.OutQuad, t) -- 59
					x = deltaX - tmp -- 60
				elseif posX > 0 then -- 61
					local tmp = deltaX -- 62
					deltaX = posX - posX * _with_0:func(_with_0.OutQuad, t) -- 63
					x = deltaX - tmp -- 64
				end -- 57
				if posY < 0 then -- 65
					local tmp = deltaY -- 66
					deltaY = posY - posY * _with_0:func(_with_0.OutQuad, t) -- 67
					y = deltaY - tmp -- 68
				elseif posY > moveY then -- 69
					local tmp = deltaY -- 70
					deltaY = posY + (moveY - posY) * _with_0:func(_with_0.OutQuad, t) -- 71
					y = deltaY - tmp -- 72
				end -- 65
			end -- 56
			x = x or 0 -- 73
			y = y or 0 -- 74
			self:emit("Scrolled", Vec2(x, y)) -- 75
			if t == 1 then -- 76
				self:unschedule() -- 77
				self:emit("ScrollEnd") -- 78
			end -- 76
			return false -- 79
		end -- 52
		local isReseting -- 81
		isReseting = function() -- 81
			return not self.dragging and (deltaX > 0 or deltaX < -moveX or deltaY > moveY or deltaY < 0) -- 82
		end -- 81
		local startReset -- 84
		startReset = function() -- 84
			posX = deltaX -- 85
			posY = deltaY -- 86
			timePassed = 0 -- 87
			return self:schedule(updateReset) -- 88
		end -- 84
		local setOffset -- 90
		setOffset = function(delta, touching) -- 90
			local dPosX = delta.x -- 91
			local dPosY = delta.y -- 92
			local newPosX = deltaX + dPosX -- 93
			local newPosY = deltaY + dPosY -- 94
			newPosX = math.min(newPosX, paddingX) -- 96
			newPosX = math.max(newPosX, -moveX - paddingX) -- 97
			newPosY = math.max(newPosY, -paddingY) -- 98
			newPosY = math.min(newPosY, moveY + paddingY) -- 99
			dPosX = newPosX - deltaX -- 100
			dPosY = newPosY - deltaY -- 101
			if touching then -- 103
				local lenY -- 104
				if newPosY < 0 then -- 104
					lenY = (0 - newPosY) / paddingY -- 105
				elseif newPosY > moveY then -- 106
					lenY = (newPosY - moveY) / paddingY -- 107
				else -- 108
					lenY = 0 -- 108
				end -- 104
				local lenX -- 109
				if newPosX > 0 then -- 109
					lenX = (newPosX - 0) / paddingX -- 110
				elseif newPosX < -moveX then -- 111
					lenX = (-moveX - newPosX) / paddingX -- 112
				else -- 113
					lenX = 0 -- 113
				end -- 109
				if lenY > 0 then -- 115
					local v = lenY * 3 -- 116
					dPosY = dPosY / math.max(v * v, 1) -- 117
				end -- 115
				if lenX > 0 then -- 118
					local v = lenX * 3 -- 119
					dPosX = dPosX / math.max(v * v, 1) -- 120
				end -- 118
			end -- 103
			deltaX = deltaX + dPosX -- 122
			deltaY = deltaY + dPosY -- 123
			self:emit("Scrolled", Vec2(dPosX, dPosY)) -- 125
			if not touching and (newPosY < -paddingY * 0.5 or newPosY > moveY + paddingY * 0.5 or newPosX > paddingX * 0.5 or newPosX < -moveX - paddingX * 0.5) then -- 127
				return startReset() -- 131
			end -- 127
		end -- 90
		local accel = screenSize * 2 -- 133
		local updateSpeed -- 134
		updateSpeed = function(dt) -- 134
			V = S / dt -- 135
			if V.length > accel then -- 136
				V = V:normalize() -- 137
				V = V * accel -- 138
			end -- 136
			S = Vec2.zero -- 139
			return false -- 140
		end -- 134
		local updatePos -- 142
		updatePos = function(dt) -- 142
			local dir = Vec2(V.x, V.y) -- 143
			dir = dir:normalize() -- 144
			local A = dir * -accel -- 145
			local incX = V.x > 0 -- 146
			local incY = V.y > 0 -- 147
			V = V + A * dt * 0.5 -- 148
			local decX = V.x < 0 -- 149
			local decY = V.y < 0 -- 150
			if incX == decX and incY == decY then -- 151
				if isReseting() then -- 152
					startReset() -- 153
				else -- 155
					self:unschedule() -- 155
					self:emit("ScrollEnd") -- 156
				end -- 152
			else -- 158
				local dS = V * dt -- 158
				setOffset(dS, false) -- 159
			end -- 151
			return false -- 160
		end -- 142
		self:slot("TapFilter", function(touch) -- 162
			if not touch.first or not Rect(-width / 2, -height / 2, width, height):containsPoint(touch.location) then -- 163
				touch.enabled = false -- 164
			end -- 163
		end) -- 162
		self:slot("TapBegan", function(touch) -- 166
			deltaMoveLength = 0 -- 167
			S = Vec2.zero -- 168
			V = Vec2.zero -- 169
			self:schedule(updateSpeed) -- 170
			return self:emit("ScrollTouchBegan") -- 171
		end) -- 166
		self:slot("TapEnded", function() -- 173
			if not self.dragging then -- 174
				self:emit("NoneScrollTapped") -- 175
			end -- 174
			self.dragging = false -- 176
			if isReseting() then -- 177
				startReset() -- 178
			elseif V ~= Vec2.zero and deltaMoveLength > 10 then -- 179
				self:schedule(updatePos) -- 180
			else -- 182
				self:emit("ScrollEnd") -- 182
			end -- 177
			return self:emit("ScrollTouchEnded") -- 183
		end) -- 173
		self:slot("TapMoved", function(touch) -- 185
			local lastMoveLength = deltaMoveLength -- 186
			S = touch.delta -- 187
			deltaMoveLength = deltaMoveLength + S.length -- 188
			if deltaMoveLength > 10 then -- 189
				setOffset(S, true) -- 190
				if lastMoveLength <= 10 then -- 191
					self.dragging = true -- 192
					return self:emit("ScrollStart") -- 193
				end -- 191
			end -- 189
		end) -- 185
		self.area:slot("MouseWheel", function(delta) -- 195
			local px, py = paddingX, paddingY -- 196
			paddingX, paddingY = 0, 0 -- 197
			setOffset(delta * -20) -- 198
			paddingX, paddingY = px, py -- 199
		end) -- 195
		if scrollBar then -- 201
			local getScrollBarX -- 202
			getScrollBarX = function() -- 202
				if self.barX then -- 203
					return self.barX -- 203
				end -- 203
				local barX = SolidRect({ -- 205
					width = 50, -- 205
					height = 10, -- 206
					color = 0x66000000 + scrollBarColor3 -- 207
				}) -- 204
				local barBgX = SolidRect({ -- 209
					width = self.area.width, -- 209
					height = 10, -- 210
					color = 0x22000000 + scrollBarColor3 -- 211
				}) -- 208
				barBgX:addChild(barX) -- 212
				self.area:addChild(barBgX) -- 213
				self.barX = barX -- 214
				self.barBgX = barBgX -- 215
				return barX -- 216
			end -- 202
			local getScrollBarY -- 217
			getScrollBarY = function() -- 217
				if self.barY then -- 218
					return self.barY -- 218
				end -- 218
				local barY = SolidRect({ -- 220
					width = 10, -- 220
					height = 50, -- 221
					color = 0x66000000 + scrollBarColor3 -- 222
				}) -- 219
				local barBgY = SolidRect({ -- 224
					width = 10, -- 224
					height = self.area.height, -- 225
					color = 0x22000000 + scrollBarColor3 -- 226
				}) -- 223
				barBgY.x = self.area.width - 10 -- 227
				barBgY:addChild(barY) -- 228
				self.area:addChild(barBgY) -- 229
				self.barY = barY -- 230
				self.barBgY = barBgY -- 231
				return barY -- 232
			end -- 217
			local fadeSeq = Sequence(Show(), Opacity(0, 1, 1), Delay(1), Opacity(0.4, 1, 0, Ease.OutQuad), Hide()) -- 233
			local fadeBarX = Action(fadeSeq) -- 240
			local fadeBarY = Action(fadeSeq) -- 241
			self:slot("Scrolled", function(delta) -- 242
				if delta.x ~= 0 then -- 243
					local barX = getScrollBarX() -- 244
					barX.x = (self.area.width - 50) * math.max(math.min(-self.offset.x / (viewWidth - width), 1), 0) -- 245
					self.barBgX:perform(fadeBarX) -- 246
				end -- 243
				if delta.y ~= 0 then -- 247
					local barY = getScrollBarY() -- 248
					barY.y = (self.area.height - 50) * math.max(math.min(1 - self.offset.y / (viewHeight - height), 1), 0) -- 249
					return self.barBgY:perform(fadeBarY) -- 250
				end -- 247
			end) -- 242
		end -- 201
		self:slot("Enter", function() -- 252
			return self:emit("Scrolled", Vec2.zero) -- 252
		end) -- 252
		self.scroll = function(self, delta) -- 254
			if delta then -- 255
				deltaX = deltaX + delta.x -- 256
				deltaY = deltaY + delta.y -- 257
				self:emit("Scrolled", Vec2(delta.x, delta.y)) -- 258
			end -- 255
			if isReseting() then -- 259
				return startReset() -- 259
			end -- 259
		end -- 254
		self.scrollTo = function(self, offset) -- 261
			local delta = offset - Vec2(deltaX, deltaY) -- 262
			deltaX = offset.x -- 263
			deltaY = offset.y -- 264
			return self:emit("Scrolled", delta) -- 265
		end -- 261
		self.updatePadding = function(self, padX, padY) -- 267
			paddingX = padX -- 268
			paddingY = padY -- 269
			return self:scroll(Vec2.zero) -- 270
		end -- 267
		self.getPadding = function() -- 272
			return Vec2(paddingX, paddingY) -- 272
		end -- 272
		self.getViewSize = function() -- 273
			return Size(viewWidth, viewHeight) -- 273
		end -- 273
		self.getTotalDelta = function() -- 274
			return Vec2(deltaX, deltaY) -- 274
		end -- 274
		self.resetSize = function(self, w, h, viewW, viewH) -- 275
			local offset = self.offset -- 276
			self.offset = Vec2.zero -- 277
			width, height = w, h -- 278
			viewWidth = math.max(viewW or w, w) -- 279
			viewHeight = math.max(viewH or h, h) -- 280
			moveY = viewHeight - height -- 281
			moveX = viewWidth - width -- 282
			local size = Size(w, h) -- 283
			self.contentSize = size -- 284
			self.area.size = size -- 285
			self.view.size = size -- 286
			if clipping then -- 287
				self.area.stencil = SolidRect({ -- 287
					width = w, -- 287
					height = h -- 287
				}) -- 287
			end -- 287
			self.offset = offset -- 288
			if self.barBgX then -- 289
				self.area:removeChild(self.barBgX) -- 290
				self.barBgX = nil -- 291
				self.barX = nil -- 292
			end -- 289
			if self.barBgY then -- 293
				self.area:removeChild(self.barBgY) -- 294
				self.barBgY = nil -- 295
				self.barY = nil -- 296
			end -- 293
		end -- 275
	end, -- 16
	offset = property(function(self) -- 298
		return self:getTotalDelta() -- 298
	end, function(self, offset) -- 299
		return self:scroll(offset - self:getTotalDelta()) -- 299
	end), -- 298
	viewSize = property(function(self) -- 301
		return self:getViewSize() -- 301
	end, function(self, size) -- 302
		return self:resetSize(self.contentSize.width, self.contentSize.height, size.width, size.height) -- 308
	end), -- 301
	padding = property(function(self) -- 310
		return self:getPadding() -- 310
	end, function(self, padding) -- 311
		return self:updatePadding(padding.x, padding.y) -- 311
	end), -- 310
	setupMenuScroll = function(self, menu) -- 313
		self:slot("Scrolled", function(delta) -- 314
			return menu:moveAndCullItems(delta) -- 315
		end) -- 314
		local menuEnabled = true -- 316
		self:slot("ScrollStart", function() -- 317
			menuEnabled = menu.enabled -- 318
			menu.enabled = false -- 319
		end) -- 317
		return self:slot("ScrollTouchEnded", function() -- 320
			if not menu.enabled then -- 321
				menu.enabled = menuEnabled -- 321
			end -- 321
		end) -- 321
	end, -- 313
	adjustSizeWithAlign = function(self, alignMode, padding, size, viewSize) -- 323
		if alignMode == nil then -- 323
			alignMode = "Auto" -- 323
		end -- 323
		if padding == nil then -- 323
			padding = 10 -- 323
		end -- 323
		if size == nil then -- 323
			size = self.area.size -- 323
		end -- 323
		viewSize = viewSize or size -- 325
		local offset = self.offset -- 326
		self.offset = Vec2.zero -- 327
		if "Auto" == alignMode then -- 329
			viewSize = self.view:alignItems(Size(viewSize.width, size.height), padding) -- 330
		elseif "Vertical" == alignMode then -- 331
			viewSize = self.view:alignItemsVertically(size, padding) -- 332
		elseif "Horizontal" == alignMode then -- 333
			viewSize = self.view:alignItemsHorizontally(size, padding) -- 334
		end -- 334
		self:resetSize(size.width, size.height, viewSize.width, viewSize.height) -- 335
		self.offset = offset -- 341
	end, -- 323
	scrollToPosY = function(self, posY, time) -- 343
		if time == nil then -- 343
			time = 0.3 -- 343
		end -- 343
		local height = self.contentSize.height -- 344
		local offset = self.offset -- 345
		local viewHeight = self.viewSize.height -- 346
		local deltaY = height / 2 - posY -- 347
		local startY = offset.y -- 348
		local endY = startY + deltaY -- 349
		if viewHeight <= height then -- 350
			endY = 0 -- 351
		else -- 353
			endY = math.max(endY, 0) -- 353
			endY = math.min(endY, viewHeight - height) -- 354
		end -- 350
		return self:schedule(once(function() -- 355
			local changeY = endY - startY -- 356
			cycle(time, function(progress) -- 357
				offset = Vec2(offset.x, startY + changeY * Ease:func(Ease.OutQuad, progress)) -- 358
				return self:scrollTo(offset) -- 359
			end) -- 357
			offset = Vec2(offset.x, endY) -- 360
			return self:scrollTo(offset) -- 361
		end)) -- 361
	end -- 343
}) -- 15
return _module_0 -- 361
