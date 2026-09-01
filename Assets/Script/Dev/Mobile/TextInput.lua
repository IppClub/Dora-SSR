-- [ts]: TextInput.ts
local ____lualib = require("lualib_bundle") -- 1
local Error = ____lualib.Error -- 1
local RangeError = ____lualib.RangeError -- 1
local ReferenceError = ____lualib.ReferenceError -- 1
local SyntaxError = ____lualib.SyntaxError -- 1
local TypeError = ____lualib.TypeError -- 1
local URIError = ____lualib.URIError -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArrayForEach = ____lualib.__TS__ArrayForEach -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local App = ____Dora.App -- 1
local ClipNode = ____Dora.ClipNode -- 1
local Color = ____Dora.Color -- 1
local Color3 = ____Dora.Color3 -- 1
local DrawNode = ____Dora.DrawNode -- 1
local Keyboard = ____Dora.Keyboard -- 1
local Label = ____Dora.Label -- 1
local Node = ____Dora.Node -- 1
local Size = ____Dora.Size -- 1
local sleep = ____Dora.sleep -- 1
local thread = ____Dora.thread -- 1
local Vec2 = ____Dora.Vec2 -- 1
local nvg = require("nvg") -- 2
____exports.inputLength = function(text) return (utf8.len(text)) or 0 end -- 4
____exports.inputSlice = function(text, start, ____end) -- 5
	if ____end == nil then -- 5
		____end = ____exports.inputLength(text) -- 5
	end -- 5
	local first = utf8.offset(text, start + 1) or #text + 1 -- 6
	local last = (utf8.offset(text, ____end + 1) or #text + 1) - 1 -- 7
	return string.sub(text, first, last) -- 8
end -- 5
____exports.insertInputText = function(text, at, inserted) return (____exports.inputSlice(text, 0, at) .. inserted) .. ____exports.inputSlice(text, at) end -- 10
function ____exports.layoutInput(text, width, advance) -- 14
	local x = 0 -- 15
	local row = 0 -- 15
	local stops = {{x = 0, row = 0}} -- 16
	local display = {} -- 17
	for ____, code in utf8.codes(text) do -- 18
		local char = utf8.char(code) -- 19
		if char == "\n" then -- 19
			display[#display + 1] = char -- 20
			row = row + 1 -- 20
			x = 0 -- 20
		else -- 20
			local step = advance(char) -- 22
			if x > 0 and x + step > width then -- 22
				display[#display + 1] = "\n" -- 24
				row = row + 1 -- 24
				x = 0 -- 24
				stops[#stops] = {x = x, row = row} -- 25
			end -- 25
			display[#display + 1] = char -- 27
			x = x + step -- 27
		end -- 27
		stops[#stops + 1] = {x = x, row = row} -- 29
	end -- 29
	return { -- 31
		text = table.concat(display, ""), -- 31
		stops = stops, -- 31
		rows = row + 1 -- 31
	} -- 31
end -- 14
function ____exports.createTextInputView(input, fontSize, singleLine, background) -- 34
	if singleLine == nil then -- 34
		singleLine = false -- 34
	end -- 34
	if background == nil then -- 34
		background = 4279704614 -- 34
	end -- 34
	local border = Node() -- 35
	border.tag = input.tag .. "-border" -- 35
	border.color3 = Color3(3423048) -- 36
	input:addChild(border, -1) -- 36
	input:onRender(function() -- 37
		nvg.Save() -- 38
		nvg.ApplyTransform(input) -- 38
		nvg.BeginPath() -- 39
		nvg.RoundedRect( -- 39
			0, -- 39
			0, -- 39
			input.width, -- 39
			input.height, -- 39
			12 -- 39
		) -- 39
		nvg.FillPaint(nvg.LinearGradient( -- 40
			0, -- 40
			input.height, -- 40
			0, -- 40
			0, -- 40
			Color(4280560955), -- 40
			Color(background) -- 40
		)) -- 40
		nvg.Fill() -- 41
		nvg.BeginPath() -- 42
		nvg.RoundedRect( -- 42
			0.75, -- 42
			0.75, -- 42
			input.width - 1.5, -- 42
			input.height - 1.5, -- 42
			11.25 -- 42
		) -- 42
		nvg.StrokeWidth(1.5) -- 43
		nvg.StrokeColor(Color(border.color3)) -- 43
		nvg.Stroke() -- 43
		nvg.Restore() -- 43
		return false -- 44
	end) -- 37
	local insetX = 12 -- 46
	local insetY = 8 -- 46
	local width = math.max(1, input.width - insetX * 2 - 2) -- 47
	local height = math.max(1, input.height - insetY * 2) -- 48
	local lineHeight = fontSize + 4 -- 49
	local function makeLabel() -- 50
		local label = Label("sarasa-mono-sc-regular", fontSize, true) -- 51
		if not label then -- 51
			error( -- 52
				__TS__New(Error, "Missing mobile input font"), -- 52
				0 -- 52
			) -- 52
		end -- 52
		label.alignment = "Left" -- 53
		label.anchor = Vec2(0, 1) -- 53
		label.textWidth = -1 -- 53
		return label -- 54
	end -- 50
	local measure = makeLabel() -- 58
	measure.tag = "remix-input-measure" -- 58
	measure.visible = false -- 58
	input:addChild(measure) -- 59
	measure.batched = false -- 60
	measure.text = "M" -- 60
	local ____opt_0 = measure:getCharacter(1) -- 60
	local markerX = ____opt_0 and ____opt_0.x or 0 -- 62
	local singleHeight = measure.height -- 63
	measure.text = "M\nM" -- 64
	local gap = measure.lineGap + lineHeight - (measure.height - singleHeight) -- 65
	local widths = {} -- 66
	local function advance(char) -- 67
		if widths[char] ~= nil then -- 67
			return widths[char] -- 68
		end -- 68
		measure.text = char .. "M" -- 69
		local ____math_max_4 = math.max -- 70
		local ____opt_2 = measure:getCharacter(2) -- 70
		local step = ____math_max_4(1, (____opt_2 and ____opt_2.x or markerX + fontSize) - markerX) -- 70
		widths[char] = step -- 71
		return step -- 72
	end -- 67
	local stencil = DrawNode() -- 74
	stencil:drawPolygon( -- 75
		{ -- 75
			Vec2.zero, -- 75
			Vec2(width + 2, 0), -- 75
			Vec2(width + 2, height), -- 75
			Vec2(0, height) -- 75
		}, -- 75
		Color(4294967295) -- 75
	) -- 75
	local clip = ClipNode(stencil) -- 76
	clip.tag = "remix-input-clip" -- 76
	clip.anchor = Vec2.zero -- 77
	clip.position = Vec2(insetX, insetY) -- 77
	clip.size = Size(width + 2, height) -- 77
	input:addChild(clip, 1) -- 78
	local content = Node() -- 79
	content.tag = "remix-input-content" -- 79
	clip:addChild(content) -- 79
	local label = makeLabel() -- 80
	label.tag = "remix-input-text" -- 80
	label.lineGap = gap -- 80
	label.color3 = Color3(16052712) -- 80
	content:addChild(label) -- 80
	local placeholder = makeLabel() -- 81
	placeholder.tag = "remix-input-placeholder" -- 81
	placeholder.lineGap = gap -- 81
	local textTop = singleLine and (height + singleHeight) / 2 or height -- 82
	placeholder.textWidth = singleLine and -1 or width -- 83
	placeholder.y = textTop -- 83
	placeholder.color3 = Color3(11055037) -- 83
	clip:addChild(placeholder) -- 83
	local caret = DrawNode() -- 84
	caret.tag = "remix-input-caret" -- 84
	caret:drawPolygon( -- 85
		{ -- 85
			Vec2.zero, -- 85
			Vec2(1, 0), -- 85
			Vec2(1, fontSize + 2), -- 85
			Vec2(0, fontSize + 2) -- 85
		}, -- 85
		Color(4294954035) -- 85
	) -- 85
	content:addChild(caret) -- 86
	local layout = ____exports.layoutInput("", width, advance) -- 87
	local lastText = "" -- 88
	local active = false -- 88
	local blink = 0 -- 88
	local offset = 0 -- 88
	local index = 0 -- 88
	local function maxOffset() -- 89
		return math.max(0, singleLine and layout.stops[#layout.stops].x - width or layout.rows * lineHeight - height) -- 89
	end -- 89
	local function position() -- 90
		content.x = singleLine and -offset or 0 -- 91
		content.y = singleLine and 0 or offset -- 92
		label.y = textTop -- 92
		local stop = layout.stops[index + 1] -- 93
		caret.position = Vec2( -- 94
			singleLine and stop.x or math.min(width, stop.x), -- 94
			singleLine and (height - fontSize - 2) / 2 or height - stop.row * lineHeight - fontSize - 2 -- 94
		) -- 94
	end -- 90
	local function follow() -- 96
		local stop = layout.stops[index + 1] -- 97
		if singleLine then -- 97
			if stop.x < offset then -- 97
				offset = stop.x -- 99
			end -- 99
			if stop.x > offset + width then -- 99
				offset = stop.x - width -- 100
			end -- 100
		else -- 100
			local top = stop.row * lineHeight -- 102
			if top < offset then -- 102
				offset = top -- 103
			end -- 103
			if top + lineHeight > offset + height then -- 103
				offset = top + lineHeight - height -- 104
			end -- 104
		end -- 104
		offset = math.max( -- 106
			0, -- 106
			math.min( -- 106
				maxOffset(), -- 106
				offset -- 106
			) -- 106
		) -- 106
		position() -- 106
	end -- 96
	caret:schedule(function(dt) -- 108
		blink = blink + dt -- 108
		caret.visible = active and (blink % 1 < 0.5 or App.reducedMotion) -- 108
		return false -- 108
	end) -- 108
	local function nearest(x, row) -- 109
		local closest = 0 -- 110
		local distance = math.huge -- 110
		__TS__ArrayForEach( -- 111
			layout.stops, -- 111
			function(____, stop, i) -- 111
				local d = math.abs(stop.row - row) * (width + 1) + math.abs(stop.x - x) -- 112
				if d < distance then -- 112
					distance = d -- 113
					closest = i -- 113
				end -- 113
			end -- 111
		) -- 111
		return closest -- 115
	end -- 109
	return { -- 117
		label = label, -- 118
		caret = caret, -- 118
		placeholder = placeholder, -- 118
		clip = clip, -- 118
		border = border, -- 118
		update = function(text, hint, focused, cursor) -- 119
			if singleLine then -- 119
				text = (string.gsub(text, "[\r\n]", "")) -- 120
			end -- 120
			if lastText ~= text then -- 120
				layout = ____exports.layoutInput(text, singleLine and math.huge or width, advance) -- 121
				label.text = layout.text -- 121
				lastText = text -- 121
			end -- 121
			placeholder.text = hint -- 122
			placeholder.visible = text == "" and not focused -- 122
			border.color3 = Color3(focused and 16763955 or 3423048) -- 123
			active = focused -- 124
			index = math.max( -- 124
				0, -- 124
				math.min(#layout.stops - 1, cursor) -- 124
			) -- 124
			blink = 0 -- 125
			caret.visible = active -- 125
			follow() -- 125
		end, -- 119
		caretPosition = function() return Vec2(insetX + caret.x + content.x, insetY + caret.y + content.y) end, -- 127
		indexAt = function(point) return nearest( -- 128
			point.x - insetX - content.x, -- 128
			singleLine and 0 or math.max( -- 128
				0, -- 128
				math.floor((height + offset - (point.y - insetY)) / lineHeight) -- 128
			) -- 128
		) end, -- 128
		verticalIndex = function(cursor, direction) -- 129
			local stop = layout.stops[math.min(cursor, #layout.stops - 1) + 1] -- 129
			return nearest(stop.x, stop.row + direction) -- 129
		end, -- 129
		scroll = function(delta) -- 130
			offset = math.max( -- 130
				0, -- 130
				math.min( -- 130
					maxOffset(), -- 130
					offset + delta -- 130
				) -- 130
			) -- 130
			position() -- 130
		end -- 130
	} -- 130
end -- 34
function ____exports.createTextInput(options) -- 147
	local node -- 148
	local view -- 149
	local focused = false -- 150
	local composition = "" -- 150
	local compositionCursor = 0 -- 150
	local cursor = 0 -- 150
	local revision = 0 -- 150
	local dragDistance = 0 -- 150
	local function normalize(text) -- 151
		return options.singleLine and (string.gsub(text, "[\r\n]", "")) or (string.gsub((string.gsub(text, "\r\n", "\n")), "\r", "\n")) -- 151
	end -- 151
	local function updateIMEPos(next) -- 153
		local target = node -- 154
		if not target or not view then -- 154
			return -- 155
		end -- 155
		local captured = revision -- 156
		local caret = view.caretPosition() -- 157
		target:convertToWindowSpace( -- 158
			Vec2( -- 158
				math.max( -- 158
					12, -- 158
					math.min(target.width - 12, caret.x) -- 158
				), -- 158
				math.max( -- 158
					8, -- 158
					math.min(target.height - 8, caret.y) -- 158
				) -- 158
			), -- 158
			function(pos) -- 158
				if node ~= target or captured ~= revision or not options.isEnabled() then -- 158
					return -- 159
				end -- 159
				Keyboard:updateIMEPosHint(pos) -- 160
				if next ~= nil then -- 160
					next() -- 160
				end -- 160
			end -- 158
		) -- 158
	end -- 153
	local function refresh() -- 163
		cursor = math.min( -- 164
			cursor, -- 164
			____exports.inputLength(options.getText()) -- 164
		) -- 164
		if view ~= nil then -- 164
			view.update( -- 165
				____exports.insertInputText( -- 165
					options.getText(), -- 165
					cursor, -- 165
					composition -- 165
				), -- 165
				options.getPlaceholder(), -- 165
				focused, -- 165
				cursor + compositionCursor -- 165
			) -- 165
		end -- 165
		if focused then -- 165
			updateIMEPos() -- 166
		end -- 166
	end -- 163
	local function clearFocus() -- 168
		revision = revision + 1 -- 169
		focused = false -- 169
		composition = "" -- 169
		compositionCursor = 0 -- 169
		if node then -- 169
			node.keyboardEnabled = false -- 170
		end -- 170
		refresh() -- 171
	end -- 168
	local function blur() -- 173
		if focused then -- 173
			if node ~= nil then -- 173
				node:detachIME() -- 173
			end -- 173
		end -- 173
		clearFocus() -- 173
	end -- 173
	local function focus(reopen) -- 174
		if reopen == nil then -- 174
			reopen = true -- 174
		end -- 174
		if not options.isEnabled() then -- 174
			return -- 175
		end -- 175
		revision = revision + 1 -- 176
		updateIMEPos(function() -- 177
			if reopen then -- 177
				if node ~= nil then -- 177
					node:detachIME() -- 178
				end -- 178
			end -- 178
			if node ~= nil then -- 178
				node:attachIME() -- 179
			end -- 179
			updateIMEPos() -- 179
		end) -- 177
	end -- 174
	local function setValue(text, at) -- 182
		options.setText(text) -- 182
		cursor = at -- 182
		refresh() -- 182
	end -- 182
	local function textInput(text) -- 183
		if not options.isEnabled() then -- 183
			return -- 184
		end -- 184
		composition = "" -- 185
		compositionCursor = 0 -- 185
		local value = normalize(text) -- 186
		setValue( -- 187
			____exports.insertInputText( -- 187
				options.getText(), -- 187
				cursor, -- 187
				value -- 187
			), -- 187
			cursor + ____exports.inputLength(value) -- 187
		) -- 187
	end -- 183
	local function keyInput(key) -- 189
		if not options.isEnabled() then -- 189
			return -- 190
		end -- 190
		if key == "Escape" then -- 190
			blur() -- 191
			return -- 191
		end -- 191
		if composition ~= "" then -- 191
			return -- 192
		end -- 192
		local value = options.getText() -- 193
		if key == "BackSpace" and cursor > 0 then -- 193
			setValue( -- 194
				____exports.inputSlice(value, 0, cursor - 1) .. ____exports.inputSlice(value, cursor), -- 194
				cursor - 1 -- 194
			) -- 194
		elseif key == "Delete" and cursor < ____exports.inputLength(value) then -- 194
			setValue( -- 195
				____exports.inputSlice(value, 0, cursor) .. ____exports.inputSlice(value, cursor + 1), -- 195
				cursor -- 195
			) -- 195
		elseif key == "Home" or key == "End" or key == "Left" or key == "Right" or key == "Up" or key == "Down" then -- 195
			cursor = key == "Home" and 0 or (key == "End" and ____exports.inputLength(value) or ((key == "Up" or key == "Down") and (view and view.verticalIndex(cursor, key == "Up" and -1 or 1) or cursor) or math.max( -- 197
				0, -- 199
				math.min( -- 199
					____exports.inputLength(value), -- 199
					cursor + (key == "Left" and -1 or 1) -- 199
				) -- 199
			))) -- 199
			refresh() -- 200
		elseif key == "Return" then -- 200
			local modified = Keyboard:isKeyPressed("LCtrl") or Keyboard:isKeyPressed("RCtrl") or Keyboard:isKeyPressed("LGui") or Keyboard:isKeyPressed("RGui") -- 202
			local ____opt_17 = options.onReturn -- 202
			if not (____opt_17 and ____opt_17(modified)) and not options.singleLine then -- 202
				textInput("\n") -- 203
			end -- 203
		end -- 203
	end -- 189
	local function unmount() -- 206
		blur() -- 206
		node = nil -- 206
		view = nil -- 206
	end -- 206
	return { -- 207
		refresh = refresh, -- 208
		focus = focus, -- 208
		blur = blur, -- 208
		unmount = unmount, -- 208
		isFocused = function() return focused end, -- 209
		isComposing = function() return composition ~= "" end, -- 210
		deferFocus = function() -- 211
			local captured = revision -- 212
			thread(function() -- 213
				sleep(0) -- 213
				if captured == revision then -- 213
					focus() -- 213
				end -- 213
			end) -- 213
		end, -- 211
		mount = function(target) -- 215
			unmount() -- 216
			node = target -- 216
			view = ____exports.createTextInputView(target, options.fontSize, options.singleLine, options.background) -- 217
			target.touchEnabled = true -- 218
			target.swallowTouches = true -- 218
			target:onAttachIME(function() -- 219
				focused = true -- 219
				composition = "" -- 219
				compositionCursor = 0 -- 219
				target.keyboardEnabled = true -- 219
				refresh() -- 219
			end) -- 219
			target:onDetachIME(clearFocus) -- 220
			target:onTextInput(textInput) -- 221
			target:onTextEditing(function(text, start) -- 222
				if not options.isEnabled() then -- 222
					return -- 223
				end -- 223
				composition = normalize(text) -- 224
				compositionCursor = math.max( -- 224
					0, -- 224
					math.min( -- 224
						____exports.inputLength(composition), -- 224
						start or ____exports.inputLength(composition) -- 224
					) -- 224
				) -- 224
				refresh() -- 224
			end) -- 222
			target:onKeyDown(keyInput) -- 226
			target.keyboardEnabled = false -- 226
			target:onTapBegan(function() -- 227
				dragDistance = 0 -- 227
			end) -- 227
			target:onTapMoved(function(touch) -- 228
				if not options.isEnabled() then -- 228
					return -- 229
				end -- 229
				dragDistance = dragDistance + (math.abs(touch.delta.x) + math.abs(touch.delta.y)) -- 230
				if view ~= nil then -- 230
					view.scroll(options.singleLine and -touch.delta.x or touch.delta.y) -- 231
				end -- 231
				if focused then -- 231
					updateIMEPos() -- 231
				end -- 231
			end) -- 228
			target:onMouseWheel(function(delta) -- 233
				if not options.isEnabled() then -- 233
					return -- 233
				end -- 233
				if view ~= nil then -- 233
					view.scroll(-delta.y * 20) -- 233
				end -- 233
				if focused then -- 233
					updateIMEPos() -- 233
				end -- 233
			end) -- 233
			target:onTapped(function(touch) -- 234
				if dragDistance > 5 or not options.isEnabled() then -- 234
					return -- 235
				end -- 235
				if touch ~= nil and composition == "" then -- 235
					cursor = view and view.indexAt(touch.location) or cursor -- 236
				end -- 236
				refresh() -- 237
				if not focused then -- 237
					focus() -- 237
				end -- 237
			end) -- 234
			target:onCleanup(function() -- 239
				if node == target then -- 239
					unmount() -- 239
				end -- 239
			end) -- 239
			refresh() -- 240
		end -- 215
	} -- 215
end -- 147
return ____exports -- 147