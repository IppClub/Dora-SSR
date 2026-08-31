-- [ts]: RemixInput.ts
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
local Label = ____Dora.Label -- 1
local Node = ____Dora.Node -- 1
local Size = ____Dora.Size -- 1
local Vec2 = ____Dora.Vec2 -- 1
____exports.inputLength = function(text) return (utf8.len(text)) or 0 end -- 3
____exports.inputSlice = function(text, start, ____end) -- 4
	if ____end == nil then -- 4
		____end = ____exports.inputLength(text) -- 4
	end -- 4
	local first = utf8.offset(text, start + 1) or #text + 1 -- 5
	local last = (utf8.offset(text, ____end + 1) or #text + 1) - 1 -- 6
	return string.sub(text, first, last) -- 7
end -- 4
____exports.insertInputText = function(text, at, inserted) return (____exports.inputSlice(text, 0, at) .. inserted) .. ____exports.inputSlice(text, at) end -- 9
function ____exports.layoutInput(text, width, advance) -- 13
	local x = 0 -- 14
	local row = 0 -- 14
	local stops = {{x = 0, row = 0}} -- 15
	local display = {} -- 16
	for ____, code in utf8.codes(text) do -- 17
		local char = utf8.char(code) -- 18
		if char == "\n" then -- 18
			display[#display + 1] = char -- 19
			row = row + 1 -- 19
			x = 0 -- 19
		else -- 19
			local step = advance(char) -- 21
			if x > 0 and x + step > width then -- 21
				display[#display + 1] = "\n" -- 23
				row = row + 1 -- 23
				x = 0 -- 23
				stops[#stops] = {x = x, row = row} -- 24
			end -- 24
			display[#display + 1] = char -- 26
			x = x + step -- 26
		end -- 26
		stops[#stops + 1] = {x = x, row = row} -- 28
	end -- 28
	return { -- 30
		text = table.concat(display, ""), -- 30
		stops = stops, -- 30
		rows = row + 1 -- 30
	} -- 30
end -- 13
function ____exports.createRemixInputView(input, fontSize) -- 33
	local insetX = 12 -- 34
	local insetY = 8 -- 34
	local width = math.max(1, input.width - insetX * 2 - 2) -- 35
	local height = math.max(1, input.height - insetY * 2) -- 36
	local lineHeight = fontSize + 4 -- 37
	local function makeLabel() -- 38
		local label = Label("sarasa-mono-sc-regular", fontSize, true) -- 39
		if not label then -- 39
			error( -- 40
				__TS__New(Error, "Missing Remix input font"), -- 40
				0 -- 40
			) -- 40
		end -- 40
		label.alignment = "Left" -- 41
		label.anchor = Vec2(0, 1) -- 41
		label.textWidth = -1 -- 41
		return label -- 42
	end -- 38
	local measure = makeLabel() -- 46
	measure.tag = "remix-input-measure" -- 46
	measure.visible = false -- 46
	input:addChild(measure) -- 47
	measure.batched = false -- 48
	measure.text = "M" -- 48
	local ____opt_0 = measure:getCharacter(1) -- 48
	local markerX = ____opt_0 and ____opt_0.x or 0 -- 50
	local singleHeight = measure.height -- 51
	measure.text = "M\nM" -- 52
	local gap = measure.lineGap + lineHeight - (measure.height - singleHeight) -- 53
	local widths = {} -- 54
	local function advance(char) -- 55
		if widths[char] ~= nil then -- 55
			return widths[char] -- 56
		end -- 56
		measure.text = char .. "M" -- 57
		local ____math_max_4 = math.max -- 58
		local ____opt_2 = measure:getCharacter(2) -- 58
		local step = ____math_max_4(1, (____opt_2 and ____opt_2.x or markerX + fontSize) - markerX) -- 58
		widths[char] = step -- 59
		return step -- 60
	end -- 55
	local stencil = DrawNode() -- 62
	stencil:drawPolygon( -- 63
		{ -- 63
			Vec2.zero, -- 63
			Vec2(width + 2, 0), -- 63
			Vec2(width + 2, height), -- 63
			Vec2(0, height) -- 63
		}, -- 63
		Color(4294967295) -- 63
	) -- 63
	local clip = ClipNode(stencil) -- 64
	clip.tag = "remix-input-clip" -- 64
	clip.anchor = Vec2.zero -- 65
	clip.position = Vec2(insetX, insetY) -- 65
	clip.size = Size(width + 2, height) -- 65
	input:addChild(clip, 1) -- 66
	local content = Node() -- 67
	content.tag = "remix-input-content" -- 67
	clip:addChild(content) -- 67
	local label = makeLabel() -- 68
	label.tag = "remix-input-text" -- 68
	label.lineGap = gap -- 68
	label.color3 = Color3(16052712) -- 68
	content:addChild(label) -- 68
	local placeholder = makeLabel() -- 69
	placeholder.tag = "remix-input-placeholder" -- 69
	placeholder.lineGap = gap -- 69
	placeholder.textWidth = width -- 70
	placeholder.y = height -- 70
	placeholder.color3 = Color3(11055037) -- 70
	clip:addChild(placeholder) -- 70
	local caret = DrawNode() -- 71
	caret.tag = "remix-input-caret" -- 71
	caret:drawPolygon( -- 72
		{ -- 72
			Vec2.zero, -- 72
			Vec2(1, 0), -- 72
			Vec2(1, fontSize + 2), -- 72
			Vec2(0, fontSize + 2) -- 72
		}, -- 72
		Color(4294954035) -- 72
	) -- 72
	content:addChild(caret) -- 73
	local layout = ____exports.layoutInput("", width, advance) -- 74
	local lastText = "" -- 75
	local active = false -- 75
	local blink = 0 -- 75
	local offset = 0 -- 75
	local index = 0 -- 75
	local function maxOffset() -- 76
		return math.max(0, layout.rows * lineHeight - height) -- 76
	end -- 76
	local function position() -- 77
		content.y = offset -- 78
		label.y = height -- 78
		local stop = layout.stops[index + 1] -- 79
		caret.position = Vec2( -- 80
			math.min(width, stop.x), -- 80
			height - stop.row * lineHeight - fontSize - 2 -- 80
		) -- 80
	end -- 77
	local function follow() -- 82
		local stop = layout.stops[index + 1] -- 83
		local top = stop.row * lineHeight -- 84
		if top < offset then -- 84
			offset = top -- 85
		end -- 85
		if top + lineHeight > offset + height then -- 85
			offset = top + lineHeight - height -- 86
		end -- 86
		offset = math.max( -- 87
			0, -- 87
			math.min( -- 87
				maxOffset(), -- 87
				offset -- 87
			) -- 87
		) -- 87
		position() -- 87
	end -- 82
	caret:schedule(function(dt) -- 89
		blink = blink + dt -- 89
		caret.visible = active and (blink % 1 < 0.5 or App.reducedMotion) -- 89
		return false -- 89
	end) -- 89
	local function nearest(x, row) -- 90
		local closest = 0 -- 91
		local distance = math.huge -- 91
		__TS__ArrayForEach( -- 92
			layout.stops, -- 92
			function(____, stop, i) -- 92
				local d = math.abs(stop.row - row) * (width + 1) + math.abs(stop.x - x) -- 93
				if d < distance then -- 93
					distance = d -- 94
					closest = i -- 94
				end -- 94
			end -- 92
		) -- 92
		return closest -- 96
	end -- 90
	return { -- 98
		label = label, -- 99
		caret = caret, -- 99
		placeholder = placeholder, -- 99
		clip = clip, -- 99
		update = function(text, hint, focused, cursor) -- 100
			if lastText ~= text then -- 100
				layout = ____exports.layoutInput(text, width, advance) -- 101
				label.text = layout.text -- 101
				lastText = text -- 101
			end -- 101
			placeholder.text = hint -- 102
			placeholder.visible = text == "" and not focused -- 102
			active = focused -- 103
			index = math.max( -- 103
				0, -- 103
				math.min(#layout.stops - 1, cursor) -- 103
			) -- 103
			blink = 0 -- 104
			caret.visible = active -- 104
			follow() -- 104
		end, -- 100
		caretPosition = function() return Vec2(insetX + caret.x, insetY + caret.y + offset) end, -- 106
		indexAt = function(point) return nearest( -- 107
			point.x - insetX, -- 107
			math.max( -- 107
				0, -- 107
				math.floor((height + offset - (point.y - insetY)) / lineHeight) -- 107
			) -- 107
		) end, -- 107
		verticalIndex = function(cursor, direction) -- 108
			local stop = layout.stops[math.min(cursor, #layout.stops - 1) + 1] -- 108
			return nearest(stop.x, stop.row + direction) -- 108
		end, -- 108
		scroll = function(delta) -- 109
			offset = math.max( -- 109
				0, -- 109
				math.min( -- 109
					maxOffset(), -- 109
					offset + delta -- 109
				) -- 109
			) -- 109
			position() -- 109
		end -- 109
	} -- 109
end -- 33
return ____exports -- 33