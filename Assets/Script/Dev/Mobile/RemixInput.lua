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
	local measure = makeLabel() -- 44
	measure.batched = false -- 44
	measure.text = "M" -- 44
	local ____opt_0 = measure:getCharacter(1) -- 44
	local markerX = ____opt_0 and ____opt_0.x or 0 -- 46
	local singleHeight = measure.height -- 47
	measure.text = "M\nM" -- 48
	local gap = measure.lineGap + lineHeight - (measure.height - singleHeight) -- 49
	local widths = {} -- 50
	local function advance(char) -- 51
		if widths[char] ~= nil then -- 51
			return widths[char] -- 52
		end -- 52
		measure.text = char .. "M" -- 53
		local ____math_max_4 = math.max -- 54
		local ____opt_2 = measure:getCharacter(2) -- 54
		local step = ____math_max_4(1, (____opt_2 and ____opt_2.x or markerX + fontSize) - markerX) -- 54
		widths[char] = step -- 55
		return step -- 56
	end -- 51
	local stencil = DrawNode() -- 58
	stencil:drawPolygon( -- 59
		{ -- 59
			Vec2.zero, -- 59
			Vec2(width + 2, 0), -- 59
			Vec2(width + 2, height), -- 59
			Vec2(0, height) -- 59
		}, -- 59
		Color(4294967295) -- 59
	) -- 59
	local clip = ClipNode(stencil) -- 60
	clip.tag = "remix-input-clip" -- 60
	clip.anchor = Vec2.zero -- 61
	clip.position = Vec2(insetX, insetY) -- 61
	clip.size = Size(width + 2, height) -- 61
	input:addChild(clip, 1) -- 62
	local content = Node() -- 63
	content.tag = "remix-input-content" -- 63
	clip:addChild(content) -- 63
	local label = makeLabel() -- 64
	label.tag = "remix-input-text" -- 64
	label.lineGap = gap -- 64
	label.color3 = Color3(16052712) -- 64
	content:addChild(label) -- 64
	local placeholder = makeLabel() -- 65
	placeholder.tag = "remix-input-placeholder" -- 65
	placeholder.lineGap = gap -- 65
	placeholder.textWidth = width -- 66
	placeholder.y = height -- 66
	placeholder.color3 = Color3(11055037) -- 66
	clip:addChild(placeholder) -- 66
	local caret = DrawNode() -- 67
	caret.tag = "remix-input-caret" -- 67
	caret:drawPolygon( -- 68
		{ -- 68
			Vec2.zero, -- 68
			Vec2(1, 0), -- 68
			Vec2(1, fontSize + 2), -- 68
			Vec2(0, fontSize + 2) -- 68
		}, -- 68
		Color(4294954035) -- 68
	) -- 68
	content:addChild(caret) -- 69
	local layout = ____exports.layoutInput("", width, advance) -- 70
	local lastText = "" -- 71
	local active = false -- 71
	local blink = 0 -- 71
	local offset = 0 -- 71
	local index = 0 -- 71
	local function maxOffset() -- 72
		return math.max(0, layout.rows * lineHeight - height) -- 72
	end -- 72
	local function position() -- 73
		content.y = offset -- 74
		label.y = height -- 74
		local stop = layout.stops[index + 1] -- 75
		caret.position = Vec2( -- 76
			math.min(width, stop.x), -- 76
			height - stop.row * lineHeight - fontSize - 2 -- 76
		) -- 76
	end -- 73
	local function follow() -- 78
		local stop = layout.stops[index + 1] -- 79
		local top = stop.row * lineHeight -- 80
		if top < offset then -- 80
			offset = top -- 81
		end -- 81
		if top + lineHeight > offset + height then -- 81
			offset = top + lineHeight - height -- 82
		end -- 82
		offset = math.max( -- 83
			0, -- 83
			math.min( -- 83
				maxOffset(), -- 83
				offset -- 83
			) -- 83
		) -- 83
		position() -- 83
	end -- 78
	caret:schedule(function(dt) -- 85
		blink = blink + dt -- 85
		caret.visible = active and (blink % 1 < 0.5 or App.reducedMotion) -- 85
		return false -- 85
	end) -- 85
	local function nearest(x, row) -- 86
		local closest = 0 -- 87
		local distance = math.huge -- 87
		__TS__ArrayForEach( -- 88
			layout.stops, -- 88
			function(____, stop, i) -- 88
				local d = math.abs(stop.row - row) * (width + 1) + math.abs(stop.x - x) -- 89
				if d < distance then -- 89
					distance = d -- 90
					closest = i -- 90
				end -- 90
			end -- 88
		) -- 88
		return closest -- 92
	end -- 86
	return { -- 94
		label = label, -- 95
		caret = caret, -- 95
		placeholder = placeholder, -- 95
		clip = clip, -- 95
		update = function(text, hint, focused, cursor) -- 96
			if lastText ~= text then -- 96
				layout = ____exports.layoutInput(text, width, advance) -- 97
				label.text = layout.text -- 97
				lastText = text -- 97
			end -- 97
			placeholder.text = hint -- 98
			placeholder.visible = text == "" and not focused -- 98
			active = focused -- 99
			index = math.max( -- 99
				0, -- 99
				math.min(#layout.stops - 1, cursor) -- 99
			) -- 99
			blink = 0 -- 100
			caret.visible = active -- 100
			follow() -- 100
		end, -- 96
		caretPosition = function() return Vec2(insetX + caret.x, insetY + caret.y + offset) end, -- 102
		indexAt = function(point) return nearest( -- 103
			point.x - insetX, -- 103
			math.max( -- 103
				0, -- 103
				math.floor((height + offset - (point.y - insetY)) / lineHeight) -- 103
			) -- 103
		) end, -- 103
		verticalIndex = function(cursor, direction) -- 104
			local stop = layout.stops[math.min(cursor, #layout.stops - 1) + 1] -- 104
			return nearest(stop.x, stop.row + direction) -- 104
		end, -- 104
		scroll = function(delta) -- 105
			offset = math.max( -- 105
				0, -- 105
				math.min( -- 105
					maxOffset(), -- 105
					offset + delta -- 105
				) -- 105
			) -- 105
			position() -- 105
		end -- 105
	} -- 105
end -- 33
return ____exports -- 33