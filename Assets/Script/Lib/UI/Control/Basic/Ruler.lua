-- [yue]: Script/Lib/UI/Control/Basic/Ruler.yue
local Class = dora.Class -- 1
local View = dora.View -- 1
local math = _G.math -- 1
local Label = dora.Label -- 1
local string = _G.string -- 1
local Vec2 = dora.Vec2 -- 1
local tostring = _G.tostring -- 1
local table = _G.table -- 1
local tonumber = _G.tonumber -- 1
local Color = dora.Color -- 1
local ScaleX = dora.ScaleX -- 1
local Ease = dora.Ease -- 1
local once = dora.once -- 1
local cycle = dora.cycle -- 1
local App = dora.App -- 1
local Node = dora.Node -- 1
local Size = dora.Size -- 1
local pairs = _G.pairs -- 1
local Spawn = dora.Spawn -- 1
local Y = dora.Y -- 1
local Opacity = dora.Opacity -- 1
local Sequence = dora.Sequence -- 1
local Hide = dora.Hide -- 1
local _module_0 = nil -- 1
local Ruler = require("UI.View.Control.Basic.Ruler") -- 2
local Round = require("Utils").Round -- 3
_module_0 = Class(Ruler, { -- 6
	__init = function(self, args) -- 6
		local y, width, height, fontName, fontSize, fixed = args.y, args.width, args.height, args.fontName, args.fontSize, args.fixed -- 7
		local viewSize = View.size -- 8
		local halfW = width / 2 -- 9
		local halfH = height / 2 -- 10
		local interval = 10 -- 11
		local indent = 100 -- 12
		if fontSize == nil then -- 13
			fontSize = 12 -- 13
		end -- 13
		local vsCache = { } -- 14
		self.endPosY = y -- 15
		if fixed ~= nil then -- 16
			self.isFixed = fixed -- 16
		else -- 16
			self.isFixed = true -- 16
		end -- 16
		local labels = { } -- 18
		local labelList = { } -- 19
		local len = nil -- 20
		do -- 21
			local posX = self.intervalNode.anchor.x * width -- 22
			local center = Round(posX / 100) -- 23
			len = Round((posX + halfW) / 100 - center) -- 24
			len = 1 + math.max((center - Round((posX - halfW) / 100)), len) -- 25
			for i = center - len, center + len do -- 26
				local pos = i * 100 -- 27
				local label -- 28
				do -- 28
					local _with_0 = Label(fontName, fontSize) -- 28
					_with_0.text = string.format("%.0f", pos / 100 * indent) -- 29
					_with_0.scaleX = 1 / self.intervalNode.scaleX -- 30
					_with_0.position = Vec2(pos, halfH - 18 - fontSize) -- 31
					_with_0.tag = tostring(pos) -- 32
					label = _with_0 -- 28
				end -- 28
				self.intervalNode:addChild(label) -- 33
				labels[pos] = label -- 34
				table.insert(labelList, label) -- 35
			end -- 35
		end -- 35
		local moveLabel -- 37
		moveLabel = function(label, pos) -- 37
			labels[tonumber(label.tag)] = nil -- 38
			label.text = string.format("%.0f", pos / 100 * indent) -- 40
			label.scaleX = 1 / self.intervalNode.scaleX -- 41
			label.position = Vec2(pos, halfH - 18 - fontSize) -- 42
			label.tag = tostring(pos) -- 43
			labels[pos] = label -- 39
		end -- 37
		local updateLabels -- 45
		updateLabels = function() -- 45
			local posX = self.intervalNode.anchor.x * width -- 46
			local center = math.floor(posX / 100) -- 47
			local right = center + len -- 48
			local left = center - len -- 49
			local insertPos = 1 -- 50
			for i = left, right do -- 51
				local pos = i * 100 -- 52
				if labels[pos] then -- 53
					break -- 54
				else -- 56
					local label = table.remove(labelList) -- 56
					table.insert(labelList, insertPos, label) -- 57
					insertPos = insertPos + 1 -- 58
					moveLabel(label, pos) -- 59
				end -- 53
			end -- 59
			insertPos = #labelList -- 60
			for i = right, left, -1 do -- 61
				local pos = i * 100 -- 62
				if labels[pos] then -- 63
					break -- 64
				else -- 66
					local label = table.remove(labelList, 1) -- 66
					table.insert(labelList, insertPos, label) -- 67
					insertPos = insertPos - 1 -- 68
					moveLabel(label, pos) -- 69
				end -- 63
			end -- 69
			local scale = self.intervalNode.scaleX -- 71
			local current = Round(self.intervalNode.anchor.x * width / interval) -- 72
			local delta = 1 + math.ceil(halfW / scale / interval) -- 73
			local max = current + delta -- 74
			local min = current - delta -- 75
			local count = 1 -- 76
			local vs = { } -- 77
			for i = min, max do -- 78
				posX = i * interval -- 79
				local v = vsCache[count] -- 80
				if v then -- 81
					v = Vec2(posX, halfH) -- 81
				else -- 83
					v = Vec2(posX, halfH) -- 83
					vsCache[count] = v -- 84
				end -- 81
				vs[count] = v -- 85
				count = count + 1 -- 86
				v = vsCache[count] -- 87
				if v then -- 88
					v = Vec2(posX, halfH - (i % 10 == 0 and fontSize + 6 or fontSize - 2)) -- 88
				else -- 90
					v = Vec2(posX, halfH - (i % 10 == 0 and fontSize + 6 or fontSize - 2)) -- 90
					vsCache[count] = v -- 91
				end -- 88
				vs[count] = v -- 92
				count = count + 1 -- 93
				v = vsCache[count] -- 94
				if v then -- 95
					v = Vec2(posX, halfH) -- 95
				else -- 97
					v = Vec2(posX, halfH) -- 97
					vsCache[count] = v -- 98
				end -- 95
				vs[count] = v -- 99
				count = count + 1 -- 100
			end -- 100
			return self.intervalNode:set(vs, Color(0xffffffff)) -- 101
		end -- 45
		local updateIntervalTextScale -- 103
		updateIntervalTextScale = function(scale) -- 103
			return self.intervalNode:eachChild(function(child) -- 104
				child.scaleX = scale -- 105
			end) -- 105
		end -- 103
		self.makeScale = function(self, scale) -- 107
			scale = math.min(scale, 5) -- 108
			self.intervalNode.scaleX = scale -- 109
			updateIntervalTextScale(1 / scale) -- 111
			return updateLabels() -- 112
		end -- 107
		self.makeScaleTo = function(self, scale) -- 114
			do -- 115
				local _with_0 = self.intervalNode -- 115
				_with_0:perform(ScaleX(0.5, self.intervalNode.scaleX, scale, Ease.OutQuad)) -- 116
				_with_0:schedule(once(function() -- 118
					return cycle(0.5, function() -- 118
						return updateIntervalTextScale(1 / _with_0.scaleX) -- 118
					end) -- 118
				end)) -- 118
			end -- 115
			return updateLabels() -- 119
		end -- 114
		local _value = 0 -- 121
		local _max = 0 -- 122
		local _min = 0 -- 123
		do -- 125
			local _exp_0 = App.platform -- 125
			if "macOS" == _exp_0 or "Windows" == _exp_0 or "Linux" == _exp_0 then -- 126
				self:addChild((function() -- 127
					local _with_0 = Node() -- 127
					_with_0.size = Size(width, height) -- 128
					_with_0.touchEnabled = true -- 129
					_with_0.swallowMouseWheel = true -- 130
					_with_0:slot("MouseWheel", function(delta) -- 131
						local newVal = self:getValue() + delta.y * indent / 10 -- 132
						return self:setValue(_min < _max and math.min(math.max(_min, newVal), _max) or newVal) -- 133
					end) -- 131
					return _with_0 -- 127
				end)()) -- 127
			end -- 133
		end -- 133
		self.setIndent = function(self, ind) -- 135
			indent = ind -- 136
			for i, label in pairs(labels) do -- 137
				label.text = string.format("%.0f", ind * i / 100) -- 138
			end -- 138
		end -- 135
		self.getIndent = function(self) -- 139
			return indent -- 139
		end -- 139
		self.lastValue = nil -- 141
		self.setValue = function(self, v) -- 142
			_value = v -- 143
			local val = _min < _max and math.min(math.max(_value, _min), _max) or _value -- 144
			val = self.isFixed and Round(val / (indent / 10)) * (indent / 10) or val -- 145
			if val == -0 then -- 146
				val = 0 -- 146
			end -- 146
			if self.lastValue ~= val then -- 147
				self.lastValue = val -- 148
				self:emit("Changed", val) -- 149
			end -- 147
			local posX = v * 10 * interval / indent -- 150
			self.intervalNode.anchor = Vec2(posX / width, 0) -- 151
			return updateLabels() -- 152
		end -- 142
		self.getValue = function(self) -- 154
			return _value -- 154
		end -- 154
		self.getPos = function(self) -- 155
			return _value * 10 * interval / indent -- 155
		end -- 155
		self.setLimit = function(self, min, max) -- 157
			_max = max -- 158
			_min = min -- 159
		end -- 157
		local time = 0 -- 161
		local startPos = 0 -- 162
		local updateReset -- 163
		updateReset = function(deltaTime) -- 163
			if _min >= _max then -- 164
				return -- 164
			end -- 164
			local scale = self.intervalNode.scaleX -- 165
			time = time + deltaTime -- 166
			local t = time / 1 -- 167
			if scale < 1 then -- 168
				t = t / 0.1 -- 168
			end -- 168
			t = math.min(1, t) -- 169
			local yVal = nil -- 170
			if startPos < _min then -- 171
				yVal = startPos + (_min - startPos) * Ease:func(scale < 1 and Ease.Linear or Ease.OutElastic, t) -- 172
			elseif startPos > _max then -- 173
				yVal = startPos + (_max - startPos) * Ease:func(scale < 1 and Ease.Linear or Ease.OutElastic, t) -- 174
			end -- 171
			self:setValue(((yVal and yVal or 0) - _value) / scale + _value) -- 175
			if t == 1.0 then -- 176
				return self:unschedule() -- 176
			end -- 176
		end -- 163
		local isReseting -- 178
		isReseting = function() -- 178
			return _min < _max and (_value > _max or _value < _min) -- 179
		end -- 178
		local startReset -- 181
		startReset = function() -- 181
			startPos = _value -- 182
			time = 0 -- 183
			return self:schedule(updateReset) -- 184
		end -- 181
		local _v = 0 -- 186
		local _s = 0 -- 187
		local updateSpeed -- 188
		updateSpeed = function(deltaTime) -- 188
			if _s == 0 then -- 189
				return -- 189
			end -- 189
			_v = _s / deltaTime -- 190
			_s = 0 -- 191
		end -- 188
		local updatePos -- 193
		updatePos = function(deltaTime) -- 193
			local val = viewSize.height * 2 -- 194
			local a = _v > 0 and -val or val -- 195
			local yR = _v > 0 -- 196
			_v = _v + a * deltaTime -- 197
			if (_v < 0) == yR then -- 198
				_v = 0 -- 199
				a = 0 -- 200
			end -- 198
			local ds = _v * deltaTime + a * (0.5 * deltaTime * deltaTime) -- 201
			local newValue = _value - ds * indent / (interval * 10) -- 202
			self:setValue((newValue - _value) / self.intervalNode.scaleY + _value) -- 203
			if _v == 0 or isReseting() then -- 204
				if isReseting() then -- 205
					return startReset() -- 205
				else -- 206
					return self:unschedule() -- 206
				end -- 205
			end -- 204
		end -- 193
		self:slot("TapFilter", function(touch) -- 208
			if not touch.first then -- 209
				touch.enabled = false -- 209
			end -- 209
		end) -- 208
		self:slot("TapBegan", function() -- 211
			_s = 0 -- 212
			_v = 0 -- 213
			return self:schedule(updateSpeed) -- 214
		end) -- 211
		self:slot("TapMoved", function(touch) -- 216
			local deltaX = touch.delta.x -- 217
			local v = _value - deltaX * indent / (interval * 10) -- 218
			local padding = 0.5 * indent -- 219
			if _max > _min then -- 220
				local d = 1 -- 221
				if v > _max then -- 222
					d = (v - _max) * 3 / padding -- 223
				elseif v < _min then -- 224
					d = (_min - v) * 3 / padding -- 225
				end -- 222
				v = _value + (v - _value) / (d < 1 and 1 or d * d) -- 226
			end -- 220
			self:setValue((v - _value) / self.intervalNode.scaleX + _value) -- 227
			_s = _s + deltaX -- 228
		end) -- 216
		return self:slot("TapEnded", function() -- 230
			if isReseting() then -- 231
				return startReset() -- 232
			elseif _v ~= 0 then -- 233
				return self:schedule(updatePos) -- 234
			end -- 231
		end) -- 234
	end, -- 6
	show = function(self, default, min, max, ind, callback) -- 236
		self:setLimit(min, max) -- 237
		self:setIndent(ind) -- 238
		self:slot("Changed"):set(callback) -- 239
		self.lastValue = nil -- 240
		self:setValue(default) -- 241
		self.visible = true -- 242
		return self:perform(Spawn(Y(0.5, self.endPosY + 30, self.endPosY, Ease.OutBack), Opacity(0.3, self.opacity, 1))) -- 246
	end, -- 236
	hide = function(self) -- 248
		if not self.visible then -- 249
			return -- 249
		end -- 249
		self:slot("Changed", nil) -- 250
		self:unschedule() -- 251
		return self:perform(Sequence(Spawn(Y(0.5, self.y, self.endPosY + 30, Ease.InBack), Opacity(0.5, self.opacity, 0)), Hide())) -- 258
	end -- 248
}) -- 5
return _module_0 -- 258
