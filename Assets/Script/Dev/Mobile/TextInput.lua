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
local nvg = require("nvg") -- 3
____exports.inputLength = function(text) return (utf8.len(text)) or 0 end -- 5
____exports.inputSlice = function(text, start, ____end) -- 6
	if ____end == nil then -- 6
		____end = ____exports.inputLength(text) -- 6
	end -- 6
	local first = utf8.offset(text, start + 1) or #text + 1 -- 7
	local last = (utf8.offset(text, ____end + 1) or #text + 1) - 1 -- 8
	return string.sub(text, first, last) -- 9
end -- 6
____exports.insertInputText = function(text, at, inserted) return (____exports.inputSlice(text, 0, at) .. inserted) .. ____exports.inputSlice(text, at) end -- 11
function ____exports.layoutInput(text, width, advance) -- 15
	local x = 0 -- 16
	local row = 0 -- 16
	local stops = {{x = 0, row = 0}} -- 17
	local display = {} -- 18
	for ____, code in utf8.codes(text) do -- 19
		local char = utf8.char(code) -- 20
		if char == "\n" then -- 20
			display[#display + 1] = char -- 21
			row = row + 1 -- 21
			x = 0 -- 21
		else -- 21
			local step = advance(char) -- 23
			if x > 0 and x + step > width then -- 23
				display[#display + 1] = "\n" -- 25
				row = row + 1 -- 25
				x = 0 -- 25
				stops[#stops] = {x = x, row = row} -- 26
			end -- 26
			display[#display + 1] = char -- 28
			x = x + step -- 28
		end -- 28
		stops[#stops + 1] = {x = x, row = row} -- 30
	end -- 30
	return { -- 32
		text = table.concat(display, ""), -- 32
		stops = stops, -- 32
		rows = row + 1 -- 32
	} -- 32
end -- 15
function ____exports.createTextInputView(input, fontSize, singleLine, background, nativeSurface) -- 35
	if singleLine == nil then -- 35
		singleLine = false -- 35
	end -- 35
	if background == nil then -- 35
		background = 4279704614 -- 35
	end -- 35
	if nativeSurface == nil then -- 35
		nativeSurface = false -- 35
	end -- 35
	local border = Node() -- 36
	border.tag = input.tag .. "-border" -- 36
	border.color3 = Color3(3423048) -- 37
	input:addChild(border, -1) -- 37
	if nativeSurface then -- 37
		local w = input.width -- 41
		local h = input.height -- 41
		local r = math.min(12, w / 2, h / 2) -- 41
		local verts = {} -- 42
		for ____, corner in ipairs({{x = w - r, y = r, a = -math.pi / 2}, {x = w - r, y = h - r, a = 0}, {x = r, y = h - r, a = math.pi / 2}, {x = r, y = r, a = math.pi}}) do -- 43
			do -- 43
				local i = 0 -- 44
				while i <= 8 do -- 44
					local a = corner.a + i * math.pi / 16 -- 45
					verts[#verts + 1] = Vec2( -- 46
						corner.x + math.cos(a) * r, -- 46
						corner.y + math.sin(a) * r -- 46
					) -- 46
					i = i + 1 -- 44
				end -- 44
			end -- 44
		end -- 44
		local fill = DrawNode() -- 49
		fill:drawPolygon( -- 49
			verts, -- 49
			Color(background) -- 49
		) -- 49
		input:addChild(fill, -2) -- 49
		local outline = DrawNode() -- 50
		outline:drawPolygon( -- 50
			verts, -- 50
			Color(0), -- 50
			1.5, -- 50
			Color(4294967295) -- 50
		) -- 50
		border:addChild(outline) -- 50
	else -- 50
		input:onRender(function() -- 51
			nvg.Save() -- 52
			nvg.ApplyTransform(input) -- 52
			nvg.BeginPath() -- 53
			nvg.RoundedRect( -- 53
				0, -- 53
				0, -- 53
				input.width, -- 53
				input.height, -- 53
				12 -- 53
			) -- 53
			nvg.FillPaint(nvg.LinearGradient( -- 54
				0, -- 54
				input.height, -- 54
				0, -- 54
				0, -- 54
				Color(4280560955), -- 54
				Color(background) -- 54
			)) -- 54
			nvg.Fill() -- 55
			nvg.BeginPath() -- 56
			nvg.RoundedRect( -- 56
				0.75, -- 56
				0.75, -- 56
				input.width - 1.5, -- 56
				input.height - 1.5, -- 56
				11.25 -- 56
			) -- 56
			nvg.StrokeWidth(1.5) -- 57
			nvg.StrokeColor(Color(border.color3)) -- 57
			nvg.Stroke() -- 57
			nvg.Restore() -- 57
			return false -- 58
		end) -- 51
	end -- 51
	local insetX = 12 -- 60
	local insetY = 8 -- 60
	local width = math.max(1, input.width - insetX * 2 - 2) -- 61
	local height = math.max(1, input.height - insetY * 2) -- 62
	local lineHeight = fontSize + 4 -- 63
	local function makeLabel() -- 64
		local label = Label("sarasa-mono-sc-regular", fontSize, true) -- 65
		if not label then -- 65
			error( -- 66
				__TS__New(Error, "Missing mobile input font"), -- 66
				0 -- 66
			) -- 66
		end -- 66
		label.alignment = "Left" -- 67
		label.anchor = Vec2(0, 1) -- 67
		label.textWidth = -1 -- 67
		return label -- 68
	end -- 64
	local measure = makeLabel() -- 72
	measure.tag = "remix-input-measure" -- 72
	measure.visible = false -- 72
	input:addChild(measure) -- 73
	measure.batched = false -- 74
	measure.text = "M" -- 74
	local ____opt_0 = measure:getCharacter(1) -- 74
	local markerX = ____opt_0 and ____opt_0.x or 0 -- 76
	local singleHeight = measure.height -- 77
	measure.text = "M\nM" -- 78
	local gap = measure.lineGap + lineHeight - (measure.height - singleHeight) -- 79
	local widths = {} -- 80
	local function advance(char) -- 81
		if widths[char] ~= nil then -- 81
			return widths[char] -- 82
		end -- 82
		measure.text = char .. "M" -- 83
		local ____math_max_4 = math.max -- 84
		local ____opt_2 = measure:getCharacter(2) -- 84
		local step = ____math_max_4(1, (____opt_2 and ____opt_2.x or markerX + fontSize) - markerX) -- 84
		widths[char] = step -- 85
		return step -- 86
	end -- 81
	local stencil = DrawNode() -- 88
	stencil:drawPolygon( -- 89
		{ -- 89
			Vec2.zero, -- 89
			Vec2(width + 2, 0), -- 89
			Vec2(width + 2, height), -- 89
			Vec2(0, height) -- 89
		}, -- 89
		Color(4294967295) -- 89
	) -- 89
	local clip = ClipNode(stencil) -- 90
	clip.tag = "remix-input-clip" -- 90
	clip.anchor = Vec2.zero -- 91
	clip.position = Vec2(insetX, insetY) -- 91
	clip.size = Size(width + 2, height) -- 91
	input:addChild(clip, 1) -- 92
	local content = Node() -- 93
	content.tag = "remix-input-content" -- 93
	clip:addChild(content) -- 93
	local label = makeLabel() -- 94
	label.tag = "remix-input-text" -- 94
	label.lineGap = gap -- 94
	label.color3 = Color3(16052712) -- 94
	content:addChild(label) -- 94
	local placeholder = makeLabel() -- 95
	placeholder.tag = "remix-input-placeholder" -- 95
	placeholder.lineGap = gap -- 95
	local textTop = singleLine and (height + singleHeight) / 2 or height -- 96
	placeholder.textWidth = singleLine and -1 or width -- 97
	placeholder.y = textTop -- 97
	placeholder.color3 = Color3(11055037) -- 97
	clip:addChild(placeholder) -- 97
	local caret = DrawNode() -- 98
	caret.tag = "remix-input-caret" -- 98
	caret:drawPolygon( -- 99
		{ -- 99
			Vec2.zero, -- 99
			Vec2(1, 0), -- 99
			Vec2(1, fontSize + 2), -- 99
			Vec2(0, fontSize + 2) -- 99
		}, -- 99
		Color(4294954035) -- 99
	) -- 99
	content:addChild(caret) -- 100
	local layout = ____exports.layoutInput("", width, advance) -- 101
	local lastText = "" -- 102
	local active = false -- 102
	local blink = 0 -- 102
	local offset = 0 -- 102
	local index = 0 -- 102
	local function maxOffset() -- 103
		return math.max(0, singleLine and layout.stops[#layout.stops].x - width or layout.rows * lineHeight - height) -- 103
	end -- 103
	local function position() -- 104
		content.x = singleLine and -offset or 0 -- 105
		content.y = singleLine and 0 or offset -- 106
		label.y = textTop -- 106
		local stop = layout.stops[index + 1] -- 107
		caret.position = Vec2( -- 108
			singleLine and stop.x or math.min(width, stop.x), -- 108
			singleLine and (height - fontSize - 2) / 2 or height - stop.row * lineHeight - fontSize - 2 -- 108
		) -- 108
	end -- 104
	local function follow() -- 110
		local stop = layout.stops[index + 1] -- 111
		if singleLine then -- 111
			if stop.x < offset then -- 111
				offset = stop.x -- 113
			end -- 113
			if stop.x > offset + width then -- 113
				offset = stop.x - width -- 114
			end -- 114
		else -- 114
			local top = stop.row * lineHeight -- 116
			if top < offset then -- 116
				offset = top -- 117
			end -- 117
			if top + lineHeight > offset + height then -- 117
				offset = top + lineHeight - height -- 118
			end -- 118
		end -- 118
		offset = math.max( -- 120
			0, -- 120
			math.min( -- 120
				maxOffset(), -- 120
				offset -- 120
			) -- 120
		) -- 120
		position() -- 120
	end -- 110
	caret:schedule(function(dt) -- 122
		blink = blink + dt -- 122
		caret.visible = active and (blink % 1 < 0.5 or App.reducedMotion) -- 122
		return false -- 122
	end) -- 122
	local function nearest(x, row) -- 123
		local closest = 0 -- 124
		local distance = math.huge -- 124
		__TS__ArrayForEach( -- 125
			layout.stops, -- 125
			function(____, stop, i) -- 125
				local d = math.abs(stop.row - row) * (width + 1) + math.abs(stop.x - x) -- 126
				if d < distance then -- 126
					distance = d -- 127
					closest = i -- 127
				end -- 127
			end -- 125
		) -- 125
		return closest -- 129
	end -- 123
	return { -- 131
		label = label, -- 132
		caret = caret, -- 132
		placeholder = placeholder, -- 132
		clip = clip, -- 132
		border = border, -- 132
		update = function(text, hint, focused, cursor) -- 133
			if singleLine then -- 133
				text = (string.gsub(text, "[\r\n]", "")) -- 134
			end -- 134
			if lastText ~= text then -- 134
				layout = ____exports.layoutInput(text, singleLine and math.huge or width, advance) -- 135
				label.text = layout.text -- 135
				lastText = text -- 135
			end -- 135
			placeholder.text = hint -- 136
			placeholder.visible = text == "" and not focused -- 136
			border.color3 = Color3(focused and 16763955 or 3423048) -- 137
			active = focused -- 138
			index = math.max( -- 138
				0, -- 138
				math.min(#layout.stops - 1, cursor) -- 138
			) -- 138
			blink = 0 -- 139
			caret.visible = active -- 139
			follow() -- 139
		end, -- 133
		caretPosition = function() return Vec2(insetX + caret.x + content.x, insetY + caret.y + content.y) end, -- 141
		indexAt = function(point) return nearest( -- 142
			point.x - insetX - content.x, -- 142
			singleLine and 0 or math.max( -- 142
				0, -- 142
				math.floor((height + offset - (point.y - insetY)) / lineHeight) -- 142
			) -- 142
		) end, -- 142
		verticalIndex = function(cursor, direction) -- 143
			local stop = layout.stops[math.min(cursor, #layout.stops - 1) + 1] -- 143
			return nearest(stop.x, stop.row + direction) -- 143
		end, -- 143
		scroll = function(delta) -- 144
			offset = math.max( -- 144
				0, -- 144
				math.min( -- 144
					maxOffset(), -- 144
					offset + delta -- 144
				) -- 144
			) -- 144
			position() -- 144
		end -- 144
	} -- 144
end -- 35
function ____exports.createTextInput(options) -- 163
	local node -- 164
	local view -- 165
	local focused = false -- 166
	local composition = "" -- 166
	local compositionCursor = 0 -- 166
	local cursor = 0 -- 166
	local revision = 0 -- 166
	local dragDistance = 0 -- 166
	local function normalize(text) -- 167
		return options.singleLine and (string.gsub(text, "[\r\n]", "")) or (string.gsub((string.gsub(text, "\r\n", "\n")), "\r", "\n")) -- 167
	end -- 167
	local function updateIMEPos(next) -- 169
		local target = node -- 170
		if not target or not view then -- 170
			return -- 171
		end -- 171
		local captured = revision -- 172
		local caret = view.caretPosition() -- 173
		target:convertToWindowSpace( -- 174
			Vec2( -- 174
				math.max( -- 174
					12, -- 174
					math.min(target.width - 12, caret.x) -- 174
				), -- 174
				math.max( -- 174
					8, -- 174
					math.min(target.height - 8, caret.y) -- 174
				) -- 174
			), -- 174
			function(pos) -- 174
				if node ~= target or captured ~= revision or not options.isEnabled() then -- 174
					return -- 175
				end -- 175
				Keyboard:updateIMEPosHint(pos) -- 176
				if next ~= nil then -- 176
					next() -- 176
				end -- 176
			end -- 174
		) -- 174
	end -- 169
	local function refresh() -- 179
		local text = options.getText() -- 180
		cursor = math.min( -- 181
			cursor, -- 181
			____exports.inputLength(text) -- 181
		) -- 181
		local editing = ____exports.insertInputText(text, cursor, composition) -- 182
		local ____this_8 -- 182
		____this_8 = options -- 183
		local ____opt_7 = ____this_8.isSecure -- 183
		local display = ____opt_7 and ____opt_7(____this_8) and string.rep( -- 183
			"•", -- 183
			____exports.inputLength(editing) -- 183
		) or editing -- 183
		if view ~= nil then -- 183
			view.update( -- 184
				display, -- 184
				options.getPlaceholder(), -- 184
				focused, -- 184
				cursor + compositionCursor -- 184
			) -- 184
		end -- 184
		if focused then -- 184
			updateIMEPos() -- 185
		end -- 185
	end -- 179
	local function clearFocus() -- 187
		revision = revision + 1 -- 188
		focused = false -- 188
		composition = "" -- 188
		compositionCursor = 0 -- 188
		if node then -- 188
			node.keyboardEnabled = false -- 189
		end -- 189
		refresh() -- 190
	end -- 187
	local function blur() -- 192
		if focused then -- 192
			if node ~= nil then -- 192
				node:detachIME() -- 192
			end -- 192
		end -- 192
		clearFocus() -- 192
	end -- 192
	local function focus(reopen) -- 193
		if reopen == nil then -- 193
			reopen = true -- 193
		end -- 193
		if not options.isEnabled() then -- 193
			return -- 194
		end -- 194
		revision = revision + 1 -- 195
		updateIMEPos(function() -- 196
			if reopen then -- 196
				if node ~= nil then -- 196
					node:detachIME() -- 197
				end -- 197
			end -- 197
			if node ~= nil then -- 197
				node:attachIME() -- 198
			end -- 198
			updateIMEPos() -- 198
		end) -- 196
	end -- 193
	local function setValue(text, at) -- 201
		options.setText(text) -- 201
		cursor = at -- 201
		refresh() -- 201
	end -- 201
	local function textInput(text) -- 202
		if not options.isEnabled() then -- 202
			return -- 203
		end -- 203
		composition = "" -- 204
		compositionCursor = 0 -- 204
		local value = normalize(text) -- 205
		setValue( -- 206
			____exports.insertInputText( -- 206
				options.getText(), -- 206
				cursor, -- 206
				value -- 206
			), -- 206
			cursor + ____exports.inputLength(value) -- 206
		) -- 206
	end -- 202
	local function keyInput(key) -- 208
		if not options.isEnabled() then -- 208
			return -- 209
		end -- 209
		if key == "Escape" then -- 209
			blur() -- 210
			return -- 210
		end -- 210
		if composition ~= "" then -- 210
			return -- 211
		end -- 211
		local value = options.getText() -- 212
		if key == "BackSpace" and cursor > 0 then -- 212
			setValue( -- 213
				____exports.inputSlice(value, 0, cursor - 1) .. ____exports.inputSlice(value, cursor), -- 213
				cursor - 1 -- 213
			) -- 213
		elseif key == "Delete" and cursor < ____exports.inputLength(value) then -- 213
			setValue( -- 214
				____exports.inputSlice(value, 0, cursor) .. ____exports.inputSlice(value, cursor + 1), -- 214
				cursor -- 214
			) -- 214
		elseif key == "Home" or key == "End" or key == "Left" or key == "Right" or key == "Up" or key == "Down" then -- 214
			cursor = key == "Home" and 0 or (key == "End" and ____exports.inputLength(value) or ((key == "Up" or key == "Down") and (view and view.verticalIndex(cursor, key == "Up" and -1 or 1) or cursor) or math.max( -- 216
				0, -- 218
				math.min( -- 218
					____exports.inputLength(value), -- 218
					cursor + (key == "Left" and -1 or 1) -- 218
				) -- 218
			))) -- 218
			refresh() -- 219
		elseif key == "Return" then -- 219
			local modified = Keyboard:isKeyPressed("LCtrl") or Keyboard:isKeyPressed("RCtrl") or Keyboard:isKeyPressed("LGui") or Keyboard:isKeyPressed("RGui") -- 221
			local ____opt_19 = options.onReturn -- 221
			if not (____opt_19 and ____opt_19(modified)) and not options.singleLine then -- 221
				textInput("\n") -- 222
			end -- 222
		end -- 222
	end -- 208
	local function unmount() -- 225
		blur() -- 225
		node = nil -- 225
		view = nil -- 225
	end -- 225
	return { -- 226
		refresh = refresh, -- 227
		focus = focus, -- 227
		blur = blur, -- 227
		unmount = unmount, -- 227
		pasteFromClipboard = function(replace) -- 228
			if replace == nil then -- 228
				replace = false -- 228
			end -- 228
			if not options.isEnabled() then -- 228
				return false -- 229
			end -- 229
			local value = normalize(App:getClipboardText()) -- 230
			if value == "" then -- 230
				return false -- 231
			end -- 231
			if replace then -- 231
				setValue( -- 232
					value, -- 232
					____exports.inputLength(value) -- 232
				) -- 232
			else -- 232
				textInput(value) -- 233
			end -- 233
			return true -- 234
		end, -- 228
		isFocused = function() return focused end, -- 236
		isComposing = function() return composition ~= "" end, -- 237
		deferFocus = function() -- 238
			local captured = revision -- 239
			thread(function() -- 240
				sleep(0) -- 240
				if captured == revision then -- 240
					focus() -- 240
				end -- 240
			end) -- 240
		end, -- 238
		mount = function(target) -- 242
			unmount() -- 243
			node = target -- 243
			view = ____exports.createTextInputView( -- 244
				target, -- 244
				options.fontSize, -- 244
				options.singleLine, -- 244
				options.background, -- 244
				options.nativeSurface -- 244
			) -- 244
			target.touchEnabled = true -- 245
			target.swallowTouches = true -- 245
			target:slot( -- 246
				"GamepadActivate", -- 246
				function() -- 246
					if options.isEnabled() then -- 246
						focus() -- 246
					end -- 246
				end -- 246
			) -- 246
			target:onAttachIME(function() -- 247
				focused = true -- 247
				composition = "" -- 247
				compositionCursor = 0 -- 247
				target.keyboardEnabled = true -- 247
				refresh() -- 247
			end) -- 247
			target:onDetachIME(clearFocus) -- 248
			target:onTextInput(textInput) -- 249
			target:onTextEditing(function(text, start) -- 250
				if not options.isEnabled() then -- 250
					return -- 251
				end -- 251
				composition = normalize(text) -- 252
				compositionCursor = math.max( -- 252
					0, -- 252
					math.min( -- 252
						____exports.inputLength(composition), -- 252
						start or ____exports.inputLength(composition) -- 252
					) -- 252
				) -- 252
				refresh() -- 252
			end) -- 250
			target:onKeyDown(keyInput) -- 254
			target.keyboardEnabled = false -- 254
			target:onTapBegan(function() -- 255
				dragDistance = 0 -- 255
			end) -- 255
			target:onTapMoved(function(touch) -- 256
				if not options.isEnabled() then -- 256
					return -- 257
				end -- 257
				dragDistance = dragDistance + (math.abs(touch.delta.x) + math.abs(touch.delta.y)) -- 258
				if view ~= nil then -- 258
					view.scroll(options.singleLine and -touch.delta.x or touch.delta.y) -- 259
				end -- 259
				if focused then -- 259
					updateIMEPos() -- 259
				end -- 259
			end) -- 256
			target:onMouseWheel(function(delta) -- 261
				if not options.isEnabled() then -- 261
					return -- 261
				end -- 261
				if view ~= nil then -- 261
					view.scroll(-delta.y * 20) -- 261
				end -- 261
				if focused then -- 261
					updateIMEPos() -- 261
				end -- 261
			end) -- 261
			target:onTapped(function(touch) -- 262
				if dragDistance > 5 or not options.isEnabled() then -- 262
					return -- 263
				end -- 263
				if touch ~= nil and composition == "" then -- 263
					cursor = view and view.indexAt(touch.location) or cursor -- 264
				end -- 264
				refresh() -- 265
				if not focused then -- 265
					focus() -- 265
				end -- 265
			end) -- 262
			target:onCleanup(function() -- 267
				if node == target then -- 267
					unmount() -- 267
				end -- 267
			end) -- 267
			refresh() -- 268
		end -- 242
	} -- 242
end -- 163
return ____exports -- 163